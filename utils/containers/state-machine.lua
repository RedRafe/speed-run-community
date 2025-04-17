---@class StateMachine
local StateMachine = {}
StateMachine.__index = StateMachine

script.register_metatable('StateMachine', StateMachine)

local Task = require 'scripts.core.task'
local Token = require 'scripts.core.token'

---@param states table<string, number>
---@param events table<number, number>
function StateMachine.new(states, events)
    return setmetatable({
        states = states,
        events = events,
        current_state = -1,
    }, StateMachine)
end

---@param self StateMachine
---@param state number
---@param data? table
function StateMachine:raise_event_for_state(state, data)
    local event = self.events[state]

    if not event then
        error('Unknown state: ' .. serpent.block({ state = state, events = self.events }))
    end

    --game.print(string.format('[color=red][STATE][/color]: (%d) %s', state, table.index_of(self.states, state)))
    return script.raise_event(event, data or {})
end

---@param self StateMachine
---@param state number
---@param data? table
function StateMachine:set_state(state, data)
    self.current_state = state
    self:raise_event_for_state(state, data)
end

local set_state_callback = Token.register(function(tbl)
    StateMachine.set_state(tbl.self, tbl.state, tbl.data)
end)

---@param self StateMachine
---@param next_state? number
---@param data? table
function StateMachine:transition(next_state, data)
    next_state = next_state or (self.current_state + 1) % table.size(self.states)

    Task.set_timeout_in_ticks(1, set_state_callback, {
        self = self,
        state = next_state,
        data = data,
    })
end

---@param self StateMachine
---@return number
function StateMachine:get_state()
    return self.current_state
end

return StateMachine
