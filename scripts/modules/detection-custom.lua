local sides = {
    north = true,
    south = true,
}

local Custom = {}

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

Custom.full_coal_inventory = {
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

Custom.full_unique_inventory = {
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

return Custom