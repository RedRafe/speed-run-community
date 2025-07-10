local Challenges = require 'scripts.modules.challenge-utils'
local icon = Challenges.icon

return {
    force_name_map = {
        player = 'Spectator',
        north = 'West',
        south = 'East'
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
        north  = { x = -320, y = 0 },
        south  = { x =  320, y = 0 },
    },
    color = {
        north = { 140, 140, 252 },
        south = { 252, 084, 084 },
        player = {111, 111, 111 },
    },
    challenges = Challenges.process{
        -- Build
        { caption = 'Light Up!', tooltip = 'Place 3 lamps.', condition = { type = 'build', name = 'small-lamp', count = 3 } },
        { caption = 'Landfiller', tooltip = 'Place 200 landfill.', condition = { type = 'build', name = 'landfill', count = 200 } },
        { caption = 'Burner Metropolis', tooltip = 'Place 200 burner mining drills.', condition = { type = 'build', name = 'burner-mining-drill', count = 200 } },
        { caption = 'Oil Explorer', tooltip = 'Place 30 pumpjacks.', condition = { type = 'build', name = 'pumpjack', count = 30 } },
        { caption = 'Silo Foundation', tooltip = 'Build 1,000 concrete.', condition = { type = 'build', name = 'concrete', count = 1000 } },
        { caption = 'Lab Rush', tooltip = 'Have 100 labs researching.', icon = icon('entity/lab', 100) },
        { caption = 'Botlap', tooltip = 'Build a locomotive with bots.', icon = icon('entity/locomotive'), condition = { type = 'custom', name = 'botlap' } },
        { caption = 'Solaris', tooltip = 'Place and connect 100 solar panels.', icon = icon('entity/solar-panel', 100) },
        { caption = 'Rollercoaster', tooltip = 'Build a rail loop around your starter lake and complete 5 train laps.', icon = icon('entity/curved-rail-a') },
        { caption = 'Fortified!', tooltip = 'Surround yourself with 8 walls.', icon = icon('entity/stone-wall', 8) },
        { caption = 'Steel Upgrade', tooltip = 'Upgrade 150 furnaces to steel furnaces.', icon = icon('entity/steel-furnace', 150) },
        { caption = 'Gatekeeper', tooltip = 'Build one gate that\'s 250 tiles long.', icon = icon('entity/gate', 250), condition = { type = 'custom', name = 'long_gate', data = { count = 250 } } },
        { caption = 'Pumped Dry', tooltip = 'Place pumps on every usable position of your starter lake and connect their outputs.', icon = icon('entity/offshore-pump') },
        { caption = 'Copper Pavement', tooltip = 'Cover a copper patch with stone bricks.', icon = icon('entity/copper-ore') },
        { caption = 'Freight Train', tooltip = 'Construct a train with 30 wagons.', icon = icon('entity/cargo-wagon'), condition = { type = 'custom', name = 'long_train', data = { count = 30 } } },
        {
            { caption = 'Rock Power', tooltip = 'Connect power to 20 rocks.', icon = icon('entity/big-rock', 20) },
            { caption = 'Total Rock Power', tooltip = 'Connect power to 100 rocks.', icon = icon('entity/huge-rock', 100) },
        },
        { caption = 'Heart-Shaped Box', tooltip = 'Place 200 wooden chests in a heart shape.', icon = icon('entity/wooden-chest', 200) },
        { caption = 'Pole Upgrade Program', tooltip = 'Replace all small poles with medium ones.', icon = icon('entity/medium-electric-pole') },
        { caption = 'Looping Louie', tooltip = 'Build 100 separate belt loops.', icon = icon('entity/transport-belt', 100) },
        { caption = 'Assembly Line Upgrade', tooltip = 'Upgrade all assemblers to level 2.', icon = icon('entity/assembling-machine-2') },

        -- Craft
        { caption = 'Uranium Touch', tooltip = 'Craft one U-235.', condition = { type = 'craft', name = 'uranium-235' } },
        { caption = 'Blue Chips', tooltip = 'Craft 200 processing units.', condition = { type = 'craft', name = 'processing-unit', count = 200 } },
        { caption = 'LDS Factory', tooltip = 'Craft 200 low-density structures.', condition = { type = 'craft', name = 'low-density-structure', count = 200 } },
        { caption = 'Rocket Fuel', tooltip = 'Craft 200 rocket fuel.', condition = { type = 'craft', name = 'rocket-fuel', count = 100 } },
        { caption = 'Shotgun Lord', tooltip = 'Craft 50 shotguns.', condition = { type = 'craft', name = 'shotgun', count = 50 } },
        { caption = 'Red Supremacy', tooltip = 'Craft 200 fast underground belts.', condition = { type = 'craft', name = 'fast-underground-belt', count = 200 } },
        { caption = 'Bulk Inserters', tooltip = 'Craft 200 bulk inserters.', condition = { type = 'craft', name = 'bulk-inserter', count = 200 } },
        { caption = 'Paint It Red', tooltip = 'Gather 10,000 copper ore.', condition = { type = 'craft', name = 'copper-ore', count = 10000 } },
        {
            Challenges.factory('Underground Pipe', 'Produce %d underground pipes', 'pipe-to-ground', { 500, 2000 }),
            Challenges.factory('Fast Inserter', 'Produce %d fast inserters', 'fast-inserter', { 250, 1000 }),
            Challenges.factory('Rail', 'Produce %d rails', 'rail', { 500, 2500, 5000 }),
            Challenges.factory('Big Electric Pole', 'Produce %d big electric poles.', 'big-electric-pole', { 50, 250, 500 }),
            Challenges.factory('Train Stop', 'Produce %d train stops.', 'train-stop', { 50, 250, 500 } ),
            Challenges.factory('Car', 'Produce %d cars.', 'car', { 10, 50, 250 } ),
            Challenges.factory('Refined Hazard Concrete', 'Produce %d refined hazard concrete.', 'refined-hazard-concrete', { 1000, 2500, 5000 } ),
            Challenges.factory('Accumulator', 'Produce %d accumulators.', 'accumulator', { 500, 1000 } ),
            Challenges.factory('Module', 'Produce %d modules.',
                { 'speed-module', 'speed-module-2', 'speed-module-3', 'efficiency-module', 'efficiency-module-2', 'efficiency-module-3', 'productivity-module', 'productivity-module-2', 'productivity-module-3' },
                { 50, 250 }
            ),
            Challenges.factory('Flamethrower Turret', 'Produce %d flamethrower turrets.', 'flamethrower-turret', { 25, 100 } ),
            Challenges.factory('Rocket', 'Produce %d rockets.', 'rocket', { 500, 2500 } ),
            Challenges.factory('Land Mine', 'Produce %d land mines.', 'land-mine', { 1000, 5000 } ),
            Challenges.factory('Flamethrower Ammo', 'Produce %d flamethrower ammo.', 'flamethrower-ammo', { 500, 2500 } ),
            Challenges.factory('Grenade', 'Produce %d grenades.', 'grenade', { 50, 250, 1000 } ),
            Challenges.factory('Defender Capsule', 'Produce %d defender capsules.', 'defender-capsule', { 10, 50, 250 } ),
            Challenges.factory('Submachine Gun', 'Produce %d submachine guns.', 'submachine-gun', { 100, 250 } ),
            Challenges.factory('Programmable Speaker', 'Produce %d programmable speakers.', 'programmable-speaker', { 250, 1000 } ),
            Challenges.factory('Fast Splitter', 'Produce %d fast splitters.', 'fast-splitter', { 100, 250 } ),
            Challenges.factory('Electric Pump', 'Produce %d electric pumps.', 'pump', { 250, 1000 } ),
            Challenges.factory('Oil Refinery', 'Produce %d oil refineries.', 'oil-refinery', { 50, 200 } ),
            Challenges.factory('Solid Fuel', 'Produce %d solid fuel.', 'solid-fuel', { 500, 2000, 10000 } ),
        },

        -- Research
        { caption = 'Steel Axe', tooltip = 'Unlock the Steel Axe technology.', condition = { type = 'research', name = 'steel-axe' } },
        { caption = 'Productive Mining', tooltip = 'Unlock Mining Productivity 1.', condition = { type = 'research', name = 'mining-productivity-1' } },
        { caption = 'Bullet Specialist', tooltip = 'Research Projectile Damage 4 + Shooting Speed 4.', condition = { type = 'research', names = { 'physical-projectile-damage-4', 'weapon-shooting-speed-4' } } },
        { caption = 'POWER IS FINE', tooltip = 'Total 5 min of yellow power, after researching \'Electric Energy Distribution 1\'.', icon = icon('utility/electricity_icon') },

        -- Hold
        { caption = 'Fishing Industry', tooltip = 'Collect 200 fish.', condition = { type = 'hold', name = 'raw-fish', count = 200 } },
        { caption = 'Vat of Acid', tooltip = 'Hold 100 sulfuric acid barrels.', condition = { type = 'hold', name = 'sulfuric-acid-barrel', count = 100 } },
        { caption = 'Rainbow Barrels', tooltip = 'Carry one of each barrel type.', condition = { type = 'hold', names = { 'water-barrel', 'crude-oil-barrel', 'petroleum-gas-barrel', 'light-oil-barrel', 'heavy-oil-barrel', 'lubricant-barrel', 'sulfuric-acid-barrel'} } },
        { caption = 'Inserter Collector', tooltip = 'Hold one of every type of inserter.', condition = { type = 'hold', names = { 'burner-inserter', 'inserter', 'long-handed-inserter', 'fast-inserter', 'bulk-inserter' } } },

        { caption = 'Comfort Coal', tooltip = 'Fill your inventory with coal only.', icon = icon('item/coal'), condition = { type = 'custom', name = 'full_inventory_coal' } },
        { caption = 'Inventory Variety', tooltip = 'Fill your inventory with a different item in every slot.', icon = icon('technology/toolbelt'), condition = { type = 'custom', name = 'full_inventory_unique' } },

        -- Death
        { caption = 'RIP', tooltip = 'Die in any way.', condition = { type = 'death', name = 'character' } },
        { caption = 'Crash Test', tooltip = 'Destroy a car completely by crashing it into obstacles.', condition = { type = 'death', name = 'car', damage_type = 'impact' }},
        { caption = 'Pole Wrecker', tooltip = 'Destroy 200 power poles.', condition = { type = 'death', names = { 'small-electric-pole', 'medium-electric-pole', 'big-electric-pole', 'substation' }, count = 200 } },
        { caption = 'Turret Buster', tooltip = 'Destroy 5 gun turrets.', condition = { type = 'death', name = 'gun-turret', count = 5 } },
        { caption = 'Bug Check', tooltip = 'Destroy 1 biter base.', condition = { type = 'death', names = {'biter-spawner', 'spitter-spawner'}, enemy = true } },
        { caption = 'Biter Extinction', tooltip = 'Destroy 25 biter bases.', condition = { type = 'death', names = {'biter-spawner', 'spitter-spawner'}, count = 25, enemy = true } },
        { caption = 'Roadkill', tooltip = 'Die by getting run over by a tank.', icon = icon('entity/tank'), condition = { type = 'death', name = 'character', cause_name = 'tank' } },
        { caption = 'Cliffhanger', tooltip = 'Destroy a cliff.', icon = icon('utility/cliff_deconstruction_enabled_modifier_icon'), condition = { type = 'custom', name = 'destroy_cliff' } },
        { caption = 'Shotgun Sheriff', tooltip = 'Kill 100 biters with a shotgun.', icon = icon('entity/small-biter', 100), condition = { type = 'custom', name = 'shotgun_kills', data = { count = 100 } } },

        -- Equip
        { caption = 'Fully Equipped', tooltip = 'Wear modular armor with filled equipment grid.', condition = { type = 'custom', name = 'full_modular_grid' }, icon = icon('item/modular-armor') },

        -- Custom
        { caption = 'Fish Catcher', tooltip = 'Use an inserter to catch a fish.', icon = icon('entity/inserter') },
        { caption = 'Delivery Service', tooltip = 'Deliver 10,000 items by logistic robots.', icon = icon('entity/logistic-robot', 10000) },
        { caption = 'Pyromaniac', tooltip = 'Use a flamethrower.', icon = icon('item/flamethrower') },
        { caption = 'Chestplosion', tooltip = 'Cause a chestplosion that fully covers a stone patch.', icon = icon('entity/stone') },
        { caption = 'Lube Up', tooltip = 'Fill a fluid wagon with lubricant.', icon = icon('entity/fluid-wagon') },
        { caption = 'Perfect Mining', tooltip = 'Use electric mining drills to fully cover one coal patch without overlapping areas.', icon = icon('entity/electric-mining-drill') },
        { caption = 'Ironception', tooltip = 'Fill an iron chest with iron chests.', icon = icon('entity/iron-chest'), condition = { type = 'custom', name = 'full_iron_chest', data = { chests = {} } } },
        { caption = 'Accumulator Test', tooltip = 'Fully charge and discharge 250 accumulators.', icon = icon('entity/accumulator', 250) },
        { caption = 'Radar Network', tooltip = 'Power 50 radars with full energy satisfaction.', icon = icon('entity/radar', 50) },
        { caption = 'Belt Loop Adventure', tooltip = 'Ride a belt loop around your starter lake without moving manually.', icon = icon('item/transport-belt') },
        { caption = 'Red Ammo Belt', tooltip = 'Fill a belt loop with 500 rounds of Piercing rounds magazines.', icon = icon('item/piercing-rounds-magazine', 500) },
        { caption = 'Crypto Farm', tooltip = 'Use over 100 MW for 1 full minute.', icon = icon('entity/big-electric-pole', 100) },
        { caption = 'Racer', tooltip = 'Stay in a car for 3 minutes without exiting.', icon = icon('entity/car', 3), condition = { type = 'custom', name = "stay_in_car", data = { ticks = 3*60*60, players = {} } } },
        { caption = 'Display of Affection', tooltip = 'Write “I❤️FACTORIO” using 10 display panels.', icon = icon('entity/display-panel') },
        { caption = 'Catch Me If You Can', tooltip = 'Get chased by 50 biters at once.', icon = icon('entity/small-biter', 50) },
        { caption = 'Collector\'s Chest', tooltip = 'Fill a steel chest with full stacks of different items.', icon = icon('entity/steel-chest'), condition = { type = 'custom', name = 'full_steel_chest_unique', data = { chests = {} } } },
        { caption = 'Beacon King', tooltip = 'Have 12 machines running under the influence of a beacon.', icon = icon('entity/beacon', 12) },
        { caption = 'Shooting Practice', tooltip = 'Use 500 yellow ammo on biters.', icon = icon('item/firearm-magazine', 500) },
    }
}
