local Challenges = require 'scripts.modules.challenges'
local Config = require 'scripts.config'
local Game = require 'scripts.modules.game'
local Gui = require 'scripts.modules.gui'
local PlayerMenu = require 'scripts.gui.player.core'
local Terrain = require 'scripts.modules.terrain'

local Public = {
    Visual = {},
    Editor = {}
}
local Visual = Public.Visual
local Editor = Public.Editor

local pages = PlayerMenu.get_pages()
local selected = {}
local proposed = {}

fsrc.subscribe({
    selected = selected,
    proposed = proposed
}, function(tbl)
    selected = tbl.selected
    proposed = tbl.proposed
end)

function Public.get_selected()
    return selected
end


-- == VISUAL ==================================================================

local visual = {
    main_button_name = Gui.uid_name('main_button_visual'),
    action_assign = Gui.uid_name('action_assign'),
    pin_button_name = Gui.uid_name('pin_button'),
    pinned_view_name = Gui.uid_name('pinned_view'),
    unpin_button_name = Gui.uid_name('unpin_button'),
    pinned_view_close_button_name = Gui.uid_name('pinned_view_close_button'),
}
local letters = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I' }
local btn_size = 90
local styles = {
    west = 'tool_button_blue',
    east = 'tool_button_red',
}

local challenge_tooltip = function(player, challenge)
    local claim_text = challenge.condition and {'bingo.challenge_claim_auto'} or {'bingo.challenge_claim_manual'}
    if player.admin then
        return {'', {'bingo.challenge_admin_tooltip', Config.force_name_map.west, Config.force_name_map.east}, {'bingo.challenge_player_tooltip', challenge.side and Config.force_name_map[challenge.side] or '---', challenge.tooltip, claim_text } }
    end
    return {'', {'bingo.challenge_player_tooltip', challenge.side and Config.force_name_map[challenge.side] or '---', challenge.tooltip, claim_text } }
end

local count_points = function()
    local points = {
        player = #selected,
        west = 0,
        east = 0,
    }
    for _, ch in pairs(selected) do
        if ch.side then
            points[ch.side] = points[ch.side] + 1
        end
    end
    points.player = points.player - points.west - points.east
    return points
end
Public.get_points = count_points

pages[#pages + 1] = {
    admin = false,
    button = {
        type = 'sprite-button',
        sprite = 'bingo',
        tooltip = 'Player challenges',
        name = visual.main_button_name,
    },
    caption = {
        type = 'label',
        caption = 'Bingo',
        style = 'bold_label',
    },
}

--- Call update after
local draw_challenge_ui = function (parent, data)
    local flow = parent.add { type = 'frame' }.add{ type = 'flow', direction = 'horizontal' }

    do --- Counter
        data.challenges_counter = {}
        local vert = flow.add { type = 'flow', direction = 'vertical' }
        Gui.add_pusher(vert, 'vertical')
        for side, button in pairs({
            player = vert.add { type = 'sprite-button', style = 'frame_button' },
            west = vert.add { type = 'sprite-button', caption = Config.force_name_map.west:sub(1, 1), style = styles.west, tooltip = Config.force_name_map.west },
            east = vert.add { type = 'sprite-button', caption = Config.force_name_map.east:sub(1, 1), style = styles.east, tooltip = Config.force_name_map.east },
        }) do
            Gui.set_style(button, { size = 32 })
            data.challenges_counter[side] = button
        end
        Gui.add_pusher(vert, 'vertical')
    end
    do --- Bingo board
        Gui.add_pusher(flow)
        local inner_flow = flow.add { type = 'flow', direction = 'vertical' }
        Gui.add_pusher(inner_flow, 'vertical')
        local tbl = flow.add { type = 'table', column_count = Challenges.get_size()+1 }
        Gui.set_style(tbl, { vertical_spacing = 8 })
        Gui.add_pusher(inner_flow, 'vertical')
        Gui.add_pusher(flow)
        data.challenges_table = tbl
    end
    do -- Pin Button
        Gui.add_pusher(flow)
        local pin_button = flow.add {
            type = 'sprite-button',
            sprite = 'utility/track_button',
            name = visual.pin_button_name,
            style = 'tool_button'
        }
        Gui.set_style(pin_button, { size = 32, padding = 0 })
        pin_button.tooltip = 'Pin challenges to the screen'
        pin_button.style.font_color = { 255, 255, 255 }
        pin_button.style.hovered_font_color = { 255, 255, 0 }
        pin_button.style.clicked_font_color = { 255, 0, 0 }
    end
