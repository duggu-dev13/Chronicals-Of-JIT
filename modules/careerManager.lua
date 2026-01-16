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

return CareerManager
