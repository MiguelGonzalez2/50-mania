--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)
]]

PlayState = Class{__includes = BaseState}

function PlayState:enter(level)
    
    -- Level itself
    self.level = level

    -- Level chart
    self.chart = self.level.chart

    -- Notes that compose the chart
    self.notes = self.chart.notes

    -- Pointers to the first and last note that are relevant to the screen
    -- This will update in order to avoid processing notes that are far
    -- beyond the screen scope.
    self.minNote = 1
    self.maxNote = #self.notes

    -- These will be set to true whenever the last visible note of a column has been
    -- processed. When all are true, we can cut the processing since no more notes
    -- are visible. (Only for optimization purposes)
    self.processedColumns = {false, false, false, false}

    -- Judge that tracks scores depending on acc
    self.judge = Judge(self.notes, self.chart.longNoteCount)

    -- Timer that indicates the beginning of the song
    --self.timer = 0

    -- Background
    self.background = level.background

    -- Fade into the level then start song
    self.fadeIn = 255 -- Alpha for the fadein
    self.song = self.level.song
    self.songPitch = 1 -- Pitch for gameover
    Timer.tween(LEVEL_START_FADE_TIME, {[self] = {fadeIn = 0}}):finish(function()
        self.song:play()
        self.fadeIn = nil
    end)
    

    -- Gradients for aesthetics when a key is pressed
    self.gradients = {}
    for i=1,4 do
        local opaque = {unpack(NOTE_COLORS[i])}
        local transparent = {unpack(NOTE_COLORS[i])}
        opaque[4] = 180
        transparent[4] = 0
        self.gradients[i] = gradient{direction='horizontal'; transparent, opaque}
    end

    -- Pause menu
    self.paused = false
    self.pauseX = VIRTUAL_WIDTH+50

end

