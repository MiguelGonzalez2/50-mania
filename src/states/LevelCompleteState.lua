--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    This is a screen that shows the level recap after completing it
]]

LevelCompleteState = Class{__includes = BaseState}

-- [[Initializes the information]]
function LevelCompleteState:enter(status)

    self.score = status.score or 0
    self.maxcombo = status.maxcombo or 0
    self.judgements = status.judgements or nil
    self.acc = status.acc or 0
    self.notes = status.notes
    self.level = status.level or nil

    -- Update the highscores
    self.newHighScore = updateHighScoresFile(self.level.path, self.score, self.maxcombo, self.acc)

    -- Init mark
    self.mark = nil
    for i=1,#MARKS_THRESHOLDS do
        if self.acc >= MARKS_THRESHOLDS[i] then
            self.mark = i
            break
        end
    end
    if not self.mark then self.mark = #MARKS_THRESHOLDS + 1 end

    -- Init judgement panel
    self.judgementsPanel = JudgementRecap(self.judgements)
    -- Init mark panel after a bit
    self.markPanel = nil
    -- Init score panel after a bit
    self.scoresPanel = nil 
    --Graph Panel
    self.graphPanel = nil

    self.canInput = false

    -- Roll panels in
    Timer.after(RECAP_FADE_SEPARATION, function()
        self.markPanel = MarkDisplay(self.mark,self.newHighScore) 
        Timer.after(RECAP_FADE_SEPARATION, function()
            self.scoresPanel = ScoresPanel(self.score, self.acc, self.maxcombo)
            Timer.after(RECAP_FADE_SEPARATION, function()
                self.graphPanel = GraphPanel(self.notes)
                Timer.after(RECAP_FADE_SEPARATION, function()
                    self.infoPanel = InfoPanel()
                    self.canInput = true
                end)
            end)
        end)
    end)

    -- Audio
    love.audio.stop()
    gSounds['recap']:setLooping(1)
    gSounds['recap']:play()

end

function LevelCompleteState:update(dt)
    if self.canInput then
        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            gSounds['recap']:stop()
            gSounds['selected']:play()
            -- Reset level
            self.level:reset()
            gStateMachine:change('play', self.level)
        elseif love.keyboard.wasPressed('escape') then
            gSounds['recap']:stop()
            gSounds['select']:play()
            gStateMachine:change('levelSelect')
        end
    end
end

function LevelCompleteState:render()

    -- background
    if self.level.background then
        local bg = self.level.background
        love.graphics.setColor(255,255,255,130)
        love.graphics.draw(bg,0,0,0,VIRTUAL_WIDTH/bg:getWidth(), VIRTUAL_HEIGHT/bg:getHeight())
    end

    self.judgementsPanel:render()

    if self.markPanel then
        self.markPanel:render()
    end

    if self.scoresPanel then
        self.scoresPanel:render()
    end

    if self.graphPanel then
        self.graphPanel:render()
    end

    if self.infoPanel then
        self.infoPanel:render()
    end

end