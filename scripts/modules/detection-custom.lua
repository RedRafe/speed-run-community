local Statistics = require 'scripts.modules.statistics'

local sides = {
    west = true,
    east = true,
}

local Custom = {}

local function is_targeting_entity(unit, entity)
    local distraction = unit.commandable.distraction_command
    if not distraction then
        return
    end

    local target = distraction.target
    if not target then
        return
    end

    if target == entity then
        return true
    end

    if target.type == 'unit' then
        return is_targeting_entity(target, entity)
    end
end

Custom.biter_chase = {
    [defines.events.on_tick] = function(_, data)
        for side in pairs(sides) do
            for _, player in pairs(game.forces[side].connected_players) do
                local character = player.character
                if not character then
                    goto continue
                end

                local surface = player.surface
                local enemy = surface.find_nearest_enemy{max_distance = 32, position = player.position, force = player.force}
                if not (enemy and enemy.type == 'unit') then
                    goto continue
                end

                if not is_targeting_entity(enemy, character) then
                    goto continue
                end

                local count = 0
                for _, unit in pairs(surface.find_enemy_units(player.position, 100, player.force)) do
                    if is_targeting_entity(unit, character) then
                        -- unit.surface.create_entity{name = 'highlight-box', position = unit.position, source = unit, time_to_live = 1}
                        count = count + 1
                    end
                end

                -- game.print(count)
                if count >= data.count then
                    return side
                end

                ::continue::
            end
        end
    end,
}

Custom.botlap = {
    [defines.events.on_robot_built_entity] = function(event)
        local entity = event.entity
        if entity.type ~= 'locomotive' then
            return
        end

        local side = entity.force.name
        if not sides[side] then
            return
        end

        return side
    end,
}

Custom.destroy_cliff = {
    [defines.events.on_player_used_capsule] = function(event)
        if event.item.name ~= 'cliff-explosives' then
            return
        end

        local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
        local side = player.force.name
        if not sides[side] then
            return
        end

        return side
    end,
}

Custom.full_inventory_coal = {
    [defines.events.on_player_main_inventory_changed] = function(event)
        local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
        local side = player.force.name
        if not sides[side] then
            return
        end

        local inventory = player.get_main_inventory() --[[@as LuaInventory]]
        if inventory.get_item_count('coal') == #inventory * 50 then
            return side
        end
    end,
}

Custom.full_inventory_unique = {
    [defines.events.on_player_main_inventory_changed] = function(event)
        local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
        local side = player.force.name
        if not sides[side] then
            return
        end

        local inventory = player.get_main_inventory() --[[@as LuaInventory]]
        if inventory.count_empty_stacks(true, true) > 0 then return end

        local seen = {}
        for i = 1, #inventory do
            local name = inventory[i].name
            if seen[name] then
                return
            end
            seen[name] = true
        end

        return side
    end,
}

Custom.full_iron_chest = {
    [defines.events.on_match_started] = function(_, data)
        data.chests = {}
    end,
    [defines.events.on_built_entity] = function(event, data)
        local entity = event.entity
        if entity.name ~= 'iron-chest' then
            return
        end

        local side = entity.force.name
        if not sides[side] then
            return
        end

        data.chests[entity.unit_number] = entity
    end,
    [defines.events.on_tick] = function(_, data)
        local index, chest = next(data.chests, data.index)
        if not index then
            data.index = nil
            ---@cast chest LuaEntity
            return
        end
        if not chest.valid then
            data.chests[index] = nil
            return
        end

        local inventory = chest.get_inventory(defines.inventory.chest) --[[@as LuaInventory]]
        if inventory.get_item_count('iron-chest') == #inventory * 50 then
            return chest.force.name
        end
    end,
}
Custom.full_iron_chest[defines.events.on_robot_built_entity] = Custom.full_iron_chest[defines.events.on_built_entity]

-- TODO: disallow spawnable items
Custom.full_chest_unique = {
        [defines.events.on_match_started] = function(_, data)
            data.chests = {}
        end,
        [defines.events.on_built_entity] = function(event, data)
        local entity = event.entity
        if entity.name ~= data.name then
            return
        end

        local side = entity.force.name
        if not sides[side] then
            return
        end

        data.chests[entity.unit_number] = entity
    end,
    [defines.events.on_tick] = function(_, data)
        local index, chest = next(data.chests, data.index)
        if not index then
            data.index = nil
            ---@cast chest -?
            return
        end
        if not chest.valid then
            data.chests[index] = nil
        end

        local inventory = chest.get_inventory(defines.inventory.chest)
        if inventory.count_empty_stacks(true, true) > 0 then
            return
        end

        local seen = {}
        for i = 1, #inventory do
            local name = inventory[i].name
            local flags = prototypes.item[name].flags
            if (flags and flags.spawnable) or seen[name] or inventory.get_insertable_count(name) > 0 then
                return
            end
            seen[name] = true
        end

        return chest.force.name
    end,
}
Custom.full_chest_unique[defines.events.on_robot_built_entity] = Custom.full_chest_unique[defines.events.on_built_entity]

