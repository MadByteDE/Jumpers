--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|             system.lua           |--
--| System/engine functions and tools|--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Sys = {
    debugmode=false,
    width=1280/2,
    height=720/2,
    fullscreen=false,
}


-- Initialize
function Sys.init()
    -- Window
    LW.setTitle("Dozers!")
    Sys.setWindowResolution(Sys.width, Sys.height, Sys.fullscreen)
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
    Sys.rescaleWindow()
end

function Sys.rescaleWindow()
    local windowWidth, windowHeight = Sys.width, Sys.height
    -- Borderless fullscreen maximizes the window and ignores set w, h,
    -- so use those values for scaling!
    if Sys.fullscreen then
        windowWidth, windowHeight = LG.getDimensions()
    end
    local gameWidth = Game.width or windowWidth
    local gameHeight = Game.height or windowHeight
    Sys.scaleX = windowWidth/gameWidth
    Sys.scaleY = windowHeight/gameHeight
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

--convert table to string. print (dump(table))
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ',\n'
      end
      return s .. '} '
   else
      if type(o) == 'string' then
		return '"'..o..'"'
      else
		return tostring(o)
	  end
   end
end

function loadTableFromFile (fn)
	local info = love.filesystem.getInfo( fn, "file" )
	if not info then
		print ("file " .. (fn or "nil") "not found")
		return 
	end
	local lines = {}
	for line in love.filesystem.lines(fn) do
		lines[#lines+1]=line
	end
	local s = "return " .. table.concat (lines)
	--FIXME: https://stackoverflow.com/questions/34388285/creating-a-secure-lua-sandbox/34388499#34388499
	local f, e = loadstring(s);
	if f then
		return f();
	else
		print (e)
		return nil, e;
	end;
end


-- Main callbacks
function Sys.update(dt)
end

function Sys.draw()
    if Sys.debugmode then
        -- Draw debug infos / stuff here?
        local mx, my = Sys.toGameCoords(LMouse.getPosition())
        LG.print("MX, MY: "..mx..", "..my, 10, 80)
		LG.print ("FPS:"..love.timer.getFPS(),10,100)
--    if true then return end
    -- draw physics bodies and their shapes
    	for _, body in pairs(Game.world:getBodies()) do
			for _, fixture in pairs(body:getFixtures()) do
			    LG.setColor (1, math.random(0,3)/3,1,0.5)

				local shape = fixture:getShape()
				if shape:typeOf("CircleShape") then
					local cx, cy = body:getWorldPoints(shape:getPoint())
					love.graphics.circle("fill", cx, cy, shape:getRadius())
				elseif shape:typeOf("PolygonShape") then
					love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
				else
					love.graphics.line(body:getWorldPoints(shape:getPoints()))
				end
			end
			LG.setColor(0,1,0,1)
			local contacts = body:getContacts( )
			for i=1,#contacts do
				local x1,y1,x2,y2 = contacts[i]:getPositions()
				if (x1) then
					LG.circle ("fill",x1,y1,6,3)
				end
				if (x2) then
					LG.circle ("fill",x2,y2,6,3)
				end
			end
		
	
		end
    --draw contacts
		LG.setColor(255,0,0,255)
		local contacts = Game.world.getContacts and Game.world:getContacts() or Game.world:getContactList()
		for i=1,#contacts do
			local x1,y1,x2,y2 = contacts[i]:getPositions()
			if (x1) then
				LG.circle ("fill",x1,y1,6,4)
			end
			if (x2) then
				LG.circle ("fill",x2,y2,6,4)
			end
		end
    LG.setColor (1,1,1,1)

    end

end

function Sys.keypressed(key)
end

function Sys.keyreleased(key)
	if key == "tab" then Sys.debugmode = not Sys.debugmode end
end

function Sys.mousepressed(x, y, button)
end

return Sys
