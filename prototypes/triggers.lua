local Shared = require 'utils.shared'

local function effect(event_id)
    return {
        type = 'direct',
        action_delivery = {
            type = 'instant',
            source_effects = {
                type = 'script',
                effect_id = event_id
            }
        }
    }
end

--- Cargo landing pad
data.raw['cargo-landing-pad']['cargo-landing-pad'].created_effect = effect(Shared.triggers.on_cargo_landing_pad_created)

--- Spawners
for _, prototype in pairs(data.raw['unit-spawner']) do
    prototype.created_effect = effect(Shared.triggers.on_enemy_created)
end

--- Turrets
for _, turret_type in pairs({
    'ammo-turret',
    'artillery-turret',
    'electric-turret',
    'fluid-turret',
    'turret',
}) do
    for _, prototype in pairs(data.raw[turret_type]) do
        if prototype.subgroup == 'enemies' then
            prototype.created_effect = effect(Shared.triggers.on_enemy_created)
        else
            prototype.created_effect = effect(Shared.triggers.on_built_turret)
        end
    end
end
