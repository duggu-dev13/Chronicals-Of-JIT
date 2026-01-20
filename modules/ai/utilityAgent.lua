local UtilityAgent = {}

function UtilityAgent:new(x, y, id)
    local obj = {
        id = id or math.random(1000),
        x = x or 0,
        y = y or 0,
        w = 32,
        h = 32,
        speed = 100,
        
        -- Needs (0-100)
        needs = {
            hunger = math.random(0, 50), -- Increases over time
            energy = math.random(50, 100), -- Decreases over time
            social = math.random(50, 100)  -- Decreases over time (Loneliness)
        },
        
        -- State
        currentState = "IDLE", -- IDLE, WANDER, MOVING_TO_EAT, MOVING_TO_REST, EATING, RESTING
        targetX = nil,
        targetY = nil,
        actionTimer = 0,
        
        decisionTimer = 0, -- Time until next think
        
        color = {math.random(), math.random(), math.random()},
        showDebug = false, -- Toggle for thinking text
        
        -- Daily Schedule (Hour -> Action)
        -- 9-12: Class, 12-1: Eat, 1-4: Library/Labs
        schedule = {
            { startH = 9, endH = 12, action = "CLASS" },
            { startH = 12, endH = 13, action = "EAT" },
            { startH = 13, endH = 16, action = "WANDER" } -- Free time
        }
    }
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function UtilityAgent:update(dt, timeSystem)
    -- 1. Update Needs
    self.needs.hunger = math.min(100, self.needs.hunger + dt * 2) -- Gets hungry
    self.needs.energy = math.max(0, self.needs.energy - dt * 1)   -- Gets tired
    self.needs.social = math.max(0, self.needs.social - dt * 1.5) -- Gets lonely
    
    -- 2. Execute Current State
    self:executeState(dt)
    
    -- 3. Make Decisions periodically
    self.decisionTimer = self.decisionTimer - dt
    if self.decisionTimer <= 0 then
        self:decide(timeSystem)
        self.decisionTimer = 2.0 -- Think every 2 seconds
    end
end

function UtilityAgent:decide(timeSystem)
    -- Calculate Utility Scores
    local scores = {}
    local currentHour = timeSystem and timeSystem.hour or 10
    
    -- 1. Check Schedule (High Priority)
    local scheduledAction = nil
    for _, slot in ipairs(self.schedule) do
        if currentHour >= slot.startH and currentHour < slot.endH then
            scheduledAction = slot.action
            break
        end
    end
    
    if scheduledAction == "CLASS" then
        -- High urgency to go to class
        table.insert(scores, { action = "CLASS", score = 200 })
    elseif scheduledAction == "EAT" then
        -- Boost hunger score naturally, or just force it
        table.insert(scores, { action = "EAT", score = 150 })
    end
    
    -- 2. Basic Needs
    -- Score Eat
    local hungerScore = (self.needs.hunger / 100) ^ 2 * 100
    table.insert(scores, { action = "EAT", score = hungerScore })
    
    -- Score Rest
    local energyScore = ((100 - self.needs.energy) / 100) ^ 2 * 100
    table.insert(scores, { action = "REST", score = energyScore })
    
    -- Score Wander (Default low score)
    table.insert(scores, { action = "WANDER", score = 10 })
    
    -- Pick Best Action
    table.sort(scores, function(a, b) return a.score > b.score end)
    local bestAction = scores[1]
    
    -- Apply Decision
    if bestAction.action == "EAT" and self.currentState ~= "EATING" and self.currentState ~= "MOVING_TO_EAT" then
        self.currentState = "MOVING_TO_EAT"
        self:pickRandomTarget() 
    elseif bestAction.action == "REST" and self.currentState ~= "RESTING" and self.currentState ~= "MOVING_TO_REST" then
         self.currentState = "MOVING_TO_REST"
         self:pickRandomTarget() 
    elseif bestAction.action == "CLASS" and self.currentState ~= "IN_CLASS" and self.currentState ~= "MOVING_TO_CLASS" then
         self.currentState = "MOVING_TO_CLASS" -- Go to class
         self:pickRandomTarget()
    elseif bestAction.action == "WANDER" and self.currentState == "IDLE" then
         self.currentState = "WANDER"
         self:pickRandomTarget()
    end
end

function UtilityAgent:executeState(dt)
    if self.currentState == "WANDER" or self.currentState == "MOVING_TO_EAT" or self.currentState == "MOVING_TO_REST" or self.currentState == "MOVING_TO_CLASS" then
        if self.targetX and self.targetY then
            -- Move towards target
            local dx = self.targetX - self.x
            local dy = self.targetY - self.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < 5 then
                -- Arrived
                if self.currentState == "MOVING_TO_EAT" then
                    self.currentState = "EATING"
                    self.actionTimer = 5 
                elseif self.currentState == "MOVING_TO_REST" then
                    self.currentState = "RESTING"
                    self.actionTimer = 10
                elseif self.currentState == "MOVING_TO_CLASS" then
                    self.currentState = "IN_CLASS"
                    self.actionTimer = 120 -- Stay in class (game seconds, not real time)
                else
                    self.currentState = "IDLE"
                    self.actionTimer = 2
                end
            else
                -- Normalize and move
                local nx, ny = dx/dist, dy/dist
                self.x = self.x + nx * self.speed * dt
                self.y = self.y + ny * self.speed * dt
            end
        end
        
    elseif self.currentState == "EATING" then
        self.actionTimer = self.actionTimer - dt
        self.needs.hunger = math.max(0, self.needs.hunger - dt * 20) 
        if self.actionTimer <= 0 then self.currentState = "IDLE" end
        
    elseif self.currentState == "RESTING" then
        self.actionTimer = self.actionTimer - dt
        self.needs.energy = math.min(100, self.needs.energy + dt * 10) 
        if self.actionTimer <= 0 then self.currentState = "IDLE" end

    elseif self.currentState == "IN_CLASS" then
         -- Just wait
         self.actionTimer = self.actionTimer - dt
         if self.actionTimer <= 0 then self.currentState = "IDLE" end

    elseif self.currentState == "IDLE" then
        self.actionTimer = self.actionTimer - dt
    end
end

function UtilityAgent:pickRandomTarget()
    self.targetX = self.x + math.random(-200, 200)
    self.targetY = self.y + math.random(-200, 200)
    self.hasValidTarget = false -- Reset validity so Manager reassigns if needed
end

function UtilityAgent:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, 10)
    
    -- Debug: State (Only if enabled)
    if self.showDebug then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(self.currentState, self.x - 10, self.y - 20)
    end
end

return UtilityAgent