Custom.full_modular_grid = {
    [defines.events.on_player_placed_equipment] = function(event)
        local grid = event.grid
        local player = grid.player_owner
        if not player and player.character then
            return
        end

        local side = player.force.name
        if not sides[side] then
            return
        end

        local inventory = player.get_inventory(defines.inventory.character_armor)
        local slot = inventory[1]
        if slot.name ~= 'modular-armor' then
            return
        end
        if slot.grid ~= grid then
            return
        end

        local total = 0
        for _, equipment in pairs(grid.equipment) do
            local shape = equipment.shape
            total = total + shape.width * shape.height
        end

        if total == grid.width * grid.height then
            return side
        end
    end,
}

Custom.long_gate = {
    [defines.events.on_built_entity] = function(event, data)
        local entity = event.entity
        if entity.type ~= 'gate' then
            return
        end

        local side = entity.force.name
        if not sides[side] then
            return
        end

        local to_check = {entity}
        local seen = {[entity.unit_number] = true}
        for _, gate in pairs(to_check) do
            for _, neighbor in pairs(gate.neighbours) do
                if neighbor.type == 'gate' and not seen[neighbor.unit_number] then
                    seen[neighbor.unit_number] = true
                    to_check[#to_check+1] = neighbor
                end
            end
        end

        if #to_check >= data.count then
            return side
        end
    end,
}

Custom.long_train = {
    [defines.events.on_built_entity] = function(event, data)
        local entity = event.entity
        local train = entity.train
        if not train then
            return
        end

        local side = entity.force.name
        if not sides[side] then
            return
        end

        if #train.carriages >= data.count then
            return side
        end
    end,
}

local rock_whitelist = { 'big-sand-rock', 'big-rock', 'huge-rock', }
Custom.rock_power = {
    [defines.events.on_match_started] = function(_, data)
        data.rocks = {}
    end,
    [defines.events.on_built_entity] = function(event, data)
        local entity = event.entity --[[@as LuaEntity]]
        if entity.type ~= 'electric-pole' then
            return
        end

        local side = entity.force.name
        if not sides[side] then
            return
        end

        local supply_distance = entity.prototype.get_supply_area_distance(entity.quality)
        local area = { entity.position, entity.position }
        area[1].x = area[1].x - supply_distance
        area[1].y = area[1].y - supply_distance
        area[2].x = area[2].x + supply_distance
        area[2].y = area[2].y + supply_distance

        local rocks = entity.surface.find_entities_filtered{ area = area, name = rock_whitelist }
        for _, rock in pairs(rocks) do
            local rock_id = script.register_on_object_destroyed(rock)
            local rock_data = data.rocks[rock_id] or {  }
            data.rocks[rock_id] = rock_data
            rock_data[entity.unit_number] = entity

            rock.surface.create_entity{
                name = 'highlight-box',
                position = rock.position,
                source = rock,
                time_to_live = 90,
                blink_interval = 15,
            }
        end

        local networks = {}
        for _, poles in pairs(data.rocks) do
            for unit_number, pole in pairs(poles) do
                if not pole.valid then
                    poles[unit_number] = nil
                    goto continue
                end

                local id = pole.electric_network_id
                local network = networks[id] or { pole = pole, count = 0 }
                networks[id] = network
                network.count = network.count + 1

                ::continue::
            end
        end

        for _, network in pairs(networks) do
            if network.count >= data.count then
                local statistics = network.pole.electric_network_statistics
                for _, output_count in pairs(statistics.output_counts) do
                    if output_count > 0 then
                        return side
                    end
                end
            end
        end
    end,
    [defines.events.on_object_destroyed] = function(event, data)
        data.rocks[event.registration_number] = nil
    end,
}

Custom.shoot_ammo = {
    [defines.events.on_tick] = function()
        local stats = Statistics.get_current()

        for side in pairs(sides) do
            local item_stats = stats[side]
            if item_stats['firearm-magazine'].consumed - item_stats['piercing-rounds-magazine'].consumed >= 500 then
                return side
            end
        end
    end,
}

Custom.source_kills = {
    [defines.events.on_entity_damaged] = function(event, data)
        if event.entity.type ~= data.entity_type then
            return
        end

        if event.final_health > 0 then
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

        local source = event.source
        if not source then
            return
        end

        for _, name in pairs(data.source) do
            if source.name == name then
                goto forelse
            end
        end
        do return end
        ::forelse::

        local count = (data[side] or 0) + 1
        data[side] = count

        if count >= data.count then
            return side
        end
    end,
}

Custom.stay_in_car = {
    [defines.events.on_match_started] = function(_, data)
        data.players = {}
    end,
    [defines.events.on_player_driving_changed_state] = function(event, data)
        local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
        local side = player.force.name
        if not sides[side] then
            return
        end

        local entity = event.entity
        if not (entity and entity.name == 'car') then
            data.players[event.player_index] = nil
        end

        data.players[event.player_index] = {car = entity, end_tick = event.tick + data.ticks}
    end,
    [defines.events.on_tick] = function(event, data)
        for index, player_data in pairs(data.players) do
            if player_data.end_tick == event.tick then
                local player = game.get_player(index) --[[@as LuaPlayer]]
                if not (player_data.car.valid and player_data.car == player.physical_vehicle) then
                    data.players[index] = nil
                else
                    local side = player.force.name
                    if not sides[side] then
                        data.players[index] = nil
                        return
                    end
                    return side
                end
            end
        end
    end,
}

return Custom