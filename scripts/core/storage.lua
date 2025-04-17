-- created by: grilledham
-- source: https://github.com/Refactorio/RedMew/blob/develop/utils/global.lua
-- modified by: RedRafe
-- ========================================================================= --

local EventCore = require 'scripts.core.event-core'
local Token = require 'scripts.core.token'

local Storage = {}

Storage.subscribe = function(tbl, callback)
    local token = Token.register_global(tbl)

    EventCore.on_load(function()
        callback(Token.get_global(token))
    end)

    return token
end

Storage.subscribe_init = function(tbl, init_handler, callback)
    local token = Token.register_global(tbl)

    EventCore.on_init(function()
        init_handler(tbl)
        callback(tbl)
    end)

    EventCore.on_load(function()
        callback(Token.get_global(token))
    end)

    return token
end

return Storage
