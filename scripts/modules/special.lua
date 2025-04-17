local Special = {}

local libraries = {}

local this = {
    enabled = false
}

fsrc.subscribe(this, function(tbl) this = tbl end)

local register_lib = function(lib)
    if lib.events then
        for event_name, token in pairs(lib.events) do
            fsrc.add(event_name, token)
        end
    end

    if lib.on_nth_tick then
        for event_tick, token in pairs(lib.on_nth_tick) do
            fsrc.add(event_tick, token, { on_nth_tick = true })
        end
    end
end

Special.enabled = function()
    return this.enabled
end

Special.add_lib = function(lib)
    for _, current in pairs(libraries) do
        if current == lib then
            return
        end
    end
    libraries[#libraries + 1] = lib
end

Special.remove_lib = function(lib)
    table.remove_element(libraries, lib)
end

return Special
