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


function getTableGroup(groupParam,pointPosition)

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
        -- [1] = 
        -- {
            -- ["type"] = "LAV-25",
            -- ["transportable"] = 
            -- {
                -- ["randomTransportable"] = false,
            -- }, -- end of ["transportable"]
            -- ["unitId"] = 2,
            -- ["skill"] = "Average",
            -- ["y"] = 616314.28571429,
            -- ["x"] = -288585.71428572,
            -- ["name"] = "Ground Unit1",
            -- ["playerCanDrive"] = true,
            -- ["heading"] = 0.28605144170571,
        -- }, -- end of [1]
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
                ["randomTransportable"] = false,
            } -- end of ["transportable"]
        groupData["units"][index]["unitId"]=groupParam:getUnit(index).getID(unit)
        groupData["units"][index]["skill"] = "Average"
        groupData["units"][index]["name"] = groupParam:getUnit(index).getName(unit)
        groupData["units"][index]["playerCanDrive"] = true
        groupData["units"][index]["heading"] = 0.28605144170571
        
    end
	return groupData
end

pierreUnit = Unit.getByName("pierre") --408m to MI8
pierreGroup = Unit.getGroup(pierreUnit)

pilotMI8Unit = Unit.getByName("pilotMI8")
distance = getDistance(pilotMI8Unit,pierreUnit)
trigger.action.outText("Distance: " .. distance , 15)

staticCargo = StaticObject.getByName("Cargo1")
distance = getDistance(pilotMI8Unit,staticCargo)
trigger.action.outText("Distance to cargo: " .. distance , 15)


-- SAVE PIERRE
	-- pierreGroupTable = getTableGroup(pierreGroup,pierreUnit.getPosition(pierreUnit).p)
	-- env.info("groupData ".. pierreGroupTable["name"])
	-- pierreGroup.destroy(pierreGroup)

-- DESTROY PIERRE 
	-- pierreGroup.destroy(pierreGroup)

-- REBIRTH PIERRE
	-- coalition.addGroup(country.id.RUSSIA, Group.Category.GROUND, pierreGroupTable)




-- GARBAGE


-- for index, unit in pairs(pierreGroup:getUnits()) do
	-- --trigger.action.outText(Unit.getName(unit) .. "     " .. Unit.getTypeName(unit), 10 )
	-- env.info(index .. " LOG OUT " ..Unit.getName(unit))
	-- assetUnitPosition =  pierreGroup:getUnit(index).getPosition(unit).p
	-- trigger.action.outText("Pierre x" .. assetUnitPosition.x, 15)
	-- trigger.action.outText("Pierre y" .. assetUnitPosition.y, 15)
-- end
-- assetUnitPosition		= pierreGroup:getUnit(1).p
-- trigger.action.outText("Pierre x" .. assetUnitPosition.x, 15)
-- trigger.action.outText("Pierre y" .. assetUnitPosition.y, 15)