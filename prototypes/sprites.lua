local function make_sprite(name, size, p)
    local sprite = {
        type = 'sprite',
        name = name,
        filename = '__speed-run-community__/graphics/icons/' .. name .. '.png',
        size = size or 64,
        flags = { 'not-compressed' },
    }
    for k, v in pairs(p or {}) do
        sprite[k] = v
    end
    return sprite
end

data:extend({
    make_sprite('speedrun', 200),
    make_sprite('bingo'),
    make_sprite('editor'),
    make_sprite('game'),
    make_sprite('roll'),
    make_sprite('start'),
    make_sprite('stats'),
    make_sprite('stop'),
    make_sprite('team'),
    make_sprite('undo'),
})