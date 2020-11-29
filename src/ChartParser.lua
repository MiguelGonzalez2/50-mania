--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    This file contains the Chart Parser, which reads song chart files
    and imports the note timestamps accordingly.

    FILE FORMAT:

    Line 1 -> 50!ManiaV1
    Line 2 -> Parameters in the format name=value separated by semicolon
    Line 3 onwards: Notes with format column:timestamp(ms):release(ms)
    RELEASE SHOULD ONLY APPEAR ON LONG NOTES

    Example:

    50!ManiaV1
    title=AiAe;author=Miguel Gonzalez;songName=AiAe;songAuthor=Yuyoyuppe;difficulty=Hard
    1:1000
    1:1500
    2:1500
    1:3000
    4:2000

    Supported parameters:
    title: Level title
    author: Level author
    songName: Name of the song that plays
    songAuthor: Author of the song that plays
    difficulty: String describing the difficulty of the song
    diffColor: r,g,b containing a color for the difficulty (ex: 255,0,0 for red)
]]

ChartParser = Class{}

function ChartParser:init(filename)
    
    local parsed = ChartParser:parseFile(filename)
    -- Load notes
    self.notes = parsed.notes or nil
    self.longNoteCount = parsed.longNoteCount or nil
    self.params = parsed.params or nil

end

-- Reads through the file parsing the notes
function ChartParser:parseFile(filename)

    local longNoteCount = 0

    --[[ -- Check if file exists via opening it
    local file = io.open(filename, "rb")
    if not file then
        return nil
    end
    file.close() ]]

    -- Keeps track of which line are we scanning
    local linePointer = 1

    -- Keeps track of found notes
    local notes = {}

    -- Keeps track of parameters
    local params = {}

    for line in getFileContentsRelative(filename) do

        -- Check format header
        if linePointer == 1 then
            if line ~= "50!ManiaV1" then
                return nil
            end
        end

        -- Grab params
        if linePointer == 2 then
            -- Split by semicolon
            for parameter in line:gmatch("[^;]+") do
                local paramName = nil
                -- Split by equals
                for element in parameter:gmatch("[^=]+") do
                    if not paramName then
                        paramName = element
                    else
                        params[paramName] = element -- Assign key-value pair
                    end
                end
            end
        end

        -- Grab notes
        if linePointer >= 3 then
            
            local stamp = 0
            local column = 1
            local release = nil
            local parsingField = 0

            -- Parse line: we split using gmatch and looking for a colon
            for match in line:gmatch("[^:]+") do
                if parsingField  == 0 then
                    column = tonumber(match)
                    parsingField  = parsingField + 1
                elseif parsingField == 1 then
                    stamp = tonumber(match)/1000 -- From ms to s
                    parsingField = parsingField + 1
                else
                    release = tonumber(match)/1000 -- From ms to s
                    longNoteCount = longNoteCount + 1
                end
            end

            notes[#notes+1] = Note(column, stamp, release)
        end

        -- Increase pointer
        linePointer = linePointer + 1
    end
   
    return {notes = notes, longNoteCount = longNoteCount, params = params}
end