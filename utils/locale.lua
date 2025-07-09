---@class Locale
local Locale = {}

local Entities = prototypes.entity
local Tiles = prototypes.tile
---@param name string
---@return LuaEntityPrototype|LuaTilePrototype
local function get_entity_or_tile(name)
	return Entities[name] or Tiles[name]
end

---@param list LocalisedString[]
---@return LocalisedString
local function listify(key, list)
	local count = #list
	if count > 19 then error 'More complicated logic needs to be implemented for or lists larger than 19' end

	---@type LocalisedString
	return {key, count, list[count], table.unpack(list, 1, count - 1)}
end
---@param list LocalisedString[]
function Locale.or_list(list)
	return listify("locale-util.or-list", list)
end
---@param list LocalisedString[]
function Locale.and_list(list)
	return listify("locale-util.and-list", list)
end

---@param condition BuildCondition
function Locale.place_condition(condition)
	local names = condition.names or {condition.name}
	local count = #names

	if count == 1 then
		local prototype = get_entity_or_tile(names[1])
		return {'challenge-tooltip.place-single', prototype.localised_name, condition.count}

	else
		---@type LocalisedString[]
		local localised_list = {}
		for index, name in pairs(names) do
			localised_list[index] = get_entity_or_tile(name).localised_name
		end

		return {'challenge-tooltip.place-multiple', Locale.or_list(localised_list), condition.count}
	end
end

local condition_switch = {
	['build'] = Locale.place_condition,
	['craft'] = Locale.craft_condition,
	['research'] = Locale.research_condition,
	['hold'] = Locale.hold_condition,
	['death'] = Locale.death_condition,
	['equip'] = Locale.equip_condition,
	['custom'] = Locale.custom_condition,
}

---@param condition LuaChallengeCondition
function Locale.condition(condition)
	return condition_switch[condition.type](condition)
end

return Locale