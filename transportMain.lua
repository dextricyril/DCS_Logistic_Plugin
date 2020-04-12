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
	["country"] = groupParam:getUnit(1):getCountry()
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
		env.info("Allow search again " .. self:getName())
		trigger.action.outText("Allow search again " .. self:getName(),3)
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

function HelicoPlayer:canEmbarkTroop(tableData)
	env.info("canEmbarkTroop")
	local currentNumberOfTroop = 0
	for _,troop in ipairs (self.troopInside) do -- troop is formated as groupData
		currentNumberOfTroop = currentNumberOfTroop + table.maxn(troop["units"])
	end
	env.info("currentNumberOfTroop " .. currentNumberOfTroop)
	-- if the current number of troops plus new group can be carried by this helicopter
	if (currentNumberOfTroop + table.maxn(tableData["units"])) <= self:getMaxTroop() 
	then 
		env.info("canEmbarkTroop end true")
		return true
	else
		env.info("canEmbarkTroop end false")
		trigger.action.outTextForGroup(self:getGroup():getID(),"Cannot carry troop, Overcapacity",15)
		return false
	end
	
end

function HelicoPlayer:embarkTroop(tableData)
	env.info("embarkTroop")
	table.insert(self.troopInside, tableData)
	self:setCommMenuDone(false)
	env.info("check " ..self.troopInside[1]["name"])
	env.info("embarkTroop end")
end

function HelicoPlayer:checkTroopInside()
	for _,troop in ipairs (self.troopInside) do -- troop is formated as groupData
		env.info("Carrying group: " .. troop["name"])
		trigger.action.outText("Carrying group: " .. troop["name"],10)
	end
end

function HelicoPlayer:setDisembarkingTroopsCoordinates()
	env.info("setDisembarkingTroopsCoordinates")
	helicoCoordinates = self:getUnit():getPosition().p
	env.info("setDisembarkingTroopsCoordinates " .. helicoCoordinates.x .."  Z  " .. helicoCoordinates.z)
	for indexGroup,troop in ipairs (self.troopInside) do -- troop is formated as groupData
		env.info("Group: " .. troop["name"])
		troop["y"] = helicoCoordinates.z
		troop["x"] = helicoCoordinates.x
		--trigger.action.outText("Carrying group: " .. troop["name"],10)
		for indexUnit,soldier in ipairs (troop["units"]) do
			env.info("SoldiersetDise " .. soldier["name"])
			--Give the unit a delta to not spawn into each other
			coordZ = 3 +  indexUnit + helicoCoordinates.z
			coordX = 3 + indexGroup  +helicoCoordinates.x
			soldier["y"] = coordZ
			soldier["x"] = coordX
		end
	end
	env.info("setDisembarkingTroopsCoordinates end")
end

function HelicoPlayer:disembarkTroop()
	env.info("spawn troop")
	self:setCommMenuDone(false)
	self:setDisembarkingTroopsCoordinates()
	for _,troop in ipairs (self.troopInside) do -- troop is formated as groupData
		local countryId = troop["country"]
		local groupCategory = Group.Category.GROUND
		newGroup = coalition.addGroup(countryId,groupCategory,troop)
		env.info("Disembarking : " .. troop["name"])
		env.info("DisembarkingCheck : " .. newGroup:getName())
		trigger.action.outText("Disembarking: " .. troop["name"],10)
	end
	--empty troop list
	self.troopInside = {}
	self:setCommMenuDone(false)
end

function HelicoPlayer:hasTroopInside()
	return (table.maxn(self.troopInside)>0)
end

function HelicoPlayer:getNearbyGroups()
	env.info("getNearbyGroups")
	local nearbyGroups = {
		["troops"] = {},
		["groundUnits"] = {},
	}
	
	local coalitionNumber = self.unitObj:getCoalition()
	env.info("getNearbyGroups " .. self.unitObj:getCoalition())
	
	--trigger.action.outText("red infantry check", 2 )
	for i, group in ipairs(coalition.getGroups(coalitionNumber)) do
		env.info("Working on " .. group:getName())
		groupUnit = group:getUnit(1)
		env.info("Working on " .. groupUnit:getName())
		local distance = getDistance(self.unitObj, groupUnit)
		if distance < 30 then
			env.info("group is close " .. group:getName())
			if (isGroupInfantryOnly(group) and distance < 16) then
				env.info("infantry is close " .. group:getName())
				table.insert(nearbyGroups["troops"], group)
			elseif( group:getCategory() == 2 ) --if ground vehicule
			then
				table.insert(nearbyGroups["groundUnits"], group)
				env.info("close unit " .. group:getName())
			end
		end
	end
	env.info("getNearbyGroups before checking")

	local listOfTroop = nearbyGroups["troops"]
	-- local loadTroopCommandList = {}
	for index,troopGroup in ipairs(listOfTroop) do
		env.info(" nearby troop " .. troopGroup:getName())
		trigger.action.outText(" nearby troop : " .. troopGroup:getName(),5)
	end
	
	return nearbyGroups
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