end




local update_single_challenge = function (player, index, parent, challenge)
    local button = parent.add {
        type = 'button',
        -- caption = challenge_tooltip(player, challenge),
        style = challenge.side and styles[challenge.side] or 'frame_button',
        tags = { [Gui.tag] = visual.action_assign, index = index },
        tooltip = challenge_tooltip(player, challenge),
    }
    Gui.set_style(button, { size = btn_size, padding = 0 })

    local h_flow = button.add { type = 'flow', direction = 'horizontal' }
    Gui.set_style(h_flow, {
        vertical_align = 'center',
        horizontally_stretchable = true,
        vertically_stretchable = true,
        size = btn_size - 6,
        margin = -2
    })

    local v_flow = h_flow.add { type = 'flow', direction = 'vertical' }
    Gui.add_pusher(v_flow, 'vertical')
    Gui.set_style(v_flow, {
        horizontal_align = 'center',
        vertically_stretchable = true,
        horizontally_stretchable = true,
        size = btn_size - 6,
        margin = -2
    })

    if not (challenge.condition or challenge.side) then
        local asterisk = h_flow.add { type = 'label', caption = '[font=var][color=red]*[/color][/font]' }
        Gui.set_style(asterisk, { left_margin = -8, top_margin = 38 })
    end

    local label = v_flow.add { type = 'label', caption = challenge.caption, style = 'caption_label' }
    Gui.set_style(label, {
        single_line = false,
        font = 'var',
        font_color = { 255, 255, 255 },
        maximal_width = btn_size - 10,
        horizontal_align = 'center',
        padding = 0,
        margin = 0
    })
    Gui.add_pusher(v_flow, 'vertical')
    local icon = v_flow.add { type = 'sprite-button', style = 'transparent_slot' }
    if challenge.icon then
        icon.sprite = challenge.icon.sprite
        icon.number = challenge.icon.number
    end
end

local update_challenge_ui = function (player, parent, challenges_counter)
    Gui.clear(parent)

    for x = 0, parent.column_count - 1 do
        for y = 0, parent.column_count - 1 do
            if x == 0 and y == 0 then
                --- 1st empty slot
                parent.add { type = 'empty-widget' }
            elseif x == 0 then
                --- Header row
                local flow = parent.add { type = 'flow', direction = 'vertical' }
                Gui.set_style(flow, { horizontal_align = 'center', width = btn_size+4 })
                flow.add { type = 'label', caption = y, style = 'caption_label' }
            elseif y == 0 then
                --- Header column
                local flow = parent.add { type = 'flow', direction = 'horizontal' }
                Gui.set_style(flow, { vertical_align = 'center', height = btn_size+4, right_padding = 4 })
                flow.add { type = 'label', caption = letters[x], style = 'caption_label' }
            else
                --- Challenge button
                local index = (x - 1) * (parent.column_count - 1) + y
                local ch = selected[index]
                update_single_challenge(player, index, parent, ch)
            end
        end
    end

    local points = count_points()
    for side, button in pairs(challenges_counter) do
        button.number = points[side]
    end
end


--- Create a frame that is pinned to the left side of the screen
---@param player LuaPlayer
---@param params { caption: string, close_button_name: string, unpin_button_name: string, searchbox_name: string }
local function draw_pinned_frame(player, params)
    local info = {}

    local parent = player.gui.left
    local frame = parent.add { 
        type = 'frame',
        name = visual.pinned_view_name,
        direction = 'vertical',
        style = 'frame'
    }
    Gui.set_style(frame, Gui.styles.closable_frame)
    frame.style.padding = 3
    Gui.set_data(frame, info)
    info.frame = frame


    local title_flow = frame.add{ type = 'flow', direction = 'horizontal' }
    Gui.set_style(title_flow, { horizontal_spacing = 8, vertical_align = 'center', bottom_padding = 4 })

    info.label = title_flow.add { type = 'label', caption = params.caption, style = 'frame_title' }

    Gui.add_pusher(title_flow)


    local searchbox = title_flow.add({
        type = 'textfield',
        name = params.searchbox_name or Gui.closable_frame_searchbox_name,
        style = 'search_popup_textfield',
    })
    info.searchbox = searchbox
    info.searchbox.visible = false
    Gui.set_data(info.searchbox, info)


    info.unpin_button = title_flow.add { 
        type = 'sprite-button',
        name = params.unpin_button_name,
        sprite = 'utility/track_button_white',
        clicked_sprite = 'utility/track_button',
        style = 'frame_action_button',
        tooltip = 'Unpin this window'
    }
    Gui.set_data(info.unpin_button, info)

    info.close_button = title_flow.add { 
        type = 'sprite-button',
        name = params.close_button_name,
        sprite = 'utility/close',
        clicked_sprite = 'utility/close_black',
        style = 'frame_action_button',
        tooltip = 'Close this window'
    }
    Gui.set_data(info.close_button, info)
    return frame
