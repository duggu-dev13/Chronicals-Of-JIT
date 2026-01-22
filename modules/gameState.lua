local sti = require 'libraries/sti'
local wf = require 'libraries/windfield'
local Player = require 'modules/player'
local PhoneOS = require 'modules/phone/phoneOS'
local CareerManager = require 'modules/careerManager'
local TravelMenu = require 'modules/ui/travelMenu'
local MessageManager = require 'modules/messageManager'
local QuestManager = require 'modules/questManager'
local ShopMenu = require 'modules/ui/shopMenu' -- Import ShopMenu
local StatusMenu = require 'modules/ui/statusMenu' -- Import StatusMenu
local StudyGame = require 'modules/minigames/studyGame' -- Restored Missing Import
local ExamGame = require 'modules/minigames/examGame' -- New PCG Exam
local StoryManager = require 'modules/storyManager' -- Story/Prologue
local FormMenu = require 'modules/ui/formMenu' -- Admission Form
local ResourceManager = require 'modules/resourceManager'
local NPCManager = require 'modules/npcManager'
local ClassroomManager = require 'modules/classroomManager'

local GameState = {}

function GameState:new(stateManager)
    local obj = {
        stateManager = stateManager,
        world = nil,
        gameMap = nil,
        player = nil,
        cam = require('libraries/camera')(),
        mapConfigs = require('data/maps'),
        currentMapPath = nil,
        interactAreas = {},
        currentInteractArea = nil,
        debugDraw = false,
        
        -- Modules
        timeSystem = require('modules/timeSystem'):new(), -- Global Time
        hud = require('modules/hud'):new(),
        phone = nil,
        careerManager = nil,
        travelMenu = nil,
        shopMenu = nil,
        statusMenu = nil,
        
        -- Travel Animation State
        isTraveling = false,
        travelTimer = 0,
        busX = -200,
        travelTarget = nil,
        
        -- Loading State
        isLoading = false,
        loadingTimer = 0,
        pendingMapLoad = nil,
        
        -- Stage & Depth
        stageArea = nil,
        benchRects = {},
        walls = {},
        
        -- Config
        playerScaleMultiplier = 1,
        selectedCharacter = 'student',
        
        -- Audio
        sounds = {}
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function GameState:init()
    -- Initialize things that don't depend on a specific game session
end

function GameState:enter()
    self:initGame()
end

function GameState:initGame()
    if not self.phone then
        self.phone = PhoneOS:new()
    end
    
    if not self.careerManager then
        self.careerManager = CareerManager:new()
        -- Default path based on selection
        self.careerManager:setPath(self.selectedCharacter)
        
        -- Hook up Money Animation
        self.careerManager.onMoneyChanged = function(amount)
            if self.hud then self.hud:addMoneyPopup(amount) end
        end
    elseif not self.careerManager.onMoneyChanged then
        -- Ensure callback is set if manager already exists (hot-reload safety)
        self.careerManager.onMoneyChanged = function(amount)
            if self.hud then self.hud:addMoneyPopup(amount) end
        end
    end
    
    if not self.messageManager then
        self.messageManager = MessageManager:new({
            onNotify = function(msg) 
                if self.hud then self.hud:addNotification(msg) end 
            end
        })
    end

    if not self.questManager then
        self.questManager = QuestManager:new({
            onNotify = function(msg)
                if self.hud then self.hud:addNotification(msg) end
            end
        })
    end
    
    if not self.travelMenu then
        self.travelMenu = TravelMenu:new()
    end

    if not self.shopMenu then
        self.shopMenu = ShopMenu:new(self)
    end

    if not self.statusMenu then
        self.statusMenu = StatusMenu:new(self)
    end

    if not self.studyGame then
        self.studyGame = StudyGame:new({
            onComplete = function(score)
                self:endMinigame(score)
            end
        })
    end

    if not self.examGame then
        self.examGame = ExamGame:new({
            onComplete = function(score)
                self:endMinigame(score, 'exam')
            end
        })
    end
    
    if not self.storyManager then
        self.storyManager = StoryManager:new(self)
    end
    
    if not self.formMenu then
        self.formMenu = FormMenu:new(self)
    end
    
    if not self.npcManager then
        self.npcManager = NPCManager:new(self)
    end
    
    if not self.classroomManager then
        self.classroomManager = ClassroomManager:new(self)
    end

    if not self.sounds.music then
        self.sounds.music = ResourceManager.getSound('sounds/ambience.mp3', 'stream')
        if self.sounds.music then
            self.sounds.music:setLooping(true)
            self.sounds.music:play()
        end
    elseif not self.sounds.music:isPlaying() then
        self.sounds.music:play()
    end

    local initialMap = 'maps/college_base_map.lua'
    local spawn = self:getSpawnPoint(initialMap)
    self:queueMapLoad(initialMap, spawn)
    
    -- Auto-Start Prologue (Delayed until load finishes)
    if self.storyManager then
        self.pendingPrologue = true
    end
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
                -- Apply Travel Time Cost
                if self.timeSystem and pending.travelCost then
                    -- Fix: Add directly to minutes, not accumulated seconds
                    self.timeSystem:addMinutes(pending.travelCost)
                    print("Travel Cost Applied: " .. pending.travelCost .. " mins")
                    
                    -- Energy Cost for Travel (e.g., 0.5 energy per minute of travel?)
                    -- Let's say flat cost for now or small drain
                    if self.careerManager then
                        local energyCost = 5 -- Flat cost per trip
                        self.careerManager:modifyEnergy(-energyCost)
                    end
                end
            end
        end
        return
    end
    
    -- Check Delayed Start
    if self.pendingPrologue and self.storyManager then
        self.pendingPrologue = false
        self.storyManager:startPrologue()
    end
    
    -- ===================== INPUT BLOCKING =====================
    if self:isInputBlocked() then
        -- Update ONLY the active blocking element
        if self.phone and self.phone.isOpen then self.phone:update(dt) end
        if self.studyGame and self.studyGame.isActive then self.studyGame:update(dt) end
        if self.examGame and self.examGame.isActive then self.examGame:update(dt) end -- Update Exam
        if self.formMenu and self.formMenu.isOpen then self.formMenu:update(dt) end
        if self.storyManager and self.storyManager.dialogueActive then self.storyManager:update(dt) end
        if self.classroomManager and self.classroomManager.isActive then self.classroomManager:update(dt) end
        
        if self.isTraveling then self:updateTravelSequence(dt) end
        
        -- PAUSE World/Player/Time interactions
        return
    end
    -- ==========================================================

    if not self.world or not self.player then return end

    self.world:update(dt)
    self.player:update(dt)

    if self.npcManager then
        self.npcManager:update(dt)
    end
    
    if self.classroomManager then
        self.classroomManager:update(dt)
    end

    if self.gameMap and self.gameMap.update then
        self.gameMap:update(dt)
    end

    self:updateInteractState()
    self:updateCamera()
    
    if self.hud then
        self.hud:update(dt)
    end
    
    if self.timeSystem then
         -- Time updates (if any passive logic exists)
    end
end

function GameState:isInputBlocked()
    return (self.phone and self.phone.isOpen) or
           (self.travelMenu and self.travelMenu.isOpen) or
           (self.shopMenu and self.shopMenu.isOpen) or
           (self.statusMenu and self.statusMenu.isOpen) or
           (self.studyGame and self.studyGame.isActive) or
           (self.examGame and self.examGame.isActive) or -- Block for Exam
           (self.formMenu and self.formMenu.isOpen) or -- Block for Form
           (self.storyManager and self.storyManager.dialogueActive) or -- Block for Story
           (self.classroomManager and self.classroomManager.isActive) or -- Block for Class
           (self.isTraveling) or
           (self.isLoading)
end

function GameState:draw()
    -- Reset color to white before drawing
    love.graphics.setColor(1, 1, 1, 1)
    
    self.cam:attach()
        self:drawYSortedScene()
        
        if self.debugDraw then
            love.graphics.setColor(0, 1, 0, 0.8)
            self.world:draw()
            love.graphics.setColor(1, 1, 1, 1)
        end
    self.cam:detach()
    
    if not self.isLoading then
        -- self:drawDebugZones() -- Debug disabled
        self:drawInteractionPrompt()
        
        -- Debug: Live Coordinates (Minecraft Style)
        if self.player then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(string.format("X: %.1f Y: %.1f", self.player.x or 0, self.player.y or 0), 10, 100)
        end
        
        if self.hud and self.timeSystem and self.careerManager then
            self.hud:draw(
                self.timeSystem:getTimeString(), 
                self.timeSystem:getDay(), 
                self.careerManager.money, 
                self.careerManager.energy
            )
        end
        
        if self.phone then
            -- Updated to pass TimeSystem as 4th argument, Player as 5th
            self.phone:draw(self.careerManager, self.messageManager, self.questManager, self.timeSystem, self.player)
        end
        
        if self.travelMenu then
            self.travelMenu:draw()
        end
        
        if self.shopMenu then
            self.shopMenu:draw()
        end
        
        if self.statusMenu then
            self.statusMenu:draw()
        end
        
        if self.isTraveling then
             self:drawBus()
        end
        
        if self.studyGame and self.studyGame.isActive then
            self.studyGame:draw()
        end
    end
    
    -- FORCE DRAW ON TOP (Debug Fix)
    if self.studyGame and self.studyGame.isActive then
        self.studyGame:draw()
    end
    if self.examGame and self.examGame.isActive then
        self.examGame:draw()
    end
    
    if self.formMenu and self.formMenu.isOpen then
        self.formMenu:draw()
    end
    
    if self.classroomManager then
        self.classroomManager:draw()
    end
    
    if self.storyManager then
        self.storyManager:draw()
    end

    self:drawLoadingOverlay()
    
    -- Ensure color is reset after drawing
    love.graphics.setColor(1, 1, 1, 1)
end

function GameState:keypressed(key, action)
    -- PRIORITY: Check Minigame Input FIRST
    print("[GameState] keypressed: " .. key .. " (" .. tostring(action) .. ") on " .. tostring(self))
    
    if self.studyGame and self.studyGame.isActive then
        print("[GameState] Blocked by StudyGame")
        self.studyGame:keypressed(key)
        return 
    end
    
    if self.examGame and self.examGame.isActive then
         print("[GameState] Blocked by ExamGame")
        self.examGame:keypressed(key)
        return
    end
    
    if self.storyManager and self.storyManager.dialogueActive then
        print("[GameState] Blocked by StoryManager (Dialogue Active)")
        self.storyManager:keypressed(key)
        return
    end
    
    if self.classroomManager and self.classroomManager.isActive then
        print("[GameState] Blocked by ClassroomManager")
        self.classroomManager:keypressed(key)
        return
    end
    
    if self.formMenu and self.formMenu.isOpen then
        print("[GameState] Blocked by FormMenu")
        self.formMenu:keypressed(key)
        return
    end

    -- Global Keys (Status Menu, Phone)
    if action == 'status' then
        if self.statusMenu then
             self.statusMenu:toggle()
             return
        end
    end
    
    if self.statusMenu and self.statusMenu.isOpen then
        self.statusMenu:keypressed(key)
        return -- Input Sink
    end

    if action == 'debug' then
        self.debugDraw = not self.debugDraw
    elseif action == 'phone' then
        if self.phone then
            self.phone:toggle()
        end
    elseif action == 'interact' then
        print("[GameState] Interact Action Received. PhoneOpen: " .. tostring(self.phone and self.phone.isOpen))
        if self.phone and self.phone.isOpen then return end
        if self.travelMenu and self.travelMenu.isOpen then return end
        if self.shopMenu and self.shopMenu.isOpen then return end -- Block interact if shop open
        self:handleInteraction()
    elseif action == 'menu' then
        self.stateManager:setState("menu")
    elseif key == 'f8' then
        -- DEBUG: Force Start Minigame
        print("F8 Pressed: Force Starting Study Game")
        self:startMinigame('study')
    elseif key == 'f4' then
        -- DEBUG: Toggle NPC Debug Info
        if self.npcManager then self.npcManager:toggleDebug() end
        if self.hud then self.hud:addNotification("Toggled NPC Debug") end
    elseif key == 'f9' then
        -- DEBUG: Force Start Exam
        print("F9 Pressed: Force Starting Exam")
        self:startMinigame('exam')
    elseif key == 'f7' then
        -- DEBUG: Force Start Admission Form
        if self.formMenu then self.formMenu:open() end
    elseif key == 'f6' then
         -- DEBUG: Force Prologue
         if self.storyManager then self.storyManager:startPrologue() end
    elseif self.studyGame and self.studyGame.isActive then
        self.studyGame:keypressed(key)
    end
end

-- ===================== WALLS =====================
function GameState:initWalls()
    self.walls = {}
    self.benchRects = {}

    if not self.gameMap or not self.world then return end

    local layersToCheck = { "Walls", "Walls and Buildings", "College", "Canteen", "Canten" }

    for _, layerName in ipairs(layersToCheck) do
        local layer = self.gameMap.layers[layerName]
        if layer and layer.objects then
            local offsetX = layer.offsetx or 0
            local offsetY = layer.offsety or 0

            for _, obj in ipairs(layer.objects) do
                -- User Request: Named objects are Interaction Zones (Non-Wall)
                if obj.name and obj.name ~= "" then
                    -- Skip collision generation for named interaction zones
                else
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
                    -- High-Res Ellipse using Chain Loop (Smoother than Polygon)
                    local rx = (obj.width or 0) / 2
                    local ry = (obj.height or 0) / 2
                    local cx = x + rx
                    local cy = y + ry
                    
                    local vertices = {}
                    local segments = 24 -- 24 points for very smooth loop
                    for i = 0, segments - 1 do
                        local angle = (i / segments) * math.pi * 2
                        local vx = cx + math.cos(angle) * rx
                        local vy = cy + math.sin(angle) * ry
                        table.insert(vertices, vx)
                        table.insert(vertices, vy)
                    end
                    
                    -- Use Chain Collider (Loop) for smooth walls
                    -- Note: Chain Colliders are hollow (edges only), which is fine for walls.
                    -- If loop is true, it connects first and last point.
                    if self.world.newChainCollider then
                         collider = self.world:newChainCollider(vertices, true)
                    else
                         -- Fallback if windfield version differs (should prevent crash)
                         -- Reduce to 8 for Polygon fallback
                         local polyVerts = {}
                         local polySegs = 8
                         for i = 0, polySegs - 1 do
                            local angle = (i / polySegs) * math.pi * 2
                            local vx = cx + math.cos(angle) * rx
                            local vy = cy + math.sin(angle) * ry
                            table.insert(polyVerts, vx)
                            table.insert(polyVerts, vy)
                         end
                         collider = self.world:newPolygonCollider(polyVerts)
                    end
                end

                if collider then
                    collider:setType("static")
                    table.insert(self.walls, collider)
                end
            end -- Close else block
        end -- Close if obj.name block
    end -- Close for obj loop
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
        -- 1. Manual/Hardcoded Zone
        if interaction.x and interaction.y then
             table.insert(self.interactAreas, {
                name = interaction.layer or "Manual",
                prompt = interaction.prompt or "Press E",
                action = interaction.action,
                targetMap = interaction.targetMap,
                targetSpawn = interaction.targetSpawn,
                type = interaction.type, -- Fix: Copy minigame type
                x = interaction.x,
                y = interaction.y,
                w = interaction.w or 32, -- Fix: Add default width
                h = interaction.h or 32
            })
        -- 2. Tiled Object Layer Zone (From Config)
        elseif interaction.layer and self.gameMap.layers[interaction.layer] then
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
                        type = interaction.type, 
                        x = (obj.x or 0) + offsetX,
                        y = (obj.y or 0) + offsetY,
                        w = obj.width or 0,
                        h = obj.height or 0,
                        shape = obj.shape -- Preserve shape for drawing
                    })
                end
            end
        end
    end
    
    -- 3. Auto-Scan for Benches (Dynamic Interaction)
    if self.gameMap.layers["Benches and Vegetation"] then
        local layer = self.gameMap.layers["Benches and Vegetation"]
        if layer and layer.objects then
            for _, obj in ipairs(layer.objects) do
                -- Check for 'benchId' property or similar if needed, or just all objects on this layer
                if obj.properties and obj.properties["benchId"] then
                     table.insert(self.interactAreas, {
                         name = "Bench",
                         prompt = "Press E to Attend Class",
                         action = "class",
                         x = (obj.x or 0),
                         y = (obj.y or 0),
                         w = obj.width or 32,
                         h = obj.height or 32
                     })
                end
            end
        end
    end

    -- 4. Dynamic Tiled Zones (User Named Areas)
    -- Define Zone Mapping: Name in Tiled -> Action/Prompt
    local zoneMap = {
        ["Canteen_Entrance"] = { action = "canteen", prompt = "Press E to Enter Canteen" },
        ["Library_Entrance"] = { action = "library", prompt = "Press E to Enter Library" },
        ["Classroom_Entrance"] = { action = "class", prompt = "Press E to Attend Class" },
        ["Hostel_Entrance"] = { action = "hostel_lobby", prompt = "Press E to Enter Hostel" },
        ["Notice_Board"] = { action = "notice", prompt = "Press E to Read Notice" },
        ["Bench_Seat"] = { action = "bench", prompt = "Press E to Sit" },
        ["Transport_Menu"] = { action = "load_map", type = "travel", prompt = "Press E to Open Map" },
        ["Garden_Hangout"] = { action = nil, prompt = nil }, -- NPC AI Zone only
    }

    local layersToScan = { 
        "College", "Canteen", "Walls and Buildings", "InteractionZones",
        "Classroom_Entrance", "Canteen_Entrance", "Bench_Seat", "Transport_Menu"
    }
    
    -- Removed debug print loop
    
    for _, layerName in ipairs(layersToScan) do
        local layer = self.gameMap.layers[layerName]
        if layer and layer.objects then
            local offsetX = layer.offsetx or 0
            local offsetY = layer.offsety or 0
            
            -- Check if the LAYER itself defines the zone type (e.g. layer "Canteen_Entrance")
            local layerConfig = zoneMap[layerName]

            for _, obj in ipairs(layer.objects) do
                -- Priority: 1. Object Properties (Manual Override), 2. Object Name Map, 3. Layer Name Map
                local config = zoneMap[obj.name] or layerConfig
                local manualProps = obj.properties or {}
                
                -- Construct config from properties if available
                if manualProps.action then
                    config = {
                        action = manualProps.action,
                        targetMap = manualProps.targetMap,
                        targetZone = manualProps.targetZone, -- Use zone name instead of coords
                        prompt = manualProps.prompt,
                        type = manualProps.type
                    }
                end
                
                if config and config.action then
                     table.insert(self.interactAreas, {
                         name = (obj.name and obj.name ~= "") and obj.name or layerName,
                         prompt = config.prompt,
                         action = config.action,
                         targetMap = config.targetMap,
                         targetZone = config.targetZone, -- Propagate zone target
                         type = config.type, -- Fix: Propagate type
                         x = (obj.x or 0) + offsetX,
                         y = (obj.y or 0) + offsetY,
                         w = obj.width or 32,
                         h = obj.height or 32,
                         shape = obj.shape
                     })
                end
            end
        end
    end
