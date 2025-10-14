local StateManager = require 'modules/stateManager'
local Menu = require 'modules/menu'
local GameState = require 'modules/gameState'

local stateManager

function love.load()
    -- Window setup
    local width, height = love.window.getDesktopDimensions(1)
    love.window.setMode(math.floor(width * 0.9), math.floor(height * 0.9), { resizable = true, fullscreen = false })
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Initialize state manager
    stateManager = StateManager:new()
    
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
    stateManager:keypressed(key)
end

function love.keyreleased(key)
    stateManager:keyreleased(key)
end

function love.mousemoved(x, y, dx, dy)
    stateManager:mousemoved(x, y, dx, dy)
end

function love.mousepressed(x, y, button)
    stateManager:mousepressed(x, y, button)
end
