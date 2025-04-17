---@class Buckets
local Buckets = {}
Buckets.__index = Buckets

script.register_metatable('Buckets', Buckets)

local DEFAULT_INTERVAL = 60

---@param interval? number
function Buckets.new(interval)
    return setmetatable({
        list = {},
        interval = interval or DEFAULT_INTERVAL
    }, Buckets)
end

---@param self Buckets
---@param id number|string
---@param data any
function Buckets:add(id, data)
    local bucket_id = id % self.interval
    self.list[bucket_id] = self.list[bucket_id] or {}
    self.list[bucket_id][id] = data or {}
end

---@param self Buckets
---@param id number|string
function Buckets:get(id)
    if not id then
        return
    end
    local bucket_id = id % self.interval
    return self.list[bucket_id] and self.list[bucket_id][id]
end

---@param self Buckets
---@param id number|string
function Buckets:remove(id)
    if not id then
        return
    end
    local bucket_id = id % self.interval
    if self.list[bucket_id] then
        self.list[bucket_id][id] = nil
    end
end

---@param self Buckets
---@param id number|string
function Buckets:get_bucket(id)
    local bucket_id = id % self.interval
    self.list[bucket_id] = self.list[bucket_id] or {}
    return self.list[bucket_id]
end

-- Redistributes current buckets content over a new time interval
---@param self Buckets
---@param new_interval number
function Buckets:reallocate(new_interval)
    new_interval = new_interval or DEFAULT_INTERVAL
    if self.interval == new_interval then
        return
    end
    local tmp = {}

    -- Collect data from existing buckets
    for b_id = 0, self.interval - 1 do
        for id, data in pairs(self.list[b_id] or {}) do
            tmp[id] = data
        end
    end

    -- Clear old buckets
    self.list = {}

    -- Update interval and reinsert data
    self.interval = new_interval
    for id, data in pairs(tmp) do
        self:add(id, data)
    end
end

-- Distributes a table's content over a time interval
---@param tbl table
---@param interval? number
function Buckets.migrate(tbl, interval)
    local bucket = Buckets.new(interval)
    for id, data in pairs(tbl) do
        bucket:add(id, data)
    end
    return bucket
end

return Buckets
