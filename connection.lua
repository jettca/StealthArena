require "json"
local socket = require "socket"
local udp = socket.udp()
local port =  6500
local data, msg_or_ip, port_or_nil, msg
ip = nil
serverIp = nil

udp:settimeout(0)

isClient = false
isServer = false

sleepTime = 0.1
sleepTimer = 0
    
function connectionSetup(arg)

    if #arg > 1 then
        isClient = true
        print("client")
        serverIp = arg[2]
        print(serverIp)
        udp:setpeername(serverIp, port)

    else
        isServer = true
        print("server")

        udp:setsockname('*', port)
    end

    ip, _ = socket.dns.toip(socket.dns.gethostname())
    print(ip)
end

function connectToServer(ninja)
    local formattedMessage = {}
    formattedMessage["type"] = "newConnection"
    formattedMessage["data"] = {id=ip, ninja=ninja}

    udp:send(json.encode(formattedMessage))

end

function connectionUpdate(dt, ninjas, world)

    local rawMessage, msg = udp:receive()

    if rawMessage then

        local formattedMessage = json.decode(rawMessage)
        if formattedMessage ~= nil then

            print(formattedMessage.type)

            if formattedMessage.type == "newConnection" then
                
                local newNinja = makeNinja(200, 200, world)
                newNinja.id = formattedMessage.data["id"]
                newNinja.fixture:setUserData(ip)
                
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

            elseif formattedMessage.type == "worldUpdate" and isClient then
                
                for _, ninja in pairs(formattedMessage.data) do
                    local localNinja = ninjas[ninja.id]
                    localNinja.body:setX(ninja.x)
                    localNinja.body:setY(ninja.y)
                end

            end

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
                formattedMessage.data[ninja.id] = {id=ninja.id, x=ninja.body:getX(), y=ninja.body:getY()}
            end
        
            for _, ninja in pairs(ninjas) do
                if ninja.id ~= ip then
                    udp:sendto(json.encode(formattedMessage), ninja.id, port)
                end
            end

        end
    end

end

function clientPressHandler(key)
    local formattedMessage = {}
    formattedMessage["type"] = "keyPress"
    formattedMessage["data"] = {id=ip, key=key}

    udp:send(json.encode(formattedMessage))
end

function serverPressHandler(key, ninjas)
    local formattedMessage = {}
    formattedMessage["type"] = "keyPress"
    formattedMessage["data"] = {id=ip, key=key}

    for _, ninja in pairs(ninjas) do
        if ninja.id ~= ip then
            udp:sendto(json.encode(formattedMessage), ninja.id, port)
        end
    end
end

function clientReleaseHandler(key)
    local formattedMessage = {}
    formattedMessage["type"] = "keyRelease"
    formattedMessage["data"] = {id=ip, key=key}

    udp:send(json.encode(formattedMessage))
end

function serverReleaseHandler(key, ninjas)
    local formattedMessage = {}
    formattedMessage["type"] = "keyPress"
    formattedMessage["data"] = {id=ip, key=key}
    
    for _, ninja in pairs(ninjas) do
        if ninja.id ~= ip then
            udp:sendto(json.encode(formattedMessage), ninja.id, port)
        end
    end
end
