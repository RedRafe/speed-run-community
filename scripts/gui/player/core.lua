local Gui = require 'scripts.modules.gui'
local SplitView = require 'scripts.gui.split_view'

local Public = SplitView{
    main_button_name = Gui.uid_name('top_button'),
    main_button_sprite = 'speedrun',
    main_button_tooltip = {'bingo.player_menu_tooltip'},
    main_frame_caption = 'Player menu',
    main_frame_name = Gui.uid_name('main_frame'),
    searchbox_name = Gui.uid_name('searchbox')
}

return Public