dofile("ninja.lua")
dofile("connection.lua")
--dofile("map.lua")

local ninjas = {}
local myninja
local world
local map
local ground

function love.load(arg)

    local windowSize = 650

    connectionSetup(arg)

    -- Set up world
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*64, true)
    world:setCallbacks(beginContact, endContact)
    
--    map = makeMap(world)
    ground = {}
    ground.body = love.physics.newBody(world, windowSize/2, windowSize - 50/2)
    ground.shape = love.physics.newRectangleShape(windowSize, 50)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setUserData("ground")

    local ninja = makeNinja(200, 200, world)
    ninja.id = ip
    ninja.fixture:setUserData(ip)
    ninjas[ninja.id] = ninja
    myninja = ninjas[ip]

    love.graphics.setBackgroundColor(104, 136, 248)
    love.window.setMode(650, 650)

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
    love.graphics.translate(-100, -300)
    love.graphics.setColor(72, 160, 14)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))
    love.graphics.setColor(255, 255, 255)

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
