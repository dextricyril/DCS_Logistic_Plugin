-- GLOBAL METHODS
function Set (list) -- HOW is a set not native !!!!!!!
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

-- get distance between two units (objects seem to work as well)
function getDistance(unit1, unit2)
	unit1Position = unit1.getPosition(unit1).p
	unit2Position = unit2.getPosition(unit2).p
	xDiff = unit1Position.x - unit2Position.x
	yDiff = unit1Position.y - unit2Position.y
	zDiff = unit1Position.z - unit2Position.z
	return (xDiff^2 + yDiff^2 + zDiff^2)^0.5 
end

-- SAVE GROUP TABLE 
function getTableGroup(groupParam,pointPosition,heading)

    local groupData = {
    ["visible"] = false,
    ["taskSelected"] = true,
    ["route"] = 
    {
    }, -- end of ["route"]
    ["groupId"] = groupParam.getID(groupParam),
    ["tasks"] = 
    {
    }, -- end of ["tasks"]
    ["hidden"] = false,
    ["units"] = 
    {
	
    }, -- end of ["units"]
    ["y"] = pointPosition.y,
    ["x"] = pointPosition.x,
    ["name"] = groupParam.getName(groupParam),
    ["start_time"] = 0,
    ["task"] = "Ground Nothing",
  } -- end of [1]
  
    for index, unit in pairs(groupParam:getUnits()) do
        groupData["units"][index] = {}
        groupData["units"][index]["type"] = groupParam:getUnit(index).getTypeName(unit)
        groupData["units"][index]["y"] = groupParam:getUnit(index).getPosition(unit).p.z
        groupData["units"][index]["x"] = groupParam:getUnit(index).getPosition(unit).p.x
        groupData["units"][index]["transportable"] = 
            {
                ["randomTransportable"] = true,
            } -- end of ["transportable"]
        groupData["units"][index]["unitId"]=groupParam:getUnit(index).getID(unit)
        groupData["units"][index]["skill"] = "Average"  --TODO find and reuse the unit skill level
        groupData["units"][index]["name"] = groupParam:getUnit(index).getName(unit)
        groupData["units"][index]["playerCanDrive"] = true
        groupData["units"][index]["heading"] = heading or 0.28605144170571
        
    end
	return groupData
end

-- GLOBAL VARIABLES
infantryGoups = {}

HelicoPlayerList = {}


chopperNameList = {}

--GLOBAL LIST OF PLAYABLE HELICOPTER UNIT

-- Helicopter class
HelicoPlayer = {}


-- Derived class method new
function HelicoPlayer:new(o,unit)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self.unit=unit
   self.commMenuDone = false
   self.troopInside = {}
   return o
end

-- Derived class method 

function HelicoPlayer:getMaxTroop()
	strType = Unit.getTypeName(self.unit)
	if strType == "Ka-50" then return 0 end
	if strType == "Mi-8MT" then return 24 end
	if strType == "UH-1H" then return 10 end
	return 3 -- SA342
end

function HelicoPlayer:print()
   env.info("The name of the pilot" .. Unit.getName(self.unit))
   env.info("The type of chopper " .. Unit.getTypeName(self.unit) )
   trigger.action.outText("The name of the pilot" .. Unit.getName(self.unit) .. " MAX troop " .. self:getMaxTroop() , 5 )
   trigger.action.outText("The type of chopper " .. Unit.getTypeName(self.unit) , 5)
end

function HelicoPlayer:getUnit()
	return self.unit
end

function HelicoPlayer:getGroup()
	return Unit.getGroup(self.unit)
end

function HelicoPlayer:inAir()
	return Unit.inAir(self.unit)
end

function HelicoPlayer:update()
	env.info("updateHelico")
	if self:inAir() and self.commMenuDone then
		env.info("Changing back comm menu done")
		self.commMenuDone = false
		missionCommands.removeItemForGroup(self:getGroup(),"Transport")
	end
end

function HelicoPlayer:getCommMenuDone()
	env.info("getCommMenu to " .. tostring(self.commMenuDone))
	return self.commMenuDone
end
function HelicoPlayer:setCommMenuDone(bool)
	env.info("setCommMenu to " .. tostring(bool))
	self.commMenuDone = bool
	env.info("check CommMenu " .. tostring(self:getCommMenuDone()))
