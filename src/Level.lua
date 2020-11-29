--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    Represents a level and its associated data
]]

Level = Class {}

function Level:init(song, chart, background, path)
    self.song = song -- Source object containing the level audio
    self.chart = chart -- ChartParser containing the timestamps
    self.background = background -- Image file containing the background
    self.path = path -- Unique identifier of the level given by its path relative to the level folder.
end

-- Resets the level so it can be played again
function Level:reset()
    -- Set song as it was
    self.song:setPitch(1)
    self.song:rewind()

    -- Reload chart
    self.chart = ChartParser(LEVEL_DIRECTORY .. "/" .. self.path)
end