require "json"
local socket = require "socket"
local udp = socket.udp()
local port =  6500
local data, msg_or_ip, port_or_nil, msg
ip = nil

udp:settimeout(0)

isClient = false
isServer = false

sleepTime = 0.1
sleepTimer = 0
    
function connectionSetup(arg)

    if #arg > 1 then
        isClient = true
        print("client")

        udp:setpeername(arg[2], port)

    else
        isServer = true
        print("server")

        udp:setsockname('*', port)
    end

    ip, _ = socket.dns.toip(socket.dns.gethostname())

end

function connectToServer(ninja)
    local formattedMessage = {}
    formattedMessage["type"] = "newConnection"
    formattedMessage["data"] = {id: ip, ninja:ninja}

    udp:send(json.encode(formattedMessage))

end

function connectionUpdate(dt, ninjas)

    local rawMessage, msg = udp:receive()
    if rawMessage then
        if formattedMessage.type == "newConnection" then
            ninjas[formattedMessage.data["id"]] = formattedMessage.data["ninja"]

            if isServer then
                for _, ninja in pairs(ninjas) do
                    udp:sendto(rawMessage, ninja.id, port)
                end
            end

        elseif formattedMessage.type == "keyPress" then
            ninjas[formattedMessage.data["id"]].pressed[formattedMessage.data["key"]] = true

            if isServer then
                for _, ninja in pairs(ninjas) do
                    udp:sendto(rawMessage, ninja.id, port)
                end
            end

        elseif formattedMessage.type == "keyRelease" then
            ninjas[formattedMessage.data["id"]].pressed[formattedMessage.data["key"]] = false

            if isServer then
                for _, ninja in pairs(ninjas) do
                    udp:sendto(rawMessage, ninja.id, port)
                end
            end

        elseif formattedMessage.type == "worldUpdate" and isClient then
            ninjas = formattedMessage.data["ninjas"]

        end
    end


    if isServer then

        sleepTimer = sleepTimer + dt

        if sleepTimer > sleepTime then
            sleepTimer = 0

            local formattedMessage = {}
            formattedMessage["type"] = "worldUpdate"
            formattedMessage["data"] = ninjas
        
            for _, ninja in pairs(ninjas) do
                udp:sendto(json.encode(formattedMessage), ninja.id, port)
            end

        end
    end

end

function clientPressHandler(key)
    local formattedMessage = {}
    formattedMessage["type"] = "keyPress"
    formattedMessage["data"] = {id:ip, key:key}

    udp:send(json.encode(message))
end

function serverPressHandler(key, ninjas)
    local formattedMessage = {}
    formattedMessage["type"] = "keyPress"
    formattedMessage["data"] = {id:ip, key:key}

    for _, ninja in pairs(ninjas) do
        udp:sendto(json.encode(formattedMessage), ninja.id, port)
    end
end

function clientReleaseHandler(key)
    local formattedMessage = {}
    formattedMessage["type"] = "keyRelease"
    formattedMessage["data"] = {id:ip, key:key}

    udp:send(json.encode(message))
end

function serverReleaseHandler(key, ninjas)
    local formattedMessage = {}
    formattedMessage["type"] = "keyPress"
    formattedMessage["data"] = {id:ip, key:key}
    
    for _, ninja in pairs(ninjas) do
        udp:sendto(json.encode(formattedMessage), ninja.id, port)
    end
end
