local Colors = require 'utils.colors'
local Gui = require 'scripts.modules.gui'

---@param config table
---@param config.main_button_name string
---@param config.main_button_sprite string
---@param config.main_button_tooltip string
---@param config.main_frame_caption string
---@param config.main_frame_name string
---@param config.search_button_name string
---@param config.searchbox_name string
return function(config)
    local Public = {
        config = config
    }
    local pages = {}

    function Public.get_pages()
        return pages
    end

    function Public.get_right_data(player)
        return Gui.get_data(Public.get_main_frame(player))
    end

    function Public.get_subheader(player)
        local subheader = Public.get_right_data(player).subheader
        subheader.parent.visible = true
        return subheader
    end

    function Public.get_canvas(player)
        return Public.get_right_data(player).canvas
    end

    function Public.get_subfooter(player)
        local subfooter = Public.get_right_data(player).subfooter
        subfooter.parent.visible = true
        return subfooter
    end

    function Public.try_get_main_frame(player)
        return player.gui.screen[config.main_frame_name]
    end

    function Public.get_main_frame(player)
        local frame = player.gui.screen[config.main_frame_name]
        if frame and frame.valid then
            return frame
        end

        frame = Gui.add_closable_frame(player, {
            name = config.main_frame_name,
            caption = config.main_frame_caption,
            search_button = config.search_button_name,
            searchbox = config.searchbox_name,
        })
        Gui.set_style(frame, {
            natural_width = 600,
            natural_height = 610,
            horizontally_stretchable = true,
            vertically_stretchable = true,
        })

        local data = Gui.get_data(frame)
        local main_flow = frame.add { type = 'flow', name = 'flow', direction = 'horizontal' }
        Gui.set_style(main_flow, { horizontal_spacing = 12 })

        do -- left
            local left_pane = main_flow.add { type = 'frame', direction = 'vertical', style = 'inside_deep_frame' }.add {
                type = 'scroll-pane',
                direction = 'vertical',
                horizontal_scroll_policy = 'never',
                vertical_scroll_policy = 'dont-show-but-allow-scrolling',
            }
            Gui.set_style(left_pane, { maximal_height = 400 })

            local left = left_pane.add { type = 'flow', name = 'left', direction = 'vertical' }
            Gui.set_style(left, {
                vertically_stretchable = true,
                horizontal_align = 'center',
                padding = 10,
                vertical_spacing = 5,
                minimal_width = 60,
            })

            data.left_buttons = {}
            for _, page in pairs(pages) do
                local button = left.add(page.button)
                local caption = left.add(page.caption)

                if page.admin then
                    button.visible = player.admin
                    caption.visible = player.admin
                end

                data.left_buttons[page.button.name] = button
            end
            data.left = left
        end

        do -- right
            data.right =
                main_flow.add { type = 'frame', style = 'inside_shallow_frame_with_padding', direction = 'vertical' }
            Gui.set_style(data.right, {
                natural_width = 640,
                natural_height = 400,
                vertically_stretchable = true,
                horizontally_stretchable = true,
                padding = 0,
            })

            local subheader = data.right.add { type = 'frame', style = 'subheader_frame' }
            Gui.set_style(subheader, { use_header_filler = true, horizontally_stretchable = true })
            data.subheader = subheader.add { type = 'flow', direction = 'horizontal' }
            Gui.set_style(data.subheader, { vertical_align = 'center', left_padding = 8, right_padding = 8 })
            subheader.visible = false

            data.canvas = data.right.add { type = 'flow', direction = 'vertical' }
            Gui.set_style(data.canvas, {
                vertically_stretchable = true,
                horizontally_stretchable = true,
                padding = 0, --12,
            })

            local subfooter = data.right.add { type = 'frame', style = 'subfooter_frame' }
            Gui.set_style(subfooter, { use_header_filler = true, horizontally_stretchable = true })
            data.subfooter =
                subfooter.add { type = 'flow', direction = 'horizontal', style = 'player_input_horizontal_flow' }
            Gui.set_style(data.subfooter, { vertical_align = 'center', left_padding = 8, right_padding = 8 })
            subfooter.visible = false

            Gui.set_data(data.right, {
                subheader = data.subheader,
                canvas = data.canvas,
                subfooter = data.subfooter,
                right = data.right,
            })
        end

        player.opened = frame
    end

    function Public.toggle_main_button(player)
        local main_frame = player.gui.screen[config.main_frame_name]
        if main_frame then
            Gui.destroy(main_frame)
        else
            Public.get_main_frame(player)
        end
    end

    function Public.toggle_left_button(player, button_name)
        local frame = player.gui.screen[config.main_frame_name]
        if not (frame and frame.valid) then
            return
        end

        for _, elem in pairs(Gui.get_data(frame).left_buttons) do
            if elem.name == button_name then
                elem.toggled = not elem.toggled
            else
                elem.toggled = false
            end
        end
    end

    function Public.clear_right_data(player)
        local data = Public.get_right_data(player)
        Gui.clear(data.subheader)
        Gui.clear(data.canvas)
        Gui.clear(data.subfooter)
        data.subheader.parent.visible = false
        data.subfooter.parent.visible = false
    end

    function Public.draw_title(player, caption)
        local subheader = Public.get_subheader(player)
        local title = subheader.add { type = 'label', style = 'heading_2_label', caption = caption }
        Gui.set_style(title, { font_color = Colors.main })
        subheader.parent.visible = true
    end

    fsrc.add(defines.events.on_player_created, function(event)
        local player = game.get_player(event.player_index)
        if not (player and player.valid) then
            return
        end

        Gui.add_top_element(player, {
            type = 'sprite-button',
            name = config.main_button_name,
            sprite = config.main_button_sprite,
            tooltip = config.main_button_tooltip,
        })
    end)

    Gui.on_closed(config.main_frame_name, function(event)
        Public.toggle_main_button(event.player)
    end)

    Gui.on_click(config.main_button_name, function(event)
        Public.toggle_main_button(event.player)
    end)

    fsrc.add(prototypes.custom_input.open_player_menu, function(event)
        local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
        Public.toggle_main_button(player)
    end)

    Public.on_filter_changed = (function()
        local handlers

        local function on_event(event)
            local data = Gui.get_data(event.element)
            if not (data and data.left_buttons) then
                return
            end

            local handler
            for name, button in pairs(data.left_buttons) do
                if button.toggled then
                    handler = handlers[name]
                end
            end
            if not handler then
                return
            end

            handler(event)
        end

        return function(element_name, handler)
            if not handlers then
                handlers = {}
                Gui.on_text_changed(config.searchbox_name, on_event)
            end

            handlers[element_name] = handler
        end
    end)()

    return Public
end
