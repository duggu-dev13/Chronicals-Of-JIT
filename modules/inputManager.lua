local InputManager = {}

InputManager.keys = {}
InputManager.bindings = {
    up = { 'w', 'up' },
    down = { 's', 'down' },
    left = { 'a', 'left' },
    right = { 'd', 'right' },
    interact = { 'e' },
    menu = { 'escape' },
    phone = { 'p' },
    status = { 'tab' },
    sprint = { 'lshift', 'rshift' },
    -- test_travel_hostel = { 'f5' },
    -- test_travel_college = { 'f6' },
    confirm = { 'return', 'space' },
    debug = { 'f1' }
}

function InputManager:init()
    -- Initialize key states
end

function InputManager:update()
    -- Update key states if needed (e.g. for "just pressed" logic)
    -- For now, love.keyboard.isDown is sufficient for continuous input
end

function InputManager:isDown(action)
    local keys = self.bindings[action]
    if not keys then return false end
    
    for _, key in ipairs(keys) do
        if love.keyboard.isDown(key) then
            return true
        end
    end
    return false
end

function InputManager:isPressed(key)
    -- This is a helper to map raw keys to actions for keypressed events
    for action, keys in pairs(self.bindings) do
        for _, k in ipairs(keys) do
            if k == key then
                return action
            end
        end
    end
    return nil
end

return InputManager
