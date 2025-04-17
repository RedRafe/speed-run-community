local math = _G.math

-- MATH UTIL LIBRARY
--=============================================================================

math.sqrt2 = math.sqrt(2)
math.inv_sqrt2 = 1 / math.sqrt2
math.tau = 2 * math.pi

local _abs = math.abs
local _ceil = math.ceil
local _cos = math.cos
local _floor = math.floor
local _log = math.log
local _max = math.max
local _min = math.min
local _sin = math.sin
local _sqrt = math.sqrt
local deg_to_rad = math.tau / 360

local sort = table.sort

--- Rounds math.sin to 7 decimal places
---@param x number
---@return number
math.round_sin = function(x)
    return _floor(_sin(x) * 1e7 + 0.5) / 1e7
end

--- Rounds math.cos to 7 decimal places
---@param x number
---@return number
math.round_cos = function(x)
    return _floor(_cos(x) * 1e7 + 0.5) / 1e7
end

--- Rounds a value to certain number of decimal places (idp)
--- math.round(123456789.12345, 3) --> 123456789.123
---@param value number
---@param idp number
---@return number
math.round = function(value, idp)
    local mult = 10 ^ (idp or 0)
    return _floor(value * mult + 0.5) / mult
end

--- Rounds a value to a specified number of significant figures (sf)
--- math.round_sig(123456789.12345, 3) --> 123000000.0
---@param value number
---@param sf number
---@return number
math.round_sig = function(value, sf)
    if value == 0 then
        return 0
    end
    local mag = 10 ^ (sf - _ceil(_log(value < 0 and -value or value, 10)))
    return _floor(value * mag + 0.5) / mag
end

math.clamp = function(num, min, max)
    if num < min then
        return min
    elseif num > max then
        return max
    else
        return num
    end
end

--- Takes two points and calculates the slope of a line
---@param x1, y1 numbers - coordinates of a point on a line
---@param x2, y2 numbers - coordinates of a point on a line
---@return number - the slope of the line
math.calculate_slope = function(x1, y1, x2, y2)
    return _abs((y2 - y1) / (x2 - x1))
end

--- Calculates the y-intercept of a line
---@param x, y numbers - coordinates of point on line
---@param slope number - the slope of a line
---@return number - the y-intercept of a line
math.calculate_y_intercept = function(x, y, slope)
    return y - (slope * x)
end

math.degrees = function(angle)
    return angle * deg_to_rad
end

--- Get the mean value of an array
---@param tbl number[]
---@return number
math.mean = function(tbl)
    local sum = 0
    local count = #tbl

    if count == 0 then
        return 0
    end

    for i = 1, count do
        sum = sum + tbl[i]
    end

    return sum / count
end
local _mean = math.mean

--- Get the median of an array
---@param tbl number[]
---@return number
math.median = function(tbl)
    local temp = {}
    for _, v in ipairs(tbl) do
        temp[#temp + 1] = v
    end
    sort(temp)
    local count = #temp

    if count == 0 then
        return 0
    end

    if count % 2 == 0 then
        return (temp[count / 2] + temp[count / 2 + 1]) / 2
    else
        return temp[_ceil(count / 2)]
    end
end

--- Get the mode of a table. Returns a table of values.
--- Works on anything (not just numbers)
---@param tbl array of number|string
---@return table
math.mode = function(tbl)
    local counts = {}
    for _, v in pairs(tbl) do
        counts[v] = (counts[v] or 0) + 1
    end

    local biggest_count = 0
    local mode = {}

    for k, v in pairs(counts) do
        if v > biggest_count then
            biggest_count = v
            mode = { k }
        elseif v == biggest_count then
            mode[#mode + 1] = k
        end
    end

    return mode
end

--- Get the standard deviation of a table
---@param tbl number[]
---@return number
math.standard_deviation = function(tbl)
    local m = _mean(tbl)
    local sum = 0
    local count = #tbl

    for i = 1, count do
        local vm = tbl[i] - m
        sum = sum + (vm * vm)
    end

    return _sqrt(sum / (count - 1))
end

--- Get the max and min for a table
---@param tbl number[]
---@return number, number
math.range = function(tbl)
    local max, min = tbl[1], tbl[1]

    for i = 2, #tbl do
        max = _max(max, tbl[i])
        min = _min(min, tbl[i])
    end

    return max, min
end

return math
