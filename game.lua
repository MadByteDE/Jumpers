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
    highScore = 0,
}


-- Initialize
function Game.init()
    -- Set internal resolution
    Game.setGameResolution(512, 288)
    -- Create physics world
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    Game.world = LP.newWorld(0, 0, true)
    Game.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    --timer
    Game.timer = 0
    Game.score = 0
    Game.timeLimit = 60 --seconds
    -- Get other stuff ready
	Game.status = "play"
	Ball.init()

    Map.init()
    Dozer.init()
	Object.init()
    -- Create units
    Dozer.create(100, 150, 16,24, {keyboard={moveLeft="left", moveRight="right", moveForwards="up",moveBackwards="down",jump="backspace"}})
	Dozer.create(480, 250, 22,22, {keyboard={moveLeft="a", moveRight="d", moveForwards="w",moveBackwards="s",jump="backspace"}})
	Ball.create (250,50, {r=5, color={0,0,1,1}})
	Ball.create (250,100, {r=10, color={0,0,1,1}})
	Ball.create (250,150, {r=15, color={0,0,1,1}})
	Ball.create (250,200, {r=20, color={0,0,1,1}})
	Object.create (150,20, "targetarea", {shape=LP.newPolygonShape(0,0, 50,50, 100,150, 40,50, 0,100)})

	Object.create (100,100, "hole", {shape=LP.newPolygonShape(10,10, 50,50, 40,10, 40,50)})
	Object.create (400,150, "hole", {shape=LP.newPolygonShape(10,10, 20,10, 50,50, 60,20, 15,50)})

	
	Game.groundCanvas = LG.newCanvas (512,288)
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
    	Game.timer = Game.timer + dt
    	Game.dt = dt
        -- Update units
    	Game.world:update(dt)
        Dozer.update(dt)
		Ball.update(dt)
	
		--Game.CalculateScore()
		--update particle animations
		aniFx.update ()
	if Game.timer > Game.timeLimit then Game.GameOver() end
	end
end

function Game.draw()
	LG.clear (0.6,0.4,0,1)
	LG.setLineWidth(3)
	if Game.status == "play" or Game.status == "gameover" then
		-- Draw groundCanvas (trackmarks)
		LG.setColor (1,1,1,1)
		LG.draw (Game.groundCanvas,0,0)
        -- Draw map
        Map.draw()
        -- Draw units
        Object.draw()

        Dozer.draw()

        Ball.draw()
        LG.setColor(1,1,1,1)
        aniFx.draw ()
    end
    if Game.status == "gameover" then
		LG.setColor (1,0,0,0.5)
		LG.circle ("fill", 220,120,100,8,1)
		LG.setColor (1,0,0,1)
		LG.circle ("line", 220,120,100,8,1)

		LG.setColor (1,1,1,1)
		LG.print ("TIME IS UP\nScore:"..Game.score.."\nr=restart",150,100,0,2)
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
    Dozer.keypressed(key)
end

function Game.mousepressed(x, y, button)
end

function Game.GameOver()
	Game.status = "gameover"
	if Game.score > Game.highScore then Game.highScore = Game.score end 
end

function beginContact(a, b, coll)
	--print (Game.timer .. " beginContact ")
	--swap fixtures a,b so they are always in same order. dozer=a targetarea=a balls=b
	local aud = a:getUserData() or {} --{type="nil!"}
	local bud = b:getUserData() or {} --{type="nil!"}
	--print ("\t"..(aud.type or "nil").."/"..(bud.type or "nil"))
	--[[if bud.type=="dozer" then
		a,b = b,a
		aud,bud=bud,aud
	end--]]
	if bud.type=="targetarea" or bud.type=="hole" then
		a,b = b,a --targetarea: is always 'a' 
		aud,bud=bud,aud
	end

	if aud.type == "hole" and bud.type=="ball" then
		print "beginContact: ball & hole"
			Ball.setRemove(bud.ball.i)
			Game.score=Game.score+(bud.ball.points or 1)
			local x,y = bud.ball.body:getPosition()
			aniFx.add ({x=x,y=y, color={0.4,0.4,0.4,0.5},duration=math.random(1,10), f_update = aniFx.update_expandExplosion, f_draw=aniFx.draw_expandExplosion, drawType="arcs",expandSpeed=math.random(5,10)}) 

		end

--   local x,y = coll:getNormal()
--    if a.dozer then a.dozer.normals={x=x,y=y} a.dozer.landed=true end
end

function Game.CalculateScore()
	Game.score = 0
	for i=#Object.units, 1, -1 do
		local object = Object.units[i]
		if object.type=="targetarea" then
			local contacts = object.body:getContacts( )
	--		if #contacts > 0 then 			print (Game.timer .. " #contacts:" ..#contacts) end

			for u,v in pairs (contacts) do
				local fixtureA, fixtureB = v:getFixtures()
				local bodyA = fixtureA:getBody()
				local bodyB = fixtureB:getBody()
				local aud = fixtureA:getUserData() or {type="nil!"}
				local bud = fixtureB:getUserData() or {type="nil!"}
				if aud.ball or bud.ball then
					if bodyA:isTouching(bodyB) then
						--print (u .. " " .. aud.type.."/"..bud.type)

						Game.score=Game.score+1
					end
				end
			end
		end
	end
end

return Game
