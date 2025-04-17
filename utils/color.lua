local Color = {}

local tonumber = tonumber

---@param hex string
local hex2rgb = function(hex)
    hex = hex:gsub('#','')
    return {
        r = tonumber('0x'..hex:sub(1,2)) / 255,
        g = tonumber('0x'..hex:sub(3,4)) / 255,
        b = tonumber('0x'..hex:sub(5,6)) / 255,
        a = tonumber('0x'.. (#hex == 8 and hex:sub(7,8) or 'ff')) / 255
    }
end

Color.hex2rgb = hex2rgb

---@param color string|table
Color.parse = function(color)
    if type(color) == 'string' then
        return hex2rgb(color)
    end

    local norm = 1
    if (color.r and color.r > 1) or (color[1] and color[1] > 1) then
        norm = 255
    end

    return {
        r = (color.r or color[1]) / norm,
        g = (color.g or color[2]) / norm,
        b = (color.b or color[3]) / norm,
        a = color.a or color[4] or 1
    }
end

return Color
