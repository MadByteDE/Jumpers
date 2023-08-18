--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                         	       |--
--|           ball.lua		           |--
--|   Balls: moveable. pushed by dozers to archive gameplay goals.    |--
--|                 	               |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Ball = {}
local BallMaterials =
	{
	[1] = {name="Rock", density=1.0, worth = 1.0, color={0.5,0.5,0.5,1} },
	[2] = {name="Crushed Rock", density=3, worth = 2, color={0,1,0.5,1}},
	
	}

-- Initialize
function Ball.init()
	Ball.units = {}
end

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Private functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Public functions
function Ball.create (x,y, parameters)
    if not parameters then parameters = {} end
    local newBall = {}
	newBall.body = LP.newBody(Game.world, x, y, "dynamic")
	newBall.r = parameters.r or 10
	newBall.shape = LP.newCircleShape(newBall.r)
	newBall.fixture = LP.newFixture(newBall.body, newBall.shape, parameters.density or 1)
    newBall.fixture:setFriction(0.1)
	newBall.fixture:setRestitution(0.6)
	newBall.body:setLinearDamping(5)
	newBall.body:setAngularDamping(0.5)
	newBall.color = parameters.color or {1,0,0,1}
	newBall.remove = false
	newBall.points = parameters.points or newBall.r
	newBall.material = parameters.material or 1
	newBall.fixture:setUserData({type="ball", ball=newBall})
	table.insert(Ball.units, newBall)
end

function Ball.addBall (x,y, material, r)
	local m = BallMaterials[material] or {}
	local parameters = {
		r = r,
		density = m.density or 1,
		color = m.color or {1,0,1,1},
		points = r * (m.worth or 1),
		material = material,
	}
	Ball.create (x,y,parameters)
end
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--


function Ball.setRemove (i)
	if not Ball.units[i] then print "Ball.setRemove: Ball.units[i] was nil" return end
	Ball.units[i].remove=true
end

-- Main callbacks
function Ball.update(dt)
	for i=#Ball.units, 1, -1 do
		local ball=Ball.units[i]
		if ball.remove then 
			ball.body:destroy()
			table.remove (Ball.units, i)
		else
			ball.i=i
		end
			
		
	end
end

function Ball.draw()
		-- draw Balls
	for i=1,#Ball.units, 1 do
		local ball=Ball.units[i]
		local shapeType = ball.shape:type()
				local x,y=ball.body:getPosition()
		--LG.setColor (1,1,1,1)
		--LG.circle ("line",x,y,math.random(5,10))
		LG.setColor (ball.color)
		if shapeType == "CircleShape" then
			local cx, cy = ball.body:getWorldPoints(ball.shape:getPoint())
			LG.circle("fill", cx, cy, ball.shape:getRadius())
			LG.setColor (1,1,1,0.5)
			local angle = ball.body:getAngle()
			LG.arc( "fill", cx, cy, ball.shape:getRadius(), angle, angle+math.pi )
		end
		if shapeType == "PolygonShape" then
			LG.polygon("fill", ball.body:getWorldPoints(ball.shape:getPoints()))
		end
		if Sys.debugmode then
			LG.print ("r="..ball.r,x,y)
		end
	end
end

--[[
function Template.keypressed(key)
end

function Template.mousepressed(x, y, button)
end
--]]
return Ball
