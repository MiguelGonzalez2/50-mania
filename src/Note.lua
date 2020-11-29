--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    This file represents an in-game note (object that falls through the screen
    and must be hit at the correct time)
]]

Note = Class{}

-- Initializer for the note
-- * col: Column for the note (1-4)
-- * hitStamp: Seconds since the start of the song at which
-- this particular note should be hit for max points.
-- * releaseStamp: long notes only! Timesamp at which the note should be released.
function Note:init(col, hitStamp, releaseStamp) 

    self.col = col
    self.hitStamp = hitStamp
    self.releaseStamp = releaseStamp or nil

    -- Init a timer for the note (seconds from song start)
    self.x, self.y = COLUMN_OFFSET+NOTE_WIDTH*(self.col-1), nil
    self.width, self.height = NOTE_WIDTH, NOTE_HEIGHT

    if self.releaseStamp then
        self.height = (self.releaseStamp - self.hitStamp)*NOTE_SPEED
    end

    -- How the note was judged
    self.judgement = nil

end

-- Update function: the song's timeStamp should be provided
-- as an argument in order to properly compute coordinates.
--
-- Optional argument force can be passed to force the update
-- even if results wouldnt be visible.
--
-- RETURNS false if note schedule time is so late that it wouldnt
-- appear on the screen yet (hence it wasnt updated), true otherwise
function Note:update(timeStamp,force)

    local hitStamp,judgement,releaseStamp,height = self.hitStamp, self.judgement, self.releaseStamp, self.height

    -- The note should hit the judge line at its hitStamp, so we
    -- spawn it only if there's time to do so, and if it hasnt been judged or
    -- otherwise its a long note that is still visible
    if force or ((hitStamp - timeStamp)*NOTE_SPEED < JUDGE_LINE_POS and (not judgement or (releaseStamp and (timeStamp - releaseStamp) <= TIMING_WINDOWS[#TIMING_WINDOWS]))) then
        -- Update Y coordinate depending on remaining time
        if not releaseStamp then
            self.y = JUDGE_LINE_POS - (hitStamp - timeStamp)*NOTE_SPEED + NOTE_HEIGHT/2 - height
        else
            self.y = JUDGE_LINE_POS - (hitStamp - timeStamp)*NOTE_SPEED + NOTE_HEIGHT/2 - height
        end
        return true
    else
        return false
    end
end

-- Render function
function Note:render()

    local judgement = self.judgement

    -- Only render if its close enough and hasnt been judged. If judged but its a long note it should be rendered.
    if self.y and ((not judgement) or self.releaseStamp) then
        local color = NOTE_COLORS[self.col]

        -- Lower alpha if missed longnote
        if judgement == #TIMING_WINDOWS then
            color[4] = 170
        end
        love.graphics.setColor(color)
        color[4] = 255

        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end
end