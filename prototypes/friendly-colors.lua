local Color = require 'utils.color'

---@param source string, the type to apply the color to
---@param color string|table
---@param options?
---@param options.mode string, the mode to be applied the color to: 'enemy_map_color'|'friendly_map_color'
---@param options.name string, the only entity to apply the color to
local function friendly_color(source, color, options)
    options = options or {}
    local mode = options.mode or 'friendly_map_color'

    local _color = Color.parse(color)
    local _source = data.raw[source]

    for _, entity in pairs(options.name and { _source[options.name] } or _source) do
        entity[mode] = _color
        entity.map_color = _color
    end
end

local PALETTE = {
    default                       = '#298fc3',

    -- Friendly entities          - friendly_map_color
    ['accumulator']               = '#7a7a7a',
    ['ammo-turret']               = '#caa718',
    ['assembling-machine']        = '#3fa4d6',
    ['beacon']                    = '#008192',
    ['boiler']                    = '#00008c',
    ['burner-generator']          = '#21a057',
    ['centrifuge']                = '#88e588',
    ['chemical-plant']            = '#4bc04b',
    ['container']                 = '#dcbc5e',
    ['curved-rail']               = '#9fcacc',
    ['electric-energy-interface'] = '#21a057',
    ['electric-pole']             = '#a6a6a6',
    ['electric-turret']           = '#d82d2d',
    ['fluid-turret']              = '#ea7519',
    ['furnace']                   = '#e2b878',
    ['gate']                      = '#7f7f7f',
    ['generator']                 = '#21a057',
    ['heat-pipe']                 = '#c12828',
    ['inserter']                  = '#36c9ff',
    ['lab']                       = '#ff90bd',
    ['logistic-container']        = '#dcbc5e',
    ['mining-drill']              = '#298fc3',
    ['oil-refinery']              = '#328032',
    ['pipe-to-ground']            = '#5a269e',
    ['pipe']                      = '#5a269e',
    ['pump']                      = '#340d66',
    ['radar']                     = '#7ce8c0',
    ['reactor']                   = '#40ff40',
    ['roboport']                  = '#d3cf88',
    ['rocket-silo']               = '#2b4544',
    ['simple-entity']             = '#997950',
    ['solar-panel']               = '#1f2124',
    ['storage-tank']              = '#4c0082',
    ['straight-rail']             = '#9fcacc',
    ['tree']                      = '#006600',
    ['wall']                      = '#ccd8cc',

    -- Enemy entities             - enemy_map_color
    ['unit-spawner']              = '#ff1919',
    ['turret']                    = '#871928',

    -- Colors
    ['yellow']                    = '#fabb00',
    ['red']                       = '#fa450e',
    ['blue']                      = '#36c9ff',
    ['peas']                      = '#77d577',
    ['green']                     = '#12ff9c',
    ['pink']                      = '#f712ff',
    ['white']                     = '#e8e8e8',
    ['purple']                    = '#4c0082',
    ['aqua']                      = '#7fffd4',
    ['lavender']                  = '#9470db',
    ['teal']                      = '#008080',
    ['crimson']                   = '#dc143c',
}

--- Miscellaneous
for _, source in pairs({
    'burner-generator',
    'container',
    'electric-energy-interface',
    'electric-pole',
    'generator',
    'heat-pipe',
    'logistic-container',
    'pipe-to-ground',
    'pipe',
    'pump',
    'radar',
    'reactor',
    'roboport',
    'storage-tank',
}) do friendly_color(source, PALETTE[source]) end

--- Enemies
friendly_color('unit-spawner', PALETTE['unit-spawner'], { mode = 'enemy_map_color' })
friendly_color('turret',       PALETTE['turret'],       { mode = 'enemy_map_color' })

--- Scraps
friendly_color('container', PALETTE['default'], 'crash-site-spaceship-wreck-big-1')
friendly_color('container', PALETTE['default'], 'crash-site-spaceship-wreck-big-2')
friendly_color('container', PALETTE['default'], 'crash-site-spaceship-wreck-medium-1')
friendly_color('container', PALETTE['default'], 'crash-site-spaceship-wreck-medium-2')
friendly_color('container', PALETTE['default'], 'crash-site-spaceship-wreck-medium-3')

--- Yellow tier
friendly_color('transport-belt',   PALETTE['yellow'], { name = 'transport-belt'   })
friendly_color('underground-belt', PALETTE['yellow'], { name = 'underground-belt' })
friendly_color('splitter',         PALETTE['yellow'], { name = 'splitter'         })
friendly_color('loader',           PALETTE['yellow'], { name = 'loader'           })

--- Red tier
friendly_color('transport-belt',   PALETTE['red'], { name = 'fast-transport-belt'   })
friendly_color('underground-belt', PALETTE['red'], { name = 'fast-underground-belt' })
friendly_color('splitter',         PALETTE['red'], { name = 'fast-splitter'         })
friendly_color('loader',           PALETTE['red'], { name = 'fast-loader'           })

--- Blue tier
friendly_color('transport-belt',   PALETTE['blue'], { name = 'express-transport-belt'   })
friendly_color('underground-belt', PALETTE['blue'], { name = 'express-underground-belt' })
friendly_color('splitter',         PALETTE['blue'], { name = 'express-splitter'         })
friendly_color('loader',           PALETTE['blue'], { name = 'express-loader'           })

--- Green tier
friendly_color('transport-belt',   PALETTE['peas'], { name = 'turbo-transport-belt'   })
friendly_color('underground-belt', PALETTE['peas'], { name = 'turbo-underground-belt' })
friendly_color('splitter',         PALETTE['peas'], { name = 'turbo-splitter'         })
friendly_color('loader',           PALETTE['peas'], { name = 'turbo-loader'           })
