local Challenges = require 'scripts.modules.challenges'
local Game = require 'scripts.modules.game'
local Statistics = require 'scripts.modules.statistics'
local PlayerGui = require 'scripts.gui.player.challenges'
local Custom = require 'scripts.modules.detection-custom'

local Visual = PlayerGui.Visual

local condition_map = {}
local caption_map = {}
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
    condition_map = condition_map,
    caption_map = caption_map,
    death_counts = death_counts,
    custom_data = custom_data,
    current = current,
}, function(tbl)
    condition_map = tbl.condition_map
    caption_map = tbl.caption_map
    death_counts = tbl.death_counts
    custom_data = tbl.custom_data
    current = tbl.current
end)

local function complete_challenge(challenge, side)
    if challenge.side then
        return
    end
    challenge.side = side

    Visual.print_challenge(challenge, side)
    Visual.update_all()
end

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

local function register_custom_handlers()
    local custom = current.custom
    for _, challenge in pairs(Challenges.get_challenges()) do
        local condition = challenge.condition
        if condition and condition.type == 'custom' then
            local caption = challenge.caption
            for id, detector in pairs(Custom[condition.name]) do
                fsrc.add(id, function(event)
                    if not (Game.is_playing() and custom[caption]) then
                        return
                    end
                    local side = detector(event, custom_data[caption])
                    if side then
                        complete_challenge(caption_map[caption], side)
                        custom[caption] = nil
                    end
                end)
            end
        end
    end
end

fsrc.on_init(register_custom_handlers)
fsrc.on_load(register_custom_handlers)

local function on_match_started()
    local selected = PlayerGui.get_selected()

    clear(condition_map)
    clear(caption_map)
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

        condition_map[condition] = challenge
        caption_map[challenge.caption] = challenge

        if condition.type == 'craft' then
            current.craft[challenge.caption] = condition
        elseif condition.type == 'death' and condition.entity_type then
            for name in pairs(prototypes.get_entity_filtered{ { filter = "type", type = condition.entity_type } }) do
                add_or_create(current.death, name, condition)
            end
        elseif condition.type == 'custom' then
            current.custom[challenge.caption] = condition
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

    for caption, condition in pairs(current.custom) do
        local data = table.deepcopy(condition.data) or {}
        custom_data[caption] = data
    end
end

fsrc.add(defines.events.on_match_started, on_match_started)

--- Build
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
        complete_challenge(condition_map[condition], side)

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

--- Craft
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
                if item_stats[name] and (item_stats[name].produced < (condition.count or 1)) then
                    goto continue
                end
            end

            crafts[k] = nil
            complete_challenge(condition_map[condition], side)

            ::continue::
        end
    end

end)

--- Research
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
        complete_challenge(condition_map[condition], side)

        ::continue::
    end

end)

--- Hold
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
            complete_challenge(condition_map[condition], side)

            ::continue::
        end
    end
end)

--- Death
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

    local force = event.force
    if not force then
        return
    end

    local side = force.name
    if not sides[side] then
        return
    end

    for k, condition in pairs(conditions) do
        local cause = event.cause
        if not cause then
            goto continue
        end
        if condition.cause_name then
            if cause.name ~= condition.cause_name then
                goto continue
            end
        elseif condition.cause_type then
            if cause.type ~= condition.cause_type then
                goto continue
            end
        end
        if condition.same_force ~= nil then
            if (cause.force == force) ~= condition.same_force then
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
        complete_challenge(condition_map[condition], side)

        ::continue::
    end
end)

--- Equip
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
        complete_challenge(condition_map[condition], side)
    end
end)