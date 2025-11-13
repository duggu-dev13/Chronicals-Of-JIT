-- gameState.lua
-- Main game state (the actual gameplay)

local sti = require 'libraries/sti'
local Camera = require 'libraries/camera'
local wf = require 'libraries/windfield'
local Player = require 'modules/player'

local GameState = {}

function GameState:new(stateManager)
    local obj = {}
    obj.stateManager = stateManager
    
    -- Game variables (moved from main.lua)
    obj.cam, obj.world, obj.gameMap, obj.player, obj.walls = nil, nil, nil, nil, {}
    obj.benchRects = {}
    obj.stageArea = nil
    obj.debugDraw = false
    obj.sounds = {}
    obj.currentMapPath = nil
    obj.interactAreas = {}
    obj.currentInteractArea = nil
    obj.isLoading = false
    obj.loadingTimer = 0
    obj.pendingMapLoad = nil
    obj.selectedCharacter = 'student'
    obj.playerScaleMultiplier = 1
    obj.mapConfigs = {
        ['maps/college_base_map.lua'] = {
            spawn = { x = 2900, y = 320 },
            simpleDraw = true,
            playerScale = 2,
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
    if not self.cam then
        self.cam = Camera()
        self.cam.scale = 2  -- Default zoom (will be overridden by map config)
    end

    if not self.sounds.music then
        self.sounds.music = love.audio.newSource('sounds/ambience.mp3', 'stream')
        self.sounds.music:setLooping(true)
        self.sounds.music:play()
    elseif not self.sounds.music:isPlaying() then
        self.sounds.music:play()
    end

    local initialMap = 'maps/college_base_map.lua'
    local spawn = self:getSpawnPoint(initialMap)
    self:queueMapLoad(initialMap, spawn)
end

function GameState:update(dt)
    if self.isLoading then
        self.loadingTimer = self.loadingTimer - dt
        if self.loadingTimer <= 0 then
            local pending = self.pendingMapLoad
            self.isLoading = false
            self.pendingMapLoad = nil
            if pending then
                self:loadMap(pending.mapPath, pending.spawn)
            end
        end
        return
    end

    if not self.world or not self.player then return end

    self.world:update(dt)
    self.player:update(dt)

    if self.gameMap and self.gameMap.update then
        self.gameMap:update(dt)
    end

    self:updateInteractState()
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
    
    if not self.isLoading then
        self:drawInteractionPrompt()
    end

    self:drawLoadingOverlay()
    
    -- Ensure color is reset after drawing
    love.graphics.setColor(1, 1, 1, 1)
end

function GameState:keypressed(key)
    if key == 'f1' then
        self.debugDraw = not self.debugDraw
    elseif key == 'e' then
        self:handleInteraction()
    elseif key == 'escape' then
        self.stateManager:setState("menu")
    end
end

-- ===================== WALLS =====================
function GameState:initWalls()
    self.walls = {}
    self.benchRects = {}

    if not self.gameMap or not self.world then return end

    local layersToCheck = { "Walls", "Walls and Buildings" }

    for _, layerName in ipairs(layersToCheck) do
        local layer = self.gameMap.layers[layerName]
        if layer and layer.objects then
            local offsetX = layer.offsetx or 0
            local offsetY = layer.offsety or 0

            for _, obj in ipairs(layer.objects) do
                local shape = obj.shape
                local x = (obj.x or 0) + offsetX
                local y = (obj.y or 0) + offsetY
                local collider = nil

                if shape == "rectangle" then
                    collider = self.world:newRectangleCollider(x, y, obj.width, obj.height)
                    if obj.width and obj.height and obj.width <= 40 and obj.height <= 40 then
                        table.insert(self.benchRects, {
                            x = x, y = y, w = obj.width, h = obj.height
                        })
                    end
                elseif shape == "ellipse" then
                    local radius = math.max(obj.width or 0, obj.height or 0) / 2
                    local cx = x + (obj.width or 0) / 2
                    local cy = y + (obj.height or 0) / 2
                    collider = self.world:newCircleCollider(cx, cy, radius)
                end

                if collider then
                    collider:setType("static")
                    table.insert(self.walls, collider)
                end
            end
        end
    end

    -- Add stage area for depth sorting
    self:initStageArea()
end

-- ===================== STAGE AREA & PLANTS =====================
function GameState:initStageArea()
    self.stageArea = nil

    local stageLayer = self.gameMap and self.gameMap.layers and self.gameMap.layers["Base Stage Floor"]
    if stageLayer and stageLayer.objects and #stageLayer.objects > 0 then
        local stageObj = stageLayer.objects[1]
        local offsetX = stageLayer.offsetx or 0
        local offsetY = stageLayer.offsety or 0
        self.stageArea = {
            x = (stageObj.x or 0) + offsetX,
            y = (stageObj.y or 0) + offsetY,
            w = stageObj.width,
            h = stageObj.height
        }
    end

    local floorObjectsLayer = self.gameMap.layers["Floor and Wall Objects"]
    if floorObjectsLayer and floorObjectsLayer.objects then
        for _, obj in ipairs(floorObjectsLayer.objects) do
            table.insert(self.benchRects, {
                x = obj.x + (floorObjectsLayer.offsetx or 0),
                y = obj.y + (floorObjectsLayer.offsety or 0),
                w = obj.width,
                h = obj.height
            })
        end
    end

    local benchesLayer = self.gameMap.layers["Benches and Vegetation"]
    if benchesLayer and benchesLayer.objects then
        for _, obj in ipairs(benchesLayer.objects) do
            table.insert(self.benchRects, {
                x = obj.x + (benchesLayer.offsetx or 0),
                y = obj.y + (benchesLayer.offsety or 0),
                w = obj.width,
                h = obj.height
            })
        end
    end

    if not self.stageArea then
        local config = self.mapConfigs[self.currentMapPath or ""] or {}
        local stageConfig = config.stageArea
        if stageConfig then
            self.stageArea = {
                x = stageConfig.x,
                y = stageConfig.y,
                w = stageConfig.w,
                h = stageConfig.h
            }
        end
    end
end

function GameState:getSpawnPoint(mapPath)
    local config = self.mapConfigs[mapPath]
    if config and config.spawn then
        return { x = config.spawn.x, y = config.spawn.y }
    end
    return { x = 200, y = 100 }
end

function GameState:getInteractionConfigs(mapPath)
    local config = self.mapConfigs[mapPath]
    if config and config.interactions then
        return config.interactions
    end
    return {}
end

function GameState:setSelectedCharacter(characterId)
    if Player.characterConfigs[characterId] then
        self.selectedCharacter = characterId
    else
        self.selectedCharacter = 'student'
    end
end

function GameState:prepareNewGame(characterId)
    self:setSelectedCharacter(characterId)

    if self.player and self.player.sounds and self.player.sounds.footstep:isPlaying() then
        self.player.sounds.footstep:stop()
    end

    if self.world and self.world.destroy then
        self.world:destroy()
    end

    self.world = nil
    self.gameMap = nil
    self.player = nil
    self.currentMapPath = nil
    self.interactAreas = {}
    self.currentInteractArea = nil
    self.stageArea = nil
    self.isLoading = false
    self.loadingTimer = 0
    self.pendingMapLoad = nil
end

function GameState:collectInteractAreas()
    self.interactAreas = {}
    if not self.gameMap then return end

    for _, interaction in ipairs(self:getInteractionConfigs(self.currentMapPath)) do
        local layer = self.gameMap.layers[interaction.layer]
        if layer and layer.objects then
            local offsetX = layer.offsetx or 0
            local offsetY = layer.offsety or 0
            for _, obj in ipairs(layer.objects) do
                table.insert(self.interactAreas, {
                    name = interaction.layer,
                    prompt = interaction.prompt or "Press E",
                    action = interaction.action,
                    targetMap = interaction.targetMap,
                    targetSpawn = interaction.targetSpawn,
                    x = (obj.x or 0) + offsetX,
                    y = (obj.y or 0) + offsetY,
                    w = obj.width or 0,
                    h = obj.height or 0
                })
            end
        end
    end
end

function GameState:queueMapLoad(mapPath, spawn)
    self.pendingMapLoad = {
        mapPath = mapPath,
        spawn = spawn and { x = spawn.x, y = spawn.y } or nil
    }
    self.isLoading = true
    self.loadingTimer = 1.5

    if self.player then
        if self.player.sounds and self.player.sounds.footstep:isPlaying() then
            self.player.sounds.footstep:stop()
        end
        if self.player.collider then
            self.player.collider:setLinearVelocity(0, 0)
        end
    end
end

function GameState:loadMap(mapPath, spawnOverride)
    if self.world and self.world.destroy then
        self.world:destroy()
    end

    local config = self.mapConfigs[mapPath] or {}
    self.playerScaleMultiplier = config.playerScale or 1

    -- Apply camera scale from map config
    if self.cam and config.cameraScale then
        self.cam.scale = config.cameraScale
    end

    self.currentMapPath = mapPath
    self.gameMap = sti(mapPath)
    self.world = wf.newWorld(0, 0, true)
    self.walls = {}
    self.benchRects = {}
    self.interactAreas = {}
    self.currentInteractArea = nil

    local spawn = spawnOverride or self:getSpawnPoint(mapPath)

    if self.player and self.player.sounds and self.player.sounds.footstep:isPlaying() then
        self.player.sounds.footstep:stop()
    end

    self:initWalls()
    self:collectInteractAreas()

    local validSpawn = {
        x = (spawn and spawn.x) or 200,
        y = (spawn and spawn.y) or 100
    }
    self.player = Player:new(self.world, validSpawn, self.selectedCharacter)

    if self.cam then
        self.cam:lookAt(self.player.x, self.player.y)
    end

    self:updateCamera()
    self.isLoading = false
    self.loadingTimer = 0
end

function GameState:updateInteractState()
    self.currentInteractArea = nil
    if not self.interactAreas then return end

    if not self.player or not self.player.collider then return end

    local colliderX, colliderY = self.player.collider:getPosition()
    local px = colliderX
    local py = self.player.getBottomY and self.player:getBottomY() or ((self.player.y or colliderY) + 16)

    for _, area in ipairs(self.interactAreas) do
        if px >= area.x and px <= area.x + area.w and py >= area.y and py <= area.y + area.h then
            self.currentInteractArea = area
            break
        end
    end
end

function GameState:drawInteractionPrompt()
    if not self.currentInteractArea then return end

    local prompt = self.currentInteractArea.prompt or "Press E"
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(prompt, 0, love.graphics.getHeight() - 60, love.graphics.getWidth(), 'center')
end

function GameState:handleInteraction()
    if not self.currentInteractArea then return end

    local area = self.currentInteractArea
    if area.action == 'load_map' and area.targetMap then
        local spawn = area.targetSpawn or self:getSpawnPoint(area.targetMap)
        self:queueMapLoad(area.targetMap, spawn)
    end
end

function GameState:drawLoadingOverlay()
    if not self.isLoading then return end

    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle('fill', 0, 0, width, height)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Loading...", 0, height / 2 - 16, width, 'center')
end

-- ===================== CAMERA =====================
function GameState:updateCamera()
    if not self.cam or not self.player or not self.gameMap then return end

    self.cam:lookAt(self.player.x, self.player.y)

    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local mapWidth = (self.gameMap.width or 0) * (self.gameMap.tilewidth or 0)
    local mapHeight = (self.gameMap.height or 0) * (self.gameMap.tileheight or 0)

    if mapWidth == 0 or mapHeight == 0 then
        return
    end

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
function GameState:drawSimpleScene()
    if not self.gameMap then return end

    for _, layer in ipairs(self.gameMap.layers) do
        if layer.type == "tilelayer" or layer.type == "imagelayer" then
            love.graphics.setColor(1, 1, 1, 1)
            self.gameMap:drawLayer(layer)
        end
    end

    if self.player then
        love.graphics.setColor(1, 1, 1, 1)
        local cameraScale = self.cam and self.cam.scale or 1
        self.player:draw(cameraScale, self.playerScaleMultiplier)
    end
end

function GameState:drawSceneWithDepth()
    if not self.gameMap then
        return
    end

    local config = self.mapConfigs[self.currentMapPath or ""]
    if config and config.simpleDraw then
        self:drawSimpleScene()
        return
    end

    if not self.player then
        return
    end

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
    
    local playerBottomY = self.player.getBottomY and self.player:getBottomY() or (self.player.y + 16)

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
    self.player:draw(self.cam.scale, self.playerScaleMultiplier)

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
