---@alias LuaChallengeUnion LuaChallenge|LuaChallenge[]

---@class LuaChallenge
---@field caption string
---@field tooltip string
---@field condition? LuaChallengeCondition
---@field icon? {sprite: string, number: int}

---@alias LuaChallengeCondition BuildCondition|CraftCondition|ResearchCondition|HoldCondition|DeathCondition|EquipCondition|CustomCondition

---@class GenericCondition
---@field name? string
---@field names? string[]
---@field count? uint

---@class BuildCondition:GenericCondition
---@field type 'build'

---@class CraftCondition:GenericCondition
---@field type 'craft'

---@class ResearchCondition:GenericCondition
---@field type 'research'

---@class HoldCondition:GenericCondition
---@field type 'hold'

---@class DeathCondition:GenericCondition
---@field type 'death'

---@class EquipCondition:GenericCondition
---@field type 'equip'

---@class CustomCondition
---@field type 'custom'
---@field name string

local Public = {}

local icon_map = {
    build = 'entity/',
    craft = 'item/',
    research = 'technology/',
    hold = 'item/',
    death = 'entity/',
    equip = 'equipment/',
}

---@param challenges LuaChallengeUnion[]
function process(challenges)
    for _, challenge in pairs(challenges) do
        if challenge.caption then
            if challenge.icon then
                goto continue
            end

            local condition = challenge.condition
            if not condition then
                goto continue
            end

            local icon = icon_map[condition.type]
            if icon then
                local name = condition.name or condition.names[1]
                icon = icon .. name
                if not helpers.is_valid_sprite_path(icon) and condition.type == 'craft' then
                    icon = 'fluid/' .. name
                end
                if helpers.is_valid_sprite_path(icon) then
                    challenge.icon = { sprite = icon, number = condition.count }
                end
            end
        else
            process(challenge)
        end

        ::continue::
    end

    return challenges
end
Public.process = process

---@param caption string
---@param tooltip string
---@param name string|string[]
---@param counts uint[]
function Public.factory(caption, tooltip, name, counts)
    local suffixes = {'Mega Factory', 'Giga Factory'}
    if #counts == 3 then
        table.insert(suffixes, 'Factory')
    end

    local challenges = {} ---@type LuaChallenge[]
    local multiple = type(name) == 'table'
    for i, count in pairs(counts) do
        local condition = { type = 'craft', count = count }
        if multiple then
            condition.names = name
        else
            condition.name = name
        end

        challenges[i] = {
            caption = caption .. ' ' .. suffixes[i],
            tooltip = string.format(tooltip, count),
            condition = condition,
        }
    end

    return challenges
end

return Public