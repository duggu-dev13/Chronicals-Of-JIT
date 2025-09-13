function love.load()
    anim8 = require 'libraries/anim8'
    
    sti = require 'libraries/sti'
    gameMap = sti('maps/tileSet.lua')

    camera = require 'libraries/camera'
    cam = camera()
    
    wf = require 'libraries/windfield'

    world = wf.newWorld(0, 0)

    -- Get the desktop dimensions (1wad for primary monitor)
    local width, height = love.window.getDesktopDimensions(1)
    
    -- Set the window size to 80% of desktop dimensions
    local windowWidth = math.floor(width * 0.9)
    local windowHeight = math.floor(height * 0.9)
    love.window.setMode(windowWidth, windowHeight, {
        resizable = true,
        fullscreen = false
    })

    love.graphics.setDefaultFilter("nearest", "nearest")

    cam.scale = 4

    -- Player object
    player = {}
    player.collider = world:newBSGRectangleCollider(100, 100, 18, 35, 4)
    player.collider:setFixedRotation(true)
    -- Set the player's starting position to the center of the first tile
    player.x = 400
    player.y = 200

    -- Player object
    player.walkingSpeed = 50
    player.animSpeed = 0.1
    player.spriteSheet = love.graphics.newImage("sprites/Teacher_1_walk-Sheet.png")  
    
    player.grid = anim8.newGrid(32, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations= {}
    player.animations.down = anim8.newAnimation(player.grid('1-6', 4), player.animSpeed)
    player.animations.up = anim8.newAnimation(player.grid('1-6', 2), player.animSpeed)
    player.animations.left = anim8.newAnimation(player.grid('1-6', 1), player.animSpeed)
    player.animations.right = anim8.newAnimation(player.grid('1-6', 3), player.animSpeed)

    player.anim = player.animations.down
    walls = {}

    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do 
            local  wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType("static")
            table.insert(walls, wall)
        end
    end
end

function love.update(dt)
    
    local isMoving = false

    local vx = 0
    local vy = 0
    
    if love.keyboard.isDown('w') then
        vy = player.walkingSpeed * -1
        player.anim = player.animations.up
        isMoving = true
    end
    if love.keyboard.isDown('s') then
        vy = player.walkingSpeed
        player.anim = player.animations.down
        isMoving = true
    end
    if love.keyboard.isDown('d') then
        vx = player.walkingSpeed
        player.anim = player.animations.right
        isMoving = true
    end
    if love.keyboard.isDown('a') then
        vx = player.walkingSpeed * -1
        player.anim = player.animations.left
        isMoving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
        player.anim:gotoFrame(1)
    end
    
    world:update(dt)
    player.x = player.collider:getX() + 2 -- Manual Adjusting offset of Collider
    player.y = player.collider:getY()

    player.anim:update(dt)

    cam:lookAt(player.x, player.y)

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    local mapWidth = gameMap.width * gameMap.tilewidth
    local mapHeight = gameMap.height * gameMap.tileheight

    if cam.x < (windowWidth / (2 * cam.scale)) then 
        cam.x = (windowWidth / (2 * cam.scale))
    end

    if cam.y < (windowHeight / (2 * cam.scale)) then 
        cam.y = (windowHeight / (2 * cam.scale))
    end

    if cam.x > (mapWidth - (windowWidth / (2 * cam.scale))) then 
        cam.x = (mapWidth - (windowWidth / (2 * cam.scale)))
    end

    if cam.y > (mapHeight - (windowHeight / (2 * cam.scale))) then 
        cam.y = (mapHeight - (windowHeight / (2 * cam.scale)))
    end
end



function love.draw()
    cam:attach() -- Pass the scale factor to the camera
        gameMap:drawLayer(gameMap.layers['Base Floor'])
        gameMap:drawLayer(gameMap.layers['Base Stage Floor'])
        gameMap:drawLayer(gameMap.layers['Floor and Wall Objects'])
        gameMap:drawLayer(gameMap.layers['Base Wall'])
        gameMap:drawLayer(gameMap.layers['Windows'])
        gameMap:drawLayer(gameMap.layers['Wall Objects'])
        gameMap:drawLayer(gameMap.layers['Benches and Vegetation'])
        player.anim:draw(
            player.spriteSheet,
            player.x, player.y,
            nil,
            cam.scale / 3,
            cam.scale / 3,
            16, 16
        )
        
    cam:detach()
end