end

function HelicoPlayer:addUnitInTroop()
	--TODO
end

function HelicoPlayer:getCloseTroopList()
	env.info("In close troop list" )
	local closeTroopList={}
	for index,group in ipairs (infantryGoups) do
		if group:getCoalition() == Unit.getCoalition(self.unit) then
			env.info("In close troop list checking group " .. group:getName())
			local troopUnit = group:getUnit(1)  -- find the first unit in group
			local distance = getDistance(self.unit, troopUnit)
			if distance < 20 then
				env.info("In close troop inserting " .. group:getName())
				table.insert(closeTroopList,group:getName())
			end
		end
	end
	return closeTroopList
end

--ALL HELICO METHODS
function updateAllHelico()
	for index,helo in ipairs (HelicoPlayerList) do
		helo:update()
	end
end

-- LOCAL METHODS FOR INFANTRY CHECKING
function inListTroops(unitType) -- String with unit type
	local troops = Set { "Soldier M249", "Soldier M4", "Stinger comm", "Soldier stinger","Infantry AK","Paratrooper AKS-74",
		"SA-18 Igla comm","SA-18 Igla manpad","SA-18 Igla-S manpad","SA-18 Igla-S comm" }
	if troops[unitType] then
		env.info("YES " .. unitType)
		return true
	end
	env.info("Not found " .. unitType)
	return false
end

function isGroupInfantryOnly(group)
	for index, unit in pairs(group:getUnits()) do
		--trigger.action.outText(Unit.getName(unit) .. "     " .. Unit.getTypeName(unit), 10 )
		env.info(Unit.getTypeName(unit))
		if not inListTroops(Unit.getTypeName(unit)) then
			return false
		end
	end
	return true
end

--TROOP LOAD AND UNLOAD
function troopLoad(args)
	env.info("load troop method")
	for key,_ in ipairs(args) do
		env.info("found args " .. args[key])
	end
	env.info("LOAD GROUP" ..	args[1] .. "...     TODO :)")
	--TODO
	trigger.action.outText("LOAD GROUP" ..	args[1] .. "...     TODO :)",15)
end

-- HELICOPTER FINDER METHODS
function addRadioF10Options()
	trigger.action.outText("Setting radios " , 5	)
	env.info("Radios ")
	
	--Clean radio command
	--missionCommands.removeItem("Transport") -- remove all transport menu
	env.info("Size in radio" .. table.maxn(HelicoPlayerList))
	for k,helicoUnit in ipairs(HelicoPlayerList) do
		env.info("Radios for " .. helicoUnit:getUnit():getName())
		env.info("Radios for " .. helicoUnit:getUnit():getName() .. "is in air" .. tostring(helicoUnit:inAir()) .. "  " .. tostring(helicoUnit:getCommMenuDone()))
		if not helicoUnit:getCommMenuDone() then
			local group = helicoUnit:getGroup()
			local groupID = group:getID()
			env.info("Group " .. group:getName())
			local rootF10 = missionCommands.addSubMenuForGroup(groupID, "Transport")
			local troopMenu = missionCommands.addSubMenuForGroup(groupID, "Troop mouvement", rootF10)
			local listOfTroop = helicoUnit:getCloseTroopList()
			local loadTroopCommandList = {}
			for index,troopGroup in ipairs(listOfTroop) do
				env.info("Adding radio to " ..  group:getName() .."  for  " .. troopGroup)
				loadTroopCommandList[index] = missionCommands.addCommandForGroup(groupID, "Embark ".. troopGroup, troopMenu,troopLoad , {troopGroup})
			end
			helicoUnit:setCommMenuDone(true)
		end
	end
end

