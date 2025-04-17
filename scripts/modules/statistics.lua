local Config = require 'scripts.config'
local Game = require 'scripts.modules.game'
local Queue = require 'utils.containers.queue'
local ItemStatistics = require 'scripts.modules.item-statistics'

local tracked_items = {}
for _, item in pairs(prototypes.item) do
    if item.stackable and item.group.name ~= 'other' then
        table.insert(tracked_items, item.name)
    end
end
for _, fluid in pairs(prototypes.fluid) do
    if fluid.group.name ~= 'other' then
        table.insert(tracked_items, fluid.name)
    end
end


local Statistics = {}

local MAX_STORED_GAMES = 10

local past = Queue.new()

--[[
    ticks :: number,
    winning_force :: string,
    losing_force :: string,
    north = { item_name :: ItemStatistics(), ... },
    south = { item_name :: ItemStatistics(), ... },
]]
local current = {}

local stats = {
    north = { item = {}, fluid = {} },
    south = { item = {}, fluid = {} },
}

fsrc.subscribe({
    past = past,
    current = current,
    stats = stats,
}, function(tbl)
    past = tbl.past
    current = tbl.current
    stats = tbl.stats
end)

local function get_entity_contents(entity)
    local totals = {}
    if not (entity and entity.valid) then
        return totals
    end
    for i_id = 1, entity.get_max_inventory_index() do
        local inventory = entity.get_inventory(i_id)
        if inventory and inventory.valid and not inventory.is_empty() then
            for _, item in pairs(inventory.get_contents()) do
                totals[item.name] = (totals[item.name] or 0) + item.count
            end
        end
    end
    return totals
end

Statistics.get_current = function()
    return current
end

---@param index? number
Statistics.get_past = function(index)
    if index then
        return past:peek(index)
    else
        return past:to_array()
    end
end

fsrc.add(defines.events.on_tick, function()
    if not Game.is_playing() then
        return
    end

    local item_index = (game.tick % #tracked_items) + 1
    local item_name = tracked_items[item_index]

    for _, side in pairs({ 'north', 'south' }) do
        local force_stats = prototypes.item[item_name] and stats[side].item or stats[side].fluid
        local item_stats = current[side] and current[side][item_name]

        if item_stats then
            item_stats.produced = --[[item_stats.produced +]] force_stats.get_input_count(item_name)
            item_stats.consumed = --[[item_stats.consumed +]] force_stats.get_output_count(item_name)
            item_stats:get_stored()
        end
    end
end)

fsrc.on_built(function(event)
    if not Game.is_playing() then
        return
    end

    local entity = event.entity
    if not (entity and entity.valid) then
        return
    end

    if entity.type == 'entity-ghost' or entity.type == 'tile-ghost' then
        return
    end

    local side = entity.force.name
    local item_stats = side and current[side] and current[side][entity.name]
    if not item_stats then
        return
    end

    item_stats.placed = item_stats.placed + 1
    item_stats:get_stored()
end)

fsrc.on_destroyed(function(event)
    if not Game.is_playing() then
        return
    end

    local entity = event.entity
    if not (entity and entity.valid) then
        return
    end

    if entity.type == 'entity-ghost' or entity.type == 'tile-ghost' then
        return
    end

    local side = entity.force.name
    local item_stats = current[side] and current[side][entity.name]
    if not item_stats then
        return
    end

    item_stats.lost = item_stats.lost + 1

    for item, amount in pairs(get_entity_contents(entity)) do
        current[side][item].lost = current[side][item].lost + amount
    end
end)

fsrc.add(defines.events.on_map_init, function()
    for _, side in pairs({ 'north', 'south' }) do
        -- Cache LuaFlowStatistics
        stats[side].item = game.forces[side].get_item_production_statistics('nauvis')
        stats[side].fluid = game.forces[side].get_fluid_production_statistics('nauvis')

        -- Init ItemStatistics[]
        local force_stats = {}

        for _, item_name in pairs(tracked_items) do
            force_stats[item_name] = ItemStatistics.new({ name = item_name, type = prototypes.item[item_name] and 'item' or 'fluid' })
        end

        current[side] = force_stats
    end
end)

fsrc.add(defines.events.on_match_finished, function(event)
    current.ticks = Game.ticks()
    current.winning_force = event.winning_force
    current.losing_force = event.losing_force
end)

fsrc.add(defines.events.on_map_reset, function()
    -- Push only 'real' games
    if current.ticks and current.ticks > 0 then
        past:push(table.deepcopy(current))
    end

    -- Pop oldest record
    while past:size() > MAX_STORED_GAMES do
        past:pop()
    end

    -- Reset current table
    table.clear_table(current)
end)

return Statistics
