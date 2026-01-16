local MessageManager = {}

function MessageManager:new(config)
    local obj = {}
    
    -- List of messages { sender = "Name", text = "Content", read = false, time = "08:00" }
    obj.messages = {}
    obj.unreadCount = 0
    obj.onNotify = config and config.onNotify
    
    setmetatable(obj, self)
    self.__index = self
    
    -- Add initial welcome message
    obj:receiveMessage("Mom", "Good luck at college! Don't forget to eat and sleep! Love you.", "08:00")
    
    return obj
end

function MessageManager:receiveMessage(sender, text, timeString)
    table.insert(self.messages, 1, {
        sender = sender,
        text = text,
        read = false,
        time = timeString or "00:00"
    })
    self.unreadCount = self.unreadCount + 1
    
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
