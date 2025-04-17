local Gui = require 'scripts.modules.gui'
local PlayerMenu = require 'scripts.gui.player.core'
local Statistics = require 'scripts.modules.statistics'
local Config = require 'scripts.config'

local string_find = string.find
function formatNumberWithCommas(number)
    local formattedNumber = string.format('%d', number)
    local left, num, right = string.match(formattedNumber, '^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

local Public = {}

local main_button_name = Gui.uid_name('statistics_button')

local pages = PlayerMenu.get_pages()
pages[#pages + 1] = {
    admin = false,
    button = {
        type = 'sprite-button',
        sprite = 'stats',
        tooltip = 'Production statistics',
        name = main_button_name,
    },
    caption = {
        type = 'label',
        caption = 'Statistics',
        style = 'bold_label',
    },
}

Public.draw = function(player)
    local data = PlayerMenu.get_right_data(player)
    local frame = data.canvas

    local tabs = frame
        .add { type = 'frame', style = 'inside_deep_frame' }
        .add { type = 'tabbed-pane' }
    Gui.set_style(tabs, { minimal_width = 614, minimal_height = 492 })

    local tables = {}

    for name, field in pairs({
        ['Production'] = 'produced',
        ['Consumption'] = 'consumed',
        ['Storage'] = 'stored',
        ['Built'] = 'placed',
        ['Losses'] = 'lost',
        --['Sent'] = 'sent',
    }) do
        local tab = tabs.add { type = 'tab', caption = name }

        local sheet = tabs.add { type = 'frame', style = 'deep_frame_in_shallow_frame', direction = 'vertical' }
        Gui.set_style(sheet, { left_margin = 8, right_margin = 8, bottom_margin = 2 })

        tabs.add_tab(tab, sheet)

        local sp = sheet.add { type = 'scroll-pane', style = 'naked_scroll_pane', vertical_scroll_policy = 'always' }
        Gui.set_style(sp, { horizontally_squashable = false, vertically_stretchable = true, horizontally_stretchable = true })

        local stats_table = sp.add { type = 'table', name = field, column_count = 2 }
        Gui.set_style(stats_table, { horizontal_spacing = 0, vertical_spacing = 0 })

        tables[field] = stats_table
    end

    data.stats_tables = tables
    Public.update(player)
end

Public.update = function(player)
    local frame = PlayerMenu.get_main_frame(player)
    local data = frame and Gui.get_data(frame)
    if not (data and data.stats_tables) then
        return
    end

    local pattern = data.searchbox.text or ''
    patter = pattern:lower()
    local current = Statistics.get_current()
    local north = current.north
    local south = current.south

    local function add_flow_statistic(parent, item_name)
        local value = {
            north = north[item_name][parent.name] or 0,
            south = south[item_name][parent.name] or 0
        }
        local tot = value.north + value.south
        if tot == 0 then
            return
        end

        local flow = parent.add { type = 'frame', direction = 'horizontal', style = 'shallow_frame' }
        Gui.set_style(flow, { left_padding = 10, right_padding = 10 })

        flow.add { type = 'sprite-button', sprite = north[item_name].sprite, tooltip = north[item_name].localised_name, style = 'slot_button_in_shallow_frame' }

        local comparison = flow.add { type = 'flow', direction = 'vertical' }

        for side, color in pairs({
            north = { 140, 140, 252 },
            south = { 252, 084, 084 },
        }) do
            local flow = comparison.add { type = 'flow', direction = 'horizontal' }
            Gui.set_style(flow, { vertical_align = 'center' })

            local progressbar = flow.add { type = 'progressbar', value = value[side] / tot }
            Gui.set_style(progressbar, { color = color, natural_width = 160 })

            local label = flow.add { type = 'label', caption = formatNumberWithCommas(value[side]) }
            Gui.set_style(label, { minimal_width = 65, horizontal_align = 'right' })
        end
    end

    for _, parent in pairs(data.stats_tables) do
        if parent.valid then
            parent.clear()
            for _, stat in pairs(current.north) do
                if string_find(stat.name:lower(), pattern) then
                    add_flow_statistic(parent, stat.name)
                end
            end
        end
    end
end

-- == EVENTS ==================================================================

Gui.on_click(main_button_name, function(event)
    PlayerMenu.toggle_left_button(event.player, main_button_name)
    PlayerMenu.clear_right_data(event.player)
    if event.element.toggled then
        Public.draw(event.player)
    end
end)

PlayerMenu.on_filter_changed(main_button_name, function(event)
    Public.update(event.player)
end)

-- ============================================================================