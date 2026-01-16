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
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function CareerManager:earnMoney(amount, reason)
    self.money = self.money + amount
    table.insert(self.history, 1, { desc = reason or "Earnings", amount = amount })
    -- Limit history to 20 items
    if #self.history > 20 then table.remove(self.history) end
end

function CareerManager:spendMoney(amount, reason)
    if self.money >= amount then
        self.money = self.money - amount
        table.insert(self.history, 1, { desc = reason or "Spending", amount = -amount })
        if #self.history > 20 then table.remove(self.history) end
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
end

function CareerManager:setPath(pathName)
    self.path = pathName
    if pathName == 'student' then
        self.jobTitle = "Student"
    elseif pathName == 'professor' then
        self.jobTitle = "Lab Assistant"
    end
end

return CareerManager
