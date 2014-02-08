dofile("camera.lua")
dofile("ninja.lua")
dofile("connection.lua")
--dofile("map.lua")

local ninjas = {}
local myninja
local world
local map
local ground
local windowX = 800
local windowY = 600

function love.load(arg)
    connectionSetup(arg)

    -- Set up world
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*64, true)
    world:setCallbacks(beginContact, endContact)
    
--    map = makeMap(world)
    ground = {}
    ground.body = love.physics.newBody(world, windowX/2, windowY - 50/2)
    ground.shape = love.physics.newRectangleShape(windowX, 50)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setUserData("ground")

    local ninja = makeNinja(200, 200, world, ip)
    myninja = ninjas[ip]

    love.graphics.setBackgroundColor(104, 136, 248)
    love.window.setMode(windowX, windowY)
    camera:set()

    if(isClient) then
        connectToServer(myninja)
    end
end

function love.update(dt)
    connectionUpdate(dt, ninjas, world)
    world:update(dt)

    -- ninja movement input
    for _, ninja in pairs(ninjas) do
        moveNinja(dt, ninja)
    end
end

function love.draw()
    camera:unset()
    camera:setPosition(myninja.body:getX() - windowX/2, myninja.body:getY() - windowY/2)
    camera:set()

    love.graphics.setColor(72, 160, 14)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))
    love.graphics.setColor(255, 255, 255)

    for _, ninja in pairs(ninjas) do
        drawNinja(ninja)
    end
end

function love.keypressed(key)
    if myninja.pressed[key] ~= nil then
        myninja.pressed[key] = true

        if isClient then
            clientPressHandler(key)
        else
            serverPressHandler(key, ninjas)
        end
    end
end

function love.keyreleased(key)
    if myninja.pressed[key] ~= nil then
        myninja.pressed[key] = false

        if isClient then
            clientReleaseHandler(key)
        else
            serverReleaseHandler(key, ninjas)
        end
    end
end

function beginContact(a, b, coll)
    local ninja
    if a:getUserData() == "ground" then
        ninja = ninjas[b:getUserData()]
    elseif b:getUserData() == "ground" then
        ninja = ninjas[a:getUserData()]
    else
        return
    end

    ninja.touching = ground
end

function endContact(a, b, coll)
    local ninja
    if a:getUserData() == "ground" then
        ninja = ninjas[b:getUserData()]
    elseif b:getUserData() == "ground" then
        ninja = ninjas[a:getUserData()]
    else
        return
    end

    ninja.touching = nil
end
