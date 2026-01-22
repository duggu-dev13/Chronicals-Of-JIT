local PhoneOS = {}

function PhoneOS:new()
    local obj = {}
    obj.isOpen = false
    obj.currentApp = nil 
    
    -- Mock Data for Status Bar
    obj.batteryLevel = 85
    obj.signalStrength = 4
    
    obj.apps = {
        { name = "M-Bank", color = {0.2, 0.8, 0.2}, action = "bank", icon = "💳", installed = false },
        { name = "Jobs", color = {0.8, 0.5, 0.2}, action = "jobs", icon = "💼", installed = false },
        { name = "Maps", color = {0.2, 0.2, 0.8}, action = "maps", icon = "🗺️", installed = true }, -- Maps always available
        { name = "Social", color = {0.8, 0.2, 0.8}, action = "social", icon = "💬", installed = false },
        { name = "ToDo", color = {0.2, 0.6, 0.8}, action = "todo", icon = "📝", installed = false }
    }
    
    -- Preload Fonts
    obj.fonts = {
        tiny = love.graphics.newFont(12),
        small = love.graphics.newFont(14),
        regular = love.graphics.newFont(16),
        medium = love.graphics.newFont(24),
        large = love.graphics.newFont(32),
        huge = love.graphics.newFont(48) -- Even bigger clock
    }
    
    -- Animation State
    obj.animationTimer = 0
    obj.isOpening = false
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function PhoneOS:installApp(actionName)
    for _, app in ipairs(self.apps) do
        if app.action == actionName or actionName == 'all' then
            app.installed = true
        end
    end
end

function PhoneOS:update(dt)
    if self.isOpen then
        self.animationTimer = math.min(1, self.animationTimer + dt * 2) -- Slide in speed
    else
        self.animationTimer = 0
    end
end

function PhoneOS:toggle()
    self.isOpen = not self.isOpen
    if not self.isOpen then
        self.currentApp = nil
        self.animationTimer = 0
    else
        self.animationTimer = 0 -- Start animation on open
        self.isOpening = true
    end
end

function PhoneOS:keypressed(key)
    if not self.isOpen then return false end
    -- Future keyboard navigation or shortcuts
    if key == 'escape' then
        self:toggle()
        return true
    end
    return false
end

function PhoneOS:mousepressed(x, y, button, context)
    if not self.isOpen then return false end
    
    local sw, sh = love.graphics.getDimensions()
    local phoneW, phoneH = 300, 550
    local px, py = (sw - phoneW)/2, (sh - phoneH)/2
    
    -- Screen Area (same as draw)
    local screenX, screenY = px + 10, py + 10
    local screenW, screenH = phoneW - 20, phoneH - 20
    
    -- Check if click is inside phone frame
    if x >= px and x <= px + phoneW and y >= py and y <= py + phoneH then
        
        -- 1. Check Home Bar (Bottom Area relative to screen)
        -- Draw: screenY + screenH - 15, height 5. Check area larger for usability.
        if y > screenY + screenH - 40 then
            self.currentApp = nil -- Go Home
            return true
        end
        
        -- 2. App Interaction
        if not self.currentApp then
            -- Home Screen Clicks
            local iconSize = 60
            local gap = 25
            -- Draw logic: startX = screenX + 25, startY = screenY + 160
            local startX = screenX + 25
            local startY = screenY + 160
            
            for i, app in ipairs(self.apps) do
                local col = (i-1) % 3
                local row = math.floor((i-1) / 3)
                local ix = startX + col * (iconSize + gap)
                local iy = startY + row * (iconSize + gap + 20)
                
                if app.installed then -- Only clickable if installed
                    if x >= ix and x <= ix + iconSize and y >= iy and y <= iy + iconSize then
                        self.currentApp = app.action
                    end
                end
            end
        else
            -- Inside App Actions
            if self.currentApp == 'jobs' then
                -- Job Button Detection
                -- Draw logic: topY = screenY + 30. jY = topY + 80 = screenY + 110.
                -- Button Y = jY + 35 = screenY + 145.
                -- Button X = screenX + screenW - 80.
                local topY = screenY + 30
                local jY = topY + 80
                local btnY = jY + 35
                local btnX = screenX + screenW - 80
                
                if x >= btnX and x <= btnX + 60 and y >= btnY and y <= btnY + 30 then
                    -- Execute Job Logic
                    if context and context.career then
                        if context.career.energy >= 30 then
                            context.career:modifyEnergy(-30)
                            context.career:earnMoney(150, "Freelance Job")
                            if context.time then context.time:addMinutes(120) end
                            if context.hud then context.hud:addNotification("Job Done! +Rs.150") end
                        else
                            if context.hud then context.hud:addNotification("Not enough energy!") end
                        end
                    end
                end
            end
        end
        return true
    end
    
    return false
