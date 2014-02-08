require "json"
local socket = require "socket"
local udp = socket.udp()
local port = 12345
ip = nil
serverIp = nil

udp:settimeout(0)
udp:setoption("broadcast", true)

isClient = false
isServer = false

sleepTime = 0.01
sleepTimer = 0

function connectionSetup(arg)

    if #arg > 1 then
        isClient = true
        print("client")
        serverIp = arg[2]
        print(serverIp)

        udp:setsockname('*', port)
    else
        isServer = true
        print("server")

        udp:setsockname('*', port)
    end

    local client = socket.connect( "www.google.com", 80 )
    ip, _ = client:getsockname()

    print(ip)
end

function connectToServer(ninja)
    local formattedMessage = {}
    formattedMessage["type"] = "newConnection"
    formattedMessage["data"] = {id=ip, ninja=ninja}

    udp:sendto(json.encode(formattedMessage), serverIp, port)

end

function connectionUpdate(dt, ninjas, world)

    local rawMessage, msg, receiveIp, receivePort
    if isServer then
        rawMessage, msg = udp:receive()
    else
        rawMessage, msg = udp:receive()
    end


    if rawMessage then
        print(rawMessage)

        local formattedMessage = json.decode(rawMessage)
        if formattedMessage ~= nil then

            print(formattedMessage.type)

            if formattedMessage.type == "newConnection" then

                local newNinja = makeNinja(200, 200, world, formattedMessage.data["id"])

                ninjas[formattedMessage.data["id"]] = newNinja

                if isServer then
                    for _, ninja in pairs(ninjas) do
                        if ninja.id ~= formattedMessage.data["id"] and ninja.id ~= ip then
                            udp:sendto(rawMessage, ninja.id, port)
                        end
                    end
                end

            elseif formattedMessage.type == "keyPress" then
                ninjas[formattedMessage.data["id"]].pressed[formattedMessage.data["key"]] = true

                if isServer then
                    for _, ninja in pairs(ninjas) do
                        if ninja.id ~= formattedMessage.data["id"] and ninja.id ~= ip then
                            udp:sendto(rawMessage, ninja.id, port)
                        end
                    end
                end

            elseif formattedMessage.type == "keyRelease" then
                ninjas[formattedMessage.data["id"]].pressed[formattedMessage.data["key"]] = false

                if isServer then
                    for _, ninja in pairs(ninjas) do
                        if ninja.id ~= formattedMessage.data["id"] and ninja.id ~= ip then
                            udp:sendto(rawMessage, ninja.id, port)
                        end
                    end
                end

            elseif isClient and formattedMessage.type == "worldUpdate" then

                for _, ninja in pairs(formattedMessage.data) do
                    if ninjas[ninja.id] == nil then
                        local newNinja = makeNinja(ninja.x, ninja.y, world, ninja.id)
                        newNinja.pressed = ninja.pressed
                        newNinja.dir = ninja.dir
                        ninjas[ninja.id] = newNinja
                    else
                        local localNinja = ninjas[ninja.id]
                        localNinja.body:setX(ninja.x)
                        localNinja.body:setY(ninja.y)
                        localNinja.dir = ninja.dir
                        localNinja.pressed = ninja.pressed
                    end
                end
            end

        end
    else
        if(msg ~= "timeout") then
            print(tostring(msg))
        end
    end


    if isServer then

        sleepTimer = sleepTimer + dt

        if sleepTimer > sleepTime then
            sleepTimer = 0

            local formattedMessage = {}
            formattedMessage["type"] = "worldUpdate"
            formattedMessage["data"] = {}
            for _, ninja in pairs(ninjas) do
                formattedMessage.data[ninja.id] = {id=ninja.id, x=ninja.body:getX(), y=ninja.body:getY(), dir=ninja.dir, pressed=ninja.pressed}
            end

            for _, ninja in pairs(ninjas) do
                if ninja.id ~= ip then
                    _, err = udp:sendto(json.encode(formattedMessage), ninja.id, port)
                    if err then
                        print("error: "..err)
                    end
                end
            end

        end
    end

end

function clientPressHandler(key)
    local formattedMessage = {}
    formattedMessage["type"] = "keyPress"
    formattedMessage["data"] = {id=ip, key=key}

    --udp:sendto(json.encode(formattedMessage), serverIp, port)
end

function serverPressHandler(key, ninjas)
    local formattedMessage = {}
    formattedMessage["type"] = "keyPress"
    formattedMessage["data"] = {id=ip, key=key}

    for _, ninja in pairs(ninjas) do
        if ninja.id ~= ip then
            --udp:sendto(json.encode(formattedMessage), ninja.id, port)
        end
    end
end

function clientReleaseHandler(key)
    local formattedMessage = {}
    formattedMessage["type"] = "keyRelease"
    formattedMessage["data"] = {id=ip, key=key}

    --udp:sendto(json.encode(formattedMessage), serverIp, port)
end

function serverReleaseHandler(key, ninjas)
    local formattedMessage = {}
    formattedMessage["type"] = "keyPress"
    formattedMessage["data"] = {id=ip, key=key}

    for _, ninja in pairs(ninjas) do
        if ninja.id ~= ip then
            --udp:sendto(json.encode(formattedMessage), ninja.id, port)
        end
    end
end
