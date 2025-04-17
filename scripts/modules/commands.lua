local Actions = require 'scripts.modules.command-actions'

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
    }
}) do
    commands.add_command( command.name, command.help, command.action)
end