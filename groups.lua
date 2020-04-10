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

-- GLOBAL VARIABLES
infantryGoups = {}


-- LOCAL METHODS
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


--Looking for red groups
trigger.action.outText("red", 2 )
for i, gp in pairs(coalition.getGroups(1)) do
	trigger.action.outText(Group.getName(gp), 10 )
	if isGroupInfantryOnly(gp) then
		trigger.action.outText(" OK   " .. Group.getName(gp), 10 )
		table.insert(infantryGoups,gp)
	else
		trigger.action.outText(" NOPE " .. Group.getName(gp), 10 )
	end
end

--Looking for blue groups
trigger.action.outText("blue", 2 )
for i, gp in pairs(coalition.getGroups(2)) do
	trigger.action.outText(Group.getName(gp), 10)
	if isGroupInfantryOnly(gp) then
		trigger.action.outText(" OK   " .. Group.getName(gp), 10 )
		table.insert(infantryGoups,gp)
	else
		trigger.action.outText(" NOPE " .. Group.getName(gp), 10 )
	end
end

-- checking
for _, group in ipairs(infantryGoups) do
	trigger.action.outText("Saved group " .. Group.getName(group), 15 )
end