end

function PhoneOS:draw(extraData, messageManager, questManager, timeSystem, player)
    if not self.isOpen then return end
    
    local sw, sh = love.graphics.getDimensions()
    local phoneW, phoneH = 300, 550
    local px, py = (sw - phoneW)/2, (sh - phoneH)/2
    
    -- 1. Outer Frame (Bezel)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", px, py, phoneW, phoneH, 30, 30)
    
    -- 2. Screen Area
    love.graphics.setColor(0.05, 0.05, 0.05, 1)        
    local screenX, screenY = px + 10, py + 10
    local screenW, screenH = phoneW - 20, phoneH - 20
    
    -- Scissor for screen content clipping
    love.graphics.setScissor(screenX, screenY, screenW, screenH)
        
        if not self.currentApp then
            self:drawHomeScreen(screenX, screenY, screenW, screenH, timeSystem)
        else
            -- App Background (Usually white/light)
            love.graphics.setColor(0.95, 0.95, 0.98, 1)
            love.graphics.rectangle("fill", screenX, screenY, screenW, screenH, 20, 20)
            
            if self.currentApp == 'bank' then self:drawBankApp(screenX, screenY, screenW, screenH, extraData)
            elseif self.currentApp == 'social' then self:drawSocialApp(screenX, screenY, screenW, screenH, messageManager)
            elseif self.currentApp == 'todo' then self:drawTodoApp(screenX, screenY, screenW, screenH, questManager)
            elseif self.currentApp == 'jobs' then self:drawJobsApp(screenX, screenY, screenW, screenH, extraData)
            elseif self.currentApp == 'maps' then self:drawMapsApp(screenX, screenY, screenW, screenH, player)
            end
        end
        
        -- 3. Status Bar (Always on top)
        self:drawStatusBar(screenX, screenY, screenW, timeSystem)
        
        -- 4. Home Bar (Always on top)
        love.graphics.setColor(0.8, 0.8, 0.8, 0.5)
        love.graphics.rectangle("fill", screenX + (screenW - 100)/2, screenY + screenH - 15, 100, 5, 2.5, 2.5)

    love.graphics.setScissor() -- Disable scissor
    
    -- Reset State
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
end

function PhoneOS:drawStatusBar(x, y, w, timeSystem)
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", x, y, w, 25)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.fonts.tiny)
    
    -- Time (Left)
    local timeStr = timeSystem and timeSystem:getTimeString() or "12:00"
    love.graphics.print(timeStr, x + 15, y + 5)
    
    -- Icons (Right)
    love.graphics.print("Wifi  100%", x + w - 70, y + 5)
end

function PhoneOS:drawHomeScreen(x, y, w, h, timeSystem)
    -- Wallpaper (Vertical Gradient)
    for i = 0, h do
        local r = 0.2 + (i/h)*0.3 
        local g = 0.1 + (i/h)*0.1
        local b = 0.4 + (i/h)*0.4 -- Purple/Blue gradient
        love.graphics.setColor(r, g, b, 1)
        love.graphics.line(x, y+i, x+w, y+i)
    end
    
    -- Big Clock Widget
    local timeStr = timeSystem and timeSystem:getTimeString() or "12:00"
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.setFont(self.fonts.huge)
    love.graphics.printf(timeStr, x, y + 60, w, "center")
    
    love.graphics.setFont(self.fonts.small)
    love.graphics.printf("Friday, Jan 16", x, y + 110, w, "center") -- Mock Date
    
    -- App Grid
    local iconSize = 60
    local gap = 25
    local startX = x + 25
    local startY = y + 160
    
    for i, app in ipairs(self.apps) do
        local col = (i-1) % 3
        local row = math.floor((i-1) / 3)
        local ix = startX + col * (iconSize + gap)
        local iy = startY + row * (iconSize + gap + 20)
        
        if app.installed then
            -- Icon
            love.graphics.setColor(app.color)
            love.graphics.rectangle("fill", ix, iy, iconSize, iconSize, 15, 15) -- Rounded
            
            -- Symbol (using emoji text for now, could be images)
            love.graphics.setColor(1, 1, 1, 1)
            -- love.graphics.printf(app.icon or "", ix, iy + 15, iconSize, "center") -- Emojis might break font, disabling for safety
            
            -- Label
            love.graphics.setFont(self.fonts.tiny)
            love.graphics.printf(app.name, ix - 5, iy + iconSize + 5, iconSize + 10, "center")
        end
    end
