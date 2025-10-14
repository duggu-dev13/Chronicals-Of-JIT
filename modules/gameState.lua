-- gameState.lua
-- Main game state (the actual gameplay)

local GameState = {}

function GameState:new(stateManager)
    local obj = {}
    obj.stateManager = stateManager
    
    -- Game variables (moved from main.lua)
    obj.cam, obj.world, obj.gameMap, obj.player, obj.walls = nil, nil, nil, nil, {}
    obj.benchRects = {}
    obj.debugDraw = false
    obj.sounds = {}
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function GameState:enter()
    -- Initialize game if not already done
    if not self.gameMap then
        self:initGame()
    end
end

function GameState:initGame()
    local sti = require 'libraries/sti'
    local camera = require 'libraries/camera'
    local wf = require 'libraries/windfield'
    local Player = require 'modules/player'
    
    -- Map & physics
    self.gameMap = sti('maps/tileSet.lua')
    self.world = wf.newWorld(0, 0, true)

    -- Camera
    self.cam = camera()
    self.cam.scale = 4

    -- Music
    self.sounds.music = love.audio.newSource('sounds/ambience.mp3', 'stream')
    self.sounds.music:play()
    self.sounds.music:setLooping(true)
    
    -- Player
    self.player = Player:new(self.world)

    -- Walls
    self:initWalls()
end

function GameState:update(dt)
    self.world:update(dt)
    self.player:update(dt)
    self:updateCamera()
end

function GameState:draw()
    -- Reset color to white before drawing
    love.graphics.setColor(1, 1, 1, 1)
    
    self.cam:attach()
        self:drawSceneWithDepth()
        if self.debugDraw then
            love.graphics.setColor(0, 1, 0, 0.8)
            self.world:draw()
            love.graphics.setColor(1, 1, 1, 1)
        end
    self.cam:detach()
    
    -- Ensure color is reset after drawing
    love.graphics.setColor(1, 1, 1, 1)
end

function GameState:keypressed(key)
    if key == 'f1' then
        self.debugDraw = not self.debugDraw
    elseif key == 'escape' then
        self.stateManager:setState("menu")
    end
end

-- ===================== WALLS =====================
function GameState:initWalls()
    if not self.gameMap.layers["Walls"] then return end
    for _, obj in pairs(self.gameMap.layers["Walls"].objects) do
        local wall = self.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wall:setType("static")
        table.insert(self.walls, wall)

        -- Heuristic: treat small rectangles as bench tops for depth masking
        if obj.width <= 40 and obj.height <= 40 then
            table.insert(self.benchRects, {
                x = obj.x, y = obj.y, w = obj.width, h = obj.height
            })
        end
    end
    
    -- Add stage area for depth sorting
    self:initStageArea()
end

