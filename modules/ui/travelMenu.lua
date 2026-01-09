local TravelMenu = {}

function TravelMenu:new()
    local obj = {}
    obj.isOpen = false
    obj.locations = {
        { name = "Hostel", map = "maps/hostel.lua", cost = 10 },
        { name = "College", map = "maps/college_base_map.lua", cost = 20 }
    }
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function TravelMenu:open()
    self.isOpen = true
end

function TravelMenu:close()
    self.isOpen = false
end

function TravelMenu:mousepressed(x, y)
    if not self.isOpen then return nil end
    
    local sw, sh = love.graphics.getDimensions()
    local menuW, menuH = 400, 300
    local px, py = (sw - menuW)/2, (sh - menuH)/2
    
    -- Check list clicks
    local startY = py + 60
    for i, loc in ipairs(self.locations) do
        local btnY = startY + (i-1)*50
        if x >= px + 20 and x <= px + menuW - 20 and y >= btnY and y <= btnY + 40 then
            return loc
        end
    end
    
    -- Check Close (Click outside)
    if x < px or x > px + menuW or y < py or y > py + menuH then
        self:close()
    end
    
    return nil
end

function TravelMenu:draw()
    if not self.isOpen then return end
    
    local sw, sh = love.graphics.getDimensions()
    local menuW, menuH = 400, 300
    local px, py = (sw - menuW)/2, (sh - menuH)/2
    
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
    love.graphics.rectangle("fill", px, py, menuW, menuH, 10, 10)
    
    -- Header
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf("Select Destination", px, py + 20, menuW, "center")
    
    -- List
    local startY = py + 60
    for i, loc in ipairs(self.locations) do
        local btnY = startY + (i-1)*50
        
        -- Button
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.rectangle("fill", px + 20, btnY, menuW - 40, 40, 5, 5)
        
        -- Text
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(loc.name .. " (Cost: " .. loc.cost .. "m)", px + 30, btnY + 10, menuW - 60, "left")
    end
end

return TravelMenu
