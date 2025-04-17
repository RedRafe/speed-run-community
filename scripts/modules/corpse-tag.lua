local Public = {}

local format = string.format

local map_tags = {}
fsrc.subscribe(map_tags, function(tbl) map_tags = tbl end)

local armors = {
    'power-armor-mk2',
    'power-armor',
    'modular-armor',
    'heavy-armor',
}

if script.active_mods['space-age'] then
    table.insert(armors, 'mech-armor', 1)
end

local function get_armor_icon(inventory)
    local get_item_count = inventory.get_item_count
    for _, armor in pairs(armors) do
        if get_item_count(armor) > 0 then
            return armor
        end
    end
    return 'light-armor'
end

--- Add map tag to player's corpse (if not empty)
fsrc.add(defines.events.on_player_died, function(event)
    local player = event.player_index and game.get_player(event.player_index)
    if not (player and player.valid) then
        return
    end

    local tick = game.tick
    local entity
    for _, corpse in
        pairs(player.physical_surface.find_entities_filtered {
            position = player.physical_position,
            radius = 0.5,
            name = 'character-corpse',
        })
    do
        if corpse.character_corpse_player_index == player.index and corpse.character_corpse_tick_of_death == tick then
            entity = corpse
            break
        end
    end

    if not (entity and entity.valid) then
        return
    end

    local inv = entity.get_inventory(defines.inventory.character_corpse)
    if not (inv and inv.valid) then
        return
    end

    if inv.is_empty() then
        entity.destroy()
        return
    end

    map_tags[fsrc.register_on_object_destroyed(entity)] = player.force.add_chart_tag(entity.surface, {
        position = entity.position,
        icon = { type = 'item', name = get_armor_icon(inv) },
        text = format('%s\'s corpse', player.name),
    })
end)

--- Remove chart tags when retrieving the body
fsrc.add(defines.events.on_object_destroyed, function(event)
    local tag = event.registration_number and map_tags[event.registration_number]

    if not tag then
        return
    end

    if tag.valid then
        tag.destroy()
    end

    map_tags[event.registration_number] = nil
end)

Public.clear_all_tags = function()
    for id, tag in pairs(map_tags) do
        if tag and tag.valid then
            tag.destroy()
        end
        map_tags[id] = nil
    end
end

return Public
