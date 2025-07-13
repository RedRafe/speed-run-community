local Config = require 'scripts.config'

local Public = {}

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
        local index = challengeID
        if type(challengeID) == 'string' then
            index = Public.utils.contains(tbl, { caption = challengeID, tooltip = '' })
        elseif type(challengeID) == 'table' then
            index = Public.utils.contains(tbl, challengeID)
        end
        if index and type(index) == 'number' then
            table.remove(tbl, index)
        end
    end
}

local function unpack_challenges(list, challenge_arr)
    for _, challenge in ipairs(challenge_arr) do
        if challenge.caption then
            list[#list+1] = challenge
        else
            unpack_challenges(list, challenge)
        end
    end
end

Public.get_challenges = function()
    local list = {}
    unpack_challenges(list, challenges)
    return list
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

local function choose_random_challenge(list)
    local index = math.random(#list)
    local selected = list[index]

    if not selected.caption then
        if selected.limit and selected.limit > 0 then
            selected.limit = selected.limit - 1
        else
            table.remove(list, index)
        end
        return choose_random_challenge(selected)
    end

    table.remove(list, index)
    return selected
end

---@param size? number
Public.select_random_challenges = function(size)
    local selected = {} ---@type LuaChallenge[]
    local to_add = (size or this.size) ^ 2
    local list = table.deepcopy(challenges)
    for i = 1, to_add do
        selected[i] = choose_random_challenge(list)
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
