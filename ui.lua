local ui = {}

ui.font = love.graphics.newFont("AsepriteFont.ttf", 64)
ui.txt = love.graphics.newText(ui.font, "File")
ui.panning = false
ui.currentWindowSize = {w=1869, h=948}
ui.currentIco = nil
ui.overUI = false

ui.objectHovering = nil
ui.colourDragging = false
ui.hueDragging = false

ui.currentHue = 0

ui.dragXable = false
ui.dragYable = true

ui.draggingX = false
ui.draggingY = false

ui.slices = {}
ui.buttons = {}
ui.textBoxes = {}
ui.toolButtons = {}

ui.currentColourPicker = {x=0,y=0,layer=2,type="colourPicker"}
ui.currentHuePicker = {x=0,y=0,layer=2,type="huePicker"}

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
    ui.cursorEyedropIco = love.graphics.newImage("eyedropCursor.png")

    ui.buttonSprite = love.graphics.newImage("darkbutton.png")
    ui.buttonHoverSprite = love.graphics.newImage("darkhoverbutton.png")
    ui.buttonClickSprite = love.graphics.newImage("darkclickbutton.png")

    ui.textBoxSprite = love.graphics.newImage("textbox.png")
    ui.textBoxHoverSprite = love.graphics.newImage("textboxhover.png")

    ui.colourSelectHover = {sprite=love.graphics.newImage("colourselecthover.png"),x=0,y=0}
    ui.colourSelectHoverLight = love.graphics.newImage("colourselecthoverlight.png")

    ui.hueSelectHover = {sprite=love.graphics.newImage("colourselecthover.png"),x=0,y=0}
    

    --s = register9Slice("dark9slice.png", "dark")
    --s.sizeX = 70
    --s.sizeY = 105

    --s2 = 
    --s2.sizeX = 70
    --s2.sizeY = 7

    --s.pos = {x=100,y=100}
    --s2.pos = {x=100,y=100}

    --bu = 
    --bu.sizeX = 32

    --bu.pos = {x=120,y=160}

    registerToolButton("brush")
    registerToolButton("eraser")
    registerToolButton("eyedropper")
    registerToolButton("paintbucket")
    registerToolButton("noise")
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

    --bu.sizeX = bu.text:getWidth() / 6
    ui.screenBounds.right.scale.y = ui.screenBounds.bottom.y - 97
    ui.screenBounds.left.scale.y = ui.screenBounds.bottom.y - 97

    ui:checkObjectCulling()
    if ui.objectHovering ~= nil then
        --print(ui.objectHovering.type)
    end
end

function ui:draw()
    local x, y = love.mouse.getPosition()
    
    ui.currentIco = ui.cursorIco
    if ui.panning then ui.currentIco = ui.cursorPanIco end
    ui:checkMouseIco()
    

    love.graphics.setColor(0.211, 0.196, 0.235)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 50)

    love.graphics.setColor(0.145, 0.137, 0.156)
    love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), 50)




    love.graphics.rectangle("fill", ui.screenBounds.right.x, 50, love.graphics:getWidth() - ui.screenBounds.right.x , love.graphics.getHeight() - 50)



    love.graphics.rectangle("fill", 0, 50, clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x) , love.graphics.getHeight())

    love.graphics.rectangle("fill", 0, clamp(ui.screenBounds.left.y, ui.screenBounds.bottom.y, 9999), love.graphics.getWidth() , love.graphics:getHeight() - ui.screenBounds.bottom.y)
    love.graphics.setColor(0.247, 0.235, 0.258)

    love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), 3)

    love.graphics.setColor(0, 0, 0)

    love.graphics.rectangle("fill", 0, 48, love.graphics.getWidth()  , 2)

    
    love.graphics.rectangle("fill", clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x), ui.screenBounds.left.y, ui.screenBounds.right.x - clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x), 2)


    love.graphics.rectangle("fill", clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x), ui.screenBounds.left.y , ui.screenBounds.left.scale.x, clamp(0,ui.screenBounds.left.scale.y, 999)) 




    love.graphics.rectangle("fill", clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x), clamp(ui.screenBounds.left.y, ui.screenBounds.bottom.y, 9999), ui.screenBounds.right.x - clamp(0, ui.screenBounds.left.x, ui.screenBounds.right.x), 2)
    love.graphics.rectangle("fill", ui.screenBounds.right.x, ui.screenBounds.left.y, ui.screenBounds.right.scale.x, clamp(0, ui.screenBounds.right.scale.y, 9999) )

    love.graphics.setColor(1, 1, 1)

    
    ui:drawColour()
    ui:drawHue()
    ui:drawToolButtons()
    ui:draw9slices()
    ui:drawButtons()

    
    

    
    
