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

function Jumper.create(x, y)
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
    jumper.body = LP.newBody(Game.world, x,y, "dynamic")
	jumper.shape = LP.newCircleShape(32)
	jumper.fixture = LP.newFixture(jumper.body, jumper.shape)
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
        LG.print("center.y:"..center.y, 5, 5)

        -- Draw Jumper
        LG.setColor(jumper.color)
        LG.rectangle("fill", jumper.x, jumper.y, jumper.width, jumper.height)
        LG.setColor(1, 1, 1)

        -- Draw jump line
        local line = {}
        line.x = center.x + 16 * math.sin(jumper.angle)
        line.y = center.y + 16 * math.cos(jumper.angle)
        LG.line(center.x, center.y, line.x, line.y)

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
