local Chat = require 'scripts.modules.chat'
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

Actions.chat = function(command)
    command.destination = command.name
    if (command.name == 'spectator') or (command.name == 'spect') then
        command.destination = 'player'
    end
    Chat.process_message(command)
end

return Actions