end

function ui:drawToolButtons()
    local count = 0
    local mX, mY = love.mouse.getPosition()
    for _,i in pairs(ui.toolButtons) do
        local chosenSprite = i.sprite

        if i.toolType == PixelService.currentTool then
            chosenSprite = i.selectedSprite
        end

        if mX > ui.screenBounds.right.x + 5 and mX < ui.screenBounds.right.x + 5 + 32 then
            if mY > (ui.screenBounds.right.y + ((count * 17)*2)) and mY < (ui.screenBounds.right.y + ((count * 17)*2) + 32) then
                local result = ui:queryHoverChange(i)
                

                if result then
                    chosenSprite = i.selectedSprite
                    if love.mouse.isDown(1) then
                        if PixelService.currentTool ~= "noise" then
                            PixelService.currentTool = i.toolType
                        end
                    end
                end
            end
        end


        love.graphics.draw(chosenSprite, ui.screenBounds.right.x + 5, ui.screenBounds.right.y + ((count * 17)*2), 0, 2, 2)
    
        

        count = count + 1
    end
end

function hsv(h, s, v)
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

function rgbToHsv(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v
    v = max

    local d = max - min
    if max == 0 then
        s = 0
        h = 0
    else
        s = d / max
        if max == r then
            h = (g - b) / d % 6
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
        if h < 0 then h = h + 1 end
    end

    return h, s, v
end


function ui:drawColour()
    local mX, mY = love.mouse.getPosition()
    if ui.currentColourPicker.x ~= (ui.screenBounds.left.x/2) - 10 or ui.currentColourPicker.y ~= (love.graphics:getHeight() - (ui.screenBounds.left.y + ui.screenBounds.left.scale.y))/2 - 5 - 50 then
        if colorPickerImgData ~= nil then
            local xEqu = math.floor(((ui.currentColourPicker.x - colorPickerImg:getWidth() - 10) + mX) / 2) 
            local yEqu = math.floor((mY - ((love.graphics:getHeight() - 50) - colorPickerImg:getHeight()*2)) / 2)

            if ui.colourDragging and love.mouse.isDown(1) then
                xEqu = clamp(0, xEqu, colorPickerImgData:getWidth()  - 1)
                yEqu = clamp(0, yEqu, colorPickerImgData:getHeight() - 1)

                ui.colourDragging = true
                local newR, newG, newB, newA = colorPickerImgData:getPixel(xEqu,yEqu)
                PixelService.currentColour = {r=newR,g=newG,b=newB,1}
                ui.colourSelectHover.x = xEqu
                ui.colourSelectHover.y = yEqu

                ui.colourSelectHover.lastX = xEqu / colorPickerImgData:getWidth()
                ui.colourSelectHover.lastY = yEqu / colorPickerImgData:getHeight()

            end

            if ui.colourSelectHover.lastX ~= nil and not love.mouse.isDown(1) then
                ui.colourSelectHover.x = math.floor(
                    ui.colourSelectHover.lastX * colorPickerImgData:getWidth()
                )
                ui.colourSelectHover.y = math.floor(
                    ui.colourSelectHover.lastY * colorPickerImgData:getHeight()
                )
            end
        end
        ui.currentColourPicker = {x=(ui.screenBounds.left.x/2) - 10,y=(love.graphics:getHeight() - 50)/2 - 5,layer=1,type="colourPicker"}
        if ui.currentColourPicker.x > 1 and ui.currentColourPicker.y > 1 then
            local testImgData = love.image.newImageData((ui.screenBounds.left.x/2) - 10,100)
            local imgX,imgY = testImgData:getDimensions()
            for x=0,imgX-1 do
                for y=0,imgY-1 do
                    local r,g,b = hsv(ui.currentHue,((1/imgX)*x),1-(1/imgY)*y)


                    testImgData:setPixel(x,y,r,g,b,1)
                end
            end

            colorPickerImg = love.graphics.newImage(testImgData)
            colorPickerImgData = testImgData

        end
        
    end
    love.graphics.draw(colorPickerImg,10,(love.graphics:getHeight() - 50)- colorPickerImg:getHeight()*2  ,0,2,2)

    local newH,newS,newV = rgbToHsv(PixelService.currentColour.r,PixelService.currentColour.g,PixelService.currentColour.g)
    local pickerImg = ui.colourSelectHover.sprite
    if newV < 0.5 then pickerImg = ui.colourSelectHoverLight end

    love.graphics.draw(pickerImg,
    10 + (ui.colourSelectHover.x * 2),
    ((love.graphics:getHeight() - 50) - colorPickerImg:getHeight() * 2) + (ui.colourSelectHover.y * 2),
    0, 2, 2,
    ui.colourSelectHover.sprite:getWidth() / 2,
    ui.colourSelectHover.sprite:getHeight() / 2
)

end


function ui:drawHue()
    local mX, mY = love.mouse.getPosition()
    if ui.currentHuePicker.x ~= (ui.screenBounds.left.x/2) - 10 or ui.currentHuePicker.y ~= (love.graphics:getHeight() - (ui.screenBounds.left.y + ui.screenBounds.left.scale.y))/2 - 5 - 10 then
        if huePickerImgData ~= nil then
            local xEqu = math.floor(((ui.currentHuePicker.x - huePickerImg:getWidth() - 10) + mX) / 2) 
            local yEqu = math.floor((mY - ((love.graphics:getHeight() - 10) - huePickerImg:getHeight()*2)) / 2)

            if ui.hueDragging and love.mouse.isDown(1) then
                ui:queryHoverChange(ui.currentHuePicker)
                xEqu = clamp(0, xEqu, huePickerImgData:getWidth()  - 1)
                yEqu = clamp(0, yEqu, huePickerImgData:getHeight() - 1)


                ui.hueDragging = true
                local newR, newG, newB, newA = huePickerImgData:getPixel(xEqu,yEqu)

                ui.currentHue = xEqu / huePickerImgData:getWidth()

                local prevR = PixelService.currentColour.r
                local prevG = PixelService.currentColour.g
                local prevB = PixelService.currentColour.b
                local h, s, v = rgbToHsv(prevR, prevG, prevB)

                local r, g, b = hsv(ui.currentHue, s, v)

                PixelService.currentColour = {r=r, g=g, b=b, 1}
                ui.hueSelectHover.x = xEqu
                ui.hueSelectHover.y = yEqu

                ui.hueSelectHover.lastX = xEqu / huePickerImgData:getWidth()
                ui.hueSelectHover.lastY = yEqu / huePickerImgData:getHeight()

            end

            if ui.hueSelectHover.lastX ~= nil and not love.mouse.isDown(1) then
                ui.hueSelectHover.x = math.floor(
                    ui.hueSelectHover.lastX * huePickerImgData:getWidth()
                )
                ui.hueSelectHover.y = math.floor(
                    ui.hueSelectHover.lastY * huePickerImgData:getHeight()
                )
            end
        end
        ui.currentHuePicker = {x=(ui.screenBounds.left.x/2) - 10,y=(love.graphics:getHeight() - 10)/2 - 5,layer=1,type="huePicker"}
        if ui.currentHuePicker.x > 1 and ui.currentHuePicker.y > 1 then
            local testImgData = love.image.newImageData((ui.screenBounds.left.x/2) - 10,15)
            local imgX,imgY = testImgData:getDimensions()
            for x=0,imgX-1 do
                for y=0,imgY-1 do
                    local r,g,b = hsv(((1/imgX)*x),1,1)
                    testImgData:setPixel(x,y,r,g,b,1)
                end
            end

            huePickerImg = love.graphics.newImage(testImgData)
            huePickerImgData = testImgData

        end
        
    end
    love.graphics.draw(huePickerImg,10,(love.graphics:getHeight() - 10)- huePickerImg:getHeight()*2  ,0,2,2)
    
    love.graphics.draw(ui.hueSelectHover.sprite,
        10 + (ui.hueSelectHover.x * 2),
        ((love.graphics:getHeight() - 10) - huePickerImg:getHeight()) ,
        0, 2, 2,
        ui.hueSelectHover.sprite:getWidth() / 2,
        ui.hueSelectHover.sprite:getHeight() / 2
)

end

function ui:draw9slices()
    local scaleSize = 2 
    for _,slice in pairs(ui.slices) do
        if not(slice.bound) then
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
end

function ui:draw9sliceSingular(slice)
    local scaleSize = 2 
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

function ui:drawButtons()
    local scaleSize = 2
    for _,slice in pairs(ui.buttons) do
        if not(slice.bound) then
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
end


function ui:drawButtonSingular(slice)
    local scaleSize = 2
    for i,part in pairs(slice.parts) do
        if part == slice.parts.t then 
            love.graphics.draw(slice.sprite,part.q, slice.pos.x + (part.offset.x * scaleSize),(slice.pos.y + (part.offset.y) * scaleSize), 0,scaleSize * (slice.sizeX+0.5)*2,scaleSize,0,0)
        else
            love.graphics.draw(slice.sprite,part.q, slice.pos.x + ((part.offset.x + (part.move.x * slice.sizeX)) * scaleSize),slice.pos.y + ((part.offset.y + (part.move.y * slice.sizeY)) * scaleSize), 0,scaleSize,scaleSize,0,0)
        end



    end
    love.graphics.draw(slice.text,slice.pos.x + ((slice.parts.t.offset.x + (slice.parts.t.move.x * slice.sizeX)) * scaleSize) - (slice.text:getWidth() / 3.58),slice.pos.y + ((slice.parts.t.offset.y + (slice.parts.t.move.y * slice.sizeY)) * scaleSize)-2,0,scaleSize/3.5,scaleSize/3.5)
end


function ui:drawTextBoxSingular(slice)
    local scaleSize = 2
    for i,part in pairs(slice.parts) do
        if part == slice.parts.t then 
            love.graphics.draw(slice.sprite,part.q, slice.pos.x + (part.offset.x * scaleSize),(slice.pos.y + (part.offset.y) * scaleSize), 0,scaleSize * (slice.sizeX+0.5)*2,scaleSize,0,0)
        else
            love.graphics.draw(slice.sprite,part.q, slice.pos.x + ((part.offset.x + (part.move.x * slice.sizeX)) * scaleSize),slice.pos.y + ((part.offset.y + (part.move.y * slice.sizeY)) * scaleSize), 0,scaleSize,scaleSize,0,0)
        end



    end
    love.graphics.draw(slice.text,slice.pos.x + 8,slice.pos.y + ((slice.parts.t.offset.y + (slice.parts.t.move.y * slice.sizeY)) * scaleSize)-4,0,scaleSize/3.5,scaleSize/3.5)
end


ui.camX = 0
ui.camY = 0
function ui:mousemoved( x, y, dx, dy, istouch )
    if ui.colourDragging and ui.hueDragging and not ui.dragXable and not ui.dragYable then
    return
end

    if panning then
        ui.camX = ui.camX + dx
        ui.camY = ui.camY + dy
    end

    if (ui.dragXable or ui.draggingX) and love.mouse.isDown(1) then
        ui.draggingX = true
        ui.screenBounds.left.x = clamp(20, ui.screenBounds.left.x + dx, ui.screenBounds.right.x)
    end

    if (ui.dragYable or ui.draggingY) and love.mouse.isDown(1) then
        ui.draggingY = true
        ui.screenBounds.bottom.y = clamp(ui.screenBounds.left.y, ui.screenBounds.bottom.y + dy, love.graphics:getHeight() - 20)
    end
end

local tbSelected = false
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
                        if mousejustpressed then
                            if i.useFunc ~= nil then
                                i:useFunc()
                            end
                        end 
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

    for _,i in pairs(ui.textBoxes) do
        if x > i.pos.x and x < i.pos.x + ((i.parts.tr.offset.x + (i.parts.tr.move.x * i.sizeX)) * 2) then
            
            if y > i.pos.y and y < i.pos.y + 13 * 2 then
                local result = ui:queryHoverChange(i)
                if result then
                    if love.mouse.isDown(1) then
                        i.sprite = ui.textBoxHoverSprite
                        tbSelected = true
                    end

                    if tbSelected then
                        local txt = i.textStr

                        if justkeypressed == "backspace" then
                            txt = txt:sub(1, #txt - 1)
                        end

                        if justkeypressed == "space" then
                            txt = txt.. " "
                        end

                        if #justkeypressed == 1 then
                            txt = txt.. justkeypressed
                        end

                        local newTxt = love.graphics.newText(ui.font, txt)
                        local textScale = 2 / 3.5
                        local innerWidth = i.sizeX * 2

                        if newTxt:getWidth() * textScale <= innerWidth*2 then
                            i.text = newTxt
                            i.textStr = txt
                        end

                    end
                else
                    i.sprite = ui.textBoxSprite
                    tbSelected = false
                end
            else
                i.sprite = ui.textBoxSprite
            end
        else
            i.sprite = ui.textBoxSprite
        end
    end

    if ui.hueDragging then
        ui:queryHoverChange(ui.currentHuePicker)
    end

    if ui.colourDragging then
        ui:queryHoverChange(ui.currentColourPicker)
    end
end

function ui:queryHoverChange(inputObj)
    if ui.colourDragging then
        ui.objectHovering = ui.currentColourPicker
        return inputObj == ui.currentColourPicker
    end

    if ui.hueDragging then
        ui.objectHovering = ui.currentHuePicker
        return inputObj == ui.currentHuePicker
    end
    if ui.objectHovering == nil then
        ui.objectHovering = inputObj
    end

    if inputObj.layer > ui.objectHovering.layer then
        ui.objectHovering = inputObj
    end

    return ui.objectHovering == inputObj
end

function ui:checkMouseIco()
    x,y = love.mouse.getPosition()

    if ui.objectHovering ~= nil then
        ui.currentIco = ui.cursorMouseIco
    else
        if PixelService.currentTool == "brush" or PixelService.currentTool == "paintbucket" then
            ui.currentIco = ui.cursorIco
        elseif PixelService.currentTool == "eyedropper" then
            ui.currentIco = ui.cursorEyedropIco

        end
    end

    if x < ui.screenBounds.left.x + 10 and x > ui.screenBounds.left.x - 10 and y > ui.screenBounds.left.y and  y < ui.screenBounds.bottom.y + 10 and ui.objectHovering ~= nil then
        if ui.objectHovering.type == "bg" and not ui.colourDragging and not ui.hueDragging  then
            ui.currentIco = ui.cursorDragXIco
            ui.dragXable = true
        end
    else    
        ui.dragXable = false
    end

    if y < ui.screenBounds.bottom.y + 10 and y > ui.screenBounds.bottom.y - 10 and x > ui.screenBounds.left.x - 10 and x < ui.screenBounds.right.x and ui.objectHovering ~= nil then
        if ui.objectHovering.type == "bg" and not ui.colourDragging and not ui.hueDragging then
            ui.currentIco = ui.cursorDragYIco
            ui.dragYable = true
        end
    else    
        ui.dragYable = false
    end

    if ui.dragXable and ui.dragYable  then
        ui.currentIco = ui.cursorDragXYIco
    end

    local mX, mY = love.mouse.getPosition()

    if huePickerImgData ~= nil
        and mX >= 10
        and mX <= 10 + huePickerImg:getWidth() * 2
        and mY >= (love.graphics:getHeight() - 10) - huePickerImg:getHeight() * 2
        and mY <= (love.graphics:getHeight() - 10) or ui.hueDragging  then
            ui.currentIco = ui.cursorEyedropIco
    end

    if colorPickerImgData ~= nil
        and mX >= 10
        and mX <= 10 + colorPickerImg:getWidth() * 2
        and mY >= (love.graphics:getHeight() - 50) - colorPickerImg:getHeight() * 2
        and mY <= (love.graphics:getHeight() - 50) or ui.colourDragging  then
            ui.currentIco = ui.cursorEyedropIco
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
    if ui.colourDragging then return end
    if ui.hueDragging then return end
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

mousejustpressed = false
function ui:mousepressed(x, y, button, istouch)
    if button == 1 then
        mousejustpressed=true
        local px = 10
        local py = (love.graphics:getHeight() - 50) - colorPickerImg:getHeight() * 2
        local pw = colorPickerImg:getWidth() * 2
        local ph = colorPickerImg:getHeight() * 2

        if x >= px and x <= px + pw and y >= py and y <= py + ph then
            ui.colourDragging = true
            return
        end

        px = 10
        py = (love.graphics:getHeight() - 10) - huePickerImg:getHeight() * 2
        pw = huePickerImg:getWidth() * 2
        ph = huePickerImg:getHeight() * 2

        if x >= px and x <= px + pw and y >= py and y <= py + ph then
            ui.hueDragging = true
            return
        end

    end

    if button == 3 then
        panning = true
   end
end

function ui:mousereleased(x, y, button)
    if button == 1 or button == 2 then
        if button == 1 then
            ui.draggingX = false
            ui.draggingY = false
            ui.colourDragging = false
            ui.hueDragging = false
        end
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

        end
    end
end


control = false
alt = false
justkeypressed = ""
function ui:keypressed( key, scancode, isrepeat )
    justkeypressed = scancode
   if scancode == "lctrl" then
      control = true
   end

   if PixelService.currentTool ~= "noise" then
    if scancode == "lalt" then
            alt = true
            PixelService.bankedTool = PixelService.currentTool
            PixelService.currentTool = "eyedropper"
    end

    if scancode == "b" then
            PixelService.currentTool = "brush"
    end

    if scancode == "e" then
            PixelService.currentTool = "eraser"
    end

    if scancode == "i" then
            PixelService.currentTool = "eyedropper"
    end

    if scancode == "g" then
            PixelService.currentTool = "paintbucket"
    end
end

    if control and scancode == "z" then
        local targetEntry = table.remove(PixelService.localBigPx)
        if targetEntry ~= nil then
            for _,i in pairs(targetEntry) do
            PixelService:setPixelFast(imgData, i.x, i.y, i.old.r, i.old.g, i.old.b, i.old.a, false)
            end
        end
    end


    if control and scancode == "n" then
        ui:generateNewCanvas()
    end

    if control and scancode == "s" then
        ui:saveFile()
    end
end

function ui:saveFile()
    local x, y = love.mouse.getPosition()
    local pX, pY = PixelService:posToPixel(img,love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,x, y)
    local w, h = imgData:getDimensions()
    local func = function(gui)
        local name = "file"
        if gui.elements[1].textStr ~= "" then name = gui.elements[1].textStr end
        
        imgData:encode("png", name.. ".png")

        removeFloatingGui(gui)

        love.system.openURL("file://" .. love.filesystem.getSaveDirectory())



    end


    Gui:createFloatingGui("Save File",100, love.graphics.getHeight()/2-250,62,100,"saveFile", func)
    Gui:addElement(Gui.guis.floating.saveFile, registerTextBox("textbox.png", "nameTB", "Name Here"))
            
end

function ui:generateNewCanvas()
    local x, y = love.mouse.getPosition()
    local pX, pY = PixelService:posToPixel(img,love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,x, y)
    local w, h = imgData:getDimensions()
    local func = function(gui)
        local newX = 16
        local newY = 16
        if tonumber(gui.elements[1].textStr) ~= nil then newX = tonumber(gui.elements[1].textStr) end
        if tonumber(gui.elements[2].textStr) ~= nil then newY = tonumber(gui.elements[2].textStr) end
        
        imgData = love.image.newImageData(newX, newY)

        img = love.graphics.newImage(imgData)

        cursorImgData = love.image.newImageData(newX, newY)

        cursorImg = love.graphics.newImage(cursorImgData)

        removeFloatingGui(gui)

    end


    Gui:createFloatingGui("New Sprite",love.graphics.getWidth()/2-31, love.graphics.getHeight()/2-250,62,100,"newCanvas", func)
    Gui:addElement(Gui.guis.floating.newCanvas, registerTextBox("textbox.png", "canvasxTB", "16"))
    Gui:addElement(Gui.guis.floating.newCanvas, registerTextBox("textbox.png", "canvasyTB", "16"))
            
end

function ui:keyreleased( key, scancode, isrepeat )
   if scancode == "lctrl" then
      control = false
   end
   if scancode == "lalt" and PixelService.currentTool ~= "noise" then
      alt = false
      PixelService.currentTool = PixelService.bankedTool
   end

end

function ui:changeColour(r, g, b, a)
    a=a or 1

    local hue, sat, val = rgbToHsv(r, g, b)

    if hue ~= hue then hue = 0 end


    PixelService.currentColour = {r=r,g=g,b=b,a=a}

    ui.currentHue = hue

    if huePickerImgData then
        local w = huePickerImgData:getWidth()
        local x = math.floor(hue*val)

        ui.hueSelectHover.x = clamp(0, x, w-1)
        ui.hueSelectHover.y = 0
        ui.hueSelectHover.lastX = ui.hueSelectHover.x / w
        ui.hueSelectHover.lastY = 0
    end

    if colorPickerImgData then
        local w, hgt = colorPickerImgData:getDimensions()

        local x = math.floor(sat*w)
        local y = math.floor((1-val) * hgt)
        ui.colourSelectHover.x = clamp(0,x,w-1)
        ui.colourSelectHover.y = clamp(0, y, hgt-1)

        ui.colourSelectHover.lastX = ui.colourSelectHover.x / w
        ui.colourSelectHover.lastY = ui.colourSelectHover.y / hgt
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
            if love.mouse.isDown(2) then
                PixelService.tempC = {r=0,g=0,b=0,a=0}
            else
                PixelService.tempC = PixelService.currentColour
            end
            if PixelService.currentTool == "brush" or PixelService.currentTool == "paintbucket" then
                local newH,newS,newV = rgbToHsv(PixelService.tempC.r,PixelService.tempC.g,PixelService.tempC.b)
                print(newV,newS)

                PixelService.tooLight = newV > 0.5 and newS < 0.5

                PixelService:setPixelFast(cursorImgData, pX, pY, PixelService.tempC.r, PixelService.tempC.g, PixelService.tempC.b, PixelService.tempC.a, false)
            end
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
        layer = 2,
        bount = false,
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

function registerButton(spritePath, id, text)
    text = text or "Empty"
    local sprite = love.graphics.newImage(spritePath)
    local newText = love.graphics.newText(ui.font, text)

    local slice = {    
        text = newText,
        sizeX = 0,
        sizeY = 0,
        layer = 3,
        bount = false,
        type = "button",
        pos = {x=0,y=0},
        useFunc = nil,
        parts = {    
            tl = {q=love.graphics.newQuad(0,0,3,18,sprite:getWidth(),sprite:getHeight()),offset={x=0,y=0},move={x=0,y=0}},
            t = {q=love.graphics.newQuad(3,0,1,18,sprite:getWidth(),sprite:getHeight()),offset={x=3,y=0},move={x=1,y=0}},
            tr = {q=love.graphics.newQuad(4,0,3,18,sprite:getWidth(),sprite:getHeight()),offset={x=4,y=0},move={x=2,y=0}},
        },
        sprite = sprite
    }

    table.insert(ui.buttons, slice)
    return slice
end

function registerTextBox(spritePath, id, text)
    text = text or "Empty"
    local sprite = love.graphics.newImage(spritePath)
    local newText = love.graphics.newText(ui.font, text)

    local slice = {    
        text = newText,
        textStr = text,
        sizeX = 44,
        sizeY = 0,
        layer = 3,
        bount = false,
        type = "textBox",
        pos = {x=0,y=0},
        parts = {    
            tl = {q=love.graphics.newQuad(0,0,3,13,sprite:getWidth(),sprite:getHeight()),offset={x=0,y=0},move={x=0,y=0}},
            t = {q=love.graphics.newQuad(3,0,1,13,sprite:getWidth(),sprite:getHeight()),offset={x=3,y=0},move={x=1,y=0}},
            tr = {q=love.graphics.newQuad(4,0,3,13,sprite:getWidth(),sprite:getHeight()),offset={x=4,y=0},move={x=2,y=0}},
        },
        sprite = sprite
    }

    table.insert(ui.textBoxes, slice)
    return slice
end

function registerToolButton(toolType)

    local tool = {    
        layer = 1,
        type = "toolButton",
        toolType = toolType,
        sprite = love.graphics.newImage(toolType.. "button.png"),
        selectedSprite = love.graphics.newImage(toolType.. "buttonhover.png")
    }

    table.insert(ui.toolButtons, tool)
    return tool
end

return ui