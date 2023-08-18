--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|           object.lua             |--
--|   object: everything that is not a wall, not a ball, not a dozer    |--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Object = {}
--types: 
--"hole" : removes any balls that touches it. awards points.
--"converter" : takes balls as input, outputs new balls
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
		newObject.drawFunction = Object.Hole_Draw
		newObject.ballContactFunction = Object.Hole_ballContact
    end
    if type == "targetarea" then
		newObject.drawFunction = Object.TargetArea
    end

    if type == "hole" or type == "targetarea" then
		newObject.fixture:setSensor(true)
    end
    
    if type == "converter" then
		newObject.fixture:setSensor(true)
		newObject.outputPosition = {x=x+parameters.outputOffset.x,y=y+parameters.outputOffset.y}
		newObject.outputMaterial = parameters.outputMaterial or 1
		newObject.outputr = parameters.outputr or 3	--ball radius
		newObject.outputFactor = parameters.outputFactor or 0.5
		newObject.convertTime = parameters.convertTime or 0  --time between creation of new output balls
		newObject.outputTimer = parameters.convertTime --internal timer for converting
		newObject.inputMaterial = parameters.inputMaterial or 1
		newObject.inputStorage = 0 --putting balls into converters: inputStorage+ball.r*outputFactor
		newObject.outputBuffer = {}
		
		newObject.drawFunction = Object.Converter_draw
		newObject.ballContactFunction = Object.Converter_ballContact
		newObject.updateFunction = Object.Converter_update
	end
    
    newObject.type = type or "object"
	newObject.fixture:setUserData({type=newObject.type, object=newObject})
	table.insert(Object.units, newObject)
end

-- Main callbacks
function Object.update(dt)
	for i=#Object.units, 1, -1 do
		local object = Object.units[i]
		if object.updateFunction then
			object:updateFunction(dt)
		end
	end
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

---- vv Hole vv -----
function Object.Hole_Draw(object)
	LG.setColor (0,0,0,1)
	LG.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))
	LG.setColor (1,1,1,0.75)
	LG.polygon("line", object.body:getWorldPoints(object.shape:getPoints()))
end

function Object.Hole_ballContact(object,ball)
	Ball.setRemove(ball.i)
	Game.score=Game.score+(ball.points or 1)
	local x,y = ball.body:getPosition()
	aniFx.add ({x=x,y=y, color={0.4,0.4,0.4,0.5},duration=math.random(1,10), f_update = aniFx.update_expandExplosion, f_draw=aniFx.draw_expandExplosion, drawType="arcs",expandSpeed=math.random(5,10)}) 
end

---- vv Converter vv ----------
function Object.Converter_ballContact(object,ball)
	print ("object.inputMaterial / ball.material :" .. object.inputMaterial.."/".. ball.material)
	if object.inputMaterial ~= ball.material then return end 
	Ball.setRemove(ball.i)
	object.inputStorage = object.inputStorage + (ball.r*object.outputFactor) 
end


function Object.Converter_draw(object)
	LG.setColor (0,0.5,0,1)
	LG.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))
	LG.setColor (0,1,1,1)
	LG.polygon("line", object.body:getWorldPoints(object.shape:getPoints()))
	LG.setColor (1,0.5,0,1)
	LG.circle ("line", object.outputPosition.x,object.outputPosition.y,10,6)
	local x,y = object.body:getPosition()
	LG.setColor (1,1,1,1)
	--LG.print ("inputStorage:"..object.inputStorage,x,y)
	LG.print ("outputTimer:"..object.outputTimer,object.outputPosition.x,object.outputPosition.y)
	local w=(1-((object.outputTimer or 0)/object.convertTime))*2*math.pi
	LG.arc("line", "open",object.outputPosition.x,object.outputPosition.y, 10, 0, 0-w,6)
end

function Object.Converter_addOutput (object, output)
	table.insert (object.outputBuffer, output)
end

function Object.Converter_update(object,dt)
	if object.inputStorage >= object.outputr then 
		object.outputTimer = object.outputTimer-dt
		if object.outputTimer <= 0 then
			Object.Converter_addOutput (object, 1)
			object.inputStorage = object.inputStorage - object.outputr
			object.outputTimer = object.convertTime
		end
 	end
	--print "update"
	if #object.outputBuffer~=0 then
--		Ball.create (object.outputPosition.x,object.outputPosition.y, {r=5, color={1,1,1,1}})
		local a=5
		local x=object.outputPosition.x+math.random(-a,a)
		local y=object.outputPosition.y+math.random(-a,a)
		
		Ball.addBall (x,y,object.outputMaterial, object.outputr)
		table.remove (object.outputBuffer,1)
	end
end

------ vv TargetArea vv-----
function Object.drawTargetArea(object)
	LG.setColor (0.4, 0.4,0.2,1)
	LG.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))
	LG.setColor (object.color or {1,0,1,1})
	LG.polygon("line", object.body:getWorldPoints(object.shape:getPoints()))
end

return Object
