USAF_1 = SPAWN:New( "USAF_1" )
:InitRandomizePosition(true,0,0)
	:InitLimit( 2, 500 )
	:SpawnScheduled( 900, .850 )
 
USAF_2 = SPAWN:New( "USAF_2" )
:InitRandomizePosition(true,0,0)
	:InitLimit( 2, 500 )
	:SpawnScheduled( 300, .850 )
 
USAF_3 = SPAWN:New( "USAF_3" ) 
:InitRandomizePosition(true,0,0)
	:InitLimit( 2, 500 )
	:SpawnScheduled( 300, .850 )
 
USAF_4 = SPAWN:New( "USAF_4" )
:InitRandomizePosition(true,0,0)
	:InitLimit( 2, 500 )
	:SpawnScheduled( 600, .850 )

USAF_5 = SPAWN:New( "USAF_5" ) 
:InitRandomizePosition(true,0,0)
	:InitLimit( 2, 500 )
	:SpawnScheduled( 600, .850 )
 
USAF_6 = SPAWN:New( "USAF_6" )
:InitRandomizePosition(true,0,0)
	:InitLimit( 2, 500 )
	:SpawnScheduled( 600, .850 )

USAF_7 = SPAWN:New( "USAF_7" )
:InitRandomizePosition(true,0,0)
	:InitLimit( 1, 500 )
	:SpawnScheduled( 300, .850 )

CONVOY_7 = SPAWN:New( "CONVOY_7" )
:InitRandomizePosition(true,0,0)
	:InitLimit( 6, 500 )
	:SpawnScheduled( 100, .100 )

CONVOY_8 = SPAWN:New( "CONVOY_8" )
:InitRandomizePosition(true,0,0)
	:InitLimit( 6, 980 )
	:SpawnScheduled( 100, .100 )

CONVOY_9 = SPAWN:New( "CONVOY_9" )
:InitRandomizePosition(true,0,0)
	:InitLimit( 7, 500 )
	:SpawnScheduled( 100, .100 )

CONVOY_10 = SPAWN:New( "CONVOY_10" )
:InitRandomizePosition(true,0,0)
	:InitLimit( 6, 500 )
	:SpawnScheduled( 100, .100 )	

CONVOY_11 = SPAWN:New( "CONVOY_11" )
:InitRandomizePosition(true,0,0)
	:InitLimit( 7, 500 )
	:SpawnScheduled( 100, .100 )
  
AWACS_BLUE_OVERLORD = SPAWN:New( "AWACS_BLUE_OVERLORD" ) 
	:InitLimit( 1, 500 )
	:SpawnScheduled( 200, .100 )
	
AWACS_BLUE_OVERLORD2 = SPAWN:New( "AWACS_BLUE_OVERLORD2" ) 
	:InitLimit( 1, 500 )
	:SpawnScheduled( 200, .100 )	
 
TANKERS3B_BLUE = SPAWN:New( "TANKERS3B_BLUE" ) 
	:InitLimit( 1, 500 )
	:SpawnScheduled( 780, .870 )

TANKER135_BLUE = SPAWN:New( "TANKER135_BLUE" ) 
	:InitLimit( 1, 500 )
	:SpawnScheduled( 780, .870 )

TANKER135_BLUE_MPRS = SPAWN:New( "TANKER135_BLUE_MPRS" ) 
	:InitLimit( 1, 500 )
	:SpawnScheduled( 40, .870 )

ESCORT_1 = SPAWN:New( "ESCORT_1" ) 
	:InitLimit( 2, 500 )
	:SpawnScheduled( 120, .870 )

ESCORT_2 = SPAWN:New( "ESCORT_2" ) 
	:InitLimit( 2, 500 )
	:SpawnScheduled( 120, .870 )

ESCORT_3 = SPAWN:New( "ESCORT_3" ) 
	:InitLimit( 2, 500 )
	:SpawnScheduled( 120, .870 )
	
function ScheduleDelete(group)
  SCHEDULER:New( nil, function()
    env.info("Cleaning up: Destroying landed group")
    group:Destroy()
  end, {}, 60)
end

DeleteLanding = EVENTHANDLER:New()
DeleteLanding:HandleEvent( EVENTS.Land )
function DeleteLanding:OnEventLand( EventData )
  ThisGroup = GROUP:FindByName(EventData.IniGroupName)
  GroupUnit = ThisGroup:GetDCSUnit(1)
  FirstUnit = UNIT:Find(GroupUnit)
  if FirstUnit:GetPlayerName() then
    PlayerName = FirstUnit:GetPlayerName()
    env.info(PlayerName .. " has landed")
  else
    env.info("Not a player landed, deleting")
    ScheduleDelete(ThisGroup)
  end
end

