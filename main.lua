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

    local ninja = makeNinja(200, 200, world)
    ninja.id = ip
    ninja.fixture:setUserData(ip)
    ninjas[ninja.id] = ninja
    myninja = ninjas[ip]

    love.graphics.setBackgroundColor(104, 136, 248)
    love.window.setMode(windowX, windowY)

    if(isClient) then
        connectToServer(myninja)
    end

    camera:set()
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
end

function love.keypressed(key)
    if myninja.pressed[key] ~= nil then
        myninja.pressed[key] = true
    end
    if isClient then
        clientPressHandler(key)
    else
        serverPressHandler(key, ninjas)
    end
end

function love.keyreleased(key)
    if myninja.pressed[key] ~= nil then
        myninja.pressed[key] = false
    end
    if isClient then
        clientReleaseHandler(key)
    else
        serverReleaseHandler(key, ninjas)
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
