local UtilityAgent = require 'modules/ai/utilityAgent'
local NPCManager = {}

function NPCManager:new(gameState)
    local obj = {
        gameState = gameState,
        agents = {},
        zones = {
            canteen = { x = 1500, y = 800, w = 400, h = 300 }, -- Placeholder Canteen
            benches = {}, -- Will be populated from GameState
            library = { x = 2000, y = 500, w = 300, h = 300 } -- Placeholder Library
        }
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function NPCManager:clearAgents()
    -- Destroy physics bodies if any
    for _, agent in ipairs(self.agents) do
        if agent.collider and agent.collider.destroy then
            -- Safe destroy if world exists, though usually world is already gone
            pcall(function() agent.collider:destroy() end)
        end
    end
    self.agents = {}
end

function NPCManager:spawnNPCs(count, startX, startY)
    for i = 1, count do
        -- Random scatter around start point
        local sx = startX + math.random(-100, 100)
        local sy = startY + math.random(-100, 100)
        
        local world = self.gameState.world
        local agent = UtilityAgent:new(sx, sy, i, world)
        table.insert(self.agents, agent)
    end
    print("Spawned " .. count .. " NPCs.")
end

function NPCManager:update(dt)
    for _, agent in ipairs(self.agents) do
        -- Inject Context if needed (e.g., knowledge of map)
        if not agent.mapData then
            -- Pass simplified map data or targets based on current decision
            if agent.currentState == "MOVING_TO_EAT" and not agent.hasValidTarget then
                self:assignTargetZone(agent, "canteen")
            elseif agent.currentState == "MOVING_TO_REST" and not agent.hasValidTarget then
                 -- If Night ( > 20:00 or < 6:00), go to Hostel
                 local hour = self.gameState.timeSystem and self.gameState.timeSystem.hour or 12
                 if hour >= 20 or hour < 6 then
                    self:assignTargetZone(agent, "hostel")
                 else
                    self:assignTargetZone(agent, "benches")
                 end
            elseif agent.currentState == "MOVING_TO_CLASS" and not agent.hasValidTarget then
                 self:assignTargetZone(agent, "class")
            elseif agent.currentState == "MOVING_TO_LIBRARY" and not agent.hasValidTarget then
                 self:assignTargetZone(agent, "library")
            elseif agent.currentState == "MOVING_TO_HANGOUT" and not agent.hasValidTarget then
                 -- Bunking students go to benches or canteen or random spot
                 if math.random() > 0.5 then
                    self:assignTargetZone(agent, "canteen")
                 else
                    self:assignTargetZone(agent, "benches")
                 end
            end
        end
        
        agent:update(dt, self.gameState.timeSystem, self.gameState.world, self.agents)
    end
end

function NPCManager:assignTargetZone(agent, zoneType)
    local targets = self.zones[zoneType]
    local target = nil
    
    if targets and #targets > 0 then
        target = targets[math.random(#targets)]
    else
        -- Fallback logic
        -- Only log occasionally or if in debug_mode
        if math.random() < 0.05 then 
            print("[NPCManager] Warning: No zones for " .. zoneType .. ". Agent wandering.")
        end
    end
    
    if target then
        -- Randomize point within zone
        agent.targetX = target.x + math.random(0, target.w or 0)
        agent.targetY = target.y + math.random(0, target.h or 0)
        agent.hasValidTarget = true
    else
        -- FORCE Fallback to Canteen (Safe Hub) if specific zone fails
        -- Do not allow WANDER
        if zoneType ~= "canteen" then
             -- print("[NPCManager] Zone " .. zoneType .. " missing. Redirecting to Canteen.")
             self:assignTargetZone(agent, "canteen")
        else
             -- Even canteen failed? Just stay put or panic.
             agent.currentState = "IDLE"
             agent.hasValidTarget = true -- Fake it to stop retrying
        end
    end
end

function NPCManager:toggleDebug()
    for _, agent in ipairs(self.agents) do
        agent.showDebug = not agent.showDebug
    end
end

function NPCManager:draw()
    for _, agent in ipairs(self.agents) do
        agent:draw()
    end
end

function NPCManager:refreshZones(gameState)
    -- Clear current zones
    self.zones = {
        canteen = {},
        benches = {},
        class = {},
        library = {},
        hostel = {}
    }
    
    -- Populate from Map Config (Priority)
    local currentPath = gameState.currentMapPath
    local mapConfig = gameState.mapConfigs and gameState.mapConfigs[currentPath]
    
    if mapConfig and mapConfig.npcZones then
        if mapConfig.npcZones.canteen then
            for _, z in ipairs(mapConfig.npcZones.canteen) do table.insert(self.zones.canteen, z) end
        end
        if mapConfig.npcZones.benches then
            for _, z in ipairs(mapConfig.npcZones.benches) do table.insert(self.zones.benches, z) end
        end
        if mapConfig.npcZones.class then
            for _, z in ipairs(mapConfig.npcZones.class) do table.insert(self.zones.class, z) end
        end
        if mapConfig.npcZones.library then
            for _, z in ipairs(mapConfig.npcZones.library) do table.insert(self.zones.library, z) end
        end
        if mapConfig.npcZones.hostel then
            for _, z in ipairs(mapConfig.npcZones.hostel) do table.insert(self.zones.hostel, z) end
        end
    end

    -- Populate from GameState interactions (Secondary / Discovery)
    if gameState.interactAreas then
        for _, area in ipairs(gameState.interactAreas) do
            -- Updated logic for Tiled Zones
            if area.action == 'canteen' or area.action == 'eat' then
                table.insert(self.zones.canteen, area)
            elseif area.action == 'bench' or area.name == 'Bench' or area.name == 'Bench_Seat' then
                table.insert(self.zones.benches, area)
            elseif area.action == 'class' then
                table.insert(self.zones.class, area)
            elseif area.action == 'library' or area.type == 'library' then
                table.insert(self.zones.library, area)
            elseif area.action == 'hostel_lobby' then
                table.insert(self.zones.hostel, area)
            end
        end
    end
    
    -- Fallbacks (if map has no zones AND no config)
    if #self.zones.canteen == 0 then self.zones.canteen = {{x=1500, y=800, w=200, h=200}} end
    if #self.zones.class == 0 then self.zones.class = {{x=200, y=300, w=100, h=100}} end -- Fallback near spawn
    if #self.zones.library == 0 then self.zones.library = {{x=1800, y=600, w=200, h=200}} end -- Library fallback
    if #self.zones.benches == 0 then self.zones.benches = {{x=1600, y=2600, w=300, h=100}} end -- Garden fallback
    
    -- Hostel Gate
    if not self.zones.hostel then self.zones.hostel = {} end
    if #self.zones.hostel == 0 then self.zones.hostel = {{x=1300, y=400, w=200, h=200}} end -- Placeholder Hostel location
    
    print("NPC Zones Refreshed. Agents active: " .. #self.agents)
end

return NPCManager
