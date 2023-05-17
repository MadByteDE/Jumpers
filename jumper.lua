--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|            Jumper.lua            |--
--|    Jumper for a new lua file     |--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Jumper = {}


-- Initialize
function Jumper.init()
    Jumper.units = {}
end

function Jumper.create(x, y, w,h)
    local jumper = {}
    jumper.x = x
    jumper.y = y
    jumper.width = w
    jumper.height = h
    jumper.color = {1, 0, 0}
    jumper.angle = 0
    jumper.power = 0
    jumper.speed = 100
    jumper.vx = 0
    jumper.vy = 0
    jumper.maxVel = 500
    jumper.remove = false
    jumper.body = LP.newBody(Game.world, x,y, "dynamic")
	jumper.shape = LP.newRectangleShape(jumper.width, jumper.height)
	jumper.fixture = LP.newFixture(jumper.body, jumper.shape)
	jumper.fixture:setRestitution(0) --no rebound
	jumper.body:setFixedRotation(true)
	jumper.body:setMass (2)
	jumper.gfx = {}
	jumper.gfx.image = LG.newImage("gfx/jumponaut.png")
	jumper.gfx.imageScaleX = jumper.width / jumper.gfx.image:getWidth() 
	jumper.gfx.imageScaleY = jumper.height / jumper.gfx.image:getHeight() 
	table.insert(Jumper.units, jumper)
end

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Private functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Public functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

-- Main callbacks
function Jumper.update(dt)
    for i=#Jumper.units, 1, -1 do
        local jumper = Jumper.units[i]
        -- Remove units when needed
        if jumper.remove then table.remove(Jumper.units, i) return end

        -- Calculate angle
        local center = {x=jumper.body:getX(), y=jumper.body:getY()}
        local mx, my = Sys.toGameCoords(LMouse.getPosition())
        jumper.angle = Sys.getAngle(center, {x=mx, y=my})

        -- Jump on mouse press
        if LMouse.isDown(1) then
            jumper.power = jumper.power + 50 * dt
        elseif jumper.power > 0 then
            local vx = (jumper.power*5) * math.sin(jumper.angle)
            local vy = (jumper.power*5) * math.cos(jumper.angle)
            jumper.body:applyLinearImpulse(vx, vy)
            jumper.power = 0
            jumper.landed = false
        end

        -- Clamp stuff
        jumper.power = Sys.clamp(jumper.power, 0, 100)
        jumper.vx = Sys.clamp(jumper.vx, -jumper.maxVel, jumper.maxVel)
        jumper.vy = Sys.clamp(jumper.vy, -jumper.maxVel, jumper.maxVel)

        -- Update position vars
		jumper.x = jumper.body:getX()-jumper.width/2
		jumper.y = jumper.body:getY()-jumper.height/2
    end
end

function Jumper.draw()
    for i=#Jumper.units, 1, -1 do
        local jumper = Jumper.units[i]
        -- Update center
        local center = {x=jumper.body:getX(), y=jumper.body:getY()}
        if Sys.debugmode then
			LG.print(i..")x:y="..math.floor(center.x)..":"..math.floor(center.x), 5, 10*i)
		end
        -- Draw Jumper
        if jumper.gfx then
			LG.setColor (1,1,1,1)
			local stretch = (100-jumper.power*0.5)/100 --vertical shrinking, as if preparing up for jump
			LG.draw (jumper.gfx.image, jumper.x, jumper.y+jumper.height*(1-stretch), 
				0, jumper.gfx.imageScaleX, jumper.gfx.imageScaleY*stretch)
        else
			LG.setColor(jumper.color)
			LG.rectangle("fill", jumper.x, jumper.y, jumper.width, jumper.height)
			LG.setColor(1, 1, 1)
		end
        -- Draw jump line
        local line = {}
        line.x = center.x + 16 * math.sin(jumper.angle)
        line.y = (center.y-jumper.height) + 16 * math.cos(jumper.angle)
        LG.line(center.x, center.y-jumper.height, line.x, line.y)

        -- Draw power indicator
        if jumper.power > 0 then
            local power = math.floor(jumper.power)
            local x, y = jumper.x-64, jumper.y - 15
            LG.printf(power, x, y, jumper.width+128, "center")
        end
    end
end

function Jumper.keypressed(key)
end

function Jumper.mousepressed(x, y, button)
end

return Jumper
