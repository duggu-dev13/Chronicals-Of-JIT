local anim8 = require 'libraries/anim8'

local Player = {}

Player.characterConfigs = {
    student = {
        sheet = 'sprites/Player/Student_1_Walk_Full_Compose-Sheet_SpriteSheet.png',
        frameWidth = 64,
        frameHeight = 64,
        rows = { right = 1, left = 2, down = 3, up = 4 },
        animSpeed = 0.1,
        scaleFactor = 2 / 6,
        footstepSound = 'sounds/female_footsteps.mp3'
    },
    teacher = {
        sheet = 'sprites/Player/professor_1_Walk_Full_Compose-Sheet_SpriteSheet.png',
        frameWidth = 64,
        frameHeight = 64,
        rows = { right = 1, left = 2, down = 3, up = 4 },
        animSpeed = 0.1,
        scaleFactor = 1 / 6,
        footstepSound = 'sounds/female_footsteps.mp3'
    }
}

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
    obj.walkingSpeed = (obj.config.walkingSpeed or 60) * 2
    obj.animSpeed = obj.config.animSpeed or 0.12

    obj.frameWidth = obj.config.frameWidth or 64
    obj.frameHeight = obj.config.frameHeight or 64
    obj.originX = obj.frameWidth / 2
    obj.originY = obj.frameHeight / 2
    obj.scaleFactor = obj.config.scaleFactor or (1 / 6)
    obj.groundOffset = obj.config.groundOffset or 10

    obj.spriteSheet = love.graphics.newImage(obj.config.sheet)
    
    -- Sound setup
    obj.sounds = {}
    local footstepPath = obj.config.footstepSound or 'sounds/female_footsteps.mp3'
    obj.sounds.footstep = love.audio.newSource(footstepPath, 'stream')

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
    self.y = self.collider:getY() - (self.frameHeight / 2) + self.groundOffset
end

function Player:update(dt)
    local vx, vy, isMoving = 0, 0, false

    if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
        vy = -self.walkingSpeed
        self.anim = self.animations.up
        isMoving = true
    end
    if love.keyboard.isDown('s') or love.keyboard.isDown('down') then
        vy = self.walkingSpeed
        self.anim = self.animations.down
        isMoving = true
    end
    if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        vx = self.walkingSpeed
        self.anim = self.animations.right
        isMoving = true
    end
    if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        vx = -self.walkingSpeed
        self.anim = self.animations.left
        isMoving = true
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
    self.anim:update(dt)
end

function Player:setPosition(x, y)
    if not self.collider then return end
    self.collider:setPosition(x, y)
    self:updatePositionFromCollider()
end

function Player:getDrawScale(cameraScale, extraScale)
    return (cameraScale or 1) * self.scaleFactor * (extraScale or 1)
end

function Player:getBottomY()
    return (self.y or 0) + self.frameHeight - self.groundOffset
end

function Player:draw(cameraScale, extraScale)
    local drawScale = self:getDrawScale(cameraScale, extraScale)
    self.anim:draw(
        self.spriteSheet,
        self.x, self.y,
        nil,
        drawScale, drawScale,
        self.originX, self.originY
    )
end

return Player