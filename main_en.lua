-- $Name:Crash Dive!$
-- $Version:0.3.0$

-- vim: set fileencoding=utf-8 nobomb foldmethod=syntax nofoldenable foldnestmax=1:

instead_version '1.6.1'

--require 'dbg'

require 'hideinv'
require 'kroom'

game.use = "That’s not possible...";
game.inv = "A strange thing..."
game.act = "Nothing happens"

game.codepage="UTF-8"

-- FUNCTIONS + GLOBALS

function init()
    lifeon(radiation, 4);
    lifeon(poison, 5)
end;

global {
    -- result will be 8..128 in steps of 8
    gl_encrypted_x = rnd(16) * 8,
    gl_encrypted_y = rnd(16) * 8,

    gl_destination_x = rnd(16) * 8,
    gl_destination_y = rnd(16) * 8,

    gl_activated_arming = false,
}

-- direction keys which can be used to move between rooms
UP = 'u';
DOWN = 'd';
NORTH = 'n';
SOUTH = 's';
EAST = 'e';
WEST = 'w';

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
            Now the room names are used, but the original keys still work if a keyboard is connected.
            The original game limits the number of items which can be carried to 6. This limit has been removed.
          ]],
    kway = {
        kroom(vroom('Back to main menu', 'main'), DOWN),
    },
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
        kroom('sonar_sphere', NORTH),
        kroom('forward_passage', SOUTH),
    },
}

ballast_control = room {
    nam = "Ballast control",
    obj = {
        'depth_gauge',
        'red_button',
    },
    kway = {
        kroom('command_station', EAST),
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
            dsc = "There is a suicide {note}.",
            act = [[I can no longer live with my terrible secret. May the devil have mercy on my soul.]],
        },
        'security_id',
    },
    kway = {
        kroom('forward_passage', EAST),
    },
}:disable();

command_station = room {
    nam = 'Command station',
    obj = {
        'periscope',
    },
    kway = {
        kroom('missile_control', DOWN),
        kroom('long_corridor', NORTH),
        kroom('navigation_center', EAST),
        kroom('ballast_control', WEST),
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
        kroom('forward_passage', UP),
        kroom('torpedo_room', NORTH),
        kroom('galley', EAST),
        kroom('missile_control', SOUTH),
        kroom('shower_stalls', WEST),
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
        kroom('missile_control', WEST),
    },
}

escape_tube = room {
    nam = 'Escape tube',
    dsc = "You are in the escape tube.",
    entered = function(s)
        lifeon(enemy, 6);
    end,
    obj = {
        obj {
            nam = "hatch",
            dsc = "There is a {hatch} in the floor.",
            act = 'It is airtight.',
        },
        obj {
            nam = "handle",
            dsc = "It has a {handle} to open it.",
            act = function(s)
                if not forward_passage:disabled() then
                    set_sound('snd/264060__paul368__sfx-door-close-big.ogg')
                    p "You close the hatch."
                    forward_passage:disable()
                    -- closing it does not remove the gas already here ;)
                else
                    set_sound('snd/264061__paul368__sfx-door-open.ogg')
                    p "You open the hatch."
                    forward_passage:enable()
                    poison.escaped = true
                end
            end,
        },
        obj {
            nam = "hero",
            dsc = "In the shiny metal you see {yourself}.",
            act = function(s)
              if poison.holdbreathtimer > 0 then
                  poison.holdbreathtimer = 0
                  p [[You start breathing again.]]
              else
                  poison.holdbreathtimer = 10
                  p [[You hold your breath.]]
              end
            end,
        },
        'screwdriver',
    },
    kway = {
        kroom('forward_passage', DOWN):disable(),
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
        kroom('missile_control', EAST),
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
            set_sound('snd/163456__lemudcrab__pistol-shot.ogg')
            walkin('dead')
            p "The traitor shoots you and kills you instantly!"
        end
    end,
}

forward_passage = room {
    nam = 'Forward passage',
    obj = {
        'door',
    },
    kway = {
        kroom('escape_tube', UP),
        kroom('crews_quarters', DOWN),
        kroom('access_tunnel', NORTH),
        kroom('long_corridor', SOUTH),
        kroom('captains_quarters', WEST),
    },
}

