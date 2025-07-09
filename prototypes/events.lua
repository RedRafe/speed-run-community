local events = {
    'on_map_init',
    'on_map_reset',
    'on_match_started',
    'on_match_finished',
    'on_match_picking_phase',
    'on_match_preparation_phase',
}

for _, event_name in pairs(events) do
    data:extend({
        {
            type = 'custom-event',
            name = event_name
        }
    })
end

data:extend({
    {
        type = 'custom-input',
        name = 'open_player_menu',
        key_sequence = 'SHIFT + B',
    }
})