---@class Locale
local Locale = {}

local Entities = prototypes.entity
local Tiles = prototypes.tile
local Items = prototypes.item
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
	return listify('locale-util.or-list', list)
end
---@param list LocalisedString[]
function Locale.and_list(list)
	return listify('locale-util.and-list', list)
end

---@param key string
---@param list LocalisedString[]
---@param count integer
---@return LocalisedString
local function single_or_list_count(key, list, count)
	local list_size = #list

	if list_size == 1 then
		return {key..'-single', list[1], count}
	else
		return {key..'-multiple', Locale.or_list(list), count}
	end
end

---@param condition BuildCondition
function Locale.place_condition(condition)
	local names = condition.names or {condition.name}

	---@type LocalisedString[]
	local localised_list = {}
	for index, name in pairs(names) do
		localised_list[index] = get_entity_or_tile(name).localised_name
	end

	return single_or_list_count('challenge-tooltip.place', localised_list, condition.count)
end

---@param name ItemID|ItemID[]
---@return boolean
local function is_gather(name)
	for _ in pairs(prototypes.get_recipe_filtered{
		{filter = 'has-product-item', elem_filters = {
			{filter = 'name', name = name}
		}}
	}) do
		return false
	end
	return true
end

---@param condition CraftCondition
function Locale.craft_condition(condition)
	local names = condition.names or {condition.name}

	---@type LocalisedString[]
	local localised_list = {}
	for index, name in pairs(names) do
		localised_list[index] = Items[name].localised_name
		-- localised_list[index] = name
	end

	local key = 'challenge-tooltip.craft'
	if is_gather(names) then
		key = 'challenge-tooltip.gather'
	elseif condition.is_production then
		key = 'challenge-tooltip.production'
	end

	return single_or_list_count(key, localised_list, condition.count)
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