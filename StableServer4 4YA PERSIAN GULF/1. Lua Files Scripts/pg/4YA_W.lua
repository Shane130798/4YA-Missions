


local dcsprotect = {}
dcsprotect.eventHandler = {}

-- Add weapon names here - does partial match i.e CBU to ban all CBUs
dcsprotect.bannedWeapons = {

    "RN-24",
    "RN-28",
	"S-8TsM",
    "M274", 
}

dcsprotect.unitIds = {}

dcsprotect.warnedPlayers = {} -- store players that have been warned

function dcsprotect.queueExplosion(_oldUnit, _banned)

    local _unitName = _oldUnit:getName()
    local _playerName = _oldUnit:getPlayerName()

    timer.scheduleFunction(function()

        local _unit = Unit.getByName(_unitName)

        if _unit and _unit:inAir() then
            -- still flying!!
            -- is it the same bloke?

            if _playerName == _unit:getPlayerName() then

                --EXPLODE

                local _ammo = _unit:getAmmo()

                if _ammo then
                for _, _weapon in pairs(_ammo) do

                    for _, _bannedWeapon in pairs(dcsprotect.bannedWeapons) do
                        if dcsprotect.matches(_weapon.desc.displayName, _bannedWeapon) then

                            local _groupId = dcsprotect.getGroupId(_unit)
                            trigger.action.outTextForGroup(_groupId, "****** WARNING ******* \n\nYou are carrying an illegal loadout. You have been fired upon! \n\nBanned Weapons:\n " .. _weapon.desc.displayName, 25, true)
                                trigger.action.outSoundForGroup(_groupId, "l10n/DEFAULT/dingdong.wav")
                            trigger.action.explosion(_unit:getPoint(), 1000)

                                env.info("Destroyed player ".._playerName.." for weapon ".._weapon.desc.displayName.." unit name ".._unitName)
                            return
                        end
                    end
                end
                end

            end
        end
    end, nil, timer.getTime() + (60 * 5))

    local _groupId = dcsprotect.getGroupId(_oldUnit)
    trigger.action.outTextForGroup(_groupId, "****** WARNING ******* \n\nYou are carrying an illegal loadout. Land IMMEDIATELY and unload with ground crew - Don't jettison bombs - it counts as a launch! \n\n If you fire the illegal weapon you'll be immediately destroyed.\n\n 5 Minutes to comply. \n\nDo not launch them! \n\nBanned Weapons:\n " .. _banned, 20, true)
    trigger.action.outSoundForGroup(_groupId, "l10n/DEFAULT/dingdong.ogg")

end

function dcsprotect.eventHandler:onEvent(_event)

    if _event == nil or _event.initiator == nil then
        --IGNORE
        return
    end

    local _status, _result = pcall(function()

    -- HANDLE WEAPONS WE MISSED
    if _event.id == world.event.S_EVENT_SHOT then
        if (Object.getCategory(_event.initiator) == 1 or Object.getCategory(_event.initiator) == 2)
                and Unit.getPlayerName(_event.initiator) then

            local _unit = _event.initiator

                local _ordnance =  _event.weapon

             --   env.info("Tracking ".._ordnance:getTypeName().." - ".._ordnance:getName())
              --  env.info(mist.utils.tableShow(_event.weapon:getDesc()))

            -- find out what we shot
                if _event.weapon then

                    local _desc = _event.weapon:getDesc()

                    if _desc and _desc.displayName then
                        local _weaponName = _desc.displayName
                for _, _bannedWeapon in pairs(dcsprotect.bannedWeapons) do
                    if dcsprotect.matches(_weaponName, _bannedWeapon) then

                                trigger.action.explosion(_unit:getPoint(), 1000)

                                local _groupId = dcsprotect.getGroupId(_unit)
                                trigger.action.outTextForGroup(_groupId, "****** WARNING ******* \n\nYou have been fired upon for using ILLEGAL WEAPONS - Banned Weapons: " .. _weaponName, 10)


                        -- destroy what was fired
                        _event.weapon:destroy()

                                env.info("Destroyed player for illegal weapon ".. _weaponName)

                        return
                    end
                end
            end
                end

            local _ammo = _unit:getAmmo()

                if _ammo then

            for _, _weapon in pairs(_ammo) do

                for _, _bannedWeapon in pairs(dcsprotect.bannedWeapons) do
                    if dcsprotect.matches(_weapon.desc.displayName, _bannedWeapon) then

                                env.info("Warned player for illegal weapon ".. _weapon.desc.displayName)
                        dcsprotect.queueExplosion(_unit, _weapon.desc.displayName)
                        return
                    end
                end
            end
        end
            end
    elseif _event.id == world.event.S_EVENT_TAKEOFF then
        if (Object.getCategory(_event.initiator) == 1 or Object.getCategory(_event.initiator) == 2)
                and Unit.getPlayerName(_event.initiator) then

            -- WARN when we takeoff and start timer for explosion

            local _unit = _event.initiator
            local _ammo = _unit:getAmmo()

                if _ammo then
            for _, _weapon in pairs(_ammo) do

                for _, _bannedWeapon in pairs(dcsprotect.bannedWeapons) do
                    if dcsprotect.matches(_weapon.desc.displayName, _bannedWeapon) then
                                env.info("Warned player for illegal weapon ".. _weapon.desc.displayName)

                        dcsprotect.queueExplosion(_unit, _weapon.desc.displayName)
                        return
                    end
                end
            end
                end
            -- find out what we shot

        end
        elseif (_event.id == 15 ) and _event.initiator ~= nil and (Object.getCategory(_event.initiator) == 1 or Object.getCategory(_event.initiator) == 2)
            and _event.initiator:getPlayerName() ~= nil then
        --event birth

        -- env.info("Player entered unit")
        local _unit = _event.initiator

           -- if not dcsprotect.unitIds[_unit:getID()] then
            dcsprotect.unitIds[_unit:getID()] = true

            --  env.info("Adding F10 for ".._unit:getName())
            dcsprotect.addF10MenuOptions(_unit)
         --   end

            local _list = ""
            for _, _bannedWeapon in pairs(dcsprotect.bannedWeapons) do
               _list  = _list .. "\n".._bannedWeapon
        end

            -- warning
            local _groupId = dcsprotect.getGroupId(_unit)
            trigger.action.outTextForGroup(_groupId, "[4YA] TRAINING PERSIAN GULF PVE : Short Mission Briefing\n\ \n\Capture all enemy bases before the time runs out! \n\Server will restart when all bases are friendly. \n\Available: SRS, CTLD, Combined arms & Roadbases\n\ \n\Use radio menu & F10 to check tacans, waypoints, jtac and more\n\SRS main channel 305AM. Join us on discord! Read the briefing for more info Lalt+B!\n\Banned weapons:" .. _list, 15, true)

        end

    end)

    if (not _status) then
        env.error(string.format("Error with Weapon Protection: %s", _result))
    end
