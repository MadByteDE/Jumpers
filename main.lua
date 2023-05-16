--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--         Jumpers (WIP) 2023         --
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-

--[[
    Gedanken:
        - "self" benutzen?
        - Code-Struktur so die Richtung für dich annehmbar?
        - Gecachte Aufrufe für Lua Funktionen (gmatch=string.gmatch, random=math.random etc) nur lokal in jeder Datei wie es benötigt wird?
        - Die Wahrscheinlichkeit das wir beide Zeug in ein und der selben Datei comitten wollen, ist bei so wenigen Dateien recht hoch.
--]]

-- Modules
Sys = require("system")
Gui = require("gui")
Game = require("game")
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
LG.setDefaultFilter("nearest", "nearest")


function love.load()
    Sys.log("Jumpers is getting ready!")
    Sys.init()
    Gui.init()
    Game.init()
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
    LG.pop()
    Sys.draw()
end

function love.keypressed(key)
    Game.keypressed(key)
    Gui.keypressed(key)
end

function love.mousepressed(...)
    Game.keypressed(...)
    Gui.keypressed(...)
end
