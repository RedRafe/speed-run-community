local Config = require 'scripts.config'

local Force = {}

local function generate_force_table(side)
    return {
        threat = -1e9,
        name = string.capital_letter(side),
        cargo_landing_pad = false,
        critical_entities = {},
    }
end

local forces = {
    north = generate_force_table('north'),
    south = generate_force_table('south'),
}
local critical_entities_map = {}

fsrc.subscribe({
    forces = forces,
    critical_entities_map = critical_entities_map
}, function(tbl)
    forces = tbl.forces
    critical_entities_map = critical_entities_map
end)

Force.north = function()
    return forces.north
end

Force.south = function()
    return forces.south
end

---@param force string|LuaForce
Force.get = function(force)
    local side = (type(force) == 'string') and force or force.name
    return forces[side]
end

---@param entity LuaEntity
---@return boolean success|error
Force.register_critical_entity = function(entity)
    if not (entity and entity.valid and entity.unit_number) then
        return false
    end

    local force = forces[entity.force.name]
    if not force then
        return false
    end

    force.critical_entities[entity.unit_number] = true
    critical_entities_map[entity.unit_number] = entity.force.name
    fsrc.register_on_object_destroyed(entity)
    return true
end

fsrc.on_init(function()
    game.surfaces.nauvis.peaceful_mode = true

    local player = game.forces.player
    player.set_spawn_position(Config.spawn_point.player, 'nauvis')
    player.share_chart = true

    local north = game.forces.north
    north.set_spawn_position(Config.spawn_point.north, 'nauvis')
    north.set_cease_fire('player', true)
    north.set_friend('player', true)
    north.share_chart = true

    local south = game.forces.south
    south.set_spawn_position(Config.spawn_point.south, 'nauvis')
    south.set_cease_fire('player', true)
    south.set_friend('player', true)
    south.share_chart = true

    --north.set_friend('south', true)
end)

fsrc.add(defines.events.on_map_init, function()
    forces.north = generate_force_table('north')
    forces.south = generate_force_table('south')
end)

fsrc.add(defines.events.on_map_reset, function()
    for _, f in pairs(game.forces) do
        f.reset()
    end

    for _, player in pairs(game.players) do
        player.force = 'player'
    end
end)

local chart_all_token = fsrc.register(function()
    for _, force in pairs(game.forces) do
        force.chart_all('nauvis')
    end
end)

fsrc.add(defines.events.on_player_changed_force, function(event)
    local player = event.player_index and game.get_player(event.player_index)
    if not (player and player.valid) then
        return
    end

    if player.force.name == 'player' then
        return
    end

    fsrc.set_timeout_in_ticks(300, chart_all_token)
end)

local radius = 32 * 2.5
fsrc.add(300, function()
    local surface = game.surfaces.nauvis
    for _, player in pairs(game.connected_players) do
        local position = player.physical_position
        local area = {
            left_top     = { x = position.x - radius, y = position.y - radius },
            right_bottom = { x = position.x + radius, y = position.y + radius }
        }
        for _, force in pairs(game.forces) do
            force.chart(surface, area)
        end
    end
end, { on_nth_tick = true })

return Force
