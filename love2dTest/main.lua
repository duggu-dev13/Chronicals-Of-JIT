local sti = require 'libraries/sti'
local camera = require 'libraries/camera'
local wf = require 'libraries/windfield'
local Player = require 'modules/player'  -- import our module

local cam, world, gameMap, player, walls = nil, nil, nil, nil, {}
local benchRects = {}
local debugDraw = false

function love.load()
    -- Window setup
    local width, height = love.window.getDesktopDimensions(1)
    love.window.setMode(math.floor(width * 0.9), math.floor(height * 0.9), { resizable = true, fullscreen = false })
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Map & physics
    gameMap = sti('maps/tileSet.lua')
    world = wf.newWorld(0, 0, true)

    -- Camera
    cam = camera()
    cam.scale = 4

    -- Player
    player = Player:new(world)

    -- Walls
    initWalls()
end

function love.update(dt)
    world:update(dt)
    player:update(dt)
    updateCamera()
end

function love.draw()
    cam:attach()
        drawSceneWithDepth()
        if debugDraw then
            love.graphics.setColor(0, 1, 0, 0.8)
            world:draw()
            love.graphics.setColor(1, 1, 1, 1)
        end
    cam:detach()
end

-- ===================== WALLS =====================
function initWalls()
    if not gameMap.layers["Walls"] then return end
    for _, obj in pairs(gameMap.layers["Walls"].objects) do
        local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wall:setType("static")
        table.insert(walls, wall)

        -- Heuristic: treat small rectangles as bench tops for depth masking
        if obj.width <= 40 and obj.height <= 40 then
            table.insert(benchRects, {
                x = obj.x, y = obj.y, w = obj.width, h = obj.height
            })
        end
    end
end

-- ===================== INPUT =====================
function love.keypressed(key)
    if key == 'f1' then
        debugDraw = not debugDraw
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

-- ===================== MAP DRAWING =====================
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

-- Draw scene with benches depth-sorted against player using world-space stencil
function drawSceneWithDepth()
    -- Draw all layers except benches
    local layersBefore = {
        'Base Floor',
        'Base Stage Floor',
        'Floor and Wall Objects',
        'Base Wall',
        'Windows',
        'Wall Objects'
    }
    for _, layer in ipairs(layersBefore) do
        if gameMap.layers[layer] then
            gameMap:drawLayer(gameMap.layers[layer])
        end
    end

    local benchesLayer = gameMap.layers['Benches and Vegetation']
    if not benchesLayer then
        -- Fallback: no benches layer, just draw player and return
        player:draw(cam.scale)
        return
    end

    -- Player bottom Y in world coords (32px sprite with origin at 16,16)
    local playerBottomY = player.y + 16

    -- Margin so stencil fully covers the bench sprites around the collider top
    local margin = 32

    -- Draw benches whose collider top is above player's bottom (behind player)
    for _, r in ipairs(benchRects) do
        if r.y < playerBottomY then
            love.graphics.stencil(function()
                love.graphics.rectangle('fill', r.x - margin, r.y - margin, r.w + margin * 2, r.h + margin * 2)
            end, 'replace', 1)
            love.graphics.setStencilTest('equal', 1)
            gameMap:drawLayer(benchesLayer)
            love.graphics.setStencilTest()
        end
    end

    -- Draw player between the two groups
    player:draw(cam.scale)

    -- Draw benches whose collider top is at/under player's bottom (in front of player)
    for _, r in ipairs(benchRects) do
        if r.y >= playerBottomY then
            love.graphics.stencil(function()
                love.graphics.rectangle('fill', r.x - margin, r.y - margin, r.w + margin * 2, r.h + margin * 2)
            end, 'replace', 1)
            love.graphics.setStencilTest('equal', 1)
            gameMap:drawLayer(benchesLayer)
            love.graphics.setStencilTest()
        end
    end
end
