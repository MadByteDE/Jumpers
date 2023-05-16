--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
--|                                  |--
--|            Jumpers.lua            |--
--|    Jumpers for a new lua file     |--
--|                                  |--
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
local Jumpers = {}


-- Initialize
function Jumpers.init()
    Jumpers.units = {}
end

function Jumpers.create(x, y)
    local jumper = {}
    jumper.x = x
    jumper.y = y
    jumper.width = 16
    jumper.height = 16
    jumper.color = {1, 0, 0}
    jumper.angle = 0
    jumper.power = 0
    jumper.speed = 100
    jumper.vx = 0
    jumper.vy = 0
    jumper.maxVel = 500
    jumper.remove = false
    jumper.body = LP.newBody(Map.world, x,y, "dynamic") 
	jumper.shape = LP.newCircleShape(32) 
	jumper.fixture = LP.newFixture(jumper.body, jumper.shape)
	table.insert(Jumpers.units, jumper)
end

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Private functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--
-- Public functions
--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^--

-- Main callbacks
function Jumpers.update(dt)
    for i=#Jumpers.units, 1, -1 do
        local jumper = Jumpers.units[i]
        -- Remove units when needed
        if jumper.remove then table.remove(Jumpers.units, i) return end
--[[
        -- Set landed
        if jumper.y >= Game.height - jumper.height then
            jumper.vx = 0
            jumper.vy = 0
            jumper.landed = true
            jumper.y = Game.height - jumper.height
        end
--]]
        -- Update center
        local center = {x=jumper.body:getX()+jumper.width/2, y= jumper.body:getY()+jumper.height/2}

        -- Calculate angle
        local mx, my = Sys.toGameCoords(LMouse.getPosition())
        jumper.angle = Sys.getAngle(center, {x=mx, y=my})

        -- Not on ground
       -- if not jumper.landed then
         --   -- Apply gravity
           -- jumper.vy = jumper.vy + Game.gravity * dt
        --else
            -- Jump on mouse press
            if LMouse.isDown(1) then
                jumper.power = jumper.power + 50 * dt
            elseif jumper.power > 0 then
                --jumper.vx = ((jumper.power*5) * math.sin(jumper.angle))
                --jumper.vy = ((jumper.power*5) * math.cos(jumper.angle))
                jumper.body:applyLinearImpulse ( ((jumper.power*5) * math.sin(jumper.angle)) , 
										((jumper.power*5) * math.cos(jumper.angle)) )
                jumper.power = 0
                jumper.landed = false
            end
        

        -- Clamp stuff
        jumper.power = Sys.clamp(jumper.power, 0, 100)
        jumper.vx = Sys.clamp(jumper.vx, -jumper.maxVel, jumper.maxVel)
        jumper.vy = Sys.clamp(jumper.vy, -jumper.maxVel, jumper.maxVel)

        
		jumper.x = jumper.body:getX()--jumper.x + jumper.vx * dt
		jumper.y = jumper.body:getY()--jumper.y + jumper.vy * dt
    end
end

function Jumpers.draw()
    for i=#Jumpers.units, 1, -1 do
        local jumper = Jumpers.units[i]
        -- Update center
        --local center = {x=jumper.x+jumper.width/2, y= jumper.y+jumper.height/2}
        local center = {x=jumper.body:getX(), y=jumper.body:getY()}
        LG.print("center.y:"..center.y, 100, 10)

        -- Draw Jumper
        LG.setColor(jumper.color)
        LG.rectangle("fill", jumper.x, jumper.y, jumper.width, jumper.height)
        LG.setColor(1, 1, 1)
        -- Draw jump line
        local line = {
            x = center.x + 16 * math.sin(jumper.angle),
            y = center.y + 16 * math.cos(jumper.angle),}
        LG.line(center.x, center.y, line.x, line.y)
        -- Draw power indicator
        if jumper.power > 0 then
            local x, y = jumper.x-64, jumper.y - 15
            LG.printf(math.floor(jumper.power), x, y, jumper.width+128, "center")
        end
    end
end

function Jumpers.keypressed(key)
end

function Jumpers.mousepressed(x, y, button)
end

return Jumpers