function ckeckIfStillAlive()
	timer.scheduleFunction(ckeckIfStillAlive, nil, timer.getTime() + 4)
	--next second, deal with radio
	env.info("Asking for radios")
	timer.scheduleFunction(addRadioF10Options, nil, timer.getTime() + 1)
	
	trigger.action.outText("checking still here", 1)
	env.info("checking still here")
	HelicoPlayerList = {} -- reset helicoPlayerList
	for k,v in ipairs(chopperNameList) do
		env.info("Testing " .. v, 1)
		local unit = Unit.getByName(v)
		if unit == nil then -- if unit not found now remove from list
			trigger.action.outText("DELETING " .. v, 5	)
			env.info("DELETING " .. v)
			table.remove(chopperNameList , k)
		else
			env.info("Adding back to list " .. k .. "    "..v)
			newHelico = HelicoPlayer:new(nil,unit)
			newHelico:print()
			table.insert(HelicoPlayerList,newHelico)
			env.info("Size in check" .. table.maxn(HelicoPlayerList))
		end
	end
end

function savePlayerChopper(group)
	for index, unit in pairs(group:getUnits()) do
		env.info("Checking " .. Unit.getName(unit))
		--Unit.getPlayerName(unit)
		if Unit.getPlayerName(unit) ~= nil then
			local notHere = true
			for _, l in ipairs(chopperNameList) do 
				if l == Unit.getName(unit) then
					notHere = false
				end
			end
			if notHere then
				env.info("ADDING   " .. Unit.getName(unit))
				table.insert(chopperNameList,Unit.getName(unit))
				--Debug chopper object
				env.info("CREATING CHOPPER OBJECT ")
				local helico = HelicoPlayer:new(nil,unit)
				helico:print()
			end
		end
	end
end

function checkingNewPilot()
	timer.scheduleFunction(checkingNewPilot, nil, timer.getTime() + 10)
	--Looking for red helicopter group
	trigger.action.outText("red", 2 )
	for i, gp in pairs(coalition.getGroups(1)) do
		-- if group is chopper
		if Group.getCategory(gp) == 1 then
			savePlayerChopper(gp)
		end
	end

	--Looking for blue groups
	trigger.action.outText("blue", 2 )
	for i, gp in pairs(coalition.getGroups(2)) do
		-- if group is chopper
		if Group.getCategory(gp) == 1 then
			savePlayerChopper(gp)
		end
	end
end

-- LOCAL METHODS TO CHECKS INFANTRY GROUPS
function inListTroops(unitType) -- String with unit type
	local troops = Set { "Soldier M249", "Soldier M4", "Stinger comm", "Soldier stinger","Infantry AK","Paratrooper AKS-74",
		"SA-18 Igla comm","SA-18 Igla manpad","SA-18 Igla-S manpad","SA-18 Igla-S comm" }
	if troops[unitType] then
		env.info("YES " .. unitType)
		return true
	end
	env.info("Not found " .. unitType)
	return false
end

function isGroupInfantryOnly(group)
	for index, unit in pairs(group:getUnits()) do
		--trigger.action.outText(Unit.getName(unit) .. "     " .. Unit.getTypeName(unit), 10 )
		env.info(Unit.getTypeName(unit))
		if not inListTroops(Unit.getTypeName(unit)) then
			return false
		end
	end
	return true
end




--MAIN TEXT

env.setErrorMessageBoxEnabled(false)
trigger.action.outText("Search for groups", 2)

-- MAIN TEXT FOR HELICO FINDER

trigger.action.outText("Find players in helicopter", 2)


-- LOOK FOR TROOP THAT CAN BE CARRIED

--Looking for red groups
trigger.action.outText("red infantry check", 2 )
for i, gp in pairs(coalition.getGroups(1)) do
	if isGroupInfantryOnly(gp) then
		table.insert(infantryGoups,gp)
	end
end

--Looking for blue groups
trigger.action.outText("blue infantry check", 2 )
for i, gp in pairs(coalition.getGroups(2)) do
	trigger.action.outText(Group.getName(gp), 10)
	if isGroupInfantryOnly(gp) then
		table.insert(infantryGoups,gp)
	end
end

-- checking
for _, group in ipairs(infantryGoups) do
	trigger.action.outText("Saved group " .. Group.getName(group) .. " IN COALITION "  .. Group.getCoalition(group), 15 )
	env.info("Saved group " .. Group.getName(group) .. " IN COALITION "  .. Group.getCoalition(group) )
end

timer.scheduleFunction(ckeckIfStillAlive, nil, timer.getTime() + 4)
timer.scheduleFunction(updateAllHelico, nil, timer.getTime() + 3)

checkingNewPilot()