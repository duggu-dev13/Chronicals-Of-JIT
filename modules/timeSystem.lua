local TimeSystem = {}

function TimeSystem:new()
    local obj = {}
    obj.totalMinutes = 8 * 60 -- Start at 8:00 AM
    obj.day = 1
    obj.paused = false
    obj.accumulatedTime = 0
    
    -- Config: 1 real second = 1 game minute
    obj.secondsPerGameMinute = 1.0 
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function TimeSystem:update(dt)
    if self.paused then return end
    
    self.accumulatedTime = self.accumulatedTime + dt
    
    while self.accumulatedTime >= self.secondsPerGameMinute do
        self.accumulatedTime = self.accumulatedTime - self.secondsPerGameMinute
        self.totalMinutes = self.totalMinutes + 1
        
        -- New Day Logic (1440 mins = 24 hours)
        if self.totalMinutes >= 1440 then
            self.totalMinutes = self.totalMinutes - 1440
            self.day = self.day + 1
            -- TODO: Trigger 'New Day' Event
        end
    end
end

function TimeSystem:addMinutes(minutes)
    local oldTime = self:getTimeString()
    self.totalMinutes = self.totalMinutes + minutes
    
    -- Handle day rollover immediately if needed
    while self.totalMinutes >= 1440 do
        self.totalMinutes = self.totalMinutes - 1440
        self.day = self.day + 1
    end
    print(string.format("Time Updated: %s -> %s (Added %d mins)", oldTime, self:getTimeString(), minutes))
end

function TimeSystem:getTimeString()
    local hours = math.floor(self.totalMinutes / 60)
    local minutes = math.floor(self.totalMinutes % 60)
    
    -- Format HH:MM
    return string.format("%02d:%02d", hours, minutes)
end

function TimeSystem:getDay()
    return self.day
end

function TimeSystem:isNight()
    -- 10 PM (22:00) to 6 AM (06:00)
    local hours = math.floor(self.totalMinutes / 60)
    return hours >= 22 or hours < 6
end

return TimeSystem
