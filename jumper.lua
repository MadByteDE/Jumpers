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

function Jumper.create(x, y, w,h, parameters)
	if not parameters then parameters = {} end
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
	jumper.input = {moveLeft=false, moveRight=false, jump=false}	--this can be set by keyboard, gamepad or AI
	jumper.keyboard = parameters.keyboard 	--keyboard config, example:  {keyboard={moveLeft="a", moveRight="d", jump="s"}
	jumper.AI = parameters.AI
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
		--[[
		---mouse controls
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
        --]]
        --keyboard:
        if jumper.keyboard then
			for k,v in pairs (jumper.keyboard) do
				jumper.input[k]  = false
				if LKey.isDown(v) then
				--Jumper.units[i]
				jumper.input[k] = true
					print ("set to true:"..k)
				end
				print (k,v)
			end
		end
		--AI:
		if jumper.AI then
			jumper.input = Jumper.getAIInput(jumper)
		end
        
		--input handling
		if jumper.input.jump then
		    jumper.power = jumper.power + 100 * dt
		    print ("jump!" .. jumper.power)
		elseif jumper.power > 0 and Jumper.canJump(jumper) then
            local vx = (jumper.power*4) * math.sin(jumper.angle)
            local vy = (jumper.power*4) * math.cos(jumper.angle)
            jumper.body:applyLinearImpulse(vx, vy)
            jumper.power = 0
            jumper.landed = false			
		end
		if jumper.input.moveLeft and Jumper.canJump(jumper) then
			jumper.angle = math.rad(-90)-math.rad(45)
			jumper.body:applyLinearImpulse(-2, 0)
			print "move left"
		end
		if jumper.input.moveRight and Jumper.canJump(jumper)then
			jumper.angle = math.rad(90)+math.rad(45)
			jumper.body:applyLinearImpulse(2, 0)
			print "move right"

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
            line.x = center.x + (18 * math.sin(jumper.angle))
            line.y = center.y + (18 * math.cos(jumper.angle))
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

--return true / false is Jumper is allowed to jump
--FIXME
--this also needs to handle cases where one jumper is standing on top another jumper and not touching the ground!
function Jumper.canJump (jumper)
	return Jumper.isOnGround (jumper)
end

function Jumper.setPosition (jumper,x,y)
	jumper.body:setPosition(x,y)
	jumper.body:setLinearVelocity(0,0)
end

function Jumper.getAIInput (jumper)
	local moveLeft, moveRight, jump = false, false, false
	if math.sin(Game.timer) < 0 then 
		moveLeft = true
		moveRight = false
	else
		moveLeft = false
		moveRight = true
	end
	if math.sin(Game.timer*3) < 0 then
		jump = true
	else
		jump = false
	end
	return {moveLeft=moveLeft, moveRight=moveRight, jump=jump}
end

function Jumper.keypressed(key)
	if key=="space" then Jumper.setPosition (Jumper.units[1],100,180) end
	--[[
	for i=#Jumper.units, 1, -1 do
        local jumper = Jumper.units[i]
        if jumper.keyboard then
			for k,v in pairs (jumper.keyboard) do
				Jumper.units[i].input[k]  = false
				if v==key then
				Jumper.units[i].input[k] = true
					print ("set to true:"..k)
				end
				print (k,v)
			end
		end
    end
    --]]
end

function Jumper.mousepressed(x, y, button)
end

return Jumper
