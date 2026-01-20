
local ClassroomManager = {}

function ClassroomManager:new(gameState)
    local obj = {
        gameState = gameState,
        isActive = false,
        timer = 0,
        stage = 0, -- 0: Intro, 1: Lecture, 2: Q&A, 3: Finish
        professorName = "Prof. Smith",
        currentSubject = "Computer Science",
        dialogueQueue = {}
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function ClassroomManager:startClass()
    self.isActive = true
    self.timer = 0
    self.stage = 0
    
    -- Determine Subject based on Day/Time (Simple random for now)
    local subjects = {"Algorithms", "Data Structures", "Operating Systems", "Physics"}
    self.currentSubject = subjects[math.random(#subjects)]
    
    print("Class Started: " .. self.currentSubject)
    
    -- Initial Dialogue
    self:queueDialogue("System", "You entered the classroom.")
    self:queueDialogue(self.professorName, "Welcome, class. Today we discuss " .. self.currentSubject .. ".")
end

function ClassroomManager:update(dt)
    if not self.isActive then return end
    
    -- Sync with StoryManager: Pause our logic if dialogue is active
    if self.gameState.storyManager and self.gameState.storyManager.dialogueActive then
        return
    end
    
    if self.stage == 0 then
        -- Intro Dialogue Finished (handled by startClass init)
        -- Wait a moment, then start lecture
        self.timer = self.timer + dt
        if self.timer > 1.0 then -- Short pause between speakers
            self.stage = 1
            self.timer = 0
            self:queueDialogue(self.professorName, "Today's topic is: " .. self.currentSubject .. ".")
            self:queueDialogue(self.professorName, "Please open your textbooks to page 394.")
        end
        
    elseif self.stage == 1 then
        -- Lecture Finished
        self.timer = self.timer + dt
        if self.timer > 1.0 then 
            self.stage = 2
            self.timer = 0
             -- Mini-Quiz Placeholder
            self:queueDialogue(self.professorName, "Who can tell me the Big O complexity of QuickSort?")
            self:queueDialogue("Classmates", "...")
            self:queueDialogue(self.professorName, "Anyone? ... Fine. It's O(n log n) on average.")
        end
        
    elseif self.stage == 2 then
        -- Quiz Logic
        if not self.quizActive then
             self.quizActive = true
             self.quizOption = 1
             self.quizQuestion = {
                 text = "What is the Time Complexity of Binary Search?",
                 options = {"O(n)", "O(log n)", "O(n^2)"},
                 correct = 2
             }
             print("Quiz Started: " .. self.quizQuestion.text)
        end
        -- Input handled in keypressed
    elseif self.stage == 3 then
         self:finishClass()
    end
end

function ClassroomManager:keypressed(key)
    if not self.isActive then return end
    
    if self.stage == 2 and self.quizActive then
        if key == '1' or key == '2' or key == '3' then
            local choice = tonumber(key)
            if choice == self.quizQuestion.correct then
                self:queueDialogue(self.professorName, "Correct! Excellent work.")
                if self.gameState.careerManager then
                    self.gameState.careerManager:gainKnowledge(10) -- Bonus
                end
            else
                self:queueDialogue(self.professorName, "Incorrect. It is O(log n).")
            end
            self.stage = 3
            self.quizActive = false
        end
    end
end

function ClassroomManager:queueDialogue(sender, text)
    -- Hook into StoryManager if possible, else HUD
    if self.gameState.storyManager then
        self.gameState.storyManager:queueDialogue(sender, text)
    elseif self.gameState.hud then
        self.gameState.hud:addNotification(sender .. ": " .. text)
    end
end

function ClassroomManager:finishClass()
    self.isActive = false
    self:queueDialogue(self.professorName, "Class dismissed. Don't forget your assignments.")
    
    -- Apply Rewards
    if self.gameState.careerManager then
        self.gameState.careerManager:gainKnowledge(15)
        self.gameState.careerManager:modifyEnergy(-15)
        self.gameState.careerManager:modifyStress(5)
        
        -- Set Cooldown (e.g., 60 minutes)
        if self.gameState.timeSystem then
             self.gameState.careerManager.lastClassTime = self.gameState.timeSystem:getAbsoluteTime()
        end
    end
    
    -- Advance Time
    if self.gameState.timeSystem then
        self.gameState.timeSystem:addMinutes(60)
    end
end

function ClassroomManager:draw()
    if not self.isActive then return end
    
    -- Draw Overlay to show "IN CLASS"
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("CLASS IN SESSION: " .. self.currentSubject, 50, 50)
    
    -- Draw Quiz if active
    if self.stage == 2 and self.quizActive then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 200, 200, 400, 300)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Pop Quiz!", 200, 220, 400, "center")
        love.graphics.printf(self.quizQuestion.text, 220, 260, 360, "left")
        
        for i, opt in ipairs(self.quizQuestion.options) do
             love.graphics.print(i .. ". " .. opt, 240, 300 + (i*40))
        end
        love.graphics.printf("Press 1, 2, or 3", 200, 450, 400, "center")
    end
end

return ClassroomManager
