--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    This is a screen that shows the level score/acc/maxcombo
]]

ScoresPanel = Class {__includes = FadeInPanel}

function ScoresPanel:init(score, acc, maxcombo)
    self.FadeInPanel = FadeInPanel(0,SCORES_PANEL_POS.y, SCORES_PANEL_POS.x, SCORES_PANEL_POS.y)

    self.score = score 
    self.acc = acc 
    self.maxcombo = maxcombo
end

function ScoresPanel:render()
    
    --Lineout
    love.graphics.setColor(255,255,255,self.FadeInPanel.alpha)
    love.graphics.setLineWidth(5)

    local texts = {love.graphics.newText(gFonts['recapSmall'], "Score: "),
        love.graphics.newText(gFonts['recapSmall'], "Accuracy: "),
        love.graphics.newText(gFonts['recapSmall'], "Max Combo: ")}

    local values = {love.graphics.newText(gFonts['recapSmall'], string.format("%07d", self.score)),
        love.graphics.newText(gFonts['recapSmall'], string.format("%.2f", self.acc) .. "%"),
        love.graphics.newText(gFonts['recapSmall'], "x"..tostring(self.maxcombo))}

    love.graphics.rectangle('line', self.FadeInPanel.x, self.FadeInPanel.y, 3*VIRTUAL_WIDTH/4, texts[1]:getHeight()+20)

    -- Keep track of where to draw
    local cursor = self.FadeInPanel.x + 10 -- A bit of padding

    -- Fill the rectangle
    for i=1,3 do
        love.graphics.setColor(150,150,150,255) --Gray
        love.graphics.draw(texts[i], cursor, self.FadeInPanel.y+10)
        cursor = cursor + texts[i]:getWidth()
        love.graphics.setColor(255,255,255,255) --White
        love.graphics.draw(values[i], cursor, self.FadeInPanel.y+10)
        cursor = cursor + values[i]:getWidth() + SCORES_PANEL_PADDING
    end
end