galley = room {
    nam = 'Galley',
    obj = {
        'knife',
    },
    kway = {
        kroom('crews_quarters', WEST),
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
    kway = {
        kroom(vroom('Start', 'escape_tube'), NORTH),
    },
    hideinv = true,
};

long_corridor = room {
    nam = 'Long corridor',
    obj = {
    },
    kway = {
        kroom('forward_passage', NORTH),
        kroom('sonar_station', EAST),
        kroom('command_station', SOUTH),
        kroom('radio_room', WEST),
    },
}

lower_missile_bay = room {
    nam = 'Lower missile bay',
    obj = {
        obj {
            nam = "arming switch",
            dsc = function (s)
                if gl_activated_arming then
                    p "You see an activated arming {switch}."
                else
                    p "You see a locked arming {switch}."
                end
            end,
            act = "The lock is very secure.",
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
        kroom('missile_control', NORTH),
        kroom('upper_missile_bay', UP),
    },
}:disable();

main = room {
    nam = 'Crash Dive!',
    kway = {
        kroom(vroom('^Start game^', 'intro'), NORTH),
        kroom(vroom('^About original game^', 'about'), DOWN),
    },
    dsc = [[
        Credits^^
        • Original game «Crash Dive!» by Brian Moriarty^
        • Dropped stuff by Enma-Darei from freesound.org (CC-0)^
        • SUBMARINE DIVE ALARM by U.S. Department of Defense (PD)^
        • Pistol Shot by LeMudCrab from freesound.org (CC-0)^
        • crash.wav by sagetyrtle from freesound.org (CC-0)^
        • HQ Explosion by Quaker540 from freesound.org (CC-0)^
        • SFX Door Open.wav by Paul368 from freesound.org (CC-0)^
        • SFX Door Close Big.wav by Paul368 from freesound.org (CC-0)^
    ]],
    obj = {
        obj {
            nam = "back",
            dsc = txtc("{Back to language selection}"),
            act = function(s)
                gamefile('main.lua')
                p "" -- avoid the "Nothing happens"
            end,
        }
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
            dsc = "There is a {white button}.",
            act = function(s)
                if gl_activated_arming
                        and gl_encrypted_x == gl_destination_x
                        and gl_encrypted_y == gl_destination_y then
                    set_sound('snd/245372__quaker540__hq-explosion.ogg')
                    walkin('congratulations')
                    p "You have finished this game"
                else
                    p "Nothing happens."
                end
            end,
        },
    },
    kway = {
        kroom('command_station', UP),
        kroom('crews_quarters', NORTH),
        kroom('equipment_bay', EAST),
        kroom('lower_missile_bay', SOUTH),
        kroom('fan_room', WEST),
    },
}

navigation_center = room {
    nam = 'Navigation center',
    obj = {
        obj{
            nam = "Digital display",
            dsc = "You see a digital {display}.",
            act = function(s)
                p('X='..tostring(gl_encrypted_x)..' Y='..tostring(gl_encrypted_y))
            end,
        },
        obj{
            nam = "Tactics manual",
            dsc = "There is a {tactics manual}.",
            act = function(s)
                p(txtc(txtb("THIS DOCUMENT IS CLASSIFIED TOP SECRET^")))
                p([[^
                    ...a pair of coordinates designated X and Y. These are automatically scrambled
                    by the Delta-Q Encoder so that they bear no obvious relation to the latitude and
                    langitude readings which they represent...^
                ]])
            end,
        },
    },
    kway = {
        kroom('command_station', WEST),
    },
}

radio_room = room {
    nam = 'Radio room',
    obj = {
        'cable_cutters',
    },
    kway = {
        kroom('long_corridor', EAST),
    },
}

shower_stalls = room {
    nam = 'Shower stalls',
    obj = {
        'grate',
        'shampoo',
    },
    kway = {
        kroom('crews_quarters', EAST),
        kroom('ventilation_duct', SOUTH),
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
                    p 'There is a {power cable} connected to the sonar unit.'
                else
                    p 'There is a severed {power cable}.'
                end
            end,
            used = function(s, w)
                if w == cable_cutters then
                    if scanner.active then
                        walkin('dead')
                        p "A jolt of high voltage kills you instantly!"
                    else
                        sonarunit.connected = false
                        p "You have cut the power cable."
                    end
                end
            end,
        },
    },
    kway = {
        kroom('access_tunnel', SOUTH),
    },
}

sonar_station = room {
    nam = 'Sonar station',
    obj = {
        'scanner',
        obj{
            nam = "Green button",
            dsc = "There is a green {button}.",
            act = function(s)
                if scanner.active then
                    scanner.active = false
                    p "scanner deactivated"
                else
                    scanner.active = true
                    p "scanner activated"
                end
            end,
        },
    },
    kway = {
        kroom('long_corridor', WEST),
    },
}

torpedo_room = room {
    nam = 'Torpedo room',
    obj = {
        'wrench',
    },
    kway = {
        kroom('crews_quarters', SOUTH),
        kroom('weapons_locker', EAST),
    },
}

