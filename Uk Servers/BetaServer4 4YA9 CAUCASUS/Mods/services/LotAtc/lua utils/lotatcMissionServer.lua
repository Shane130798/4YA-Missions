--[[
Add the following to DCS World/Scripts/ScriptingSystem.lua after dofile('Scripts/ScriptingSystem.lua'):
dofile(lfs.writedir().."Mods\services\LotAtc\lua utils\lotatcMissionServer.lua")
]]--

lotatcLink = {}

--do
    env.info("initializing LotAtcLink...")
 --------------------------------------------------------------
-- LotAtc Link mission script file
-- Copyright RBorn Software
-- Author: DArt - LotAtc
--------------------------------------------------------------
local require = require
local loadfile = loadfile

-- Debug (show output in dcs.lag)
lotatcLink.show_debug = false

-- Customization (adapt if you need)
lotatcLink.port = 8081 -- LotAtc port
lotatcLink.host = "localhost" -- LotAtc host (no reason to change that)
lotatcLink.interval = 1 -- Update interval for orders in seconds
lotatcLink.airport_interval = 60 -- Update interval for each airports in seconds

--------------------------------------------------------------
-- Internals
lotatcLink.scheduled = false
lotatcLink.version = ""
lotatcLink.callbacks = nil
lotatcLink.userFlags = {}
lotatcLink.mission_env = {}
lotatcLink.airports = {}
lotatcLink.airport_init = true
lotatcLink.airport_current = 1
lotatcLink.airport_last = 1

--------------------------------------------------------------
-- Loading
package.path = package.path..";.\\LuaSocket\\?.lua"
package.cpath = package.cpath..";.\\LuaSocket\\?.dll"

--------------------------------------------------------------
local JSON = loadfile("Scripts\\JSON.lua")()
lotatcLink.JSON = JSON
local socket = require("socket")
--------------------------------------------------------------

--------------------------------------------------------------
-- Public API 

--------------------------------------------------------------
-- Register our callbacks
lotatcLink.registerCallbacks = function( cbk )
    lotatcLink.print("Register callbacks")
    lotatcLink.callbacks = cbk
end

--------------------------------------------------------------
lotatcLink.init = function(_me)
	env.info("lotatcLink.init is DEPRECATED and NO MORE NEEDED, you can remove it")
end

