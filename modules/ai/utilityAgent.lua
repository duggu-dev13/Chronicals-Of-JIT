local UtilityAgent = {}

function UtilityAgent:new(x, y, id, world)
    local obj = {
        id = id or math.random(1000),
        x = x or 0,
        y = y or 0,
        w = 32,
        h = 32,
        speed = 100,
        
        -- Needs (0-100)
        needs = {
            hunger = math.random(0, 50), 
            energy = math.random(50, 100), 
            social = math.random(50, 100)  
        },
        
        -- State Machine
        currentState = "IDLE", 
        stateTimer = 0,
        targetX = nil,
        targetY = nil,
        hasValidTarget = false,
        
        -- AI Config
        decisionTimer = 0, 
        color = {math.random(), math.random(), math.random()},
        showDebug = false,
        isVisible = true, -- For entering buildings
        
        -- Personality & Schedule
        personality = nil, -- Init below
        schedule = nil, 
        collider = nil
    }
    
    if world then
        obj.collider = world:newBSGRectangleCollider(obj.x, obj.y, 20, 14, 5)
        obj.collider:setFixedRotation(true)
        obj.collider:setLinearDamping(10)
    end
    
    -- Initialize Personality
    local r = math.random()
    if r < 0.2 then obj.personality = "nerd"      
    elseif r < 0.4 then obj.personality = "slacker" 
    elseif r < 0.6 then obj.personality = "active"  
    else obj.personality = "normal" end             
    
    -- Initialize Schedule
    obj.schedule = {
        { startH = 22, endH = 24, action = "SLEEP" },
        { startH = 0,  endH = 7,  action = "SLEEP" }
    }
    
    local function addSlot(s, e, a)
        table.insert(obj.schedule, { startH = s, endH = e, action = a })
    end

    if obj.personality == "nerd" then
        addSlot(7, 8, "MORNING_ROUTINE") 
        addSlot(8, 13, "CLASS")          
        addSlot(13, 14, "EAT")
        addSlot(14, 18, "LIBRARY")
        addSlot(18, 20, "REST")          
        addSlot(20, 22, "STUDY_HOSTEL")
    elseif obj.personality == "slacker" then
        addSlot(7, 10, "SLEEP")          
        addSlot(10, 11, "MORNING_ROUTINE")
        addSlot(11, 12, "CLASS")         
        addSlot(12, 16, "HANG_OUT")      
        addSlot(16, 18, "EAT")
        addSlot(18, 24, "PARTY")          
    elseif obj.personality == "active" then
        addSlot(6, 8, "WANDER")          
        addSlot(8, 9, "EAT")
        addSlot(9, 12, "CLASS")
        addSlot(12, 17, "HANG_OUT")      
        addSlot(17, 22, "REST")
    else -- Normal
        addSlot(7, 9, "MORNING_ROUTINE") 
        addSlot(9, 12, "CLASS")
        addSlot(12, 13, "EAT")
        addSlot(13, 16, "LIBRARY")       
        addSlot(16, 19, "HANG_OUT")
        addSlot(19, 22, "REST")
    end
    
    -- Clamp Hours and Add Variation
    local offset = math.random(-30, 30) / 60 -- +/- 30 mins variance
    
    for _, s in ipairs(obj.schedule) do
        -- Apply offset to all start/end times except sleep boundaries if desired
        -- For simplicity, shift everything, but keep clamp
        s.startH = s.startH + offset
        s.endH = s.endH + offset
        
        s.startH = math.max(0, math.min(24, s.startH))
        s.endH = math.max(0, math.min(24, s.endH))
    end
    
    obj.log = function(msg) print("[Agent " .. obj.id .. "] " .. msg) end
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function UtilityAgent:update(dt, timeSystem, world, agents)
    -- 1. Update Needs
    self.needs.hunger = math.min(100, self.needs.hunger + dt * 2) 
    self.needs.energy = math.max(0, self.needs.energy - dt * 1)   
    self.needs.social = math.max(0, self.needs.social - dt * 1.5) 
    
    -- 2. Execute Current State Frame
    local stateFunc = self["update_" .. self.currentState]
    if stateFunc then
        stateFunc(self, dt, world, agents) -- Pass agents to state
    else
        self:update_IDLE(dt) 
    end
    
    -- 3. Make Decisions periodically
    self.decisionTimer = self.decisionTimer - dt
    if self.decisionTimer <= 0 then
        self:decide(timeSystem, agents)
        self.decisionTimer = 2.0 
    end
    
    -- 4. Sync Visuals from Physics
    if self.collider then
        self.x = self.collider:getX()
        self.y = self.collider:getY() + 7 -- Offset like player
    end
end

-- ================= STATE MACHINE ENGINE =================

