require "kbd"

stead.kroom = function(where, direction)
    if where == nil then
        error("Wrong parameter to kroom.", 2);
    end
    if direction == nil then
        return stead.deref(where)
    end
    hook_keys(direction)
    return obj {
        nam = where,
        kroom_type = true,
        where = where,
        direction = direction,
    }
end

room = stead.inherit(room, function(v)
    v.entered = stead.hook(v.entered, function(f, s, ...)
        if s.kway and (not s.way or stead.table.maxn(s.way) == 0) then
            if not s.way then
                s.way = {}
            end
            for i,v in ipairs(s.kway) do
                if v.kroom_type then
                    s.way:add(v.where)
                    if v:disabled() then
                        -- a disabled kroom is a shortcut to disable the destination room
                        -- so move the disabled state to that room
                        stead.ref(v.where):disable()
                        v:enable()
                    end
                else
                    s.way:add(v)
                end
            end
        end
        return f(s, ...)
    end)
    v.kbd = stead.hook(v.kbd, function(f, s, down, key)
        local i,v;
        if down and s.kway then
            for i,v in ipairs(s.kway) do
                if v.kroom_type and key == v.direction then
                    if not stead.ref(v.where):disabled() then
                        stead.walk(v.where)
                        return
                    end
                end
            end
        end
        return f(s, down, key)
    end)
    return v
end)

kroom = stead.kroom

