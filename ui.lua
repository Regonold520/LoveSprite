local ui = {}

ui.font = love.graphics.newFont("AsepriteFont.ttf", 64)
ui.txt = love.graphics.newText(ui.font, "File")
ui.panning = false
ui.currentWindowSize = {w=1869, h=948}
ui.currentIco = nil
ui.overUI = false

ui.objectHovering = nil

ui.dragXable = false
ui.dragYable = true

ui.slices = {}
ui.buttons = {}

ui.currentColourPicker = {x=0,y=0}

ui.screenBounds = {
    left = {
        x=400,
        y = 98,
        scale = {
            x=2, 
            y=love.graphics.getHeight() - 220 - 77
        }
    },

    right = {
        x=love.graphics.getWidth() - 40,
        y = 98,
        scale = {
            x=2, 
            y=love.graphics.getHeight() - 220 - 77
        }
    },

    bottom = {
        x= 0,
        y = love.graphics.getHeight() - 200,
        scale = {
            x=0,
            y=0
        }
    }
}


function ui:load()
    ui.cursorIco = love.graphics.newImage("cursorSprite.png")
    ui.cursorPanIco = love.graphics.newImage("panSprite.png")
    ui.cursorMouseIco = love.graphics.newImage("pointerCursor.png")
    ui.cursorDragXIco = love.graphics.newImage("dragXCursor.png")
    ui.cursorDragYIco = love.graphics.newImage("dragYCursor.png")
    ui.cursorDragXYIco = love.graphics.newImage("dragXYCursor.png")

    ui.buttonSprite = love.graphics.newImage("darkbutton.png")
    ui.buttonHoverSprite = love.graphics.newImage("darkhoverbutton.png")
    ui.buttonClickSprite = love.graphics.newImage("darkclickbutton.png")

    s = register9Slice("dark9slice.png", "dark")
    s.sizeX = 70
    s.sizeY = 105

    s2 = register9Slice("light9slice.png", "light")
    s2.sizeX = 70
    s2.sizeY = 7

    s.pos = {x=300,y=100}
    s2.pos = {x=300,y=100}

    bu = registerButton("darkbutton.png", "dark")
    bu.sizeX = 32

    bu.pos = {x=320,y=160}
end

function ui:update(dt)
    x,y = love.mouse.getPosition()
    if not(x > ui.screenBounds.left.x and x < ui.screenBounds.right.x) or not(y > ui.screenBounds.left.y and y <  ui.screenBounds.bottom.y) then
        if ui.objectHovering == nil then
            ui.objectHovering = {layer=0, type="bg"}
        end
    else
        ui.objectHovering = nil
    end

    bu.sizeX = bu.text:getWidth() / 6
    ui.screenBounds.right.scale.y = ui.screenBounds.bottom.y - 97
    ui.screenBounds.left.scale.y = ui.screenBounds.bottom.y - 97
    ui:checkObjectCulling()
end

