-- GLOBAL METHODS
function Set (list) -- HOW is a set not native !!!!!!!
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end
--GLOBAL LIST OF PLAYABLE HELICOPTER UNIT

chopperList = {}

function ckeckIfStillAlive()
	timer.scheduleFunction(ckeckIfStillAlive, nil, timer.getTime() + 4)
	trigger.action.outText("checking still here", 1)
	
	for k,v in ipairs(chopperList) do
		env.info("Testing " .. v, 1)
		if Unit.getByName(v) == nil then -- if unit not found now remove from list
			trigger.action.outText("DELETING " .. v, 5	)
			env.info("DELETING " .. v, 1)
			table.remove(chopperList , k)
		end
	end
end

function savePlayerChopper(group)
	for index, unit in pairs(group:getUnits()) do
		env.info("Checking " .. Unit.getName(unit))
		--Unit.getPlayerName(unit)
		if Unit.getPlayerName(unit) ~= nil then
			local notHere = true
			for _, l in ipairs(chopperList) do 
				if l == Unit.getName(unit) then
					notHere = false
				end
			end
			if notHere then
				env.info("ADDING   " .. Unit.getName(unit))
				table.insert(chopperList,Unit.getName(unit))
			end
		end
	end
end

function checkingNewPilot()
	timer.scheduleFunction(checkingNewPilot, nil, timer.getTime() + 10)
	--Looking for red helicopter group
	trigger.action.outText("red", 2 )
	for i, gp in pairs(coalition.getGroups(1)) do
		trigger.action.outText(Group.getName(gp), 10 )
		-- if group is chopper
		if Group.getCategory(gp) == 1 then
			savePlayerChopper(gp)
		end
	end

	--Looking for blue groups
	trigger.action.outText("blue", 2 )
	for i, gp in pairs(coalition.getGroups(2)) do
		trigger.action.outText(Group.getName(gp), 10)
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

