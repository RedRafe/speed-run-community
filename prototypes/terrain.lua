require 'prototypes.noise'

local f = string.format
local starting_radius = 39
--local NE = data.raw['noise-expression']
local NF = data.raw['noise-function']
local mgs = data.raw.planet.nauvis.map_gen_settings

data:extend({
    {
        type = 'noise-expression',
        name = 'moat',
        parameters = { 'x', 'y' },
        expression = f('(abs(x) < %d) + ((y*y) + (x*x) < 4*(%d^2)) - 2*((y*y + x*x) < (0.5 * %d^2))', starting_radius, starting_radius, starting_radius),
    },
    {
        type = 'noise-function',
        name = 'is_roughly_biter_area',
        parameters = { 'x', 'y' },
        expression = 'abs(y) >= 512 + abs(x) * 0.45',
    },
    {
        type = 'noise-expression',
        name = 'starting_concrete',
        parameters = { 'distance', 'map_seed_small' },
        expression = 'if(moat | (distance > 135), -100, 100 * ((distance < 120) + decorative_mix_noise{seed = map_seed_small, input_scale = 1/7}))',
    },
    {
        type = 'noise-function',
        name = 'scattered_entity',
        parameters = { 'scale', 'reseed' },
        expression = '-1.5 + rpi(0.2) + decorative_mix_noise{seed = 5000 + reseed, input_scale = scale} - min(0, decorative_knockout)'
    },
})

--- Water
--NF['water_base'].expression = 'if((max_elevation >= elevation) & (is_roughly_biter_area{ x = x, y = y } != 1), influence * min(max_elevation - elevation, 1), -inf)'

--- Resources
NF['resource_autoplace_all_patches'].local_expressions.starting_patches = f('if(x*x + y*y > %d^2, %s, -inf)', starting_radius, NF['resource_autoplace_all_patches'].local_expressions.starting_patches)
NF['resource_autoplace_all_patches'].local_expressions.regular_patches = f('if(x*x + y*y > %d^2, %s, -inf)', starting_radius, NF['resource_autoplace_all_patches'].local_expressions.regular_patches)
for _, ore in pairs({ 'iron-ore', 'copper-ore', 'coal', 'stone' }) do
    data.raw.resource[ore].autoplace.richness_expression = data.raw.resource[ore].autoplace.richness_expression .. ' * ((distance < 224) * 9 + 1)'
end

--- Rocks
--NE['rock_noise'].expression = f('clamp(-inf, inf, (distance < 224) * 0.25 + %s) * (x*x + y*y > %d^2)', NE['rock_noise'].expression, starting_radius)

--- Trees
--[[
local remove_trees = function(expr)
    return f('if(is_roughly_biter_area{ x = x, y = y}, 0.05, 1) * (x*x + y*y > (%d)^2) * %s', starting_radius, expr)
end
for _, tree in pairs {
    'tree_01',
    'tree_02',
    'tree_02_red',
    'tree_03',
    'tree_04',
    'tree_05',
    'tree_06',
    'tree_06_brown',
    'tree_07',
    'tree_08',
    'tree_08_brown',
    'tree_08_red',
    'tree_09',
    'tree_09_brown',
    'tree_09_red',
    'tree_02',
} do
    NE[tree].expression = remove_trees(NE[tree].expression)
end
NE['tree_dead_desert'].local_expressions.tree_noise = remove_trees(NE['tree_dead_desert'].local_expressions.tree_noise)
NE['tree_dead_desert'].local_expressions.desert_noise = remove_trees(NE['tree_dead_desert'].local_expressions.desert_noise)
]]

--- Concrete
--[[
data.raw.tile['refined-concrete'].autoplace = {
    default_enabled = true,
    probability_expression = 'starting_concrete',
    tile_restriction = { 'water' },
}
mgs.autoplace_settings.tile.settings['refined-concrete'] = {}
]]

-- Moat
local moat = table.deepcopy(data.raw.tile.deepwater)

moat.name = 'moat'
moat.collision_mask = {
    layers = {
        doodad = true,
        item = true,
        player = true,
        rail = true,
        resource = true,
        water_tile = true,
    },
}
moat.autoplace = { probability_expression = 'moat * inf' }
moat.default_cover_tile = nil

data:extend({ moat })

mgs.autoplace_settings.tile.settings['moat'] = {}

