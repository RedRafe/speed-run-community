local string = _G.string

-- STRING UTIL LIBRARY
--=============================================================================

---@param text string
---@param start string
string.starts_with = function(text, start)
    return text:sub(1, #start) == start
end

---@param text string
---@param ending string
string.ends_with = function(text, ending)
    return ending == '' or text:sub(-#ending) == ending
end

---@param text string
---@param sub string
string.contains = function(text, sub)
    return text:find(sub, 1, true) ~= nil
end

---@param s string
---@param old string
---@param new string
string.replace = function(s, old, new)
    local search_start_idx = 1

    while true do
        local start_idx, end_idx = s:find(old, search_start_idx, true)
        if not start_idx then
            break
        end

        local postfix = s:sub(end_idx + 1)
        s = s:sub(1, (start_idx - 1)) .. new .. postfix

        search_start_idx = -1 * postfix:len()
    end

    return s
end

--- Multiply String Value
---@param text string
---@param coefficient number
string.msv = function(text, coefficient)
    if not text then
        return nil
    end
    local n, _ = text:gsub('%a', '')
    local s = text:match('%a+')
    return tostring(tonumber(n) * coefficient) .. s
end

---@param text string
string.find_base = function(text)
    return text:gsub('^sp%-([1-9][0-9]?)%-', '')
end

--- Removes whitespace from the start and end of the string.
--- http://lua-users.org/wiki/StringTrim
---@param text texting
string.trim = function(text)
    return text:gsub('^%s*(.-)%s*$', '%1')
end

string.capital_letter = function(text)
    return (text:gsub("^%l", string.upper))
end

return string
