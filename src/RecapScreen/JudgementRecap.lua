--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    Panel which shows a recap of the judgements this level
]]

JudgementRecap = Class{__includes = FadeInPanel}

function JudgementRecap:init(judgements)

    self.FadeInPanel = FadeInPanel(0,JUDGE_PANEL_POS.y, JUDGE_PANEL_POS.x, JUDGE_PANEL_POS.y)
    self.judgements = judgements

end

function JudgementRecap:render()

    -- Coords for each entry
    local x,y = 0,0
    -- Text for the judgement
    local text = nil
    -- Text containing judgement count
    local judgements = nil

    -- Render judgements
    for i=1,#TIMING_WINDOWS do
        text = love.graphics.newText(gFonts['judge'], JUDGE_TEXTS[i] .. ":")
        judgements = love.graphics.newText(gFonts['combo'], "x".. tostring(self.judgements[i]))
        x,y = 0,math.floor((i+1)/2)*(text:getHeight()+RECAP_SCREEN_SPACING)-RECAP_SCREEN_SPACING

        -- Split in 2 columns
        if i % 2 == 1 then
            x = 20 + self.FadeInPanel.x
        else
            x = 3*VIRTUAL_WIDTH/4 - text:getWidth() - judgements:getWidth() - 20 + self.FadeInPanel.x
        end
        
        -- Set alpha
        local color = JUDGE_COLORS[i]
        color[4] = self.FadeInPanel.alpha

        -- Draw stuff
        love.graphics.setColor(unpack(color))
        love.graphics.draw(text, x, y)
        love.graphics.setColor(255,255,255, self.FadeInPanel.alpha)
        love.graphics.draw(judgements, x+text:getWidth()+10, y-10)
    end

    -- Render panel with judgement recap
    love.graphics.setColor(255,255,255,self.FadeInPanel.alpha)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle('line', self.FadeInPanel.x, self.FadeInPanel.y, 3*VIRTUAL_WIDTH / 4, y+text:getHeight())

end
