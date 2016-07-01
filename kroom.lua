-- partly based on module kbd

stead.module_init(function()
    input.key = stead.hook(input.key, function(f, s, down, key, ...)
        if input._key_hooks[key] then
            input.key_event = { key = key, down = down };
            return 'user_kbd_kroom'
        end
        return f(s, down, key, ...)
    end)
    input._key_hooks = {}
    --[[ enable key_hooks in kroom() - allows other directions too
    input._key_hooks['n'] = true; -- North
    input._key_hooks['s'] = true; -- South
    input._key_hooks['e'] = true; -- East
    input._key_hooks['w'] = true; -- West
    input._key_hooks['u'] = true; -- Up
    input._key_hooks['d'] = true; -- Down
    --]]
end)

stead.kroom = function(where, direction)
    if where == nil then
        error("Wrong parameter to kroom.", 2);
    end
    if direction == nil then
        return stead.deref(where)
    end
    input._key_hooks[direction] = true;
    return obj {
        nam = where,
        kroom_type = true,
        where = where,
        direction = direction,
    }
end

game.action = stead.hook(game.action, function(f, s, cmd, ...)
    if cmd == 'user_kbd_kroom' then
        local i,v;
        if input.key_event.down and stead.here().kway then
            for i,v in ipairs(stead.here().kway) do
                if v.kroom_type and input.key_event.key == v.direction then
                    if not stead.ref(v.where):disabled() then
                        stead.walk(v.where)
                    end
                end
            end
        end
        return
    end
    return f(s, cmd, ...);
end)

room = stead.inherit(room, function(v)
    v.entered = stead.hook(v.entered, function(f, s, ...)
        if s.kway and (not s.way or stead.table.maxn(s.way) == 0) then
            if not s.way then
                s.way = {}
            end
            for i,v in ipairs(s.kway) do
                if v.kroom_type then
                    stead.table.insert(s.way, v.where)
                    if v:disabled() then
                        -- a disabled kroom is a shortcut to disable the destination room
                        -- so move the disabled state to that room
                        stead.ref(v.where):disable()
                        v:enable()
                    end
                else
                    stead.table.insert(s.way, v)
                end
            end
        end
        return f(s, ...)
    end)
    return v
end)

kroom = stead.kroom
