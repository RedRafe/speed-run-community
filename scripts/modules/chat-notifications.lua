local Config = require 'scripts.config'

local force_name_map = Config.force_name_map
local format = string.format

local sides = {
    west = true,
    east = true,
}

-- == RESEARCH QUEUE ============================================================

fsrc.add(defines.events.on_research_queued, function(event)
    local player = game.get_player(event.player) --[[@as LuaPlayer]]
    local side = player.force.name
    if not sides[side] then
        return
    end

    local research = event.research
    local player_tag = player.tag or ''
    local force_text = format('(%s) ', force_name_map[side])
    local research_text = format('[technology=%s]', research.name)
    local player_text = format('%s %s', player.name, player_tag)

    game.forces.player.print({ '', force_text, { 'player-queued-research', research_text, player_text } }, { color = Config.color[side], skip = defines.print_skip.never })
end)

fsrc.add(defines.events.on_research_cancelled, function(event)
    local player = game.get_player(event.player) --[[@as LuaPlayer]]
    local side = player.force.name
    if not sides[side] then
        return
    end

    local player_tag = player.tag or ''
    local force_text = format('(%s) ', force_name_map[side])
    local player_text = format('%s %s', player.name, player_tag)

    for research, count in pairs(event.research) do
        local research_text = format('[technology=%s]', research)
        for i = 1, count do
            game.forces.player.print({ '', force_text, { 'player-cancelled-research', research_text, player_text } }, { color = Config.color[side], skip = defines.print_skip.never })
        end
    end
end)

-- TODO: figure out what tech was moved, because it doesn't give it to you in the event
-- player-moved-research-forwards=__1__ moved forwards in the queue by __2__.
-- player-moved-research-backwards=__1__ moved backwards in the queue by __2__.
-- fsrc.add(defines.events.on_research_moved, function(event)

-- end)

fsrc.add(defines.events.on_research_finished, function(event)
    local research = event.research
    local side = research.force.name
    if not sides[side] then
        return
    end

    local force_text = format('(%s) ', force_name_map[side])
    local research_text = format('[technology=%s]', research.name)
    game.forces.player.print({ '', force_text, { 'technology-researched', research_text } }, { color = Config.color[side], skip = defines.print_skip.never, sound = defines.print_sound.never })
end)

-- == DEATH ============================================================

fsrc.add(defines.events.on_pre_player_died, function(event)
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local side = player.force.name
    if not sides[side] then
        return
    end

    local force_text = format('(%s) ', force_name_map[side])
    local player_text = format('%s %s', player.name, player.tag)

    if event.cause then
        game.forces.player.print({ '', force_text, { 'multiplayer.player-died-by', player_text, event.cause, player.position}, { color = Config.color[side] } })
    else
        game.forces.player.print({ '', force_text, { 'multiplayer.player-died', player_text, player.position}, { color = Config.color[side] } })
    end
end)