--------------------------------------------------------------
-- Initialize lotAtc Link
lotatcLink.initLink = function(_me)
	if not lotatcLink.scheduled then
		lotatcLink.mission_env = _me
		lotatcLink.conn = socket.tcp()
		lotatcLink.conn:settimeout(.0001)
		lotatcLink.conn:connect(lotatcLink.host, lotatcLink.port)
		
		timer.scheduleFunction(function(arg, time)
				local bool, err = pcall(lotatcLink.step)
				if not bool then
					lotatcLink.print("lotatcLink.step() failed: "..err)
				end
				
				return timer.getTime() + lotatcLink.interval -- <<< update interval
			end, nil, timer.getTime() + lotatcLink.interval)
			
		lotatcLink.scheduled = true
		lotatcLink.print("Init scheduler ")

		-- Get airbases
		local base = world.getAirbases()
	   lotatcLink.print( "Find airport ", #base )
	   local airports = {}
	   for i = 1, #base do
		   local info = {}
		   info.point = Airbase.getPoint(base[i])
		   info.callsign = Airbase.getCallsign(base[i])
		   info.id = Airbase.getID(base[i])
		   airports[#airports+1] = info
		   lotatcLink.print( "Add airport ", info.id, info.callsign )
	   end
	   lotatcLink.print( "Airport loaded", #airports )
	   lotatcLink.airports = airports
	   lotatcLink.airport_last = timer.getTime()
	   lotatcLink.airport_current = 1
	   lotatcLink.airport_init = true
	end
end

--------------------------------------------------------------
-- Register an user flag to be accessible on LotAtc Advanced
lotatcLink.registerUserFlag = function( _n, _title, _description )
	local f = {}
	f.number = _n
	f.title = _title
	f.description = _description
    f.value = trigger.misc.getUserFlag(f.number)
    lotatcLink.print("Register " .. f.number )
	lotatcLink.userFlags[#lotatcLink.userFlags+1] = f
end

--------------------------------------------------------------
----------- INTERNALS
function JSON:assert(message)
   lotatcLink.print("Internal Error: invalid JSON data " .. message)
end

--------------------------------------------------------------
lotatcLink.get_user_flags = function()
	for i, f in pairs(lotatcLink.userFlags) do
		-- update status
		f.value = trigger.misc.getUserFlag(f.number)
	end
	return lotatcLink.userFlags
end

--------------------------------------------------------------
lotatcLink.step = function(arg, time)
	local command = { }
	command.command = "order"

	local t = timer.getTime()
	-- Fill data as a string
	local data = {}
	
	--user flags
	data.user_flags = lotatcLink.get_user_flags()

	-- airports
	if  lotatcLink.airport_init or ((t - lotatcLink.airport_last) > lotatcLink.airport_interval) then
		data.airports = lotatcLink.get_next_airport()
		lotatcLink.airport_last = t;
	end
	command.data = JSON:encode(data)

	-- Send update
    local tosend = JSON:encode(command) 
	-- env.info("LotAtcLink: send " .. tosend)
	local ret1, ret2, ret3 = lotatcLink.conn:send(tosend)

	--env.info("LotAtcLink: send error: ".. ret1)
	if ret1 then
		bytes_sent = ret1
	else
		--env.info("could not send witchcraft: "..ret2)
		if ret3 == 0 then
			if ret2 == "closed" then
				lotatcLink.conn = socket.tcp()
				lotatcLink.conn:settimeout(.0001)
				lotatcLink.print("socket was closed")
			end
			lotatcLink.print("reconnecting to "..tostring(lotatcLink.host)..":"..tostring(lotatcLink.port))
			lotatcLink.conn:connect(lotatcLink.host, lotatcLink.port)
			return
		end
		bytes_sent = ret3
	end
	local line, err = lotatcLink.conn:receive()
	if err then
		lotatcLink.print("LotAtcLink: read error: "..err)
	else
		--env.info("LotAtcLink: received data: ".. line)
		msg = JSON:decode(line)
		if msg then 
			if msg.command == "status" then
				if lotatcLink.callbacks and lotatcLink.callbacks.command_status then
					lotatcLink.callbacks.command_status(env, msg)
				else
					lotatcLink.print("no callback for command_status (use LotAtcLink.registerCallbacks)")
				end
			elseif msg.command == "order" then
				-- Check for flag changes
				-- no group in this cases
				for i, order in pairs(msg.orders) do
					if order.order_name == "flag" then
						-- env.info("Set flag " .. order.number .. " to ")
						-- if order.value then
						-- 	env.info("--> True")
						-- else
						-- 	env.info("--> False")
						-- end
						trigger.action.setUserFlag( order.number, order.value)
					end
				end

				-- Call custom if any
				if lotatcLink.callbacks and lotatcLink.callbacks.command_order then
					lotatcLink.callbacks.command_order(env, msg)
				else
					lotatcLink.print("no callback for command_order (use LotAtcLink.registerCallbacks)")
				end
			end
		end
	end
end

--------------------------------------------------------------
lotatcLink.print = function( s, ...)
    if lotatcLink.show_debug then
        local ps = "[LOTATC-LINK] " .. tostring(s)
        for i, v in ipairs(arg) do
            ps = ps .. " " .. tostring(v)
        end
        env.info(ps)
    end
end
--------------------------------------------------------------
lotatcLink.round = function(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end
--------------------------------------------------------------
lotatcLink.get_weather= function(vec3)
    local point={x=vec3.x, y=vec3.y, z=vec3.z}
    local alt = point.y
    -- Get Temperature [K] and Pressure [Pa] at vec3.
    local T
    local Pqfe
    
    -- At user specified altitude.
    T,Pqfe=atmosphere.getTemperatureAndPressure({x=vec3.x, y=alt, z=vec3.z})
    
    -- Get pressure at sea level.
    local _,Pqnh=atmosphere.getTemperatureAndPressure({x=vec3.x, y=0, z=vec3.z})
    lotatcLink.print(string.format("Pqnh = %.2f", Pqnh))
    T = lotatcLink.round(T-273.15)
    lotatcLink.print(string.format("T = %.1f, Pqfe = %.2f", T,Pqfe))
    -- Convert pressure from Pascal to hecto Pascal.
    -- Get wind velocity vector.
    local windvec3  = atmosphere.getWind(point)
    local direction = math.deg(math.atan2(windvec3.z, windvec3.x))
    
    if direction < 0 then
        direction = direction + 360
    end
    
    -- Convert TO direction to FROM direction. 
    if direction > 180 then
        direction = direction-180
    else
        direction = direction+180
    end
    
    -- Calc 2D strength.
    local strength=math.sqrt((windvec3.x)^2+(windvec3.z)^2)
    local weather = {}
    weather.temperature = T
    weather.qnh = lotatcLink.round(Pqnh/100)
    weather.qfe = lotatcLink.round(Pqfe/100)

    local winds = {}
    winds.ground = {}
    winds.ground.from = direction
    winds.ground.speed = strength
    weather.winds = winds

    return weather
end
--------------------------------------------------------------
--- Weather Report. Report pressure QFE/QNH, temperature, wind at certain location.
lotatcLink.get_next_airport = function()
  local data = {}
  if lotatcLink.airport_init then
    -- init all
    for k,v in pairs(lotatcLink.airports) do
      data[#data+1] = lotatcLink.get_airport(k)
    end
    lotatcLink.airport_init = false
    lotatcLink.print( "Airport init done")
  else
    -- Slow loop
    local n = lotatcLink.airport_current
    data[#data+1] = lotatcLink.get_airport(n)

    if n >= (#lotatcLink.airports) then
      n = 0
    end
    lotatcLink.airport_current = n+1
  end
  return data
end

lotatcLink.get_airport = function(n)
  lotatcLink.print( "get airport", n)
  local data = {}

  local airport = lotatcLink.airports[n]
  if airport then
    lotatcLink.print( "          ----> ", airport.callsign)
    data.name = airport.callsign
    data.weather = lotatcLink.get_weather(airport.point)
  else
    lotatcLink.print( "          ----> NO AIRPORT")
  end
  
  return data
end


--------------------------------------------------------------
-- Launch link
lotatcLink.initLink(_G)

--------------------------------------------------------------
-- END
--------------------------------------------------------------


    env.info("LotAtcLink initialized")
--end
