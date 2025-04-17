--- Buff force's main build to match rocket silo health
local cargo_landing_pad = data.raw['cargo-landing-pad']['cargo-landing-pad']
cargo_landing_pad.is_military_target = true
cargo_landing_pad.max_health = 5000

--- Buff force's main build to match rocket silo health
local character = data.raw['character']['character']
character.is_military_target = true

--- Make raw fish not deconstructable with planners/bots
local fish = data.raw.fish.fish
fish.flags = fish.flags or {}
table.insert(fish.flags, 'not-deconstructable')

--- Fire utils
local fire_flame = table.deepcopy(data.raw.fire['fire-flame'])
fire_flame.name = 'bb-fire-flame'

local fire_sticker = table.deepcopy(data.raw.sticker['fire-sticker'])
fire_sticker.name = 'bb-fire-sticker'

data:extend({ fire_flame, fire_sticker })

--- Loot chest
local loot_chest_entity = table.deepcopy(data.raw['infinity-container']['infinity-chest'])
loot_chest_entity.name = 'loot-chest'
loot_chest_entity.minable.result = 'loot-chest'
loot_chest_entity.icon = '__speed-run-community__/graphics/icons/loot-chest.png'
loot_chest_entity.gui_mode = 'none'
loot_chest_entity.picture = {
    layers = {
        {
            filename = '__speed-run-community__/graphics/loot-chest/loot-chest.png',
            priority = 'extra-high',
            width = 66,
            height = 74,
            shift = util.by_pixel(0, -2),
            scale = 0.5,
        },
        {
            filename = '__speed-run-community__/graphics/loot-chest/loot-chest-shadow.png',
            priority = 'extra-high',
            width = 112,
            height = 46,
            shift = util.by_pixel(12, 4.5),
            draw_as_shadow = true,
            scale = 0.5,
        },
    },
}

local loot_chest_item = table.deepcopy(data.raw.item['infinity-chest'])
loot_chest_item.name = 'loot-chest'
loot_chest_item.place_result = 'loot-chest'
loot_chest_item.icon = '__speed-run-community__/graphics/icons/loot-chest.png'

data:extend({ loot_chest_entity, loot_chest_item })
