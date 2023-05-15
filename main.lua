
-- Jumpers

function love.load()
end

function love.update(dt)
end

function love.draw()
    love.graphics.print("Hello World.")
    love.graphics.print("Hello World 2",100,100)
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
end

function love.mousepressed(x, y, button)
end

function love.quit()
end
