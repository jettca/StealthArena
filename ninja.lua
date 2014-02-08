local anim8 = require 'anim8'
local ninja_im = love.graphics.newImage('ninja.png')
frame_width = 50
frame_height = 77
local ninja_g = anim8.newGrid(frame_width, frame_height, ninja_im:getWidth(), ninja_im:getHeight())

function makeNinja(x, y, world)
    local ninja = {
        image = ninja_im,
        anim = {
            stand = anim8.newAnimation(ninja_g('1-1', 1), 0.1),
            walkLeft = anim8.newAnimation(ninja_g('1-8', 2), 0.1),
            walkRight = anim8.newAnimation(ninja_g('1-8', 3), 0.1)
        },
        speed = 400,
        accel = 50000,
        decel = 500,
        jump = -400,
        dir = '',
        pressed = {
            left = false,
            right = false,
            up = false,
        },
        touching = nil,
        jumptime = 0,
        maxjump = .5,
        knives = {}
    }
    ninja.body = love.physics.newBody(world, x, y, 'dynamic')
    ninja.box = love.physics.newRectangleShape(frame_width, frame_height)
    ninja.fixture = love.physics.newFixture(ninja.body, ninja.box, 20)

    return ninja
end

function moveNinja(dt, ninja)
    vx, vy = ninja.body:getLinearVelocity()
    if ninja.pressed.up then
        if ninja.touching ~= nil and ninja.touching.body:getY() >= ninja.body:getY() then
            ninja.body:setLinearVelocity(vx, ninja.jump)
            ninja.jumptime = ninja.maxjump
        elseif ninja.jumptime > 0 then
            ninja.body:setLinearVelocity(vx, ninja.jump)
            ninja.jumptime = ninja.jumptime - dt
        end
    else
        ninja.jumptime = 0
    end
    if ninja.pressed.right then
        ninja.dir = 'right'
        ninja.anim.walkRight:update(dt)
        if vx < ninja.speed then
            ninja.body:applyForce(ninja.accel, 0)
        end
    elseif ninja.pressed.left then
        ninja.dir = 'left'
        ninja.anim.walkLeft:update(dt)
        if vx > -ninja.speed then
            ninja.body:applyForce(-ninja.accel, 0)
        end
    else
        ninja.dir = ''
        ninja.body:applyForce(-vx*ninja.decel, 0)
    end
end

function drawNinja(ninja)
    drawX = ninja.body:getX() - frame_width/2
    drawY = ninja.body:getY() - frame_height/2
    if ninja.dir == '' then
        ninja.anim.stand:draw(ninja.image, drawX, drawY)
    elseif ninja.dir == 'left' then
        ninja.anim.walkLeft:draw(ninja.image, drawX, drawY)
    elseif ninja.dir == 'right' then
        ninja.anim.walkRight:draw(ninja.image, drawX, drawY)
    end
end

function throwKnife(world, ninja)
    local knife = {}
    knife.body = love.physics.newBody(world, ninja.body:getX(), ninja.body:getY())
end
