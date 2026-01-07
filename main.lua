scalar = 10

Ui = require("ui")
PixelService = require("pixelservice")
Gui = require("gui")

function love.load()
    love.mouse.setVisible( false )
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(0.078,0.070,0.090)

    PixelService:load()
    Ui:load()
    Gui:load()
end


function love.update(dt)
    PixelService:update(dt)
    Ui:update(dt)
    Gui:update(dt)

    mousejustpressed = false
    justkeypressed = ""
end


function love.mousemoved( x, y, dx, dy, istouch )
    Ui:mousemoved(x,y,dx,dy,istouch)
end

function love.draw()
    PixelService:draw()
    Ui:draw()
    Gui:draw()

    local x, y = love.mouse.getPosition()
    if PixelService.tooLight and not(Ui.overUI) and Ui.objectHovering == nil then love.graphics.setColor(0, 0, 0) end
    love.graphics.draw(Ui.currentIco, x, y, 0, 2, 2, Ui.currentIco:getWidth()/2, Ui.currentIco:getHeight() / 2)
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
