--GFX effects
-- f_update can be to set to a function that will be called every love.update frame.
-- if the effect has finished, return true from f_update to remove it.
-- f_draw is called in love.draw
-- vars is a table to hold variables for use in update/draw functions

aniFx = {}
aniFx.t={}
aniFx.toDelete = {}
local random=math.random
local sin=math.sin
local cos=math.cos
local rad=math.rad


function aniFx.update ()
	for i,v in pairs (aniFx.t) do
		--print ("update i="..i)
		local finished = v.f_update (v)
		if finished then table.insert (aniFx.toDelete, i) end
	end
	aniFx.deleteFinished ()
end

function aniFx.deleteFinished ()	
	for i,v in pairs (aniFx.toDelete) do
		--print ("deleteFinished, for loop, i="..i)
		aniFx.t[v] = nil
		--print ("deleted " .. i)
	
	end
	aniFx.toDelete = {}
end

function aniFx.draw ()
			--print "aniFx.draw()"
	for i,v in pairs (aniFx.t) do
		--LG.print ("["..i.."]"..(v.r or "nil"), v.x, v.y)	
		v.f_draw (v)		
	end
	LG.setColor (1,1,1,1)
end


function aniFx.add (o)
    --o = o or {}   -- create object if user does not provide one
	o.vars = {}
    table.insert (aniFx.t,o)
  --  print "aniFx:add"
end
---

--v.timer: counts from 0 to v.timerEnd
--v.progressPercent: from 0 to 1
function aniFx.timer (v)
	--print ( v.time, v.timeEnd, v.timePercent)
	if v.time==nil then v.time = 0 end
	v.time=v.time+Game.dt
	v.timePercent = v.time/v.timeEnd
	if v.time>v.timeEnd then return true end
	return false
end

function update_count_up (v)
	v.r=v.r+Game.dt*(v.countSpeed or 1)
	if v.r>20 then return true end
	--if not v.vars.test then v.vars.test=1 end
	--v.vars.test=math.random(0,1000)--v.vars.test+1
	return false
end

function aniFx.update_count_down (v)
	v.r=v.r-Game.dt*(v.countSpeed or 1)
	if v.r<0 then return true end
	return false
end




function aniFx.draw_circle (v)
	--LG.print (v.vars.test or "nil", v.x,v.y)
	LG.setColor (v.color)
	love.graphics.circle( "line", v.x, v.y, v.r,  16 )
end

--ship warps in
function aniFx.draw_sparkle (v)
	LG.setColor (v.color)
	for n=1,10 do
		LG.line (v.x,v.y, v.x+math.random (-v.r,v.r), v.y+math.random(-v.r,v.r))
	end
end

-------
function aniFx.update_bubbleExplosion (v)
	--if v.time==0 then
	if not v.vars.time then
		v.vars.time = 0
	--	v.bubbles = {}
		for i=1,v.nbubbles do
			v.bubbles[i] = {}
			v.bubbles[i].x=v.x+math.random(-10,10)
			v.bubbles[i].y=v.y+math.random(-10,10)
			v.bubbles[i].r=math.random(0,5)
		end
	end
	v.x=v.x+v.xspeed*Game.dt
	v.y=v.y+v.yspeed*Game.dt

	for i=1,#v.bubbles do
		v.bubbles[i].r=v.bubbles[i].r+Game.dt*100
		if v.bubbles[i].r>20 then
			v.bubbles[i].x=v.x+math.random(-30,30)
			v.bubbles[i].y=v.y+math.random(-30,30)
			v.bubbles[i].r=math.random(0,50)
		end
	end
	
	v.vars.time=v.vars.time+Game.dt
	if v.vars.time > (v.duration or 1) then return true end
end