function ui:draw()
    local x, y = love.mouse.getPosition()
    
    ui.currentIco = ui.cursorIco
    if ui.panning then ui.currentIco = ui.cursorPanIco end
    ui:checkMouseIco()
    

    love.graphics.setColor(0.17254901960784313, 0.17254901960784313, 0.18823529411764706)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 50)

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), 50)




    love.graphics.rectangle("fill", ui.screenBounds.right.x, 50, love.graphics:getWidth() - ui.screenBounds.right.x , love.graphics.getHeight() - 50)



    love.graphics.rectangle("fill", 0, 50, clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x) , love.graphics.getHeight())

    love.graphics.rectangle("fill", 0, clamp(ui.screenBounds.left.y, ui.screenBounds.bottom.y, 9999), love.graphics.getWidth() , love.graphics:getHeight() - ui.screenBounds.bottom.y)
    love.graphics.setColor(0.34, 0.34, 0.34)

    love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), 3)

    love.graphics.setColor(0, 0, 0)

    love.graphics.rectangle("fill", 0, 48, love.graphics.getWidth()  , 2)

    
    love.graphics.rectangle("fill", clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x), ui.screenBounds.left.y, ui.screenBounds.right.x - clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x), 2)


    love.graphics.rectangle("fill", clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x), ui.screenBounds.left.y , ui.screenBounds.left.scale.x, clamp(0,ui.screenBounds.left.scale.y, 999)) 




    love.graphics.rectangle("fill", clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x), clamp(ui.screenBounds.left.y, ui.screenBounds.bottom.y, 9999), ui.screenBounds.right.x - clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x), 2)
    love.graphics.rectangle("fill", ui.screenBounds.right.x, ui.screenBounds.left.y, ui.screenBounds.right.scale.x, clamp(0, ui.screenBounds.right.scale.y, 9999) )

    love.graphics.setColor(1, 1, 1)


    love.graphics.draw(ui.txt,5,-5,0,0.6,0.6)

    ui:draw9slices()
    ui:drawButtons()

    ui:drawColour()

    love.graphics.draw(ui.currentIco, x, y, 0, 2, 2, ui.currentIco:getWidth()/2, ui.currentIco:getHeight() / 2)
    
end

local function hsv(h, s, v)
    if s <= 0 then return v,v,v end
    h = h*6
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return r+m, g+m, b+m
end

function ui:drawColour()
    if ui.currentColourPicker.x ~= (ui.screenBounds.left.x/2) - 10 or ui.currentColourPicker.y ~= (love.graphics:getHeight() - (ui.screenBounds.left.y + ui.screenBounds.left.scale.y))/2 - 5 - 10 then
        print("oh la la")
        ui.currentColourPicker = {x=(ui.screenBounds.left.x/2) - 10,y=(love.graphics:getHeight() - (ui.screenBounds.left.y + ui.screenBounds.left.scale.y))/2 - 5}
        if ui.currentColourPicker.x > 1 and ui.currentColourPicker.y > 1 then
            local testImgData = love.image.newImageData((ui.screenBounds.left.x/2) - 10, (love.graphics:getHeight() - (ui.screenBounds.left.y + ui.screenBounds.left.scale.y))/2 - 5)
            local imgX,imgY = testImgData:getDimensions()
            for x=0,imgX-1 do
                for y=0,imgY-1 do
                    local r,g,b = hsv(0.3,((1/imgX)*x),1-(1/imgY)*y)
                    testImgData:setPixel(x,y,r,g,b,1)
                end
            end

            colorPickerImg = love.graphics.newImage(testImgData)

        end
        
    end
    love.graphics.draw(colorPickerImg,10,ui.screenBounds.left.y + ui.screenBounds.left.scale.y ,0,2,2)
end

function ui:draw9slices()
    local scaleSize = 2 
    for _,slice in pairs(ui.slices) do
        for i,part in pairs(slice.parts) do
            if part == slice.parts.t then 
                love.graphics.draw(slice.sprite,part.q, slice.pos.x + (part.offset.x * scaleSize),(slice.pos.y + (part.offset.y) * scaleSize), 0,scaleSize * (slice.sizeX+0.5)*2,scaleSize,0,0)
            elseif part == slice.parts.b then 
                love.graphics.draw(slice.sprite,part.q, slice.pos.x + (part.offset.x * scaleSize),slice.pos.y + ((part.offset.y + (part.move.y * slice.sizeY)) * scaleSize), 0,scaleSize * (slice.sizeX+0.5)*2,scaleSize,0,0)
            elseif part == slice.parts.l then 
                love.graphics.draw(slice.sprite,part.q, slice.pos.x + (part.offset.x * scaleSize),(slice.pos.y + (part.offset.y-scaleSize) * scaleSize), 0,scaleSize,scaleSize * (slice.sizeY+1)*2,0,0)
            elseif part == slice.parts.r then 
                love.graphics.draw(slice.sprite,part.q, slice.pos.x + ((part.offset.x + (part.move.x * slice.sizeX)) * scaleSize),(slice.pos.y + (part.offset.y) * scaleSize), 0,scaleSize,scaleSize * (slice.sizeY+0.5)*2,0,0)
            elseif part == slice.parts.m then 
                love.graphics.draw(slice.sprite,part.q, slice.pos.x + (part.offset.x * scaleSize),(slice.pos.y + (part.offset.y) * scaleSize), 0,scaleSize * (slice.sizeX+0.5)*2,scaleSize * (slice.sizeY+0.5)*2,0,0)
            else
                love.graphics.draw(slice.sprite,part.q, slice.pos.x + ((part.offset.x + (part.move.x * slice.sizeX)) * scaleSize),slice.pos.y + ((part.offset.y + (part.move.y * slice.sizeY)) * scaleSize), 0,scaleSize,scaleSize,0,0)
            end

        end
    end
