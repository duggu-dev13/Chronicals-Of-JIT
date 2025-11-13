local Menu = {}

function Menu:new(stateManager)
    local obj = {}
    obj.stateManager = stateManager

    obj.mode = 'main'
    obj.selectedOption = 1
    obj.characterSelected = 1

    obj.mainOptions = {
        { text = "Start New Game", action = "character_select" },
        { text = "Settings", action = "settings" },
        { text = "Quit", action = "quit" }
    }

    obj.characterOptions = {
        { text = "Play as Student", characterId = "student" },
        { text = "Play as Teacher", characterId = "teacher" }
    }

    obj.title = "Chronicles of the JIT: The Game"
    obj.characterTitle = "Choose Your Role"

    obj.titleFont = nil
    obj.optionFont = nil
    obj.instructionFont = nil
    obj.titleY = 0
    obj.optionStartY = 0
    obj.optionSpacing = 60
    obj.optionWidth = 0
    obj.optionHeight = 0

    obj.characterStartY = 0
    obj.characterSpacing = 70
    obj.characterOptionWidth = 0
    obj.characterOptionHeight = 0

    setmetatable(obj, self)
    self.__index = self
    return obj
end

local function computeOptionDimensions(font, options)
    local padding = 40
    local heightPadding = 20
    local maxWidth = 0
    for _, option in ipairs(options) do
        local width = font:getWidth(option.text or "")
        if width > maxWidth then
            maxWidth = width
        end
    end
    local boxWidth = maxWidth + padding
    local boxHeight = font:getHeight() + heightPadding
    return boxWidth, boxHeight
end

local function optionBounds(centerWidth, startY, spacing, width, height, index)
    local x = (centerWidth - width) / 2
    local y = startY + (index - 1) * spacing
    return x, y, width, height
end

function Menu:enter()
    self.titleFont = love.graphics.newFont(48)
    self.optionFont = love.graphics.newFont(24)
    self.instructionFont = love.graphics.newFont(16)

    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    self.titleY = windowHeight * 0.25
    self.optionStartY = windowHeight * 0.5
    self.characterStartY = windowHeight * 0.5

    self.optionWidth, self.optionHeight = computeOptionDimensions(self.optionFont, self.mainOptions)
    self.characterOptionWidth, self.characterOptionHeight = computeOptionDimensions(self.optionFont, self.characterOptions)
end

function Menu:getActiveOptions()
    if self.mode == 'character' then
        return self.characterOptions
    end
    return self.mainOptions
end

function Menu:getActiveSelection()
    if self.mode == 'character' then
        return self.characterSelected
    end
    return self.selectedOption
end

function Menu:setActiveSelection(index)
    local options = self:getActiveOptions()
    if #options == 0 then return end
    if self.mode == 'character' then
        self.characterSelected = ((index - 1) % #options) + 1
    else
        self.selectedOption = ((index - 1) % #options) + 1
    end
end

function Menu:getActiveLayout()
    if self.mode == 'character' then
        return self.characterOptionWidth, self.characterOptionHeight, self.characterStartY, self.characterSpacing
    else
        return self.optionWidth, self.optionHeight, self.optionStartY, self.optionSpacing
    end
end

function Menu:update(dt)
    local options = self:getActiveOptions()
    if #options == 0 then return end

    local mx, my = love.mouse.getPosition()
    local windowWidth = love.graphics.getWidth()
    local optionWidth, optionHeight, startY, spacing = self:getActiveLayout()

    for i = 1, #options do
        local x, y, width, height = optionBounds(windowWidth, startY, spacing, optionWidth, optionHeight, i)
        if mx >= x and mx <= x + width and my >= y and my <= y + height then
            self:setActiveSelection(i)
        end
    end
end

local function drawOptions(self, options, selectedIndex, title, startY, spacing, width, height)
    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()

    love.graphics.setColor(0.1, 0.1, 0.2, 1)
    love.graphics.rectangle('fill', 0, 0, windowWidth, windowHeight)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.titleFont)
    love.graphics.printf(title, 0, self.titleY, windowWidth, 'center')

    love.graphics.setFont(self.optionFont)
    for i, option in ipairs(options) do
        local x, y, w, h = optionBounds(windowWidth, startY, spacing, width, height, i)
        if i == selectedIndex then
            love.graphics.setColor(0.2, 0.4, 0.8, 0.8)
            love.graphics.rectangle('fill', x, y, w, h, 8, 8)
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
            love.graphics.rectangle('fill', x, y, w, h, 8, 8)
            love.graphics.setColor(0.85, 0.85, 0.85, 1)
        end
        love.graphics.printf(option.text or "", x, y + h / 2 - self.optionFont:getHeight() / 2, w, 'center')
    end

    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.setFont(self.instructionFont or love.graphics.newFont(16))
    if self.mode == 'character' then
        love.graphics.printf("Use arrow keys or mouse to choose. Enter to confirm, Esc to go back.", 0, windowHeight - 60, windowWidth, 'center')
    else
        love.graphics.printf("Use arrow keys or mouse to navigate. Enter to select.", 0, windowHeight - 60, windowWidth, 'center')
    end
end

function Menu:draw()
    local options = self:getActiveOptions()
    local selectedIndex = self:getActiveSelection()
    local width, height, startY, spacing = self:getActiveLayout()
    local title = self.mode == 'character' and self.characterTitle or self.title

    drawOptions(self, options, selectedIndex, title, startY, spacing, width, height)
end

function Menu:keypressed(key)
    local options = self:getActiveOptions()
    if #options == 0 then return end

    if key == 'up' then
        self:setActiveSelection(self:getActiveSelection() - 1)
    elseif key == 'down' then
        self:setActiveSelection(self:getActiveSelection() + 1)
    elseif key == 'return' or key == 'space' then
        self:selectOption()
    elseif key == 'escape' then
        if self.mode == 'character' then
            self.mode = 'main'
        else
            love.event.quit()
        end
    end
end

function Menu:selectOption()
    local options = self:getActiveOptions()
    local selectedIndex = self:getActiveSelection()
    local option = options[selectedIndex]
    if not option then return end

    if self.mode == 'character' then
        local characterId = option.characterId or 'student'
        local gameState = self.stateManager.states["game"]
        if gameState and gameState.prepareNewGame then
            gameState:prepareNewGame(characterId)
        elseif gameState and gameState.setSelectedCharacter then
            gameState:setSelectedCharacter(characterId)
        end
        self.stateManager:setState("game")
    else
        if option.action == "character_select" then
            self.mode = 'character'
            self.characterSelected = 1
        elseif option.action == "settings" then
            print("Settings not implemented yet")
        elseif option.action == "quit" then
            love.event.quit()
        end
    end
end

function Menu:mousepressed(x, y, button)
    if button ~= 1 then return end
    self:selectOption()
end

function Menu:exit()
    self.mode = 'main'
    self.selectedOption = 1
    self.characterSelected = 1
end

return Menu
