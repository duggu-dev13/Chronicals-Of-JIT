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

function NPCManager:spawnNPCs(count, startX, startY)
    for i = 1, count do
        -- Random scatter around start point
        local sx = startX + math.random(-100, 100)
        local sy = startY + math.random(-100, 100)
        
        local agent = UtilityAgent:new(sx, sy, i)
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
                 self:assignTargetZone(agent, "bench")
            elseif agent.currentState == "MOVING_TO_CLASS" and not agent.hasValidTarget then
                 self:assignTargetZone(agent, "class")
            end
        end
        
        agent:update(dt, self.gameState.timeSystem)
    end
end

function NPCManager:assignTargetZone(agent, zoneType)
    local targets = self.zones[zoneType]
    local target = nil
    
    if targets and #targets > 0 then
        target = targets[math.random(#targets)]
    else
        -- Fallback logic
        print("Warning: No zones found for " .. zoneType)
    end
    
    if target then
        -- Randomize point within zone
        agent.targetX = target.x + math.random(0, target.w or 0)
        agent.targetY = target.y + math.random(0, target.h or 0)
        agent.hasValidTarget = true
    else
        -- Revert to wander
        agent.currentState = "WANDER"
        agent:pickRandomTarget()
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
        library = {} -- Add others as needed
    }
    
    -- Populate from GameState interactions
    if gameState.interactAreas then
        for _, area in ipairs(gameState.interactAreas) do
            if area.action == 'eat' then
                table.insert(self.zones.canteen, area)
            elseif area.action == 'sleep' or area.name == 'Bench' then
                 -- Treat standard sleep zones or benches as rest spots
                table.insert(self.zones.benches, area)
            elseif area.action == 'class' then
                table.insert(self.zones.class, area)
            elseif area.type == 'library' then
                table.insert(self.zones.library, area)
            end
        end
    end
    
    -- Fallbacks (if map has no zones)
    if #self.zones.canteen == 0 then self.zones.canteen = {{x=1500, y=800, w=200, h=200}} end
    
    print("NPC Zones Refreshed: " .. #self.zones.canteen .. " Canteens, " .. #self.zones.benches .. " Benches.")
end

return NPCManager
