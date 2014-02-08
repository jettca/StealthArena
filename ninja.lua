local anim8 = require 'anim8'

function makeNinja(x, y)
    local ninja_im = love.graphics.newImage('ninja.png')
    local width = 50
    local height = 77
    local ninja_g = anim8.newGrid(width, height, ninja_im:getWidth(), ninja_im:getHeight())

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
        dir = '',
        pressed = {
            left = false,
            right = false,
            up = false,
            down = false
        }
    }
    ninja.body = love.physics.newBody(world, x, y, 'dynamic')
    ninja.box = love.physics.newRectangleShape(width, height)
    ninja.fixture = love.physics.newFixture(ninja.body, ninja.box, 20)
    ninja.fixture:setUserData('ninja')

    return ninja
end

function moveNinja(dt, ninja)
    vx, vy = ninja.body:getLinearVelocity()
    if ninja.pressed.left then
        ninja.dir = 'left'
        ninja.anim.walkLeft:update(dt)
        if vx > -ninja.speed then
            ninja.body:applyForce(-ninja.accel, 0)
        end
    elseif ninja.pressed.right then
        ninja.dir = 'right'
        ninja.anim.walkRight:update(dt)
        if vx < ninja.speed then
            ninja.body:applyForce(ninja.accel, 0)
        end
    else
        ninja.dir = ''
        ninja.body:applyForce(-vx*ninja.decel, 0)
    end
end