end

local function draw_challenge_table_pinned(parent, data)
    local tbl = parent.add { type = 'table', column_count = Challenges.get_size() }
    Gui.set_style(tbl, { vertical_spacing = 0, horizontal_spacing = 0 })
    data.challenges_table = tbl
end

local function update_challenge_table_pinned(player, tbl, challenges_counter)
    Gui.clear(tbl)

    for x = 0, tbl.column_count - 1 do 
        for y = 0, tbl.column_count - 1 do
            local index = x * tbl.column_count + y + 1
            local challenge = selected[index]
            update_single_challenge(player, index, tbl, challenge)
        end
    end
end


local draw_pinned = function(player)
    local frame
    local result, error = pcall(function()
    frame = draw_pinned_frame(player, {
        caption = 'Bingo Challenges',
        close_button_name = visual.pinned_view_close_button_name,
        unpin_button_name = visual.unpin_button_name,
        searchbox_name = Gui.closable_frame_searchbox_name
    })
    end)
    if not result then
        game.print("Error drawing pinned challenges: " .. error)
        return
    end
    local data = Gui.get_data(frame)
    draw_challenge_table_pinned(frame, data)
    update_challenge_table_pinned(player, data.challenges_table, data.challenges_counter)
end


local function destroy_pinned(player)
    local view = player.gui.left[visual.pinned_view_name]
    if view and view.valid then
        Gui.destroy(view)
    end
end

Visual.draw = function(player)
    local data = PlayerMenu.get_right_data(player)
    local parent = data.canvas
    destroy_pinned(player)
    draw_challenge_ui(parent, data)
    update_challenge_ui(player, data.challenges_table, data.challenges_counter)
end


Visual.update = function(player)
    local frame = PlayerMenu.try_get_main_frame(player)
    local data = frame and Gui.get_data(frame)
    if (data and data.challenges_table and data.challenges_table.valid) then
        update_challenge_ui(player, data.challenges_table, data.challenges_counter)
    end

    local pinned = player.gui.left[visual.pinned_view_name]
    if (pinned and pinned.valid) then
        data = Gui.get_data(pinned)
        update_challenge_table_pinned(
            player, data.challenges_table, data.challenges_counter
        )
    end

end

Visual.update_all = function()
    for _, player in pairs(game.players) do
        Visual.update(player)
    end
end

Visual.print_challenge = function(challenge, side)
    local result = (challenge.side == side)
    game.print({ 'bingo.challenge_'..(result and 'achieved' or 'failed'),
        table.concat(Config.color[side], ','),
        Config.force_name_map[side],
        challenge.caption,
        challenge.tooltip,
    }, {
        sound_path = result and 'utility/achievement_unlocked' or 'utility/new_objective'
    })
end


Gui.on_click(PlayerMenu.config.main_button_name, function(event)
    local player = event.player
    PlayerMenu.toggle_main_button(player)
    if player.gui.screen[PlayerMenu.config.main_frame_name] then
        Visual.draw(player)
    end
end)

fsrc.add(prototypes.custom_input.open_player_menu, function(event)
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    PlayerMenu.toggle_main_button(player)
    if player.gui.screen[PlayerMenu.config.main_frame_name] then
        Visual.draw(player)
    end
end)

-- == VISUAL - EVENTS =========================================================

Gui.on_click(visual.pin_button_name, function(event)
    PlayerMenu.clear_right_data(event.player)
    PlayerMenu.toggle_main_button(event.player)
    draw_pinned(event.player)
end)

Gui.on_click(visual.unpin_button_name, function(event)
    local player = event.player
    PlayerMenu.toggle_main_button(event.player)
    local result, error = pcall(function()
    PlayerMenu.clear_right_data(event.player)
    Visual.draw(player)

end)
    if not result then
        game.print("Error unpinning challenges: " .. error)
    end
end)

Gui.on_click(visual.pinned_view_close_button_name, function(event)
    destroy_pinned(event.player)
end)

