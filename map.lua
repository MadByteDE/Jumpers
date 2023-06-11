--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|              Map.lua             |--
--|      Map for a new lua file      |--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Map = {}


-- Initialize
function Map.init()
	Map.walls = {}	--.body .shape .fixture .color
	Map.addWall (100,100,80,10, {1,0,0,1})
	Map.addWall (350,100,80,10, {1,1,0,1})
	Map.addWall (200,170,140,5, {1,0.5,0,1})
	Map.addWall (200,250,350,30, {0.2,0.2,0,1})
	Map.addCircleWall (400,250,60,{0.8,0.8,0,1})
	Map.addCircleWall (450,150,40,{0.4,0.8,0,1})
	-- Map.addWall (80,200,40,5, {0.2,0.7,0,1})
	Map.addWall (0,200,40,150, {0.2,0.7,0,1})
	Map.addBall (398,10,5, {0,0,1,1})
	Map.addBall (200,100,10, {1,0,0,1})
end
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Private functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Public functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
--FIXME: das sollte evtl eine einzige Funktion sein: addWall (type, parameters)
function Map.addWall (x,y, w,h, color)
    local newWall = {}
	newWall.body = LP.newBody(Game.world, x, y, "static")
	newWall.body:setUserData({type="wall"})
	newWall.shape = LP.newRectangleShape(w, h)
	newWall.fixture = LP.newFixture(newWall.body, newWall.shape, 1)
    newWall.color = color
    --newWall.fixture:setFriction(10)
	table.insert(Map.walls, newWall)
end

function Map.addCircleWall (x,y,r, color)
    local newWall = {}
	newWall.body = LP.newBody(Game.world, x, y, "static")
	newWall.shape = LP.newCircleShape(r)
	newWall.fixture = LP.newFixture(newWall.body, newWall.shape, 1)
    newWall.fixture:setFriction(10)
	newWall.color = color
	table.insert(Map.walls, newWall)
end

--Ball...Wall...alles das gleiche.
function Map.addBall (x,y,r, color)
    local newWall = {}
	newWall.body = LP.newBody(Game.world, x, y, "dynamic")
	newWall.shape = LP.newCircleShape(r)
	newWall.fixture = LP.newFixture(newWall.body, newWall.shape, 1)
    newWall.fixture:setFriction(0.1)
   newWall.fixture:setRestitution(0.6)
	newWall.color = color
	table.insert(Map.walls, newWall)
end

-- Main callbacks
function Map.update(dt)
end

function Map.draw()
	-- draw walls
	for i=1,#Map.walls, 1 do
		local wall=Map.walls[i]
		local shapeType = wall.shape:type()
		LG.setColor (wall.color)
		if shapeType == "CircleShape" then
			local cx, cy = wall.body:getWorldPoints(wall.shape:getPoint())
			LG.circle("fill", cx, cy, wall.shape:getRadius())
			LG.setColor (1,1,1,0.5)
			local angle = wall.body:getAngle()
			LG.arc( "fill", cx, cy, wall.shape:getRadius(), angle, angle+math.pi )
		end
		if shapeType == "PolygonShape" then
			LG.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
		end
	end
end

function Map.keypressed(key)
end

function Map.mousepressed(x, y, button)
end

return Map
