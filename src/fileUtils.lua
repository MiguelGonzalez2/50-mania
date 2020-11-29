--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    Some utilities for file management required to search/load songs (levels) from
    disk.
]]

-- Returns a path that works with fused mode
function getPath(path)
    if love.filesystem.isFused() then
        local dir = love.filesystem.getSourceBaseDirectory()
        local success = love.filesystem.mount(dir, "base")
        return "base/"..path
    else
        return path
    end
end

-- Returns an containing the lines of a file in order, where path is the file's path:
--   - Relative to the game executable (.exe) created and fused by LOVE2D or,
--   - Relative to the main.lua source directory
-- This allows for testing independent of the game being fused or not
function getFileContentsRelative(path)

    if love.filesystem.isFused() then
        local dir = love.filesystem.getSourceBaseDirectory()
        local success = love.filesystem.mount(dir, "base")
        if success then
           return love.filesystem.lines("base/"..path) 
        else 
            return nil
        end
    else
        return love.filesystem.lines(path)
    end

end

-- Returns a table containing the names of the directories/files within the given path:
--   - Relative to the game executable (.exe) created and fused by LOVE2D or,
--   - Relative to the main.lua source directory
-- This allows for testing independent of the game being fused or not
function getDirContentsRelative(path)

    local dir = nil

    if love.filesystem.isFused() then
        dir = love.filesystem.getSourceBaseDirectory()
        local success = love.filesystem.mount(dir, "base")
        return love.filesystem.getDirectoryItems("base/"..path)
    else
        return love.filesystem.getDirectoryItems(path)
    end

end

-- These functions from here onwards are the functions that manage the highscore file,
-- which contains highscores one at a line with the format
-- levelPath=score;combo;acc

-- This function returns the table of high scores. Said table contains element
-- of the following structure: "levelDir/levelFile.50m" = {score=xxxxxxx,combo=xxxxx,acc=xxx}
-- That is, for each level file, it contains the highest score, and the combo and acc of that score.
function getHighScoresFromFile()

    local highscores = {}

    if love.filesystem.exists(SAVE_FILE_NAME) then
        for highscore in love.filesystem.lines(SAVE_FILE_NAME) do
            -- Split the path and the scores
            local levelPath = nil
            local score, combo, acc = nil
            for element in highscore:gmatch("[^=]+") do
                if not levelPath then
                    levelPath = element
                else
                    -- Split each value of the score
                    for value in element:gmatch("[^;]+") do
                        if not score then
                            score = value
                        elseif not combo then
                            combo = value
                        elseif not acc then
                            acc = value
                        end
                    end
                end
            end

            -- Insert score
            highscores[levelPath] = {score=score,combo=combo,acc=acc}
        end
    end

    return highscores
end

-- Given a levelPath, score, combo and acc, this function will update the highscores
-- file if needed to reflect the highest score.
-- Returns true if file was updated due to higher score.
function updateHighScoresFile(levelPath, score, combo, acc)

    -- Fetch the highscores
    local highScores = getHighScoresFromFile()
    local fileData = ""

    -- Add the newest highscore
    if not highScores[levelPath] or tonumber(highScores[levelPath].score) < tonumber(score) then
        
        -- Update the score
        highScores[levelPath] = {score=score,combo=combo,acc=acc}

        -- Generate the file data
        for levelPath,scores in pairs(highScores) do
            fileData = fileData .. levelPath .. "=" .. tostring(scores.score) .. ";" .. tostring(scores.combo) .. ";" .. tostring(scores.acc) .. "\n"
        end

        -- Write file data
        love.filesystem.write(SAVE_FILE_NAME, fileData)

        return true
    end

    return false

end