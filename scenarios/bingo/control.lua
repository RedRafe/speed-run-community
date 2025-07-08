require '__speed-run-community__.utils.lib.lib'

fsrc.on_init(function()
    for _, side in pairs({ 'north', 'south' }) do
        if not game.forces[side] then
            game.create_force(side)
        end
    end
end)

--- Modules
require '__speed-run-community__.scripts.modules.blueprints'
require '__speed-run-community__.scripts.modules.challenges'
require '__speed-run-community__.scripts.modules.chat'
require '__speed-run-community__.scripts.modules.commands'
require '__speed-run-community__.scripts.modules.corpse-tag'
require '__speed-run-community__.scripts.modules.debug'
require '__speed-run-community__.scripts.modules.enemy'
require '__speed-run-community__.scripts.modules.floaty-chat'
require '__speed-run-community__.scripts.modules.force'
require '__speed-run-community__.scripts.modules.freeplay'
require '__speed-run-community__.scripts.modules.game'
require '__speed-run-community__.scripts.modules.inventory'
require '__speed-run-community__.scripts.modules.permission'
require '__speed-run-community__.scripts.modules.statistics'
require '__speed-run-community__.scripts.modules.teleport'
require '__speed-run-community__.scripts.modules.terrain'

--- GUIs
require '__speed-run-community__.scripts.gui.player.main'
require '__speed-run-community__.scripts.gui.player.challenges'
require '__speed-run-community__.scripts.gui.player.statistics'
require '__speed-run-community__.scripts.gui.player.teams'
require '__speed-run-community__.scripts.gui.clock.main'

-- Post Modules
require '__speed-run-community__.scripts.modules.detection'