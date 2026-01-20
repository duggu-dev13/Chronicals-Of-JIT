local FormMenu = {}

function FormMenu:new(game)
    local obj = {
        game = game, -- Reference to GameState
        isOpen = false,
        
        -- Form Data
        name = "Alex",
        age = "18",
        department = "CS", -- CS, Civil, Mechanical, Electronics
        
        -- UI State
        activeField = 1, -- 1: Name, 2: Age, 3: Dept, 4: Submit
        departments = {"CS", "Civil", "Mechanical", "Electronics"},
        deptIndex = 1,
        
        -- Fonts
        fontTitle = love.graphics.newFont(32),
        fontLabel = love.graphics.newFont(24),
        fontInput = love.graphics.newFont(20)
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function FormMenu:open()
    self.isOpen = true
    self.activeField = 1
end

function FormMenu:close()
    self.isOpen = false
end

function FormMenu:update(dt)
    -- Blinking cursor logic could go here
end

function FormMenu:draw()
    if not self.isOpen then return end
    
    local w, h = love.graphics.getDimensions()
    
    -- Background Overlay
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Form Box
    local boxW, boxH = 500, 400
    local x, y = (w - boxW)/2, (h - boxH)/2
    
    love.graphics.setColor(0.1, 0.2, 0.3, 1)
    love.graphics.rectangle("fill", x, y, boxW, boxH, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, boxW, boxH, 10, 10)
    
    -- Title
    love.graphics.setFont(self.fontTitle)
    love.graphics.printf("JIT ADMISSION FORM", x, y + 20, boxW, 'center')
    
    -- Fields
    local startY = y + 100
    local gap = 60
    
    love.graphics.setFont(self.fontLabel)
    
    -- 1. Name
    self:drawField(x + 50, startY, "Name:", self.name, self.activeField == 1)
    
    -- 2. Age
    self:drawField(x + 50, startY + gap, "Age:", self.age, self.activeField == 2)
    
    -- 3. Department
    self:drawField(x + 50, startY + gap*2, "Dept:", "< " .. self.department .. " >", self.activeField == 3)
    
    -- 4. Submit
    love.graphics.setColor(self.activeField == 4 and {0, 1, 0, 1} or {0.5, 0.5, 0.5, 1})
    love.graphics.rectangle("fill", x + 150, startY + gap*3 + 20, 200, 50)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf("SUBMIT", x + 150, startY + gap*3 + 30, 200, 'center')
    
    love.graphics.setColor(1, 1, 1, 1)
end

function FormMenu:drawField(x, y, label, value, isActive)
    if isActive then
        love.graphics.setColor(1, 1, 0, 1)
    else
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    end
    love.graphics.print(label, x, y)
    love.graphics.print(value, x + 150, y)
    
    if isActive then
        love.graphics.print("_", x + 150 + love.graphics.getFont():getWidth(value) + 2, y)
    end
end

function FormMenu:textinput(t)
    if not self.isOpen then return end
    
    if self.activeField == 1 then
        self.name = self.name .. t
    elseif self.activeField == 2 then
        -- Only numbers for age
        if tonumber(t) then
            self.age = self.age .. t
        end
    end
end

function FormMenu:keypressed(key)
    if not self.isOpen then return end
    
    if key == 'tab' or key == 'down' then
        self.activeField = self.activeField + 1
        if self.activeField > 4 then self.activeField = 1 end
    elseif key == 'up' then
        self.activeField = self.activeField - 1
        if self.activeField < 1 then self.activeField = 4 end
    end
    
    if key == 'backspace' then
        if self.activeField == 1 then
            self.name = string.sub(self.name, 1, -2)
        elseif self.activeField == 2 then
            self.age = string.sub(self.age, 1, -2)
        end
    end
    
    if self.activeField == 3 then
        if key == 'left' then
            self.deptIndex = self.deptIndex - 1
            if self.deptIndex < 1 then self.deptIndex = #self.departments end
            self.department = self.departments[self.deptIndex]
        elseif key == 'right' or key == 'return' or key == 'space' then
            self.deptIndex = self.deptIndex + 1
            if self.deptIndex > #self.departments then self.deptIndex = 1 end
            self.department = self.departments[self.deptIndex]
        end
    end
    
    if key == 'return' and self.activeField == 4 then
        self:submit()
    end
end

function FormMenu:submit()
    print("Form Submitted: " .. self.name .. ", " .. self.department)
    
    -- Update Game State
    if self.game.careerManager then
        self.game.careerManager.department = self.department
        -- self.game.careerManager.name = self.name -- Add name field if needed
    end
    
    self:close()
    
    -- Trigger Next Story Step (e.g., StoryManager)
    if self.game.storyManager then
        self.game.storyManager:queueDialogue("System", "Admission Successful! Welcome to " .. self.department .. ".")
        self.game.storyManager:queueDialogue("Dad", "Great choice, " .. self.name .. ". " .. self.department .. " has a bright future.")
    end
end

return FormMenu
