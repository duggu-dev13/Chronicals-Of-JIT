local Questions = require 'data/examQuestions'

local ExamGame = {}

function ExamGame:new(callbacks)
    local obj = {}
    obj.callbacks = callbacks or {} -- onComplete(score)
    obj.isActive = false
    obj.currentQuestionIndex = 1
    obj.examPaper = {} -- Generated List of Questions
    obj.selectedOption = 1
    obj.score = 0
    obj.timeLeft = 0
    
    obj.fontHeader = love.graphics.newFont(30)
    obj.fontText = love.graphics.newFont(20)
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function ExamGame:generatePaper(proficiency, department)
    -- PCG Logic:
    -- Filter Questions by Department (and Common)
    local targetDept = department or "CS" -- Default to CS
    
    self.examPaper = {}
    local paperSize = 3
    
    -- Create Pool
    local pool = {}
    for _, q in ipairs(Questions) do
        if q.department == "Common" or q.department == targetDept then
            table.insert(pool, q)
        end
    end
    
    -- Fallback if pool is empty (shouldn't happen)
    if #pool == 0 then
        table.insert(pool, { text = "Error: No Questions Found", options = {"A", "B"}, correct = 1 })
    end
    
    for i=1, paperSize do
        if #pool == 0 then break end
        local idx = love.math.random(#pool)
        table.insert(self.examPaper, pool[idx])
        table.remove(pool, idx)
    end
    
    -- Difficulty Scaling: Time Limit
    -- Base: 10s per question.
    -- High Prof: 15s per question.
    -- Low Prof: 5s per question.
    local timePerQ = 10
    if proficiency > 0.7 then timePerQ = 15
    elseif proficiency < 0.3 then timePerQ = 7 end
    
    self.timeLeft = paperSize * timePerQ
end

function ExamGame:start(proficiency, department)
    self.isActive = true
    self.score = 0
    self.currentQuestionIndex = 1
    self.selectedOption = 1
    self:generatePaper(proficiency or 0.5, department)
end

function ExamGame:update(dt)
    if not self.isActive then return end
    
    self.timeLeft = self.timeLeft - dt
    if self.timeLeft <= 0 then
        self:finish()
    end
end

function ExamGame:draw()
    if not self.isActive then return end
    
    local w, h = love.graphics.getDimensions()
    
    love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
    love.graphics.rectangle('fill', 0, 0, w, h)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.fontHeader)
    love.graphics.printf("SEMESTER EXAM", 0, 50, w, 'center')
    
    love.graphics.setFont(self.fontText)
    love.graphics.print("Time Left: " .. math.ceil(self.timeLeft), 50, 50)
    
    if #self.examPaper == 0 then return end
    
    local q = self.examPaper[self.currentQuestionIndex]
    love.graphics.printf("Q" .. self.currentQuestionIndex .. ": " .. q.text, 100, 150, w - 200, 'center')
    
    local oy = 250
    for i, opt in ipairs(q.options) do
        if i == self.selectedOption then
            love.graphics.setColor(1, 1, 0, 1)
            love.graphics.print("> " .. opt, w/2 - 100, oy)
        else
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print("  " .. opt, w/2 - 100, oy)
        end
        oy = oy + 40
    end
    
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.printf("[W/S] Navigate   [SPACE] Confirm", 0, h - 50, w, 'center')
end

function ExamGame:keypressed(key)
    if not self.isActive then return end
    
    if key == 'w' or key == 'up' then
        self.selectedOption = self.selectedOption - 1
        if self.selectedOption < 1 then self.selectedOption = 4 end -- Hardcoded 4 options logic
    elseif key == 's' or key == 'down' then
        self.selectedOption = self.selectedOption + 1
        if self.selectedOption > 4 then self.selectedOption = 1 end
    elseif key == 'space' or key == 'return' then
        self:answer(self.selectedOption)
    end
end

function ExamGame:answer(choice)
    local q = self.examPaper[self.currentQuestionIndex]
    if choice == q.correct then
        self.score = self.score + 10
    end
    
    self.currentQuestionIndex = self.currentQuestionIndex + 1
    if self.currentQuestionIndex > #self.examPaper then
        self:finish()
    else
        self.selectedOption = 1
    end
end

function ExamGame:finish()
    self.isActive = false
    if self.callbacks.onComplete then
        self.callbacks.onComplete(self.score)
    end
end

return ExamGame