Gui.on_click(visual.main_button_name, function(event)
    PlayerMenu.toggle_left_button(event.player, visual.main_button_name)
    PlayerMenu.clear_right_data(event.player)
    if event.element.toggled then
        Visual.draw(event.player)
    end
end)

Gui.on_click(visual.action_assign, function(event)
    local player = event.player
    local side = player.force.name

    if (side == 'player') and (not player.admin) then
        return
    end

    local element = event.element
    local index = element.tags.index

    if side == 'player' or player.admin then
        --- Case: Admin is handling the assignment
        if event.button == defines.mouse_button_type.left then
            side = 'west'
        elseif event.button == defines.mouse_button_type.right then
            side = 'east'
        end

        if side and (side == selected[index].side) then
            selected[index].side = nil
        else
            selected[index].side = side
        end
    else
        --- Case: Player is self-assigning
        if not Game.is_playing() then
            player.print({'bingo.game_paused'})
            return
        end
        if side then
            if selected[index].side == nil then
                selected[index].side = side
            elseif selected[index].side == side then
                selected[index].side = nil
            end
        end
    end

    Visual.print_challenge(selected[index], side)
    Visual.update_all()
end)

-- == EDITOR ==================================================================

local editor = {
    main_button_name = Gui.uid_name('main_button_editor'),
    action_get_random = Gui.uid_name('get_random'),
    action_confirm_new_random = Gui.uid_name('clear_random'),
    action_clear_new_random = Gui.uid_name('new_random'),
    action_map_reroll = Gui.uid_name('map_reroll'),
    action_map_reset = Gui.uid_name('map_reset'),
    action_game_start = Gui.uid_name('game_start'),
    action_game_end = Gui.uid_name('game_end'),
}

pages[#pages + 1] = {
    admin = true,
    button = {
        type = 'sprite-button',
        sprite = 'game',
        tooltip = 'Game manager',
        name = editor.main_button_name,
    },
    caption = {
        type = 'label',
        caption = 'Game',
        style = 'bold_label',
    },
}

local function to_strings(challenges, filter)
    local result = {}
    for _, ch in pairs(challenges) do
        if (string.find(ch.caption:lower(), filter) or string.find(ch.tooltip:lower(), filter)) then
            table.insert(result, ch.caption)
        end
    end
    table.sort(result)
    return result
end

Editor.draw = function(player)
    local data = PlayerMenu.get_right_data(player)
    local frame = data.canvas

    --- Map settings
    local box_1 = frame.add { type = 'frame', caption = 'Game settings', style = 'bordered_frame' }
    Gui.set_style(box_1, { left_margin = 12, right_margin = 12, top_margin = 12 })

    --- Game settings
    local flow_1 = box_1.add { type = 'flow', direction = 'horizontal' }
    Gui.add_pusher(flow_1)
    local inner_1 = flow_1.add { type = 'frame', direction = 'horizontal', style = 'quick_bar_inner_panel' }
    local table_1 = inner_1.add { type = 'table', column_count = 4, style = 'filter_slot_table' }
    Gui.add_pusher(flow_1)

    table_1.add { type = 'sprite-button', sprite = 'undo', name = editor.action_map_reset, style = 'slot_button', tooltip = { 'bingo.undo' } }
    table_1.add { type = 'sprite-button', sprite = 'roll', name = editor.action_map_reroll, style = 'slot_button', tooltip = { 'bingo.roll' } }
    table_1.add { type = 'sprite-button', sprite = 'stop', name = editor.action_game_end, style = 'slot_button', tooltip = { 'bingo.stop' } }
    table_1.add { type = 'sprite-button', sprite = 'start', name = editor.action_game_start, style = 'slot_button', tooltip = { 'bingo.start' } }

    --- Bingo settings
    local box_2 = frame.add { type = 'frame', caption = 'Bingo settings', style = 'bordered_frame' }
    Gui.set_style(box_2, { left_margin = 12, right_margin = 12 })

    local v_flow = box_2.add { type = 'flow', direction = 'vertical' }

    local h_flow = v_flow.add { type = 'flow', direction = 'horizontal' }
    local ch_table = h_flow.add { type = 'table', column_count = 5 }

    Gui.add_pusher(ch_table)
    local list_box = ch_table.add{ type = 'frame', style = 'deep_frame_in_shallow_frame' }.add { type = 'list-box', items = {}, vertical_scroll_policy = 'auto-and-reserve-space'}
    Gui.set_style(list_box, { height = 360, width = 240 })
    data.editor_left = list_box

    local b_flow = ch_table.add { type = 'flow', direction = 'horizontal' }
    Gui.add_pusher(b_flow)
    local reroll = b_flow.add{ type = 'sprite-button', name = editor.action_get_random, sprite = 'utility/refresh', tooltip = 'Reroll random challenges', style = 'tool_button' }
    Gui.set_style(reroll, { size = 40, padding = 2, right_margin = 8 })
    Gui.add_pusher(b_flow)

    list_box = ch_table.add{ type = 'frame', style = 'deep_frame_in_shallow_frame' }.add { type = 'list-box', items = {}, vertical_scroll_policy = 'auto-and-reserve-space' }
    Gui.set_style(list_box, { height = 360, width = 240 })
    Gui.add_pusher(ch_table)
    data.editor_right = list_box

    local footer = v_flow.add { type = 'flow', direction = 'horizontal' }
    Gui.add_pusher(footer)
    footer.add { type = 'button', name = editor.action_clear_new_random, style = 'red_back_button', caption = 'Cancel', tooltip = 'Reset to current list' }
    footer.add { type = 'button', name = editor.action_confirm_new_random, style = 'confirm_button_without_tooltip', caption = 'Confirm', tooltip = 'This action will erase all the bingo progression' }

    Editor.update(player)
