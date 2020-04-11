-- GLOBAL METHODS
function Set (list) -- HOW is a set not native !!!!!!!
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end
--GLOBAL LIST OF PLAYABLE HELICOPTER UNIT

-- Helicopter class
HelicoPlayer = {}


-- Derived class method new
function HelicoPlayer:new(o,unit)
   o = {}
   setmetatable(o, self)
   self.__index = self
   self.unit=unit
   troopInside = {}
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

HelicoPlayerList = {}


chopperNameList = {}

function addRadioF10Options()
	trigger.action.outText("Setting radios " , 5	)
	env.info("Radios ")
	
	--Clean radio command
	missionCommands.removeItem("Transport") -- remove all transport menu
	env.info("Size in radio" .. table.maxn(HelicoPlayerList))
	for k,helicoUnit in ipairs(HelicoPlayerList) do
		env.info("Radios for " .. helicoUnit:getUnit():getName())
		env.info("Radios for " .. helicoUnit:getUnit():getName() .. "is in air" .. tostring(helicoUnit:inAir()))
		if not helicoUnit:inAir() then
			local group = helicoUnit:getGroup()
			local groupID = group:getID()
			env.info("Group " .. group:getName())
			local rootF10 = missionCommands.addSubMenuForGroup(groupID, "Transport")
			local troopMenu = missionCommands.addSubMenuForGroup(groupID, "Troop mouvement", rootF10)
			local loadTroopCommand = missionCommands.addCommandForGroup(groupID, "Embark Troops", troopMenu, nil)
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
		--trigger.action.outText(Group.getName(gp), 10 )
		-- if group is chopper
		if Group.getCategory(gp) == 1 then
			savePlayerChopper(gp)
		end
	end

	--Looking for blue groups
	trigger.action.outText("blue", 2 )
	for i, gp in pairs(coalition.getGroups(2)) do
		--trigger.action.outText(Group.getName(gp), 10)
		-- if group is chopper
		if Group.getCategory(gp) == 1 then
			savePlayerChopper(gp)
		end
	end
end

-- MAIN TEXT
env.setErrorMessageBoxEnabled(false)

trigger.action.outText("Find players", 2)

timer.scheduleFunction(ckeckIfStillAlive, nil, timer.getTime() + 4)

checkingNewPilot()

