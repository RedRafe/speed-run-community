local Config = require 'scripts.config'

local Public = {}

local this = {
    seed = nil
}

Public.set_current_seed = function()
    this.seed = game.surfaces.nauvis.map_gen_settings.seed
end

Public.set_random_seed = function()
    this.seed = nil
end

local function configure_forces()
    local player = game.forces.player
    player.set_spawn_position(Config.spawn_point.player, 'nauvis')

    local west = game.forces.west
    west.set_spawn_position(Config.spawn_point.west, 'nauvis')

    local east = game.forces.east
    east.set_spawn_position(Config.spawn_point.east, 'nauvis')
end

fsrc.on_init(function()
    local mgs = game.surfaces.nauvis.map_gen_settings
    mgs.starting_points = { { x = 320, y = 0 } }
    game.surfaces.nauvis.map_gen_settings = mgs
end)

fsrc.subscribe(this, function(tbl) this = tbl end)

fsrc.add(defines.events.on_map_init, function()
    --- Chart map
    local radius = 32*7
    local surface = game.surfaces.nauvis
    for _, position in pairs(Config.spawn_point) do
        surface.request_to_generate_chunks(position, 5)
    end
    surface.force_generate_chunk_requests()

    for _, f in pairs(game.forces) do
        f.chart(surface, {
            { x = -750 - radius, y = -200 },
            { x =  750 + radius, y =  200 }
        })
    end
end)

fsrc.add(defines.events.on_match_picking_phase, function()
    local surface = game.surfaces.nauvis

    --- Remove all rocks/trees of spect island
    for _, entity in pairs(surface.find_entities_filtered{
        position = { 0, 0 },
        radius = 30,
        name = 'character',
        invert = true,
    }) do
        entity.destroy()
    end
end)

fsrc.add(defines.events.on_map_reset, function()
    local surface = game.surfaces.nauvis
    local mgs = surface.map_gen_settings

    if this.seed then
        mgs.seed = this.seed
        this.seed = nil
    else
        mgs.seed = math.random(341, 4294967294)
    end
    surface.map_gen_settings = mgs

    surface.clear(true)
    surface.request_to_generate_chunks({ x = 0, y = 0 }, 8)
    surface.force_generate_chunk_requests()

    configure_forces()
end)

return Public
