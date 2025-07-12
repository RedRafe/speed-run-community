local Actions = require 'scripts.modules.command-actions'
local shared = require('utils.shared')

local function validate_player(player)
    if not player then
        return false
    end
    if not player.valid then
        return false
    end
    if not player.character then
        return false
    end
    if not player.connected then
        return false
    end
    if not game.get_player(player.index) then
        return false
    end
    return true
end

local function do_follow(cmd)
    local player = game.player
    if not player or not validate_player(player) then
        return
    end
    if player.force.name ~= 'player' then
        player.print('You must be a spectator to use this command.', { color = {r=1,g=0,b=0} })
        return
    end

    if not cmd.parameter then
        return
    end
    local target_player = game.get_player(cmd.parameter)

    if not target_player or not validate_player(target_player) then
        return
    end

    player.centered_on = target_player.character
end

for _, command in pairs({
    {
        name = 'on-map-reset',
        help = 'Instantly rerolls a new map',
        action = Actions.instant_map_reset
    },
    {
        name = 'transition',
        help = 'Moves game state to nest stage',
        action = Actions.transition
    },
    {
        name = 'hax',
        help = 'Unlock all recipes',
        action = Actions.hax
    },
    {
        name = 'follow',
        help = 'Follows a player',
        action = do_follow
    }
}) do
    commands.add_command(command.name, command.help, function(cmd)
        shared.safe_wrap_cmd(cmd, command.action, cmd)
    end)
end