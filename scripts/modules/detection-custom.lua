local sides = {
    north = true,
    south = true,
}

local Custom = {}

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
            ---@cast chest -?
            return
        end
        if not chest.valid then
            data.chests[index] = nil
        end

        local inventory = chest.get_inventory(defines.inventory.chest)
        if inventory.get_item_count('iron-chest') == #inventory * 50 then
            return chest.force.name
        end
    end,
}
Custom.full_iron_chest[defines.events.on_robot_built_entity] = Custom.full_iron_chest[defines.events.on_built_entity]

Custom.full_steel_chest_unique = {
        [defines.events.on_built_entity] = function(event, data)
        local entity = event.entity
        if entity.name ~= 'steel-chest' then
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
            if seen[name] or inventory.get_insertable_count(name) > 0 then
                return
            end
            seen[name] = true
        end

        return chest.force.name
    end,
}
Custom.full_steel_chest_unique[defines.events.on_robot_built_entity] = Custom.full_steel_chest_unique[defines.events.on_built_entity]

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
                if not seen[neighbor.unit_number] then
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

Custom.shotgun_kills = {
    [defines.events.on_entity_damaged] = function(event, data)
        if event.entity.type ~= 'unit' then
            return
        end

        if event.final_health > 0 then
            return
        end

        local source = event.source
        if not source then
            return
        end
        if not (source.name == 'shotgun-pellet' or source.name == 'piercing-shotgun-pellet') then
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

        local count = (data[side] or 0) + 1
        data[side] = count

        if count >= 100 then
            return side
        end
    end,
}

return Custom