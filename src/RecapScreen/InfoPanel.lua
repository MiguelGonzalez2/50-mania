--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    This is a panel that shows some information on how to keep playing.
]]

InfoPanel = Class {__includes = FadeInPanel}

function InfoPanel:init()
    self.FadeInPanel = FadeInPanel(RECAP_INFO_PANEL_POS.x-20,RECAP_INFO_PANEL_POS.y, RECAP_INFO_PANEL_POS.x, RECAP_INFO_PANEL_POS.y)
end

function InfoPanel:render()
    
    --Lineout
    love.graphics.setColor(255,255,255,self.FadeInPanel.alpha)
    love.graphics.setLineWidth(5)

    local texts = {love.graphics.newText(gFonts['infoSmall'], "Enter: "),
        love.graphics.newText(gFonts['infoSmall'], "Esc: ")}

    local values = {love.graphics.newText(gFonts['infoSmall'], "Replay Level"),
        love.graphics.newText(gFonts['infoSmall'], "Level Select")}

    -- Keep track of where to draw
    local ycursor = self.FadeInPanel.y + 10
    local xcursor = self.FadeInPanel.x + 10
    -- Fill the rectangle
    for i=1,2 do
        xcursor = self.FadeInPanel.x+10
        love.graphics.setColor(150,150,150,255) --Gray
        love.graphics.draw(texts[i], xcursor, ycursor)
        xcursor = xcursor + texts[i]:getWidth()
        love.graphics.setColor(255,255,255,255) --White
        love.graphics.draw(values[i], xcursor, ycursor)
        ycursor = ycursor + values[i]:getHeight() + INFO_PANEL_PADDING
    end

    love.graphics.rectangle('line', self.FadeInPanel.x, self.FadeInPanel.y, VIRTUAL_WIDTH - RECAP_INFO_PANEL_POS.x - 20,ycursor-self.FadeInPanel.y)
end