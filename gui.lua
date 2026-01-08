local gui = {}

gui.guis = {}
gui.guis.floating = {}

function gui:load()
end

function gui:update(dt)
end

function gui:draw()
    love.graphics.setColor(1,1,1)
    gui:drawFloatingGuis()

end

function gui:drawFloatingGuis()
    for _,base in pairs(gui.guis.floating) do
        --love.graphics.setScissor(base.x, base.y, base.dimX*4+14, base.dimY*4+14)

        Ui:draw9sliceSingular(base.bottomSlice)
        Ui:draw9sliceSingular(base.topSlice)
        
        local elemCount = 1
        for c,element in ipairs(base.elements) do
            

            if element.type == "textBox" then
                element.pos.x = element.origPos.x + 8
                element.pos.y = element.origPos.y + 15 + ((element.sprite:getHeight() * 2) * elemCount) + (5*elemCount)
                Ui:drawTextBoxSingular(element)
            end

            elemCount = elemCount + 1
        end

        Ui:drawButtonSingular(base.confirmButton)
        Ui:drawButtonSingular(base.cancelButton)

        love.graphics.draw(base.title, base.x + 10, base.y, 0, 2/3.5, 2/3.5)
    end
end

function gui:createFloatingGui(title ,posX, posY, dimX,dimY,id, returnFunc)
    returnFunc = returnFunc or nil
    local newGui = {
        x = posX,
        y = posY,
        dimX = dimX,
        dimY = dimY,
        title = love.graphics.newText(Ui.font, title),
        topSlice = register9Slice("light9slice.png", id.."TopSlice"),
        bottomSlice = register9Slice("dark9slice.png", id.."BottomSlice"),
        elements = {},
        confirmButton = registerButton("darkbutton.png", "dark", "Confirm"),
        cancelButton = registerButton("darkbutton.png", "dark", "Cancel")
    }

    newGui.confirmButton.useFunc = function()
        returnFunc(newGui)
    end

    newGui.cancelButton.useFunc = function()
        removeFloatingGui(newGui)
    end
    
    newGui.topSlice.sizeX = dimX
    newGui.bottomSlice.sizeX = dimX

    newGui.topSlice.sizeY = 7
    newGui.bottomSlice.sizeY = dimY

    newGui.confirmButton.sizeX = 26
    newGui.cancelButton.sizeX = 26

    newGui.topSlice.pos = {x=posX,y=posY}
    newGui.bottomSlice.pos = {x=posX,y=posY}

    newGui.confirmButton.pos = {x=posX + dimX*4 - 28*8-12,y=posY + dimY*4 - 14*2}
    newGui.cancelButton.pos = {x=posX + dimX*4 - 28*4,y=posY + dimY*4 - 14*2}

    newGui.topSlice.bound = true
    newGui.bottomSlice.bound = true
    newGui.confirmButton.bound = true
    newGui.cancelButton.bound = true

    gui.guis.floating[id] = newGui
    return newGui
end

function removeFloatingGui(inputGui)

    for _,i in pairs(gui.guis.floating) do
        if i == inputGui then
            gui.guis.floating[_] = nil
            PixelService.currentTool = "brush"
            break
        end

    end

    for _,i in pairs(Ui.slices) do
        if i == inputGui.topSlice or i == inputGui.bottomSlice then
            Ui.slices[_] = nil
        end

    end

    for _,i in pairs(Ui.buttons) do
        if i == inputGui.cancelButton or i == inputGui.confirmButton then
            Ui.buttons[_] = nil
            break
        end

    end

    for _,i in pairs(inputGui.elements) do
        if i.type == "textBox" then
            Ui.textBoxes[_] = nil
        end
    end
end

function gui:addElement(newGui, element)
    element.pos = {x=newGui.x,y=newGui.y}
    element.origPos = {x=newGui.x,y=newGui.y}
    table.insert(newGui.elements, element)
end


return gui