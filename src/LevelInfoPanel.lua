--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    Rectangular panel that contains the information of a level.
]]

LevelInfoPanel = Class {}

-- Initializes the info panel given the song chart object, x and y coords and mark if available.
function LevelInfoPanel:init(chart,x,y,mark)

    self.chart = chart
    self.x = x
    self.y = y
    self.mark = mark

    self.xscale = 1
    self.yscale = 1
end

function LevelInfoPanel:render()

    -- Render outline
    love.graphics.setColor(255,255,255)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", self.x, self.y, LEVEL_PANEL_SIZE.width*self.xscale, LEVEL_PANEL_SIZE.height*self.yscale)

    -- Level mark
    local markOffset = 0
    if self.mark then
        love.graphics.setColor(MARKS_COLORS[self.mark])
        local mark = love.graphics.newText(gFonts["mark"], MARKS[self.mark])
        markOffset = LEVEL_PANEL_SIZE.height*self.yscale
        love.graphics.draw(mark, self.x+10, self.y,0,LEVEL_PANEL_SIZE.height*self.yscale/mark:getHeight(),LEVEL_PANEL_SIZE.height*self.yscale/mark:getHeight())
    end

    -- Level title and author
    love.graphics.setColor(255,255,255,255)
    local title = love.graphics.newText(gFonts["recapSmall"],(self.chart.params["title"] or "Untitled") .. " by " .. (self.chart.params["author"] or "Unknown"))
    love.graphics.draw(title, self.x+5+markOffset, self.y+5, 0, self.xscale, self.yscale)
    -- song title and author
    love.graphics.setColor(150,150,150,255)
    local song = love.graphics.newText(gFonts["infoSmall"], "Song: " .. (self.chart.params["songName"] or "Unknown") .. " by " .. (self.chart.params["songAuthor"] or "Unknown"))
    love.graphics.draw(song, self.x+5+markOffset, self.y+5+title:getHeight()*self.yscale, 0, self.xscale, self.yscale)

    -- Difficulty
    local diff = love.graphics.newText(gFonts["recapSmall"],self.chart.params["difficulty"] or "Unknown difficulty")
    local diffColorString = self.chart.params["diffColor"] or "255,255,255"
    -- Parse color string
    local color = {}
    for value in diffColorString:gmatch("[^,]+") do
        color[#color+1]=tonumber(value)
    end
    -- Draw
    love.graphics.setColor(unpack(color))
    love.graphics.draw(diff, self.x+5+markOffset, self.y+5+title:getHeight()*self.yscale+song:getHeight()*self.yscale, 0, self.xscale, self.yscale)
end