--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    Panel which fades in horizontally
]]

FadeInPanel = Class {}

function FadeInPanel:init(x0,y0,x1,y1)
    self.x = x0
    self.y = y0
    self.alpha = 100

    Timer.tween(RECAP_PANEL_FADE_TIME, {[self] = {x=x1,y=y1, alpha = 255}})
end