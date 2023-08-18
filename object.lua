--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|           object.lua             |--
--|   object: everything that is not a wall, not a ball, not a dozer    |--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Object = {}
--types: 
--"hole" : removes any balls that touches it.
--"targetarea" : target-area for balls.

-- Initialize
function Object.init()
	Object.units = {}
end

function Object.create (x,y, type, parameters)
	if not parameters then parameters = {} end

    local newObject = {}
	newObject.body = LP.newBody(Game.world, x, y, "dynamic")
	newObject.shape = parameters.shape or LP.newCircleShape(parameters.r or 10)
	newObject.fixture = LP.newFixture(newObject.body, newObject.shape, 1)
    newObject.fixture:setFriction(0.1)
	newObject.fixture:setRestitution(0.6)
	newObject.body:setLinearDamping(5)
	newObject.body:setAngularDamping(0.5)
	newObject.color = parameters.color or {1,0,1,1}
    if type == "hole" then
		newObject.drawFunction = Object.drawHole
    end
    if type == "targetarea" then
		newObject.drawFunction = Object.drawTargetArea
    end

    if type == "hole" or type == "targetarea" then
		newObject.fixture:setSensor(true)
    end
    newObject.type = type or "object"
	newObject.fixture:setUserData({type=newObject.type, object=newObject})
	table.insert(Object.units, newObject)
end

-- Main callbacks
function Object.update(dt)
end

function Object.draw()
	for i=#Object.units, 1, -1 do
	local object = Object.units[i]
	--LG.print (Object.units[i].type or "nil",10,10+10*i)
	if object.drawFunction then
		object:drawFunction()
	end
	end
end

function Object.drawHole(object)
	LG.setColor (0,0,0,1)
	LG.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))
	LG.setColor (1,1,1,0.75)
	LG.polygon("line", object.body:getWorldPoints(object.shape:getPoints()))
end

function Object.drawTargetArea(object)
	LG.setColor (0.4, 0.4,0.2,1)
	LG.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))
	LG.setColor (object.color or {1,0,1,1})
	LG.polygon("line", object.body:getWorldPoints(object.shape:getPoints()))
end

return Object
