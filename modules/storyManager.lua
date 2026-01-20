local StoryManager = {}

function StoryManager:new(gameState)
    local obj = {
        gameState = gameState,
        isActive = false,
        currentCutscene = nil,
        dialogueQueue = {},
        dialogueActive = false,
        storyFlags = {
            prologue_started = false,
            admission_done = false,
            parents_talk_done = false,
            app_installed = false
        },
        
        -- UI
        fontName = love.graphics.newFont(24),
        fontText = love.graphics.newFont(18),
        timer = 0
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function StoryManager:startPrologue()
    print("Starting Prologue...")
    self.storyFlags.prologue_started = true
    
    -- Check Role
    local role = "student"
    if self.gameState.careerManager and self.gameState.careerManager.path then
        role = self.gameState.careerManager.path
    elseif self.gameState.selectedCharacter then
        role = self.gameState.selectedCharacter
    end
    
    if role == "professor" then
        -- Professor (Max) Path
        self:queueDialogue("Narrator", "Max is an alumni of JIT (Batch 2002).")
        self:queueDialogue("Narrator", "After losing $10 Million in his AI Startup, he returns home.")
        self:queueDialogue("Max", "Back to square one. Bankrupt... but not beaten.")
        self:queueDialogue("Dad", "Son, JIT is hiring Lab Assistants. It's a fresh start.")
        self:queueDialogue("Max", "I guess you're right, Dad. Let's see if the old college still stands.")
        self:queueDialogue("System", "Objective: Go to the HOD Office (Coming Soon).")
    else
        -- Student (Alex) Path
        -- Sequence 1: Arrival at Gate with Parents
        self:queueDialogue("Dad", "Well, here we are at JIT. Big day, son.")
        self:queueDialogue("Mom", "Make us proud, Alex. Study hard!")
        self:queueDialogue("Alex", "I will. Thanks for everything.")
        self:queueDialogue("System", "Objective: Go to the Admission Section.")
        
        -- Trigger Quest Logic if needed
        if self.gameState.questManager then
            -- Fix: Use startQuest, not addQuest
            self.gameState.questManager:startQuest("Admission", "Admission Process", "Go to the Admission Block and fill the form.")
        end
    end
end

function StoryManager:queueDialogue(speaker, text)
    table.insert(self.dialogueQueue, { speaker = speaker, text = text })
    self.dialogueActive = true
end

function StoryManager:update(dt)
    if not self.dialogueActive then return end
    
    -- Simple input wait logic is handled in keypressed
end

function StoryManager:draw()
    if not self.dialogueActive then return end
    if #self.dialogueQueue == 0 then return end
    
    local w, h = love.graphics.getDimensions()
    local current = self.dialogueQueue[1]
    
    -- Dialogue Box
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 50, h - 200, w - 100, 180, 10, 10)
    
    -- Border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", 50, h - 200, w - 100, 180, 10, 10)
    
    -- Name
    love.graphics.setColor(1, 1, 0, 1) -- Yellow for name
    love.graphics.setFont(self.fontName)
    love.graphics.print(current.speaker, 70, h - 180)
    
    -- Text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.fontText)
    love.graphics.printf(current.text, 70, h - 140, w - 140, "left")
    
    -- Prompt
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.print("[SPACE] Next", w - 200, h - 40)
end

function StoryManager:keypressed(key)
    if not self.dialogueActive then return false end
    
    if key == 'space' or key == 'return' then
        table.remove(self.dialogueQueue, 1)
        if #self.dialogueQueue == 0 then
            self.dialogueActive = false
            self:onDialogueFinished()
        end
        return true -- Consume Input
    end
    return false
end

function StoryManager:onDialogueFinished()
    print("Dialogue Sequence Finished")
    -- Check flags to trigger next events
    if not self.storyFlags.parents_talk_done then
        self.storyFlags.parents_talk_done = true
        -- Trigger Welcome Message
        if self.gameState.messageManager then
            self.gameState.messageManager:sendWelcomeMessage()
        end
    end
end

function StoryManager:triggerEvent(eventName)
    if eventName == "install_app" then
        if self.storyFlags.app_installed then
            self:queueDialogue("System", "Apps already installed.")
        else
            self.storyFlags.app_installed = true
            self:queueDialogue("System", "Scanning QR Code...")
            self:queueDialogue("System", "Downloading 'XYZ Student App'...")
            self:queueDialogue("System", "Installation Complete! Phone Unlocked.")
            self:queueDialogue("System", "New Apps: M-Bank, Jobs, Social, ToDo.")
            
            -- Unlock Apps
            if self.gameState.phone then
                self.gameState.phone:installApp('all')
            end
        end
    end
end

return StoryManager