function getHelicoPlayerByName(name)
	env.info("getHelicoPlayerByName " .. table.maxn(HelicoPlayerList) .. "   " .. name)

	for index,helo in ipairs (HelicoPlayerList) do
		env.info("for Loop " .. helo:getName())
		if name == helo:getName() then
			return helo
		end
	end
	env.warning("Not found getHelicoPlayerByName:   " .. name)
	return nil
end


--TROOP LOAD AND UNLOAD
function troopLoad(args)
	env.info("load troop method")
	for key,_ in ipairs(args) do
		env.info("found args " .. args[key])
	end
	local helicoPlayerName = args[1]
	local helicoPlayer = getHelicoPlayerByName(helicoPlayerName)
	local troopGroupName = args[2]
	if (troopGroupName == nil) then
		env.info("Not up to date troop")
		refreshCommMenu(helicoPlayerName)
	end
	--env.info("LOAD GROUP" ..	troopGroupName .. "...     TODO :)")
	--TODO
	local troopGroup = Group.getByName(troopGroupName)
	if troopGroup == nil then
		trigger.action.outText("TROOPS NOT FOUND " .. troopGroupName , 15)
		env.warning("troop not found " .. troopGroupName)
		return
	end
	env.info("troopDataTable")
	local troopDataTable = getTableGroup(troopGroup,helicoPlayer:getUnit():getPosition().p,nil) -- replace nil by heading would be cool
	env.info("troopDataTable " .. troopDataTable["name"] .. troopDataTable["country"])
	if helicoPlayer:canEmbarkTroop(troopDataTable) then
		helicoPlayer:embarkTroop(troopDataTable)
		trigger.action.outText(troopGroupName .. " is now inside " .. helicoPlayerName, 15)
		troopGroup.destroy(troopGroup)
		helicoPlayer:setCommMenuDone(false)
	end
	env.info("End troop load")
end

function checkTroopHelicoPlayer(args)
	local helicoPlayerName = args[1]
	local helicoPlayer = getHelicoPlayerByName(helicoPlayerName)
	helicoPlayer:checkTroopInside()
end

function disembarkTroopHelicoPlayer(args)
	local helicoPlayerName = args[1]
	local helicoPlayer = getHelicoPlayerByName(helicoPlayerName)
	helicoPlayer:disembarkTroop()
	env.info("disembarking end")
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
	--Desimbarking troop
	env.info("Disembark troop ")
	if (helicoPlayer:hasTroopInside()) then
		missionCommands.addCommandForGroup(groupID, "check troop ", troopMenu,checkTroopHelicoPlayer , {helicoPlayer:getName()})
		missionCommands.addCommandForGroup(groupID, "Disembark troop ", troopMenu,disembarkTroopHelicoPlayer , {helicoPlayer:getName()})
	end
	--Embarking troop
	local listOfTroop = helicoPlayer:getNearbyGroups()["troops"]
	local loadTroopCommandList = {}
	for index,troopGroup in ipairs(listOfTroop) do
		env.info("Adding radio to " ..  group:getName() .."  for  " .. troopGroup:getName())
		trigger.action.outText("Can carry troop: " .. troopGroup:getName(),5)
		loadTroopCommandList[index] = missionCommands.addCommandForGroup(groupID, "Embark ".. troopGroup:getName(), troopMenu,troopLoad , {helicoPlayer:getName() , troopGroup:getName()})
	end
	--TODO ADD CARGO
	missionCommands.addCommandForGroup(groupID, "Refresh", rootF10, refreshCommMenu , {helicoPlayer:getName()})
	
	env.info("addRadioF10OptionsForGroup finnish")
end

function refreshCommMenu(args)
	--env.info("refreshCommMenu")
	helicoPlayerName = args[1]
	helicoPlayer = getHelicoPlayerByName(helicoPlayerName)
	helicoPlayer:setCommMenuDone(false)
	--env.info("refreshCommMenu complete")
end

-- HELICOPTER FINDER METHODS
function savePlayerChopper(group)
	for index, unit in pairs(group:getUnits()) do
		--env.info("Checking " .. Unit.getName(unit))
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
	env.info("isGroupInfantryOnly")
	for index, unit in pairs(group:getUnits()) do
		--trigger.action.outText(Unit.getName(unit) .. "     " .. Unit.getTypeName(unit), 10 )
		env.info(Unit.getTypeName(unit))
		if not inListTroops(Unit.getTypeName(unit)) then
			env.info("isGroupInfantryOnly false")
			return false
		end
	end
	env.info("isGroupInfantryOnly true")
	return true
end




--MAIN TEXT

env.setErrorMessageBoxEnabled(false)
trigger.action.outText("Search for groups", 2)

-- MAIN TEXT FOR HELICO FINDER

trigger.action.outText("Find players in helicopter", 2)

timer.scheduleFunction(updateAllHelico, nil, timer.getTime() + 3)

checkingNewPilot()