local Menu = {}

function Menu:new(stateManager)
    local obj = {}
    obj.stateManager = stateManager

    obj.mode = 'main' -- 'main', 'character', 'settings'
    obj.selectedOption = 1
    
    -- Main Menu Options
    obj.mainOptions = {
        { text = "Start Journey", action = "character_select" },
        { text = "Options", action = "settings" },
        { text = "Exit", action = "quit" }
    }

    -- Character Selection
    obj.characterOptions = {
        { text = "Student", characterId = "student", desc = "Balance of Time & Money." },
        { text = "Scholar", characterId = "teacher", desc = "High Knowledge, Low Energy." }
    }
    
    -- Settings Options
    obj.settingsOptions = {
        { text = "Music Volume: 100%", action = "toggle_music" },
        { text = "Fullscreen: Off", action = "toggle_fullscreen" },
        { text = "Back", action = "back" }
    }

    -- Styling
    obj.title = "ACADEMIC LIFE"
    obj.subtitle = "Chronicles of the JIT"
    
    -- Fonts (loaded in enter)
    obj.fonts = {}
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Menu:enter()
    -- Load Fonts
    self.fonts.title = love.graphics.newFont(64)
    self.fonts.subtitle = love.graphics.newFont(24)
    self.fonts.option = love.graphics.newFont(28)
    self.fonts.small = love.graphics.newFont(16)
end

function Menu:getActiveOptions()
    if self.mode == 'character' then return self.characterOptions end
    if self.mode == 'settings' then return self.settingsOptions end
    return self.mainOptions
end

function Menu:update(dt)
    local options = self:getActiveOptions()
    if #options == 0 then return end

    -- Mouse Hover Logic
    local mx, my = love.mouse.getPosition()
    local w, h = love.graphics.getDimensions()
    local startY = h * 0.5
    local spacing = 60
    
    for i, opt in ipairs(options) do
        local y = startY + (i-1) * spacing
        -- Center checking
        local textW = self.fonts.option:getWidth(opt.text)
        local x = (w - textW) / 2
        
        if mx >= x - 20 and mx <= x + textW + 20 and my >= y and my <= y + 40 then
            self.selectedOption = i
        end
    end
end

function Menu:draw()
    local w, h = love.graphics.getDimensions()
    
    -- Background Gradient (Fake)
    for i = 0, h do
        local c = 0.1 + (i/h) * 0.1
        love.graphics.setColor(c, c, c+0.1, 1)
        love.graphics.line(0, i, w, i)
    end
    
    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.fonts.title)
    love.graphics.printf(self.title, 0, h*0.15, w, "center")
    
    love.graphics.setColor(0.6, 0.8, 1, 1)
    love.graphics.setFont(self.fonts.subtitle)
    love.graphics.printf(self.subtitle, 0, h*0.28, w, "center")
    
    -- Menu Box
    local options = self:getActiveOptions()
    local startY = h * 0.5
    local spacing = 60
    
    for i, opt in ipairs(options) do
        local y = startY + (i-1) * spacing
        
        if i == self.selectedOption then
            -- Highlight
            love.graphics.setColor(1, 0.8, 0, 1) -- Gold highlight
            love.graphics.setFont(self.fonts.option)
            love.graphics.printf("> " .. opt.text .. " <", 0, y, w, "center")
            
            -- Description (if exists)
            if opt.desc then
                love.graphics.setColor(0.8, 0.8, 0.8, 1)
                love.graphics.setFont(self.fonts.small)
                love.graphics.printf(opt.desc, 0, h - 50, w, "center")
            end
        else
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
            love.graphics.setFont(self.fonts.option)
            love.graphics.printf(opt.text, 0, y, w, "center")
        end
    end
    
    -- Footer
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.setFont(self.fonts.small)
    love.graphics.printf("v0.2.1-alpha", 10, h-30, w, "left")
end

function Menu:keypressed(key)
    local options = self:getActiveOptions()
    
    if key == 'up' then
        self.selectedOption = self.selectedOption - 1
        if self.selectedOption < 1 then self.selectedOption = #options end
    elseif key == 'down' then
        self.selectedOption = self.selectedOption + 1
        if self.selectedOption > #options then self.selectedOption = 1 end
    elseif key == 'return' or key == 'space' then
        self:executeOption(options[self.selectedOption])
    elseif key == 'escape' then
        if self.mode ~= 'main' then
            self.mode = 'main'
            self.selectedOption = 1
        else
            love.event.quit()
        end
    end
end

function Menu:mousepressed(x, y, button)
    if button == 1 then
        local options = self:getActiveOptions()
        self:executeOption(options[self.selectedOption])
    end
end

function Menu:executeOption(opt)
    if not opt then return end
    
    if opt.action == 'character_select' then
        self.mode = 'character'
        self.selectedOption = 1
    elseif opt.action == 'settings' then
        self.mode = 'settings'
        self.selectedOption = 1
    elseif opt.action == 'quit' then
        love.event.quit()
    elseif opt.action == 'back' then
        self.mode = 'main'
        self.selectedOption = 1
    elseif opt.action == 'toggle_fullscreen' then
        local isFull = love.window.getFullscreen()
        love.window.setFullscreen(not isFull)
        opt.text = "Fullscreen: " .. (not isFull and "On" or "Off")
    elseif opt.action == 'toggle_music' then
        -- Placeholder
        opt.text = "Music Volume: " .. (opt.text:find("100") and "0% (Muted)" or "100%")
    elseif opt.characterId then
        -- Start Game
        local gameState = self.stateManager.states["game"]
        if gameState then
            if gameState.prepareNewGame then gameState:prepareNewGame(opt.characterId) end
            if gameState.setSelectedCharacter then gameState:setSelectedCharacter(opt.characterId) end
            self.stateManager:setState("game")
        end
    end
end

function Menu:exit()
    -- Cleanup if needed
end

return Menu
