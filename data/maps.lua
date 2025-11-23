local MapConfigs = {
    ['maps/college_base_map.lua'] = {
        spawn = { x = 2900, y = 320 },
        simpleDraw = true,
        playerScale = 4,
        cameraScale = 2,  -- Zoomed out for campus view
        interactions = {
            {
                layer = 'College',
                prompt = 'Press E to enter the classroom',
                action = 'load_map',
                targetMap = 'maps/tileSet.lua',
                targetSpawn = { x = 200, y = 100 }
            }
        }
    },
    ['maps/tileSet.lua'] = {
        spawn = { x = 200, y = 100 },
        stageArea = { x = 160, y = 160, w = 200, h = 120 },
        cameraScale = 4  -- Normal zoom for classroom
    }
}

return MapConfigs
