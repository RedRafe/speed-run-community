data:extend({
    {
        type = 'bool-setting',
        name = 'bingo_show_claimed',
        setting_type = 'runtime-per-user',
        default_value = false,
        order = '001'
    },
    {
        type = 'bool-setting',
        name = 'bingo_show_on_top',
        setting_type = 'runtime-per-user',
        default_value = true,
        ortder = '002'
    },
    {
        type = 'int-setting',
        name = 'bingo_show_challenges',
        setting_type = 'runtime-per-user',
        default_value = 5,
        minimum_value = 1,
        maximum_value = 10,
        order = '003'
    },
})
