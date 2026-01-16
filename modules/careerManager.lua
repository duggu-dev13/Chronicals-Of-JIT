local CareerManager = {}

function CareerManager:new()
    local obj = {}
    
    -- Stats
    obj.money = 500
    obj.energy = 100
    obj.maxEnergy = 100
    obj.stress = 0
    obj.maxStress = 100
    
    -- Career Path
    obj.path = nil -- 'student' or 'professor'
    obj.jobTitle = "Unemployed"
    obj.experience = 0
    
    -- Transaction History
    obj.history = {
        { desc = "Initial Balance", amount = 500 }
    }
    obj.onMoneyChanged = nil -- Callback function
    obj.lastSleepTime = -9999 -- Initialize to allow immediate sleep
    obj.lastClassTime = -9999 -- Initialize to allow immediate class
    
    -- RPG Stats
    obj.knowledge = 0
    obj.integrity = 50 -- Neutral
    obj.innovation = 10
    obj.reputation = 0
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function CareerManager:earnMoney(amount, reason)
    self.money = self.money + amount
    table.insert(self.history, 1, { desc = reason or "Earnings", amount = amount })
    -- Limit history to 20 items
    if #self.history > 20 then table.remove(self.history) end
    if self.onMoneyChanged then self.onMoneyChanged(amount) end
end

function CareerManager:spendMoney(amount, reason)
    if self.money >= amount then
        self.money = self.money - amount
        table.insert(self.history, 1, { desc = reason or "Spending", amount = -amount })
        if #self.history > 20 then table.remove(self.history) end
        if self.onMoneyChanged then self.onMoneyChanged(-amount) end
        return true
    end
    return false
end

function CareerManager:modifyEnergy(amount)
    self.energy = math.max(0, math.min(self.maxEnergy, self.energy + amount))
end

function CareerManager:modifyMoney(amount, reason)
    self.money = self.money + amount
    table.insert(self.history, 1, { desc = reason or "Adjustment", amount = amount })
    if #self.history > 20 then table.remove(self.history) end
    if self.onMoneyChanged then self.onMoneyChanged(amount) end
end

function CareerManager:setPath(pathName)
    self.path = pathName
    if pathName == 'student' then
        self.jobTitle = "Student"
    elseif pathName == 'professor' then
        self.jobTitle = "Lab Assistant"
    end
end

function CareerManager:sleep(currentTime)
    if currentTime and (currentTime - self.lastSleepTime < 600) then
        return false, "Not tired yet."
    end

    self.energy = self.maxEnergy
    self.stress = 0
    if currentTime then
        self.lastSleepTime = currentTime + 480 -- +8 hours of sleep duration? No, lastSleepTime tracks when they WOKE UP effectively? 
        -- Wait, logic: "once I slept, for next 10 hours I cant sleep".
        -- So Record the time sleep started (or ended).
        -- Let's say currentTime is START of sleep.
        self.lastSleepTime = currentTime + 480 -- Let's set it to the time they wake up.
    end
    return true, "Use TimeSystem to advance"
end

function CareerManager:eat()
    local cost = 50
    local energyGain = 20
    
    if self.energy >= self.maxEnergy then
        return false, "Not hungry."
    end
    
    if self.money >= cost then
        if self:spendMoney(cost, "Food") then
            self:modifyEnergy(energyGain)
            return true, "Ate food."
        end
        return false, "Not enough money."
    end
    return false, "Not enough money."
end




function CareerManager:attendClass(timeSystem)
    -- Requires Time System to check hours
    if not timeSystem then return false, "Time System Error" end
    
    
    -- Calculate hour from totalMinutes (since .hour property doesn't exist)
    local currentTime = timeSystem.totalMinutes
    local hour = math.floor(currentTime / 60)
    
    -- Cooldown Check: Class takes 60 mins. Let's force a 30 mins break after it ends.
    -- So subsequent start must be >= start + 60 + 30 = 90 mins later
    if (currentTime - self.lastClassTime) < 90 then
        local minsWait = 90 - (currentTime - self.lastClassTime)
        return false, "Class ended recently. Wait " .. minsWait .. "m."
    end
    
    -- Classes: 09:00 to 14:00
    -- Classes: 09:00 to 14:00
    if hour < 9 or hour >= 14 then
        return false, "Classes are closed. Open 09:00 - 14:00."
    end
    
    local energyCost = 20
    if self.energy < energyCost then
        return false, "Too tired to study."
    end
    
    self:modifyEnergy(-energyCost)
    self:gainKnowledge(10)
    
    self.lastClassTime = currentTime -- Mark the START time
    timeSystem:addMinutes(60) -- Takes 1 hour
    
    return true, "Attended Lecture. Knowledge +10"
end

function CareerManager:gainKnowledge(amount)
    self.knowledge = self.knowledge + amount
end

function CareerManager:modifyIntegrity(amount)
    self.integrity = math.max(0, math.min(100, self.integrity + amount))
end

function CareerManager:getRank()
    -- Simple rank based on knowledge/experience
    if self.knowledge < 50 then return "Novice"
    elseif self.knowledge < 200 then return "Intermediate"
    else return "Expert"
    end
end

return CareerManager
