local MapConfigs = {
    ['maps/college_base_map.lua'] = {
        spawn = { x = 1800, y = 2500 },
        simpleDraw = false,
        playerScale = 2.5,
        cameraScale = 2,
        interactions = {
            -- All interaction zones are now defined in Tiled map Layers (e.g. "Canteen_Entrance")
        },
        -- NPC Zones are also discovered from Tiled map
        npcZones = {
            canteen = {},
            benches = {},
            class = {},
            library = {},
            hostel = {}
        },

    },
    ['maps/tileSet.lua'] = {
        spawn = { x = 200, y = 100 },
        stageArea = { x = 160, y = 160, w = 200, h = 120 },
        cameraScale = 3,
        playerScale = 1.5,
        interactions = {
            {
                layer = "Door",
                targetMap = "maps/college_base_map.lua",
                targetSpawn = { x = 200, y = 300 },
                prompt = "Go to College",
                action = "load_map"
            },
            {
                -- Manual Exit fallback (Left Wall)
                x = 10, y = 100, w = 50, h = 300,
                targetMap = "maps/college_base_map.lua",
                targetSpawn = { x = 200, y = 300 },
                prompt = "Press E to Leave Class",
                action = "load_map"
            }
        }
    },
    ['maps/hostel.lua'] = {
        spawn = { x = 300, y = 400 },
        cameraScale = 3,
        playerScale = 1.5,
        interactions = {
            {
                layer = 'Exits',
                prompt = 'Press E to go to College',
                action = 'load_map',
                name = 'Gate',
                type = 'travel'
            },
            {
                -- Manual Study Table
                x = 200, y = 200, w = 50, h = 50,
                action = 'minigame',
                type = 'study'
            },
            {
                layer = "Bed",
                x = 60, y = 60, w = 40, h = 60,
                action = "sleep",
                prompt = "Sleep (Restore Energy)"
            }
        }
    },
    ['maps/canteen.lua'] = {
        spawn = { x = 320, y = 300 },
        cameraScale = 3,
        playerScale = 1.5,
        interactions = {
            {
                name = "Counter",
                x = 200, y = 100, w = 240, h = 60,
                prompt = 'Press E for Service',
                action = 'shop'
            },
            {
                name = "Exit",
                x = 300, y = 400, w = 40, h = 40,
                prompt = 'Press E to Leave',
                action = 'load_map',
                targetMap = 'maps/college_base_map.lua',
                -- Standardized Spawn: Just outside the Canteen door (Entrance was 1100, 1970)
                targetSpawn = { x = 1100, y = 2050 }
            }
        }
    }
}

return MapConfigs
