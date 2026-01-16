local StatusMenu = {}

function StatusMenu:new(game)
    local obj = {
        gameState = game,
        isOpen = false,
        activeTab = 'stats' -- stats, inventory, quest (future expansion)
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function StatusMenu:toggle()
    self.isOpen = not self.isOpen
end

function StatusMenu:draw()
    if not self.isOpen then return end
    
    local w, h = love.graphics.getDimensions()
    local career = self.gameState.careerManager
    
    if not career then return end
    
    -- 1. Dark Overlay (Elden Ring Vibe)
    love.graphics.setColor(0.05, 0.05, 0.05, 0.95)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- 2. Header Line (Golden)
    love.graphics.setColor(0.7, 0.6, 0.3, 1)
    love.graphics.rectangle("fill", 50, 80, w - 100, 2)
    
    -- 3. Title
    love.graphics.setFont(love.graphics.newFont(36))
    love.graphics.printf("STATUS", 0, 30, w, "center")
    
    -- 4. Left Column: Character Info
    local leftX = 100
    local topY = 120
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print(career.jobTitle, leftX, topY)
    
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Rank: " .. career:getRank(), leftX, topY + 30)
    
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Rank: " .. career:getRank(), leftX, topY + 30)
    
    -- Removed Avatar Placeholder as requested
    
    -- 5. Middle Column: Main Stats
    local midX = 400
    
    self:drawStatRow("Level", "1", midX, topY) -- Placeholder Lvl
    self:drawStatRow("Knowledge", career.knowledge, midX, topY + 40)
    
    love.graphics.rectangle("fill", midX, topY + 90, 200, 1) -- Separator
    
    self:drawStatRow("Energy", math.floor(career.energy) .. " / " .. career.maxEnergy, midX, topY + 110)
    self:drawStatRow("Stress", math.floor(career.stress) .. " / " .. career.maxStress, midX, topY + 150)
    self:drawStatRow("Energy", math.floor(career.energy) .. " / " .. career.maxEnergy, midX, topY + 110)
    self:drawStatRow("Stress", math.floor(career.stress) .. " / " .. career.maxStress, midX, topY + 150)
    -- Money is handled in Phone/HUD
    
    -- 6. Right Column: Attributes
    local rightX = 700
    
    love.graphics.setColor(0.7, 0.6, 0.3, 1)
    love.graphics.print("Attributes", rightX, topY)
    
    love.graphics.setColor(1, 1, 1, 1)
    local attrY = topY + 40
    self:drawStatRow("Integrity", career.integrity, rightX, attrY)
    self:drawStatRow("Innovation", career.innovation, rightX, attrY + 40)
    self:drawStatRow("Reputation", career.reputation, rightX, attrY + 80)
    
    -- 7. Footer controls
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.printf("[TAB] Close", 0, h - 50, w, "center")
end

function StatusMenu:drawStatRow(label, value, x, y)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(label, x, y)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(tostring(value), x + 150, y, 100, "right")
end

function StatusMenu:keypressed(key)
    if key == 'tab' or key == 'escape' then
        self:toggle()
        return true
    end
    return false
end

return StatusMenu
