local MapConfigs = {
    ['maps/college_base_map.lua'] = {
        spawn = { x = 2900, y = 320 },
        simpleDraw = true,
        playerScale = 4,
        cameraScale = 2,
        interactions = {
            {
                layer = 'College',
                prompt = 'Press E to enter the classroom',
                action = 'load_map',
                targetMap = 'maps/tileSet.lua',
                targetSpawn = { x = 200, y = 100 }
            },
            {
                -- Manual Gate Zone (Square 1200-2000, 2800-4000)
                x = 1200, y = 2800, w = 800, h = 1200,
                prompt = 'Press E to go to Hostel',
                action = 'load_map',
                targetMap = 'maps/hostel.lua',
                targetSpawn = { x = 300, y = 400 }
            }
        }
    },
    ['maps/tileSet.lua'] = {
        spawn = { x = 200, y = 100 },
        stageArea = { x = 160, y = 160, w = 200, h = 120 },
        cameraScale = 4
    },
    ['maps/hostel.lua'] = {
        spawn = { x = 300, y = 400 },
        cameraScale = 3,
        interactions = {
            {
                layer = 'Exits',
                prompt = 'Press E to go to College',
                action = 'load_map',
                targetMap = 'maps/college_base_map.lua',
                targetSpawn = { x = 2900, y = 320 }
            }
        }
    }
}

return MapConfigs