end

function ui:drawButtons()
    local scaleSize = 2
    for _,slice in pairs(ui.buttons) do
        for i,part in pairs(slice.parts) do
            if part == slice.parts.t then 
                love.graphics.draw(slice.sprite,part.q, slice.pos.x + (part.offset.x * scaleSize),(slice.pos.y + (part.offset.y) * scaleSize), 0,scaleSize * (slice.sizeX+0.5)*2,scaleSize,0,0)
            else
                love.graphics.draw(slice.sprite,part.q, slice.pos.x + ((part.offset.x + (part.move.x * slice.sizeX)) * scaleSize),slice.pos.y + ((part.offset.y + (part.move.y * slice.sizeY)) * scaleSize), 0,scaleSize,scaleSize,0,0)
            end



        end
        love.graphics.draw(slice.text,slice.pos.x + ((slice.parts.t.offset.x + (slice.parts.t.move.x * slice.sizeX)) * scaleSize) - (slice.text:getWidth() / 3.58),slice.pos.y + ((slice.parts.t.offset.y + (slice.parts.t.move.y * slice.sizeY)) * scaleSize)-2,0,scaleSize/3.5,scaleSize/3.5)
    end
end

ui.camX = 0
ui.camY = 0
function ui:mousemoved( x, y, dx, dy, istouch )
    if panning then
        ui.camX = ui.camX + dx
        ui.camY = ui.camY + dy
    end

    if ui.dragXable and love.mouse.isDown(1) then
        ui.screenBounds.left.x = clamp(20, ui.screenBounds.left.x + dx, ui.screenBounds.right.x)
    end

    if ui.dragYable and love.mouse.isDown(1) then
        ui.screenBounds.bottom.y = clamp(ui.screenBounds.left.y, ui.screenBounds.bottom.y + dy, love.graphics:getHeight() - 20)
    end
end

function ui:checkObjectCulling()
    local x,y = love.mouse.getPosition()
    for _,i in pairs(ui.slices) do
        if x > i.pos.x and x < i.pos.x + ((i.parts.tr.offset.x + (i.parts.tr.move.x * i.sizeX)) * 2) then
            
            if y > i.pos.y and y < i.pos.y + ((i.parts.br.offset.y + (i.parts.br.move.y * i.sizeY)) * 2) then
                ui:queryHoverChange(i)
            end
        end
    end

    for _,i in pairs(ui.buttons) do
        if x > i.pos.x and x < i.pos.x + ((i.parts.tr.offset.x + (i.parts.tr.move.x * i.sizeX)) * 2) then
            
            if y > i.pos.y and y < i.pos.y + 18 * 2 then
                local result = ui:queryHoverChange(i)
                if result then
                    i.sprite = ui.buttonHoverSprite

                    if love.mouse.isDown(1) then
                        i.sprite = ui.buttonClickSprite
                    end
                else
                    i.sprite = ui.buttonSprite
                end
            else
                i.sprite = ui.buttonSprite
            end
        else
            i.sprite = ui.buttonSprite
        end
    end
end

function ui:queryHoverChange(inputObj)
    if ui.objectHovering == nil then
        ui.objectHovering = inputObj
    end

    if inputObj.layer >= ui.objectHovering.layer then
        ui.objectHovering = inputObj
    end

    return ui.objectHovering == inputObj