upper_missile_bay = room {
    nam = 'Upper missile bay',
    obj = {
        obj {
            nam = "Digital display",
            dsc = "You see a digital {display}.",
            act = function(s)
                p('X='..tostring(gl_destination_x)..' Y='..tostring(gl_destination_y))
            end,
        },
        obj {
            nam = "Gold Button",
            dsc = "There is a Gold {Button}.",
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
            dsc = "There is a silver {button}.",
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
        kroom('lower_missile_bay', DOWN),
    },
}

ventilation_duct = room {
    nam = 'Ventilation duct',
    obj = {
        obj {
            nam = 'duct',
            dsc = 'There is a {duct} down to the fan room.',
            used = function(s,w)
                set_sound('snd/196124__enma-darei__dropped-stuff.ogg')
                drop(w, fan_room)
                if w == sonarunit then
                    traitor.alive = false
                    place(pistol, fan_room)
                end
                p 'It falls down to the fan room.'
            end,
        }
    },
    kway = {
        kroom('shower_stalls', NORTH),
    },
}:disable();

weapons_locker = room {
    nam = 'Weapons locker',
    obj = {
        'gas_mask',
    },
    kway = {
        kroom('torpedo_room', WEST),
    },
}

-- OBJECTS

cable_cutters = obj {
    nam = 'Cable cutter',
    dsc = 'There is a {cable cutter}.',
    tak = 'You take the cable cutter.',
}

card = obj {
    nam = 'Card',
    dsc = "There is a {card}.",
    tak = 'You take the card.',
    inv = "It's the Ace of Spades!",
}

depth_gauge = obj {
    nam = 'Depth gauge',
    var {
        depth = 0,
    },
    dsc = 'There is a {depth gauge} at the wall.',
    act = function(s)
        p(tostring(s.depth)..' fathoms')
    end,
    life = function(s)
        if s.depth < 128 then
            s.depth = s.depth + 8
            if s.depth == 128 then
                set_sound('snd/40158__sagetyrtle__crash.ogg')
                lifeoff(s)
                p(txtb('BANG!')..' The sub hits the bottom of the sea.')
            end
        end
    end,
}

door = obj {
    nam = 'door',
    dsc = function(s)
        if captains_quarters:disabled() then
            p 'There is a closed {door}.'
        else
            p 'There is an open {door}.'
        end
    end,
    act = function(s)
        if captains_quarters:disabled() then
            p 'The lock is very secure, you cannot open it.'
        else
            p 'The lock is broken.'
        end
    end,
    used = function(s, w)
        if w == key then
            p "The key won't fit."
        elseif w == pistol and pistol.bullet then
            set_sound('snd/163456__lemudcrab__pistol-shot.ogg')
            captains_quarters:enable()
            pistol.bullet = false
            p 'BANG!';
            p "Lock destroyed!"
        end
    end,
}

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

gas_mask = obj {
    nam = 'Gas mask',
    dsc = code[[
        if here() == weapons_locker then
            p 'There is a {Gas mask} in an open locker.'
        else
            p 'There is a {Gas mask} on the floor.'
        end
    ]],
    tak = 'You wear the Gas mask.',
}

grate = obj {
    nam = 'Grate',
    dsc = 'There is a {grate} on the wall towards the stern of the sub.',
    act = function(s)
        if ventilation_duct:disabled() then
            p 'It is screwed in place.'
        else
            p 'It is open.'
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
    dsc = "There is a {key}.",
    tak = "You take the key.",
    inv = "Key",
}:disable();

knife = obj {
    nam = 'Knife',
    dsc = 'There is a dull {knife}.',
    tak = 'You take the knife.',
    inv = 'Dull knife',
}

periscope = obj {
    nam = 'Periscope',
    dsc = 'there is a {periscope} coming out of the roof.',
    act = function(s)
        if depth_gauge.depth == 0 then
            p(txtb('^The enemy is approaching on a ship!!!!!!!!!^'))
        else
            p 'You can only see water.'
        end
    end,
}

pistol = obj {
    nam = 'Pistol',
    var {
        bullet = true;
    },
    dsc = 'There is a {pistol} lying on the floor.',
    tak = "You take the pistol.",
    inv = function(s)
        if s.bullet then
            p "It has only one bullet."
        else
            p "It does not have any bullets."
        end
    end,
    use = function(s, w)
        if not s.bullet then
            p "The pistol does not have any bullets left."
        elseif w ~= door then
            set_sound('snd/163456__lemudcrab__pistol-shot.ogg')
            s.bullet = false
            p 'BANG!';
        end
    end,
}

poison = obj {
    nam = 'Poison',
    var{
        escaped = false, -- escaped to escape tube
        holdbreathtimer = 0, -- 0 = not holding breath
    },
    life = function(s)
        -- p(tostring(s.holdbreathtimer))
        if s.holdbreathtimer > 0 then
            s.holdbreathtimer = s.holdbreathtimer - 1
            if s.holdbreathtimer == 0 then
                p [[You are no longer able to hold your breath.^]]
            end
        end
        if poison.escaped and s.holdbreathtimer == 0 and not have(gas_mask) and not gas_mask:disabled() then
            if here() ~= dead then
                walkin('dead')
                p "A cloud of poisonous gas kills you instantly!"
            end
        end
    end,
}

sonarunit = obj {
    nam = 'Sonar unit',
    var {
        rusty = true,
        bolted = true,
        connected = true,
    },
    dsc =  function(s)
        if s.rusty then
            p 'There is a bolted-down radioactive {sonar unit}.'
        else
            p 'There is a radioactive glowing {sonar unit}.'
        end
    end,
    act =  function(s)
        if s.bolted then
            p "The bolts won't let you pick it up."
        elseif s.connected then
            p "It is connected to the cable."
        else
            take(s)
            p "You picked up the radioactive sonar unit."
        end
    end,
    inv = 'It is glowing!',
    used = function(s, w)
        if w == shampoo then
            s.rusty = false
            remove(w, me())
            p "Shampoo all used up."
        end
        if w == wrench then
            if s.rusty then
                p "The bolts are too tight and rusty."
            else
                s.bolted = false
                p "You have removed the bolts."
            end
        end
    end,
}

radiation = obj {
    nam = 'Radiation',
    life = function(s)
        if where(sonarunit) == nil and not have(sonarunit) and not sonarunit:disabled() then
            move('sonarunit', 'sonar_sphere', 'sonar_sphere'); -- fix where()
        end
        if (here() == where(sonarunit) or have(sonarunit)) and not have(radiation_suit) then
            -- note in the original game you get killed in the sonar sphere only
            walkin('dead')
            p "A blast of radioactivity kills you instantly!"
        end
    end,
}

radiation_suit = obj {
    nam = 'Radiation suit',
    dsc = 'There is a {radiation suit}.',
    tak = 'You wear the radiation suit.',
    inv = function (s)
        if key:disabled() then
            key:enable()
            place(key)
            p "You found a key!"
        end
    end,
}

red_button = obj {
    nam = 'Red button',
    dsc = 'with a {Red button} next to it.',
    act = code[[
        if depth_gauge.depth == 128 then
            p 'Nothing happens.'
        elseif live(depth_gauge) then
            lifeoff(depth_gauge)
            p 'Sub levels off.'
        else
            if depth_gauge.depth == 0 then
                set_sound('snd/submarine_dive_horn.ogg')
            end
            lifeon(depth_gauge, 8)
            p 'Sub dives.'
        end
    ]],
}

scanner = obj {
    nam = "Scanner",
    var {
        -- in the original game it is inactive by default
        -- if it is active, an additional step is required to solve the game
        active = true;
    },
    dsc = function(s)
        if s.active then
            p "You see an active {scanner}."
        else
            p "You see a blank {scanner}."
        end
    end,
    act = function(s)
        if s.active then
            p "The enemy is approaching on a ship!!!"
        else
            p "It is blank."
        end
    end,
}

security_id = obj {
    nam = "Security ID",
    dsc = "You found a {Security ID}.",
    tak = "You take the Secutity ID.",
}:disable();

screwdriver = obj {
    nam = 'Tiny screwdriver',
    dsc = 'There is a tiny {screwdriver}.',
    tak = 'You pick up the tiny screwdriver.',
    inv = 'Seems ordinary.',
}

shampoo = obj {
    nam = 'Shampoo',
    dsc = 'There is a bottle of {shampoo}.',
    tak = 'You take the bottle.',
    inv = 'It is heavy duty shampoo.',
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
            p "He is wearing a gas mask and looks dangerous."
        else
            p "He is dead."
        end
    end,
    used = function(s, w)
        if s.alive and here() ~= dead then
            set_sound('snd/163456__lemudcrab__pistol-shot.ogg')
            walkin('dead')
            p "The traitor shoots you and kills you instantly!"
        end
    end,
}

wrench = obj {
    nam = 'Wrench',
    dsc = 'There is a {wrench}.',
    tak = 'You take the wrench.',
}
