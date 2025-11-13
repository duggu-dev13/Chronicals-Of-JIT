-- player.lua
local anim8 = require 'libraries/anim8'

local Player = {}

local function copySpawn(spawn)
    if not spawn then return nil end
    return { x = spawn.x, y = spawn.y }
end

function Player:new(world, spawn)
    local obj = {}

    -- Player setup
    local spawnPos = copySpawn(spawn) or { x = 200, y = 100 }
    obj.x, obj.y = spawnPos.x, spawnPos.y
    obj.walkingSpeed = 50
    obj.animSpeed = 0.08
    obj.spriteSheet = love.graphics.newImage("sprites/Teacher_1_walk-Sheet.png")
    
    -- Sound setup
    obj.sounds = {}
    obj.sounds.footstep = love.audio.newSource('sounds/female_footsteps.mp3', 'stream')

    -- Collider
    obj.collider = world:newBSGRectangleCollider(obj.x, obj.y, 15, 10, 4)
    obj.collider:setFixedRotation(true)

    -- Animations
    local grid = anim8.newGrid(32, 32, obj.spriteSheet:getWidth(), obj.spriteSheet:getHeight())
    obj.animations = {
        down  = anim8.newAnimation(grid('1-6', 4), obj.animSpeed),
        up    = anim8.newAnimation(grid('1-6', 2), obj.animSpeed),
        left  = anim8.newAnimation(grid('1-6', 1), obj.animSpeed),
        right = anim8.newAnimation(grid('1-6', 3), obj.animSpeed)
    }
    obj.anim = obj.animations.down

    setmetatable(obj, self)
    self.__index = self
    obj:updatePositionFromCollider()
    return obj
end

function Player:updatePositionFromCollider()
    if not self.collider then return end
    self.x, self.y = self.collider:getX() + 2, self.collider:getY() - 15
end

function Player:update(dt)
    local vx, vy, isMoving = 0, 0, false

    if love.keyboard.isDown('w') then vy = -self.walkingSpeed; self.anim = self.animations.up; isMoving = true end
    if love.keyboard.isDown('s') then vy =  self.walkingSpeed; self.anim = self.animations.down; isMoving = true end
    if love.keyboard.isDown('d') then vx =  self.walkingSpeed; self.anim = self.animations.right; isMoving = true end
    if love.keyboard.isDown('a') then vx = -self.walkingSpeed; self.anim = self.animations.left; isMoving = true end

    self.collider:setLinearVelocity(vx, vy)
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

function Player:draw(scale)
    self.anim:draw(
        self.spriteSheet,
        self.x, self.y,
        nil,
        scale / 3, scale / 3,
        16, 16
    )
end

return Player