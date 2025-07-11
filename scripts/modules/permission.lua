local Config = require 'scripts.config'
local Permission = {}

local groups = {
    admin     = Config.permission_group.admin,
    default   = Config.permission_group.default,
    north     = Config.permission_group.default,
    south     = Config.permission_group.default,
    player    = Config.permission_group.player,
    spectator = Config.permission_group.player,
    jail      = Config.permission_group.jail,

}
Permission.groups = groups

---@param group_name string, name of the group. If not existing, it will be created a new one
---@param allowed boolean
---@param action_list? InputAction[], defaults to all input actions
Permission.apply_permissions = function(group_name, allowed, action_list)
    local group = game.permissions.get_group(group_name)

    if not group then
        group = game.permissions.create_group(group_name)
    end

    for _, action_id in pairs(action_list or defines.input_action) do
        group.set_allows_action(action_id, allowed)
    end
end

---@param player_index number
---@param group_name? string, name of the group. If not provided, player group will be used
Permission.set_player_group = function(player_index, group_name)
    local player = player_index and game.get_player(player_index)
    if not (player and player.valid) then
        return
    end

    player.permission_group = game.permissions.get_group(group_name or Config.permission_group.player)
end

fsrc.on_init(function()
    game.permissions.get_group('Default').name = Config.permission_group.admin

    Permission.apply_permissions(Config.permission_group.default, true)
    Permission.apply_permissions(Config.permission_group.default, false, {
        defines.input_action.delete_permission_group,
        --defines.input_action.import_blueprint_string,
        --defines.input_action.open_blueprint_library_gui,
    })

    Permission.apply_permissions(Config.permission_group.player, false)
    Permission.apply_permissions(Config.permission_group.player, true, {
        defines.input_action.admin_action,
        defines.input_action.change_active_item_group_for_filters,
        defines.input_action.change_active_quick_bar,
        defines.input_action.change_multiplayer_config,
        defines.input_action.clear_cursor,
        defines.input_action.custom_input,
        defines.input_action.edit_permission_group,
        defines.input_action.gui_checked_state_changed,
        defines.input_action.gui_click,
        defines.input_action.gui_confirmed,
        defines.input_action.gui_elem_changed,
        defines.input_action.gui_location_changed,
        defines.input_action.gui_hover,
        defines.input_action.gui_leave,
        defines.input_action.gui_selected_tab_changed,
        defines.input_action.gui_selection_state_changed,
        defines.input_action.gui_switch_state_changed,
        defines.input_action.gui_text_changed,
        defines.input_action.gui_value_changed,
        defines.input_action.map_editor_action,
        defines.input_action.open_character_gui,
        defines.input_action.quick_bar_set_selected_page,
        defines.input_action.quick_bar_set_slot,
        defines.input_action.remote_view_surface,
        defines.input_action.set_filter,
        defines.input_action.set_player_color,
        defines.input_action.spawn_item,
        defines.input_action.start_walking,
        defines.input_action.toggle_map_editor,
        defines.input_action.toggle_show_entity_info,
        defines.input_action.write_to_console,
    })

    Permission.apply_permissions(Config.permission_group.jail, false)
    Permission.apply_permissions(Config.permission_group.jail, true, {
        defines.input_action.edit_permission_group,
        defines.input_action.write_to_console,
    })
end)

fsrc.add(defines.events.on_player_changed_force, function(event)
    local player = event.player_index and game.get_player(event.player_index)
    if not (player and player.valid) then
        return
    end

    local old = player.permission_group.name
    if old ~= Permission.groups.default and old ~= Permission.groups.player then
        return
    end

    Permission.set_player_group(player.index, Permission.groups[player.force.name])
end)

fsrc.add(defines.events.on_player_created, function(event)
    if not game.is_multiplayer() then
        return
    end

    Permission.set_player_group(event.player_index, Config.permission_group.player)
end)

fsrc.add(defines.events.on_singleplayer_init, function()
    for _, player in pairs(game.connected_players) do
        Permission.set_player_group(player.index, Config.permission_group.admin)
    end
end)

return Permission
