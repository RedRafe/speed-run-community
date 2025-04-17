fsrc.on_init(function()
    if not remote.interfaces['freeplay'] then
        return
    end

    remote.call('freeplay', 'set_created_items', {})
    remote.call('freeplay', 'set_debris_items', {})
    remote.call('freeplay', 'set_disable_crashsite', true)
    remote.call('freeplay', 'set_respawn_items', {})
    remote.call('freeplay', 'set_ship_items', {})
    remote.call('freeplay', 'set_ship_parts', {})
    remote.call('freeplay', 'set_skip_intro', true)
end)
