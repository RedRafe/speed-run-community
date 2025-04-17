-- created by: grilledham
-- source: https://github.com/Refactorio/RedMew/blob/develop/utils/token.lua
-- ========================================================================= --

local Token = {}

local tokens = {}
local counter = 0

--- Assigns a unique id for the given var.
--- This function cannot be called after on_init() or on_load() has run as that is a desync risk.
--- Typically this is used to register functions, so the id can be stored in the global table
--- instead of the function. This is because closures cannot be safely stored in the global table.
---@param  var any
---@return number, the unique token for the variable.
Token.register = function(var)
    counter = counter + 1
    tokens[counter] = var

    return counter
end

--- Returns current counter
--- Helpful for recurrent functions
Token.get_counter = function()
    return counter
end

Token.get = function(token_id)
    return tokens[token_id]
end

storage.__tokens = {}

Token.register_global = function(var)
    if type(var) == 'function' then
        return error('Cannot register function to the global table')
    end

    local c = #storage.__tokens + 1
    storage.__tokens[c] = var

    return c
end

Token.get_global = function(token_id)
    return storage.__tokens[token_id]
end

Token.set_global = function(token_id, var)
    if type(var) == 'function' then
        return error('Cannot register function to the global table')
    end

    storage.__tokens[token_id] = var
end

local uid_counter = 100

Token.uid = function()
    uid_counter = uid_counter + 1

    return uid_counter
end

return Token
