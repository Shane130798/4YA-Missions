--[[
Here is a simple example to use with lotatcMissionServer
]]--

env.info("initializing My LotAtc Link example...")
local LCallbacks = {}
--------------------------------------------------------------
-- LotAtc Link mission script example file
-- Copyright RBorn Software
-- Author: DArt - LotAtc
-- You can modify and adapt it
--------------------------------------------------------------
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
--------------------------------------------------------------
LCallbacks.command_order = function(env, msg)
    if msg.orders then
        env.info("LotAtcLink: receive order")
        for i, order in pairs(msg.orders) do
            env.info("------ Treat order")
            env.info("   o " .. order.order_name )
            local _group = nil
            if order.group_name then
                env.info("   o " .. order.group_name )
                env.info("   o " .. order.unit_name )
                _group = GROUP:FindByName( order.group_name )
            end
            if _group and (_group:GetPlayerCount() == 0 ) then
                --env.info( "Found!" )
                if order.order_name == "object" then
                    loe_order(env,order, _group )
                elseif order.order_name == "delete" then
                    env.info("   o delete")
                    _group:Destroy(true)
                elseif order.order_name == "command" then
                    loe_command(env,order, _group )
                end
            end
        end
    end
end

--------------------------------------------------------------
loe_order = function(env, order, _group)
    env.info("   o " .. order.property )
    
    if order.property == "headingDeg" then
        loe_order_headingDeg(env, order, _group)
    elseif order.property == "altitude" then
        loe_order_altitude(env, order, _group)
    elseif order.property == "position" then
        loe_order_position(env, order, _group)
    else
        env.info("-- Not yet supported --")
    end
end

--------------------------------------------------------------
loe_order_headingDeg = function( env, order, _group )
    env.info( "change heading to " .. order.value )
    FromCoord = _group:GetCoordinate()
    ToCoord = FromCoord:Translate( 1000000, tonumber(order.value) )
    RoutePoints = {}
    RoutePoints[#RoutePoints+1] = FromCoord:WaypointAirFlyOverPoint( "BARO", _group:GetVelocityKMH())
    RoutePoints[#RoutePoints+1] = ToCoord:WaypointAirFlyOverPoint( "BARO", _group:GetVelocityKMH())
    RouteTask = _group:TaskRoute( RoutePoints )
    _group:SetTask(RouteTask, 1 )
end

--------------------------------------------------------------
loe_order_altitude = function( env, order, _group )
    env.info( "change altitude to " .. order.value )
    Route = _group:CopyRoute()
    for i, w in pairs(Route) do
        w.alt = tonumber(order.value)
    end
    _group:Route(Route)
end

--------------------------------------------------------------
loe_order_position = function( env, order, _group )
    env.info( "   --> change position " .. order.value.latitude .. " " .. order.value.longitude )
    FromCoord = _group:GetCoordinate()
    env.info( FromCoord )
    _pos = COORDINATE:NewFromLLDD(order.value.latitude, order.value.longitude)--, FromCoord:GetPointVec2():GetAlt())
    _name = _group.GroupName
    _group:Destroy(true)
    _newgroup = SPAWN:New(_name):SpawnFromVec3(_pos:GetVec3())
end
--------------------------------------------------------------
loe_command = function(env, order, _group)
    env.info("   o " .. order.property )
    
    if order.property == "rtb" then
        loe_command_rtb(env, order, _group)
    elseif order.property == "cap" then
        loe_command_cap(env, order, _group)
    else
        env.info("-- Not yet supported --")
    end
end

--------------------------------------------------------------
loe_command_rtb = function( env, order, _group )
    env.info( "RTB on" .. order.value )
    local _airbase = AIRBASE:FindByName(order.value)
    if _airbase then
        FromCoord = _group:GetCoordinate()
        
        local AirbasePointVec2 = _airbase:GetPointVec2()
        local AirbaseAirPoint = AirbasePointVec2:WaypointAir(
          POINT_VEC3.RoutePointAltType.BARO,
          "Land",
          "Landing", 
          _group:GetUnit(1):GetDesc().speedMax
        )
        
        AirbaseAirPoint["airdromeId"] = _airbase:GetID()
        AirbaseAirPoint["speed_locked"] = true

        RoutePoints = {}
        RoutePoints[#RoutePoints+1] = FromCoord:WaypointAirFlyOverPoint( "BARO", _group:GetVelocityKMH())
        RoutePoints[#RoutePoints+1] = AirbaseAirPoint
        RouteTask = _group:TaskRoute( RoutePoints )
        _group:SetTask(RouteTask, 1 )
    end
end

--------------------------------------------------------------
loe_command_cap = function( env, order, _group )
    env.info( "CAP on")
    ZoneA = ZONE_RADIUS:New( "Zone A".. _group.GroupName, _group:GetVec2(), 30000 )
    AICapZone = AI_CAP_ZONE:New( ZoneA, 500, 1000, 500, 600 )
    AICapZone:SetControllable( _group )
    AICapZone:SetEngageZone( ZoneA ) -- Set the Engage Zone. The AI will only engage when the bogeys are within the CapEngageZone.

    AICapZone:__Start( 1 ) -- They should statup, and start patrolling in the PatrolZone.
end
--------------------------------------------------------------
lotatcLink.registerCallbacks( LCallbacks )
env.info("My LotAtc Link initialized")
