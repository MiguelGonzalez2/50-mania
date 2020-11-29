--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    This is a screen that shows the performance throughout the level as a simple graph
]]

GraphPanel = Class {__includes = FadeInPanel}

function GraphPanel:init(notes)
    self.FadeInPanel = FadeInPanel(0, GRAPH_PANEL_POS.y, GRAPH_PANEL_POS.x, GRAPH_PANEL_POS.y)
    self.notes = notes
    self.width = 3*VIRTUAL_WIDTH/4
    self.height = VIRTUAL_HEIGHT - self.FadeInPanel.y - 20

    self.samples = {}

    self:addSamples()
end

function GraphPanel:addSamples()

    -- Compute each sample
    for i=1,GRAPH_PANEL_SAMPLES do
        local start = math.max(1,math.floor((i-1)*(#self.notes/GRAPH_PANEL_SAMPLES)))
        -- We use math.max to ensure that at least one sample is selected
        local finish = math.min(math.max(math.floor(i*(#self.notes/GRAPH_PANEL_SAMPLES)),math.floor((i-1)*(#self.notes/GRAPH_PANEL_SAMPLES))+1),#self.notes)
        -- Maximum and actual values in each sample (we use acc weights for this)
        local sampleMax = 0
        local sampleVal = 0

        for note=start,finish do
            sampleMax = sampleMax + ACC_WEIGHTS[1]
            sampleVal = sampleVal + ACC_WEIGHTS[self.notes[note].judgement or #ACC_WEIGHTS]
        end

        -- The height in the plot depends on how well we did
        local heightInPlot = ( 1 - sampleVal/sampleMax ) * (self.height-20)
        local widthInPlot = i/GRAPH_PANEL_SAMPLES * (self.width-10)
        -- Color has more green if we did good, more red otherwise
        local colorInPlot = {( 1 - sampleVal/sampleMax )*255,sampleVal/sampleMax*255,0,255}

        -- Schedule drawing
        Timer.after(i/GRAPH_PANEL_SAMPLES*GRAPH_DELAY, function() 
            self.samples[i] =  {x=widthInPlot,y=heightInPlot, color = colorInPlot}
        end)

    end

end

function GraphPanel:render()
    --Lineout
    love.graphics.setColor(255,255,255,self.FadeInPanel.alpha)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle('line', self.FadeInPanel.x, self.FadeInPanel.y, self.width, self.height)

    -- Graph
    for i=1,GRAPH_PANEL_SAMPLES do
        if i>1 and self.samples[i] and self.samples[i-1] then
            love.graphics.setColor(unpack(self.samples[i].color))
            love.graphics.line(self.FadeInPanel.x+self.samples[i-1].x, 10+self.FadeInPanel.y+self.samples[i-1].y,self.FadeInPanel.x+self.samples[i].x, 10+self.FadeInPanel.y+self.samples[i].y)
        end
    end
end