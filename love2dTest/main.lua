
function love.load()
    anim8 = require 'libraries/anim8'
    
    -- Get the desktop dimensions (1 for primary monitor)
    local width, height = love.window.getDesktopDimensions(1)
    
    -- Set the window size to 80% of desktop dimensions
    local windowWidth = math.floor(width * 0.8)
    local windowHeight = math.floor(height * 0.8)
    love.window.setMode(windowWidth, windowHeight, {
        resizable = true,
        fullscreen = false
    })

    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Player object
    player = {}
    player.x = 400
    player.y = 500
    player.walkingSpeed = 2
    player.animSpeed = 0.1
    player.spriteSheet = love.graphics.newImage("sprites/Teacher_1_walk-Sheet.png")  
    background = love.graphics.newImage("sprites/classroom.png")

    player.grid = anim8.newGrid(32, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations= {}
    player.animations.down = anim8.newAnimation(player.grid('1-6', 4), player.animSpeed)
    player.animations.up = anim8.newAnimation(player.grid('1-6', 2), player.animSpeed)
    player.animations.left = anim8.newAnimation(player.grid('1-6', 1), player.animSpeed)
    player.animations.right = anim8.newAnimation(player.grid('1-6', 3), player.animSpeed)

    player.anim = player.animations.down

end

function love.update(dt)
    
    local isMoving = false

    if love.keyboard.isDown('w') then
        player.y = player.y - player.walkingSpeed
        player.anim = player.animations.up
        isMoving = true
    end
    if love.keyboard.isDown('s') then
        player.y = player.y + player.walkingSpeed
        player.anim = player.animations.down
        isMoving = true
    end
    if love.keyboard.isDown('d') then
        player.x = player.x + player.walkingSpeed
        player.anim = player.animations.right
        isMoving = true
    end
    if love.keyboard.isDown('a') then
        player.x = player.x - player.walkingSpeed
        player.anim = player.animations.left
        isMoving = true
    end

    if isMoving == false then
        player.anim:gotoFrame(1)
    end
    
    player.anim:update(dt)
end

function love.draw()
    -- Draw something on the screen
    love.graphics.draw(background, 0, 0, nil, 2, 2)
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 3, 3)
end