end

function ui:checkMouseIco()
    x,y = love.mouse.getPosition()

    if ui.objectHovering ~= nil then
        ui.currentIco = ui.cursorMouseIco
    end

    if x < ui.screenBounds.left.x + 10 and x > ui.screenBounds.left.x - 10 and y > ui.screenBounds.left.y and  y < ui.screenBounds.bottom.y + 10 and ui.objectHovering ~= nil then
        if ui.objectHovering.type == "bg" then
            ui.currentIco = ui.cursorDragXIco
            ui.dragXable = true
        end
    else    
        ui.dragXable = false
    end

    if y < ui.screenBounds.bottom.y + 10 and y > ui.screenBounds.bottom.y - 10 and x > ui.screenBounds.left.x - 10 and x < ui.screenBounds.right.x and ui.objectHovering ~= nil then
        if ui.objectHovering.type == "bg" then
            ui.currentIco = ui.cursorDragYIco
            ui.dragYable = true
        end
    else    
        ui.dragYable = false
    end

    if ui.dragXable and ui.dragYable  then
        ui.currentIco = ui.cursorDragXYIco
    end

    ui.overUI = not(x > ui.screenBounds.left.x and x < ui.screenBounds.right.x) or not(y > ui.screenBounds.left.y and y < ui.screenBounds.left.y + ui.screenBounds.left.scale.y)

end

function love.resize(w, h)
    diffX = ui.currentWindowSize.w - w
    diffY = ui.currentWindowSize.h - h

    


    ui.screenBounds.left.scale.y = love.graphics.getHeight() - 220 - 77
    ui.screenBounds.right.scale.y = love.graphics.getHeight() - 220 - 77


    if ui.screenBounds.right.x - diffX < ui.screenBounds.left.x then
        ui.screenBounds.right.x = ui.screenBounds.right.x - diffX
    else
        ui.screenBounds.right.x = ui.screenBounds.right.x - diffX
    end

    if ui.screenBounds.bottom.y - diffY < ui.screenBounds.left.y then
        ui.screenBounds.bottom.y = ui.screenBounds.left.y
    else
        if diffY > 0 or ui.screenBounds.bottom.y - diffY > ui.screenBounds.left.y then
            if ui.screenBounds.bottom.y - diffY < love.graphics.getHeight() then
                ui.screenBounds.bottom.y = ui.screenBounds.bottom.y - diffY
            end
        end
    end

    ui.currentWindowSize = {w=w,h=h}
end

function ui:wheelmoved(x,y)
    if y == 0 then return end

    local mx, my = love.mouse.getPosition()

    local old = scalar
    local zoomStep = 1.15

    if y > 0 then
        scalar = math.min(scalar * zoomStep, 50)
    else
        scalar = math.max(scalar / zoomStep, 0.01)
    end

    local cx, cy = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2

    ui.camX = ui.camX + (mx - cx - ui.camX) * (1 - scalar / old)
    ui.camY = ui.camY + (my - cy - ui.camY) * (1 - scalar / old)
end

function ui:mousepressed(x, y, button, istouch)
    if button == 3 then
        panning = true
   end
end

function ui:mousereleased(x, y, button)
    if button == 1 or button == 2 then
        if #PixelService.localCurrentPx > 0 then
            table.insert(PixelService.localBigPx, PixelService.localCurrentPx)
        end

        PixelService.localCurrentPx = {}
        PixelService.localCurrentPxSet = {}
        PixelService.lastPx = nil
    end

    if button == 3 then
        panning = false
    end

    if ui.objectHovering ~= nil then
        if ui.objectHovering.type == "button" then
            print("chat we have an eriosa")
        end
    end
end


