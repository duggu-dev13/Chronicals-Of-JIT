local StateManager = require 'modules/stateManager'
local Menu = require 'modules/menu'
local GameState = require 'modules/gameState'
local InputManager = require 'modules/inputManager'
            
local stateManager

function love.load()
    -- Window setup
    local width, height = love.window.getDesktopDimensions(1)
    love.window.setMode(math.floor(width * 0.9), math.floor(height * 0.9), { resizable = true, fullscreen = false })
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Initialize state manager
    stateManager = StateManager:new()
    InputManager:init()
    
    -- Add states
    stateManager:addState("menu", Menu:new(stateManager))
    stateManager:addState("game", GameState:new(stateManager))
    
    -- Start with menu
    stateManager:setState("menu")
end

function love.update(dt)
    stateManager:update(dt)
end

function love.draw()
    stateManager:draw()
end

-- ===================== INPUT =====================
function love.keypressed(key)
    local action = InputManager:isPressed(key)
    if action == 'interact' then print("[Main] 'E' Pressed. Action: " .. tostring(action)) end
    stateManager:keypressed(key, action)
end

function love.keyreleased(key)
    stateManager:keyreleased(key)
end

function love.mousemoved(x, y, dx, dy)
    stateManager:mousemoved(x, y, dx, dy)
end

function love.textinput(t)
    stateManager:textinput(t)
end

function love.mousepressed(x, y, button)
    stateManager:mousepressed(x, y, button)
end
