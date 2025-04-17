local ItemStatistics = {}
ItemStatistics.__index = ItemStatistics

script.register_metatable('ItemStatistics', ItemStatistics)

---@param args table, name field is mandatory
ItemStatistics.new = function(args)
    local proto = args.name and prototypes.item[args.name] or prototypes.fluid[args.name]
    assert(proto, 'No item prototype for '..(args.name or 'nil'))

    local obj = {
        name = args.name,
        type = args.type,
        localised_name = proto.localised_name,
        sprite = args.type .. '/' .. args.name,
        can_place = false,

        produced = args.produced or 0,
        consumed = args.consumed or 0,
        placed   = args.placed   or 0,
        lost     = args.lost     or 0,
        sent     = args.sent     or 0,
        stored   = args.stored   or 0,
    }

    if obj.type == 'item' then
        obj.can_place = (proto.place_result or proto.place_as_tile_result) ~= nil
    end

    return setmetatable(obj, ItemStatistics)
end

function ItemStatistics:get_stored()
    self.stored = self.produced - self.consumed - self.placed - self.lost - self.sent
    return self.stored
end

function ItemStatistics:__add(other)
    self.produced = self.produced + other.produced
    self.consumed = self.consumed + other.consumed
    self.placed   = self.placed   + other.placed
    self.lost     = self.lost     + other.lost
    self.sent     = self.sent     + other.sent

    self:get_stored()

    return self
end

function ItemStatistics:__sub(other)
    self.produced = self.produced - other.produced
    self.consumed = self.consumed - other.consumed
    self.placed   = self.placed   - other.placed
    self.lost     = self.lost     - other.lost
    self.sent     = self.sent     - other.sent

    self:get_stored()

    return self
end

return ItemStatistics