control = false
function ui:keypressed( key, scancode, isrepeat )
   if scancode == "lctrl" then
      control = true
   end

    if control and scancode == "z" then
        local targetEntry = table.remove(PixelService.localBigPx)
        if targetEntry ~= nil then
            for _,i in pairs(targetEntry) do
            PixelService:setPixelFast(imgData, i.x, i.y, i.old.r, i.old.g, i.old.b, i.old.a, false)
            end
        end
    end
end

function ui:keyreleased( key, scancode, isrepeat )
   if scancode == "lctrl" then
      control = false
   end
end


local lastX, lastY = 0,0
function updateCursor(mX,mY)
    cursorImgData = love.image.newImageData(64,64)
    local pX, pY = PixelService:posToPixel(cursorImg,love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,mX, mY)
    local w, h = cursorImgData:getDimensions()
    local r,g,b,a = 0,0,1,1
    if lastX ~= mX or lastY ~= mY and not(ui.overUI)then
        lastX, lastY = mX, mY
        if pX >= 0 and pY >= 0 and pX < w and pY < h then
            PixelService:setPixelFast(cursorImgData, pX, pY, PixelService.currentColour.r, PixelService.currentColour.g, PixelService.currentColour.b, PixelService.currentColour.a, false)
        end
        
        cursorImg = love.graphics.newImage(cursorImgData)
    end
end

function register9Slice(spritePath, id)
    local sprite = love.graphics.newImage(spritePath)

    local slice = {    
        sizeX = 0,
        sizeY = 0,
        pos = {x=0,y=0},
        layer = 1,
        type = "9slice",
        parts = {    
            tl = {q=love.graphics.newQuad(0,0,3,3,sprite:getWidth(),sprite:getHeight()),offset={x=0,y=0},move={x=0,y=0}},
            t = {q=love.graphics.newQuad(3,0,1,3,sprite:getWidth(),sprite:getHeight()),offset={x=3,y=0},move={x=1,y=0}},
            tr = {q=love.graphics.newQuad(4,0,3,3,sprite:getWidth(),sprite:getHeight()),offset={x=4,y=0},move={x=2,y=0}},
            r = {q=love.graphics.newQuad(4,3,3,1,sprite:getWidth(),sprite:getHeight()),offset={x=4,y=3},move={x=2,y=1}},
            br = {q=love.graphics.newQuad(4,4,3,3,sprite:getWidth(),sprite:getHeight()),offset={x=4,y=4},move={x=2,y=2}},
            b = {q=love.graphics.newQuad(3,4,1,3,sprite:getWidth(),sprite:getHeight()),offset={x=3,y=4},move={x=1,y=2}},
            bl = {q=love.graphics.newQuad(0,4,3,3,sprite:getWidth(),sprite:getHeight()),offset={x=0,y=4},move={x=0,y=2}},
            l = {q=love.graphics.newQuad(0,3,3,1,sprite:getWidth(),sprite:getHeight()),offset={x=0,y=4},move={x=0,y=1}},
            m = {q=love.graphics.newQuad(3,3,1,1,sprite:getWidth(),sprite:getHeight()),offset={x=3,y=3},move={x=0,y=0}}
            
        },
        sprite = sprite
    }

    ui.slices[id] = slice
    return slice
end

function registerButton(spritePath, id)
    local sprite = love.graphics.newImage(spritePath)
    local text = love.graphics.newText(ui.font, "Erio Cheller")

    local slice = {    
        text = text,
        sizeX = 0,
        sizeY = 0,
        layer = 2,
        type = "button",
        pos = {x=0,y=0},
        parts = {    
            tl = {q=love.graphics.newQuad(0,0,3,18,sprite:getWidth(),sprite:getHeight()),offset={x=0,y=0},move={x=0,y=0}},
            t = {q=love.graphics.newQuad(3,0,1,18,sprite:getWidth(),sprite:getHeight()),offset={x=3,y=0},move={x=1,y=0}},
            tr = {q=love.graphics.newQuad(4,0,3,18,sprite:getWidth(),sprite:getHeight()),offset={x=4,y=0},move={x=2,y=0}},
        },
        sprite = sprite
    }

    ui.buttons[id] = slice
    return slice
end

return ui