--fixme: use v.color parameter
function aniFx.draw_bubbleExplosion (v)
	for i=1,#v.bubbles do
		local c =i%3
		if c == 0 then LG.setColor (1,1,1,0.8) end
		if c== 1 then  LG.setColor (0.5,0.5,0.5,0.5) end
		if c==2 then LG.setColor (v.color) end
		love.graphics.circle( "fill", v.bubbles[i].x, v.bubbles[i].y, v.bubbles[i].r,  16 )
		--LG.print (v.bubbles[i].r, v.x, v.y+(i*10))
	end
		--love.graphics.circle( "line", v.x, v.y, 50,  16 )
end
-------
function aniFx.draw_fadeScreen (v)
	local alpha = 0
	if v.timePercent and (v.timePercent) < 1 then alpha=v.timePercent end
	--local remainingTime =  v.timerEnd - v.timer
	--if remainingTime < 1 then alpha=remainingTime end

	love.graphics.setColor(v.color)
	love.graphics.rectangle ("fill", 0,0, res_w,  res_h/2*(1-v.timePercent))
	
	--love.graphics.setColor(0, 1, 0, 1)
	love.graphics.rectangle ("fill", 0, res_h/2+res_h/2*(v.timePercent), res_w, res_h/2)
	love.graphics.setColor(1, 1, 1, 1)
	--LG.print (res_h/2*(v.timer), 50, 30)	
end

function aniFx.draw_blindsFadeScreen (v)
	local alpha = 0
	if v.timePercent and (v.timePercent) < 1 then alpha=v.timePercent end
	love.graphics.setColor(v.color)
	local blinds = 20
	local blindHeight = res_h/blinds
	for i = 1,blinds, 1 do
		local h = (res_h/blinds)*(i-1)
		love.graphics.rectangle ("fill", 0, h, res_w, blindHeight*(1-v.timePercent))
	end
end

function aniFx.draw_circlesFadeScreen (v)
	local alpha = 0
	if v.timePercent and (v.timePercent) < 1 then alpha=v.timePercent end
	love.graphics.setColor(v.color)
	local r = 32
	for x=0, res_w, r*1.2 do
		for y=0, res_h, r*1.2 do
			LG.circle ("fill", x,y, r*(1-v.timePercent),8)
			--love.graphics.setColor(1, 1, 1, 1)
			--LG.print (res_h/2*(v.timer), 50, 30)	
		end
	end
end


function aniFx.update_expandExplosion (v)
	if not v.vars.time then
		v.vars.time = 0
		if not v.color then v.color={1,1,1,1} end
		if not v.color[4] then v.color[4] = 1 end --default alpha=1
		if not v.drawType then v.drawType = "lines" end
		v.vars.particles = {}
		local expandSpeed = v.expandSpeed or 300
		for i=1,(v.particlesNumber or 10),1 do
			local s = random(expandSpeed/4,expandSpeed*2)
			local a = rad(math.random (0,360))
			
			v.vars.particles[i]={x=v.x,y=v.y,xs=sin(a)*s,ys=cos(a)*s}
		end
	end
	for i=1,#v.vars.particles,1 do
		v.vars.particles[i].x=v.vars.particles[i].x+v.vars.particles[i].xs*Game.dt
		v.vars.particles[i].y=v.vars.particles[i].y+v.vars.particles[i].ys*Game.dt

	end
	v.vars.time=v.vars.time+Game.dt
	if (v.duration or 1)-v.vars.time < 1 then v.color[4]=v.color[4]-Game.dt end --fade alpha  
	if v.vars.time > (v.duration or 1) then return true end
end

function aniFx.draw_expandExplosion (v)
	if not v.vars.particles then return end
	for i=1,#v.vars.particles,1 do
		LG.setColor (v.color)
		local x,y= v.vars.particles[i].x, v.vars.particles[i].y
		if v.drawType=="lines" then
			LG.line (v.x,v.y,  x,y)
		elseif v.drawType == "circles" then
			LG.circle ("line",x,y,2,8)
		elseif v.drawType == "arcs" then
			local dir = (i%2)-0.5
			LG.arc ("line","open", x,y, 10, dir*v.vars.time*2*i,dir*v.vars.time*2*i+math.pi)
		end
	end
end

return aniFx
