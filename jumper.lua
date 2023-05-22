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
	jumper.fixture:setFriction(0.5)
	jumper.body:setFixedRotation(true)
	jumper.body:setMass (2)
	jumper.image = LG.newImage("gfx/astrochar1_single.png")
	-- jumper.gfx.imageScaleX = jumper.width / jumper.gfx.image:getWidth()
	-- jumper.gfx.imageScaleY = jumper.height / jumper.gfx.image:getHeight()
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
            jumper.power = jumper.power + 100 * dt
        elseif jumper.power > 0 and Jumper.isOnGround(jumper) then
            local vx = (jumper.power*4) * math.sin(jumper.angle)
            local vy = (jumper.power*4) * math.cos(jumper.angle)
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
        -- Draw Jumper
        LG.setColor (1,1,1,1)
        local flipX = 1
        if jumper.angle < 0 then flipX = -1 end
        local stretch = (100-jumper.power*0.2)/100 --vertical shrinking, as if preparing up for jump
        local iw, ih = jumper.image:getDimensions()
        local x = jumper.x + (jumper.width/2)
        local y = jumper.y + (jumper.height - ih) + (jumper.height * (1-stretch)) + 1
        local kx = jumper.width/2 + 3 -- +3 muss irgendwas mit dem Verhältnis zwischen jumper w und image w zu tun haben?
        LG.draw(jumper.image, x, y, 0, flipX, stretch, kx, 0)

        if Sys.debugmode then
			LG.print(i..")x:y="..math.floor(center.x)..":"..math.floor(center.y), 5, 10*i)
            -- Draw jump line
            local line = {}
            line.x = center.x + (8 * math.sin(jumper.angle))
            line.y = center.y + (8 * math.cos(jumper.angle))
            LG.line(center.x, center.y, line.x, line.y)
            -- Draw power indicator
            if jumper.power > 0 then
                local power = math.floor(jumper.power)
                local x, y = jumper.x-64, jumper.y - 15
                LG.printf(power, x, y, jumper.width+128, "center")
            end
		end
    end
end

--return true / false is Jumper is touching a wall body
function Jumper.isOnGround (jumper)
	for i=1,#Map.walls, 1 do
		local wall=Map.walls[i]
		if jumper.body:isTouching (wall.body) then return true end
	end
	return false
end

function Jumper.setPosition (jumper,x,y)
	jumper.body:setPosition(x,y)
	jumper.body:setLinearVelocity(0,0)
end

function Jumper.keypressed(key)
	if key=="space" then Jumper.setPosition (Jumper.units[1],100,180) end
end

function Jumper.mousepressed(x, y, button)
end

return Jumper
