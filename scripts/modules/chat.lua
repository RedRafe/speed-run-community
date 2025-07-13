local Config = require 'scripts.config'

local Chat = {}

local CHAT_MAX_LENGTH = 100
local insert = table.insert
local remove = table.remove
local format = string.format
local force_name_map = Config.force_name_map

---@usage
---@field announcement: provides a global read-only chat for players, used by game to display event info
---@field chats: provides individual player-to-player chats
---@field muted_players: lookup table of muted players

local announcement = {}
local chats = {}
local muted_players = {}

fsrc.subscribe({
    announcement = announcement,
    chats = chats,
    muted_players = muted_players,
}, function(tbl)
    announcement = tbl.announcement
    chats = tbl.chats
    muted_players = tbl.muted_players
end)

local function push(queue, element)
    insert(queue, element)
    while #queue > CHAT_MAX_LENGTH do
        remove(queue, 1)
    end
end

-- == MUTE ====================================================================

Chat.is_muted = function(player_index)
    return muted_players[player_index] ~= nil
end

fsrc.add(defines.events.on_player_muted, function(event)
    muted_players[event.player_index] = true
end)

fsrc.add(defines.events.on_player_unmuted, function(event)
    muted_players[event.player_index] = nil
end)

fsrc.add(defines.events.on_player_removed, function(event)
    muted_players[event.player_index] = nil
end)

--- Forward force chats to spectators
fsrc.add(defines.events.on_console_chat, function(event)
    local index = event.player_index
    local message = event.message
    if not (index and message) then
        return
    end

    if Chat.is_muted(index) then
        return
    end

    local player = game.get_player(index)
    if not (player and player.valid and player.character) then
        return
    end

    message = message:gsub('virtual%-signal=emoji%-', 'img=virtual-signal.emoji-')

    local player_force = player.force.name
    local player_tag = player.tag or ''
    local color = Config.color[player_force]
    local player_force_text = format('[color=%d,%d,%d](%s)[/color]', color[1], color[2], color[3], force_name_map[player_force])
    local msg = format('%s %s %s: %s', player.name, player_tag, player_force_text, message)

    if player_force == 'player' then
        if not msg:find('%[gps_tag=.+%]') then -- TODO: if not tournament mode
            game.forces.west.print(msg, { color = player.color })
            game.forces.east.print(msg, { color = player.color })
        end
    else
        if true then -- TODO: if not preparation phase
            game.forces.player.print(msg, { color = player.color })
        end
    end
end)

-- == FORCE CHAT COMMANDS ============================================================

local function force_chat(force_name, command)
    local message = command.parameter
    if not message then
        return
    end
    local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
    local player_force = player.force.name
    local player_tag = player.tag or ''
    local color = Config.color[player_force]
    local player_force_text = format('[color=%d,%d,%d](%s)[/color]', color[1], color[2], color[3], force_name_map[player_force])
    color = Config.color[force_name]
    local force_text = format('[color=%d,%d,%d](%s)[/color]', color[1], color[2], color[3], force_name_map[force_name])
    local msg = format('%s %s %s to %s: %s', player.name, player_tag, player_force_text, force_text, message)

    game.forces.player.print(msg, { color = player.color })
    game.forces[force_name].print(msg, { color = player.color })
end

for name, cmd in pairs{ west = 'west', east = 'east', player = 'spectator' } do
    commands.add_command(cmd, nil, function(command)
        force_chat(name, command)
    end)
end

-- == PLAYER CHATS ============================================================

---@param index_1 number, LuaPlayer::index
---@param index_2 number, LuaPlayer::index
---@return table|nil
local function get_chat(index_1, index_2)
    if index_1 > index_2 then
        index_1, index_2 = index_2, index_1
    end

    return chats[index_1] and chats[index_1][index_2]
end

---@param index_1 number, LuaPlayer::index
---@param index_2 number, LuaPlayer::index
---@return table
local function get_or_create_chat(index_1, index_2)
    if index_1 > index_2 then
        index_1, index_2 = index_2, index_1
    end

    local chat = chats[index_1] and chats[index_1][index_2]
    if not chat then
        chat = {}
        chats[index_1] = chats[index_1] or {}
        chats[index_1][index_2] = chat
        return chat
    end

    return chat
end

---@param index_1 number, LuaPlayer::index
---@param index_2 number, LuaPlayer::index
---@return table
Chat.get_chat = function(index_1, index_2)
    return get_or_create_chat(index_1, index_2)
end

---@param index_1 number, LuaPlayer::index
---@param index_2 number, LuaPlayer::index
---@param message string
Chat.post_chat = function(index_1, index_2, message)
    local player = game.get_player(index_1)
    if not (player and player.valid) then
        return
    end

    if Chat.is_muted(index_1) then
        player.print({ 'warning.chats_player_muted' })
        return
    end

    push(
        get_or_create_chat(index_1, index_2),
        format('%s: %s', player.name, message)
    )
end

---@param index_1 number, LuaPlayer::index
---@param index_2 number, LuaPlayer::index
Chat.clear_chat = function(index_1, index_2)
    local chat = get_chat(index_1, index_2)
    if chat then
        for i in pairs(chat) do
            chat[i] = nil
        end
    end
end

---@param index_1 number, LuaPlayer::index
---@param index_2 number, LuaPlayer::index
Chat.remove_chat = function(index_1, index_2)
    if index_1 > index_2 then
        index_1, index_2 = index_2, index_1
    end

    local chat = chats[index_1] and chats[index_1][index_2]
    if chat then
        chats[index_1][index_2] = nil
        if table.size(chats[index_1]) == 0 then
            chats[index_1] = nil
        end
    end
end

---@param index_1 number, LuaPlayer::index
Chat.clear_player_chats = function(index_1)
    chats[index_1] = nil

    for _, list in pairs(chats) do
        for index_2, _ in pairs(list) do
            if index_1 == index_2 then
                list[index_2] = nil
            end
        end
    end
end

Chat.get_all_chats = function()
    return chats
end

Chat.clear_all_chats = function()
    for index_1, list in pairs(chats) do
        for index_2, _ in pairs(list) do
            Chat.clear_chat(index_1, index_2)
        end
    end
end

Chat.remove_all_chats = function()
    for index_1, list in pairs(chats) do
        for index_2, _ in pairs(list) do
            Chat.clear_chat(index_1, index_2)
        end
    end
end

fsrc.add(defines.events.on_player_removed, function(event)
    Chat.clear_player_chats(event.player_index)
end)

-- == ANNOUNCEMENTS ===========================================================

---@return table
Chat.get_announcement = function()
    return announcement
end

---@param message string
Chat.post_announcement = function(message)
    push(announcement, message)
end

Chat.clear_announcement = function()
    for i in pairs(announcement) do
        announcement[i] = nil
    end
end

-- ============================================================================

return Chat