end

function GameState:queueMapLoad(mapPath, spawn)
    -- Calculate Travel Cost
    local travelCost = 0
    if self.locationManager and self.currentMapPath then
        travelCost = self.locationManager:getTravelTime(self.currentMapPath, mapPath)
    end

    self.pendingMapLoad = {
        mapPath = mapPath,
        spawn = spawn and { x = spawn.x, y = spawn.y, zone = spawn.zone } or nil,
        travelCost = travelCost -- Store cost to apply later
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
    if self.npcManager then
        self.npcManager:clearAgents()
    end

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
    
    -- Phase 6: Sortable Tiles (Rolled back)
    -- Standard Tiled rendering used.

    local validSpawn = {
        x = (spawn and spawn.x) or 200,
        y = (spawn and spawn.y) or 100
    }
    
    -- Zone-Based Spawn (Randomized)
    if spawn and spawn.zone then
        -- Find the zone in the NEWLY loaded map
        for _, area in ipairs(self.interactAreas) do
            if area.name == spawn.zone then
                -- Pick random point inside zone
                validSpawn.x = area.x + math.random(0, area.w)
                validSpawn.y = area.y + math.random(0, area.h)
                print("[Spawn] Found Zone '" .. spawn.zone .. "'. Random Spawn at: " .. validSpawn.x .. ", " .. validSpawn.y)
                break
            end
        end
    end
    self.player = Player:new(self.world, validSpawn, self.selectedCharacter)

    if self.cam then
        self.cam:lookAt(self.player.x, self.player.y)
    end

    self:updateCamera()
    self.isLoading = false
    self.loadingTimer = 0
    
    -- Quest Updates (Tutorial)
    if self.questManager then
        if mapPath ~= 'maps/hostel.lua' then
            -- Objective 1: Leave Hostel
            self.questManager:completeObjective("tutorial_01", 1)
        end
        
        if mapPath == 'maps/college_base_map.lua' then
             -- Objective 2: Go to College
            self.questManager:completeObjective("tutorial_01", 2)
            
            -- Spawn NPCs
            if self.npcManager then
                self.npcManager:refreshZones(self)
                -- Spawn around player start + jitter
                self.npcManager:spawnNPCs(15, validSpawn.x, validSpawn.y)
            end
        elseif mapPath == 'maps/hostel.lua' or mapPath == 'maps/canteen.lua' then
             -- Small population for interiors
             if self.npcManager then
                self.npcManager:refreshZones(self)
                self.npcManager:spawnNPCs(3, validSpawn.x, validSpawn.y)
             end
        end
    end
end

function GameState:updateInteractState()
    self.currentInteractArea = nil
    if not self.interactAreas then return end

    if not self.player or not self.player.collider then return end

    local colliderX, colliderY = self.player.collider:getPosition()
    local px = colliderX
    local py = self.player.getBottomY and self.player:getBottomY() or ((self.player.y or colliderY) + 16)

    -- DEBUG: Once per second
    self.debugTimer = (self.debugTimer or 0) + 1
    if self.debugTimer % 60 == 0 then
         print(string.format("[Debug] Interact Check: P(%.1f, %.1f) vs %d Areas", px, py, #self.interactAreas))
    end

    for _, area in ipairs(self.interactAreas) do
        if px >= area.x and px <= area.x + area.w and py >= area.y and py <= area.y + area.h then
            self.currentInteractArea = area
            if self.debugTimer % 60 == 0 then print("  -> INSIDE: " .. (area.name or "Unnamed")) end
            break
        end
    end
end

function GameState:drawInteractionPrompt()
    if not self.currentInteractArea then return end

    local prompt = self.currentInteractArea.prompt or "Press E"
    local w, h = love.graphics.getDimensions()
    
    -- Background (200px height at bottom)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, h - 200, w, 200)
    
    -- Text (Centered in the box)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(prompt, 0, h - 110, w, 'center') -- Centered roughly in the 200px box
end

-- DEBUG: Draw all interaction zones
function GameState:drawDebugZones()
    love.graphics.setColor(1, 0, 0, 0.3)
    for _, area in ipairs(self.interactAreas) do
        love.graphics.rectangle("line", area.x, area.y, area.w, area.h)
        love.graphics.print(area.name or "Zone", area.x, area.y - 15)
        
        -- Highlight current
        if self.currentInteractArea == area then
            love.graphics.setColor(0, 1, 0, 0.5)
            love.graphics.rectangle("fill", area.x, area.y, area.w, area.h)
            love.graphics.setColor(1, 0, 0, 0.3)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function GameState:handleInteraction()
    print("[GameState] handleInteraction called. Current Area: " .. (self.currentInteractArea and self.currentInteractArea.name or "Nil"))
    if not self.currentInteractArea then return end

    local area = self.currentInteractArea
    
    if area.action == 'load_map' then
        -- 1. Travel Gate (Special Case - ONLY if not in Classroom)
        local isClassroom = self.currentMapPath == 'maps/tileSet.lua'
        local triggersMenu = (area.type == 'travel' or area.name == 'Gate')
        print("[GameState] Travel Logic: triggersMenu="..tostring(triggersMenu)..", isClassroom="..tostring(isClassroom))
        
        if triggersMenu and self.travelMenu and not isClassroom then
             print("[GameState] Opening Travel Menu")
             self.travelMenu:open(self.currentMapPath)
             return
        end
        
        -- 2. Normal Map Transition
        if area.targetMap then
            local spawn = nil
            if area.targetZone then
                spawn = { zone = area.targetZone }
            elseif area.targetSpawn then
                spawn = area.targetSpawn
            else
                spawn = self:getSpawnPoint(area.targetMap)
            end

            -- FIX: Force spawn zone when leaving specific maps (e.g. Canteen -> Main)
            if self.currentMapPath == 'maps/canteen.lua' and area.targetMap == 'maps/college_base_map.lua' then
                spawn = { zone = "Canteen_Entrance" }
                print("[GameState] Leaving Canteen. Forcing Spawn Zone: Canteen_Entrance")
            end
            
            self:queueMapLoad(area.targetMap, spawn)
        end

    elseif area.action == 'minigame' then
        -- 3. Minigame Trigger
        print("Trigering minigame: " .. tostring(area.type))
        self:startMinigame(area.type)
        
    elseif area.action == 'sleep' then
        -- 4. Sleep Trigger
        if self.careerManager and self.timeSystem then
            local currentTime = self.timeSystem.totalMinutes
            local success, reason = self.careerManager:sleep(currentTime)
            
            if success then
                -- Advance Time (8 hours = 480 mins)
                self.timeSystem:addMinutes(480)
                
                if self.hud then
                    self.hud:addNotification("You slept well. Energy restored.")
                end
            else
                -- Failed to sleep
                if self.hud then
                    self.hud:addNotification(reason or "Cannot sleep now.")
                end
            end
        end
        
    elseif area.action == 'eat' then
        -- 5. Eat Trigger
        if self.careerManager then
            local success, reason = self.careerManager:eat()
            if success then
                -- Animation handles money notification, but we can add energy one
                if self.hud then
                    self.hud:addNotification("Yummy! Energy +20")
                end
            else
                if self.hud then
                    self.hud:addNotification(reason or "Cannot eat.")
                end
            end
        end
        
    elseif area.action == 'shop' then
        -- 6. Open Shop Menu
        if self.shopMenu then
            self.shopMenu:open()
        end
        
    elseif area.action == 'form' then
        -- 7. Open Admission Form (Prologue)
        if self.formMenu then
            self.formMenu:open()
        end
        
    elseif area.action == 'notice_board' then
        -- 8. Scan QR Code (App Unlock)
        if self.storyManager then
            self.storyManager:triggerEvent("install_app")
        end
        
    elseif area.action == 'class' then
        -- 7. Attend Class (New Event System)
        if self.classroomManager and self.careerManager then
             -- Check Cooldown (90 mins)
             local canAttend = true
             if self.timeSystem and self.careerManager.lastClassTime then
                 local diff = self.timeSystem:getAbsoluteTime() - self.careerManager.lastClassTime
                 if diff < 90 then
                     canAttend = false
                     if self.hud then self.hud:addNotification("Class ended recently. Wait " .. (90 - diff) .. "m.") end
                 end
             end


             
             -- Check Office Hours (9:00 - 16:00)
             if self.timeSystem then
                 local timeStr = self.timeSystem:getTimeString()
                 local hour = tonumber(timeStr:sub(1, 2))
                 if hour < 9 then
                     canAttend = false
                     if self.hud then self.hud:addNotification("Class starts at 9:00 AM.") end
                 elseif hour >= 16 then
                      canAttend = false
                      if self.hud then self.hud:addNotification("Classes are over for today.") end
                 end
             end

             if canAttend then
                 -- Simple check for open hours or energy
                 if self.careerManager.energy < 15 then
                     if self.hud then self.hud:addNotification("Too tired for class.") end
                 else
                     self.classroomManager:startClass()
                 end
             end
        end

    -- NEW HANDLERS for Tiled Zones
    elseif area.action == 'canteen' then
        self:queueMapLoad('maps/canteen.lua', { x = 320, y = 300 })
        
    elseif area.action == 'library' then
        if self.careerManager then
             if self.careerManager.energy < 15 then
                 if self.hud then self.hud:addNotification("Too tired to study.") end
                 return
             end
             self:startMinigame('study')
        end
        
    elseif area.action == 'hostel_lobby' then
        -- Trigger Sleep
        if self.careerManager and self.timeSystem then
             local success, reason = self.careerManager:sleep(self.timeSystem.totalMinutes)
             if success then
                 self.timeSystem:addMinutes(480)
                 if self.hud then self.hud:addNotification("Slept at Hostel. Energy Restored.") end
             else
                 if self.hud then self.hud:addNotification(reason or "Cannot sleep now.") end
             end
        end
        
    elseif area.action == 'bench' then
        if self.careerManager then
            self.careerManager:modifyEnergy(5)
            if self.hud then self.hud:addNotification("Rested on bench. +5 Energy.") end
        end
        
    elseif area.action == 'notice' then
        if self.storyManager then
            self.storyManager:triggerEvent("install_app")
        end
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
    if self.gameMap.drawLayer then
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
end

-- Draw scene with benches depth-sorted against player using world-space stencil
function GameState:drawSimpleScene()
    if not self.gameMap then return end

    if self.gameMap.layers then
        for _, layer in ipairs(self.gameMap.layers) do
            if layer.type == "tilelayer" or layer.type == "imagelayer" then
                love.graphics.setColor(1, 1, 1, 1)
                self.gameMap:drawLayer(layer)
            end
        end
    elseif self.gameMap.backgroundColor then
        -- Simple background color (for Canteen)
        love.graphics.setColor(self.gameMap.backgroundColor)
        local w = self.gameMap.width * self.gameMap.tilewidth
        local h = self.gameMap.height * self.gameMap.tileheight
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(1, 1, 1, 1)
    end

    if self.player then
        love.graphics.setColor(1, 1, 1, 1)
        self.player:draw(self.playerScaleMultiplier)
    end
    
    if self.npcManager and self.npcManager.agents then
        for _, agent in ipairs(self.npcManager.agents) do
            agent:draw()
        end
    end
end

function GameState:drawYSortedScene()
    if not self.gameMap or not self.player then return end

    -- Draw Tile Layers (Background) - Only visible ones
    for _, layer in ipairs(self.gameMap.layers) do
        if layer.type == "tilelayer" and layer.visible then
             love.graphics.setColor(1, 1, 1, 1)
             self.gameMap:drawLayer(layer)
        end
    end

    local drawables = {}
    
    -- 1. Collect Map Objects
    for _, layer in ipairs(self.gameMap.layers) do
        if layer.type == "objectgroup" and layer.objects then
             local oy = layer.offsety or 0
             for _, obj in ipairs(layer.objects) do
                 if obj.gid then -- Visual Tile Object
                     local sortY = obj.y + oy
                     table.insert(drawables, {
                         type = 'mapObj',
                         obj = obj,
                         layer = layer,
                         y = sortY 
                     })
                 end
             end
        end
    end

    -- 2. Add Player
    table.insert(drawables, {
        type = 'player',
        obj = self.player,
        y = self.player:getBottomY()
    })
    
    -- 3. Add NPCs
    if self.npcManager and self.npcManager.agents then
        for _, agent in ipairs(self.npcManager.agents) do
            table.insert(drawables, {
                type = 'npc',
                obj = agent,
                y = agent.y -- Feet position
            })
        end
    end

    -- 4. Sort
    table.sort(drawables, function(a, b)
        return a.y < b.y
    end)

    -- 5. Draw
    for _, item in ipairs(drawables) do
        love.graphics.setColor(1, 1, 1, 1)
        
        if item.type == 'player' then
            item.obj:draw(self.playerScaleMultiplier)
        elseif item.type == 'npc' then
             item.obj:draw()
        elseif item.type == 'mapObj' then
             local obj = item.obj
             local tile = self.gameMap.tiles[obj.gid]
             if tile then
                 local x = obj.x + (item.layer.offsetx or 0)
                 local y = obj.y + (item.layer.offsety or 0)
                 local image = tile.image
                 if not image and tile.tileset then
                     local tileset = self.gameMap.tilesets[tile.tileset]
                     if tileset then image = tileset.image end
                 end
                 if image then
                     local r = math.rad(obj.rotation or 0)
                     local sx = obj.width / tile.width
                     local sy = obj.height / tile.height
                     -- Draw from Bottom (y - height)
                     love.graphics.draw(image, tile.quad, x, y - obj.height, r, sx, sy)
                 end
             end
        end
    end
end


function GameState:exit()
    -- Clean up game resources if needed
    if self.sounds.music then
        self.sounds.music:stop()
    end
end



function GameState:updateTravelSequence(dt)
    local width = love.graphics.getWidth()
    self.travelTimer = self.travelTimer + dt
    
    -- Phase 1: Bus Arrives (0 to 2s)
    if self.travelTimer < 2 then
        self.busX = -200 + (self.travelTimer / 2) * (width/2 + 200) -- Move to Center
        
    -- Phase 2: Boarding (2 to 3s)
    elseif self.travelTimer < 3 then
        self.busX = width/2
        -- Hide Player here if desired
        
    -- Phase 3: Bus Departs (3 to 5s)
    elseif self.travelTimer < 5 then
        local t = self.travelTimer - 3
        self.busX = width/2 + (t / 2) * (width/2 + 300) -- Move out Right
        
    -- Phase 4: Load Map
    else
        self.isTraveling = false
        if self.travelTarget then
            self:queueMapLoad(self.travelTarget.map, self.travelTarget.spawn)
            
            -- Add Travel Time
            if self.timeSystem then
                local addedTime = self.travelTarget.cost or 30
                self.timeSystem:addMinutes(addedTime)
            end
            
            self.travelTarget = nil
        end
    end
end

function GameState:drawBus()
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 0, 1) -- Yellow Bus
    love.graphics.rectangle("fill", self.busX - 100, height - 150, 200, 100)
    
    -- Wheels
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.circle("fill", self.busX - 60, height - 50, 20)
    love.graphics.circle("fill", self.busX + 60, height - 50, 20)
    
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("BUS", self.busX - 20, height - 100)
    love.graphics.setColor(1, 1, 1, 1)
end

function GameState:mousepressed(x, y, button)
    if self.phone and self.phone.isOpen then
        if self.phone:mousepressed(x, y, button, {
            career = self.careerManager,
            time = self.timeSystem,
            hud = self.hud
        }) then
            return -- Phone consumed input
        end
    end
    
    if self.shopMenu and self.shopMenu.isOpen then
        if self.shopMenu:mousepressed(x, y, button) then
            return -- Shop consumed input
        end
    end

    if self.travelMenu and self.travelMenu.isOpen then
        local target = self.travelMenu:mousepressed(x, y)
        if target then
            -- Check Balance
            local fare = target.moneyCost or 0
            if self.careerManager and self.careerManager.money < fare then
                print("Not enough money! Need Rs." .. fare)
                -- TODO: Show UI Toast
                return
            end

            self.travelMenu:close()
            
            -- Deduct Money
            if self.careerManager then
                self.careerManager:spendMoney(fare, "Travel: Bus Fare")
            end

            -- Start Travel Sequence
            self.isTraveling = true
            self.travelTimer = 0
            self.busX = -200
            self.travelTarget = { map = target.map, spawn = nil, cost = target.cost }
            return
        end
    end
end

function GameState:startMinigame(type)
    print("Starting Minigame: " .. tostring(type))
    if type == 'study' then
        -- FIXED: Check Energy First
        if self.careerManager and self.careerManager.energy < 15 then
            if self.hud then
                self.hud:addNotification("Too tired to study! Need 15 Energy.")
            end
            return
        end
        
        if self.studyGame then
            -- Calculate difficulty from "AI Memory" (CareerManager Log)
            local prof = 0
            if self.careerManager and self.careerManager.getStudyProficiency then
                prof = self.careerManager:getStudyProficiency()
            end
            
            -- Prof 0 (Unpracticed) -> 1.4 Difficulty (Fast)
            -- Prof 1 (Expert)      -> 0.7 Difficulty (Slow/Easy)
            local diff = 1.4 - (prof * 0.7)
            
            print("Narrative AI Influence: Proficiency " .. prof .. " -> Difficulty " .. diff)
            self.studyGame:start(diff)
        end
    elseif type == 'exam' then
        if self.examGame then
            -- Pass Proficiency to generate paper
            local prof = 0
            local dept = nil
            if self.careerManager then 
                prof = self.careerManager:getStudyProficiency() 
                dept = self.careerManager.department
            end
            print("Generating Exam for proficiency: " .. prof .. " Dept: " .. (dept or "None"))
            self.examGame:start(prof, dept)
        end
    end
end

function GameState:endMinigame(score, type)
    print("Minigame Ended (" .. (type or "study") .. "). Score: " .. score)
    if self.careerManager then
        if type == 'exam' then
             -- Specific Rewards for Exams
             local knowledgeGain = score * 2
             self.careerManager:gainKnowledge(knowledgeGain)
             -- Use safe call for reputation in case it doesn't exist yet
             if self.careerManager.modifyReputation then
                 self.careerManager:modifyReputation(math.ceil(score / 10))
             end
             
             -- Track Passed Exams
             if score >= 50 then
                 self.careerManager.examsPassed = self.careerManager.examsPassed + 1
                 if self.hud then self.hud:addNotification("Exam Passed! Total: " .. self.careerManager.examsPassed) end
             else
                 if self.hud then self.hud:addNotification("Exam Failed. Need 50 to pass.") end
             end
             
             if self.hud then
                self.hud:addNotification("Knowledge +" .. knowledgeGain)
             end
        else
            -- Default (Study) Rewards
            -- 1. Progress Knowledge (Narrative Stats) instead of money
            local knowledgeGain = math.floor(score / 5)
            self.careerManager:gainKnowledge(knowledgeGain)
            
            -- 2. Log for Persistent Narrative (AI memory)
            if self.timeSystem then
                local absTime = self.timeSystem:getAbsoluteTime()
                self.careerManager:logStudySession(absTime, score)
            end
            
            -- 3. Realistic Resource Deduction
            self.careerManager:modifyEnergy(-15) -- Fatigue
            if self.timeSystem then
                self.timeSystem:addMinutes(120) -- Study takes 2 hours of game time
            end

            if self.hud then
                if score > 0 then
                    local msg = string.format("Study Session: +%d Knowledge, -15 Energy", knowledgeGain)
                    self.hud:addNotification(msg)
                else
                    self.hud:addNotification("Exhausted. Session failed.")
                end
            end
        end
    end
end



function GameState:textinput(t)
    if self.formMenu and self.formMenu.isOpen then
        self.formMenu:textinput(t)
    end
end

    -- (Cluster function removed in rollback)

return GameState
