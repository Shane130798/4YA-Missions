--[[
Here is a simple example to use with lotatcMissionServer
]]--

env.info("initializing My LotAtc Link example...")
local LCallbacks = {}
LCallbacks.command_status = function(env, msg)
    env.info("LotAtcLink: have version ".. msg.version)
    local _s = string.format("trigger.action.outText('LotAtcLink is connected with LotAtc %s', 10 )", msg.version)
    local f, error_msg = loadstring(_s, "LotAtcLink")
    if f then
        setfenv(f, lotatcLink.mission_env)
        local success, result = pcall(f)
        if success then 
            env.info("LotAtcLink: success")
        else
            env.info("LotAtcLink: failed")
            env.info( error_msg )
            env.info( result )
        end
    end
end
-----------------------------------------
LCallbacks.command_order = function(env, msg)
    if msg.orders then
        env.info("LotAtcLink: receive order")
        for i, order in pairs(msg.orders) do
            local obj = order.object
            env.info("------")
            env.info("   o" .. obj.group_name )
            env.info("   o" .. obj.unit_name )
            env.info("   o" .. obj.property )
            env.info("   o" .. obj.value )
            local _group = GROUP:FindByName( obj.group_name )
            if _group then
                env.info( "Found!" )

                -- Altitude
                if obj.property == "headingDeg" then
                    env.info( "change heading to " .. obj.value )
                    FromCoord = _group:GetCoordinate()
                    ToCoord = FromCoord:Translate( 1000000, tonumber(obj.value) )
                    RoutePoints = {}
                    RoutePoints[#RoutePoints+1] = FromCoord:WaypointAirFlyOverPoint( "BARO", _group:GetVelocityKMH())
                    RoutePoints[#RoutePoints+1] = ToCoord:WaypointAirFlyOverPoint( "BARO", _group:GetVelocityKMH())
                    RouteTask = _group:TaskRoute( RoutePoints )
                    _group:SetTask(RouteTask, 1 )
                elseif obj.property == "altitude" then
                    env.info( "change altitude to " .. obj.value )
                    Route = _group:CopyRoute()
                    for i, w in pairs(Route) do
                        w:setAltitude(tonumber(obj.value), true)
                    end
                    _group:Route(Route)
                end
            end
        end
    end
end

-----------------------------------------
lotatcLink.registerCallbacks( LCallbacks )
-----------------------------------------
env.info("My LotAtc Link initialized")
