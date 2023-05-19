--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--         Jumpers (WIP) 2023         --
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-

--[[
    Aktuelle TODOs:
        1. Physikwelt ausbauen (Ränder; etwas zum draufspringen bzw. drauf landen) [ALLE]
        2. Grafikkonzept erstellen [MadByte]
        3. Weitere TODOs absprechen und aufschreiben [ALLE]
        4. Freistil / Kreativ werden? :'D
--]]

-- Modules
Sys = require("system")
Gui = require("gui")
Game = require("game")
Map = require("map")
Jumper = require("jumper")

-- LÖVE API shortcuts ?
LW = love.window
LG = love.graphics
LP = love.physics
LA = love.audio
LT = love.timer
LF = love.filesystem
LKey = love.keyboard
LMouse = love.mouse
LMath = love.math
-- Default configs
LF.setIdentity("Jumpers")
LG.setDefaultFilter("nearest", "nearest")


function love.load()
    Sys.log("Jumpers! is getting ready!")
    Sys.init()
    Gui.init()
    Game.init()
    --Map.init() --already called in Game.init()
end

-- Main callbacks
function love.update(dt)
    Sys.update(dt)
    Game.update(dt)
    Gui.update(dt)
end

function love.draw()
    LG.push()
    LG.scale(Sys.scaleX, Sys.scaleY)
    Game.draw()
    Gui.draw()
    Sys.draw()
    LG.pop()
end

function love.keypressed(key)
    Game.keypressed(key)
    Gui.keypressed(key)
end

function love.keyreleased(key, scancode)
    Game.keyreleased(key, scancode)
    Gui.keyreleased(key, scancode)
    Sys.keyreleased(key, scancode)
end

function love.mousepressed(...)
    Game.keypressed(...)
    Gui.keypressed(...)
end
