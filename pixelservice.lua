local pixelservice = {}

pixelservice.currentMap = {}
pixelservice.imageDirty = true
pixelservice.pixelLog = {}
pixelservice.justSetPx = {x=-1, y=-1}
pixelservice.currentColour = {r=0,g=0,b=1,a=1}

pixelservice.localCurrentPx = {}
pixelservice.localBigPx = {}

pixelservice.currentTool = "brush"
pixelservice.bankedTool = ""

pixelservice.tooLight = false


function pixelservice:load()

    imgData = love.image.newImageData(64, 64)
    cursorImgData = love.image.newImageData(64, 64)

    cursorImgData:setPixel(0,0,1,1,1,1)
    

    img = love.graphics.newImage(imgData)
    cursorImg = love.graphics.newImage(cursorImgData)
end

tempC = {}
function pixelservice:update(dt)
    local x, y = love.mouse.getPosition()
    updateCursor(x,y)
    
    if pixelservice.currentTool == "noise" then pixelservice.noiseTool() end
    if Ui.objectHovering == nil and not(Ui.colourDragging) and not(Ui.hueDragging) and not(Ui.canvasTranslating) then
        if pixelservice.currentTool == "brush" then pixelservice.brushTool() 
        elseif pixelservice.currentTool == "eyedropper" then pixelservice.eyedropperTool()
        elseif pixelservice.currentTool == "eraser" then pixelservice.eraserTool()
        elseif pixelservice.currentTool == "paintbucket" then pixelservice.paintBucketTool()
        elseif pixelservice.currentTool == "select" then pixelservice.selectTool() end
    end

    if pixelservice.imageDirty then
        img = love.graphics.newImage(imgData)
        pixelservice.imageDirty = false
    end
    
    Ui.objectHovering = nil
end

function pixelservice:brushTool()
    local x, y = love.mouse.getPosition()
    local pX, pY = pixelservice:posToPixel(img,love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,x, y)
    local w, h = imgData:getDimensions()
    if love.mouse.isDown(1) or love.mouse.isDown(2)  then
        if pX >= 0 and pY >= 0 and pX < w and pY < h then
            tempC = pixelservice.currentColour
            if love.mouse.isDown(2) then tempC = {r=0,g=0,b=0,a=0} end
            
            if lastPx then
                pixelservice:drawLine(lastPx.x, lastPx.y, pX, pY, tempC.r,tempC.g, tempC.b, tempC.a)
            else
                pixelservice:setPixelFast(imgData, pX, pY, tempC.r, tempC.g, tempC.b, tempC.a, true)
            end

            lastPx = {x=pX, y=pY}
            
        end
    else
        lastPx = nil
    end
end

selectTracking = false
selectStartPos = {x=0,y=0}
selectEndPos = {x=0,y=0}

pixelservice.selectedArea = nil

pixelservice.selectrionDraggable = false
pixelservice.selectrionDragMouse = nil

function pixelservice:selectSelection()
    cursorImgData = love.image.newImageData(64,64)
    local x, y = love.mouse.getPosition()
    local pX, pY = pixelservice:posToPixel(img,love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,x, y)
    local w, h = imgData:getDimensions()

    if mousejustpressed then
        pixelservice.selectrionDragMouse = {x=pX,y=pY}
    end

    pixelservice.selectrionDraggable = love.mouse.isDown(1)
end

