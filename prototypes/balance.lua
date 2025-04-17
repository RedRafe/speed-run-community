-- == AMMO MODIFIERS ==========================================================

local modifier = {
    bullet = 1 + 0.16,  -- + 16%
    shotgun = 1 + 1,    -- +100%
    fire = 1 - 0.6,     -- - 60%
    landmine = 1 - 0.9, -- - 90%
}

--- Bullet
data.raw.ammo['firearm-magazine'].ammo_type.action[1].action_delivery[1].target_effects[2].damage.amount = 5 * modifier.bullet
data.raw.ammo['piercing-rounds-magazine'].ammo_type.action.action_delivery.target_effects[2].damage.amount = 8 * modifier.bullet
data.raw.ammo['uranium-rounds-magazine'].ammo_type.action.action_delivery.target_effects[2].damage.amount = 24 * modifier.bullet
data.raw['combat-robot']['defender'].attack_parameters.ammo_type.action.action_delivery.target_effects[2].damage.amount = 8 * modifier.bullet

--- Shotgun shells
data.raw.projectile['shotgun-pellet'].action.action_delivery.target_effects.damage.amount = 8 * modifier.shotgun
data.raw.projectile['piercing-shotgun-pellet'].action.action_delivery.target_effects.damage.amount = 8 * modifier.shotgun

--- Flamethrower
data.raw.stream['handheld-flamethrower-fire-stream'].action[1].action_delivery.target_effects[1].sticker = 'bb-fire-sticker'
data.raw.stream['handheld-flamethrower-fire-stream'].action[1].action_delivery.target_effects[2].damage.amount = 2 * modifier.fire
data.raw.stream['handheld-flamethrower-fire-stream'].action[2].action_delivery.target_effects[1].entity_name = 'bb-fire-flame'

data.raw.stream['flamethrower-fire-stream'].action[1].action_delivery.target_effects[1].sticker = 'bb-fire-sticker'
data.raw.stream['flamethrower-fire-stream'].action[1].action_delivery.target_effects[2].damage.amount = 3 * modifier.fire
data.raw.stream['flamethrower-fire-stream'].action[2].action_delivery.target_effects[1].entity_name = 'bb-fire-flame'

data.raw.stream['tank-flamethrower-fire-stream'].action[1].action_delivery.target_effects[1].damage.amount = 7 * modifier.fire

data.raw.fire['bb-fire-flame'].damage_per_tick.amount = 13 / 60 * modifier.fire
data.raw.sticker['bb-fire-sticker'].damage_per_tick.amount = 10 * 100 / 60 * modifier.fire

--- Landmine
data.raw['land-mine']['land-mine'].action.action_delivery.source_effects[1].action.action_delivery.target_effects[1].damage.amount = 250 * modifier.landmine
data.raw['land-mine']['land-mine'].action.action_delivery.source_effects[3].damage.amount = 1000 * modifier.landmine

-- == UPGRADE MODIFIERS =======================================================

local ammo_damage = function(name, value)
    return {
        type = 'ammo-damage',
        ammo_category = name,
        modifier = value
    }
end

local turret_attack = function(name, value) -- luacheck: ignore 211
    return {
        type = 'turret-attack',
        turret_id = name,
        modifier = value
    }
end

local upgrade_modifiers = {
    ['refined-flammables-1'] = { ammo_damage('flamethrower', 0.15) },
    ['refined-flammables-2'] = { ammo_damage('flamethrower', 0.15) },
    ['refined-flammables-3'] = { ammo_damage('flamethrower', 0.15) },
    ['refined-flammables-4'] = { ammo_damage('flamethrower', 0.15) },
    ['refined-flammables-5'] = { ammo_damage('flamethrower', 0.15) },
    ['refined-flammables-6'] = { ammo_damage('flamethrower', 0.15) },
    ['refined-flammables-7'] = { ammo_damage('flamethrower', 0.15) },
    ['laser-weapons-damage-1'] = { ammo_damage('laser', 0.2) },
    ['laser-weapons-damage-2'] = { ammo_damage('laser', 0.2) },
    ['laser-weapons-damage-3'] = { ammo_damage('laser', 0.3) },
    ['laser-weapons-damage-4'] = { ammo_damage('laser', 0.4) },
    ['laser-weapons-damage-5'] = { ammo_damage('laser', 0.5), ammo_damage('beam', 0.4) },
    ['laser-weapons-damage-6'] = { ammo_damage('laser', 0.7), ammo_damage('beam', 0.6), ammo_damage('electric', 0.7) },
    ['laser-weapons-damage-7'] = { ammo_damage('laser', 0.7), ammo_damage('beam', 0.3), ammo_damage('electric', 0.7) },
    ['stronger-explosives-1'] = { ammo_damage('grenade', 0.48) },
    ['stronger-explosives-2'] = { ammo_damage('grenade', 0.48), ammo_damage('landmine', 0.1) },
    ['stronger-explosives-3'] = { ammo_damage('grenade', 0.48), ammo_damage('landmine', 0.1), ammo_damage('rocket', 0.3) },
    ['stronger-explosives-4'] = { ammo_damage('grenade', 0.48), ammo_damage('landmine', 0.1), ammo_damage('rocket', 0.4) },
    ['stronger-explosives-5'] = { ammo_damage('grenade', 0.48), ammo_damage('landmine', 0.1), ammo_damage('rocket', 0.5) },
    ['stronger-explosives-6'] = { ammo_damage('grenade', 0.48), ammo_damage('landmine', 0.1), ammo_damage('rocket', 0.6) },
    ['stronger-explosives-7'] = { ammo_damage('grenade', 0.48), ammo_damage('landmine', 0.1), ammo_damage('rocket', 0.5) },
    ['physical-projectile-damage-1'] = { ammo_damage('bullet', 0.3), ammo_damage('shotgun-shell', 0.3) },
    ['physical-projectile-damage-2'] = { ammo_damage('bullet', 0.3), ammo_damage('shotgun-shell', 0.3) },
    ['physical-projectile-damage-3'] = { ammo_damage('bullet', 0.3), ammo_damage('shotgun-shell', 0.3) },
    ['physical-projectile-damage-4'] = { ammo_damage('bullet', 0.3), ammo_damage('shotgun-shell', 0.3) },
    ['physical-projectile-damage-5'] = { ammo_damage('bullet', 0.3), ammo_damage('shotgun-shell', 0.3), ammo_damage('cannon-shell', 0.9) },
    ['physical-projectile-damage-6'] = { ammo_damage('bullet', 0.3), ammo_damage('shotgun-shell', 0.3), ammo_damage('cannon-shell', 1.3) },
    ['physical-projectile-damage-7'] = { ammo_damage('bullet', 0.3), ammo_damage('shotgun-shell', 0.3), ammo_damage('cannon-shell', 1.0) },
    ['artillery-shell-range-1'] = {},
    ['artillery-shell-speed-1'] = {},
}

for name, technology in pairs(data.raw.technology) do
    if upgrade_modifiers[name] then
        technology.effects = upgrade_modifiers[name]
    end
end
