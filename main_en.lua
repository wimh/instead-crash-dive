-- $Name:Crash Dive!$
-- $Version:0.1.0$

-- vim: set fileencoding=utf-8 nobomb foldmethod=syntax nofoldenable foldnestmax=1:

instead_version '1.9.1'

require 'dbg'

require 'object'
require 'para'
require 'xact'
require 'dash'
require "hideinv"

game.use = 'That’s not possible...';
game.inv = 'A strange thing...'
game.act = 'Nothing happens'

game.codepage="UTF-8"

-- FUNCTIONS + GLOBALS

function init()
    take(eyes); 
    take(ears); 
    take(nose);
    take(mouth); 
    take(feet);
    lifeon(enemy, 6);
    lifeon(radiation, 4);
end; 

global {
    -- 0 = not holding breath
    gl_holdbreathtimer = 0, 
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
    way = {
        'sonar_sphere', -- N
        'forward_passage', -- S
    },
}

ballast_control = room {
    nam = "Ballast control",
    obj = {
        'depth_gauge',
        'red_button',
    },
    way = {
        'command_station', -- E
    }
}

captains_quarters = room {
    nam = "Captain's quarters",
    obj = {
    },
    way = {
        'forward_passage', -- E
    },
}:disable();

command_station = room {
    nam = 'Command station',
    obj = {
        'periscope',
    },
    way = {
        vroom('Down', 'missile_control'),--command_station
        'long_corridor', -- N
        'navigation_center', -- E
        'ballast_control', -- W
    },
}

closed_eyes = room {
    nam = '',
    dsc = [[You can't see anything!]],
};

crews_quarters = room {
    nam = "Crew's quarters",
    dsc = [[crews_quarters]],
    obj = {
        'card',
    },
    way = {
        vroom('Up', 'forward_passage'),
        'torpedo_room', -- N
        'galley', -- E
        'missile_control', -- S
        'shower_stalls', -- W
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
    way = {
        'missile_control', -- W
    },
}

escape_tube = room {
    forcedsc = true,
    nam = 'Escape tube',
    dsc = [[You are in the escape tube. There is a {hatch|hatch} in the floor. It has a {hatch_handle|handle} to open it.]],
    obj = { 
        xact('hatch', 'It is airtight'),
        xact('hatch_handle', code[[
            if not disabled(path('Down')) then
                p "You close the hatch."
                path('Down'):disable()
            else
                p "You open the hatch."
                path('Down'):enable()
                lifeon(poison, 5)
            end
        ]]),
        'screwdriver',
    },
    way = {
        vroom('Down', 'forward_passage'):disable(),
    },
};

fan_room = room {
    nam = 'Fan room',
    obj = {
        obj {
            nam = 'traitor',
            dsc = "The {traitor} stands here",
        },
        obj {
            nam = 'pistol',
            dsc = 'he holds a {pistol}.',
        },
    },
    way = {
        'missile_control', -- E
    },
}

forward_passage = room {
    nam = 'Forward passage',
    dsc = [[forward_passage]],
    obj = {
        obj {
            nam = 'door',
            dsc = 'There is closed {door}',
            act = 'The lock is very secure, you cannot open it.',
        },
    },
    way = {
        vroom('Up', 'escape_tube'),
        vroom('Down', 'crews_quarters'),
        'access_tunnel', -- N
        'long_corridor', -- S
        'captains_quarters', -- W
    },
}

galley = room {
    nam = 'Galley',
    obj = {
        obj {
            nam = 'knife',
            dsc = 'there is a dull {knife}',
            tak = 'You take the knife.',
            inv = 'Dull knife',
        }
    },
    way = {
        'crews_quarters', -- W
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
    way = {
        'forward_passage', -- N
        'sonar_station', -- E
        'command_station', -- S
        'radio_room', -- W
    },
}

lower_missile_bay = room {
    nam = 'Lower missile bay',
    obj = {
    },
    way = {
        'missile_control', -- N
        vroom('Up', 'upper_missile_bay'),
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
            dsc = "There is an {airlock}",
            act = '',
        },
        obj {
            nam = 'airlockslot',
            dsc = "with a {slot}",
            act = "It accepts a security ID card.",
            used = function(s, w)
                if w == card then
                    p "Did you look at the card?"
                end
            end,
        },
        obj {
            nam = 'white button',
            dsc = "There is a {white button}",
        },
    },
    way = {
        vroom('Up', 'command_station'),
        'crews_quarters', -- N
        'equipment_bay', -- E
        'lower_missile_bay', -- S
        'fan_room', -- W
    },
}

navigation_center = room {
    nam = 'Navigation center',
    obj = {
    },
    way = {
        'command_station', -- W
    },
}

radio_room = room {
    nam = 'Radio room',
    obj = {
        'cable_cutters',
    },
    way = {
        'long_corridor', -- E
    },
}

shower_stalls = room {
    nam = 'Shower stalls',
    obj = {
        'grate',
        'shampoo',
    },
    way = {
        'crews_quarters', -- E
         vroom('Ventilation shaft', 'ventilation_duct'):disable(), -- N
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
    way = {
        'access_tunnel', -- S
    },
}

sonar_station = room {
    nam = 'Sonar station',
    obj = {
    },
    way = {
        'long_corridor', -- W
    },
}

torpedo_room = room {
    nam = 'Torpedo room',
    obj = {
        'wrench',
    },
    way = {
        'crews_quarters', -- S
        'weapons_locker', -- E
    },
}

upper_missile_bay = room {
    nam = 'Upper missile bay',
    obj = {
    },
    way = {
        vroom('Down', 'lower_missile_bay'),
    },
}

ventilation_duct = room {
    nam = 'Ventilation duct',
    obj = {
        obj {
            nam = 'duct',
            dsc = 'There is a {duct} down to the fan room.',
            act = '',
        }
    },
    way = {
        'shower_stalls', -- N
    },
}

weapons_locker = room {
    nam = 'Weapons locker',
    obj = {
        'gas_mask',
    },
    way = {
        'torpedo_room', -- W
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
    act = 'it is screwed in place',
    used = function(s, w)
        if w == screwdriver then
            p "You can't unscrew it, the screwdriver is too tiny."
        end
    end,
}

key = obj {
    nam = 'key',
    dsc = "a {key}",
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
    nam = 'sonarunit',
    var {
        rusty = true,
        bolted = true,
        connected = true,
    },
    dsc =  function(s)
        if s.rusty then
            p 'a bolted-down radioactive {sonar unit}'
        else
            p 'a radioactive {sonar unit}'
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
    inv = 'It glows...',
    used = function(s, w)
        if w == shampoo then
            s.rusty = false
            p "the bolts are shiny now."
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
        if here() == sonar_sphere and not have(radiation_suit) then
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
        drop(s) -- todo different action ;)
        p 'You drop the radiation suit'
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

wrench = obj {
    nam = 'Wrench',
    dsc = 'a {wrench}',
    tak = 'you take the wrench',
}
