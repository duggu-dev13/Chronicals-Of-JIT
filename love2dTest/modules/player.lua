-- player.lua
local anim8 = require 'libraries/anim8'

local Player = {}

function Player:new(world)
    local obj = {}

    -- Player setup
    obj.x, obj.y = 200, 100
    obj.walkingSpeed = 50
    obj.animSpeed = 0.1
    obj.spriteSheet = love.graphics.newImage("sprites/Teacher_1_walk-Sheet.png")

    -- Collider
    obj.collider = world:newBSGRectangleCollider(obj.x, obj.y, 18, 35, 4)
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
    return obj
end

function Player:update(dt)
    local vx, vy, isMoving = 0, 0, false

    if love.keyboard.isDown('w') then vy = -self.walkingSpeed; self.anim = self.animations.up; isMoving = true end
    if love.keyboard.isDown('s') then vy =  self.walkingSpeed; self.anim = self.animations.down; isMoving = true end
    if love.keyboard.isDown('d') then vx =  self.walkingSpeed; self.anim = self.animations.right; isMoving = true end
    if love.keyboard.isDown('a') then vx = -self.walkingSpeed; self.anim = self.animations.left; isMoving = true end

    self.collider:setLinearVelocity(vx, vy)
    if not isMoving then self.anim:gotoFrame(1) end

    self.x, self.y = self.collider:getX() + 2, self.collider:getY()
    self.anim:update(dt)
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
