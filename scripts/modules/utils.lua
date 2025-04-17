local Public = {}

Public.for_teams = function(callback, ...)
    local forces = game.forces
    callback(forces.north, ...)
    callback(forces.south, ...)
end

Public.for_forces = function(callback, ...)
    local forces = game.forces
    callback(forces.north, ...)
    callback(forces.south, ...)
    callback(forces.player, ...)
end

Public.for_players = function(callback, ...)
    local forces = game.forces
    for _, player in pairs(forces.north) do
        callback(player, ...)
    end
    for _, player in pairs(forces.south) do
        callback(player, ...)
    end
end

---@param force ForceID, string|number|LuaForce
---@return LuaForce
Public.get_force = function(force)
    if type(force) == 'userdata' then
        return force
    end
    return game.forces[force]
end

--- Create Flying text for the player, or for all players on that surface if no player specified
--- see docs @ https://lua-api.factorio.com/latest/classes/LuaPlayer.html#create_local_flying_text
---@param message table, { text: string, position: MapPosition, color: Color }
---@param target? LuaPlayer|LuaForce|LuaGameScript, if not provided, all players will be used
Public.create_local_flying_text = function(message, target)
    local players
    if target then
        players = (target.object_name == 'LuaPlayer') and { target } or target.connected_players
    else
        players = game.connected_players
    end

    for _, player in pairs(players) do
        player.create_local_flying_text(message)
    end
end

return Public
