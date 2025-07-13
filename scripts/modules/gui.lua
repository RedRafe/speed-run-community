-- created by: grilledham
-- source: https://github.com/Refactorio/RedMew/blob/develop/utils/gui.lua
-- modified by: RedRafe
-- ========================================================================= --

local mod_gui = require '__core__.lualib.mod-gui'
local getinfo = debug.getinfo

-- == GUI LIB =================================================================

local data = {}

local Gui = {
    events = {},
    tag = '__@' .. script.mod_name,
}

fsrc.subscribe(data, function(tbl) data = tbl end)

-- Get a unique name identifier to be used as LuaGuiElement::name or tag
Gui.uid_name = function(name)
    local filename = (getinfo(2, 'S') or getinfo(1, 'S')).short_src:sub(1, -5)
    return filename .. '/' .. name
end

-- Associates data with the LuaGuiElement. If data is nil, then removes the data
---@param element LuaGuiElement
---@param value any
Gui.set_data = function(element, value)
    data[element.player_index] = data[element.player_index] or {}
    data[element.player_index][element.index] = value
end

-- Gets the associated data with this LuaGuiElement, if any
---@param element LuaGuiElement
Gui.get_data = function(element)
    return data[element.player_index] and data[element.player_index][element.index]
end

-- Sets the style of the LuaGuiElement to a prototype, if string, or sets LuaGuiElement::style attributes as provided in the table
---@param element LuaGuiElement
---@param style string|table
Gui.set_style = function(element, style)
    if type(style) == 'string' then
        element.style = style
    else
        for k, v in pairs(style) do
            element.style[k] = v
        end
    end
    return element
end

-- Removes data associated with LuaGuiElement and its children recursively
---@param element LuaGuiElement
Gui.remove_data_recursively = function(element)
    Gui.set_data(element, nil)

    local children = element.children

    if not children then
        return
    end

    for _, child in next, children do
        if child.valid then
            Gui.remove_data_recursively(child)
        end
    end
end

-- Removes data associated with LuaGuiElement
---@param element LuaGuiElement
Gui.remove_children_data = function(element)
    local children = element.children

    if not children then
        return
    end

    for _, child in next, children do
        if child.valid then
            Gui.set_data(child, nil)
            Gui.remove_children_data(child)
        end
    end
end

-- Removes data associated with LuaGuiElement and its children recursively and destroys it
---@param element LuaGuiElement
Gui.destroy = function(element)
    Gui.remove_data_recursively(element)
    element.destroy()
end

-- Removes data associated with LuaGuiElement and clears it
---@param element LuaGuiElement
Gui.clear = function(element)
    Gui.remove_children_data(element)
    element.clear()
end

-- == EVENTS ==================================================================

-- Register a handler for the defines.events.EVENT_ID event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
---@param event_id defines.events
---@return function(element_name `string`, handler `function`)
local function handler_factory(event_id)
    local handlers

    local function on_event(event)
        local element = event.element
        if not element or not element.valid then
            return
        end

        local tag = element.tags and element.tags[Gui.tag]
        local handler = handlers[tag or element.name]
        if not handler then
            return
        end

        local player = game.get_player(event.player_index)
        if not player or not player.valid then
            return
        end
        event.player = player

        handler(event)
    end

    return function(element_name, handler)
        if not handlers then
            handlers = {}
            fsrc.add(event_id, on_event)
        end

        handlers[element_name] = handler
    end
end

Gui.on_checked_state_changed = handler_factory(defines.events.on_gui_checked_state_changed)
Gui.on_click = handler_factory(defines.events.on_gui_click)
Gui.on_closed = handler_factory(defines.events.on_gui_closed)
Gui.on_confirmed = handler_factory(defines.events.on_gui_confirmed)
Gui.on_elem_changed = handler_factory(defines.events.on_gui_elem_changed)
Gui.on_hover = handler_factory(defines.events.on_gui_hover)
Gui.on_leave = handler_factory(defines.events.on_gui_leave)
Gui.on_location_changed = handler_factory(defines.events.on_gui_location_changed)
Gui.on_opened = handler_factory(defines.events.on_gui_opened)
Gui.on_selected_tab_changed = handler_factory(defines.events.on_gui_selected_tab_changed)
Gui.on_selection_state_changed = handler_factory(defines.events.on_gui_selection_state_changed)
Gui.on_switch_state_changed = handler_factory(defines.events.on_gui_switch_state_changed)
Gui.on_text_changed = handler_factory(defines.events.on_gui_text_changed)
Gui.on_value_changed = handler_factory(defines.events.on_gui_value_changed)

-- == STYLES ==================================================================

Gui.styles = {
    top_button = {
        --name = 'frame_button',
        font_color = { 165, 165, 165 },
        font = 'heading-2',
        minimal_height = 40,
        maximal_height = 40,
        minimal_width = 40,
        padding = 0,
    },
    pusher = {
        top_margin = 0,
        bottom_margin = 0,
        left_margin = 0,
        right_margin = 0,
    },
    dragger = {
        vertically_stretchable = true,
        horizontally_stretchable = true,
        margin = 0,
    },
    closable_frame = {
        horizontally_stretchable = true,
        vertically_stretchable = true,
        maximal_height = 900,
        top_padding = 8,
        bottom_padding = 8,
    },
}

-- == BUILDERS ================================================================

