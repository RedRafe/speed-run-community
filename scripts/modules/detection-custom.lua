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
        if not inventory.is_full() then
            return
        end

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

return Custom