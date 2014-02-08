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
    
    local ninja = makeNinja(1000, 1000, world, ip)
    ninjas[ninja.id] = ninja
    myninja = ninjas[ip]
    myninja.visible = true

    myninja.los.body = love.physics.newBody(world, x, y, "dynamic")
    myninja.los.body:setGravityScale(0)
    myninja.los.body:setMass(0)
    myninja.los.shape = love.physics.newPolygonShape(
        0, 0, myninja.los.length, myninja.los.height/2,
        myninja.los.length, -myninja.los.height/2
    )
    myninja.los.fixture = love.physics.newFixture(myninja.los.body, myninja.los.shape)
    myninja.los.fixture:setSensor(true)
    myninja.los.fixture:setUserData("los")

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
        if ninja.visible then
            drawNinja(ninja)
        end
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
    local adata = a:getUserData()
    local bdata = b:getUserData()

    if adata == "floor" and ninjas[bdata] ~= nil then
        ninja = ninjas[bdata]
        ninja.touching = a:getBody()
    elseif b:getUserData() == "floor" and ninjas[adata] ~= nil then
        ninja = ninjas[adata]
        ninja.touching = b:getBody()

    elseif (adata == "floor" or adata == "wall") and knives[bdata] ~= nil then
        knife = knives[bdata]
        knife.fixture:destroy()
        knives[bdata] = nil
    elseif (bdata == "floor" or bdata == "wall") and knives[adata] ~= nil then
        knife = knives[adata]
        knife.fixture:destroy()
        knives[adata] = nil

    elseif ninjas[adata] ~= nil and knives[bdata] ~= nil then
        knife = knives[bdata]
        knife.fixture:destroy()
        knives[bdata] = nil
    elseif ninjas[bdata] ~= nil and knives[adata] ~= nil then
        knife = knives[adata]
        knife.fixture:destroy()
        knives[adata] = nil

    elseif ninjas[adata] ~= nil and bdata == "los" then
        ninjas[adata].visible = true
    elseif ninjas[bdata] ~= nil and adata == "los" then
        ninjas[bdata].visible = true
    end

end

function endContact(a, b, coll)
    local ninja
    local adata = a:getUserData()
    local bdata = b:getUserData()
    if a:getUserData() == "floor" and ninjas[b:getUserData()] ~= nil then
        ninja = ninjas[b:getUserData()]
        ninja.touching = nil
    elseif b:getUserData() == "floor" and ninjas[b:getUserData()] ~= nil then
        ninja = ninjas[a:getUserData()]
        ninja.touching = nil

    elseif ninjas[adata] ~= nil and bdata == "los" then
        ninjas[adata].visible = false
    elseif ninjas[bdata] ~= nil and adata == "los" then
        ninjas[bdata].visible = false
    end
end
