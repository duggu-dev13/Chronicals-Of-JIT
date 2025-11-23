local ResourceManager = {}

ResourceManager.images = {}
ResourceManager.sounds = {}

function ResourceManager.getImage(path)
    if not ResourceManager.images[path] then
        local success, image = pcall(love.graphics.newImage, path)
        if success then
            ResourceManager.images[path] = image
        else
            print("Error loading image: " .. path)
            return nil
        end
    end
    return ResourceManager.images[path]
end

function ResourceManager.getSound(path, type)
    local key = path .. (type or "static")
    if not ResourceManager.sounds[key] then
        local success, sound = pcall(love.audio.newSource, path, type or "static")
        if success then
            ResourceManager.sounds[key] = sound
        else
            print("Error loading sound: " .. path)
            return nil
        end
    end
    return ResourceManager.sounds[key]
end

function ResourceManager.clear()
    ResourceManager.images = {}
    ResourceManager.sounds = {}
end

return ResourceManager
