local Gui = require 'scripts.modules.gui'
local PlayerMenu = require 'scripts.gui.player.core'
local Config = require 'scripts.config'

local Public = {}

local main_button_name = Gui.uid_name('team_button')
local player_list_tag = Gui.uid_name('player_list')
local action_move = Gui.uid_name('move')

local current_selected = {}
local current_source = {}

fsrc.subscribe({
    current_selected = current_selected,
    current_source = current_source,
}, function(tbl)
    current_selected = tbl.current_selected
    current_source = tbl.current_source
end)

local shortcuts = {
    north_right = 'player',
    player_left = 'north',
    player_right = 'south',
    south_left = 'player'
}

local pages = PlayerMenu.get_pages()
pages[#pages + 1] = {
    admin = true,
    button = {
        type = 'sprite-button',
        sprite = 'team',
        tooltip = 'Team manager',
        name = main_button_name,
    },
    caption = {
        type = 'label',
        caption = 'Teams',
        style = 'bold_label',
    },
}

Public.draw = function(player)
    local data = PlayerMenu.get_right_data(player)
    local frame = data.canvas

    local flow = frame.add { type = 'frame' }.add{ type = 'flow', direction = 'horizontal' }
    Gui.set_style(flow, { top_padding = 6 })
    Gui.add_pusher(flow)
    local inner_flow = flow.add { type = 'flow', direction = 'vertical' }
    Gui.add_pusher(inner_flow, 'vertical')
    local tbl = flow.add { type = 'table', column_count = 5 }
    Gui.add_pusher(inner_flow, 'vertical')
    Gui.add_pusher(flow)

    local lists = {}

    local function make_header(parent, force)
        local button = parent.add { type = 'sprite-button', caption = Config.force_name_map[force], style = 'frame_button' }
        Gui.set_style(button, { minimal_width = 170, maximal_width = 170, font_color = Config.color[force], font = 'heading-1' })
        button.ignored_by_interaction = true
    end

    local function make_list(parent, force)
        local list_box = parent.add { type = 'list-box', items = {}, tags = { [Gui.tag] = player_list_tag, name = force } }
        Gui.set_style(list_box, { minimal_height = 480, minimal_width = 170, maximal_height = 480 })
        lists[force] = list_box
    end

    local function make_buttons(parent)
        local tt = parent.add { type = 'table', column_count = 1 }
        local button = tt.add({ type = 'sprite-button', caption = '←', tags = { [Gui.tag] = action_move, direction = 'left' } })
        Gui.set_style(button, { font = 'heading-1', maximal_height = 38, maximal_width = 38, font_color = { 255, 255, 255 } })
        local button = tt.add({ type = 'sprite-button', caption = '→', tags = { [Gui.tag] = action_move, direction = 'right' } })
        Gui.set_style(button, { font = 'heading-1', maximal_height = 38, maximal_width = 38, font_color = { 255, 255, 255 } })
    end

    --- Header
    make_header(tbl, 'north')
    tbl.add { type = 'empty-widget' }
    make_header(tbl, 'player')
    tbl.add { type = 'empty-widget' }
    make_header(tbl, 'south')

    --- Table
    make_list(tbl, 'north')
    make_buttons(tbl)
    make_list(tbl, 'player')
    make_buttons(tbl)
    make_list(tbl, 'south')

    data.teams = lists

    Public.update(player)
end

Public.update = function(player)
    local frame = PlayerMenu.get_main_frame(player)
    local data = frame and Gui.get_data(frame)
    if not (data and data.teams and data.teams) then
        return
    end

    local pattern = data.searchbox.text or ''
    patter = pattern:lower()

    for force, list_box in pairs(data.teams) do
        if list_box.valid then
            local items = {}
            for _, p in pairs(game.forces[force].connected_players) do
                if string.find(p.name:lower(), pattern) then
                    items[#items + 1] = p.name
                end
            end
            table.sort(items)
            list_box.items = items
        end
    end
end

-- == EVENTS ==================================================================

Gui.on_click(main_button_name, function(event)
    PlayerMenu.toggle_left_button(event.player, main_button_name)
    PlayerMenu.clear_right_data(event.player)
    current_selected[event.player_index] = nil
    if event.element.toggled then
        Public.draw(event.player)
    end
end)

Gui.on_selection_state_changed(player_list_tag, function(event)
    local element = event.element
    current_selected[event.player_index] = element.items[element.selected_index]
    current_source[event.player_index] = element.tags.name
end)

Gui.on_click(action_move, function(event)
    local player_index = event.player_index
    if not current_selected[player_index] then
        return
    end

    local source = current_source[player_index]
    if not source then
        return
    end

    local key = source .. '_' .. event.element.tags.direction
    local destination = shortcuts[key]
    if not destination then
        return
    end

    local player = game.get_player(current_selected[player_index])
    if not player or (player.force.name == destination) then
        return
    end
    player.force = destination

    for _, p in pairs(game.players) do
        Public.update(p)
    end
end)

PlayerMenu.on_filter_changed(main_button_name, function(event)
    Public.update(event.player)
end)

-- ============================================================================
