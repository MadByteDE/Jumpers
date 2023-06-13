--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|             game.lua             |--
--|      Game systems and logic      |--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Game = {
    status="play",
    gravity=350,
    timer=0,
}


-- Initialize
function Game.init()
    -- Set internal resolution
    Game.setGameResolution(512, 288)
    -- Create physics world
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    Game.world = LP.newWorld(0, 100, true)
    Game.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    Game.timer = 0
    -- Get other stuff ready
    Map.init()
    Jumper.init()
    -- Create units
    --Jumper.create(200, 200, 4,8)

   -- Jumper.create(100, 200, 14,22, {keyboard={moveLeft="a", moveRight="d", jump="s"}})
    Jumper.create(100, 200, 14,22, {keyboard={moveLeft="left", moveRight="right", jump="up"}})
    --Jumper.create(300, 200, 14,22, {AI=true})


   -- Jumper.create(120, 200, 16,32)

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
	Game.timer = Game.timer + dt
end

function Game.draw()
	LG.print("TAB to toggle debug. SPACE to reset unit[1].",0,Game.height-24)
	if Game.status == "play" then
        -- Draw map
        Map.draw()
        -- Draw units
        Jumper.draw()
    end
    -- Screen border
    LG.rectangle ("line", 0,0, Game.width, Game.height)
end

function Game.keypressed(key)
    if key == "escape" then love.event.quit() end
end

function Game.keyreleased(key, scancode)
	if key == "f1" then Sys.setWindowResolution(_, _, not Sys.fullscreen) end
    if key == "r" then Game.init() end
    Jumper.keypressed(key)
end

function Game.mousepressed(x, y, button)
end

return Game