end

-- App Draw Functions (Restored with updated fonts and layout offsets)

function PhoneOS:drawBankApp(x, y, w, h, careerManager)
    local topY = y + 30 
    
    -- Header
    love.graphics.setColor(0.2, 0.8, 0.2, 1)
    love.graphics.setFont(self.fonts.medium)
    love.graphics.printf("M-Bank", x, topY, w, "center")
    
    -- Balance
    local balance = careerManager and careerManager.money or 0
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.setFont(self.fonts.large)
    love.graphics.printf("Rs." .. balance, x, topY + 80, w, "center")
    love.graphics.setFont(self.fonts.small)
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.printf("Current Balance", x, topY + 120, w, "center")
    
    -- List container
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.printf("Recent Transactions:", x + 20, topY + 160, w, "left")
    
    -- ... (Transactions logic simplified for brevity, assume scrollable later)
    -- Just showing placeholder items
    local ty = topY + 190
    if careerManager and careerManager.history then
        for i, trans in ipairs(careerManager.history) do
            if i > 4 then break end
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
            love.graphics.setFont(self.fonts.small)
            love.graphics.print(trans.desc, x + 20, ty)
            
            if trans.amount >= 0 then love.graphics.setColor(0, 0.6, 0, 1) else love.graphics.setColor(0.8, 0, 0, 1) end
            love.graphics.printf(trans.amount, x + w - 80, ty, 60, "right")
            ty = ty + 30
        end
    end
end

function PhoneOS:drawSocialApp(x, y, w, h, messageManager)
    local topY = y + 30
    love.graphics.setColor(0.8, 0.2, 0.8, 1)
    love.graphics.setFont(self.fonts.medium)
    love.graphics.printf("Social", x, topY, w, "center")
    
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.setFont(self.fonts.regular)
    love.graphics.printf("Recent Messages", x + 20, topY + 60, w, "left")
    
    -- Just placeholder logic
    local msgY = topY + 90
    if messageManager and messageManager.messages then
        for i, msg in ipairs(messageManager.messages) do
             if i > 3 then break end
             love.graphics.setColor(0.9, 0.9, 0.9, 1)
             love.graphics.rectangle("fill", x+15, msgY, w-30, 60, 10, 10)
             
             love.graphics.setColor(0.2, 0.2, 0.8, 1)
             love.graphics.setFont(self.fonts.small)
             love.graphics.print(msg.sender, x+25, msgY+5)
             
             love.graphics.setColor(0.3, 0.3, 0.3, 1)
             love.graphics.printf(msg.text, x+25, msgY+25, w-50, "left")
             
             msgY = msgY + 70
        end
    end
end

function PhoneOS:drawTodoApp(x, y, w, h, questManager)
    local topY = y + 30
    local animOffset = (1 - self.animationTimer) * 50 -- Slide up effect
    
    love.graphics.setColor(0.2, 0.6, 0.8, 1)
    love.graphics.setFont(self.fonts.medium)
    love.graphics.printf("ToDo", x, topY, w, "center")
    
    local qY = topY + 60
    
    if questManager and questManager.quests then
        -- Separated Lists
        local activeQuests = {}
        local completedQuests = {}
        
        for _, quest in pairs(questManager.quests) do
            if quest.status == 'active' then table.insert(activeQuests, quest)
            elseif quest.status == 'completed' then table.insert(completedQuests, quest) end
        end
        
        -- Sort for stability
        table.sort(activeQuests, function(a, b) return a.title < b.title end)
        table.sort(completedQuests, function(a, b) return a.title < b.title end)
        
        -- Draw Active Section
        if #activeQuests > 0 then
            love.graphics.setColor(0.8, 0.2, 0.2, 1) -- Section Header: RED (Not Completed)
            love.graphics.setFont(self.fonts.small)
            love.graphics.print("PENDING TASKS", x + 20, qY + animOffset)
            qY = qY + 25
            
            for _, quest in ipairs(activeQuests) do
                -- Red Checkbox
                love.graphics.setColor(0.8, 0.2, 0.2, 1)
                love.graphics.setFont(self.fonts.regular)
                love.graphics.print("☐", x + 20, qY + animOffset)
                
                -- Black Text
                love.graphics.setColor(0.1, 0.1, 0.1, 1)
                love.graphics.print(" " .. quest.title, x + 35, qY + animOffset)
                
                -- Description
                love.graphics.setColor(0.4, 0.4, 0.4, 1)
                love.graphics.setFont(self.fonts.tiny)
                love.graphics.print(quest.desc, x + 40, qY + 20 + animOffset)
                qY = qY + 50
            end
            qY = qY + 10 -- Spacer
        end
        
        -- Draw Completed Section
        if #completedQuests > 0 then
            love.graphics.setColor(0.2, 0.6, 0.2, 1) -- Section Header: GREEN (Completed)
            love.graphics.setFont(self.fonts.small)
            love.graphics.print("COMPLETED", x + 20, qY + animOffset)
            qY = qY + 25
            
            for _, quest in ipairs(completedQuests) do
                -- Green Checkbox and Text (Dimmed)
                love.graphics.setColor(0.2, 0.6, 0.2, 0.8) 
                love.graphics.setFont(self.fonts.regular)
                love.graphics.print("☑ " .. quest.title, x + 20, qY + animOffset)
                qY = qY + 30
            end
        end
    end
