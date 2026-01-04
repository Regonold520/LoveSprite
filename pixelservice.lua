local pixelservice = {}

pixelservice.currentMap = {}
pixelservice.imageDirty = true
pixelservice.pixelLog = {}
pixelservice.justSetPx = {x=-1, y=-1}
pixelservice.currentColour = {r=0,g=0,b=1,a=1}

pixelservice.localCurrentPx = {}
pixelservice.localBigPx = {}


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
    local pX, pY = pixelservice:posToPixel(img,love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,x, y)
    local w, h = imgData:getDimensions()
    if Ui.objectHovering == nil then
        if love.mouse.isDown(1) or love.mouse.isDown(2)  then
            if pX >= 0 and pY >= 0 and pX < w and pY < h then
                tempC = pixelservice.currentColour
                if love.mouse.isDown(2) then tempC = {r=0,g=0,b=0,a=0} end

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

    if pixelservice.imageDirty then
        img = love.graphics.newImage(imgData)
        pixelservice.imageDirty = false
    end
    
    Ui.objectHovering = nil
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


return pixelservice