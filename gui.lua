--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|              gui.lua             |--
--|       UI elements and text       |--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Gui = {}


-- Initialize
function Gui.init()
end

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Private functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Public functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

-- Main callbacks
function Gui.update(dt)
end

function Gui.draw()
	LG.setColor (0,0,0,1)
	LG.print ("time remaining:"..math.floor(Game.timeLimit-Game.timer).."s",10,0)
	LG.print ("Score:"..Game.score or 0,10,10)
	LG.print ("High Score:"..Game.highScore or "---",10,20)
	LG.print ("r=restart TAB=debug",350,0)
end

function Gui.keypressed(key)
end

function Gui.keyreleased(key, scancode)
end

function Gui.mousepressed(x, y, button)
end

return Gui