function pixelservice:selectTool()
    cursorImgData = love.image.newImageData(64,64)
    local x, y = love.mouse.getPosition()
    local pX, pY = pixelservice:posToPixel(img,love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,x, y)
    local w, h = imgData:getDimensions()
    if pixelservice.selectedArea ~= nil then
        local startbX,startbY = pixelservice:pixelToPos(imgData, love.graphics.getWidth()/2, love.graphics.getHeight()/2, pixelservice.selectedArea.startPos.x, pixelservice.selectedArea.startPos.y)
        local endbX,endbY = pixelservice:pixelToPos(imgData, love.graphics.getWidth()/2, love.graphics.getHeight()/2, pixelservice.selectedArea.endPos.x+1, pixelservice.selectedArea.endPos.y+1)
        if x >= startbX and x <= endbX and y >= startbY and y <= endbY then
            pixelservice:selectSelection()
            if not(selectTracking) then return end
        end
    end
    if mousejustpressed then
        if pX >= 0 and pY >= 0 and pX < w and pY < h then
            selectTracking = true
            selectStartPos = {x=pX,y=pY}
        end
    end

    if mousejustreleased then
        selectTracking = false
        selectEndPos = {x=pX,y=pY}
        
        if selectStartPos.x  < pX or selectStartPos.y  < pY then
            pixelservice.selectedArea = {
                startPos = selectStartPos,
                endPos = selectEndPos
            }
        else
            pixelservice.selectedArea = nil
        end

    end

    Ui.overrideCursorUpdate = selectTracking

    if selectTracking then
        PixelService:setPixelFast(cursorImgData, selectStartPos.x, selectStartPos.y, 1, 0, 0, 1, false)
        PixelService:setPixelFast(cursorImgData, pX, pY, 1, 0, 0, 1, false)
        local xMult = (selectStartPos.x - pX > 0) and 1 or -1
        local yMult = (selectStartPos.y - pY > 0) and 1 or -1



        for newx=0,math.abs(selectStartPos.x-pX) do
            local colour = 1

            if selectStartPos.x- (newx*xMult) >= 0 and selectStartPos.y >= 0 and selectStartPos.x- (newx*xMult) < w and selectStartPos.y < h then

                local topR, topG, topB, topA = imgData:getPixel(selectStartPos.x - (newx*xMult), selectStartPos.y)

                local newH, newS, newV = rgbToHsv(topR,topG,topB)

                if newV > 0.5 then colour = 0 end

                PixelService:setPixelFast(cursorImgData, selectStartPos.x - (newx*xMult), selectStartPos.y, colour, colour, colour, 1, false)
            end


            colour = 1

            if selectStartPos.x- (newx*xMult) >= 0 and pY >= 0 and selectStartPos.x- (newx*xMult) < w and pY < h then

                topR, topG, topB, topA = imgData:getPixel(selectStartPos.x - (newx*xMult), pY)

                newH, newS, newV = rgbToHsv(topR,topG,topB)

                if newV > 0.5 then colour = 0 end


                PixelService:setPixelFast(cursorImgData, selectStartPos.x - (newx*xMult), pY, colour, colour, colour, 1, false)
            end
        end

        for newy=0,math.abs(selectStartPos.y-pY) do




            local colour = 1

            if selectStartPos.x >= 0 and selectStartPos.y - (newy*yMult) >= 0 and selectStartPos.x < w and selectStartPos.y - (newy*yMult) < h then

                local topR, topG, topB, topA = imgData:getPixel(selectStartPos.x, selectStartPos.y - (newy*yMult))

                local newH, newS, newV = rgbToHsv(topR,topG,topB)

                if newV > 0.5 then colour = 0 end

                PixelService:setPixelFast(cursorImgData, selectStartPos.x, selectStartPos.y - (newy*yMult), colour, colour, colour, 1, false)
            end
            colour = 1

            if pX >= 0 and selectStartPos.y - (newy*yMult) >= 0 and pX < w and selectStartPos.y - (newy*yMult) < h then

                topR, topG, topB, topA = imgData:getPixel(pX, selectStartPos.y - (newy*yMult))

                newH, newS, newV = rgbToHsv(topR,topG,topB)

                if newV > 0.5 then colour = 0 end


                PixelService:setPixelFast(cursorImgData,  pX, selectStartPos.y - (newy*yMult), colour, colour, colour, 1, false)
            end
        end



        cursorImg = love.graphics.newImage(cursorImgData)
    end

end

