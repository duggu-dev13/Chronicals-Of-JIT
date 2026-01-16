local QuestManager = {}

function QuestManager:new(config)
    local obj = {}
    
    -- Structure: { id = "quest_id", title = "Title", desc = "Description", status = "active/completed", objectives = {} }
    obj.quests = {}
    obj.onNotify = config and config.onNotify
    
    setmetatable(obj, self)
    self.__index = self
    
    -- Initialize with Tutorial Quest
    obj:startQuest("tutorial_01", "First Day", "Welcome to college! Get settled in.")
    obj:addObjective("tutorial_01", "Leave the Hostel")
    obj:addObjective("tutorial_01", "Go to College Campus")
    
    return obj
end

function QuestManager:startQuest(id, title, desc)
    if self.quests[id] then return end -- Already exists
    
    self.quests[id] = {
        id = id,
        title = title,
        desc = desc,
        status = "active",
        objectives = {}
    }

    print("Quest Started: " .. title)
    if self.onNotify then self.onNotify("New Quest: " .. title) end
end

function QuestManager:addObjective(questId, description)
    local quest = self.quests[questId]
    if quest then
        table.insert(quest.objectives, {
            desc = description,
            completed = false
        })
    end
end

function QuestManager:completeObjective(questId, index)
    local quest = self.quests[questId]
    if quest and quest.objectives[index] then
        if not quest.objectives[index].completed then
            quest.objectives[index].completed = true
            print("Objective Completed: " .. quest.objectives[index].desc)
            self:checkQuestCompletion(questId)
        end
    end
end

function QuestManager:checkQuestCompletion(questId)
    local quest = self.quests[questId]
    if not quest then return end
    
    local allComplete = true
    for _, obj in ipairs(quest.objectives) do
        if not obj.completed then
            allComplete = false
            break
        end
    end
    

    if allComplete then
        quest.status = "completed"
        print("Quest Completed: " .. quest.title)
        if self.onNotify then self.onNotify("Quest Completed: " .. quest.title) end
        -- Trigger rewards here if needed
    end
end

return QuestManager
