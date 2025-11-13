-- menu.lua
-- Main menu state for the game

local Menu = {}

function Menu:new(stateManager)
    local obj = {}
    obj.stateManager = stateManager
    obj.selectedOption = 1
    obj.options = {
        {text = "Play Game", action = "play"},
        {text = "Settings", action = "settings"},
        {text = "Quit", action = "quit"}
    }
    obj.title = "Chronicals of the JIT: The Game"
    obj.titleFont = nil
    obj.optionFont = nil
    obj.titleY = 0
    obj.optionStartY = 0
    obj.optionSpacing = 60
    obj.optionWidth = 0
    obj.optionHeight = 0
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Menu:enter()
    -- Load fonts
    self.titleFont = love.graphics.newFont(48)
    self.optionFont = love.graphics.newFont(24)
    
    -- Calculate positions
    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    self.titleY = windowHeight * 0.3
    self.optionStartY = windowHeight * 0.5
    
    -- Calculate option dimensions
    local maxWidth = 0
    for _, option in ipairs(self.options) do
        local width = self.optionFont:getWidth(option.text)
        if width > maxWidth then
            maxWidth = width
        end
    end
    self.optionWidth = maxWidth + 40
    self.optionHeight = self.optionFont:getHeight() + 20
end

function Menu:update(dt)
    -- Check for mouse hover over options
    local mx, my = love.mouse.getPosition()
    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    
    for i, option in ipairs(self.options) do
        local y = self.optionStartY + (i - 1) * self.optionSpacing
        local x = (windowWidth - self.optionWidth) / 2
        
        if mx >= x and mx <= x + self.optionWidth and my >= y and my <= y + self.optionHeight then
            self.selectedOption = i
        end
    end
end

function Menu:draw()
    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    
    -- Draw background
    love.graphics.setColor(0.1, 0.1, 0.2, 1)
    love.graphics.rectangle('fill', 0, 0, windowWidth, windowHeight)
    
    -- Draw title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.titleFont)
    local titleWidth = self.titleFont:getWidth(self.title)
    love.graphics.printf(self.title, 0, self.titleY, windowWidth, 'center')
    
    -- Draw options
    love.graphics.setFont(self.optionFont)
    for i, option in ipairs(self.options) do
        local y = self.optionStartY + (i - 1) * self.optionSpacing
        local x = (windowWidth - self.optionWidth) / 2
        
        -- Highlight selected option
        if i == self.selectedOption then
            love.graphics.setColor(0.2, 0.4, 0.8, 0.8)
            love.graphics.rectangle('fill', x, y, self.optionWidth, self.optionHeight)
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
            love.graphics.rectangle('fill', x, y, self.optionWidth, self.optionHeight)
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
        end
        
        -- Draw option text
        love.graphics.printf(option.text, x, y + 10, self.optionWidth, 'center')
    end
    
    -- Draw instructions
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    -- love.graphics.printf("Use UP/DOWN arrows or mouse to navigate, ENTER/CLICK to select", 0, windowHeight - 50, windowWidth, 'center')
end

function Menu:keypressed(key)
    if key == 'up' then
        self.selectedOption = self.selectedOption - 1
        if self.selectedOption < 1 then
            self.selectedOption = #self.options
        end
    elseif key == 'down' then
        self.selectedOption = self.selectedOption + 1
        if self.selectedOption > #self.options then
            self.selectedOption = 1
        end
    elseif key == 'return' or key == 'space' then
        self:selectOption()
    elseif key == 'escape' then
        love.event.quit()
    end
end

function Menu:selectOption()
    local option = self.options[self.selectedOption]
    
    if option.action == "play" then
        self.stateManager:setState("game")
    elseif option.action == "settings" then
        -- TODO: Implement settings menuL
        print("Settings not implemented yet")
    elseif option.action == "quit" then
        love.event.quit()
    end
end

function Menu:mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        self:selectOption()
    end
end

function Menu:exit()
    -- Clean up if needed
end

return Menu
