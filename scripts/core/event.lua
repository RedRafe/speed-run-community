--- This Module allows for registering multiple handlers to the same event,
--- overcoming the limitation of script registering.

local EventCore = require 'scripts.core.event-core'
local Storage = require 'scripts.core.storage'
local Token = require 'scripts.core.token'

Storage.subscribe(EventCore.get_handlers(), EventCore.set_handlers)

local Event = {}

Event.on_init = function(handler)
    EventCore.on_init(handler)
end

Event.on_load = function(handler)
    EventCore.on_load(handler)
end

Event.on_configuration_changed = function(handler)
    EventCore.on_configuration_changed(handler)
end

Event.raise_event = EventCore.raise_event
Event.register_on_object_destroyed = EventCore.register_on_object_destroyed

Event.add = function(event_name, handler, options)
    EventCore.add(event_name, handler, options)
end

Event.remove = function(event_name, handler, options)
    EventCore.remove(event_name, handler, options)
end

Event.add_on_nth_tick = function(tick, handler)
    EventCore.add(tick, handler, { on_nth_tick = true })
end

Event.add_token = function(event_name, token)
    EventCore.add(event_name, token)
end

Event.remove_token = function(event_name, token)
    EventCore.remove(event_name, token)
end

Event.add_token_on_nth_tick = function(event_name, token)
    EventCore.add(event_name, token, { on_nth_tick = true })
end

Event.remove_token_on_nth_tick = function(event_name, token)
    EventCore.remove(event_name, token, { on_nth_tick = true })
end

Event.add_function = function(event_name, string_function, options)
    EventCore.add(event_name, string_function, options)
end

Event.remove_function = function(event_name, name)
    EventCore.remove(event_name, name)
end

Event.add_function_on_nth_tick = function(event_name, string_function, options)
    options.on_nth_tick = true
    EventCore.add(event_name, string_function, options)
end

Event.remove_function_on_nth_tick = function(event_name, name)
    EventCore.remove(event_name, name, { on_nth_tick = true })
end

local function handler_factory(event_list)
    return function(handler, options)
        for _, event_name in pairs(event_list) do
            EventCore.add(event_name, handler, options)
        end
    end
end

Event.on_built = handler_factory {
    defines.events.on_biter_base_built,
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.on_space_platform_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
    defines.events.on_entity_cloned,
}
Event.on_destroyed = handler_factory {
    defines.events.on_entity_died,
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity,
    defines.events.on_space_platform_mined_entity,
    defines.events.script_raised_destroy,
}
Event.on_built_tile = handler_factory {
    defines.events.on_player_built_tile,
    defines.events.on_robot_built_tile,
    defines.events.on_space_platform_built_tile,
}
Event.on_mined_tile = handler_factory {
    defines.events.on_player_mined_tile,
    defines.events.on_robot_mined_tile,
    defines.events.on_space_platform_mined_tile,
}

Event.on_trigger = (function()
    local handlers

    local function on_event(event)
        local effect_id = event.effect_id
        if not effect_id then
            return
        end

        local handler = handlers[effect_id]
        if not handler then
            return
        end

        handler(event)
    end

    return function(effect_id, handler)
        if not handlers then
            handlers = {}
            EventCore.add(defines.events.on_script_trigger_effect, on_event)
        end

        handlers[effect_id] = handler
    end
end)()

local function register_events()
    local handlers = EventCore.get_handlers()

    for event_name, tokens in pairs(handlers.token_handlers) do
        for _, token in pairs(tokens) do
            local handler = Token.get(token)
            EventCore.add(event_name, handler)
        end
    end

    for tick, tokens in pairs(handlers.token_handlers_on_nth_tick) do
        for _, token in pairs(tokens) do
            local handler = Token.get(token)
            EventCore.add(tick, handler, { on_nth_tick = true })
        end
    end

    for event_name, string_handlers in pairs(handlers.function_handlers) do
        for _, string_handler in pairs(string_handlers) do
            local handler = load('return ' .. string_handler)()
            EventCore.add(event_name, handler)
        end
    end

    for tick, string_handlers in pairs(handlers.function_handlers_on_nth_tick) do
        for _, string_handler in pairs(string_handlers) do
            local handler = load('return ' .. string_handler)()
            EventCore.add(tick, handler, { on_nth_tick = true })
        end
    end
end

EventCore.on_init(register_events)
EventCore.on_load(register_events)

return Event
