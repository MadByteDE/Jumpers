--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|            Dozer.lua            |--
--|    Dozer for a new lua file     |--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Dozer = {}


-- Initialize
function Dozer.init()
    Dozer.units = {}
end

function Dozer.create(x, y, w,h, parameters)
	if not parameters then parameters = {} end
    local dozer = {}
    
    dozer.x = x
    dozer.y = y
    dozer.width = w
    dozer.height = h
    dozer.color = {1, 0, 0}
    dozer.angle = 0
    dozer.power = 0
    dozer.speed = 100
    dozer.vx = 0
    dozer.vy = 0
    dozer.maxVel = 500
    dozer.remove = false
    dozer.body = LP.newBody(Game.world, x,y, "dynamic")
	dozer.shape = LP.newRectangleShape(dozer.width, dozer.height)
	dozer.fixture = LP.newFixture(dozer.body, dozer.shape)
	--dozer.fixture:setRestitution(0.5) --rebound
	--dozer.fixture:setFriction(10)
	dozer.body:setFixedRotation(false)
	dozer.body:setMass (2)
	dozer.body:setLinearDamping(10)
	dozer.body:setAngularDamping(100)
	dozer.image = LG.newImage("gfx/dozer.png")
	dozer.input = {moveLeft=false, moveRight=false, moveForwards=false,moveBackwards=false,jump=false}	--this can be set by keyboard, gamepad or AI
	dozer.keyboard = parameters.keyboard 	--keyboard config, example:  {keyboard={moveLeft="a", moveRight="d", jump="s"}
	dozer.AI = parameters.AI
	
	--joint = love.physics.newWeldJoint( body1, body2, x1, y1, x2, y2, collideConnected, referenceAngle )

	local bladeFriction = 1 --0.2 default when not setFriction()
	dozer.blade1={}
	dozer.blade1.body=LP.newBody(Game.world, 0,0, "dynamic")
	dozer.blade1.shape = LP.newRectangleShape(w/1.5,-h/2, dozer.width/4, dozer.height/2, math.rad(45))
	dozer.blade1.fixture = LP.newFixture(dozer.body, dozer.blade1.shape)
	dozer.blade1.fixture:setFriction(bladeFriction)
	
	dozer.blade2={}
	dozer.blade2.body=LP.newBody(Game.world, 0,0, "dynamic")
	dozer.blade2.shape = LP.newRectangleShape(-w/1.5,-h/2, dozer.width/4, dozer.height/2, math.rad(-45))
	dozer.blade2.fixture = LP.newFixture(dozer.body, dozer.blade2.shape)
	dozer.blade2.fixture:setFriction(bladeFriction)
	--dozer.blade1.joint = LP.newWeldJoint(dozer.body, dozer.blade1.body, x+w/1.5, y-h/2, x, y, false, math.rad(45) )
--[[
	dozer.blade2={}
	dozer.blade2.body=LP.newBody(Game.world, x,y, "dynamic")
	dozer.blade2.shape = LP.newRectangleShape(dozer.width/4, dozer.height/2)
	dozer.blade2.fixture = LP.newFixture(dozer.blade2.body, dozer.shape)
	--dozer.blade2.joint = LP.newWeldJoint(dozer.body, dozer.blade2.body, x-w/1.5, y-h/2, x, y, false, math.rad(-45) )
--]]

	-- dozer.gfx.imageScaleX = dozer.width / dozer.gfx.image:getWidth()
	-- dozer.gfx.imageScaleY = dozer.height / dozer.gfx.image:getHeight()
	dozer.fixture:setUserData({type="dozer", dozer=dozer})

	table.insert(Dozer.units, dozer)
end

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Private functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Public functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

-- Main callbacks
function Dozer.update(dt)
    for i=#Dozer.units, 1, -1 do
        local dozer = Dozer.units[i]
        -- Remove units when needed --FIXME: deleting multiple entries per frame + destroy body
        if dozer.remove then table.remove(Dozer.units, i) return end
	
        if dozer.keyboard then
			for k,v in pairs (dozer.keyboard) do
				dozer.input[k]  = false
				if LKey.isDown(v) then
				--Dozer.units[i]
				dozer.input[k] = true
				--	print ("set to true:"..k)
				end
				--print (k,v)
			end
		end
		
	
			--dozer.body:setAngularVelocity (0)

		

		
		if dozer.input.moveLeft then
			local old_a = dozer.body:getAngle()
			--dozer.body:setAngle (old_a - 4*dt)
			dozer.body:applyTorque(-10000/1.5)
		--	print "turn left"
		end
		
		if dozer.input.moveRight then			
			local old_a = dozer.body:getAngle()
			--dozer.body:setAngle (old_a + 4*dt)			
			dozer.body:applyTorque(10000/1.5)
		--	print "turn right"
		end
		local angle=dozer.body:getAngle()

		local isMoving=false
		if dozer.input.moveForwards then
			local fx = math.sin(angle) *  100
			local fy = -math.cos(angle) *  100
			dozer.body:applyForce (fx, fy)
			isMoving=true
		end

		if dozer.input.moveBackwards then
			local fx = math.sin(dozer.body:getAngle()) *  100
			local fy = -math.cos(dozer.body:getAngle()) *  100
			dozer.body:applyForce (-fx, -fy)
			isMoving=true
		end
		
		local x =dozer.x+(math.sin(angle)*7)
		local y =dozer.y-(math.cos(angle)*7)
		if isMoving then
			--lots of exhaust smoke
			if math.floor(Game.timer*100)%10==0 then
				aniFx.add ({x=x,y=y, color={0.0,0.0,0.1,0.5},duration=math.random(1,10)/5, f_update = aniFx.update_expandExplosion, f_draw=aniFx.draw_expandExplosion, drawType="circles",expandSpeed=math.random(1,10)}) 
			end
		else
			--idle exhaust smoke
			if math.floor(Game.timer*10)%10==0 then
				aniFx.add ({x=x,y=y, color={0.5,0.5,0.5,0.05},particlesNumber=3,duration=math.random(1,50)/10, f_update = aniFx.update_expandExplosion, f_draw=aniFx.draw_expandExplosion, drawType="circles",expandSpeed=math.random(1,3)}) 
			end
			
		end


        -- Update position vars
		dozer.x = dozer.body:getX()--dozer.width/2
		dozer.y = dozer.body:getY()--dozer.height/2
    end
end

function Dozer.draw()
    for i=#Dozer.units, 1, -1 do
        local dozer = Dozer.units[i]
        -- Update center
        local center = {x=dozer.body:getX(), y=dozer.body:getY()}
        local angle = dozer.body:getAngle()
        -- Draw Dozer
        --love.graphics.polygon("fill", dozer.body:getWorldPoints(dozer.shape:getPoints()))
		LG.setColor (1,1,0,1)
		love.graphics.polygon("fill", dozer.body:getWorldPoints(dozer.blade1.shape:getPoints()))
		love.graphics.polygon("fill", dozer.body:getWorldPoints(dozer.blade2.shape:getPoints()))

		
        local iw, ih = dozer.image:getDimensions()
        local scalex=(dozer.width/iw)--*1.7
        local scaley=(dozer.height/ih)--*1.7
        LG.setColor (1,1,1,1)
        LG.draw(dozer.image, center.x, center.y, angle, scalex,scaley,dozer.width/scalex/2,dozer.height/scaley/2)--, dozer.height/2)
		--rotating light
		if dozer.input.moveBackwards then
		local lightAngle=(Game.timer*10)%6.3
		LG.setColor (1,0.8,0.1,0.5)
		--LG.arc ("fill","pie", center.x+math.sin(angle+2.8)*dozer.height/2, center.y-math.cos(angle+2.8)*dozer.height/2, 20, lightAngle-0.5,lightAngle+0.5)
		--LG.arc ("fill","pie", center.x+math.sin(angle-2.8)*dozer.height/2, center.y-math.cos(angle-2.8)*dozer.height/2, 20, -lightAngle-0.5,-lightAngle+0.5)
		LG.arc ("fill","pie", center.x,center.y, 20, lightAngle-0.5+math.pi,lightAngle+0.5+math.pi)
		LG.arc ("fill","pie", center.x,center.y, 20, lightAngle-0.5,lightAngle+0.5)
		end
		--draw trackmarks
		LG.push()
		 LG.scale(1/Sys.scaleX, 1/Sys.scaleY)
		LG.setCanvas(Game.groundCanvas)
		--love.graphics.setBlendMode( "add")
		LG.setColor (0.4,0.3,0,0.02)
		LG.circle ("line",center.x + math.sin(angle+math.rad(90))*5,center.y- math.cos(angle+math.rad(90))*5, 1)
		LG.circle ("line",center.x + math.sin(angle-math.rad(90))*5,center.y- math.cos(angle-math.rad(90))*5, 1)
		--love.graphics.setBlendMode("alpha")

		LG.setCanvas ()
		LG.pop()
		
        if Sys.debugmode then
			local xs,ys = dozer.body:getLinearVelocity()
			LG.print(i..")x:y="..math.floor(center.x)..":"..math.floor(center.y) .."\txsspeed:"..xs.." yspeed:"..ys, 5, 10*i)
			LG.setColor (1,0,1,1)
			LG.circle ("fill",dozer.x,dozer.y, 4,3)
		end
    end
end




--return true / false is Dozer is touching a wall body
function Dozer.isOnGround (dozer)
	for i=1,#Map.walls, 1 do
		local wall=Map.walls[i]
		if dozer.body:isTouching (wall.body) then return true end
	end
	return false
end

--return true / false is Dozer is allowed to jump
--FIXME
--this also needs to handle cases where one dozer is standing on top another dozer and not touching the ground!
function Dozer.canJump (dozer)
	return Dozer.isOnGround (dozer)
end

function Dozer.setPosition (dozer,x,y)
	dozer.body:setPosition(x,y)
	dozer.body:setLinearVelocity(0,0)
end

function Dozer.getAIInput (dozer)
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

function Dozer.keypressed(key)
	if key=="space" then Dozer.setPosition (Dozer.units[1],100,180) end
	--[[
	for i=#Dozer.units, 1, -1 do
        local dozer = Dozer.units[i]
        if dozer.keyboard then
			for k,v in pairs (dozer.keyboard) do
				Dozer.units[i].input[k]  = false
				if v==key then
				Dozer.units[i].input[k] = true
					print ("set to true:"..k)
				end
				print (k,v)
			end
		end
    end
    --]]
end

function Dozer.mousepressed(x, y, button)
end

return Dozer
