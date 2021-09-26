--[[
Add the following to DCS World/Scripts/ScriptingSystem.lua after dofile('Scripts/ScriptingSystem.lua'):
dofile(lfs.writedir().."Mods\services\LotAtc\lua utils\lotatcMissionServer.lua")
]]--

lotatcLink = {}

--do
    env.info("initializing LotAtcLink...")
 local require = require
local loadfile = loadfile
lotatcLink.mission_env = {} 
lotatcLink.scheduled = false
lotatcLink.host = "localhost"
lotatcLink.port = 8081
lotatcLink.version = ""
lotatcLink.callbacks = nil


package.path = package.path..";.\\LuaSocket\\?.lua"
package.cpath = package.cpath..";.\\LuaSocket\\?.dll"

local JSON = loadfile("Scripts\\JSON.lua")()
lotatcLink.JSON = JSON
local socket = require("socket")

lotatcLink.step = function(arg, time)
	local ret1, ret2, ret3 = lotatcLink.conn:send(  "{ \"command\": \"order\" }")
	env.info("LotAtcLink: send error: ".. ret1)
	if ret1 then
		bytes_sent = ret1
	else
		--env.info("could not send witchcraft: "..ret2)
		if ret3 == 0 then
			if ret2 == "closed" then
				lotatcLink.conn = socket.tcp()
				lotatcLink.conn:settimeout(.0001)
				env.info("LotAtcLink: socket was closed")
			end
			env.info("LotAtcLink: reconnecting to "..tostring(lotatcLink.host)..":"..tostring(lotatcLink.port))
			lotatcLink.conn:connect(lotatcLink.host, lotatcLink.port)
			return
		end
		bytes_sent = ret3
	end
	local line, err = lotatcLink.conn:receive()
	if err then
		env.info("LotAtcLink: read error: "..err)
	else
		env.info("LotAtcLink: received data: ".. line)
		msg = JSON:decode(line)
		if not lotatcLink.callbacks then
			env.info("LotAtcLink: NO REGISTERED CALLBACKS")
			return
		end
		if msg then 
			if msg.command == "status" then
				if lotatcLink.callbacks.command_status then
					lotatcLink.callbacks.command_status(env, msg)
				else
					env.info("LotAtcLink: no callback for command_status")
				end
			elseif msg.command == "order" then
				if lotatcLink.callbacks.command_order then
					lotatcLink.callbacks.command_order(env, msg)
				else
					env.info("LotAtcLink: no callback for command_order")
				end
			end

			-- local f, error_msg = loadstring(msg.code, msg.name)
			-- if f then
			-- 	witchcraft.context = {}
			-- 	witchcraft.context.arg = msg.arg
			-- 	setfenv(f, witchcraft.mission_env)
			-- 	response_msg.success, response_msg.result = pcall(f)
			-- else
			-- 	response_msg.success = false
			-- 	response_msg.result = tostring(error_msg)
			-- end
		end
	end
end

lotatcLink.init = function(_me)
	if not lotatcLink.scheduled then
		lotatcLink.mission_env = _me
		lotatcLink.conn = socket.tcp()
		lotatcLink.conn:settimeout(.0001)
		lotatcLink.conn:connect(lotatcLink.host, lotatcLink.port)
		
		timer.scheduleFunction(function(arg, time)
				local bool, err = pcall(lotatcLink.step)
				if not bool then
					env.info("lotatcLink.step() failed: "..err)
				end
				
				return timer.getTime() + 1 -- <<< update interval
			end, nil, timer.getTime() + 1)
			
		lotatcLink.scheduled = true
		env.info("LotAtcLink: init scheduler ")
	end
end
-----------------------------------------
lotatcLink.registerCallbacks = function( cbk )
    env.info("LotAtcLink: register callbacks")
    lotatcLink.callbacks = cbk
end
-----------------------------------------

-----------------------------------------


    env.info("LotAtcLink initialized")
--end