function UtilityAgent:changeState(newState, param)
    if self.currentState == newState then return end
    
    if self.log then self.log("State: " .. self.currentState .. " -> " .. newState) end
    
    -- Exit Old
    local exitFunc = self["exit_" .. self.currentState]
    if exitFunc then exitFunc(self) end
    
    self.currentState = newState
    self.stateTimer = 0
    
    -- Enter New
    local enterFunc = self["enter_" .. self.currentState]
    if enterFunc then enterFunc(self, param) end
end

-- ================= BEHAVIORS (STEERING) =================

function UtilityAgent:moveTowards(tx, ty, dt, world)
    local dx = tx - self.x
    local dy = ty - self.y
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if dist < 15 then 
        -- Stop
        if self.collider then self.collider:setLinearVelocity(0, 0) end
        return true 
    end -- Arrived
    
    local nx, ny = dx/dist, dy/dist
    local speed = self.speed
    
    if self.collider then
        -- Physics Movement
        self.collider:setLinearVelocity(nx * speed, ny * speed)
    else
        -- Fallback Manual Movement (shouldn't happen if world passed)
        self.x = self.x + nx * speed * dt
        self.y = self.y + ny * speed * dt
    end
    
    return false
end

function UtilityAgent:pickRandomTarget()
    -- Only pick if invalid
    self.targetX = self.x + math.random(-200, 200)
    self.targetY = self.y + math.random(-200, 200)
    self.hasValidTarget = false 
end

function UtilityAgent:pickSocialTarget(agents)
    if not agents then return false end
    
    local bestTarget = nil
    local minDist = 300 -- Search radius
    
    for _, other in ipairs(agents) do
        if other ~= self and (other.currentState == "HANGING_OUT" or other.currentState == "MOVING_TO_HANGOUT") then
            local dx = other.x - self.x
            local dy = other.y - self.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < minDist then
                minDist = dist
                bestTarget = other
            end
        end
    end
    
    if bestTarget then
        -- Join the group (with offset)
        self.targetX = bestTarget.x + math.random(-30, 30)
        self.targetY = bestTarget.y + math.random(-30, 30)
        return true
    end
    
    return false
end

-- ================= DECISION LOGIC =================

function UtilityAgent:decide(timeSystem, agents)
    local scores = {}
    local currentHour = 10
    if timeSystem and timeSystem.totalMinutes then
        currentHour = timeSystem.totalMinutes / 60
    end
    
    -- 1. Schedule
    local scheduledAction = nil
    for _, slot in ipairs(self.schedule) do
        if currentHour >= slot.startH and currentHour < slot.endH then
            scheduledAction = slot.action
            break
        end
    end
    
    if scheduledAction == "CLASS" then table.insert(scores, { action = "CLASS", score = 200 })
    elseif scheduledAction == "EAT" then table.insert(scores, { action = "EAT", score = 150 }) 
    elseif scheduledAction == "SLEEP" then table.insert(scores, { action = "REST", score = 300 }) -- Must sleep
    end
    
    -- 2. Needs
    table.insert(scores, { action = "EAT", score = (self.needs.hunger / 100) ^ 2 * 100 })
    table.insert(scores, { action = "REST", score = ((100 - self.needs.energy) / 100) ^ 2 * 100 })
    table.insert(scores, { action = "HANG_OUT", score = 20 })
    
    table.sort(scores, function(a, b) return a.score > b.score end)
    local bestAction = scores[1].action
    
    -- Apply Decision (Map Action -> State)
    if bestAction == "EAT" then
        self:changeState("MOVING_TO_EAT")
    elseif bestAction == "REST" then
         self:changeState("MOVING_TO_REST")
    elseif bestAction == "CLASS" then
         self:changeState("MOVING_TO_CLASS")
    elseif bestAction == "LIBRARY" then
         self:changeState("MOVING_TO_LIBRARY")
    elseif bestAction == "HANG_OUT" or bestAction == "WANDER" or bestAction == "PARTY" then
         self:changeState("MOVING_TO_HANGOUT", agents)
    end
end

-- ================= CONCRETE STATES =================

-- IDLE
function UtilityAgent:enter_IDLE() self.stateTimer = 2 end
function UtilityAgent:update_IDLE(dt)
    self.stateTimer = self.stateTimer - dt
    -- Just wait for next decision
end

-- MOVING_TO_EAT
function UtilityAgent:enter_MOVING_TO_EAT() 
    self:pickRandomTarget() 
end
-- State Updates to pass world to moveTowards
function UtilityAgent:update_MOVING_TO_EAT(dt, world)
    if self.targetX and self:moveTowards(self.targetX, self.targetY, dt, world) then
        self:changeState("EATING")
    end
end

-- EATING
function UtilityAgent:enter_EATING() 
    self.stateTimer = 5 
    self:enterBuilding() -- Hide inside canteen
end
function UtilityAgent:exit_EATING()
    self:exitBuilding(self.x, self.y) -- Reappear at door
end
function UtilityAgent:update_EATING(dt)
    self.stateTimer = self.stateTimer - dt
    self.needs.hunger = math.max(0, self.needs.hunger - dt * 20)
    if self.stateTimer <= 0 then self:changeState("IDLE") end
end

-- MOVING_TO_REST
function UtilityAgent:enter_MOVING_TO_REST() self:pickRandomTarget() end
function UtilityAgent:update_MOVING_TO_REST(dt, world)
    if self.targetX and self:moveTowards(self.targetX, self.targetY, dt, world) then
        self:changeState("RESTING")
    end
end

-- RESTING
function UtilityAgent:enter_RESTING() self.stateTimer = 10 end
function UtilityAgent:update_RESTING(dt)
    self.stateTimer = self.stateTimer - dt
    self.needs.energy = math.min(100, self.needs.energy + dt * 10)
    if self.stateTimer <= 0 then self:changeState("IDLE") end
end

-- MOVING_TO_CLASS
function UtilityAgent:enter_MOVING_TO_CLASS() self:pickRandomTarget() end
function UtilityAgent:update_MOVING_TO_CLASS(dt, world)
    if self.targetX and self:moveTowards(self.targetX, self.targetY, dt, world) then
        self:changeState("IN_CLASS")
    end
end

-- IN_CLASS
function UtilityAgent:enter_IN_CLASS() 
    self.stateTimer = 120 
    self:enterBuilding()
end
function UtilityAgent:exit_IN_CLASS()
    self:exitBuilding(self.x, self.y)
end
function UtilityAgent:update_IN_CLASS(dt)
    self.stateTimer = self.stateTimer - dt
    if self.stateTimer <= 0 then self:changeState("IDLE") end
end

-- MOVING_TO_LIBRARY
function UtilityAgent:enter_MOVING_TO_LIBRARY() self:pickRandomTarget() end
function UtilityAgent:update_MOVING_TO_LIBRARY(dt, world)
    if self.targetX and self:moveTowards(self.targetX, self.targetY, dt, world) then
        self:changeState("IN_LIBRARY")
    end
end

-- IN_LIBRARY
function UtilityAgent:enter_IN_LIBRARY() 
    self.stateTimer = 60 
    self:enterBuilding()
end
function UtilityAgent:exit_IN_LIBRARY()
    self:exitBuilding(self.x, self.y)
end
function UtilityAgent:update_IN_LIBRARY(dt)
    self.stateTimer = self.stateTimer - dt
    if self.stateTimer <= 0 then self:changeState("IDLE") end
end

-- MOVING_TO_HANGOUT
function UtilityAgent:enter_MOVING_TO_HANGOUT(agents) 
    -- Try to find a friend
    if not self:pickSocialTarget(agents) then
        self:pickRandomTarget() 
    end
end
function UtilityAgent:update_MOVING_TO_HANGOUT(dt, world)
    if self.targetX and self:moveTowards(self.targetX, self.targetY, dt, world) then
        self:changeState("HANGING_OUT")
    end
end

-- HANGING_OUT
function UtilityAgent:enter_HANGING_OUT() self.stateTimer = 10 end
function UtilityAgent:update_HANGING_OUT(dt)
    self.stateTimer = self.stateTimer - dt
    self.needs.social = math.min(100, self.needs.social + dt * 5) -- Restore Social
    if self.stateTimer <= 0 then self:changeState("IDLE") end
end

-- ================= DRAW =================

function UtilityAgent:enterBuilding()
    self.isVisible = false
    if self.collider then
        -- We can't disable, but we can move it far away or filter collision
        -- Better: Set active to false? Windfield might not support 'active' toggle easily on existing body?
        -- WF colliders are love physics bodies.
        -- self.collider:getBody():setActive(false)
        -- Let's check if WF exposes getBody or setSensor
        pcall(function() self.collider:setSensor(true) end) -- Disable physical collision
    end
end

function UtilityAgent:exitBuilding(targetX, targetY)
    self.isVisible = true
    if targetX and targetY then
        self.x, self.y = targetX, targetY
        if self.collider then
            self.collider:setPosition(targetX, targetY)
            pcall(function() self.collider:setSensor(false) end) -- Re-enable
        end
    end
end

function UtilityAgent:draw()
    if not self.isVisible then return end

    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, 10)
    
    if self.showDebug then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(self.currentState, self.x - 10, self.y - 20)
    end
end

return UtilityAgent
