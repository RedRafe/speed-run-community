local Shared = require 'utils.shared'

local Enemy = {}

--- Re-assigns unit-spawners and worms to the respective force when auto-placed
fsrc.on_trigger(Shared.triggers.on_enemy_created, function(event)
    local entity = event.source_entity
    if not (entity and entity.valid) then
        return
    end

    entity.force = (entity.position.x > 0) and 'west' or 'east'
end)

--- Freeze all moving parts at the end of the match
fsrc.add(defines.events.on_match_finished, function()
    for _, entity in pairs(game.surfaces.nauvis.find_entities_filtered({ type = { 'unit', 'unit-spawner', 'turret' } })) do
        entity.active = false
    end
end)

return Enemy