function pixelservice:eraserTool()
    local x, y = love.mouse.getPosition()
    local pX, pY = pixelservice:posToPixel(img,love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,x, y)
    local w, h = imgData:getDimensions()
    if love.mouse.isDown(1) or love.mouse.isDown(2)  then
        if pX >= 0 and pY >= 0 and pX < w and pY < h then
            tempC = {r=0,g=0,b=0,a=0}

            

            if lastPx then
                pixelservice:drawLine(lastPx.x, lastPx.y, pX, pY, tempC.r,tempC.g, tempC.b, tempC.a)
            else
                pixelservice:setPixelFast(imgData, pX, pY, tempC.r, tempC.g, tempC.b, tempC.a)
            end

            lastPx = {x=pX, y=pY}
            
        end
    else
        lastPx = nil
    end
end

function pixelservice:paintBucketTool()
    local x, y = love.mouse.getPosition()
    local pX, pY = pixelservice:posToPixel(img,love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,x, y)
    local w, h = imgData:getDimensions()
    if love.mouse.isDown(1) then
        if pX >= 0 and pY >= 0 and pX < w and pY < h then
            local fr,fg,fb,fa = imgData:getPixel(pX,pY)

            local firstColour = {r=fr,g=fg,b=fb,a=fa}
            local pRemaining = {}
            local pAdded = {}
            table.insert(pRemaining, {
                x=pX,
                y=pY,
            })

            while #pRemaining > 0 do
                local count = 1
                for _,i in pairs(pRemaining) do
                    pixelservice:setPixelFast(imgData, i.x, i.y, pixelservice.currentColour.r, pixelservice.currentColour.g, pixelservice.currentColour.b, pixelservice.currentColour.a)
                    if i.x + 1 >= 0 and i.y >= 0 and i.x + 1 < w and i.y < h then
                        local nr,ng,nb,na = imgData:getPixel(i.x+1,i.y)
                        local nColour = {r=nr,g=ng,b=nb,a=na}
                        if nColour.r == firstColour.r and nColour.g == firstColour.g and nColour.b == firstColour.b and nColour.a == firstColour.a and pAdded[i.x..","..i.y] == nil then
                            table.insert(pRemaining, {x=i.x + 1, y = i.y})
                        end
                    end

                    if i.x - 1 >= 0 and i.y >= 0 and i.x - 1 < w and i.y < h then
                        local nr,ng,nb,na = imgData:getPixel(i.x-1,i.y)
                        local nColour = {r=nr,g=ng,b=nb,a=na}
                        if nColour.r == firstColour.r and nColour.g == firstColour.g and nColour.b == firstColour.b and nColour.a == firstColour.a and pAdded[i.x..","..i.y] == nil then
                            table.insert(pRemaining, {x=i.x - 1, y = i.y})
                        end
                    end

                    if i.x  >= 0 and i.y+1 >= 0 and i.x < w and i.y+1 < h then
                        local nr,ng,nb,na = imgData:getPixel(i.x,i.y+1)
                        local nColour = {r=nr,g=ng,b=nb,a=na}
                        if nColour.r == firstColour.r and nColour.g == firstColour.g and nColour.b == firstColour.b and nColour.a == firstColour.a and pAdded[i.x..","..i.y] == nil then
                            table.insert(pRemaining, {x=i.x, y = i.y+1})
                        end
                    end

                    if i.x  >= 0 and i.y-1 >= 0 and i.x < w and i.y-1 < h then
                        local nr,ng,nb,na = imgData:getPixel(i.x,i.y-1)
                        local nColour = {r=nr,g=ng,b=nb,a=na}
                        if nColour.r == firstColour.r and nColour.g == firstColour.g and nColour.b == firstColour.b and nColour.a == firstColour.a and pAdded[i.x..","..i.y] == nil then
                            table.insert(pRemaining, {x=i.x, y = i.y-1})
                            
                        end
                    end

                    
                    table.remove(pRemaining, count)
                    pAdded[i.x..","..i.y] = i
                    count = count + 1
                end
            end
        end
    end
end

