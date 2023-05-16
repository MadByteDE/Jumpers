--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|             system.lua           |--
--| System/engine functions and tools|--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Sys = {
debugmode=true,
width = 1280,
height=720,
fullscreen=true,
}


-- Initialize
function Sys.init()
    -- Window
    LW.setTitle("Jumpers!")
    Sys.setWindowResolution( Sys.width, Sys.height, Sys.fullscreen)
    -- Other stuff
end

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Private functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Public functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
function Sys.setWindowResolution(w, h, fullscreen)
    Sys.width = w or Sys.width or LG.getWidth()
    Sys.height = h or Sys.height or LG.getHeight()
    if fullscreen == nil then fullscreen = Sys.fullscreen end
    Sys.fullscreen = fullscreen
    LW.setMode(Sys.width, Sys.height, {vsync=false, fullscreen=Sys.fullscreen})
    -- Since setMode in borderless mode will use the native desktop res instead of the set one
    Sys.rescaleWindow()
end

function Sys.rescaleWindow()
    local w, h = Sys.width, Sys.height
    if Sys.fullscreen then
        w, h = LG.getDimensions()
    end
    local gameWidth = Game.width or w
    local gameHeight = Game.height or h
    Sys.scaleX = w/gameWidth
    Sys.scaleY = h/gameHeight
    -- TODO: Make sure to scale at even values
end

function Sys.toGameCoords(x, y)
    return x/Sys.scaleX, y/Sys.scaleY
end

-- Utility functions
function Sys.clamp(val, min, max)
    if not val then return end
    return math.min(math.max(val, min), max)
end

function Sys.getAngle(a, b)
    return math.atan2(b.x - a.x, b.y - a.y)
end

function Sys.log(txt, ...)
    if not Sys.debugmode then return end
    local info = debug.getinfo(2, "Sl")
    local timestamp = string.match(LT.getTime(), "%d+.%d%d%d")
    local prefix = string.format(" %s [%s%s] ", timestamp, info.currentline, info.source)
    print(prefix..string.format(txt, ...))
end

-- Main callbacks
function Sys.update(dt)
end

function Sys.draw()
    if Sys.debugmode then
        -- Draw debug infos / stuff here?
        local mx, my = Sys.toGameCoords(LMouse.getPosition())
        LG.print("MX, MY: "..mx..", "..my, 10, 50)
    end
end

function Sys.keypressed(key)
end

function Sys.mousepressed(x, y, button)
end

return Sys
