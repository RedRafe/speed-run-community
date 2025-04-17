local Challenges = require 'scripts.gui.player.challenges'
local Config = require 'scripts.config'
local Game = require 'scripts.modules.game'
local Gui = require 'scripts.modules.gui'

local table_concat = table.concat
local math_floor = math.floor
local string_format = string.format

local main_frame_name = Gui.uid_name('main_frame')

local Public = {}

fsrc.add(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    if not (player and player.valid) then
        return
    end

    local frame = Gui.add_top_element(player, {
        type = 'frame',
        name = main_frame_name,
        style = 'subheader_frame',
    })
    frame.location = { x = 1, y = 40 }
    Gui.set_style(frame, { minimal_height = 40, maximal_height = 40 })

    local label, line
    local data = {}

    do -- North
        label = frame.add({ type = 'label', caption = Config.force_name_map.north })
        Gui.set_style(label, { font = 'heading-1', right_padding = 4, left_padding = 4, font_color = Config.color.north })
        data.north_list = label

        line = frame.add({ type = 'line', direction = 'vertical' })

        label = frame.add({ type = 'label', caption = '---', tooltip = 'Challanges completed' })
        Gui.set_style(label, { font = 'default', right_padding = 4, left_padding = 4, font_color = { 225, 225, 225 } })
        data.north_count = label
    end

    line = frame.add({ type = 'line', direction = 'vertical', style = 'dark_line' })

    label = frame.add({ type = 'label', caption = '---' })
    Gui.set_style(label, { font = 'default', right_padding = 4, left_padding = 4, font_color = { 225, 225, 225 } })
    data.clock = label

    line = frame.add({ type = 'line', direction = 'vertical', style = 'dark_line' })

    do -- South
        label = frame.add({ type = 'label', caption = '---', tooltip = 'Challanges completed' })
        Gui.set_style(label, { font = 'default', right_padding = 4, left_padding = 4, font_color = { 225, 225, 225 } })
        data.south_count = label

        line = frame.add({ type = 'line', direction = 'vertical' })

        label = frame.add({ type = 'label', caption = Config.force_name_map.south })
        Gui.set_style(label, { font = 'heading-1', right_padding = 4, left_padding = 4, font_color = Config.color.south })
        data.south_list = label
    end

    Gui.set_data(frame, data)
end)

Public.on_nth_tick = function(player)
    local time = Public.format_time(Game.ticks())
    local status = { 'bingo.status', table.index_of(Config.game_state, Game.state()) }
    local points = Challenges.get_points()
    local north_caption = { 'bingo.force_count', points.north }
    local north_tooltip = Public.get_force_list_tooltip('north')
    local south_caption = { 'bingo.force_count', points.south }
    local south_tooltip = Public.get_force_list_tooltip('south')

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_top_element(player, main_frame_name)
        local data = frame and Gui.get_data(frame)

        data.north_count.caption = north_caption
        data.north_list.tooltip = north_tooltip
        data.south_count.caption = south_caption
        data.south_list.tooltip = south_tooltip
        data.clock.caption = time
        data.clock.tooltip = status
    end
end

---@param ticks number
Public.format_time = function(ticks)
    local seconds = math_floor(ticks / 60)
    local minutes = math_floor(seconds / 60)
    local hours = math_floor(minutes / 60)

    hours = hours % 24
    minutes = minutes % 60
    seconds = seconds % 60

    return string_format(
        '[font=default-semibold]%02d[/font][font=default-small]h[/font] [font=default-semibold]%02d[/font][font=default-small]m[/font] [font=default-semibold]%02d[/font][font=default-small]s[/font]',
        hours,
        minutes,
        seconds
    )
end

Public.get_force_list_tooltip = function(side)
    local force = game.forces[side]
    local list = { string_format('[color=255,230,192][font=var]Tot. players[/font][/color]: %d', #force.connected_players) }
    for _, player in pairs(force.connected_players) do
        local c = player.color
        list[#list + 1] = string_format('[color=%f,%f,%f]%s[/color]', c.r, c.g, c.b, player.name)
    end
    return table_concat(list, '\n')
end

fsrc.add(60, Public.on_nth_tick, { on_nth_tick = true })

return Public