end

Editor.update = function(player, with_random)
    local frame = PlayerMenu.get_main_frame(player)
    local data = frame and Gui.get_data(frame)
    if not (data and data.editor_left and data.editor_left) then
        return
    end

    local pattern = data.searchbox.text or ''
    pattern = pattern:lower()

    if #proposed == 0 or with_random then
        table.add_all(proposed, selected)
    end
    if with_random then
        table.clear_table(proposed)
        table.add_all(proposed, Challenges.select_random_challenges())
    end

    data.editor_left.items = to_strings(Challenges.get_challenges(), pattern)
    data.editor_right.items = to_strings(proposed, pattern)
end

Editor.update_all = function()
    for _, player in pairs(game.players) do
        Editor.update(player)
    end
end

-- == EDITOR - EVENTS =========================================================

Gui.on_click(editor.main_button_name, function(event)
    PlayerMenu.toggle_left_button(event.player, editor.main_button_name)
    PlayerMenu.clear_right_data(event.player)
    if event.element.toggled then
        Editor.draw(event.player)
    end
end)

Gui.on_click(editor.action_map_reroll, function()
    Terrain.set_random_seed()
    fsrc.raise_event(defines.events.on_map_reset, { override = true })
end)

Gui.on_click(editor.action_map_reset, function()
    Terrain.set_current_seed()
    fsrc.raise_event(defines.events.on_map_reset, { override = true })
end)

Gui.on_click(editor.action_game_start, function(event)
    if Game.state() == Config.game_state.preparing then
        Game.transition()
        game.print('Match is starting! Good luck, have fun!', { color = { 0, 255, 0 } })
    else
        event.player.print('Cannot start the match: wrong game stage', { color = { 255, 255, 0 } })
    end
end)

Gui.on_click(editor.action_game_end, function(event)
    if Game.state() ~= Config.game_state.playing then
        return event.player.print('Cannot end the match: game has not started yet', { color = { 255, 255, 0 } })
    end

    local points = count_points()
    if points.west == points.east then
        return event.player.print('Cannot end the match: teams on even points', { color = { 255, 255, 0 } })
    else
        Game.transition()
        return event.player.print('Match has ended!', { color = { 0, 255, 0 } })
    end
end)

Gui.on_click(editor.action_get_random, function(event)
    if Game.is_playing() then
        return
    end
    
    Editor.update(event.player, true)
end)

Gui.on_click(editor.action_clear_new_random, function(event)
    if Game.is_playing() then
        return
    end

    table.clear_table(proposed)
    table.add_all(proposed, selected)

    Editor.update(event.player)
end)

Gui.on_click(editor.action_confirm_new_random, function()
    if Game.is_playing() then
        return
    end

    table.clear_table(selected)
    table.add_all(selected, proposed)
    table.clear_table(proposed)

    Visual.update_all()
    Editor.update_all()

    fsrc.raise_event(defines.events.on_challenges_changed, {})
end)

PlayerMenu.on_filter_changed(editor.main_button_name, function(event)
    Editor.update(event.player)
end)

-- == EVENTS ==================================================================

fsrc.add(defines.events.on_map_init, function()
    table.add_all(selected, Challenges.select_random_challenges())
end)

fsrc.add(defines.events.on_map_reset, function()
    table.clear_table(selected)
end)

-- ============================================================================

return Public