-- $Name:Crash Dive!$
-- $Version:0.2.0$

-- vim: set fileencoding=utf-8 nobomb foldmethod=syntax nofoldenable foldnestmax=1:

instead_version '1.9.1'

--require 'dbg'

require 'xact'
require 'hideinv'
require 'kroom'

game.use = "That’s not possible...";
game.inv = "A strange thing..."
game.act = "Nothing happens"

game.codepage="UTF-8"

-- FUNCTIONS + GLOBALS

function init()
    take(eyes); 
    take(ears); 
    take(nose);
    take(mouth); 
    take(feet);
    lifeon(radiation, 4);
end; 

global {
    -- 0 = not holding breath
    gl_holdbreathtimer = 0, 

    -- result will be 8..128 in steps of 8
    gl_encrypted_x = rnd(16) * 8,
    gl_encrypted_y = rnd(16) * 8,

    gl_destination_x = rnd(16) * 8,
    gl_destination_y = rnd(16) * 8,

    gl_activated_arming = false,
}

-- ROOMS

about = room {
    nam = 'About original game',
    dsc = [[Original game «Crash Dive!» by Brian Moriarty in published in April 
            1984 issue of Analog Computing magazin for the Atari 8-bit family.^^
            In the original game commands had to be typed. 
            For example: "EXAMINE SCREWDRIVER".
            This adaption has been made playable by mouse or touch interface. 
            That required some changes from the original game.
            Additional objects were added to allow multiple interactions on a single object. 
            The original game uses North, South, West and East for movement. 
            They have been replaced by Afore, Astern, Aport and Astarboard to make them unambiguous. 
          ]],
    obj = { vway("1", "{Back to main menu}", 'main') },
    hideinv = true,
};

access_tunnel = room {
    nam = 'Access tunnel',
    obj = {
        obj {
            nam = 'sign',
            dsc = 'There is a {sign}.',
            act = 'DANGER: Radiation zone!',
        },
    },
    kway = {
        kroom('sonar_sphere', 'n'),
        kroom('forward_passage', 's'),
    },
}

ballast_control = room {
    nam = "Ballast control",
    obj = {
        'depth_gauge',
        'red_button',
    },
    kway = {
        kroom('command_station', 'e'),
    }
}

captains_quarters = room {
    nam = "Captain's quarters",
    obj = {
        obj {
            nam = "Dead captain",
            dsc = "The {captain} lays here, he is dead.",
            act =  function(s)
                if security_id:disabled() then
                    security_id:enable()
                    p "You found something."
                else
                    p "He is dead..."
                end
            end,
        },
        obj {
            nam = "Suicide note",
            dsc = "a suicide {note}",
        },
        'security_id',
    },
    kway = {
        kroom('forward_passage', 'e'),
    },
}:disable();

