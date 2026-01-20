local MapConfigs = {
    ['maps/college_base_map.lua'] = {
        spawn = { x = 1800, y = 2500 },
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
                -- Canteen Entrance
                x = 1100, y = 1970, w = 170, h = 260,
                prompt = 'Press E to Enter Canteen',
                action = 'load_map',
                targetMap = 'maps/canteen.lua',
                targetSpawn = { x = 320, y = 300 }
            },
            {
                -- Admission Desk (New Prologue Area)
                x = 1800, y = 800, w = 200, h = 100, -- Placeholder coords
                prompt = 'Press E for Admission',
                action = 'form',
                type = 'admission'
            },
            {
                -- Notice Board (App Unlock)
                x = 1600, y = 2600, w = 100, h = 50, -- Near new spawn
                prompt = 'Press E to Scan QR Code',
                action = 'notice_board',
                type = 'info'
            },
            {
                -- Main Gate (Travel)
                x = 1800, y = 2900, w = 400, h = 100, -- South of spawn
                prompt = 'Press E to Open Travel Menu',
                action = 'load_map',
                name = 'Gate',
                type = 'travel'
            }
        }
    },
    ['maps/tileSet.lua'] = {
        spawn = { x = 200, y = 100 },
        stageArea = { x = 160, y = 160, w = 200, h = 120 },
        cameraScale = 4,
        interactions = {
            {
                layer = "Door",
                targetMap = "maps/college_base_map.lua",
                targetSpawn = { x = 200, y = 300 },
                prompt = "Go to College",
                action = "load_map"
            }
        }
    },
    ['maps/hostel.lua'] = {
        spawn = { x = 300, y = 400 },
        cameraScale = 3,
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
