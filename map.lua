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
	--[[
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
	--]]
	Map.loadMap ("maps/platforms.map")
end
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Private functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Public functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
function Map.loadMap (fn)
	for i,v in ipairs(Map.walls) do
		v.body:destroy()
	end
	Map.walls = {}
	local loadT = loadTableFromFile(fn)
--	mapInfo = loadT.mapInfo --irrelevant for Jumpers
	for wi=1, #loadT.walls, 1 do
		--HACK to load Astrodingens maps (they use 1024*768 coordinates system)
		local ratioX = 1024 / Game.width
		local ratioY = 768 / Game.height
		for i = 1, #loadT.walls[wi], 1 do
			loadT.walls[wi][i].x = loadT.walls[wi][i].x / ratioX
			loadT.walls[wi][i].y = loadT.walls[wi][i].y / ratioY
		end
		Map.addPolygonWall (loadT.walls[wi])
		--print (dump (loadT.walls[wi]))
	end
--	game_playerspawnpoints = loadT.playerspawnpoints or {x=res_w/2, y=res_h/2} --irrelevant for Jumpers 
end



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

--wall: -- [1] = {x1,y1}, [2]={x2,y2]  .bodytype="dynamic"/"static"
function Map.addPolygonWall (wall)
	if #wall < 3 or #wall>8 then return end --too many or too fwe polygon corners -> invalid
	if not wall.bodyType then wall.bodyType = "static" end
	local polygonCenter = {x=0,y=0}
	for i=1, #wall,1 do
		polygonCenter.x=polygonCenter.x+wall[i].x
		polygonCenter.y=polygonCenter.y+wall[i].y
	end
	polygonCenter.x=polygonCenter.x/#wall
	polygonCenter.y=polygonCenter.y/#wall
	local xyTable = {}
	local ii=1
	for i=1, #wall,1 do
	--	print ("wall["..i.. "]" ..wall[i].x ..":"..wall[i].y)
		xyTable[ii]=wall[i].x - polygonCenter.x
		xyTable[ii+1]=wall[i].y - polygonCenter.y
		ii=ii+2
	end
	
	local t = {}
    t.body = love.physics.newBody(Game.world, polygonCenter.x,polygonCenter.y, wall.bodyType )
	t.shape = love.physics.newPolygonShape(unpack(xyTable))
	t.fixture = love.physics.newFixture(t.body, t.shape, 1)
	--t.fixture:setSensor(true)
    t.status = "WALL"
	if not wall.color then wall.color = {1,1,1,1} end
	t.color={}
	t.color[1] = wall.color[1] or 0.5 --true--{0.5,0,0}
	t.color[2] = wall.color[2] or 0.5
	t.color[3] = wall.color[3] or 0.5
	if wall.movePath then t.movePath = wall.movePath end
	table.insert(Map.walls, t)
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