closed_eyes = room {
    nam = '',
    dsc = [[You can't see anything!]],
};

command_station = room {
    nam = 'Command station',
    obj = {
        'periscope',
    },
    kway = {
        kroom('missile_control', 'd'),
        kroom('long_corridor', 'n'),
        kroom('navigation_center', 'e'),
        kroom('ballast_control', 'w'),
    },
}

congratulations = room {
    nam = 'Congratulations',
    hideinv = true,
    dsc = "mission accomplished",
}

crews_quarters = room {
    nam = "Crew's quarters",
    obj = {
        'card',
    },
    kway = {
        kroom('forward_passage', 'u'),
        kroom('torpedo_room', 'n'),
        kroom('galley', 'e'),
        kroom('missile_control', 's'),
        kroom('shower_stalls', 'w'),
    },
}

dead = room {
    nam = 'You are dead',
    hideinv = true,
}

equipment_bay = room {
    nam = 'Equipment bay',
    obj = {
        'radiation_suit',
    },
    kway = {
        kroom('missile_control', 'w'),
    },
}

escape_tube = room {
    forcedsc = true,
    nam = 'Escape tube',
    dsc = [[You are in the escape tube. There is a {hatch|hatch} in the floor. It has a {hatch_handle|handle} to open it.]],
    entered = function(s)
        lifeon(enemy, 6);
    end,
    obj = { 
        xact('hatch', 'It is airtight'),
        xact('hatch_handle', code[[
            if not forward_passage:disabled() then
                p "You close the hatch."
                forward_passage:disable()
            else
                p "You open the hatch."
                forward_passage:enable()
                lifeon(poison, 5)
            end
        ]]),
        'screwdriver',
    },
    kway = {
        kroom('forward_passage', 'd'):disable(),
    },
};

fan_room = room {
    nam = 'Fan room',
    var {
        -- this gives time for one action.
        -- if you look at the traitor you see the result,
        -- but you will be shot if you try to leave
        countdown = 3,
    },
    obj = {
        'traitor',
    },
    kway = {
        kroom('missile_control', 'e'),
    },
    entered = function(s)
        if traitor.alive then
            if (have(sonarunit)) then
                -- walking with the radioactive unit to the room where the
                -- traitor is, would be an attack so he kills you instantly.
                -- find a different way
                -- this limitation is not in the original game, but the
                -- sonarunit would also not kill the traitor
                s.countdown = 0
            end
            lifeon(s);
        end
    end,
    left = function(s)
        -- if the traitor has seen you, he will kill you if you try to run
        if traitor.alive then
            s.countdown = 0
        end
    end,
    life = function(s)
        if s.countdown > 0 then
            s.countdown = s.countdown - 1
        end
        if s.countdown == 0 then
            walkin('dead')
            p "The traitor shoots you and kills you instantly!"
        end
    end,
}

forward_passage = room {
    nam = 'Forward passage',
    obj = {
        obj {
            nam = 'door',
            dsc = function(s)
                if captains_quarters:disabled() then
                    p 'There is a closed {door}'
                else
                    p 'There is an open {door}'
                end
            end,
            act = function(s)
                if captains_quarters:disabled() then
                    p 'The lock is very secure, you cannot open it.'
                else
                    p 'There lock is broken'
                end
            end,
            used = function(s, w)
                if w == key then
                    p "Key won't fit"
                elseif w == pistol then
                    captains_quarters:enable()
                    p "Lock destroyed!"
                end
            end,
        },
    },
    kway = {
        kroom('escape_tube', 'u'),
        kroom('crews_quarters', 'd'),
        kroom('access_tunnel', 'n'),
        kroom('long_corridor', 's'),
        kroom('captains_quarters', 'w'),
    },
}

galley = room {
    nam = 'Galley',
    obj = {
        'knife',
    },
    kway = {
        kroom('crews_quarters', 'w'),
    },
}

intro = room {
    nam = 'Intro',
    dsc = [[You're on maintenance duty aboard the USS Sea Moss, patrolling the icy North Atlantic waters
            with an arsenal of twenty nuclear missiles. ^^

            The Sea Moss is no ordinary sub. She's the first to carry the Navy's new experimental 
            sonar-jammer that can make her "invisible" to even the most sophisticated enemy sensors. The 
            50-kiloton cruisers in her missile bay are the pride of the Pentagon: fast, silent, incredibly
            accurate. ^^

            The enemy would love to get their hands on the Sea Moss and her secrets. It's not likely
            to happen, though. The only way they could possibly breach the hull would be from the inside
            - and your fellow crewmembers have been carefully handpicked for their unswerving patriotism
            and utter lack of imagination. No "moles" in this bunch of sailors. No, sir! ^^

            The intercom in the equipment bay clicks to life. "I've got a bad line in the forward escape
            tube," a voice from the command deck crackles. "Wanna come up here and take a look at it?"
            You grab a screwdriver, scoot up a ladder and slam the hatch of the escape tube behind you.
            It's all over in a few seconds. The General Quarters klaxxon blares to life. You hear the 
            shrieks and choked coughing of friends as they stumble through the passages outside, and a
            single hoarse shout: "Gas!" Some poor sucker pounds weakly on the escape hatch. Then the alarm
            cuts off as suddenly as it began. Everything is silent as death. Frozen with fear, you sit
            trembling in the airtight escape tube, knowing that now it's just you and the Sea Moss against
            whoever shut off the alarm. ^^
          ]],
    obj = { vway("1", "{Start}", 'escape_tube') },
    hideinv = true,
};

long_corridor = room {
    nam = 'Long corridor',
    obj = {
    },
    kway = {
        kroom('forward_passage', 'n'),
        kroom('sonar_station', 'e'),
        kroom('command_station', 's'),
        kroom('radio_room', 'w'),
    },
}

lower_missile_bay = room {
    nam = 'Lower missile bay',
    obj = {
        obj {
            nam = "arming switch",
            dsc = function (s)
                if gl_activated_arming then
                    p "Activated arming {switch}."
                else
                    p "locked arming {switch}."
                end
            end,
            act = "lock is very secure",
            used = function(s, w)
                if w == key then
                    gl_activated_arming = not gl_activated_arming
                    if gl_activated_arming then
                        p "You activated the arming lock."
                    else
                        p "You deactivated the arming lock."
                    end
                end
            end,
        },
    },
    kway = {
        kroom('missile_control', 'n'),
        kroom('upper_missile_bay', 'u'),
    },
}:disable();

main = room {
    nam = 'Crash Dive!',
    obj = { 
            vway('1', '{About original game}^^', 'about'),
            vway('2', '{Start game}', 'intro')
    },
    hideinv = true,
};

missile_control = room {
    nam = "Missile control",
    obj = {
        obj {
            nam = 'airlock',
            dsc = function(s)
                if lower_missile_bay:disabled() then
                    p "There is a closed airlock with a {slot} next to it."
                else
                    p "There is a open airlock with a {slot} next to it."
                end
            end,
            act = "It accepts a security ID card.",
            used = function(s, w)
                if w == card then
                    p "Did you look at the card?"
                elseif w == security_id then
                    lower_missile_bay:enable()
                    remove(w, me())
                    p "The airlock is opened"
                end
            end,
        },
        obj {
            nam = 'white button',
            dsc = "There is a {white button}",
            act = function(s)
                if gl_activated_arming
                        and gl_encrypted_x == gl_destination_x
                        and gl_encrypted_y == gl_destination_y then
                    walkin('congratulations')
                    p "You have finished this game"
                else
                    p "Nothing happens."
                end
            end,
        },
    },
    kway = {
        kroom('command_station', 'u'),
        kroom('crews_quarters', 'n'),
        kroom('equipment_bay', 'e'),
        kroom('lower_missile_bay', 's'),
        kroom('fan_room', 'w'),
    },
}

navigation_center = room {
    nam = 'Navigation center',
    obj = {
        obj{
            nam = "Digital display",
            dsc = "Digital {display}",
            act = function(s)
                p('X='..tostring(gl_encrypted_x)..' Y='..tostring(gl_encrypted_y))
            end,
        },
        obj{
            nam = "Tactics manual",
            dsc = "Tactics {manual}",
        },
    },
    kway = {
        kroom('command_station', 'w'),
    },
}

radio_room = room {
    nam = 'Radio room',
    obj = {
        'cable_cutters',
    },
    kway = {
        kroom('long_corridor', 'e'),
    },
}

shower_stalls = room {
    nam = 'Shower stalls',
    obj = {
        'grate',
        'shampoo',
    },
    kway = {
        kroom('crews_quarters', 'e'),
        kroom('ventilation_duct', 'n'),
    },
}

sonar_sphere = room {
    nam = 'Sonar sphere',
    obj = {
        'sonarunit',
        obj {
            nam = 'cable',
            dsc = function(s)
                if sonarunit.connected then
                    p 'a {power cable}'
                else
                    p 'a severed {power cable}'
                end
            end,
            used = function(s, w)
                if w == cable_cutters then
                    sonarunit.connected = false
                    p "You have cut the power cable."
                end
            end,
        },
    },
    kway = {
        kroom('access_tunnel', 's'),
    },
}

sonar_station = room {
    nam = 'Sonar station',
    obj = {
        obj{
            nam = "Blank scanner",
            dsc = "Blank {scanner}",
        },
        obj{
            nam = "Green button",
            dsc = "Green {button}",
        },
    },
    kway = {
        kroom('long_corridor', 'w'),
    },
}

torpedo_room = room {
    nam = 'Torpedo room',
    obj = {
        'wrench',
    },
    kway = {
        kroom('crews_quarters', 's'),
        kroom('weapons_locker', 'e'),
    },
}

upper_missile_bay = room {
    nam = 'Upper missile bay',
    obj = {
        obj {
            nam = "Digital display",
            dsc = "Digital {display}",
            act = function(s)
                p('X='..tostring(gl_destination_x)..' Y='..tostring(gl_destination_y))
            end,
        },
        obj {
            nam = "Gold Button",
            dsc = "Gold {Button}",
            act = function(s)
                gl_destination_x = gl_destination_x + 8
                if gl_destination_x > 128 then
                    gl_destination_x = 0
                end
                p('X='..tostring(gl_destination_x)..' Y='..tostring(gl_destination_y))
            end,
        },
        obj {
            nam = "Silver button",
            dsc = "Silver {button}",
            act = function(s)
                gl_destination_y = gl_destination_y - 8
                if gl_destination_y < 0 then
                    gl_destination_y = 128
                end
                p('X='..tostring(gl_destination_x)..' Y='..tostring(gl_destination_y))
            end,
        },
    },
    kway = {
        kroom('lower_missile_bay', 'd'),
    },
}

ventilation_duct = room {
    nam = 'Ventilation duct',
    obj = {
        obj {
            nam = 'duct',
            dsc = 'There is a {duct} down to the fan room.',
            used = function(s,w)
                if w == sonarunit then
                    drop(w, fan_room)
                    traitor.alive = false
                    place(pistol, fan_room)
                    p 'It falls down to the fan room.'
                end
            end,
        }
    },
    kway = {
        kroom('shower_stalls', 'n'),
    },
}:disable();

weapons_locker = room {
    nam = 'Weapons locker',
    obj = {
        'gas_mask',
    },
    kway = {
        kroom('torpedo_room', 'w'),
    },
}

-- OBJECTS

cable_cutters = obj {
    nam = 'Cable cutters',
}

card = obj {
    nam = 'card',
    dsc = "there is a {card}",
    tak = 'you take the card.',
    inv = "it's the Ace of Spades!",
}

depth_gauge = obj {
    nam = 'Depth gauge',
    var {
        depth = 0,
    },
    dsc = 'There is a {depth gauge} at the wall',
    act = function(s)
        p(tostring(s.depth)..' fathoms') 
    end,
    life = function(s)
        if s.depth < 128 then
            s.depth = s.depth + 8
            if s.depth == 128 then
                lifeoff(s)
                p(txtb('BANG!')..' sub hits bottom')
            end
        end
    end,
}

ears = obj {
    nam = '(My Ears)',
    inv = [[You listen. Everything is silent as death.]],
};

enemy = obj {
    nam = 'Enemy',
    var {
        timer = 30,
    },
    life = function(s)
        if s.timer > 0 then
            s.timer = s.timer - 1
        end
        -- p(tostring(s.timer))
        -- p(tostring(depth_gauge.depth))
        if s.timer == 0 and depth_gauge.depth == 0 then
            if here() ~= dead then
                walkin('dead')
                p "The enemy captures the sub and kills you instantly!"
            end
        end
    end,
}

eyes = obj {
    nam = '(My Eyes)',
    inv = function(s)
        if here() == closed_eyes then
            walkout() 
            p [[You opened your eyes. It's good to be able to see everything again.]]
        else
            walkin(closed_eyes) 
            p [[You closed your eyes.]]
        end
    end,
};

feet = obj {
    nam = '(My Feet)',
    inv = 'You jump a few times. Nothing happens...',
};

gas_mask = obj {
    nam = 'Gas mask',
    dsc = code[[
        if here() == weapons_locker then
            p 'There is a {Gas mask} in an open locker.'
        else
            p 'There is a {Gas mask} on the floor.'
        end
    ]],
    tak = 'You wear the Gas mask',
    inv = function (s)
        drop(s)
        p 'You drop the Gas mask'
    end,
}

grate = obj {
    nam = 'Grate',
    dsc = 'there is a {grate} on the wall towards the stern of the sub',
    act = function(s)
        if ventilation_duct:disabled() then
            p 'it is screwed in place'
        else
            p 'it is open'
        end
    end,
    used = function(s, w)
        if w == screwdriver then
            p "You can't unscrew it, the screwdriver is too tiny."
        elseif w == knife then
            ventilation_duct:enable()
            p "You have unscrewed the grate."
        end
    end,
}

key = obj {
    nam = 'Key',
    dsc = "a {key}",
    tak = "you take the key",
    inv = "Key",
}:disable();

knife = obj {
    nam = 'knife',
    dsc = 'there is a dull {knife}',
    tak = 'You take the knife.',
    inv = 'Dull knife',
}

mouth = obj {
    nam = '(My Mouth)',
    inv = function(s)
        if gl_holdbreathtimer > 0 then
            lifeoff(s)
            gl_holdbreathtimer = 0
            p [[It feels so good to breath again]]
        else
            gl_holdbreathtimer = 10
            lifeon(s, 3)
            p [[You hold your breath]]
        end
    end,
    life = function(s)
        if gl_holdbreathtimer > 0 then
            gl_holdbreathtimer = gl_holdbreathtimer - 1
            -- p(tostring(gl_holdbreathtimer))
            if gl_holdbreathtimer == 0 then
                lifeoff(s)
                p [[You are no longer able to hold your breath.]]
            end
        end
    end,
};

nose = obj {
    nam = '(My Nose)',
    inv = function(s)
        if have(gas_mask) then
            p [[You can't smell anything because of the gas mask.]]
        else
            p [[There is a smell of oil on your hands.]]
        end
    end,
};

periscope = obj {
    nam = 'Periscope',
    dsc = 'there is a {periscope} coming out of the roof.',
    act = function(s)
        if depth_gauge.depth == 0 then
            p(txtb('^The enemy is approaching!!!!!!!!!^'))
        else
            p 'You can only see water'
        end
    end,
}

pistol = obj {
    nam = 'pistol',
    var {
        bullet = true;
    },
    dsc = 'There is a {pistol} lying on the floor.',
    tak = "I take the pistol",
    inv = function(s)
        if s.bullet then
            p "It has only one bullet"
        else
            p "It does not have any bullets"
        end
    end,
    use = function(s, w)
        if not s.bullet then
            p "The pistol does not have any bullets left."
        else
            s.bullet = false
            p 'BANG!';
        end
    end,
}

poison = obj {
    nam = 'Poison',
    life = function(s)
        if gl_holdbreathtimer == 0 and not have(gas_mask) then
            if here() ~= dead then
                walkin('dead')
                p "A cloud of poisonous gas kills you instantly!"
            end
        end
    end,
}

sonarunit = obj {
    nam = 'Radioactive sonar unit',
    var {
        rusty = true,
        bolted = true,
        connected = true,
    },
    dsc =  function(s)
        if s.rusty then
            p 'a bolted-down radioactive {sonar unit}.'
        else
            p 'a radioactive glowing {sonar unit}.'
        end
    end,
    act =  function(s)
        if s.rusty then
            p 'The bolts are tight and rusty.'
        elseif s.bolted then
            p "The bolts won't let you pick it up"
        elseif s.connected then
            p "It is connected to the cable"
        else
            take(s)
            p "you picked up the radioactive sonar unit"
        end
    end,
    inv = function (s)
        drop(s)
        p 'You have dropped the sonar unit.'
    end,
    used = function(s, w)
        if w == shampoo then
            s.rusty = false
            remove(w, me())
            p "shampoo all used up."
        end
        if w == wrench then
            if s.rusty then
                p "the bolts are too tight and rusty"
            else
                s.bolted = false
                p "you have removed the bolts"
            end
        end
    end,
}

radiation = obj {
    nam = 'Radiation',
    life = function(s)
        if (here() == where(sonarunit) or have(sonarunit)) and not have(radiation_suit) then
            -- note in the original game you get killed in the sonar sphere only
            walkin('dead')
            p "A blast of radioactivity kills you instantly!"
        end
    end,
}

radiation_suit = obj {
    nam = 'Radiation suit',
    dsc = 'There is a {radiation suit}',
    tak = 'You wear the radiation suit',
    inv = function (s)
        if key:disabled() then
            key:enable()
            place(key)
            p "You found a key"
        else
            drop(s)
            p 'You drop the radiation suit'
        end
    end,
}

red_button = obj {
    nam = 'Red button',
    dsc = 'with a {Red button} next to it.',
    act = code[[
        if depth_gauge.depth == 128 then
            p 'nothing happens'
        elseif live(depth_gauge) then
            lifeoff(depth_gauge)
            p 'sub levels off'
        else
            lifeon(depth_gauge, 8)
            p 'sub dives'
        end
    ]],
}

security_id = obj {
    nam = "Security ID",
    dsc = "You found a {Security ID}",
    tak = "You take the Secutity ID.",
}:disable();

screwdriver = obj {
    nam = 'Tiny screwdriver',
    dsc = 'There is a tiny {screwdriver}.',
    tak = 'You picked up the tiny screwdriver',
    inv = 'seems ordiary',
}

shampoo = obj {
    nam = 'Shampoo',
    dsc = 'There is a bottle of {shampoo}',
    tak = 'You take the bottle',
    inv = 'Looks like normal shampoo',
}

traitor = obj {
    nam = 'traitor',
    var {
        alive = true,
    },
    dsc = function(s)
        if s.alive then
            p "The {traitor} holding a pistol stands here."
        else
            p "The {traitor} is lying dead on the floor."
        end
    end,
    act =  function(s)
        if s.alive then
            p "He looks dangerous"
        else
            p "He is dead"
        end
    end,
}

wrench = obj {
    nam = 'Wrench',
    dsc = 'a {wrench}',
    tak = 'you take the wrench',
}
