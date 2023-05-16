--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|             game.lua             |--
--|      Game systems and logic      |--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Game = {}


-- Initialize
function Game.init()
    Game.setGameResolution(512, 288)
    Game.status = "play"
    Game.gravity = 350
    -- Get other stuff ready
    Map.init()
    Jumpers.init()
    -- Create units
    Jumpers.create(100, 100)
end

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Private functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Public functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
function Game.setGameResolution(w, h)
    Game.width = w or Game.width
    Game.height = h or Game.height
    Sys.rescaleWindow()
end

-- Main callbacks
function Game.update(dt)
    if Game.status == "play" then
        -- Update units
        Jumpers.update(dt)
    end
end

function Game.draw()
    if Game.status == "play" then
        -- Draw units
        Jumpers.draw()
    end
    LG.print("I'm in the Game module & scaled!")
    LG.rectangle ("line", 0,0, Game.width, Game.height)
end

function Game.keypressed(key)
    if key == "escape" then love.event.quit() end
end

function Game.keyreleased(key, scancode)
	if key == "f1" then Sys.setWindowResolution (_,_, not Sys.fullscreen) end
end

function Game.mousepressed(x, y, button)
end

return Game
