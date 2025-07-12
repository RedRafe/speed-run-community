local Module = {
    triggers = {
        on_built_turret = 'on_player_built_turret',
        on_cargo_landing_pad_created = 'on_player_built_cargo_landing_pad',
        on_enemy_created = 'on_enemy_created',
    }
}

function Module.safe_wrap_cmd(cmd, func, ...)
    local print_fn = game.print
    if cmd.player_index then
        local player = game.get_player(cmd.player_index)
        if player then
            print_fn = player.print
        end
    end
    local function error_handler(err)
        log('Error caught: ' .. err)
        print_fn('Error caught: ' .. err)
        -- Print the full stack trace to the log
        log(debug.traceback())
    end
    local call_succeeded, result = xpcall(func, error_handler, ...)
    return result
end

return Module