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
}
local letters = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I' }
local btn_size = 90
local styles = {
    north = 'tool_button_blue',
    south = 'tool_button_red',
}

local challenge_tooltip = function(player, challenge)
    if player.admin then
        return {'', {'bingo.challenge_admin_tooltip', Config.force_name_map.north, Config.force_name_map.south}, {'bingo.challenge_player_tooltip', challenge.side and Config.force_name_map[challenge.side] or '---', challenge.tooltip } }
    end
    return {'', {'bingo.challenge_player_tooltip', challenge.side and Config.force_name_map[challenge.side] or '---', challenge.tooltip } }
end

local count_points = function()
    local points = {
        player = #selected,
        north = 0,
        south = 0,
    }
    for _, ch in pairs(selected) do
        if ch.side then
            points[ch.side] = points[ch.side] + 1
        end
    end
    points.player = points.player - points.north - points.south
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

Visual.draw = function(player)
    local data = PlayerMenu.get_right_data(player)
    local frame = data.canvas

    local flow = frame.add { type = 'frame' }.add{ type = 'flow', direction = 'horizontal' }

    do --- Counter
        data.challenges_counter = {}
        local vert = flow.add { type = 'flow', direction = 'vertical' }
        Gui.add_pusher(vert, 'vertical')
        for side, button in pairs({
            player = vert.add { type = 'sprite-button', style = 'frame_button' },
            north = vert.add { type = 'sprite-button', caption = Config.force_name_map.north:sub(1, 1), style = styles.north, tooltip = Config.force_name_map.north },
            south = vert.add { type = 'sprite-button', caption = Config.force_name_map.south:sub(1, 1), style = styles.south, tooltip = Config.force_name_map.south },
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

    Visual.update(player)
end

Visual.update = function(player)
    local frame = PlayerMenu.try_get_main_frame(player)
    local data = frame and Gui.get_data(frame)
    if not (data and data.challenges_table and data.challenges_table.valid) then
        return
    end
    local tbl = data.challenges_table
    Gui.clear(tbl)

    for x = 0, tbl.column_count - 1 do
        for y = 0, tbl.column_count - 1 do
            if x == 0 and y == 0 then
                --- 1st empty slot
                tbl.add { type = 'empty-widget' }
            elseif x == 0 then
                --- Header row
                local flow = tbl.add { type = 'flow', direction = 'vertical' }
                Gui.set_style(flow, { horizontal_align = 'center', width = btn_size+4 })
                flow.add { type = 'label', caption = y, style = 'caption_label' }
            elseif y == 0 then
                --- Header column
                local flow = tbl.add { type = 'flow', direction = 'horizontal' }
                Gui.set_style(flow, { vertical_align = 'center', height = btn_size+4, right_padding = 4 })
                flow.add { type = 'label', caption = letters[x], style = 'caption_label' }
            else
                --- Challenge button
                local index = (x - 1) * (tbl.column_count - 1) + y
                local ch = selected[index]
                local button = tbl.add {
                    type = 'button',
                    tooltip = challenge_tooltip(player, ch),
                    style = ch.side and styles[ch.side] or 'frame_button',
                    tags = { [Gui.tag] = visual.action_assign, index = index }
                }
                Gui.set_style(button, { size = btn_size, padding = 0 })

                local h_flow = button.add { type = 'flow', direction = 'horizontal' }
                Gui.set_style(h_flow, { vertical_align = 'center', horizontally_stretchable = true, vertically_stretchable = true, size = btn_size - 6, margin = -2 })

                local v_flow = h_flow.add { type = 'flow', direction = 'vertical' }
                Gui.add_pusher(v_flow, 'vertical')
                Gui.set_style(v_flow, { horizontal_align = 'center', vertically_stretchable = true, horizontally_stretchable = true, size = btn_size - 6, margin = -2 })

                local label = v_flow.add { type = 'label', caption = ch.caption, style = 'caption_label' }
                Gui.set_style(label, { single_line = false, font = 'var', font_color = { 255, 255, 255 }, maximal_width = btn_size - 10, horizontal_align = 'center', padding = 0, margin = 0 })
                Gui.add_pusher(v_flow, 'vertical')

                local icon = v_flow.add { type = 'sprite-button', style = 'transparent_slot' }
                if ch.icon then
                    icon.sprite = ch.icon.sprite
                    icon.number = ch.icon.number
                end
            end
        end
    end

    local points = count_points()
    for side, button in pairs(data.challenges_counter) do
        button.number = points[side]
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

-- == VISUAL - EVENTS =========================================================

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
            side = 'north'
        elseif event.button == defines.mouse_button_type.right then
            side = 'south'
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

    for _, button in pairs({
        table_1.add { type = 'sprite-button', sprite = 'undo', name = editor.action_map_reset, style = 'slot_button', tooltip = { 'bingo.undo' } },
        table_1.add { type = 'sprite-button', sprite = 'roll', name = editor.action_map_reroll, style = 'slot_button', tooltip = { 'bingo.roll' } },
        table_1.add { type = 'sprite-button', sprite = 'stop', name = editor.action_game_end, style = 'slot_button', tooltip = { 'bingo.stop' } },
        table_1.add { type = 'sprite-button', sprite = 'start', name = editor.action_game_start, style = 'slot_button', tooltip = { 'bingo.start' } },
    }) do
        --Gui.set_style(button, { width = 120 })
    end

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

    local list_box = ch_table.add{ type = 'frame', style = 'deep_frame_in_shallow_frame' }.add { type = 'list-box', items = {}, vertical_scroll_policy = 'auto-and-reserve-space' }
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
    patter = pattern:lower()

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

Gui.on_click(editor.action_map_reroll, function(event)
    Terrain.set_random_seed()
    fsrc.raise_event(defines.events.on_map_reset, { override = true })
end)

Gui.on_click(editor.action_map_reset, function(event)
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
    if points.north == points.south then
        return event.player.print('Cannot end the match: teams on even points', { color = { 255, 255, 0 } })
    else
        Game.transition()
        return event.player.print('Match has ended!', { color = { 0, 255, 0 } })
    end
end)

Gui.on_click(editor.action_get_random, function(event)
    Editor.update(event.player, true)
end)

Gui.on_click(editor.action_clear_new_random, function(event)
    table.clear_table(proposed)
    table.add_all(proposed, selected)

    Editor.update(event.player)
end)

Gui.on_click(editor.action_confirm_new_random, function(event)
    table.clear_table(selected)
    table.add_all(selected, proposed)
    table.clear_table(proposed)

    Visual.update_all()
    Editor.update_all()
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