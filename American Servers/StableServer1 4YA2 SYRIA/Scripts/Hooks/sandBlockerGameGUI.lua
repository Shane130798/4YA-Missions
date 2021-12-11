net.log("SANDBLOCKER INFO: loading started...")

--sandwich-SlotBlocker prototype
local currentDir = lfs.writedir()

local SB = {}	--DCS
local ref =	{}	--REF
local mizName	--mission name dedicates the configFile Being loaded...

local DEBUG = false

--SCRIPT GLOBAL VALUES

if DEBUG then
	net.log("SANDBLOCKER INFO: [DEBUG] currentDir > "..currentDir)
end

--INDEPENDANT FUNCTIONS
local function file_exists(file)
	local f = io.open(file, "rb")
	
	if f then 
		f:close()
		return true 
	else
		return false
	end
end

local function splitStr (inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

--[[
local function printMap(table)	--beautiful magic
	for key, value in pairs(table) do

		if type(value) == type({{}}) then
			print(key)
			SB.printMap(value)
		else
			print('\t', key, value)
		end 
	end
end

local function print_ref()
	print("\nREF:")
	print("=======================================")

	printMap(ref)

	print("=======================================")
end
]]--

--EXEC
local function loadKey(file)	--add DEBUG, exact key name + ?path?
	if file_exists(file) == true then
		net.log("SANDBLOCKER INFO: loading key")

		local f = io.open(file, "r")
		local temp = f:read("*a")
		f:close()

		ref = net.json2lua(temp)
		net.log("SANDBLOCKER INFO: ... DONE!")
	else
		net.log("SANDBLOCKER ERROR: couldn't find the key!")
	end
end

function SB.onMissionLoadEnd()
	
	if DEBUG then
		net.log("SANDBLOCKER INFO: [DEBUG] onMissionLoadEnd, fetching mission name...")
	end

	mizName = DCS.getMissionName()

	if DEBUG then
		net.log("SANDBLOCKER INFO: [DEBUG] onMissionLoadEnd, fetching complete!")
		net.log("SANDBLOCKER INFO: [DEBUG] onMissionLoadEnd mission name: "..mizName)
	end
end

function SB.onSimulationStart()
	-- 3 blocks followed by _SBconfig
	local cutMizName = splitStr(mizName, '_')

	if DEBUG then
		net.log("SANDBLOCKER INFO: [DEBUG] 1: "..cutMizName[1]..", 2: "..cutMizName[2]..", 3: "..cutMizName[3].."_SBconfig.json")
	end

	local dataFile = currentDir.."Scripts\\Hooks\\SBconfigs\\"..cutMizName[1].."_"..cutMizName[2].."_"..cutMizName[3].."_SBconfig.json"
	
	loadKey(dataFile)
	
	if DEBUG then
		net.log("SANDBLOCKER INFO: [DEBUG] onSimulationStart, loading complete!")
	end
end

--WHILE GAME CALLBACKS
function SB.onPlayerTryChangeSlot(playerId, side, slotId)	--side 1 = Red, side 2 = Blue, side 3 = Neutral
	if DEBUG then
		net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTryChangeSlot() => START!")
	end
	
	--get rid of multislot ID's
	if string.find(tostring(slotId), "_") then
		local temp = splitStr(slotId, "_")
		slotId = temp[1]
	end

	if DEBUG then
		net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTryChangeSlot() => GOT RID OF MULTISLOT ID")
	end

	--fetch slot name
	local slotName = DCS.getUnitProperty(slotId, DCS.UNIT_GROUPNAME)

	if DEBUG then
		net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTryChangeSlot() => GOT GROUPNAME")
	end

	--============ERROR=============--
	
	if DEBUG then
		net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTryChangeSlot() => MATCHING STRING!")
		net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTryChangeSlot() => slotName (raw): "..slotName)
	end

	local slotAirfield = string.match(slotName, '^%d+ USAF_([^ ]+) ') or string.match(slotName, '^%d+ ([^ ]+) ') --wizzurd [DEBUG] => SPECIFIC TO ONLY 4YA!

	if DEBUG then
		net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTryChangeSlot() => slotAirfield, slotName : "..slotAirfield..", "..slotName)
	end

	if slotAirfield == nil or ref["BLOCKER"][slotAirfield] == nil then
		net.log("SANDBLOCKER ERROR: "..slotAirfield.." does NOT exist in the configuration!")
		return	--DO NOT RETURN TRUE (except for 1st of april)
	end

	--check with "CURRENT"
	if side == 1 then
		if DEBUG then
			net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTryChangeSlot() => SIDE 1")
		end
		
		if ref["BLOCKER"][slotAirfield] == "RED" then return
		else return false end
	end
	if side == 2 then
		if DEBUG then
			net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTryChangeSlot() => SIDE 2")
		end
		
		if ref["BLOCKER"][slotAirfield] == "BLUE" then return
		else return false end
	end
	if side == 3 then
		if DEBUG then
			net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTryChangeSlot() => SIDE 3")
		end
		
		if ref["BLOCKER"][slotAirfield] == "NEUTRAL" then return
		else return false end
	end
end

function SB.onPlayerTrySendChat(playerId, message, all)
	if DEBUG then
		net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTrySendChat, playerId: "..playerId..", message: "..message)
	end

	--ID 1 = server / net
	if playerId == 1 and string.find(message, "SB ") then
		if DEBUG then
			net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTrySendChat, this is a SB command!")
		end
		
		--example switch message: "SB KRASNODAR_CTR BLUE"
		local newCommand = splitStr(message, "%s")

		
		if DEBUG then
			net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTrySendChat, newCommand 1, 2, 3 :"..newCommand[1]..", "..newCommand[2]..", "..newCommand[3])
			net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTrySendChat, newCommand = "..newCommand[2]..", "..newCommand[3])
		end
		--BLOCKER, AIRFIELD, COALITION
		if ref["BLOCKER"] then
			ref["BLOCKER"][newCommand[2]] = newCommand[3]
		end

		return ""
	
	else
		if DEBUG then
			net.log("SANDBLOCKER INFO: [DEBUG] onPlayerTrySendChat, this is not a SB command!")
		end
	end
	--RETURN TO OVERIDE, RETURN "" TO FILTER MESSAGE!
end

DCS.setUserCallbacks(SB)
net.log("SANDBLOCKER INFO: Sandblocker loading complete!")