end

function dcsprotect.validateLoadout(_unitName)

    local _status, _result = pcall(function()
    local _unit = Unit.getByName(_unitName)

    local _groupId = dcsprotect.getGroupId(_unit)

    local _unit = _unit
    local _ammo = _unit:getAmmo()

    local _banned = ""

    if _ammo then
    for _, _weapon in pairs(_ammo) do

        env.info("Loaded Weapons: ".. _weapon.desc.displayName)

        for _, _bannedWeapon in pairs(dcsprotect.bannedWeapons) do
            if dcsprotect.matches(_weapon.desc.displayName, _bannedWeapon) then

                _banned = _banned .. "\n" .. _weapon.desc.displayName
            end
        end
    end
    end

    if _banned == "" then
        trigger.action.outTextForGroup(_groupId, "**** VALID LOADOUT ****\n\nYour loadout is valid! Have a good flight!", 20, false)
    else
        trigger.action.outTextForGroup(_groupId, "****** WARNING ******* \n\nYou are carrying an illegal loadout. Land IMMEDIATELY and unload - Don't jettison bombs - as it counts as a launch! \n\n If you fire the illegal weapon you'll be immediately destroyed \n\n If you take off with your illegal loadout, you must land again IMMEDIATELY and unload the banned weapons - if you don't comply within 5 minutes, you will be fired upon! \n\nBanned Weapons:\n " .. _banned, 30, true)
    end

    end)

    if (not _status) then
        env.error(string.format("Error with Weapon Protection F10: %s", _result))
    end
end

function dcsprotect.matches(weapon, banned)

    banned = string.lower(banned)
    weapon = string.lower(weapon)

    if string.find(weapon, banned, 1, true) then
        -- check for partial match of AIM-7M also matching the AIM-7MH
        if string.find(weapon, banned.."h", 1, true) then
            env.info("Weapon "..weapon.." matches "..banned..", but also matches "..banned.."h".."... Ignoring")
            return false
        else
            env.info("Illegal Weapon "..weapon.." matches "..banned)
        return true
    end
    end

    return false

end

function dcsprotect.addF10MenuOptions(_unit)

    local _groupId = dcsprotect.getGroupId(_unit)


    missionCommands.removeItemForGroup(_groupId, {"Validate Loadout"})

    missionCommands.addCommandForGroup(_groupId, "Validate Loadout", nil, dcsprotect.validateLoadout, _unit:getName())

    env.info("Added Loadout Menu for ".._unit:getName())

end

function dcsprotect.getGroupId(_unit)

    local _unitDB = mist.DBs.unitsById[tonumber(_unit:getID())]
    if _unitDB ~= nil and _unitDB.groupId then
        return _unitDB.groupId
    end

    return nil
end

world.addEventHandler(dcsprotect.eventHandler)

