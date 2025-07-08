local function factory_challenge(caption, tooltip, name, counts)
    local suffixes = {'Mega Factory', 'Giga Factory'}
    if #counts == 3 then
        table.insert(suffixes, 'Factory')
    end
    
    local challenges = {}
    local multiple = type(name) == 'table'
    for i, count in pairs(counts) do
        local condition = { type = 'craft', count = count }
        if multiple then
            condition.names = name
        else
            condition.name = name
        end

        challenges[i] = {
            caption = caption .. ' ' .. suffixes[i],
            tooltip = string.format(tooltip, count),
            condition = condition
        }
    end

    return challenges
end

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
    challenges = {
        -- Build
        { caption = 'Light Up!', tooltip = 'Place 3 lamps.', condition = {type = 'build', name = 'small-lamp', count = 3 } },
        { caption = 'Landfiller', tooltip = 'Place 200 landfill.', condition = {type = 'build', name = 'landfill', count = 200 } },
        { caption = 'Burner Metropolis', tooltip = 'Place 200 burner mining drills.', condition = {type = 'build', name = 'burner-mining-drill', count = 200 } },
        { caption = 'Oil Explorer', tooltip = 'Place 40 pumpjacks.', condition = {type = 'build', name = 'pumpjack', count = 40 } },

        { caption = 'Lab Rush', tooltip = 'Place 100 labs all running research.' },
        { caption = 'Botlap', tooltip = 'Place a locomotive with bots.' },
        { caption = 'Solaris', tooltip = 'Place and connect 100 solar panels.' },
        { caption = 'Rollercoaster', tooltip = 'Build a rail loop around your starter lake and complete 5 train laps.' },
        { caption = 'Fortified!', tooltip = 'Wall yourself in with 8 tiles.' },
        { caption = 'Steel Upgrade', tooltip = 'Upgrade 150 furnaces to steel furnaces.' },
        { caption = 'Gatekeeper', tooltip = 'Build one gate that\'s 250 tiles long.' },
        { caption = 'Pumped Dry', tooltip = 'Place pumps on every usable position of your starter lake and connect their outputs.' },
        { caption = 'Copper Pavement', tooltip = 'Cover a copper patch with stone bricks.' },
        { caption = 'Freight Train', tooltip = 'Construct a train with 10 wagons.' },
        { caption = 'Rock and Stone!', tooltip = 'Connect power to 20 rocks.' },
        { caption = 'Heart-Shaped Box', tooltip = 'Place 200 wooden chests in a heart shape.' },
        { caption = 'Pole Upgrade Program', tooltip = 'Replace all small poles with medium ones.' },
        { caption = 'Looping Louie', tooltip = 'Build 100 separate belt loops.' },
        { caption = 'Assembly Line Upgrade', tooltip = 'Upgrade all assemblers to level 2.' },

        -- Craft
        { caption = 'Acid Barrels', tooltip = 'Fill 100 barrels with sulfuric acid.', condition = { type = 'craft', name = 'sulfuric-acid-barrel', count = 100 } },
        { caption = 'Uranium Touch', tooltip = 'Craft one U-235.', condition = { type = 'craft', name = 'uranium-235' } },
        { caption = 'Blue Chips', tooltip = 'Craft 100 processing units.', condition = { type = 'craft', name = 'processing-unit', count = 100 } },
        { caption = 'LDS Factory', tooltip = 'Craft 150 low-density structures.', condition = { type = 'craft', name = 'low-density-structure', count = 150 } },
        { caption = 'Rocket Fuel', tooltip = 'Craft 200 rocket fuel.', condition = { type = 'craft', name = 'rocket-fuel', count = 100 } },
        { caption = 'Shotgun Lord', tooltip = 'Craft 50 shotguns.', condition = { type = 'craft', name = 'shotgun', count = 50 } },
        { caption = 'Red Supremacy', tooltip = 'Craft 200 fast underground belts.', condition = { type = 'craft', name = 'fast-underground-belt', count = 200 } },
        { caption = 'Bulk Inserters', tooltip = 'Craft 200 bulk inserters.', condition = { type = 'craft', name = 'bulk-inserter', count = 200 } },
        { caption = 'Paint It Red', tooltip = 'Gather 10,000 copper ore.', condition = { type = 'craft', name = 'copper-ore', count = 10000 } },
        {
            factory_challenge("Underground Pipe", 'Produce %d underground pipes', 'pipe-to-ground', { 1000, 2000 }),
            factory_challenge("Fast Inserter", 'Produce %d fast inserters', 'fast-inserter', { 500, 1000 }),
            factory_challenge("Rail", 'Produce %d rails', 'rail', { 1000, 2500, 5000 }),
            factory_challenge('Big Electric Pole', 'Produce %d big electric poles.', 'big-electric-pole', { 100, 250, 500 }),
            factory_challenge('Train Stop', 'Produce %d train stops.', 'train-stop', { 100, 250, 500 } ),
            factory_challenge('Locomotive', 'Produce %d locomotives.', 'locomotive', { 10, 25, 50 } ),
            factory_challenge('Fluid Wagon', 'Produce %d fluid wagons.', 'fluid-wagon', { 25, 50, 100 } ),
            factory_challenge('Car', 'Produce %d cars.', 'car', { 25, 50, 150 } ),
            factory_challenge('Refined Hazard Concrete', 'Produce %d refined hazard concrete.', 'refined-hazard-concrete', { 1000, 2500, 5000 } ),
            factory_challenge('Accumulator', 'Produce %d accumulators.', 'accumulator', { 500, 1000 } ),
            factory_challenge('Module', 'Produce %d modules.',
                { 'speed-module', 'speed-module-2', 'speed-module-3', 'efficiency-module', 'efficiency-module-2', 'efficiency-module-3', 'productivity-module', 'productivity-module-2', 'productivity-module-3' },
                { 150, 300 }
            ),
            factory_challenge('Flamethrower Turret', 'Produce %d flamethrower turrets.', 'flamethrower-turret', { 25, 75 } ),
            factory_challenge('Rocket', 'Produce %d rockets.', 'rocket', { 1000, 3000 } ),
            factory_challenge('Land Mine', 'Produce %d land mines.', 'land-mine', { 5000, 10000 } ),
            factory_challenge('Flamethrower Ammo', 'Produce %d flamethrower ammo.', 'flamethrower-ammo', { 1000, 2000 } ),
            factory_challenge('Grenade', 'Produce %d grenades.', 'grenade', { 250, 500, 1000 } ),
            factory_challenge('Defender Capsule', 'Produce %d defender capsules.', 'defender-capsule', { 100, 250, 500 } ),
            factory_challenge('Submachine Gun', 'Produce %d submachine guns.', 'submachine-gun', { 100, 300 } ),
            factory_challenge('Programmable Speaker', 'Produce %d programmable speakers.', 'programmable-speaker', { 250, 750 } ),
            factory_challenge('Fast Splitter', 'Produce %d fast splitters.', 'fast-splitter', { 100, 250 } ),
            factory_challenge('Electric Pump', 'Produce %d electric pumps.', 'pump', { 250, 750 } ),
            factory_challenge('Oil Refinery', 'Produce %d oil refineries.', 'refinery', { 50, 150 } ),
            factory_challenge('Solid Fuel', 'Produce %d solid fuel.', 'solid-fuel', { 5000, 10000 } ),
        },

        -- Research
        { caption = 'Steel Axe', tooltip = 'Unlock the Steel Axe technology.', condition = { type = 'research', name = 'steel-axe' } },
        { caption = 'Productive Mining', tooltip = 'Unlock Mining Productivity 1.', condition = { type = 'research', name = 'mining-productivity-1' } },
        { caption = 'Bullet Specialist', tooltip = 'Research Projectile Damage 4 + Shooting Speed 4.', condition = { type = 'research', names = { 'projectile-damage-4', 'weapon-shooting-speed-4' } } },

        { caption = 'POWER IS FINE', tooltip = 'Total 5 min of yellow power, after researching "Electric Energy Distribution 1".' },

        -- Hold
        { caption = 'Fishing Industry', tooltip = 'Collect 200 fish.', condition = { type = 'hold', name = 'raw-fish', count = 200 } },
        { caption = 'Rainbow Barrels', tooltip = 'Carry one of each barrel type.', condition = { type = 'hold', names = { 'water-barrel', 'crude-oil-barrel', 'petroleum-gas-barrel', 'light-oil-barrel', 'heavy-oil-barrel', 'lubricant-barrel', 'sulfuric-acid-barrel'} } },
        { caption = 'Inserter Collector', tooltip = 'Hold one of every type of inserter.', condition = { type = 'hold', names = { 'burner-inserter', 'inserter', 'long-handed-inserter', 'fast-inserter', 'bulk-inserter' } } },

        { caption = 'Coal Hoarder', tooltip = 'Fill your inventory with coal only.', condition = { type = 'custom', name = 'full_inventory_coal' } },
        { caption = 'Inventory Variety', tooltip = 'Fill your inventory with a different item in every slot.', condition = { type = 'custom', name = 'full_inventory_unique' } },

        -- Death
        { caption = 'RIP', tooltip = 'Die in any way.', condition = { type = 'death', name = 'character' } },
        { caption = 'Crash Test', tooltip = 'Destroy a car completely by crashing it into obstacles.', condition = { type = 'death', name = 'car', damage_type = 'impact' } },
        { caption = 'Pole Wrecker', tooltip = 'Destroy 200 power poles.', condition = { type = 'death', names = { 'small-electric-pole', 'medium-electric-pole', 'big-electric-pole', 'substation' }, count = 200 } },
        { caption = 'Turret Buster', tooltip = 'Destroy one gun turret.', conditon = { type = 'death', name = 'gun-turret' } },
        { caption = 'Bug Check', tooltip = 'Destroy 1 biter base.', conditon = { type = 'death', names = {'biter-spawner', 'spitter-spawner'}, enemy = true } },
        { caption = 'Biter Extinction', tooltip = 'Destroy 25 biter bases.', conditon = { type = 'death', names = {'biter-spawner', 'spitter-spawner'}, count = 25, enemy = true } },

        { caption = 'Cliffhanger', tooltip = 'Destroy a cliff.' },
        { caption = 'Shotgun Sheriff', tooltip = 'Kill 100 biters with only a shotgun.' },

        -- Equip

        { caption = 'Fully Equipped', tooltip = 'Fill the equipment grid of a modular armor.', condition = { type = 'custom', name = 'full_modular_grid' } },

        -- Custom
        { caption = 'Fish Catcher', tooltip = 'Use an inserter to catch a fish.' },
        { caption = 'Delivery Service', tooltip = 'Deliver 10,000 items by logistic robots.' },
        { caption = 'Pyromaniac', tooltip = 'Use a flamethrower.' },
        { caption = 'Chestplosion', tooltip = 'Cause a chestplosion that fully covers a stone patch.' },
        { caption = 'Lube Up', tooltip = 'Fully fill a fluid wagon with lubricant.' },
        { caption = 'Perfect Mining', tooltip = 'Use electric mining drills to fully cover one coal patch without overlapping areas.' },
        { caption = 'Ironception', tooltip = 'Fill an iron chest with iron chests.' },
        { caption = 'Accumulator Test', tooltip = 'Fully charge and discharge 500 accumulators.' },
        { caption = 'Radar Network', tooltip = 'Power 50 radars at full energy satisfaction.' },
        { caption = 'Scenic Belt Loop', tooltip = 'Ride a belt loop around your starter lake without moving manually.' },
        { caption = 'Red Ammo Belt', tooltip = 'Fill a belt loop with 500 rounds of Piercing rounds magazines.' },
        { caption = 'Power Waster', tooltip = 'Use over 100 MW for 1 full minute.' },
        { caption = 'Racer', tooltip = 'Stay in a car for 3 minutes without exiting.' },
        { caption = 'Display of Affection', tooltip = 'Write “I❤️FACTORIO” using 10 display panels.' },
        { caption = 'The Ground Is Lava', tooltip = 'Produce at least 1,000 concrete and walk only on it for 1 minute.' },
        { caption = 'Catch Me If You Can', tooltip = 'Get chased by 100 biters at once.' },
        { caption = 'Collector’s Chest', tooltip = 'Fill a steel chest with full stacks of different items.' },
        { caption = 'Shooting Practice', tooltip = 'Use 500 yellow ammo on biters.' },
    }
}