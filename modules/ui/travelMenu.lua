local TravelMenu = {}

function TravelMenu:new()
    local obj = {}
    obj.isOpen = false
    obj.locations = {
        { name = "Hostel", map = "maps/hostel.lua", cost = 20, moneyCost = 100 },
        { name = "College", map = "maps/college_base_map.lua", cost = 20, moneyCost = 100 }
    }
    
    setmetatable(obj, self)
    self.__index = self
    
    -- Preload Fonts
    obj.fonts = {
        title = love.graphics.newFont(20),
        item = love.graphics.newFont(16) -- Default size
    }
    
    return obj
end

function TravelMenu:open(currentMap)
    print("[TravelMenu] Opening menu. Current Map: " .. tostring(currentMap))
    self.isOpen = true
    self.filteredLocations = {}
    for _, loc in ipairs(self.locations) do
        if loc.map ~= currentMap then
            table.insert(self.filteredLocations, loc)
        end
    end
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
    for i, loc in ipairs(self.filteredLocations or self.locations) do
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
    love.graphics.setFont(self.fonts.title)
    love.graphics.printf("Select Destination", px, py + 20, menuW, "center")
    
    -- List
    local startY = py + 60
    love.graphics.setFont(self.fonts.item)
    
    for i, loc in ipairs(self.filteredLocations or self.locations) do
        local btnY = startY + (i-1)*50
        
        -- Button
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.rectangle("fill", px + 20, btnY, menuW - 40, 40, 5, 5)
        
        -- Text
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(loc.name .. " (Time: " .. loc.cost .. "m | Fare: Rs." .. (loc.moneyCost or 0) .. ")", px + 30, btnY + 10, menuW - 60, "left")
    end
end

return TravelMenu
