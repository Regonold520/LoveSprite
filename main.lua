scalar = 10

Ui = require("ui")
PixelService = require("pixelservice")

function love.load()
    love.mouse.setVisible( false )
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(love.math.colorFromBytes(32, 33, 37))

    PixelService:load()
    Ui:load()
end


function love.update(dt)
    PixelService:update(dt)
    Ui:update(dt)
end


function love.mousemoved( x, y, dx, dy, istouch )
    Ui:mousemoved(x,y,dx,dy,istouch)
end

function love.draw()
    PixelService:draw()
    Ui:draw()
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function love.wheelmoved(x, y)
    Ui:wheelmoved(x, y)
end

function love.mousepressed(x, y, button, istouch)
    Ui:mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button)
   Ui:mousereleased(x,y,button)
end

function love.keypressed( key, scancode, isrepeat )
    Ui:keypressed( key, scancode, isrepeat )
end

function love.keyreleased( key, scancode, isrepeat )
   Ui:keyreleased( key, scancode, isrepeat )
end