-- ===================== STAGE AREA & PLANTS =====================
function GameState:initStageArea()
    -- Initialize stage area separately from other objects
    -- Try to find the actual stage area from the map
    self.stageArea = nil
    
    -- Look for stage area in the map layers
    if self.gameMap.layers["Base Stage Floor"] then
        local stageLayer = self.gameMap.layers["Base Stage Floor"]
        if stageLayer.objects and #stageLayer.objects > 0 then
            -- Use the first stage object as the stage area
            local stageObj = stageLayer.objects[1]
            self.stageArea = {
                x = stageObj.x, y = stageObj.y, w = stageObj.width, h = stageObj.height
            }
            print("Stage area found: x=" .. stageObj.x .. ", y=" .. stageObj.y .. ", w=" .. stageObj.width .. ", h=" .. stageObj.height)
        else
            -- Fallback: use manual coordinates
            self.stageArea = {
                x = 160, y = 160, w = 200, h = 120  -- Stage area coordinates - adjust if needed
            }
            print("Using manual stage area: x=160, y=160, w=200, h=120")
        end
    else
        -- Fallback: use manual coordinates
        self.stageArea = {
            x = 160, y = 160, w = 200, h = 120  -- Stage area coordinates - adjust if needed
        }
        print("Using manual stage area: x=160, y=160, w=200, h=120")
    end
    
    -- Look for plants in the map layers
    if self.gameMap.layers["Floor and Wall Objects"] and self.gameMap.layers["Floor and Wall Objects"].objects then
        print("Found " .. #self.gameMap.layers["Floor and Wall Objects"].objects .. " objects in Floor and Wall Objects layer")
        for _, obj in pairs(self.gameMap.layers["Floor and Wall Objects"].objects) do
            table.insert(self.benchRects, {
                x = obj.x, y = obj.y, w = obj.width, h = obj.height
            })
        end
    else
        print("Floor and Wall Objects layer not found or has no objects")
    end
    
    -- Also check other potential plant layers
    if self.gameMap.layers["Wall Objects"] and self.gameMap.layers["Wall Objects"].objects then
        print("Found " .. #self.gameMap.layers["Wall Objects"].objects .. " objects in Wall Objects layer")
        for _, obj in pairs(self.gameMap.layers["Wall Objects"].objects) do
            table.insert(self.benchRects, {
                x = obj.x, y = obj.y, w = obj.width, h = obj.height
            })
        end
    else
        print("Wall Objects layer not found or has no objects")
    end
    
    -- Check benches layer
    if self.gameMap.layers["Benches and Vegetation"] then
        print("Benches and Vegetation layer found")
    else
        print("Benches and Vegetation layer not found")
    end
    
    print("Total objects for depth sorting: " .. #self.benchRects)
end

-- ===================== CAMERA =====================
function GameState:updateCamera()
    self.cam:lookAt(self.player.x, self.player.y)

    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local mapWidth, mapHeight = self.gameMap.width * self.gameMap.tilewidth, self.gameMap.height * self.gameMap.tileheight

    -- Clamp camera inside map bounds
    self.cam.x = math.max(windowWidth / (2 * self.cam.scale), math.min(self.cam.x, mapWidth - (windowWidth / (2 * self.cam.scale))))
    self.cam.y = math.max(windowHeight / (2 * self.cam.scale), math.min(self.cam.y, mapHeight - (windowHeight / (2 * self.cam.scale))))
end

-- ===================== MAP DRAWING =====================
function GameState:drawMap()
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
        if self.gameMap.layers[layer] then
            self.gameMap:drawLayer(self.gameMap.layers[layer])
        end
    end
end

-- Draw scene with benches depth-sorted against player using world-space stencil
function GameState:drawSceneWithDepth()
    -- Ensure we start with white color
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Draw all layers except benches, stage, and plants (we'll handle these separately for depth sorting)
    local layersBefore = {
        'Base Floor',
        'Base Wall',
        'Windows'
    }
    for _, layer in ipairs(layersBefore) do
        if self.gameMap.layers[layer] then
            love.graphics.setColor(1, 1, 1, 1) -- Reset color before each layer
            self.gameMap:drawLayer(self.gameMap.layers[layer])
        end
    end

    local benchesLayer = self.gameMap.layers['Benches and Vegetation']
    local stageLayer = self.gameMap.layers['Base Stage Floor']
    local floorObjectsLayer = self.gameMap.layers['Floor and Wall Objects']
    local wallObjectsLayer = self.gameMap.layers['Wall Objects']
    
    -- Player bottom Y in world coords (32px sprite with origin at 16,16)
    local playerBottomY = self.player.y + 16

    -- Margin so stencil fully covers the sprites around the collider top
    local margin = 32

    -- Check if player is above the stage area
    local stageBehindPlayer = false
    if self.stageArea and self.stageArea.y < playerBottomY then
        stageBehindPlayer = true
    end
    
    -- Draw the stage layer once behind the player (if player is above stage)
    if stageBehindPlayer and stageLayer then
        love.graphics.setColor(1, 1, 1, 1)
        self.gameMap:drawLayer(stageLayer)
    end

    -- Draw benches and plants whose collider top is above player's bottom (behind player)
    for _, r in ipairs(self.benchRects) do
        if r.y < playerBottomY then
            love.graphics.stencil(function()
                love.graphics.rectangle('fill', r.x - margin, r.y - margin, r.w + margin * 2, r.h + margin * 2)
            end, 'replace', 1)
            love.graphics.setStencilTest('equal', 1)
            
            -- Draw benches layer if it exists
            if benchesLayer then
                love.graphics.setColor(1, 1, 1, 1)
                self.gameMap:drawLayer(benchesLayer)
            end
            
            -- Draw floor objects (plants) if they exist
            if floorObjectsLayer then
                love.graphics.setColor(1, 1, 1, 1)
                self.gameMap:drawLayer(floorObjectsLayer)
            end
            
            love.graphics.setStencilTest()
        end
    end

    -- Draw wall objects that don't need depth sorting (always behind player)
    if wallObjectsLayer then
        love.graphics.setColor(1, 1, 1, 1)
        self.gameMap:drawLayer(wallObjectsLayer)
    end

    -- Draw player between the two groups
    love.graphics.setColor(1, 1, 1, 1) -- Reset color before drawing player
    self.player:draw(self.cam.scale)

    -- Check if player is below the stage area
    local stageInFrontPlayer = false
    if self.stageArea and self.stageArea.y >= playerBottomY then
        stageInFrontPlayer = true
    end
    
    -- Draw stage layer once in front of the player (if player is below stage)
    if stageInFrontPlayer and stageLayer then
        love.graphics.setColor(1, 1, 1, 1)
        self.gameMap:drawLayer(stageLayer)
    end

    -- Draw benches and plants whose collider top is at/under player's bottom (in front of player)
    for _, r in ipairs(self.benchRects) do
        if r.y >= playerBottomY then
            love.graphics.stencil(function()
                love.graphics.rectangle('fill', r.x - margin, r.y - margin, r.w + margin * 2, r.h + margin * 2)
            end, 'replace', 1)
            love.graphics.setStencilTest('equal', 1)
            
            -- Draw benches layer if it exists
            if benchesLayer then
                love.graphics.setColor(1, 1, 1, 1)
                self.gameMap:drawLayer(benchesLayer)
            end
            
            -- Draw floor objects (plants) if they exist
            if floorObjectsLayer then
                love.graphics.setColor(1, 1, 1, 1)
                self.gameMap:drawLayer(floorObjectsLayer)
            end
            
            love.graphics.setStencilTest()
        end
    end
    
    -- Ensure color is reset at the end
    love.graphics.setColor(1, 1, 1, 1)
end

function GameState:exit()
    -- Clean up game resources if needed
    if self.sounds.music then
        self.sounds.music:stop()
    end
end

return GameState
