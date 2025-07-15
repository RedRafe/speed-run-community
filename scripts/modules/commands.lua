local Actions = require 'scripts.modules.command-actions'

for _, command in pairs({
    {
        name = 'on-map-reset',
        help = '[Admin] Instantly rerolls a new map',
        action = Actions.instant_map_reset
    },
    {
        name = 'transition',
        help = '[Admin] Moves game state to nest stage',
        action = Actions.transition
    },
    {
        name = 'hax',
        help = '[Admin] Unlock all recipes',
        action = Actions.hax
    },
    {
        name = 'spectator',
        help = 'Chat with Spectators',
        action = Actions.chat
    },
    {
        name = 'spect',
        help = 'Chat with Spectators',
        action = Actions.chat
    },
    {
        name = 'east',
        help = 'Chat with team East',
        action = Actions.chat
    },
    {
        name = 'west',
        help = 'Chat with team West',
        action = Actions.chat
    },
}) do
    commands.add_command(command.name, command.help, command.action)
end