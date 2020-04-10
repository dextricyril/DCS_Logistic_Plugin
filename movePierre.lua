env.setErrorMessageBoxEnabled(false)
trigger.action.outText("Pierre :)",2)

function getDistance(unit1, unit2)
	unit1Position = unit1.getPosition(unit1).p
	unit2Position = unit2.getPosition(unit2).p
	xDiff = unit1Position.x - unit2Position.x
	yDiff = unit1Position.y - unit2Position.y
	zDiff = unit1Position.z - unit2Position.z
	return (xDiff^2 + yDiff^2 + zDiff^2)^0.5 
end

pierreUnit = Unit.getByName("pierre") --408m to MI8
pierreGroup = Unit.getGroup(pierreUnit)

pilotMI8Unit = Unit.getByName("pilotMI8")
distance = getDistance(pilotMI8Unit,pierreUnit)
trigger.action.outText("Distance: " .. distance , 15)

staticCargo = StaticObject.getByName("Cargo1")
distance = getDistance(pilotMI8Unit,staticCargo)
trigger.action.outText("Distance to cargo: " .. distance , 15)


for index, unit in pairs(pierreGroup:getUnits()) do
	--trigger.action.outText(Unit.getName(unit) .. "     " .. Unit.getTypeName(unit), 10 )
	env.info(index .. " LOG OUT " ..Unit.getName(unit))
	assetUnitPosition =  pierreGroup:getUnit(index).getPosition(unit).p
	trigger.action.outText("Pierre x" .. assetUnitPosition.x, 15)
	trigger.action.outText("Pierre y" .. assetUnitPosition.y, 15)
end
-- assetUnitPosition		= pierreGroup:getUnit(1).p
-- trigger.action.outText("Pierre x" .. assetUnitPosition.x, 15)
-- trigger.action.outText("Pierre y" .. assetUnitPosition.y, 15)