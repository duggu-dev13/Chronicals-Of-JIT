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
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function CareerManager:earnMoney(amount)
    self.money = self.money + amount
    -- Play sound effect here
end

function CareerManager:spendMoney(amount)
    if self.money >= amount then
        self.money = self.money - amount
        return true
    end
    return false
end

function CareerManager:modifyEnergy(amount)
    self.energy = math.max(0, math.min(self.maxEnergy, self.energy + amount))
end

function CareerManager:modifyMoney(amount)
    self.money = self.money + amount
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
