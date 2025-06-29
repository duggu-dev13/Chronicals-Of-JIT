
function love.load()
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
    player.speed = 5
    player.sprite = love.graphics.newImage("objects/Teacher.png")
    background = love.graphics.newImage("objects/classroom.png")
end

function love.update(dt)
    if love.keyboard.isDown('w') then
        player.y = player.y - player.speed
    end
    if love.keyboard.isDown('s') then
        player.y = player.y + player.speed
    end
    if love.keyboard.isDown('d') then
        player.x = player.x + player.speed
    end
    if love.keyboard.isDown('a') then
        player.x = player.x - player.speed
    end
end

function love.draw()
    -- Draw something on the screen
    love.graphics.draw(background, 0, 0, nil, 3, 3)
    love.graphics.draw(player.sprite, player.x, player.y, nil, 3, 3)
end
