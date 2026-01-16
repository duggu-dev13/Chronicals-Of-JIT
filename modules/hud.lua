local HUD = {}

function HUD:new()
    local obj = {}
    
    -- Load fonts (using default for now if custom not available)
    obj.fontLarge = love.graphics.newFont(24)
    obj.fontSmall = love.graphics.newFont(16)
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function HUD:draw(timeString, day, money, energy)
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- 1. Top Right: Clock Panel
    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    love.graphics.rectangle("fill", width - 160, 10, 150, 80, 10, 10)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.fontLarge)
    love.graphics.print(timeString, width - 130, 20)
    
    love.graphics.setFont(self.fontSmall)
    love.graphics.print("Day " .. day, width - 130, 50)
    
    -- 2. Top Left: Money & Stats
    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    love.graphics.rectangle("fill", 10, 10, 200, 50, 10, 10)
    
    love.graphics.setColor(1, 1, 0, 1) -- Gold for Money
    love.graphics.print("Rs." .. (money or 0), 20, 25)
    
    -- 3. Bottom Left: Energy Bar
    if energy then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 10, height - 40, 200, 20) -- Back
        
        love.graphics.setColor(0, 1, 0, 1) -- Green
        local barWidth = (energy / 100) * 200
        love.graphics.rectangle("fill", 10, height - 40, barWidth, 20) -- Front
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Energy", 20, height - 60)
    end
    
    -- Reset
    love.graphics.setColor(1, 1, 1, 1)
end

return HUD
