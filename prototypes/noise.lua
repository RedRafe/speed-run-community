local function mirror_noise(expression)
    return expression:gsub('x = x', 'x = abs(x)')
end

local NE = data.raw['noise-expression']
local NF = data.raw['noise-function']

--- Water
--NF['water_base'].parameters = {'max_elevation', 'influence'}

--- Enemies
NF['enemy_autoplace_base'].expression = mirror_noise(NF['enemy_autoplace_base'].expression)
NE['enemy_base_probability'].expression = mirror_noise(NE['enemy_base_probability'].expression)
NE['enemy_base_probability'].local_functions.blob.expression = mirror_noise(NE['enemy_base_probability'].local_functions.blob.expression)

--- Resources
NF['resource_autoplace_all_patches'].local_expressions.blobs0 = mirror_noise(NF['resource_autoplace_all_patches'].local_expressions.blobs0)
NF['resource_autoplace_all_patches'].local_expressions.starting_patches = mirror_noise(NF['resource_autoplace_all_patches'].local_expressions.starting_patches)
NF['resource_autoplace_all_patches'].local_expressions.regular_patches = mirror_noise(NF['resource_autoplace_all_patches'].local_expressions.regular_patches)

--- Rocks
NE['rock_noise'].expression = mirror_noise(NE['rock_noise'].expression)

--- Trees
for _, tree in pairs{
    'tree_01',
    'tree_02',
    'tree_02_red',
    'tree_03',
    'tree_04',
    'tree_05',
    'tree_06',
    'tree_06_brown',
    'tree_07',
    'tree_08',
    'tree_08_brown',
    'tree_08_red',
    'tree_09',
    'tree_09_brown',
    'tree_09_red',
    'tree_02',
} do NE[tree].expression = mirror_noise(NE[tree].expression) end
NE['tree_dead_desert'].local_expressions.tree_noise = mirror_noise(NE['tree_dead_desert'].local_expressions.tree_noise)
NE['tree_dead_desert'].local_expressions.desert_noise = mirror_noise(NE['tree_dead_desert'].local_expressions.desert_noise)

--- Decoratives
NF['rpi'].expression = mirror_noise(NF['rpi'].expression)
NF['decorative_mix_noise'].expression = mirror_noise(NF['decorative_mix_noise'].expression)
NE['decorative_knockout'].expression = mirror_noise(NE['decorative_knockout'].expression)

--- Miscellaneous
NE['temperature_basic'].expression = mirror_noise(NE['temperature_basic'].expression)

NE['moisture_noise'].expression = mirror_noise(NE['moisture_noise'].expression)

NE['aux_noise'].expression = mirror_noise(NE['aux_noise'].expression)

NF['make_0_12like_lakes'].expression = mirror_noise(NF['make_0_12like_lakes'].expression)
NF['make_0_12like_lakes'].local_expressions.persistence = mirror_noise(NF['make_0_12like_lakes'].local_expressions.persistence)

NF['finish_elevation'].expression = mirror_noise(NF['finish_elevation'].expression)
NF['finish_elevation'].local_expressions.starting_lake_distance = mirror_noise(NF['finish_elevation'].local_expressions.starting_lake_distance)
NF['finish_elevation'].local_expressions.starting_lake_noise = mirror_noise(NF['finish_elevation'].local_expressions.starting_lake_noise)

NF['elevation_nauvis_function'].local_expressions.starting_lake_distance = mirror_noise(NF['elevation_nauvis_function'].local_expressions.starting_lake_distance)
NF['elevation_nauvis_function'].local_expressions.starting_lake_noise = mirror_noise(NF['elevation_nauvis_function'].local_expressions.starting_lake_noise)

NE['elevation_lakes'].expression = mirror_noise(NE['elevation_lakes'].expression)
NE['elevation_island'].expression = mirror_noise(NE['elevation_island'].expression)
NE['cliffiness_basic'].expression = mirror_noise(NE['cliffiness_basic'].expression)

NE['cliffiness_nauvis'].local_expressions.low_frequency_cliffiness = mirror_noise(NE['cliffiness_nauvis'].local_expressions.low_frequency_cliffiness)

NE['nauvis_persistance'].expression = mirror_noise(NE['nauvis_persistance'].expression)
NE['nauvis_detail'].expression = mirror_noise(NE['nauvis_detail'].expression)
NE['forest_path_billows'].expression = mirror_noise(NE['forest_path_billows'].expression)
NE['tree_small_noise'].expression = mirror_noise(NE['tree_small_noise'].expression)
NE['nauvis_bridge_billows'].expression = mirror_noise(NE['nauvis_bridge_billows'].expression)
NE['nauvis_hills_offset_raw_x'].expression = mirror_noise(NE['nauvis_hills_offset_raw_x'].expression)
NE['nauvis_hills_offset_raw_y'].expression = mirror_noise(NE['nauvis_hills_offset_raw_y'].expression)
NE['nauvis_hills'].expression = mirror_noise(NE['nauvis_hills'].expression)
NE['nauvis_hills_offset'].expression = mirror_noise(NE['nauvis_hills_offset'].expression)
NE['nauvis_hills_cliff_level'].expression = mirror_noise(NE['nauvis_hills_cliff_level'].expression)
NE['nauvis_macro'].expression = mirror_noise(NE['nauvis_macro'].expression)

NF['noise_layer_noise'].expression = mirror_noise(NF['noise_layer_noise'].expression)
NF['random'].expression = mirror_noise(NF['random'].expression)
NF['random_penalty_at'].expression = mirror_noise(NF['random_penalty_at'].expression)
NF['random_penalty_between'].expression = mirror_noise(NF['random_penalty_between'].expression)
NF['random_penalty_inverse'].expression = mirror_noise(NF['random_penalty_inverse'].expression)
NF['quick_multioctave_noise_persistence'].expression = mirror_noise(NF['quick_multioctave_noise_persistence'].expression)
NF['amplitude_corrected_multioctave_noise'].expression = mirror_noise(NF['amplitude_corrected_multioctave_noise'].expression)

NE['distance'].expression = mirror_noise(NE['distance'].expression)
NE['x_from_start'].expression = 'distance_from_nearest_point_x(abs(x), y, starting_positions)'
NE['y_from_start'].expression = 'distance_from_nearest_point_y(abs(x), y, starting_positions)'

--NF['spot_at_angle'].local_expressions.delta_y = '-distance * cos(angle_rad) - abs(y) + abs(y_distortion)' --'-distance * cos(angle_rad) - y + y_distortion'
NF['starting_spot_at_angle'].local_expressions.delta_y = '-distance * cos(angle_rad) - abs(y_from_start) + abs(y_distortion)' --'-distance * cos(angle_rad) - y_from_start + y_distortion'
NF['rotate_x'].expression = 'abs(x) * cos(angle_rad) + y * sin(angle_rad)' --'x * cos(angle_rad) + y * sin(angle_rad)'
NF['rotate_y'].expression = 'y * cos(angle_rad) - abs(x) * sin(angle_rad)' --'y * cos(angle_rad) - x * sin(angle_rad)'
--NF['place_every_n'].local_expressions.o_y = 'abs(y) + y_offset' --'y + y_offset'
NF['place_every_n'].expression = 'min(((o_x + o_y * 0.93819) / 1.41983 % abs(x_spacing)) <= 1,((o_x / 4.1875839 - o_y) * 0.913853883 % y_spacing) <= 1)'