--- Enemies
--[[
NE['enemy_base_probability'].expression = 'is_roughly_biter_area{ x = x, y = y } * (decorative_mix_noise{seed = map_seed_small, input_scale = 1/7} - 0.3)'

for i, worm in pairs({
    'small-worm-turret',
    'medium-worm-turret',
    'big-worm-turret',
    'behemoth-worm-turret',
}) do
    local base = table.deepcopy(data.raw.turret[worm])
    base.name = 'scattered-' .. base.name
    base.autoplace = {
        default_enabled = true,
        force = 'enemy',
        probability_expression = f('(distance > 512 * %d) * scattered_entity{ scale = 10 - 2 * %d, reseed = 13 * %d }', i, i, i),
        placement_density = (i) ^ 2
    }
    data.extend({ base })

    mgs.autoplace_settings.entity.settings[base.name] = {}
end
]]

--- Scraps
--[[
local function loot_table()
    local items = {
        ['transport-belt'] = 20,
        ['underground-belt'] = 6,
        ['splitter'] = 4,
        ['inserter'] = 10,
        ['pipe'] = 50,
        ['pipe-to-ground'] = 8,
        ['stone-brick'] = 30,
        ['iron-plate'] = 60,
        ['copper-plate'] = 60,
        ['steel-plate'] = 12,
        ['iron-gear-wheel'] = 30,
        ['copper-cable'] = 80,
        ['electronic-circuit'] = 24,
    }

    local results_per_entity = 2
    local results = {}
    for name, count in pairs(items) do
        results[#results + 1] = {
            name = name,
            type = 'item',
            amount_max = count,
            amount_min = math.ceil(count / (1 + results_per_entity)),
            probability = results_per_entity / table.size(items),
        }
    end

    return results
end

for i, scrap in pairs({
    'crash-site-spaceship-wreck-big-1',
    'crash-site-spaceship-wreck-big-2',
    'crash-site-spaceship-wreck-medium-1',
    'crash-site-spaceship-wreck-medium-2',
    'crash-site-spaceship-wreck-medium-3',
}) do
    local container = data.raw.container[scrap]
    container.autoplace = {
        default_enabled = true,
        force = 'neutral',
        probability_expression = f('(distance > 512) * scattered_entity{ scale = 8, reseed = 17 * %d }', i),
        placement_density = 2
    }
    container.minable.results = loot_table()

    mgs.autoplace_settings.entity.settings[scrap] = {}
end
]]

-- Mixed ores
--[[
local expr = f('(-0.75 - nauvis_bridges + multioctave_noise{x = x, y = abs(y)-50, seed0 = map_seed, seed1 = 137, octaves = 4, persistence = 1, input_scale = 1/(%d^2), output_scale = 1})', 8)
local bound = {
    lower = 0,
    upper = 0,
}

for i, ore in pairs({
    { name = 'iron-ore',   range = 2/14 },
    { name = 'copper-ore', range = 1/14 },
    { name = 'iron-ore',   range = 2/14 },
    { name = 'stone',      range = 3/14 },
    { name = 'copper-ore', range = 1/14 },
    { name = 'iron-ore',   range = 2/14 },
    { name = 'copper-ore', range = 1/14 },
    { name = 'iron-ore',   range = 2/14 },
    { name = 'coal',       range = 4/14 },
    { name = 'iron-ore',   range = 2/14 },
    { name = 'copper-ore', range = 1/14 },
    { name = 'iron-ore',   range = 2/14 },
    { name = 'stone',      range = 3/14 },
    { name = 'copper-ore', range = 1/14 },
    { name = 'coal',       range = 4/14 },
}) do
    bound.upper = bound.upper + ore.range

    local base = table.deepcopy(data.raw.resource[ore.name])
    base.name = f('mixed-%d-%s', i, ore.name)
    base.localised_name = {'entity-name.'..ore.name}
    base.autoplace = {
        probability_expression = f('100 * (1 - spawn) * ((%f < ore) & (ore < %f))', bound.lower, bound.upper),
        richness_expression = 'random_penalty{ x = x, y = abs(y)-50, source = 10000, seed = map_seed, amplitude = 3000}',
        local_expressions = {
            ore = f('clamp(%s, -1, 2)', expr),
            spawn = 'moat | starting_concrete '
        }
    }

    data:extend({ base })
    mgs.autoplace_settings.entity.settings[base.name] = {}
    bound.lower = bound.upper
end
]]