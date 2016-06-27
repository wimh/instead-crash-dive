-- $Name:Crash Dive!$
-- $Version:0.1.0$

-- vim: set fileencoding=utf-8 nobomb

instead_version '1.9.1'

main = room {
    nam = 'Crash Dive!';
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
    obj = {
        obj {
            nam = 'en'; dsc = '> {English}^'; act = code [[ gamefile('main_en.lua', true) ]];
        };

        obj {
            nam = 'quickstart'; dsc = '^> {quickstart}^'; act = code [[ gamefile('main_en.lua', true); walk(escape_tube) ]];
        };
    }
}
