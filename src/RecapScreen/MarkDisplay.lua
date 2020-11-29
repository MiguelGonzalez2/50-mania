--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    Displays the mark obtained by the player.
]]

MarkDisplay = Class {__includes = FadeInPanel}

function MarkDisplay:init(mark, newHighScore)
    self.FadeInPanel = FadeInPanel(MARK_PANEL_POS.x-20, MARK_PANEL_POS.y, MARK_PANEL_POS.x, MARK_PANEL_POS.y)
    self.newHighScore = newHighScore
    self.mark = mark
end

function MarkDisplay:render()
    local text = love.graphics.newText(gFonts['mark'], MARKS[self.mark])
    local color = MARKS_COLORS[self.mark]
    color[4] = self.FadeInPanel.alpha

    love.graphics.setColor(unpack(color))
    love.graphics.draw(text, self.FadeInPanel.x, self.FadeInPanel.y)

    if self.newHighScore then
        local hscore = love.graphics.newText(gFonts['recapSmall'], "New highscore!")
        -- Shadow
        love.graphics.setColor(255,255,255,math.min(150,self.FadeInPanel.alpha))
        love.graphics.draw(hscore, self.FadeInPanel.x+2, self.FadeInPanel.y + text:getHeight() + 17)
        love.graphics.setColor(255,0,0,self.FadeInPanel.alpha)
        love.graphics.draw(hscore, self.FadeInPanel.x, self.FadeInPanel.y + text:getHeight() + 15)
    end
end