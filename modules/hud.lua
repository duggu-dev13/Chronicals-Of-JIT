local HUD = {}

function HUD:new()
    local obj = {}
    
    -- Load fonts (using default for now if custom not available)
    obj.fontLarge = love.graphics.newFont(24)
    obj.fontSmall = love.graphics.newFont(16)
    
    setmetatable(obj, self)
    self.__index = self
    -- Notifications list: { text = "...", timer = 3.0, alpha = 1.0 }
    obj.notifications = {}
    -- Money Popups: { text = "+50", amount = 50, x = 0, y = 0, timer = 2.0, alpha = 1.0 }
    obj.moneyPopups = {}
    obj.displayMoney = 0
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function HUD:addNotification(text)
    table.insert(self.notifications, {
        text = text,
        timer = 4.0, -- Display duration
        yOffset = 0 -- For animation
    })
    print("Notification Added: " .. text)
end

function HUD:addMoneyPopup(amount)
    if amount == 0 then return end
    local text = (amount > 0 and "+" or "") .. amount
    table.insert(self.moneyPopups, {
        text = text,
        amount = amount,
        timer = 2.0,
        yOffset = 0
    })
end

function HUD:update(dt)
    -- Update Notifications
    for i = #self.notifications, 1, -1 do
        local n = self.notifications[i]
        n.timer = n.timer - dt
        if n.timer <= 0 then
            table.remove(self.notifications, i)
        end
    end
    
    -- Update Money Popups
    for i = #self.moneyPopups, 1, -1 do
        local p = self.moneyPopups[i]
        p.timer = p.timer - dt
        p.yOffset = p.yOffset - (20 * dt) -- Float up
        if p.timer <= 0 then
            table.remove(self.moneyPopups, i)
        end
    end
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
    
    -- Rolling Counter Logic (Visual only)
    local targetMoney = money or 0
    if math.abs(self.displayMoney - targetMoney) > 0.5 then
        self.displayMoney = self.displayMoney + (targetMoney - self.displayMoney) * 10 * love.timer.getDelta()
    else
        self.displayMoney = targetMoney
    end
    
    love.graphics.print("Rs." .. math.floor(self.displayMoney), 20, 25)
    
    -- Draw Money Popups
    for _, p in ipairs(self.moneyPopups) do
        local alpha = math.min(1, p.timer)
        if p.amount >= 0 then
            love.graphics.setColor(0, 1, 0, alpha) -- Green
        else
            love.graphics.setColor(1, 0, 0, alpha) -- Red
        end
        love.graphics.setFont(self.fontSmall)
        love.graphics.print(p.text, 80 + (p.timer > 1.5 and 5 or 0), 25 + p.yOffset) -- Little shake effect
    end
    
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
    
    -- 4. Draw Notifications (Top Center)
    local startY = 100
    for i, n in ipairs(self.notifications) do
        local alpha = math.min(1, n.timer) -- Fade out in last second
        love.graphics.setColor(0, 0, 0, 0.8 * alpha)
        local textW = self.fontSmall:getWidth(n.text) + 40
        local textH = 40
        local nx = (width - textW) / 2
        local ny = startY + (i-1)*(textH + 10)
        
        -- Box
        love.graphics.rectangle("fill", nx, ny, textW, textH, 10, 10)
        
        -- Text
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.printf(n.text, nx, ny + 10, textW, "center")
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return HUD
