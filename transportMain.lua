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


--GLOBAL LIST OF PLAYABLE HELICOPTER UNIT

-- Helicopter class
HelicoPlayer = {}


-- Derived class method new
function HelicoPlayer:new(o,unitObj)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self.unitObj=unitObj
   self.name = Unit.getName(unitObj)
   self.commMenuDone = false
   self.troopInside = {}
   return o
end

-- Derived class method 

function HelicoPlayer:getMaxTroop()
	strType = Unit.getTypeName(self.unitObj)
	if strType == "Ka-50" then return 0 end
	if strType == "Mi-8MT" then return 24 end
	if strType == "UH-1H" then return 10 end
	return 3 -- SA342
end

function HelicoPlayer:print()
   env.info("The name of the pilot" .. Unit.getName(self.unitObj))
   env.info("The type of chopper " .. Unit.getTypeName(self.unitObj) )
   trigger.action.outText("The name of the pilot" .. Unit.getName(self.unitObj) .. " MAX troop " .. self:getMaxTroop() , 5 )
   trigger.action.outText("The type of chopper " .. Unit.getTypeName(self.unitObj) , 5)
end

function HelicoPlayer:getUnit()
	return self.unitObj
end

function HelicoPlayer:getName()
	return self.name
end

function HelicoPlayer:getGroup()
	return Unit.getGroup(self.unitObj)
end

function HelicoPlayer:inAir()
	return Unit.inAir(self.unitObj)
end

function HelicoPlayer:update()
	env.info("updateHelico")
	env.info("updateHelico" .. tostring(self:inAir()))
	if not self:inAir() and not self.commMenuDone then
		env.info("Look for f10 option" .. self:getName())
		addRadioF10OptionsForGroup(self)
		self:setCommMenuDone(true)
	end
	if self:inAir() then --got airborne so allow search again
		env.info("got airborne so allow search again " .. self:getName())
		trigger.action.outText("got airborne so allow search again " .. self:getName(),3)
		self:setCommMenuDone(false)
	end
	env.info("update complete " .. self:getName())
end

function HelicoPlayer:stillExists()
	env.info("stillExists")
	env.info("stillExists " .. self.name)
	local testUnitPresent = Unit.getByName(self.name)
	env.info("stillExists test " .. tostring(testUnitPresent))
	if testUnitPresent == nil then
		return false
	end
	return true
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
		if group:getCoalition() == Unit.getCoalition(self.unitObj) then
			env.info("In close troop list checking group " .. group:getName())
			local troopUnit = group:getUnit(1)  -- find the first unit in group
			local distance = getDistance(self.unitObj, troopUnit)
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
	env.info("updateAllHelico " .. table.maxn(HelicoPlayerList))
	timer.scheduleFunction(updateAllHelico, nil, timer.getTime() + 3)
	--DELETE PREVIOUSLY EXISTING HELO
	local listOfMissingHelo = {}
	for index,helo in ipairs (HelicoPlayerList) do
		env.info("for Loop")
		if not helo:stillExists() then
			env.info("REMOVING A PLAYER HELO")
			trigger.action.outText("REMOVING A PLAYER HELO " .. helo:getName(), 10)
			table.insert(listOfMissingHelo, index)
		end
	end
	for _,indexOfHelicoPlayerList in ipairs (listOfMissingHelo) do
		table.remove(HelicoPlayerList,indexOfHelicoPlayerList)
	end
	--DO UPDATE
	for index,helo in ipairs (HelicoPlayerList) do
		env.info("update for Loop")
		helo:update()
	end
end

function checkIfHelicoInList(name)
	env.info("checkIfHelicoInList " .. table.maxn(HelicoPlayerList) .. "   " .. name)
	

	for index,helo in ipairs (HelicoPlayerList) do
		
		env.info("for Loop " .. helo:getName())
		if name == helo:getName() then
			return true
		end
	end
	return false
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

-- SET RADIO FOR THE GIVEN HelicoPlayer
function addRadioF10OptionsForGroup(helicoPlayer)
	env.info("addRadioF10OptionsForGroup ")
	env.info("addRadioF10OptionsForGroup " .. helicoPlayer:getName())
	local group = helicoPlayer:getGroup()
	local groupID = group:getID()
	missionCommands.removeItemForGroup(groupID,"Transport") -- remove all transport menu for this group
	env.info("Group " .. group:getName())
	local rootF10 = missionCommands.addSubMenuForGroup(groupID, "Transport")
	local troopMenu = missionCommands.addSubMenuForGroup(groupID, "Troop mouvement", rootF10)
	local listOfTroop = helicoPlayer:getCloseTroopList()
	local loadTroopCommandList = {}
	for index,troopGroup in ipairs(listOfTroop) do
		env.info("Adding radio to " ..  group:getName() .."  for  " .. troopGroup)
		env.info("Can carry troop: " .. troopGroup)
		loadTroopCommandList[index] = missionCommands.addCommandForGroup(groupID, "Embark ".. troopGroup, troopMenu,troopLoad , {troopGroup})
	end
	env.info("addRadioF10OptionsForGroup finnish")
end
-- HELICOPTER FINDER METHODS
function savePlayerChopper(group)
	for index, unit in pairs(group:getUnits()) do
		env.info("Checking " .. Unit.getName(unit))
		--Unit.getPlayerName(unit)
		if Unit.getPlayerName(unit) ~= nil then
			if not checkIfHelicoInList(Unit.getName(unit)) then
				env.info("ADDING   " .. Unit.getName(unit))
				trigger.action.outText("ADDING   " .. Unit.getName(unit), 5)
				newHelico = HelicoPlayer:new(nil,unit)
				newHelico:print()
				table.insert(HelicoPlayerList,newHelico)
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

timer.scheduleFunction(updateAllHelico, nil, timer.getTime() + 3)

checkingNewPilot()