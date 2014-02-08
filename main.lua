dofile("camera.lua")
dofile("ninja.lua")
dofile("connection.lua")
dofile("map.lua")

local ninjas = {}
local knives = {}
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
    world = love.physics.newWorld(0, 40*64, true)
    world:setCallbacks(beginContact, endContact)

    map = makeMap(world)
    
    local ninja = makeNinja(200, 200, world, ip)
    ninjas[ninja.id] = ninja
    myninja = ninjas[ip]

    love.graphics.setBackgroundColor(104, 136, 248)
    love.window.setMode(windowX, windowY)
    camera:set()

    if(isClient) then
        connectToServer(myninja)
    end
end

function love.update(dt)
    connectionUpdate(dt, ninjas, knives, world)
    world:update(dt)

    -- ninja movement input
    for _, ninja in pairs(ninjas) do
        moveNinja(dt, ninja)
        throwKnife(ninja, knives, world)
    end
end

function love.draw()
    camera:unset()
    camera:setPosition(myninja.body:getX() - windowX/2, myninja.body:getY() - windowY/2)
    camera:set()

    drawWalls(map.walls)
    drawPlatforms(map.platforms)

    for _, ninja in pairs(ninjas) do
        drawNinja(ninja)
    end

    for _, knife in pairs(knives) do
        drawKnife(knife)
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
    if a:getUserData() == "floor" and b:getUserData() ~= nil then
        ninja = ninjas[b:getUserData()]
        ninja.touching = a:getBody()
    elseif b:getUserData() == "floor" and b:getUserData() ~= nil then
        ninja = ninjas[a:getUserData()]
        ninja.touching = b:getBody()
    end
end

function endContact(a, b, coll)
    local ninja
    if a:getUserData() == "floor" and b:getUserData() ~= nil then
        ninja = ninjas[b:getUserData()]
        ninja.touching = nil
    elseif b:getUserData() == "floor" and b:getUserData() ~= nil then
        ninja = ninjas[a:getUserData()]
        ninja.touching = nil
    end
end
