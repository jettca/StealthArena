local anim8 = require 'anim8'
local ninja_im = love.graphics.newImage('ninja.png')
frame_width = 50
frame_height = 77
local ninja_g = anim8.newGrid(frame_width, frame_height, ninja_im:getWidth(), ninja_im:getHeight())

function makeNinja(x, y, world, ip)
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
        jump = -600,
        dir = '',
        pressed = {
            left = false,
            right = false,
            up = false,
            x = false
        },
        touching = nil,
        jumptime = 0,
        maxjump = .2,
        knives_thrown = 0
    }
    ninja.body = love.physics.newBody(world, x, y, 'dynamic')
    ninja.box = love.physics.newRectangleShape(frame_width, frame_height)
    ninja.fixture = love.physics.newFixture(ninja.body, ninja.box, 20)

    ninja.id = ip
    ninja.fixture:setUserData(ip)

    return ninja
end

function moveNinja(dt, ninja)
    vx, vy = ninja.body:getLinearVelocity()
    if ninja.pressed.up then
        if ninja.touching ~= nil and ninja.touching:getY() >= ninja.body:getY() then
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

function throwKnife(ninja, knives, world)
    if ninja.pressed.x then
        local knife = makeKnife(world, ninja)
        knives[knife.id] = knife
        ninja.knives_thrown = ninja.knives_thrown + 1
        ninja.pressed.x = false
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

function makeKnife(world, ninja)
    local knife = {
        radius = 10,
        ninja = ninja,
        id = ninja.id .. tostring(ninja.knives_thrown),
        speed = 1000
    }
    knife.body = love.physics.newBody(world, ninja.body:getX(), ninja.body:getY(), "dynamic")
    knife.shape = love.physics.newCircleShape(knife.radius)
    knife.fixture = love.physics.newFixture(knife.body, knife.shape)
    knife.fixture:setUserData(knife.id)

    if ninja.dir == "right" then
        knife.body:setLinearVelocity(knife.speed, 0)
        knife.body:setX(ninja.body:getX() + frame_width)
    else
        knife.body:setLinearVelocity(-knife.speed, 0)
        knife.body:setX(ninja.body:getX() - frame_width)
    end

    return knife
end

function drawKnife(knife)
        love.graphics.circle("fill", knife.body:getX(), knife.body:getY(), knife.shape:getRadius(), 100)
end
