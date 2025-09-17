-- main.lua
local anim8 = require 'libraries/anim8'
local sti = require 'libraries/sti'
local camera = require 'libraries/camera'
local wf = require 'libraries/windfield'

-- Globals
local cam, world, gameMap, player, walls = nil, nil, nil, nil, {}
local width, height = love.window.getDesktopDimensions(1)
local windowWidth, windowHeight = math.floor(width * 0.9), math.floor(height * 0.9)

function love.load()
    -- Window setup
    love.window.setMode(windowWidth, windowHeight, { resizable = true, fullscreen = false })
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Map & physics
    gameMap = sti('maps/tileSet.lua')
    world = wf.newWorld(0, 0, true)

    -- Camera
    cam = camera()
    cam.scale = 4

    -- Player setup
    initPlayer()

    -- Map walls
    initWalls()
end

-- ===================== PLAYER =====================
function initPlayer()
    player = {
        x = windowWidth * 0.2,
        y = windowHeight * 0.2,
        walkingSpeed = 50,
        animSpeed = 0.1,
        spriteSheet = love.graphics.newImage("sprites/Teacher_1_walk-Sheet.png")
    }

    -- Collider
    player.collider = world:newBSGRectangleCollider(player.x, player.y, 18, 35, 4)
    player.collider:setFixedRotation(true)

    -- Animations
    local grid = anim8.newGrid(32, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations = {
        down  = anim8.newAnimation(grid('1-6', 4), player.animSpeed),
        up    = anim8.newAnimation(grid('1-6', 2), player.animSpeed),
        left  = anim8.newAnimation(grid('1-6', 1), player.animSpeed),
        right = anim8.newAnimation(grid('1-6', 3), player.animSpeed)
    }
    player.anim = player.animations.down
end

function updatePlayer(dt)
    local vx, vy = 0, 0
    local isMoving = false

    if love.keyboard.isDown('w') then vy = -player.walkingSpeed; player.anim = player.animations.up; isMoving = true end
    if love.keyboard.isDown('s') then vy =  player.walkingSpeed; player.anim = player.animations.down; isMoving = true end
    if love.keyboard.isDown('d') then vx =  player.walkingSpeed; player.anim = player.animations.right; isMoving = true end
    if love.keyboard.isDown('a') then vx = -player.walkingSpeed; player.anim = player.animations.left; isMoving = true end

    player.collider:setLinearVelocity(vx, vy)
    if not isMoving then player.anim:gotoFrame(1) end

    player.x, player.y = player.collider:getX() + 2, player.collider:getY()
    player.anim:update(dt)
end

function drawPlayer()
    player.anim:draw(
        player.spriteSheet,
        player.x, player.y,
        nil,
        cam.scale / 3, cam.scale / 3,
        16, 16
    )
end

-- ===================== MAP WALLS =====================
function initWalls()
    if not gameMap.layers["Walls"] then return end
    for _, obj in pairs(gameMap.layers["Walls"].objects) do
        local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wall:setType("static")
        table.insert(walls, wall)
    end
end

-- ===================== CAMERA =====================
function updateCamera()
    cam:lookAt(player.x, player.y)

    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local mapWidth, mapHeight = gameMap.width * gameMap.tilewidth, gameMap.height * gameMap.tileheight

    -- Clamp camera inside map bounds
    cam.x = math.max(windowWidth / (2 * cam.scale), math.min(cam.x, mapWidth - (windowWidth / (2 * cam.scale))))
    cam.y = math.max(windowHeight / (2 * cam.scale), math.min(cam.y, mapHeight - (windowHeight / (2 * cam.scale))))
end

-- ===================== LOVE CALLBACKS =====================
function love.update(dt)
    world:update(dt)
    updatePlayer(dt)
    updateCamera()
end

function love.draw()
    cam:attach()
        drawMap()
        drawPlayer()
    cam:detach()
end

-- ===================== DRAW MAP =====================
function drawMap()
    local layers = {
        'Base Floor',
        'Base Stage Floor',
        'Floor and Wall Objects',
        'Base Wall',
        'Windows',
        'Wall Objects',
        'Benches and Vegetation'
    }
    for _, layer in ipairs(layers) do
        if gameMap.layers[layer] then
            gameMap:drawLayer(gameMap.layers[layer])
        end
    end
end
