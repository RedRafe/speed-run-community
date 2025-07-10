local table = _G.table

-- TABLE UTIL LIBRARY
-- ============================================================================

local random = math.random
local floor = math.floor
local remove = table.remove
local tonumber = tonumber
local pairs = pairs
local table_size = table_size

-- Add table-related functions that exist in base factorio/util to the 'table' table
require 'util'

--- Searches a table to remove a specific element without an index
---@param tbl table, to search
---@param element string|number|boolean, element to search for
table.remove_element = function(tbl, element)
    if not tbl or not element then
        return
    end
    for k, v in pairs(tbl) do
        if v == element then
            remove(tbl, k)
            break
        end
    end
end


--- Searches a table to remove a specific element without an index, works with non-primitives
--- Use for removal of nested tables. For primitives, use table.remove_element instead which is faster.
---@param tbl table, to search
---@param element any, element to search for
table.remove_any = function(tbl, element)
    if not tbl or not element then
        return
    end
    for k, v in pairs(tbl) do
        if table.compare(v, element) then
            remove(tbl, k)
            break
        end
    end
end

--- Removes an item from an array in O(1) time.
--- The catch is that fast_remove doesn't guarantee to maintain the order of items in the array.
---@param tbl table, arrayed table
---@param index number, must be >= 0. The case where index > #tbl is handled.
table.fast_remove = function(tbl, index)
    local count = #tbl
    if index > count then
        return
    elseif index < count then
        tbl[index] = tbl[count]
    end

    tbl[count] = nil
end

--- Adds the contents of table t2 to table t1
---@param t1 table, to insert into
---@param t2 table, to insert from
table.add_all = function(t1, t2)
    for k, v in pairs(t2) do
        if tonumber(k) then
            t1[#t1 + 1] = v
        else
            t1[k] = v
        end
    end
end

--- Checks if a table contains an element
---@param t table
---@param e any, table element
---@return any, the index of the element or nil
table.index_of = function(t, e)
    for k, v in pairs(t) do
        if v == e then
            return k
        end
    end
    return nil
end
local index_of = table.index_of

--- Checks if the arrayed portion of a table contains an element
---@param t table
---@param e any, table element
---@return number|nil, the index of the element or nil
table.index_of_in_array = function(t, e)
    for i = 1, #t do
        if t[i] == e then
            return i
        end
    end
    return nil
end
local index_of_in_array = table.index_of_in_array

--- Checks if a table contains an element
---@param t table
---@param e any, table element
---@return boolean, indicating success
table.contains = function(t, e)
    return index_of(t, e) and true or false
end

--- Checks if the arrayed portion of a table contains an element
---@param t table
---@param e any, table element
---@return boolean, indicating success
table.array_contains = function(t, e)
    return index_of_in_array(t, e) and true or false
end

--- Adds an element into a specific index position while shuffling the rest down
---@param t table, to add into
---@param index number, the position in the table to add to
---@param element any, to add to the table
table.set = function(t, index, element)
    local i = 1
    for k in pairs(t) do
        if i == index then
            t[k] = element
            return nil
        end
        i = i + 1
    end
    error('Index out of bounds', 2)
end

--- Returns an array of keys for a table.
---@param tbl table
table.keys = function(tbl)
    local n = 1
    local keys = {}

    for k in pairs(tbl) do
        keys[n] = k
        n = n + 1
    end

    return keys
end

--- Chooses a random entry from a table
--- because this uses math.random, it cannot be used outside of events
---@param t table
---@param key boolean, to indicate whether to return the key or value
---@return any, a random element of table t
table.get_random_dictionary_entry = function(t, key)
    local target_index = random(1, table_size(t))
    local count = 1
    for k, v in pairs(t) do
        if target_index == count then
            if key then
                return k
            else
                return v
            end
        end
        count = count + 1
    end
end

--- Chooses a random entry from a weighted table
--- because this uses math.random, it cannot be used outside of events
---@param weighted_table table, of tables with items and their weights
---@param item_index number, of the index of items, defaults to 1
---@param weight_index number, of the index of the weights, defaults to 2
---@return any, table element
table.get_random_weighted = function(weighted_table, item_index, weight_index)
    local total_weight = 0
    item_index = item_index or 1
    weight_index = weight_index or 2

    for _, w in pairs(weighted_table) do
        total_weight = total_weight + w[weight_index]
    end

    local index = random() * total_weight
    local weight_sum = 0
    for _, w in pairs(weighted_table) do
        weight_sum = weight_sum + w[weight_index]
        if weight_sum >= index then
            return w[item_index]
        end
    end
end

--- Returns a table with % chance values for each item of a weighted_table
---@param weighted_table table, of tables with items and their weights
---@param weight_index number, of the index of the weights, defaults to 2
table.get_random_weighted_chances = function(weighted_table, weight_index)
    local total_weight = 0
    weight_index = weight_index or 2
    for _, v in pairs(weighted_table) do
        total_weight = total_weight + v[weight_index]
    end
    local chance_table = {}
    for k, v in pairs(weighted_table) do
        chance_table[k] = v[weight_index] / total_weight
    end
    return chance_table
end

--- Creates a fisher-yates shuffle of a sequential number-indexed table
--- because this uses math.random, it cannot be used outside of events if no rng is supplied
--- from: http://www.sdknews.com/cross-platform/corona/tutorial-how-to-shuffle-table-items
---@param t table, to shuffle
table.shuffle_table = function(t, rng)
    local rand = rng or math.random
    local iterations = #t
    if iterations == 0 then
        error('Not a sequential table')
        return
    end
    local j

    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

--- Clears all existing entries in a table
---@param t table, to clear
---@param array boolean, to indicate whether the table is an array or not
table.clear_table = function(t, array)
    if array then
        for i = 1, #t do
            t[i] = nil
        end
    else
        for i in pairs(t) do
            t[i] = nil
        end
    end
end

--[[
	Returns the index where t[index] == target.
	If there is no such index, returns a negative value such that bit32.bnot(value) is
	the index that the value should be inserted to keep the list ordered.
	t must be a list in ascending order for the return value to be valid.

	Usage example:
	local t = {1,3,5,7,9}
	local x = 5
	local index = table.binary_search(t, x)
	if index < 0 then
		game.print('value not found, smallest index where t[index] > x is: ' .. bit32.bnot(index))
	else
		game.print('value found at index: ' .. index)
	end
]]
table.binary_search = function(t, target)
    --For some reason bit32.bnot doesn't return negative numbers so I'm using ~x = -1 - x instead.
    local lower = 1
    local upper = #t

    if upper == 0 then
        return -2 -- ~1
    end

    repeat
        local mid = floor((lower + upper) * 0.5)
        local value = t[mid]
        if value == target then
            return mid
        elseif value < target then
            lower = mid + 1
        else
            upper = mid - 1
        end
    until lower > upper

    return -1 - lower -- ~lower
end

--- Takes a table and returns the number of entries in the table. (Slower than #table, faster than iterating via pairs)
table.size = table_size

--- Merges multiple tables. Tables later in the list will overwrite entries from tables earlier in the list.
--- Ex. merge({{1, 2, 3}, {[2] = 0}, {[3] = 0}}) will return {1, 0, 0}
---@param tables table, takes a table of tables to merge
---@return table, a merged table
table.merge = util.merge

--- Determines if two tables are structurally equal.
--- Notice: tables that are LuaObjects or contain LuaObjects won't be compared correctly, use == operator for LuaObjects
---@param tbl1 table
---@param tbl2 table
---@return boolean
table.equals = table.compare

return table
