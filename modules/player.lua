local anim8 = require 'libraries/anim8'
local CharacterConfigs = require 'data/characters'
local InputManager = require 'modules/inputManager'
local ResourceManager = require 'modules/resourceManager'

local Player = {}

Player.characterConfigs = CharacterConfigs

local function copySpawn(spawn)
    if not spawn then return nil end
    return { x = spawn.x, y = spawn.y }
end

function Player.getCharacterConfig(characterId)
    return Player.characterConfigs[characterId] or Player.characterConfigs.student
end

function Player:new(world, spawn, characterId)
    local obj = {}

    obj.characterId = characterId or 'student'
    obj.config = Player.getCharacterConfig(obj.characterId)

    -- Player setup
    local spawnPos = copySpawn(spawn) or { x = 200, y = 100 }
    obj.x, obj.y = spawnPos.x, spawnPos.y
    obj.walkingSpeed = obj.config.walkingSpeed or 60
    obj.animSpeed = obj.config.animSpeed or 0.12

    obj.frameWidth = obj.config.frameWidth or 64
    obj.frameHeight = obj.config.frameHeight or 64
    
    -- Anchor at bottom-center for better depth sorting and positioning
    obj.originX = obj.frameWidth / 2
    obj.originY = obj.frameHeight 
    
    obj.scaleFactor = obj.config.scaleFactor or 0.75
    obj.groundOffset = obj.config.groundOffset or 0

    obj.spriteSheet = ResourceManager.getImage(obj.config.sheet)
    print("DEBUG: Loaded SpriteSheet: " .. obj.config.sheet)
    print("DEBUG: Dimensions: " .. obj.spriteSheet:getWidth() .. "x" .. obj.spriteSheet:getHeight())
    
    -- Sound setup
    obj.sounds = {}
    local footstepPath = obj.config.footstepSound or 'sounds/female_footsteps.mp3'
    obj.sounds.footstep = ResourceManager.getSound(footstepPath, 'stream')

    -- Collider
    obj.collider = world:newBSGRectangleCollider(obj.x, obj.y, 20, 14, 4)
    obj.collider:setFixedRotation(true)

    -- Animations
    local grid = anim8.newGrid(obj.frameWidth, obj.frameHeight, obj.spriteSheet:getWidth(), obj.spriteSheet:getHeight())
    local framesPerRow = math.max(1, math.floor(obj.spriteSheet:getWidth() / obj.frameWidth))
    local rows = obj.config.rows or { right = 1, left = 2, down = 3, up = 4 }
    obj.animations = {
        down  = anim8.newAnimation(grid('1-' .. framesPerRow, rows.down or 3), obj.animSpeed),
        up    = anim8.newAnimation(grid('1-' .. framesPerRow, rows.up or 4), obj.animSpeed),
        left  = anim8.newAnimation(grid('1-' .. framesPerRow, rows.left or 2), obj.animSpeed),
        right = anim8.newAnimation(grid('1-' .. framesPerRow, rows.right or 1), obj.animSpeed)
    }
    obj.anim = obj.animations.down

    setmetatable(obj, self)
    self.__index = self
    obj:updatePositionFromCollider()
    return obj
end

function Player:updatePositionFromCollider()
    if not self.collider then return end
    self.x = self.collider:getX()
    -- Set player Y to the bottom of the collider (feet position)
    -- Windfield getPosition returns center, so add half height (7 is approx half of 14)
    self.y = self.collider:getY() + 7 
end

function Player:update(dt)
    local vx, vy, isMoving = 0, 0, false

    local speed = self.walkingSpeed
    local speedMult = 1
    if InputManager:isDown('sprint') then
        speedMult = 3
    end
    speed = speed * speedMult

    if InputManager:isDown('up') then
        vy = -speed
        self.anim = self.animations.up
        isMoving = true
    end
    if InputManager:isDown('down') then
        vy = speed
        self.anim = self.animations.down
        isMoving = true
    end
    if InputManager:isDown('right') then
        vx = speed
        self.anim = self.animations.right
        isMoving = true
    end
    if InputManager:isDown('left') then
        vx = -speed
        self.anim = self.animations.left
        isMoving = true
    end
    
    if isMoving then
        -- Speed up animation if sprinting
        if speedMult > 1 then 
            self.anim:resume() -- Ensure it's playing
            -- We can't easily change anim speed on the fly with anim8 without hacking it or recreating, 
            -- but commonly we just let it run. or update with dt * speedMult?
            -- Anim8 update takes dt. We can pass scaled dt.
        end
    end

    if self.collider then
        self.collider:setLinearVelocity(vx, vy)
    end

    if not isMoving then
        self.anim:gotoFrame(1)
        if self.sounds.footstep:isPlaying() then
            self.sounds.footstep:stop()
        end
    else
        if not self.sounds.footstep:isPlaying() then
            self.sounds.footstep:play()
        end
    end

    self:updatePositionFromCollider()
    self:updatePositionFromCollider()
    
    -- Update animation faster if sprinting
    local updateDt = dt
    if InputManager:isDown('sprint') and isMoving then
        updateDt = dt * 2 -- Make feet move faster
    end
    self.anim:update(updateDt)
end

function Player:setPosition(x, y)
    if not self.collider then return end
    self.collider:setPosition(x, y)
    self:updatePositionFromCollider()
end

function Player:getDrawScale(extraScale)
    -- Ignore Camera Scale. World Units Only.
    return self.scaleFactor * (extraScale or 1)
end

function Player:getBottomY()
    return self.y -- Since y is now the feet position
end

function Player:draw(extraScale)
    local drawScale = self:getDrawScale(extraScale)
    self.anim:draw(
        self.spriteSheet,
        self.x, self.y,
        nil,
        drawScale, drawScale,
        self.originX, self.originY
    )
end

return Player