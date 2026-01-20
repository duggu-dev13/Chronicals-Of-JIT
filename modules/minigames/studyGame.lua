local StudyGame = {}

function StudyGame:new(callbacks)
    local obj = {}
    obj.callbacks = callbacks or {} -- onComplete, onFail
    obj.isActive = false
    obj.score = 0
    obj.timeLeft = 0
    obj.totalTime = 10
    obj.targetKey = nil
    obj.keyTimer = 0
    obj.keys = {'a', 's', 'd', 'w', 'e', 'space'}
    
    obj.fontLarge = love.graphics.newFont(40)
    obj.fontSmall = love.graphics.newFont(20)
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function StudyGame:start(difficulty)
    self.isActive = true
    self.score = 0
    self.timeLeft = 15 -- 15 seconds to study
    self.difficulty = difficulty or 1.0
    self:nextKey()
end

function StudyGame:nextKey()
    self.targetKey = self.keys[love.math.random(#self.keys)]
    -- Difficulty scales the time available (Lower difficulty = more time)
    self.keyBaseTime = 2.0 / self.difficulty
    self.keyTimer = self.keyBaseTime
end

function StudyGame:update(dt)
    if not self.isActive then return end
    
    self.timeLeft = self.timeLeft - dt
    self.keyTimer = self.keyTimer - dt
    
    if self.timeLeft <= 0 then
        self:finish(true)
        return
    end
    
    if self.keyTimer <= 0 then
        -- Missed the key!
        self.score = math.max(0, self.score - 5)
        self:nextKey()
    end
end

function StudyGame:draw()
    if not self.isActive then return end
    
    local w, h = love.graphics.getDimensions()
    
    -- Reset any camera/color state just in case
    love.graphics.origin()
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Overlay
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle('fill', 0, 0, w, h)
    
    -- Game Box
    love.graphics.setColor(0.2, 0.3, 0.4, 1)
    love.graphics.rectangle('fill', w/2 - 200, h/2 - 150, 400, 300, 10, 10)
    
    -- Text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.fontLarge)
    love.graphics.printf("STUDYING...", 0, h/2 - 120, w, 'center')
    
    love.graphics.setFont(self.fontSmall)
    love.graphics.printf("Time: " .. math.ceil(self.timeLeft), 0, h/2 - 80, w, 'center')
    love.graphics.printf("Score: " .. self.score, 0, h/2 + 100, w, 'center')
    
    -- Narrative AI Feedback
    love.graphics.setColor(1, 1, 1, 0.6)
    local diffText = self.difficulty < 1 and "Easy (Practiced)" or (self.difficulty > 1 and "Hard (Unpracticed)" or "Normal")
    love.graphics.printf("Difficulty: " .. diffText, 0, h/2 + 125, w, 'center')
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Target Key Prompt
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(1, 1, 0, 1)
    local keyText = self.targetKey and string.upper(self.targetKey) or "..."
    love.graphics.printf("PRESS: " .. keyText, 0, h/2, w, 'center')
    
    -- Bar for Key Timer
    local mw = 200
    local pct = math.max(0, self.keyTimer / (self.keyBaseTime or 2.0))
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle('fill', w/2 - mw/2, h/2 + 50, mw * pct, 10)
    
    love.graphics.setColor(1, 1, 1, 1)
end

function StudyGame:keypressed(key)
    if not self.isActive then return end
    
    if key == self.targetKey then
        self.score = self.score + 10
        self:nextKey()
    else
        self.score = math.max(0, self.score - 5)
        -- Don't change key on error, usually penalty is enough
    end
end

function StudyGame:finish(completed)
    self.isActive = false
    if self.callbacks.onComplete then
        self.callbacks.onComplete(self.score)
    end
end

return StudyGame
