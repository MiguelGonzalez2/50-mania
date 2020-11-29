--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    The Judge keeps track of how the player hits the notes. When rendered, displays
    text feedback (Miss, Bad, Good, Great, Excelent or MAX) depending on the accuracy
    of the hit.
]]

Judge = Class{}

function Judge:init(notes, longNoteCount)

    self.notes = notes -- Keeps track of notes

    self.nextNotes = {0,0,0,0} -- Index of next note of the column

    self:forwardNextNotes({1,2,3,4}) -- Update pointers on every column

    self.score = 0
    self.combo = 0
    self.maxcombo = 0
    self.hp = MAX_HP

    -- Score that gets displayed. It's different so it can be tweened
    self.displayScore = 0
    self.displayScoreTween = nil

    -- HP that gets diplayed, different so it can be tweened
    self.displayHp = MAX_HP
    self.displayHpTween = nil

    -- Which judgement text will we draw
    self.drawJudgement = -1
    -- Scale for the judgement text, for aesthetics
    self.drawJudgementScale = 0
    self.drawJudgementScaleTween = nil
    -- Scale for combo for aesthetics
    self.drawComboScale = 1
    self.drawComboScaleTween = nil

    -- Counter for each judgement, init dynamically in case more windows are added
    self.judgements = {}
    for i=1,#TIMING_WINDOWS do
        self.judgements[i] = 0
    end

    -- Tracks if long notes are being held
    self.holding = {false, false, false, false}
    self.longNoteCount = longNoteCount

    -- Particle system for visuals
    self.psystem = love.graphics.newParticleSystem(gTextures['hitParticle'], 200)
    self.psystem:setParticleLifetime(1,1.5)
    self.psystem:setEmissionRate(200)
    self.psystem:setLinearAcceleration(-50,-400,50,0)
    self.psystem:setSizes(2,1.5,1)
    self.psystem:setAreaSpread('uniform', NOTE_WIDTH/2, 5)
    self.psystem:setColors(unpack(PARTICLE_COLOR))


    -- Which columns to draw particles at. Held columns will be drawn regardless.
    -- For simplicity, its a counter on how many frames should particles be drawn for
    self.drawParticles = {0,0,0,0}

    -- Allows te judge to be paused so that it doesnt update even on timers.
    self.paused = false
end

