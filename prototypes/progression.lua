---@param p_type string
---@param p_name string
local function hide_prototype(p_type, p_name)
    if data.raw[p_type] and data.raw[p_type][p_name] then
        data.raw[p_type][p_name].hidden = true
    end
end

hide_prototype('recipe', 'artillery-shell')
hide_prototype('recipe', 'artillery-turret')
hide_prototype('recipe', 'artillery-wagon')
hide_prototype('recipe', 'atomic-bomb')
hide_prototype('recipe', 'cliff-explosives')
hide_prototype('recipe', 'land-mine')

hide_prototype('technology', 'artillery-shell-range-1')
hide_prototype('technology', 'artillery-shell-speed-1')
hide_prototype('technology', 'artillery')
hide_prototype('technology', 'atomic-bomb')
hide_prototype('technology', 'cliff-explosives')
hide_prototype('technology', 'gate')
hide_prototype('technology', 'kovarex-enrichment-process')
hide_prototype('technology', 'land-mine')

local technologies = data.raw.technology

--- Walls & Gate
table.insert(technologies['stone-wall'].effects, { type = 'unlock-recipe', recipe = 'gate' })
table.remove_any(technologies['gate'].effects, { type = 'unlock-recipe', recipe = 'gate' })

--- Oil processing
technologies['oil-processing'].research_trigger = nil
technologies['oil-processing'].unit = {
    ingredients = {
        { 'automation-science-pack', 1 },
        { 'logistic-science-pack', 1 },
    },
    time = 30,
    count = 100,
}

--- Uranium
table.insert(technologies['uranium-processing'].effects, { type = 'unlock-recipe', recipe = 'kovarex-enrichment-process' })
table.remove_any(technologies['kovarex-enrichment-process'].effects,{ type = 'unlock-recipe', recipe = 'kovarex-enrichment-process' })

technologies['uranium-processing'].research_trigger = nil
technologies['uranium-processing'].unit = {
    ingredients = {
        { 'automation-science-pack', 1 },
        { 'logistic-science-pack', 1 },
        { 'chemical-science-pack', 1 },
    },
    time = 30,
    count = 200,
}

technologies['uranium-ammo'].unit.count = 150

table.insert(technologies['rocket-fuel'].effects, { type = 'unlock-recipe', recipe = 'nuclear-fuel' })
table.remove_any(technologies['kovarex-enrichment-process'].effects,{ type = 'unlock-recipe', recipe = 'nuclear-fuel' })
