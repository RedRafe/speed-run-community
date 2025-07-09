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
---@field damage_type? string
---@field cause_type? string
---@field cause_name? string
---@field enemy? boolean

---@class EquipCondition:GenericCondition
---@field type 'equip'

---@class CustomCondition
---@field type 'custom'
---@field name string
---@field data table<AnyBasic, AnyBasic>

local Public = {}

local icon_map = {
    build = {'entity/', 'tile/'},
    craft = {'item/', 'fluid/'},
    research = {'technology/'},
    hold = {'item/'},
    death = {'entity/'},
    equip = {'equipment/'},
}

---@param challenges LuaChallengeUnion[]
function process(challenges)
    for _, challenge in pairs(challenges) do
        if challenge.caption then
            if challenge.icon then
                if not helpers.is_valid_sprite_path(challenge.icon.sprite) then
                    challenge.icon.sprite = 'utility/questionmark'
                end
                goto continue
            end

            local condition = challenge.condition
            if not condition then
                challenge.icon = { sprite = 'utility/questionmark' }
                goto continue
            end

            local icons = icon_map[condition.type]
            if icons then
                local name = condition.name or condition.names[1]
                for _, icon in pairs(icons) do
                    icon = icon .. name
                    if helpers.is_valid_sprite_path(icon) then
                        challenge.icon = { sprite = icon, number = condition.count }
                        goto forelse
                    end
                end

                challenge.icon = { sprite = 'utility/questionmark', count = condition.count }

                ::forelse::
            end
        else
            process(challenge)
        end

        ::continue::
    end

    return challenges
end
Public.process = process

---@param sprite SpritePath
---@param number? int
function Public.icon(sprite, number)
    return { sprite = sprite, number = number }
end

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