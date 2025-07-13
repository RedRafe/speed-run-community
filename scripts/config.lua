local Challenges = require 'scripts.modules.challenge-utils'
local icon = Challenges.icon
local format = string.format

return {
    force_name_map = {
        player = 'Spectator',
        west = 'West',
        east = 'East'
    },
    game_state = {
        initializing = 0,
        picking      = 1,
        preparing    = 2,
        playing      = 3,
        finished     = 4,
        resetting    = 5,
    },
    permission_group = {
        admin   = 'admin',
        default = 'default',
        jail    = 'jail',
        player  = 'player',
    },
    spawn_point = {
        player = { x =    0, y = 0 },
        west   = { x = -320, y = 0 },
        east   = { x =  320, y = 0 },
    },
    color = {
        west = { 140, 140, 252 },
        east = { 252, 084, 084 },
        player = {111, 111, 111 },
    },
    challenges = Challenges.process{
        -- Build
        { caption = 'Light Up!', tooltip = 'Place 3 lamps.', condition = { type = 'build', name = 'small-lamp', count = 3 } },
        { caption = 'Landfiller', tooltip = 'Place 200 landfill.', condition = { type = 'build', name = 'landfill', count = 200 } },
        { caption = 'Burner Metropolis', tooltip = 'Place 200 burner mining drills.', condition = { type = 'build', name = 'burner-mining-drill', count = 200 } },
        { caption = 'Oil Explorer', tooltip = 'Place 30 pumpjacks.', condition = { type = 'build', name = 'pumpjack', count = 30 } },
        { caption = 'Silo Foundation', tooltip = 'Place 1,000 concrete.', condition = { type = 'build', name = 'concrete', count = 1000 } },
        { caption = 'Steel Upgrade', tooltip = 'Build 144 steel furnaces.', condition = { type = 'build', name = 'steel-furnace', count = 144 } },
        { caption = 'Lab Rush', tooltip = 'Have 100 labs researching at once.', icon = icon('entity/lab', 100) },
        { caption = 'Botlap', tooltip = 'Place a locomotive with bots.', icon = icon('entity/locomotive'), condition = { type = 'custom', name = 'botlap' } },
        { caption = 'Solaris', tooltip = 'Place and connect 100 solar panels.', icon = icon('entity/solar-panel', 100) },
        { caption = 'Rollercoaster', tooltip = 'Build a rail loop around your starter lake and complete 5 train laps.', icon = icon('entity/curved-rail-a') },
        { caption = 'Fortified!', tooltip = 'Surround yourself with 8 walls.', icon = icon('entity/stone-wall', 8) },
        { caption = 'Gatekeeper', tooltip = 'Build one gate that\'s 250 tiles long.', icon = icon('entity/gate', 250), condition = { type = 'custom', name = 'long_gate', data = { count = 250 } } },
        { caption = 'Pumped Dry', tooltip = 'Place pumps on every usable position of your starter lake and connect their outputs.', icon = icon('entity/offshore-pump') },
        { caption = 'Copper Pavement', tooltip = 'Cover a copper patch with stone bricks.', icon = icon('entity/copper-ore') },
        { caption = 'Freight Train', tooltip = 'Build a train with 30 wagons.', icon = icon('entity/cargo-wagon', 30), condition = { type = 'custom', name = 'long_train', data = { count = 30 } } },
        {
            { caption = 'Rock Power', tooltip = 'Connect power to 20 rocks.', icon = icon('entity/big-rock', 20) },
            { caption = 'Total Rock Power', tooltip = 'Connect power to 100 rocks.', icon = icon('entity/huge-rock', 100) },
        },
        { caption = 'Heart-Shaped Box', tooltip = 'Place 200 wooden chests in a heart shape.', icon = icon('entity/wooden-chest', 200) },
        { caption = 'Looping Louie', tooltip = 'Build 100 separate belt loops.', icon = icon('entity/transport-belt', 100) },
        { caption = 'Assembly Line Upgrade', tooltip = 'Upgrade all assemblers to tier 2.', icon = icon('entity/assembling-machine-2') },

        -- Craft
        { caption = 'Uranium Touch', tooltip = 'Craft one U-238.', condition = { type = 'craft', name = 'uranium-238' } },
        { caption = 'Blue Chips', tooltip = 'Craft 200 processing units.', condition = { type = 'craft', name = 'processing-unit', count = 200 } },
        { caption = 'LDS Factory', tooltip = 'Craft 200 low-density structures.', condition = { type = 'craft', name = 'low-density-structure', count = 200 } },
        { caption = 'Rocket Fuel', tooltip = 'Craft 200 rocket fuel.', condition = { type = 'craft', name = 'rocket-fuel', count = 200 } },
        { caption = 'Shotgun Lord', tooltip = 'Craft 50 shotguns.', condition = { type = 'craft', name = 'shotgun', count = 50 } },
        { caption = 'Red Supremacy', tooltip = 'Craft 200 fast underground belts.', condition = { type = 'craft', name = 'fast-underground-belt', count = 200 } },
        { caption = 'Bulk Inserters', tooltip = 'Craft 200 bulk inserters.', condition = { type = 'craft', name = 'bulk-inserter', count = 200 } },
        { caption = 'Mining Industry', tooltip = 'Mine 10,000 copper ore.', condition = { type = 'craft', name = 'copper-ore', count = 10000 } },
        { caption = 'Laser Turret Factory', tooltip = 'Craft 50 laser turrets.', condition = { type = 'craft', name = 'laser-turret', count = 100 }, weight = 1/3 },

        Challenges.factory('Fast Inserter', 'Craft %d fast inserters', 'fast-inserter', { 250, 1000 }),
        Challenges.factory('Rail', 'Craft %d rails', 'rail', { 500, 2500, 5000 }),
        Challenges.factory('Big Electric Pole', 'Craft %d big electric poles.', 'big-electric-pole', { 50, 250, 500 }),
        Challenges.factory('Train Stop', 'Craft %d train stops.', 'train-stop', { 50, 250, 500 } ),
        Challenges.factory('Car', 'Craft %d cars.', 'car', { 10, 50, 250 } ),
        Challenges.factory('Refined Hazard Concrete', 'Craft %d refined hazard concrete.', 'refined-hazard-concrete', { 1000, 2500, 5000 } ),
        Challenges.factory('Accumulator', 'Craft %d accumulators.', 'accumulator', { 500, 1000 } ),
        Challenges.factory('Module', 'Craft %d modules.',
            { 'speed-module', 'speed-module-2', 'speed-module-3', 'efficiency-module', 'efficiency-module-2', 'efficiency-module-3', 'productivity-module', 'productivity-module-2', 'productivity-module-3' },
            { 50, 250 }
        ),
        Challenges.factory('Flamethrower Turret', 'Craft %d flamethrower turrets.', 'flamethrower-turret', { 25, 100 } ),
        Challenges.factory('Rocket', 'Craft %d rockets.', 'rocket', { 500, 2500 } ),
        Challenges.factory('Land Mine', 'Craft %d land mines.', 'land-mine', { 1000, 5000 } ),
        Challenges.factory('Flamethrower Ammo', 'Craft %d flamethrower ammo.', 'flamethrower-ammo', { 500, 2500 } ),
        Challenges.factory('Grenade', 'Craft %d grenades.', 'grenade', { 50, 250, 1000 } ),
        Challenges.factory('Defender Capsule', 'Craft %d defender capsules.', 'defender-capsule', { 10, 50, 250 } ),
        Challenges.factory('Submachine Gun', 'Craft %d submachine guns.', 'submachine-gun', { 100, 250 } ),
        Challenges.factory('Programmable Speaker', 'Craft %d programmable speakers.', 'programmable-speaker', { 250, 1000 } ),
        Challenges.factory('Fast Splitter', 'Craft %d fast splitters.', 'fast-splitter', { 100, 250 } ),
        Challenges.factory('Pump', 'Craft %d pumps.', 'pump', { 250, 1000 } ),
        Challenges.factory('Electric Engine', 'Craft %d electric engines.', 'electric-engine-unit', { 250, 1000 } ),
        Challenges.factory('Oil Refinery', 'Craft %d oil refineries.', 'oil-refinery', { 50, 200 } ),
        Challenges.factory('Solid Fuel', 'Craft %d solid fuel.', 'solid-fuel', { 500, 2000, 10000 } ),
        Challenges.factory('Heavy Armor', 'Craft %d heavy armors.', 'heavy-armor', { 1, 5, 10 } ),

        -- Research
        { caption = 'Steelaxe%', tooltip = 'Unlock Steel Axe.', condition = { type = 'research', name = 'steel-axe' } },
        { caption = 'Productive Mining', tooltip = 'Unlock Mining Productivity 1.', condition = { type = 'research', name = 'mining-productivity-1' } },
        { caption = 'Bullet Beginner', tooltip = 'Research Projectile Damage 1 + Shooting Speed 1.', condition = { type = 'research', names = { 'physical-projectile-damage-1', 'weapon-shooting-speed-1' } } },
        { caption = 'Bullet Specialist', tooltip = 'Research Projectile Damage 3 + Shooting Speed 3.', condition = { type = 'research', names = { 'physical-projectile-damage-3', 'weapon-shooting-speed-3' } } },
        { caption = 'POWER IS FINE', tooltip = 'After researching \'Electric Energy Distribution 1\', have low power for a total of 5 minutes.', icon = icon('utility/electricity_icon') },

        -- Hold
        { caption = 'Fishing Industry', tooltip = 'Collect 200 fish.', condition = { type = 'hold', name = 'raw-fish', count = 200 } },
        { caption = 'Vat of Acid', tooltip = 'Collect 100 sulfuric acid barrels.', condition = { type = 'hold', name = 'sulfuric-acid-barrel', count = 100 } },
        { caption = 'Sommelier', tooltip = 'Collect one of each barrel type.', condition = { type = 'hold', names = { 'water-barrel', 'crude-oil-barrel', 'petroleum-gas-barrel', 'light-oil-barrel', 'heavy-oil-barrel', 'lubricant-barrel', 'sulfuric-acid-barrel'} } },
        { caption = 'Inserter Collector', tooltip = 'Collect one of each inserter type.', condition = { type = 'hold', names = { 'burner-inserter', 'inserter', 'long-handed-inserter', 'fast-inserter', 'bulk-inserter' } } },
        { caption = 'Comfort Coal', tooltip = 'Fill your inventory with coal.', icon = icon('item/coal'), condition = { type = 'custom', name = 'full_inventory_coal' } },
        { caption = 'Inventory Variety', tooltip = 'Fill your inventory with a different item in every slot.', icon = icon('technology/toolbelt'), condition = { type = 'custom', name = 'full_inventory_unique' } },

        -- Death
        { caption = 'RIP', tooltip = 'Die once in any way.', condition = { type = 'death', name = 'character' } },
        { caption = 'Bit the dust', tooltip = 'Die once in any way except to biters/worms/spitters.', icon = icon('entity/character')},
        { caption = 'Crash Test', tooltip = 'Destroy a car by impact.', condition = { type = 'death', name = 'car', damage_type = 'impact' }},
        { caption = 'Pole Wrecker', tooltip = 'Destroy 150 power poles.', condition = { type = 'death', names = { 'small-electric-pole', 'medium-electric-pole', 'big-electric-pole', 'substation' }, count = 150 } },
        { caption = 'Turret Buster', tooltip = 'Destroy 5 gun turrets.', condition = { type = 'death', name = 'gun-turret', count = 5 } },
        { caption = 'Bug Check', tooltip = 'Kill 1 enemy spawner.', condition = { type = 'death', names = {'biter-spawner', 'spitter-spawner'}, enemy = true } },
        { caption = 'Biter Extinction', tooltip = 'Kill 25 enemy spawners.', condition = { type = 'death', names = {'biter-spawner', 'spitter-spawner'}, count = 25, enemy = true } },
        { caption = 'Roadkill', tooltip = 'Die by getting run over by a tank.', icon = icon('entity/tank'), condition = { type = 'death', name = 'character', cause_name = 'tank' } },
        { caption = 'Cliffhanger', tooltip = 'Destroy a cliff.', icon = icon('utility/cliff_deconstruction_enabled_modifier_icon'), condition = { type = 'custom', name = 'destroy_cliff' } },
        { caption = 'Shotgun Sheriff', tooltip = 'Kill 100 biters with shotgun shells.', icon = icon('entity/small-biter', 100), condition = { type = 'custom', name = 'shotgun_kills', data = { count = 100 } } },
        { caption = 'Rocket Launcher', tooltip = 'Kill 10 enemy spawners with rockets.', icon = icon('entity/biter-spawner', 10), },
        { caption = 'Deforestation', tooltip = 'Destroy 1,000 trees with poison capsules.', icon = icon('entity/tree-01', 1000), },
        { caption = 'Loan Repayment', tooltip = format('Destroy a chest containing the same items you started with.\n(%s)', Challenges.starting_items()), icon = icon('item/stone-furnace') },

        -- Equip
        { caption = 'Fully Equipped', tooltip = 'Wear modular armor with a fill equipment grid.', condition = { type = 'custom', name = 'full_modular_grid' }, icon = icon('item/modular-armor') },

        -- Custom
        { caption = 'Fish Catcher', tooltip = 'Catch a fish with an inserter.', icon = icon('entity/inserter') },
        { caption = 'Pyromaniac', tooltip = 'Use a flamethrower.', icon = icon('item/flamethrower') },
        { caption = 'Chestplosion', tooltip = 'Cover a stone patch with dropped items.', icon = icon('entity/stone') },
        { caption = 'Lube Up', tooltip = 'Fill a fluid wagon with lubricant.', icon = icon('entity/fluid-wagon') },
        { caption = 'Perfect Mining', tooltip = 'Cover an entire coal patch with electric drills that don\'t overlap.', icon = icon('item/coal') },
        { caption = 'Ironception', tooltip = 'Fill an iron chest with iron chests.', icon = icon('entity/iron-chest'), condition = { type = 'custom', name = 'full_iron_chest', data = { chests = {} } } },
        { caption = 'Accumulator Test', tooltip = 'Fully charge and discharge 250 accumulators.', icon = icon('entity/accumulator', 250) },
        { caption = 'Radar Network', tooltip = 'Power 50 radars with full energy satisfaction.', icon = icon('entity/radar', 50) },
        { caption = 'Belt Loop Adventure', tooltip = 'Ride a belt loop around your starter lake without moving manually.', icon = icon('item/transport-belt') },
        { caption = 'Red Ammo Belt', tooltip = 'Fill a belt loop with 500 rounds of Piercing rounds magazines.', icon = icon('item/piercing-rounds-magazine', 500) },
        { caption = 'Crypto Farm', tooltip = 'Use at least 80 MW for one minute.', icon = icon('utility/electricity_icon_unplugged', 80) }, -- icon change
        { caption = 'Joyride', tooltip = 'Stay in a car for 3 minutes without exiting.', icon = icon('entity/car', 3), condition = { type = 'custom', name = "stay_in_car", data = { ticks = 3*60*60, players = {} } } },
        { caption = 'Display of Affection', tooltip = 'Write “I❤️FACTORIO” using the signal icons of 10 display panels.', icon = icon('entity/display-panel') },
        { caption = 'Catch Me If You Can', tooltip = 'Get chased by 50 biters at once.', icon = icon('entity/small-biter', 50) },
        { caption = 'Collector\'s Chest', tooltip = 'Fill a wooden chest with full stacks of different items.', icon = icon('entity/wooden-chest'), condition = { type = 'custom', name = 'full_chest_unique', data = { name = 'wooden-chest', chests = {} } } },
        { caption = 'Collector\'s Vault', tooltip = 'Fill an iron chest with full stacks of different items.', icon = icon('entity/iron-chest'), condition = { type = 'custom', name = 'full_chest_unique', data = { name = 'iron-chest', chests = {} } } },
        { caption = 'Collector\'s Sanctum', tooltip = 'Fill a steel chest with full stacks of different items.', icon = icon('entity/steel-chest'), condition = { type = 'custom', name = 'full_chest_unique', data = { name = 'steel-chest', chests = {} } } },
        { caption = 'Beacon King', tooltip = 'Have 12 machines running under the influence of a beacon.', icon = icon('entity/beacon') },
        { caption = 'Shooting Practice', tooltip = 'Shoot 500 yellow ammo.', icon = icon('item/firearm-magazine', 500) },
        { caption = 'Highway to Hell', tooltip = 'Connect 3 separate biter bases to the starter lake with stone bricks.', icon = icon('item/stone-brick', 3) },
    }
}
