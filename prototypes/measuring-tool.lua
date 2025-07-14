data:extend{{
    type = 'selection-tool',
    name = 'measuring-tool',
    icon = '__speed-run-community__/graphics/icons/measuring-tool.png',
    icon_size = 32,
    flags = {"only-in-cursor", "not-stackable", "spawnable"},
    auto_recycle = false,
    hidden = true,
    subgroup = "tool",
    stack_size = 1,
    draw_label_for_cursor_render = true,
    select = {
        border_color = { r=1, g=1, b=1 },
        cursor_box_type = 'multiplayer-entity',
        mode = { 'buildable-type', 'entity-ghost' },
        started_sound = { filename = "__core__/sound/blueprint-select.ogg" },
        ended_sound = { filename = "__core__/sound/blueprint-create.ogg" }
    },
    alt_select = {
        border_color = { r=1, g=1, b=1 },
        cursor_box_type = 'multiplayer-entity',
        mode = { 'any-entity' },
        started_sound = { filename = "__core__/sound/blueprint-select.ogg" },
        ended_sound = { filename = "__core__/sound/blueprint-create.ogg" }
    },
    pick_sound = "__base__/sound/copy-cursor.ogg",
}, {
    type = 'custom-input',
    name = 'measuring-tool',
    key_sequence = 'ALT + M',
    item_to_spawn = 'measuring-tool',
    action = 'spawn-item',
}}