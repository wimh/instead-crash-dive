-- $Name:Crash Dive!$
-- $Version:0.3.0$

-- vim: set fileencoding=utf-8 nobomb:

instead_version '1.9.1'

main = room {
    nam = 'Crash Dive!';
    forcedsc = true,
    dsc = function(s)
        if     LANG == 'ru' then p [[Выберите язык игры:]];
        elseif LANG == 'uk' then p [[Мова:]];
        elseif LANG == 'pt' then p [[Língua:]];
        elseif LANG == 'it' then p [[Lingua:]];
        elseif LANG == 'fr' then p [[Langue:]];
        elseif LANG == 'es' then p [[Idioma:]];
        elseif LANG == 'de' then p [[Sprache:]];
        elseif LANG == 'cz' then p [[Jazyk:]];
        elseif LANG == 'nl' then p [[Kies taal:]];
        else                     p [[Select game language:]];
        end
    end;
    enter = function(s, f)
        if f == s then
            -- if user language matches game language, do not ask
            if LANG == 'en' then
                gamefile('main_en.lua', true)
            end
            --[[ debug only !!!
            take(gas_mask, weapons_locker);
            take(radiation_suit, equipment_bay);
            take(shampoo, shower_stalls);
            take(wrench, torpedo_room);
            take(cable_cutters, radio_room);
            take(sonarunit, sonar_sphere);
            take(knife, galley);
            take(pistol);
            walk(crews_quarters);
            --]]
        end
    end;
    obj = {
        obj {
            nam = 'en'; dsc = '> {English}^'; act = code [[ gamefile('main_en.lua', true) ]];
        };
    }
}
