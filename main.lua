dofile("ninja.lua")
dofile("connection.lua")
dofile("map.lua")

local ninjas = {}
local myninja
local world
local map

function love.load(arg)

    connectionSetup(arg)

    -- Set up world
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)
    map = makeMap()

    local ninja = makeNinja(200, 200, world)
    ninja.id = ip
    ninjas[ninja.id] = ninja
    myninja = ninjas[ip]
end

function love.update(dt)
    -- ninja movement input
    for _, ninja in pairs(ninjas) do
        moveNinja(dt, ninja)
    end

    world:update(dt)
    connectionUpdate(dt, ninjas)
end

function love.draw()
    for _, ninja in pairs(ninjas) do
        if ninja.dir == '' then
            ninja.anim.stand:draw(ninja.image, ninja.body:getX(), ninja.body:getY())
        elseif ninja.dir == 'left' then
            ninja.anim.walkLeft:draw(ninja.image, ninja.body:getX(), ninja.body:getY())
        elseif ninja.dir == 'right' then
            ninja.anim.walkRight:draw(ninja.image, ninja.body:getX(), ninja.body:getY())
        end
    end
end

function love.keypressed(key)
    if myninja.pressed[key] ~= nil then
        myninja.pressed[key] = true
    end
    if isClient then
        clientPressHandler(key)
    else
        serverPressHandler(key)
    end
end

function love.keyreleased(key)
    if myninja.pressed[key] ~= nil then
        myninja.pressed[key] = false
    end
    if isClient then
        clientReleaseHandler(key)
    else
        serverReleaseHandler(key)
    end
end
