local MessageManager = {}

function MessageManager:new(config)
    local obj = {}
    
    -- List of messages { sender = "Name", text = "Content", read = false, time = "08:00" }
    obj.messages = {}
    obj.unreadCount = 0
    obj.onNotify = config and config.onNotify
    
    setmetatable(obj, self)
    self.__index = self
    
    -- Initial Messages not sent immediately anymore
    -- obj:receiveMessage("JIT-Alert", "Welcome to JIT. Check Notice Board for App Unlocks.", "09:00")
    
    return obj
end

function MessageManager:sendWelcomeMessage()
    self:receiveMessage("JIT-Alert", "Welcome to JIT. Check Notice Board for App Unlocks.", "09:00")
end

function MessageManager:receiveMessage(sender, text, timeString)
    table.insert(self.messages, 1, {
        sender = sender,
        text = text,
        read = false,
        time = timeString or "00:00"
    })
    self.unreadCount = self.unreadCount + 1
    
    -- Play notification sound here
    print("New Message from " .. sender .. ": " .. text)
    if self.onNotify then self.onNotify("New Message from " .. sender) end
end

function MessageManager:markAllRead()
    for _, msg in ipairs(self.messages) do
        msg.read = true
    end
    self.unreadCount = 0
end

return MessageManager
