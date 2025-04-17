local Game = require 'scripts.modules.game'

local Actions = {}

Actions.instant_map_reset = function()
    fsrc.raise_event(defines.events.on_match_finished, { override = true })
end

Actions.transition = function()
    Game.transition()
end

Actions.hax = function()
    for _, recipe in pairs(game.player.force.recipes) do
        recipe.enabled = true
    end
end

return Actions