-- Creates a pusher element at parent LuaGuiElement
---@param parent LuaGuiElement
---@param direction? string `default: horizontal`
---@return LuaGuiElement
Gui.add_pusher = function(parent, direction)
    local pusher = parent.add { type = 'empty-widget' }
    Gui.set_style(pusher, Gui.styles.pusher)
    pusher.ignored_by_interaction = true

    if direction == 'vertical' then
        pusher.style.vertically_stretchable = true
    else
        pusher.style.horizontally_stretchable = true
    end

    return pusher
end

-- Created a dragger at parent LuaGuiElement
---@param parent LuaGuiElement
---@param target? LuaGuiElement
---@return LuaGuiElement
Gui.add_dragger = function(parent, target)
    local dragger = parent.add { type = 'empty-widget', style = 'draggable_space_header' }
    Gui.set_style(dragger, Gui.styles.dragger)

    if target then
        dragger.drag_target = target
    end

    return dragger
end

Gui.closable_frame_close_button_name = Gui.uid_name('close_button')
Gui.closable_frame_search_button_name = Gui.uid_name('search_button')
Gui.closable_frame_searchbox_name = Gui.uid_name('searchbox')

-- Creates a closable window frame with title label and close button in the middle of player's screen
---@param player LuaPlayer
---@param params table<string, value>
---@field name string `name of the closable frame`
---@field caption string `caption to be displayed`
---@field close_button? `string, defaults to its own handler`
---@field search_button? `string, defaults to its own handler`
---@field searchbox? `string
---@return LuaGuiElement `frame`, LuaGuiElement `label`
Gui.add_closable_frame = function(player, params)
    local frame = player.gui.screen[params.name]
    if frame and frame.valid then
        Gui.destroy(frame)
    end

    local info = {}

    frame = player.gui.screen.add { type = 'frame', name = params.name, direction = 'vertical', style = 'frame' }
    info.frame = frame
    Gui.set_style(frame, Gui.styles.closable_frame)
    Gui.set_data(frame, info)

    do -- title
        local title_flow = frame.add { type = 'flow', direction = 'horizontal' }
        Gui.set_style(title_flow, { horizontal_spacing = 8, vertical_align = 'center', bottom_padding = 4 })

        info.label = title_flow.add { type = 'label', caption = params.caption, style = 'frame_title' }
        info.label.drag_target = frame

        local dragger = title_flow.add { type = 'empty-widget', style = 'draggable_space_header' }
        dragger.drag_target = frame
        Gui.set_style(dragger,  {
            height = 24,
            vertically_stretchable = false,
            horizontally_stretchable = true,
        })

        local searchbox = title_flow.add({
            type = 'textfield',
            name = params.searchbox or Gui.closable_frame_searchbox_name,
            style = 'search_popup_textfield',
        })
        info.searchbox = searchbox
        info.searchbox.visible = false
        Gui.set_data(info.searchbox, info)

        info.searchbutton = title_flow.add({
            type = 'sprite-button',
            name = params.search_button or Gui.closable_frame_search_button_name,
            style = 'frame_action_button',
            sprite = 'utility/search',
            tooltip = { 'gui.search-with-focus', '__CONTROL__focus-search__' },
            auto_toggle = true,
        })
        Gui.set_data(info.searchbutton, info)

        info.close_button = title_flow.add {
            type = 'sprite-button',
            name = params.close_button or Gui.closable_frame_close_button_name,
            sprite = 'utility/close',
            clicked_sprite = 'utility/close_black',
            style = 'close_button',
            tooltip = { 'gui.close-instruction' },
        }
        Gui.set_data(info.close_button, info)
    end

    frame.auto_center = true
    return frame
end

Gui.on_click(Gui.closable_frame_close_button_name, function(event)
    Gui.destroy(Gui.get_data(event.element).frame)
end)

Gui.on_click(Gui.closable_frame_search_button_name, function(event)
    Gui.get_data(event.element).searchbox.visible = event.element.toggled
end)

-- ===========================================================================

---@param player LuaPlayer
---@return LuaGuiElement
Gui.get_top_flow = function(player)
    return mod_gui.get_button_flow(player)
end

---@param player LuaPlayer
---@param element_name string
---@return LuaGuiElement?
Gui.get_top_element = function(player, element_name)
    return Gui.get_top_flow(player)[element_name]
end

---@param player LuaPlayer
---@param child table
---@return LuaGuiElement
Gui.add_top_element = function(player, child)
    local flow = Gui.get_top_flow(player)
    local element = flow[child.name]
    if element and element.valid then
        return element
    end

    if (child.type == 'button' or child.type == 'sprite-button') and child.style == nil then
        child.style = 'frame_button'
        return Gui.set_style(flow.add(child), Gui.styles.top_button)
    end

    return flow.add(child)
end

---@param player LuaPlayer
Gui.get_left_flow = function(player)
    return mod_gui.get_frame_flow(player)
end

---@param player LuaPlayer
---@param element_name string
---@return LuaGuiElement?
Gui.get_left_element = function(player, element_name)
    return Gui.get_left_flow(player)[element_name]
end

---@param player LuaPlayer
---@param child table
---@return LuaGuiElement
Gui.add_left_element = function(player, child)
    local flow = Gui.get_left_flow(player)
    local element = flow[child.name]
    if element and element.valid then
        return element
    end
    return flow.add(child)
end

-- ============================================================================

fsrc.add(defines.events.on_player_created, function(event)
    local player = event.player_index and game.get_player(event.player_index)
    if not (player and player.valid) then
        return
    end

    local mod_gui_top_frame = Gui.get_top_flow(player).parent
    Gui.set_style(mod_gui_top_frame, { padding = 2 })
end)

fsrc.add(defines.events.on_player_removed, function(event)
    data[event.player_index] = nil
end)

return Gui