function tableContains(table, value)
    local i = 0 local contains = false

    repeat if (table[i] == value) then contains = true end i = i + 1 until(i == #table)

    return contains 
end 

function pixelservice:eyedropperTool()
    local x, y = love.mouse.getPosition()
    local pX, pY = pixelservice:posToPixel(img,love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,x, y)
    local w, h = imgData:getDimensions()
    if love.mouse.isDown(1) then
        if pX >= 0 and pY >= 0 and pX < w and pY < h then
            local r,g,b,a = imgData:getPixel(pX,pY)
            Ui:changeColour(r,g,b,a)

            lastPx = {x=pX, y=pY}
            
        end
    end
end

function pixelservice:noiseTool()
    local x, y = love.mouse.getPosition()
    local pX, pY = pixelservice:posToPixel(img,love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,x, y)
    local w, h = imgData:getDimensions()
    if Gui.guis.floating.test == nil then
        local func = function(gui)
            local newX = 0
            local newY = 0
            if tonumber(gui.elements[1].textStr) ~= nil then newX = tonumber(gui.elements[1].textStr) end
            if tonumber(gui.elements[2].textStr) ~= nil then newY = tonumber(gui.elements[2].textStr) end
            pixelservice:generateNoise(newX, newY)

            removeFloatingGui(gui)

        end


        Gui:createFloatingGui("Generate Noise" ,love.graphics.getWidth()-350, love.graphics.getHeight()/2-250,62,100,"test", func)
        Gui:addElement(Gui.guis.floating.test, registerTextBox("textbox.png", "noisexTB", "16"))
        Gui:addElement(Gui.guis.floating.test, registerTextBox("textbox.png", "noiseyTB", "16"))
            
    end
end

function pixelservice:generateNoise(dimX, dimY)
    local frequency = 0.1
    for x=0,dimX-1 do
        for y=0,dimY-1 do
            local r,g,b = hsv(0,0,love.math.noise(x * frequency,y * frequency))
            
            if x >= 0 and x < imgData:getWidth() and y >= 0 and y < imgData:getHeight() then
                pixelservice:setPixelFast(imgData, x, y, r, g, b, 1)
            end
        end
    end
end

function pixelservice:draw()
    local imgW, imgH = imgData:getDimensions()

    local rectsX = math.ceil(imgW / 16)
    local rectsY = math.ceil(imgH / 16)
    local rectSizeX = imgW

    love.graphics.setColor(0, 0, 0) 
    love.graphics.rectangle("fill", ((love.graphics.getWidth() / 2) - 2) - ((imgW / 2) * scalar) + Ui.camX,((love.graphics.getHeight() / 2) - 2) - ((imgH / 2) * scalar) + Ui.camY, imgW * scalar + 5 ,imgH * scalar + 5)
    
    local flip = true
    for i = 0,rectsX -1 do

        local sizeX
        if rectSizeX - 16 > 0 then
            sizeX = 16
            rectSizeX = rectSizeX - 16
        else
            sizeX = rectSizeX
        end
        local rectSizeY = imgH

        
        for y = 0,rectsY -1 do
            
            if (i + y) % 2 == 0 then
                love.graphics.setColor(0.5, 0.5, 0.5) 
            else
                love.graphics.setColor(0.75, 0.75, 0.75) 
            end

            if rectSizeY - 16 > 0 then
                sizeY = 16
                rectSizeY = rectSizeY - 16
            else
                sizeY = rectSizeY
            end


            love.graphics.rectangle("fill", (love.graphics.getWidth() / 2 + ((16 * i)* scalar)) - ((imgW / 2) * scalar) + Ui.camX,(love.graphics.getHeight() / 2  + ((16 * y)* scalar)) - ((imgH / 2) * scalar) + Ui.camY, sizeX * scalar ,sizeY * scalar)
            love.graphics.setColor(1,1,1)
        end

    end

    

    love.graphics.draw(img, love.graphics.getWidth() / 2 + Ui.camX,love.graphics.getHeight() / 2 + Ui.camY, 0, scalar, scalar, img:getWidth() / 2, img:getHeight() / 2)
    love.graphics.draw(cursorImg, love.graphics.getWidth() / 2 + Ui.camX,love.graphics.getHeight() / 2 + Ui.camY, 0, scalar, scalar, cursorImg:getWidth() / 2, cursorImg:getHeight() / 2)
    
    if pixelservice.selectedArea ~= nil then
        local sX, sY = pixelservice.selectedArea.startPos.x, pixelservice.selectedArea.startPos.y
        local eX, eY = pixelservice.selectedArea.endPos.x, pixelservice.selectedArea.endPos.y

        local topLeftX = math.min(sX, eX)
        local topLeftY = math.min(sY, eY)
        local bottomRightX = math.max(sX, eX)
        local bottomRightY = math.max(sY, eY)

        local startX, startY = pixelservice:pixelToPos(imgData, love.graphics.getWidth()/2, love.graphics.getHeight()/2, topLeftX, topLeftY)
        local endX, endY = pixelservice:pixelToPos(imgData, love.graphics.getWidth()/2, love.graphics.getHeight()/2, bottomRightX + 1, bottomRightY + 1) 

        local rectX = startX
        local rectY = startY
        local rectW = endX - startX
        local rectH = endY - startY

        

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", rectX, rectY, rectW, rectH)
    end




end


function pixelservice:drawLine(x0, y0, x1, y1, r, g, b, a)
    local dx = math.abs(x1 - x0)
    local dy = math.abs(y1 - y0)
    local sx = x0 < x1 and 1 or -1
    local sy = y0 < y1 and 1 or -1
    local err = dx - dy

    while true do
        pixelservice:setPixelFast(imgData, x0, y0, r, g, b, a)
        if x0 == x1 and y0 == y1 then break end
        local e2 = err * 2
        if e2 > -dy then err = err - dy; x0 = x0 + sx end
        if e2 <  dx then err = err + dx; y0 = y0 + sy end
    end
end

function pixelservice:setPixelFast(imgToUse, x, y, r, g, b, a, countPx)
    

    local w, h = imgData:getDimensions()
    if countPx == nil then countPx = true end


    if x >= 0 and y >= 0 and x < w and y < h then

        if pixelservice.selectedArea ~= nil then
            if x >= pixelservice.selectedArea.startPos.x and y >= pixelservice.selectedArea.startPos.y and x <= pixelservice.selectedArea.endPos.x and y <= pixelservice.selectedArea.endPos.y then

            else
                if countPx then
                    return
                end
            end

        end


        if countPx == nil then countPx = true end

        local key = x .. "," .. y

        if countPx and not pixelservice.localCurrentPxSet[key] then
            local oldR, oldG, oldB, oldA = imgToUse:getPixel(x, y)
            oldR, oldG, oldB, oldA = oldR or 0, oldG or 0, oldB or 0, oldA or 0

            local entry = {
                x = x,
                y = y,
                old = { r = oldR, g = oldG, b = oldB, a = oldA }
            }

            pixelservice.localCurrentPxSet[key] = entry
            table.insert(pixelservice.localCurrentPx, entry)
        end
        imgToUse:setPixel(x, y, r, g, b, a)
        pixelservice.imageDirty = true
    end
end


pixelservice.localCurrentPx = {}
pixelservice.localCurrentPxSet = {}

function pixelservice:cachePixel(entry)
    local key = entry.x .. "," .. entry.y
    if not pixelservice.localCurrentPxSet[key] then
        pixelservice.localCurrentPxSet[key] = entry      
        table.insert(pixelservice.localCurrentPx, entry)
    end
end


function pixelservice:posToPixel(theimg,imgX, imgY,x, y)
    local calcX = math.floor((((imgX  - x  + Ui.camX)) / scalar) * -1) + theimg:getWidth() / 2
    local calcY = math.ceil(((((imgY - y  + Ui.camY)) / scalar) * -1) - 1) + theimg:getHeight() / 2
    return calcX, calcY
end

function pixelservice:pixelToPos(theimg, imgX, imgY, px, py)
    local x = imgX + Ui.camX - theimg:getWidth()/2 * scalar + px * scalar
    local y = imgY + Ui.camY - theimg:getHeight()/2 * scalar + py * scalar
    return x, y
end

return pixelservice