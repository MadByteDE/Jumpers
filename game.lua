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
    Game.tilemap = {}
    -- Units
    Game.jumpers = {}
end

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Private functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
local function updateUnits(dt)
    -- Jumpers
    for i=#Game.jumpers, 1, -1 do
        local jumper = Game.jumpers[i]
        if jumper.remove then table.remove(Game.jumpers, i) return end
        -- Do stuff
    end
    -- Other units
end

local function drawUnits()
    -- Jumpers
    for i=#Game.jumpers, 1, -1 do
        local jumper = Game.jumpers[i]
        -- Draw stuff
    end
    -- Other units
end

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Public functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
function Game.setGameResolution(w, h)
    Game.width = w or Game.width
    Game.height = h or Game.height
    Sys.rescaleWindow()
end

function Game.createJumper(x, y)
    local jumper = {}
    jumper.x = x
    jumper.y = y
    jumper.width = 32
    jumper.height = 32
    jumper.angle = 90
    jumper.jumpPower = 0
    jumper.remove = false
    table.insert(Game.jumpers, jumper)
end

-- Main callbacks
function Game.update(dt)
    if Game.status == "play" then
        updateUnits(dt)
    end
end

function Game.draw()
    if Game.status == "play" then
        drawUnits()
    end
    LG.print("I'm in the Game module & scaled!")
end

function Game.keypressed(key)
    if key == "escape" then love.event.quit() end
end

function Game.mousepressed(x, y, button)
end

return Game