local LocationManager = {}

-- Travel Matrix (Minutes)
local DISTANCES = {
    ['maps/hostel.lua'] = {
        ['maps/college_base_map.lua'] = 40
    },
    ['maps/college_base_map.lua'] = {
        ['maps/hostel.lua'] = 40
    }
}

function LocationManager:new()
    local obj = {}
    obj.vehicle = 'walk' -- walk, bike, car
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function LocationManager:getTravelTime(from, to)
    local fromData = DISTANCES[from]
    if not fromData then return 10 end -- Default
    
    local baseTime = fromData[to] or 10
    
    -- Apply Vehicle Modifier
    if self.vehicle == 'bike' then
        return math.ceil(baseTime / 2)
    elseif self.vehicle == 'car' then
        return math.ceil(baseTime / 4)
    end
    
    return baseTime
end

return LocationManager
