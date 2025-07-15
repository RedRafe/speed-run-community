local Inventory = require 'scripts.modules.inventory'

local format = string.format

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
local function process(challenges)
    for _, challenge in ipairs(challenges) do
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

local suffixes = { 'Factory', 'Mega Factory', 'Giga Factory' }
---@param name string|string[]
---@param counts uint[]
function Public.factory(name, counts)
    local challenges = { weight = 1/2 } ---@type LuaChallenge[]
    local multiple = type(name) == 'table'
    for i, count in pairs(counts) do
        local condition = { type = 'craft', count = count }
        if multiple then
            condition.names = name --[[@as string[] ]]
        else
            condition.name = name --[[@as string]]
        end

        local rich_icons = {}
        for j, craft in pairs(condition.names or { condition.name }) do
            rich_icons[j] = format('[img=item.%s]', craft)
        end

        local len = #rich_icons
        if len > 1 then
            rich_icons[len] = 'or ' .. rich_icons[len]
        end

        challenges[i] = {
            caption =  rich_icons[1] .. ' ' .. suffixes[i],
            tooltip = format('Craft a total of %dx %s.', count, table.concat(rich_icons, ', ')),
            condition = condition,
        }
    end

    return challenges
end

function Public.starting_items()
    local tbl = {}
    for i, item in pairs(Inventory.get_starting_items()) do
        tbl[i] = format('%dx [img=item.%s]', item.count, item.name)
    end
    return table.concat(tbl, ', ')
end

return Public

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
---@field entity_type? string
---@field damage_type? string
---@field cause_type? string
---@field cause_name? string
---@field same_force? boolean

---@class EquipCondition:GenericCondition
---@field type 'equip'

---@class CustomCondition
---@field type 'custom'
---@field name string
---@field data table<AnyBasic, AnyBasic>