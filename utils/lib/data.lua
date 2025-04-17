local Public = {}

-- DATA UTIL LIBRARY
--=============================================================================

--- Properties starting with underscore are ignored
---@param dst table, destination
---@param src table, source
local function r_copy(dst, src)
    for k, v in pairs(src) do
        if tostring(k):find('^_') ~= 1 then
            if type(v) == 'table' then
                dst[k] = dst[k] or {}
                r_copy(dst[k], src[k])
            else
                dst[k] = src[k]
            end
        end
    end
end

--- Creates a copy of the given prototype, using the additional fields to set new properties
---@param dst table, destination
---@param src table, source
---@return table
Public.merge_prototype = function(dst, src)
    if not (dst and type(dst) == 'table' and src and type(src) == 'table') then
        return error('Could not merge prototype')
    end

    local base = table.deepcopy(dst)

    base.next_upgrade = nil -- allows creating tiered entities

    r_copy(base, src)

    if base.minable and base.minable.result then
        base.minable.result = base.p_name
    end

    return base
end

return Public
