local PhoneOS = {}

function PhoneOS:new()
    local obj = {}
    obj.isOpen = false
    obj.currentApp = nil -- nil = Home Screen
    
    -- Placeholder for Apps
    obj.apps = {
        { name = "M-Bank", color = {0.2, 0.8, 0.2}, action = "bank" },
        { name = "Jobs", color = {0.8, 0.5, 0.2}, action = "jobs" },
        { name = "Maps", color = {0.2, 0.2, 0.8}, action = "maps" },
        { name = "Social", color = {0.8, 0.2, 0.8}, action = "social" }
    }
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function PhoneOS:toggle()
    self.isOpen = not self.isOpen
    if not self.isOpen then
        self.currentApp = nil -- Reset to home on close
    end
end

function PhoneOS:mousepressed(x, y, button)
    if not self.isOpen then return false end
    
    -- Phone Screen Area (Centered)
    local sw, sh = love.graphics.getDimensions()
    local phoneW, phoneH = 300, 500
    local px, py = (sw - phoneW)/2, (sh - phoneH)/2
    
    -- Check if click is inside phone
    if x >= px and x <= px + phoneW and y >= py and y <= py + phoneH then
        -- Handle clicks
        if not self.currentApp then
            -- Home Screen Clicks
            local iconSize = 60
            local gap = 20
            local startX = px + gap
            local startY = py + 100
            
            for i, app in ipairs(self.apps) do
                local col = (i-1) % 3
                local row = math.floor((i-1) / 3)
                local ix = startX + col * (iconSize + gap)
                local iy = startY + row * (iconSize + gap)
                
                if x >= ix and x <= ix + iconSize and y >= iy and y <= iy + iconSize then
                    self.currentApp = app.action
                end
            end
        else
            -- App Screen Clicks (Back Button)
            -- Placeholder Back Button at bottom
            if y > py + phoneH - 50 then
                self.currentApp = nil
            end
        end
        return true -- Consumed input
    end
    
    return false
end

function PhoneOS:draw(extraData)
    if not self.isOpen then return end
    
    local sw, sh = love.graphics.getDimensions()
    local phoneW, phoneH = 300, 500
    local px, py = (sw - phoneW)/2, (sh - phoneH)/2
    
    -- Draw Frame
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", px, py, phoneW, phoneH, 20, 20)
    
    -- Draw Screen
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.rectangle("fill", px + 10, py + 10, phoneW - 20, phoneH - 20, 10, 10)
    
    if not self.currentApp then
        -- Draw Home Screen
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf("12:00", px, py + 30, phoneW, "center")
        
        local iconSize = 60
        local gap = 20
        local startX = px + 30 -- Adjusted for centering
        local startY = py + 100
        
        for i, app in ipairs(self.apps) do
            local col = (i-1) % 3
            local row = math.floor((i-1) / 3)
            local ix = startX + col * (iconSize + gap)
            local iy = startY + row * (iconSize + gap)
            
            love.graphics.setColor(app.color)
            love.graphics.rectangle("fill", ix, iy, iconSize, iconSize, 10, 10)
            
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.printf(app.name, ix, iy + iconSize + 5, iconSize, "center")
        end
    elseif self.currentApp == 'bank' then
        self:drawBankApp(px, py, phoneW, phoneH, extraData)
    else
        -- Back Button
        love.graphics.setColor(0.8, 0.2, 0.2, 1)
        love.graphics.rectangle("fill", px + phoneW/2 - 40, py + phoneH - 40, 80, 30, 5, 5)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Back", px + phoneW/2 - 40, py + phoneH - 35, 80, "center")
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function PhoneOS:drawBankApp(px, py, w, h, careerManager)
    -- Header
    love.graphics.setColor(0.2, 0.8, 0.2, 1)
    love.graphics.rectangle("fill", px+10, py+10, w-20, 60, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("M-Bank", px, py+25, w, "center")
    
    -- Balance
    local balance = careerManager and careerManager.money or 0
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("Rs." .. balance, px, py+100, w, "center")
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("Current Balance", px, py+140, w, "center")
    
    -- Transaction History
    love.graphics.printf("Recent Transactions:", px+20, py+180, w-40, "left")
    
    local startY = py + 210
    if careerManager and careerManager.history then
        for i, trans in ipairs(careerManager.history) do
            if i > 5 then break end -- Show last 5 only
            
            local y = startY + (i-1)*30
            
            -- Description
            love.graphics.setColor(0.3, 0.3, 0.3, 1)
            love.graphics.printf(trans.desc, px+20, y, w-100, "left")
            
            -- Amount
            if trans.amount >= 0 then
                love.graphics.setColor(0, 0.6, 0, 1) -- Green
                love.graphics.printf("+" .. trans.amount, px+w-80, y, 60, "right")
            else
                love.graphics.setColor(0.8, 0, 0, 1) -- Red
                love.graphics.printf(trans.amount, px+w-80, y, 60, "right")
            end
        end
    else
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.printf("No transactions.", px+20, startY, w-40, "left")
    end
    
    -- Reuse Back Button
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", px + w/2 - 40, py + h - 40, 80, 30, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Back", px + w/2 - 40, py + h - 35, 80, "center")
end

return PhoneOS
