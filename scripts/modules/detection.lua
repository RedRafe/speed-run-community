local Challenges = require 'scripts.modules.challenges'
local Game = require 'scripts.modules.game'
local Statistics = require 'scripts.modules.statistics'
local PlayerGui = require 'scripts.gui.player.challenges'
local Custom = require 'scripts.modules.detection-custom'

local Visual = PlayerGui.Visual

local challenge_map = {}
local death_counts = {}
local custom_data = {}
local current = {
    build = {},
    craft = {},
    research = {},
    hold = {},
    death = {},
    equip = {},
    custom = {},
}

fsrc.subscribe({
    challenge_map = challenge_map,
    death_counts = death_counts,
    custom_data = custom_data,
    current = current,
}, function(tbl)
    challenge_map = tbl.challenge_map
    death_counts = tbl.death_counts
    custom_data = tbl.custom_data
    current = tbl.current
end)

local function complete_condition(condition, side)
    local challenge = challenge_map[condition]
    if challenge.side then
        return
    end
    challenge.side = side

    Visual.print_challenge(challenge, side)
    Visual.update_all()
end

-- this variable intentionally left local
-- local detector_map = {}
-- local function remove_handlers(detectors)
--     for id, detector in pairs(detectors) do
--         fsrc.remove(id, detector_map[detector])
--         detector_map[detector] = nil
--     end
-- end

-- local function register_custom_handlers()
--     for k, condition in pairs(current.custom) do
--         local detectors = Custom[condition.name]
--         local data = custom_data[condition.name]
--         for id, detector in pairs(detectors) do
--             local handler = function(event)
--                 if not Game.is_playing() then
--                     return
--                 end
--                 local side = detector(event, data)
--                 if side then
--                     current.custom[k] = nil
--                     complete_condition(condition, side)
--                     remove_handlers(detectors)
--                 end
--             end
--             detector_map[detector] = handler
--             fsrc.add(id, handler)
--         end
--     end
-- end

-- fsrc.on_load(register_custom_handlers)

