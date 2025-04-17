-- Threading simulation module
-- Task.sleep()
-- created by: Valansch and grilledham
-- source: https://github.com/Refactorio/RedMew/blob/develop/utils/task.lua
-- modified by: RedRafe
-- ========================================================================= --

local Event = require 'scripts.core.event'
local PriorityQueue = require 'utils.containers.priority-queue'
local Queue = require 'utils.containers.queue'
local Storage = require 'scripts.core.storage'
local Token = require 'scripts.core.token'

local Task = {}

local floor = math.floor
local log10 = math.log10
local get_token = Token.get
local pcall = pcall

local task_queue = Queue.new()

local callbacks = PriorityQueue.new(function(a, b)
    return a.time < b.time
end, 'TaskPriorityQueue')

local primitives = {
    next_async_callback_time = -1,
    total_task_weight = 0,
    task_queue_speed = 1,
    task_per_tick = 1,
}

Storage.subscribe({ callbacks = callbacks, task_queue = task_queue, primitives = primitives }, function(tbl)
    callbacks = tbl.callbacks
    task_queue = tbl.task_queue
    primitives = tbl.primitives
end)

local function get_task_per_tick(tick)
    if tick % 300 == 0 then
        local size = primitives.total_task_weight
        local task_per_tick = floor(log10(size + 1)) * primitives.task_queue_speed
        if task_per_tick < 1 then
            task_per_tick = 1
        end

        primitives.task_per_tick = task_per_tick
        return task_per_tick
    end
    return primitives.task_per_tick
end

local function on_tick()
    local tick = game.tick

    for i = 1, get_task_per_tick(tick) do
        local task = task_queue:peek()
        if task ~= nil then
            -- result is error if not success else result is a boolean for if the task should stay in the queue.
            local success, result = pcall(get_token(task.func_token), task.params)
            if not success then
                log(result)
                task_queue:pop()
                primitives.total_task_weight = primitives.total_task_weight - task.weight
            elseif not result then
                task_queue:pop()
                primitives.total_task_weight = primitives.total_task_weight - task.weight
            end
        end
    end

    local callback = callbacks:peek()
    while callback ~= nil and tick >= callback.time do
        local success, result = pcall(get_token(callback.func_token), callback.params)
        if not success then
            log(result)
        end
        callbacks:pop()
        callback = callbacks:peek()
    end
end

--- Allows you to set a timer (in ticks) after which the tokened function will be run with params given as an argument
--- Cannot be called before init
---@param ticks number
---@param func_token number, a token for a function store via the token system
---@param params any, the argument to send to the tokened function
Task.set_timeout_in_ticks = function(ticks, func_token, params)
    if not game then
        error('cannot call when game is not available', 2)
    end
    callbacks:push({ time = game.tick + ticks, func_token = func_token, params = params })
end

--- Allows you to set a timer (in seconds) after which the tokened function will be run with params given as an argument
--- Cannot be called before init
---@param sec number
---@param func_token number, a token for a function store via the token system
---@param params any, the argument to send to the tokened function
Task.set_timeout = function(sec, func_token, params)
    if not game then
        error('cannot call when game is not available', 2)
    end
    Task.set_timeout_in_ticks(60 * sec, func_token, params)
end

--- Queueing allows you to split up heavy tasks which don't need to be completed in the same tick.
--- Queued tasks are generally run 1 per tick. If the queue backs up, more tasks will be processed per tick.
---@param func_token number, a token for a function stored via the token system
--- If this function returns `true` it will run again the next tick, delaying other queued tasks (see weight)
---@param params any, the argument to send to the tokened function
---@param weight number (defaults to 1), weight is the number of ticks a task is expected to take.
--- Ex. if the task is expected to repeat multiple times (ie. the function returns true and loops several ticks)
Task.queue_task = function(func_token, params, weight)
    weight = weight or 1
    primitives.total_task_weight = primitives.total_task_weight + weight
    task_queue:push({ func_token = func_token, params = params, weight = weight })
end

Task.get_queue_speed = function()
    return primitives.task_queue_speed
end

---@param value number
Task.set_queue_speed = function(value)
    value = value or 1
    if value < 0 then
        value = 0
    end

    primitives.task_queue_speed = value
end

Event.add(defines.events.on_tick, on_tick)

return Task
