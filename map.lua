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

end
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Private functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Public functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
function Map.addWall (x,y, w,h, color)
    local newWall = {}
	newWall.body = LP.newBody(Game.world, x, y, "static")
	newWall.shape = LP.newRectangleShape(w, h)
	newWall.fixture = LP.newFixture(newWall.body, newWall.shape, 1)
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
		LG.setColor (wall.color)
		LG.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
	end
end

function Map.keypressed(key)
end

function Map.mousepressed(x, y, button)
end

return Map