end

function PhoneOS:drawJobsApp(x, y, w, h, careerManager)
    local topY = y + 30
    love.graphics.setColor(0.8, 0.5, 0.2, 1)
    love.graphics.setFont(self.fonts.medium)
    love.graphics.printf("Gig Jobs", x, topY, w, "center")
    
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.setFont(self.fonts.small)
    love.graphics.printf("En: " .. (careerManager.energy or 0), x, topY + 40, w, "center")
    
    -- Job Card
    local jY = topY + 80
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", x + 20, jY, w - 40, 100, 10, 10)
    
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(self.fonts.regular)
    love.graphics.print("Freelance Coding", x + 30, jY + 10)
    
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.setFont(self.fonts.tiny)
    love.graphics.print("Fix bugs. Rs.150", x + 30, jY + 35)
    
    -- Button
    love.graphics.setColor(0.2, 0.6, 0.2, 1)
    love.graphics.rectangle("fill", x + w - 80, jY + 35, 60, 30, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Do It", x + w - 80, jY + 40, 60, "center")
end

function PhoneOS:drawMapsApp(x, y, w, h, player)
    -- Map Config
    local scale = 0.12 -- Map Scale
    local offsetX = x + w/2 - (1800 * scale) -- Center on Gate (roughly)
    local offsetY = y + h/2 - (2500 * scale)
    
    -- Background (Grass)
    love.graphics.setColor(0.2, 0.5, 0.2, 1)
    love.graphics.rectangle("fill", x, y, w, h)
    
    -- Clip to Screen
    love.graphics.setScissor(x, y, w, h)
    
    -- Draw Roads / Areas (Simplified)
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    -- Main Road Vertical
    love.graphics.rectangle("fill", offsetX + 1750*scale, offsetY + 0, 100*scale, 3000*scale)
    -- Horizontal Road (Canteen)
    love.graphics.rectangle("fill", offsetX + 1000*scale, offsetY + 2000*scale, 1000*scale, 100*scale)
    
    -- Draw Buildings (Rects)
    -- Canteen
    love.graphics.setColor(0.8, 0.4, 0.2, 1)
    love.graphics.rectangle("fill", offsetX + 1100*scale, offsetY + 1800*scale, 200*scale, 200*scale)
    love.graphics.setColor(1, 1, 1, 1); love.graphics.print("Canteen", offsetX + 1100*scale, offsetY + 1800*scale)
    
    -- College Block
    love.graphics.setColor(0.3, 0.3, 0.8, 1)
    love.graphics.rectangle("fill", offsetX + 100*scale, offsetY + 100*scale, 600*scale, 400*scale)
    love.graphics.setColor(1, 1, 1, 1); love.graphics.print("College", offsetX + 100*scale, offsetY + 100*scale)
    
    -- Hostel
    love.graphics.setColor(0.6, 0.2, 0.6, 1)
    love.graphics.rectangle("fill", offsetX + 2800*scale, offsetY + 500*scale, 300*scale, 300*scale)
    love.graphics.print("Hostel", offsetX + 2800*scale, offsetY + 500*scale)
    
    -- Player Marker
    if player and player.x then
        local px = offsetX + player.x * scale
        local py = offsetY + player.y * scale
        
        love.graphics.setColor(0, 0, 1, 1) -- Blue
        love.graphics.circle("fill", px, py, 6)
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.circle("line", px, py, 8)
    end
    
    love.graphics.setScissor() -- Reset Clip
    
    -- UI Overlay (Title)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.fonts.medium)
    love.graphics.printf("Campus Map", x, y + 20, w, "center")
end

return PhoneOS
