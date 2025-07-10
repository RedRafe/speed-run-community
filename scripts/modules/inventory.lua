local starting_items = {
    { name = 'burner-mining-drill', count = 10 },
    { name = 'stone-furnace', count = 50 },
    { name = 'wood', count = 100 },
    { name = 'coal', count = 250 },
    { name = 'iron-plate', count = 200 },
    { name = 'iron-gear-wheel', count = 25 },
}

local Public = {}

fsrc.subscribe({
    starting_items = starting_items
}, function(tbl)
    starting_items = tbl.starting_items
end)

fsrc.add(defines.events.on_player_changed_force, function(event)
    local player = event.player_index and game.get_player(event.player_index)
    local character = player.character
    if not (character and character.valid) then
        return
    end

    if player.force.name == 'player' then
        player.clear_cursor()
        for k = 1, character.get_max_inventory_index() do
            local inv = character.get_inventory(k)
            if inv and inv.valid then
                inv.clear()
            end
        end
    else
        local inv = character.get_main_inventory()
        for _, stack in pairs(starting_items) do
            inv.insert(stack)
        end
        character.get_inventory(defines.inventory.character_guns).insert({ name = 'pistol', count = 1 })
        character.get_inventory(defines.inventory.character_ammo).insert({ name = 'firearm-magazine', count = 20 })
    end
end)

return Public