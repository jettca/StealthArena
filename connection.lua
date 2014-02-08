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
    ip, _ = udp:getsockname()

    if #arg > 0 then
        isClient = true
        print("client")

        udp:setpeername(arg[1], port)
    else
        isServer = true
        print("server")

        udp:setsockname('*', port)
    end
end

function connectionUpdate(dt, ninjas)
end

function clientPressHandler(key)
end

function serverPressHandler(key)
end
