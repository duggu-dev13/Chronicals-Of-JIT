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
        { name = "Social", color = {0.8, 0.2, 0.8}, action = "social" },
        { name = "ToDo", color = {0.2, 0.6, 0.8}, action = "todo" }
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

function PhoneOS:mousepressed(x, y, button, context)
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
            elseif self.currentApp == 'jobs' then
                -- Job 1 Button Detection (Hardcoded coordinates based on draw)
                -- Button is at: px+w-90, startY+35 (startY = py + 110)
                -- so y ~ py + 145
                local startY = py + 110
                local btnX = px + phoneW - 90
                local btnY = startY + 35
                
                if x >= btnX and x <= btnX + 60 and y >= btnY and y <= btnY + 30 then
                    -- Execute Job
                    if context and context.career then
                        if context.career.energy >= 30 then
                            context.career:modifyEnergy(-30)
                            context.career:earnMoney(150, "Freelance Job")
                            
                            if context.time then
                                context.time:addMinutes(120)
                            end
                            
                            if context.hud then
                                context.hud:addNotification("Job Done! +Rs.150")
                            end
                        else
                            if context.hud then
                                context.hud:addNotification("Not enough energy!")
                            end
                        end
                    end
                end
            end
        end
        return true -- Consumed input
    end
    
    return false
end

function PhoneOS:draw(extraData, messageManager, questManager)
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
    elseif self.currentApp == 'social' then
        self:drawSocialApp(px, py, phoneW, phoneH, messageManager)
    elseif self.currentApp == 'todo' then
        self:drawTodoApp(px, py, phoneW, phoneH, questManager)
    elseif self.currentApp == 'jobs' then
        self:drawJobsApp(px, py, phoneW, phoneH, extraData)
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
    love.graphics.printf("Back", px + w/2 - 40, py + h - 35, 80, "center")
end

function PhoneOS:drawSocialApp(px, py, w, h, messageManager)
    -- Header
    love.graphics.setColor(0.8, 0.2, 0.8, 1)
    love.graphics.rectangle("fill", px+10, py+10, w-20, 60, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("Social", px, py+25, w, "center")
    
    -- Messages List
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("Recent Messages:", px+20, py+80, w-40, "left")
    
    local startY = py + 110
    if messageManager and messageManager.messages then
        for i, msg in ipairs(messageManager.messages) do
            if i > 4 then break end -- Show last 4 only
            
            local y = startY + (i-1)*70
            
            -- Bubble Background
            love.graphics.setColor(0.95, 0.95, 0.95, 1)
            love.graphics.rectangle("fill", px+20, y, w-40, 60, 5, 5)
            
            -- Sender
            love.graphics.setColor(0.2, 0.2, 0.8, 1) -- Blue Name
            love.graphics.setFont(love.graphics.newFont(14))
            love.graphics.print(msg.sender, px+30, y+5)
            
            -- Time
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
            love.graphics.printf(msg.time, px+w-80, y+5, 50, "right")
            
            -- Preview Text
            love.graphics.setColor(0.2, 0.2, 0.2, 1)
            love.graphics.printf(msg.text, px+30, y+25, w-60, "left")
        end
    else
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.printf("No messages.", px+20, startY, w-40, "left")
    end
    
    -- Reuse Back Button
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", px + w/2 - 40, py + h - 40, 80, 30, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Back", px + w/2 - 40, py + h - 35, 80, "center")
end



function PhoneOS:drawTodoApp(px, py, w, h, questManager)
    -- Header
    love.graphics.setColor(0.2, 0.6, 0.8, 1)
    love.graphics.rectangle("fill", px+10, py+10, w-20, 60, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("ToDo List", px, py+25, w, "center")
    
    -- Quest List
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    
    local startY = py + 80
    if questManager and questManager.quests then
        -- Sort quests: Active first, then Completed
        local sortedQuests = {}
        for _, quest in pairs(questManager.quests) do
            table.insert(sortedQuests, quest)
        end
        table.sort(sortedQuests, function(a, b) return a.status < b.status end) -- 'active' < 'completed' alphabetically? No.
        -- 'active' comes before 'completed' alphabetically. So 'active' < 'completed' is true. 
        
        for _, quest in ipairs(sortedQuests) do
                -- Quest Title
                if quest.status == 'completed' then
                    love.graphics.setColor(0, 0.6, 0, 1) -- Green for Completed
                    love.graphics.setFont(love.graphics.newFont(18))
                    love.graphics.printf(quest.title .. " (Done)", px+20, startY, w-40, "left")
                else
                    love.graphics.setColor(0, 0, 0, 1)
                    love.graphics.setFont(love.graphics.newFont(18))
                    love.graphics.printf(quest.title, px+20, startY, w-40, "left")
                end
                startY = startY + 25
                
                -- Description (Only if active)
                if quest.status == 'active' then
                    love.graphics.setColor(0.4, 0.4, 0.4, 1)
                    love.graphics.setFont(love.graphics.newFont(12))
                    love.graphics.printf(quest.desc, px+20, startY, w-40, "left")
                    startY = startY + 20
                    
                    -- Objectives
                    for _, obj in ipairs(quest.objectives) do
                        local status = obj.completed and "[x]" or "[ ]"
                        if obj.completed then
                            love.graphics.setColor(0.2, 0.6, 0.2, 1) -- Green for done
                        else
                            love.graphics.setColor(0.8, 0.2, 0.2, 1) -- Red for todo
                        end
                        love.graphics.printf(status .. " " .. obj.desc, px+30, startY, w-50, "left")
                        startY = startY + 20
                    end
                end
                
                startY = startY + 20 -- Gap between quests
        end
    else
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.printf("No active tasks.", px+20, startY, w-40, "center")
    end
    
    -- Reuse Back Button
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", px + w/2 - 40, py + h - 40, 80, 30, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Back", px + w/2 - 40, py + h - 35, 80, "center")
end

function PhoneOS:drawJobsApp(px, py, w, h, careerManager)
     -- Header
    love.graphics.setColor(0.8, 0.5, 0.2, 1)
    love.graphics.rectangle("fill", px+10, py+10, w-20, 60, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("Gig Jobs", px, py+25, w, "center")
    
    -- Current Energy
    local energy = careerManager and careerManager.energy or 0
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf("Energy: " .. energy .. "/100", px+20, py+80, w-40, "center")
    
    -- Job List
    local startY = py + 110
    
    -- Job 1: Freelance Coding
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.rectangle("fill", px+20, startY, w-40, 100, 5, 5)
    
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Freelance Coding", px+30, startY+10)
    
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Fix bugs for a client.", px+30, startY+30)
    love.graphics.print("Earn: Rs. 150", px+30, startY+50)
    love.graphics.print("Cost: 30 Energy, 2 Hours", px+30, startY+65)
    
    -- Work Button (Mockup visual, click handled in mousepressed?? No, PhoneOS doesn't have logic callback yet)
    -- Wait, PhoneOS needs a way to trigger logic.
    -- For now, let's put a "Button" zone.
    
    love.graphics.setColor(0.2, 0.6, 0.2, 1)
    love.graphics.rectangle("fill", px+w-90, startY+35, 60, 30, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Do It", px+w-90, startY+40, 60, "center")
    
    -- Reuse Back Button
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", px + w/2 - 40, py + h - 40, 80, 30, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Back", px + w/2 - 40, py + h - 35, 80, "center")
end

return PhoneOS
