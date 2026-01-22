local Careers = require 'data/careers'

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
    obj.department = "CS" -- Default Department
    obj.rankIndex = 1
    obj.jobTitle = "Unemployed" -- Updated by setPath
    obj.experience = 0
    obj.examsPassed = 0 -- Track exams passed
    
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
    
    -- Study Narrative Tracking
    obj.studyLog = {} -- List of { absoluteTime, score }
    obj.proficiency = 0 -- 0.0 to 1.0 (Calculated)
    
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

function CareerManager:modifyStress(amount)
    self.stress = math.max(0, math.min(self.maxStress, self.stress + amount))
end

function CareerManager:modifyMoney(amount, reason)
    self.money = self.money + amount
    table.insert(self.history, 1, { desc = reason or "Adjustment", amount = amount })
    if #self.history > 20 then table.remove(self.history) end
    if self.onMoneyChanged then self.onMoneyChanged(amount) end
end

function CareerManager:setPath(pathName)
    if Careers[pathName] then
        self.path = pathName
        self.rankIndex = 1
        local rankData = Careers[pathName].ranks[1]
        self.jobTitle = rankData.title
        print("Career Path Set: " .. pathName .. " (" .. self.jobTitle .. ")")
    else
        print("Error: Invalid Career Path " .. tostring(pathName))
    end
end

function CareerManager:sleep(currentTime)
    -- currentTime must be ABSOLUTE time from TimeSystem:getAbsoluteTime()
    local cooldown = 960 -- 16 Hours wait between sleeps
    
    if currentTime and (currentTime - self.lastSleepTime < cooldown) then
        local wait = cooldown - (currentTime - self.lastSleepTime)
        local waitHours = math.ceil(wait / 60)
        return false, "Not tired. Wait " .. waitHours .. "h."
    end

    self.energy = self.maxEnergy
    self.stress = 0
    if currentTime then
        -- Calculate wake up time slightly better? 
        -- Or just assume 8 hours always.
        self.lastSleepTime = currentTime -- Mark when we STARTED sleeping
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
    -- Use Absolute Time for Cooldown Checks
    local currentTime = timeSystem:getAbsoluteTime()
    
    -- Calculate hour from total minutes for schedule check (09:00 - 14:00)
    -- We need local time for this, not absolute
    local localMinutes = timeSystem.totalMinutes
    local hour = math.floor(localMinutes / 60)
    
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
    
    self.lastClassTime = currentTime -- Mark the START time (Absolute)
    timeSystem:addMinutes(60) -- Takes 1 hour
    
    return true, "Attended Lecture. Knowledge +10"
end

function CareerManager:gainKnowledge(amount)
    self.knowledge = self.knowledge + amount
end

function CareerManager:modifyIntegrity(amount)
    self.integrity = math.max(0, math.min(100, self.integrity + amount))
end

-- ===================== NARRATIVE AI (STUDY TRACKING) =====================

function CareerManager:logStudySession(absoluteTime, score)
    table.insert(self.studyLog, { time = absoluteTime, score = score })
    -- Limit log to last 50 studies
    if #self.studyLog > 50 then table.remove(self.studyLog, 1) end
    
    print(string.format("Narrative Logged: Study at %d (Score: %d)", absoluteTime, score))
end

function CareerManager:getStudyProficiency()
    if #self.studyLog == 0 then return 0 end
    
    -- Logic: Average score of recent studies, weighted by recency
    -- For now, simple average of last 5 studies
    local sum = 0
    local count = 0
    for i = #self.studyLog, math.max(1, #self.studyLog - 4), -1 do
        sum = sum + self.studyLog[i].score
        count = count + 1
    end
    
    local avg = sum / (count * 100) -- Normalized (max score ~100)
    return math.min(1.0, avg)
end

function CareerManager:getRank()
    -- Simple rank based on knowledge/experience
    if self.knowledge < 50 then return "Novice"
    elseif self.knowledge < 200 then return "Intermediate"
    else return "Expert"
    end
end

function CareerManager:checkPromotion()
    if not self.path or not Careers[self.path] then return end
    
    local pathData = Careers[self.path]
    local nextRankIndex = self.rankIndex + 1
    local nextRank = pathData.ranks[nextRankIndex]
    
    if not nextRank then return false, "Max Rank Reached" end
    
    -- Check Requirements
    local reqs = nextRank.req
    local meetsAll = true
    local missing = ""
    
    if reqs.knowledge and self.knowledge < reqs.knowledge then
        meetsAll = false
        missing = missing .. "Knowledge (" .. self.knowledge .. "/" .. reqs.knowledge .. ") "
    end
    
    if reqs.reputation and self.reputation < reqs.reputation then
        meetsAll = false
        missing = missing .. "Reputation (" .. self.reputation .. "/" .. reqs.reputation .. ") "
    end
    
    if reqs.examsPassed and self.examsPassed < reqs.examsPassed then
        meetsAll = false
        missing = missing .. "Exams (" .. self.examsPassed .. "/" .. reqs.examsPassed .. ") "
    end
    
    if meetsAll then
        self:promote(nextRankIndex)
        return true, "Promoted to " .. nextRank.title .. "!"
    else
        return false, "Requirements: " .. missing
    end
end

function CareerManager:promote(newIndex)
    self.rankIndex = newIndex
    local rankData = Careers[self.path].ranks[newIndex]
    self.jobTitle = rankData.title
    
    -- Grant Bonus Money?
    self:earnMoney(200, "Promotion Bonus")
    
    print("PROMOTION! New Rank: " .. self.jobTitle)
end

function CareerManager:getCurrentRankData()
    if self.path and Careers[self.path] then
        return Careers[self.path].ranks[self.rankIndex]
    end
    return nil
end

function CareerManager:getNextRankData()
    if self.path and Careers[self.path] then
         return Careers[self.path].ranks[self.rankIndex + 1]
    end
    return nil
end

return CareerManager