local function add_or_create(tbl, k, v)
    local arr = tbl[k]
    if arr then
        arr[#arr+1] = v
        return
    end
    arr = { v }
    tbl[k] = arr
end

local clear = table.clear_table

local sides = {
    west = true,
    east = true,
}

for _, challenge in pairs(Challenges.get_challenges()) do
    local condition = challenge.condition
    if condition and condition.type == 'custom' then
        local detectors = Custom[condition.name]
        local data = custom_data[condition.name]
        for id, detector in pairs(detectors) do
            fsrc.add(id, function(event)
                if not (Game.is_playing() and current.custom[condition]) then
                    return
                end
                local side = detector(event, data)
                if side then
                    current.custom[condition] = nil
                    complete_condition(condition, side)
                end
            end)
        end
    end
end

local function on_match_started()
    local selected = PlayerGui.get_selected()

    clear(challenge_map)
    clear(death_counts)
    clear(custom_data)
    for _, tbl in pairs(current) do
        clear(tbl)
    end

    for _, challenge in pairs(selected) do
        local condition = challenge.condition
        if not condition then
            goto continue
        end

        challenge_map[condition] = challenge

        if condition.type == 'craft' then
            current.craft[challenge.caption] = condition
        elseif condition.type == 'custom' then
            current.custom[condition.name] = condition
        else
            for _, name in pairs(condition.names or { condition.name }) do
                add_or_create(current[condition.type], name, condition)
            end
        end

        for _, death_conditions in pairs(current.death) do
            for _, death_condition in pairs(death_conditions) do
                death_counts[death_condition] = { west = 0, east = 0 }
            end
        end

        ::continue::
    end

    for _, condition in pairs(current.custom) do
        local data = table.deepcopy(condition.data) or {}
        custom_data[condition.name] = data
    end

    -- register_custom_handlers()
end

-- local function on_match_finished()
--     for _, condition in pairs(current.custom) do
--         remove_handlers(Custom[condition.name])
--     end
-- end

fsrc.add(defines.events.on_match_started, on_match_started)
-- fsrc.add(defines.events.on_match_finished, on_match_finished)
-- fsrc.add(defines.events.on_challenges_changed, function()
--     on_match_finished()
--     on_match_started()
-- end)

-- Build

---@param id string
---@param side string
local function built(id, side)
    local conditions = current.build[id]
    if not conditions then
        return
    end

    if not sides[side] then
        return
    end

    local current_stats = Statistics.get_current()
    local stats = current_stats[side]
    if not stats then
        return
    end

    for k, condition in pairs(conditions) do
        for _, name in pairs(condition.names or {condition.name}) do
            local item_stats = stats[name]
            if not item_stats then
                goto continue
            end
            if item_stats.placed - item_stats.lost < (condition.count or 1) then
                goto continue
            end
        end

        conditions[k] = nil
        complete_condition(condition, side)

        ::continue::
    end
end

fsrc.on_built(function(event)
    if not Game.is_playing() then
        return
    end

    local entity = event.entity
    if not (entity and entity.valid) then
        return
    end

    built(entity.name, entity.force.name)
end)

fsrc.on_built_tile(function(event)
    if not Game.is_playing() then
        return
    end

    local tile = event.tile
    local source = event.robot or event.platform or game.get_player(event.player_index) --[[@as LuaPlayer]]
    built(tile.name, source.force.name)
end)

-- Craft
-- can potentially be optimized to have statistics.lua call something here when it scans an item that's being tracked
-- but I doubt the perf hit is that bad for <25 items a tick - this isn't even making api calls, just indexing tables
fsrc.add(defines.events.on_tick, function()
    if not Game.is_playing() then
        return
    end

    local stats = Statistics.get_current()
    local crafts = current.craft

    for side in pairs(sides) do
        local item_stats = stats[side]
        for k, condition in pairs(crafts) do
            for _, name in pairs(condition.names or {condition.name}) do
                if item_stats[name].produced < (condition.count or 1) then
                    goto continue
                end
            end

            crafts[k] = nil
            complete_condition(condition, side)

            ::continue::
        end
    end

end)

-- Research
fsrc.add(defines.events.on_research_finished, function(event)
    if not Game.is_playing() then
        return
    end

    local research = event.research

    local conditions = current.research[research.name]
    if not conditions then
        return
    end

    local force = research.force
    local side = force.name
    if not sides[side] then
        return
    end

    local technologies = force.technologies
    for k, condition in pairs(conditions) do
        for _, name in pairs(condition.names or {condition.name}) do
            if not technologies[name].researched then
                goto continue
            end
        end

        conditions[k] = nil
        complete_condition(condition, side)

        ::continue::
    end

end)

-- Hold
fsrc.add(defines.events.on_player_main_inventory_changed, function(event)
    if not Game.is_playing() then
        return
    end

    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local side = player.force.name
    if not sides[side] then
        return
    end

    local inventory = player.get_main_inventory() --[[@as LuaInventory]]

    for _, conditions in pairs(current.hold) do
        for k, condition in pairs(conditions) do
            for _, name in pairs(condition.names or {condition.name}) do
                if inventory.get_item_count(name) < (condition.count or 1) then
                    goto continue
                end
            end

            conditions[k] = nil
            complete_condition(condition, side)

            ::continue::
        end
    end
end)

-- Death
fsrc.add(defines.events.on_entity_died, function(event)
    if not Game.is_playing() then
        return
    end

    local entity = event.entity
    if not entity.valid then
        return
    end

    local conditions = current.death[entity.name]
    if not conditions then
        return
    end

    local death_side = entity.force.name

    if not sides[death_side] then
        return
    end

    for k, condition in pairs(conditions) do
        local side = death_side
        if condition.enemy then
            if not side:find('enemy') then
                goto continue
            end
            side = side:sub(7)
            game.print(side)
        end
        if condition.cause_name then
            local cause = event.cause
            if not cause then
                goto continue
            end
            if cause.name ~= condition.cause_name then
                goto continue
            end
        elseif condition.cause_type then
            local cause = event.cause
            if not cause then
                goto continue
            end
            if cause.type ~= condition.cause_type then
                goto continue
            end
        end
        if condition.damage_type then
            local damage_type = event.damage_type
            if not damage_type then
                goto continue
            end
            if damage_type.name ~= condition.damage_type then
                goto continue
            end
        end

        local death_count = death_counts[condition][side] + 1
        death_counts[condition][side] = death_count

        if death_count < (condition.count or 1) then
            goto continue
        end

        conditions[k] = nil
        complete_condition(condition, side)

        ::continue::
    end
end)

-- Equip
fsrc.add(defines.events.on_player_placed_equipment, function(event)
    if not Game.is_playing() then
        return
    end

    local equipment = event.equipment
    local conditions = current.equip[equipment.name]
    if not conditions then
        return
    end

    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local side = player.force.name
    if not sides[side] then
        return
    end

    local grid = event.grid
    if grid.player_owner ~= player then
        return
    end

    for k, condition in pairs(conditions) do
        if grid.count(equipment) < (condition.count or 1) then
            return
        end

        conditions[k] = nil
        complete_condition(condition, side)
    end
end)