function PlayState:update(dt)
    
    local timer = self.song:tell()
    
    if not self.paused then
        --Not paused

        -- Update the judge if we havent lost
        if self.judge.hp > 0 then
            self.judge:update(timer)
        end
        self.judge.psystem:update(dt)

        -- Update min pointer as the lowest of the judge's pointers of columns that have notes in them (not -1)
        self.minNote = #self.notes
        for i=1,4 do
            local ptr = self.judge.nextNotes[i]
            if ptr ~= -1 then
                self.minNote = math.min(self.minNote, ptr)
            end
        end

        -- Reset processed columns
        self.processedColumns = {false, false, false, false}

        -- Update notes
        for i=self.minNote,#self.notes do

            -- Update the actual note
            local note = self.notes[i]
            -- Set column to be processed whenever note:update returns true
            self.processedColumns[note.col] = not note:update(timer)

            -- Break if all columns are done
            local willBreak = true
            for j=1,4 do
                if self.processedColumns[j] == false then
                    willBreak = false
                    break
                end
            end
            if willBreak then 
                self.maxNote = i
                break 
            end

        end

        -- Update timer
        --self.timer = self.timer + dt

        -- TRANSITION TO LEVEL COMPLETE
        if not self.song:isPlaying() and not self.fadeIn and self.judge.hp > 0 then
            self.judge.maxcombo = math.max(self.judge.maxcombo, self.judge.combo)
            gStateMachine:change('recap', {level=self.level,score=math.floor(self.judge.score*MAX_SCORE/(JUDGE_SCORES[1]*(#self.notes+self.judge.longNoteCount))), maxcombo=self.judge.maxcombo, judgements = self.judge.judgements, acc=self.judge:getAcc(), notes=self.notes})
        end

        -- TRANSITION TO GAME OVER
        if self.judge.displayHp <= 0 then
            -- Start the fade
            if not self.fadeIn then
                self.fadeIn = 0
                Timer.tween(GAME_OVER_SONG_DECAY, {[self] = {songPitch = 0.4, fadeIn=255}}):finish(function()
                    self.level.song:stop()
                    gStateMachine:change('gameOver', self.level)
                end)
            else
                self.level.song:setPitch(self.songPitch)
            end
        end

        -- Pause key
        if love.keyboard.wasPressed('escape') and not self.fadeIn then
            gSounds['select']:play()
            self.paused = true
            self.song:pause()
            self.judge:pause()
            self.fadeIn = 0 -- Trigger a "fade" to disable inputs
            -- Show the pause menu
            Timer.tween(PAUSE_TRANSITION_TIME, {[self] = {pauseX=VIRTUAL_WIDTH-200}}):finish(function()self.fadeIn=nil end)
        end

    else

        -- Cant do pause actions while fading
        if self.fadeIn then return end

        --Paused
        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            --Resume
            gSounds['select']:play()
            self.fadeIn = 0 -- Trigger a "fade" to disable inputs

            -- Move the pause menu to the side
            Timer.tween(PAUSE_TRANSITION_TIME, {[self] = {pauseX=VIRTUAL_WIDTH+50}}):finish(function()
                self.fadeIn=nil 
                self.paused = false
                self.song:resume()
                self.judge:resume()
            end)

        elseif love.keyboard.wasPressed('escape') then
            -- Back to level select
            gSounds['select']:play()
            -- Fade to the level select state
            self.fadeIn = 0
            Timer.tween(LEVEL_START_FADE_TIME, {[self] = {fadeIn = 255}}):finish(function()
                self.song:stop()
                gStateMachine:change('levelSelect')
            end)
        elseif love.keyboard.wasPressed('r') then
            -- Restart the level
            gSounds['selected']:play()
            self.fadeIn = 0
            Timer.tween(LEVEL_START_FADE_TIME, {[self] = {fadeIn = 255}}):finish(function()
                self.song:stop()
                self.level:reset()
                gStateMachine:change('play',self.level)
            end)
        end
    end

    -- Faster scroll speed
    if love.keyboard.wasPressed('f4') and not self.fadeIn then
        NOTE_SPEED = math.min(MAX_SCROLL_SPEED, math.max(MIN_SCROLL_SPEED, NOTE_SPEED+CHANGE_SCROLL_SPEED))
        -- Reset the pointers since new notes might have appeared on screen due to the change
        self.minNote = 1
        self.maxNote = #self.notes
        self:fixNotes(timer)
    end

    -- slower scroll speed
    if love.keyboard.wasPressed('f3') and not self.fadeIn then
        NOTE_SPEED = math.min(MAX_SCROLL_SPEED, math.max(MIN_SCROLL_SPEED, NOTE_SPEED-CHANGE_SCROLL_SPEED))
        -- Reset the pointers since new notes might have appeared on screen due to the change
        self.minNote = 1
        self.maxNote = #self.notes
        self:fixNotes(timer)
    end

end

function PlayState:render()

    -- Background
    if self.background then
        local bg = self.background
        love.graphics.setColor(255,255,255,150)
        love.graphics.draw(bg,0,0,0,VIRTUAL_WIDTH/bg:getWidth(), VIRTUAL_HEIGHT/bg:getHeight())
    end

    -- Render notes
    for i=self.minNote,self.maxNote do
        self.notes[i]:render()
    end

    -- Render actual keys
    for i = 1,4 do
        -- Color depending on whether its pressed or not
        if love.keyboard.isDown(string.lower(KEYS[i])) then
            love.graphics.setColor(200,200,200,255)

            -- Create a gradient for aesthetics using library lib/gradient.lua
            drawinrect(self.gradients[i], COLUMN_OFFSET + (i-1)*NOTE_WIDTH, JUDGE_LINE_POS-GRADIENT_HEIGHT,NOTE_WIDTH,GRADIENT_HEIGHT)
        else
            love.graphics.setColor(100,100,100,255)
        end

        -- Rectangle
        love.graphics.rectangle('fill', COLUMN_OFFSET + (i-1)*NOTE_WIDTH, JUDGE_LINE_POS, NOTE_WIDTH, VIRTUAL_HEIGHT - JUDGE_LINE_POS)

        -- Text
        love.graphics.setColor(20,20,20,255)
        local keyText = love.graphics.newText(gFonts['combo'], KEYS[i])
        love.graphics.draw(keyText, COLUMN_OFFSET + (i-1)*NOTE_WIDTH + NOTE_WIDTH/2, VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - JUDGE_LINE_POS) / 2 ,0,1,1,keyText:getWidth()/2,keyText:getHeight()/2)

    end

    -- Render edges of the game
    love.graphics.setColor(255,255,255,255)
    love.graphics.rectangle('fill',COLUMN_OFFSET-5,0,5,VIRTUAL_HEIGHT)
    love.graphics.rectangle('fill',COLUMN_OFFSET+4*NOTE_WIDTH,0,5,VIRTUAL_HEIGHT)

    -- Render note separators
    love.graphics.setColor(150,150,150,255)
    for i=1,3 do
        love.graphics.rectangle('fill', COLUMN_OFFSET + i*NOTE_WIDTH, 0, 1, VIRTUAL_HEIGHT)
    end

    -- Render Judge line
    love.graphics.setColor(255,255,255,255)
    love.graphics.rectangle('fill', COLUMN_OFFSET, JUDGE_LINE_POS - 4, 4*NOTE_WIDTH, 4)
    -- Render song duration UI
    local duration = self.song:getDuration()
    local current = self.song:tell()

    -- Circle outline
    love.graphics.circle('line', CLOCK_POS.x + CLOCK_RADIUS, CLOCK_POS.y + CLOCK_RADIUS, CLOCK_RADIUS)
    love.graphics.setLineWidth(5)
    -- Wedge indicating current time. It has a minimum angle of 0.2, otherwise it looks kinda ugly
    love.graphics.arc('fill', CLOCK_POS.x + CLOCK_RADIUS, CLOCK_POS.y + CLOCK_RADIUS, CLOCK_RADIUS, -math.pi/2, math.max(2*math.pi*current/duration-math.pi/2, 0.2-math.pi/2))

    -- Render Judge
    self.judge:render()

    -- Render pause info
    if self.paused then
        love.graphics.setColor(255,255,255,255)
        love.graphics.rectangle('line',self.pauseX,VIRTUAL_HEIGHT/2-100,500,110)

        local texts = {love.graphics.newText(gFonts['infoSmall'], "Enter: "),
        love.graphics.newText(gFonts['infoSmall'], "R: "),
        love.graphics.newText(gFonts['infoSmall'], "Esc: ")}

        local values = {love.graphics.newText(gFonts['infoSmall'], "Resume"),
            love.graphics.newText(gFonts['infoSmall'], "Replay Level"),
            love.graphics.newText(gFonts['infoSmall'], "Level Select")}

        -- Keep track of where to draw
        local ycursor = VIRTUAL_HEIGHT/2-100 + 10
        local xcursor = self.pauseX + 10
        -- Fill the rectangle
        for i=1,3 do
            xcursor = self.pauseX+10
            love.graphics.setColor(150,150,150,255) --Gray
            love.graphics.draw(texts[i], xcursor, ycursor)
            xcursor = xcursor + texts[i]:getWidth()
            love.graphics.setColor(255,255,255,255) --White
            love.graphics.draw(values[i], xcursor, ycursor)
            ycursor = ycursor + values[i]:getHeight() + INFO_PANEL_PADDING
        end
    end

    -- Box with info about keys and scroll speed
    local infoAlpha = 1/(1+math.exp(-math.abs(self.pauseX - (VIRTUAL_WIDTH-200))))*255 -- Compute alpha based on the distance between the pause menu and its final location.
    local infoWidth, infoHeight = 260,135
    local infoX, infoY = 40, VIRTUAL_HEIGHT - 40 - infoHeight
    love.graphics.setColor(255,255,255,255)
    love.graphics.rectangle('line',infoX,infoY,infoWidth,infoHeight)

    local texts = {love.graphics.newText(gFonts['infoSmall'], "Esc: "),
    love.graphics.newText(gFonts['infoSmall'], "F3: "),
    love.graphics.newText(gFonts['infoSmall'], "F4: "),
    love.graphics.newText(gFonts['infoSmall'], "Current scroll: ")}

    local values = {love.graphics.newText(gFonts['infoSmall'], "Pause Game"),
        love.graphics.newText(gFonts['infoSmall'], "Slower Scroll"),
        love.graphics.newText(gFonts['infoSmall'], "Faster Scroll"),
        love.graphics.newText(gFonts['infoSmall'], tostring((NOTE_SPEED-MIN_SCROLL_SPEED)/CHANGE_SCROLL_SPEED))}

    -- Keep track of where to draw
    local ycursor = infoY + 10
    local xcursor = infoX + 10
    -- Fill the rectangle
    for i=1,4 do
        xcursor = infoX + 10
        love.graphics.setColor(150,150,150,i~=1 and 255 or infoAlpha) --Gray
        love.graphics.draw(texts[i], xcursor, ycursor)
        xcursor = xcursor + texts[i]:getWidth()
        love.graphics.setColor(255,255,255,i~=1 and 255 or infoAlpha) --White
        love.graphics.draw(values[i], xcursor, ycursor)
        ycursor = ycursor + values[i]:getHeight() + INFO_PANEL_PADDING
    end

    -- Render low HP rectangle
    if self.judge.displayHp < LOW_HP_THRESHOLD then
        love.graphics.setColor(255,0,0,(LOW_HP_THRESHOLD - self.judge.displayHp)*200/LOW_HP_THRESHOLD)
        love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    end

    -- FadeIn
    if self.fadeIn then
        love.graphics.setColor(255, 255, 255, self.fadeIn)
        love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    end

end

-- If the scroll speed has changed, long note sizes should change accordingly to last the correct amount of time.
function PlayState:fixNotes(timestamp)
    for i=1,#self.notes do
        if self.notes[i].releaseStamp then
            self.notes[i].height = (self.notes[i].releaseStamp - self.notes[i].hitStamp)*NOTE_SPEED
        end
        self.notes[i]:update(timestamp, true) -- Force updates since notes positions must change due to different speed
    end
end