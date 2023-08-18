--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                         	       |--
--|           ball.lua		           |--
--|   Balls: moveable. pushed by dozers to archive gameplay goals.    |--
--|                 	               |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Ball = {}


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
	newBall.shape = LP.newCircleShape(parameters.r or 10)
	newBall.fixture = LP.newFixture(newBall.body, newBall.shape, 1)
    newBall.fixture:setFriction(0.1)
	newBall.fixture:setRestitution(0.6)
	newBall.body:setLinearDamping(5)
	newBall.body:setAngularDamping(0.5)
	newBall.color = parameters.color or {1,0,0,1}
	newBall.remove = false
	newBall.points = parameters.r or 1
	newBall.fixture:setUserData({type="ball", ball=newBall})
	table.insert(Ball.units, newBall)
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
	end
end

--[[
function Template.keypressed(key)
end

function Template.mousepressed(x, y, button)
end
--]]
return Ball
