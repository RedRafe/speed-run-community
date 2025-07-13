local Gui = require 'scripts.modules.gui'

if not _DEBUG then
    return
end

-- Auto research
fsrc.add(defines.events.on_research_started, function(event)
    event.research.researched = true
end)
fsrc.add(defines.events.on_match_started, function()
    for _, force in pairs({ game.forces.west, game.forces.east }) do
        force.technologies['electronics'].researched = true
        force.technologies['steam-power'].researched = true
        force.technologies['automation-science-pack'].researched = true
    end
end)

local frame_name = Gui.uid_name('debug')
local hax_button = Gui.uid_name('hax')
local force_button = Gui.uid_name('force')
local armor_button = Gui.uid_name('armor')

fsrc.add(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)

    local frame = Gui.add_left_element(player, {
        name = frame_name,
        type = 'frame',
        direction = 'vertical'
    })

    frame.add{ type = 'label', caption = 'Debug menu', style = 'caption_label'}
    frame.add{ type = 'button', caption = 'Hax', name = hax_button, tooltip = 'Unlock all recipes' }
    frame.add{ type = 'button', caption = 'Armor', name = armor_button, tooltip = 'Suit up with full MK2 armor' }
    frame.add{ type = 'button', caption = 'West', tags = { [Gui.tag] = force_button, force = 'west'}, tooltip = 'Join West' }
    frame.add{ type = 'button', caption = 'East', tags = { [Gui.tag] = force_button, force = 'east'}, tooltip = 'Join East' }
    frame.add{ type = 'button', caption = 'Spectator', tags = { [Gui.tag] = force_button, force = 'player'}, tooltip = 'Join spectator island' }
end)

Gui.on_click(hax_button, function(event)
    event.player.cheat_mode = true
    for _, recipe in pairs(event.player.force.recipes) do
        recipe.enabled = true
    end
end)

Gui.on_click(armor_button, function(event)
    local player = event.player
    player.get_inventory(defines.inventory.character_armor).insert({ name = 'power-armor-mk2', count = 1 })

    local grid = player.get_inventory(defines.inventory.character_armor).find_item_stack('power-armor-mk2').grid
    for _, e in pairs({
        { name = 'personal-laser-defense-equipment' },
        { name = 'personal-laser-defense-equipment' },
        { name = 'personal-laser-defense-equipment' },
        { name = 'personal-laser-defense-equipment' },
        { name = 'personal-laser-defense-equipment' },
        { name = 'personal-laser-defense-equipment' },
        { name = 'personal-laser-defense-equipment' },
        { name = 'personal-laser-defense-equipment' },
        { name = 'personal-laser-defense-equipment' },
        { name = 'personal-laser-defense-equipment' },
        { name = 'energy-shield-mk2-equipment'},
        { name = 'battery-mk2-equipment' },
        { name = 'battery-mk2-equipment' },
        { name = 'battery-mk2-equipment' },
        { name = 'battery-mk2-equipment' },
        { name = 'battery-mk2-equipment' },
        { name = 'battery-mk2-equipment' },
        { name = 'energy-shield-mk2-equipment'},
        { name = 'fission-reactor-equipment' },
        { name = 'exoskeleton-equipment' },
        { name = 'fission-reactor-equipment' },
    }) do grid.put(e).energy = 10e9 end
end)

Gui.on_click(force_button, function(event)
    event.player.force = event.element.tags.force
end)
