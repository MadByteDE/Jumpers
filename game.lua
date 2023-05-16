--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|             game.lua             |--
--|      Game systems and logic      |--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Game = {
    status="play",
    gravity=350,
}


-- Initialize
function Game.init()
    -- Set internal resolution
    Game.setGameResolution(512, 288)
    -- Create physics world
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    Game.world = LP.newWorld(0, 10, true)
    -- Get other stuff ready
    Map.init()
    Jumper.init()
    -- Create units
    Jumper.create(100, 100)
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
        Jumper.update(dt)
		Game.world:update(dt)
	end
end

function Game.draw()
    if Game.status == "play" then
        -- Draw units
        Jumper.draw()
    end
    LG.rectangle ("line", 0,0, Game.width, Game.height)
end

function Game.keypressed(key)
    if key == "escape" then love.event.quit() end
end

function Game.keyreleased(key, scancode)
	if key == "f1" then Sys.setWindowResolution(_, _, not Sys.fullscreen) end
    if key == "r" then Game.init() end
end

function Game.mousepressed(x, y, button)
end

return Game
