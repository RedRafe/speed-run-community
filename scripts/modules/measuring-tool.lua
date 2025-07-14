local format = string.format

---@param event EventData.on_player_selected_area
local function measure(event)
    if event.item ~= 'measuring-tool' then
        return
    end

    local counts = {}
    for _, entity in pairs(event.entities) do
        local name = entity.type == 'entity-ghost' and entity.ghost_name or entity.name
        counts[name] = (counts[name] or 0) + 1
    end

    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local texts = {}
    for name, count in pairs(counts) do
        texts[#texts+1] = format('[img=entity.%s]: %d', name, count)
    end

    player.create_local_flying_text{
        text = table.concat(texts, '\n'),
        position = player.position,
        time_to_live = 5 * 60,
    }
end

fsrc.add(defines.events.on_player_selected_area, measure)
fsrc.add(defines.events.on_player_alt_selected_area, measure)