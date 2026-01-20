-- stateManager.lua
-- Simple state management system for the game

local StateManager = {}

function StateManager:new()
    local obj = {}
    obj.currentState = nil
    obj.states = {}
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function StateManager:addState(name, state)
    self.states[name] = state
end

function StateManager:setState(name)
    if self.currentState and self.currentState.exit then
        self.currentState:exit()
    end
    
    self.currentState = self.states[name]
    
    if self.currentState and self.currentState.enter then
        self.currentState:enter()
    end
end

function StateManager:update(dt)
    if self.currentState and self.currentState.update then
        self.currentState:update(dt)
    end
end

function StateManager:draw()
    if self.currentState and self.currentState.draw then
        self.currentState:draw()
    end
end

function StateManager:keypressed(key, action)
    if self.currentState and self.currentState.keypressed then
        self.currentState:keypressed(key, action)
    end
end

function StateManager:keyreleased(key, action)
    if self.currentState and self.currentState.keyreleased then
        self.currentState:keyreleased(key, action)
    end
end

function StateManager:mousemoved(x, y, dx, dy)
    if self.currentState and self.currentState.mousemoved then
        self.currentState:mousemoved(x, y, dx, dy)
    end
end

function StateManager:mousepressed(x, y, button)
    if self.currentState and self.currentState.mousepressed then
        self.currentState:mousepressed(x, y, button)
    end
end

function StateManager:textinput(t)
    if self.currentState and self.currentState.textinput then
        self.currentState:textinput(t)
    end
end

return StateManager
