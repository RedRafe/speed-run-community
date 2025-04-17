local Config = require 'scripts.config'

local Public = {}

---@type LuaChallenge
---@field caption string
---@field tooltip string

---@type LuaChallenge[]
local challenges = {}
local this = {
    size = 5
}

fsrc.subscribe({
    challenges = challenges,
    this = this,
}, function(tbl)
    challenges = tbl.challenges
    this = tbl.this
end)

fsrc.on_init(function()
    for _, challenge in pairs(Config.challenges) do
        table.insert(challenges, table.deepcopy(challenge))
    end
end)

Public.utils = {
    ---@param tbl table
    ---@param challenge LuaChallenge
    contains = function(tbl, challenge)
        if not (challenge and challenge.caption) then
            return
        end
        local caption = challenge.caption:lower()
        for k, v in pairs(tbl) do
            if v.caption:lower() == caption then
                return k
            end
        end
        return nil
    end,
    ---@param tbl table
    ---@param challengeID LuaChallenge|string|number
    remove = function(tbl, challengeID)
        local index = nil
        if type(challengeID) == 'string' then
            index = Public.utils.contains(tbl, { caption = challengeID, tooltip = '' })
        elseif type(challengeID) == 'table' then
            index = Public.utils.contains(tbl, challengeID)
        else
            index = challengeID
        end
        if index and type(index) == 'number' then
            table.remove(tbl, index)
        end
    end
}

Public.get_challenges = function()
    return challenges
end

Public.get_selected = function()
    return Public.select_random_challenges()
end

---@param challenge LuaChallenge
Public.add_challenge = function(challenge)
    if not Public.utils.contains(challenges, challenge) then
        table.insert(challenges, challenge)
    end
end

---@param challengeID number|string
Public.remove_challenge = function(challengeID)
    Public.utils.remove(challenges, challengeID)
end

Public.clear_all = function()
    table.clear_table(challenges)
end

---@param size? number
Public.select_random_challenges = function(size)
    local selected = {}
    local to_add = (size or this.size) ^ 2
    while to_add > 0 do
        local proposed = challenges[math.random(#challenges)]
        if not Public.utils.contains(selected, proposed) then
            table.insert(selected, table.deepcopy(proposed))
            to_add = to_add - 1
        end
    end
    return selected
end

Public.set_size = function(size)
    this.size = size
end

Public.get_size = function()
    return this.size
end

return Public