-- Updates state depending on current stamp of the song (in seconds, from song start)
function Judge:update(timestamp)

    if self.paused then return end

    -- Judgements we've made
    local currentJudgements = {}
    -- Which columns did we judge
    local judgedNotes = {}
    -- Cache the score so we can detect if it's changed and tween
    local oldScore = self.score
    -- Cache the HP similarly
    local oldHP = self.hp
    -- Cache the combo
    local oldCombo = self.combo

    for col=1,4 do

        -- Dont assess notes that dont exist
        if self.nextNotes[col] == -1 then
            -- Reset particles if needed
            if self.drawParticles[col] > 0 then
                self.drawParticles[col] = self.drawParticles[col] - 1
            end
            goto continue
        end

        -- Checks for regular notes
        if not self.holding[col] then
            -- Check if there was a key press
            if love.keyboard.wasPressed(string.lower(KEYS[col])) then
                local offset = math.abs(timestamp - self.notes[self.nextNotes[col]].hitStamp)
                -- Assess every window
                for i=1,#TIMING_WINDOWS do
                    if offset <= TIMING_WINDOWS[i] then
                        currentJudgements[#currentJudgements+1] = i
                        -- Increase score
                        self.score = self.score + JUDGE_SCORES[i]
                        self.judgements[i] = self.judgements[i] + 1
                        -- Increase combo
                        if i ~= #TIMING_WINDOWS then
                            self.combo = self.combo + 1
                            -- Draw particle effect
                            self.drawParticles[col] = HIT_PARTICLE_DURATION+1
                        else
                            -- Miss
                            self.maxcombo = math.max(self.maxcombo, self.combo)
                            self.combo = 0
                        end

                        -- Update HP
                        self.hp = math.min(math.max(self.hp + HP_VALUES[i],0),MAX_HP)

                        -- update note
                        self.notes[self.nextNotes[col]].judgement = i

                        -- If its a short note it's been completely judged
                        if not self.notes[self.nextNotes[col]].releaseStamp then
                            judgedNotes[#judgedNotes+1]=col
                        end

                        -- if its not a miss and its a long note, hold
                        if self.notes[self.nextNotes[col]].releaseStamp and i < #TIMING_WINDOWS then
                            self.holding[col] = true
                            -- Decrease combo by one, because long-note combo is computed differently (via longNoteComboIncrease)
                            self.combo = self.combo - 1
                            -- Start increasing combo
                            self:longNoteComboIncrease(col)
                        end
                        break
                    end
                end

            -- Always check for a miss due to not hitting (that is, offset larger than the second-to-last tier)
            elseif (timestamp - self.notes[self.nextNotes[col]].hitStamp) > TIMING_WINDOWS[#TIMING_WINDOWS-1] then
                judgedNotes[#judgedNotes+1]=col
                currentJudgements[#currentJudgements+1] = #TIMING_WINDOWS
                -- break combo
                self.maxcombo = math.max(self.maxcombo, self.combo)
                self.combo = 0
                self.judgements[#TIMING_WINDOWS] = self.judgements[#TIMING_WINDOWS] + 1
                -- update note
                self.notes[self.nextNotes[col]].judgement = #TIMING_WINDOWS
                -- Update HP
                self.hp = math.min(math.max(self.hp + HP_VALUES[#TIMING_WINDOWS],0),MAX_HP)
            end
        end

        -- Check for held long notes
        if self.holding[col] then
            -- Check if there was a key release
            if love.keyboard.wasReleased(string.lower(KEYS[col])) then
                local offset = math.abs(timestamp - self.notes[self.nextNotes[col]].releaseStamp)
                -- Assess every window
                for i=1,#TIMING_WINDOWS do
                    if offset <= TIMING_WINDOWS[i] then
                        judgedNotes[#judgedNotes+1]=col
                        currentJudgements[#currentJudgements+1] = i
                        -- Increase score
                        self.score = self.score + JUDGE_SCORES[i]
                        self.judgements[i] = self.judgements[i] + 1
                        if i == #TIMING_WINDOWS then
                            -- Miss
                            self.maxcombo = math.max(self.maxcombo, self.combo)
                            self.combo = 0
                        end
                        -- update note
                        self.notes[self.nextNotes[col]].judgement = i

                        -- Release
                        self.holding[col] = false
                        break
                    end
                end

                -- If key was released too early, miss
                if offset > TIMING_WINDOWS[#TIMING_WINDOWS] then
                    judgedNotes[#judgedNotes+1]=col
                    currentJudgements[#currentJudgements+1]=#TIMING_WINDOWS
                    -- Increase score
                    self.score = self.score + JUDGE_SCORES[#TIMING_WINDOWS]
                    self.judgements[#TIMING_WINDOWS] = self.judgements[#TIMING_WINDOWS] + 1
                    --miss
                    self.maxcombo = math.max(self.maxcombo, self.combo)
                    self.combo = 0
                    -- update note
                    self.notes[self.nextNotes[col]].judgement = #TIMING_WINDOWS

                    -- Release
                    self.holding[col] = false
                    break
                end

            -- Always check for a miss due to not releasing
            elseif (timestamp - self.notes[self.nextNotes[col]].releaseStamp) > TIMING_WINDOWS[#TIMING_WINDOWS-1] then
                judgedNotes[#judgedNotes+1]=col 
                currentJudgements[#currentJudgements+1] = #TIMING_WINDOWS
                -- break combo
                self.combo = 0
                self.judgements[#TIMING_WINDOWS] = self.judgements[#TIMING_WINDOWS] + 1
                -- update note
                self.notes[self.nextNotes[col]].judgement = #TIMING_WINDOWS
                -- Release
                self.holding[col] = false
            end
        end

        -- Decrease particle counter
        if self.drawParticles[col] > 0 then 
            self.drawParticles[col] = self.drawParticles[col] - 1
        end

        ::continue::
    end

    -- Update judgement to the worst one this round
    if #currentJudgements > 0 then
        self.drawJudgement = math.max(unpack(currentJudgements))

        -- Set timer for the scale, resetting previous
        if self.drawJudgementScaleTween then
            self.drawJudgementScaleTween:remove()
            self.drawJudgementScaleTween = nil
        end

        local fadeOut = function() self.drawJudgementScaleTween = Timer.tween(JUDGE_TEXT_APPEAR_TIME, {[self] = {drawJudgementScale = 0}}) end
        local holdAndFade = function() self.drawJudgementScaleTween = Timer.after(JUDGE_TEXT_HOLD_TIME, fadeOut) end

        self.drawJudgementScale = 0.8
        -- Fade in
        self.drawJudgementScaleTween = Timer.tween(JUDGE_TEXT_APPEAR_TIME, {[self] = {drawJudgementScale = 1}})
        -- Hold
        :finish(holdAndFade)

    end

    -- Make combo pulse if it rises
    if oldCombo ~= self.combo then
        if self.drawComboScaleTween then
            self.drawComboScaleTween:remove()
            self.drawComboScaleTween = nil
        end
        self.drawComboScale = 1
        local fadeOut = function()self.drawComboScaleTween = Timer.tween(COMBO_UPDATE_RELEASE_TIME, {[self] = {drawComboScale = 1}}) end
        -- Fade in
        self.drawComboScaleTween = Timer.tween(COMBO_UPDATE_ATTACK_TIME, {[self] = {drawComboScale = 1.1}}):finish( 
        -- Fade out
        fadeOut)
    end

    -- Tween score
    if self.score ~= oldScore then
        -- End previous tweens if any
        if self.displayScoreTween then
            self.displayScoreTween:remove()
            self.displayScoreTween = nil
            self.displayScore = oldScore
        end

        self.displayScoreTween = Timer.tween(SCORE_UPDATE_TIME, {[self] = {displayScore = self.score}})
    end

    -- Tween HP
    if self.hp ~= oldHP then
        -- End previous tweens if any
        if self.displayHpTween then
            self.displayHpTween:remove()
            self.displayHpTween = nil
            self.displayHp = oldHP
        end

        self.displayHpTween = Timer.tween(HP_UPDATE_TIME, {[self] = {displayHp = self.hp}})
    end

    -- Forward pointers
    self:forwardNextNotes(judgedNotes)

end

-- Render the different parameters 
function Judge:render()

    -- Score, combo, acc. Score is normalized so that max becomes MAX_SCORE points
    local scoreText = love.graphics.newText(gFonts['score'], string.format("%07d",math.floor(self.displayScore*MAX_SCORE/(JUDGE_SCORES[1]*(#self.notes+self.longNoteCount)))))
    local comboText = love.graphics.newText(gFonts['combo'], 'x'..tostring(self.combo))
    local accText = love.graphics.newText(gFonts['acc'], string.format("%.2f",self:getAcc()).."%")
    
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(scoreText, VIRTUAL_WIDTH - scoreText:getWidth() - 10, 10)
    love.graphics.draw(accText, VIRTUAL_WIDTH - accText:getWidth() - 10, 10 + scoreText:getHeight())

    if self.combo > 0 then
        love.graphics.setColor(255,255,255,180)
        love.graphics.draw(comboText, VIRTUAL_WIDTH / 2, COMBO_TEXT_POS, 0, self.drawComboScale, self.drawComboScale, comboText:getWidth() / 2,comboText:getHeight() / 2)
    end

    -- Judgement
    if self.drawJudgement > 0 then
        love.graphics.setColor(unpack(JUDGE_COLORS[self.drawJudgement]))
        local judgeText = love.graphics.newText(gFonts['judge'], JUDGE_TEXTS[self.drawJudgement])
        love.graphics.draw(judgeText, VIRTUAL_WIDTH / 2, JUDGE_TEXT_POS, 0, self.drawJudgementScale, self.drawJudgementScale, judgeText:getWidth()/2, judgeText:getHeight()/2)
    end

    -- Particles
    for col=1,4 do
        if self.drawParticles[col] > 0 or self.holding[col] then
            love.graphics.setColor(255,255,255,255)
            love.graphics.draw(self.psystem, COLUMN_OFFSET + (col-1)*NOTE_WIDTH + NOTE_WIDTH/2,JUDGE_LINE_POS)
        end
    end

    -- HP
    love.graphics.setColor(255,0,0,255)
    love.graphics.rectangle('fill', COLUMN_OFFSET + 4*NOTE_WIDTH+7, VIRTUAL_HEIGHT - HEALTH_BAR_HEIGHT*(self.displayHp/MAX_HP)-2, HEALTH_BAR_WIDTH, HEALTH_BAR_HEIGHT)
    love.graphics.setColor(255,255,255,255)
    love.graphics.rectangle('line', COLUMN_OFFSET + 4*NOTE_WIDTH+7, VIRTUAL_HEIGHT - HEALTH_BAR_HEIGHT-2, HEALTH_BAR_WIDTH, HEALTH_BAR_HEIGHT)
end

-- Gives an accuracy percentage for the current play
function Judge:getAcc()

    local totalJudgements = 0
    local partialJudgements = 0

    for i=1,#self.judgements do

        -- Total is set to the maximum weigth posible
        totalJudgements = totalJudgements + self.judgements[i]*ACC_WEIGHTS[1]

        -- Partial is weighted accordingly
        partialJudgements = partialJudgements + self.judgements[i]*ACC_WEIGHTS[i]
    end

    if totalJudgements == 0 then
        return 100
    else
        return 100*partialJudgements/totalJudgements
    end

end

-- Forwards the next note pointers in the columns specified
-- sets them to -1 if no notes are found
function Judge:forwardNextNotes(cols)

    -- Sets nextNotes indices to that of the first 
    for i=1,#cols do
        local col = cols[i]
        -- If we didnt reach the end of the notes
        if self.nextNotes[col]+1 <= #self.notes then

            local modified = false

            -- Only check after the current pointer
            for i=(self.nextNotes[col]+1),#self.notes do
                -- If columns matches
                if self.notes[i].col == col then
                    -- Set new pointer
                    self.nextNotes[col] = i
                    modified = true
                    break
                end
            end

            -- No more notes in the column
            if not modified then
                self.nextNotes[col] = -1
            end

        else 
            -- Indicates end of column
            self.nextNotes[col] = -1
        end
    end

end

-- This function increases combo on a timer if a long note is being held
function Judge:longNoteComboIncrease(col)

    local comboIncrease = function() self:longNoteComboIncrease(col) end
    if self.holding[col] then
        -- Increase combo
        if not self.paused then
            self.combo = self.combo+1
        end
        -- Schedule new check
        Timer.after(LONG_NOTE_COMBO_DELAY, comboIncrease)
        -- Return
        return
    end
end

-- Pauses all the judge functionality
function Judge:pause()
    self.paused = true
end

-- Resumes all the judge functionality
function Judge:resume()
    self.paused = false
end