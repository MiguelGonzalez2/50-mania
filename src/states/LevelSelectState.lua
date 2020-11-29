--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    State used for level selection.
]]

LevelSelectState = Class{__includes = BaseState}

function LevelSelectState:init()

    -- Highscores
    self.highscores = getHighScoresFromFile()

    -- Level information
    self.levels = self:parseLevels()
    self.panels = self:generatePanels()
    self.selectedPanel = 1

    -- Fade out
    self.fadeOut = 255
    Timer.tween(LEVEL_START_FADE_TIME, {[self] = {fadeOut = 0}}):finish(function()
        self.fadeOut = nil
        self.canInput = true
        
        --Preview song
        if self.levels and #self.levels > 0 then
            self.previewSong = self.levels[self.selectedPanel].song
            self.previewSong:play()
            -- Jump at halfway in
            self.previewSong:seek(self.previewSong:getDuration()/2)
        end
    end)

end

function LevelSelectState:update()

    -- if we are not fading
    if not self.fadeOut then
        -- Selection
        if love.keyboard.wasPressed('down') then
            if self.selectedPanel == #self.panels then
                gSounds['cantSelect']:play()
            else
                self.selectedPanel = self.selectedPanel+1
                -- Change song
                self.previewSong:stop()
                self.previewSong = self.levels[self.selectedPanel].song
                self.previewSong:play()
                -- Jump at halfway in
                self.previewSong:seek(self.previewSong:getDuration()/2)
                gSounds['select']:play()
            end
        elseif love.keyboard.wasPressed('up') then
            if self.selectedPanel == 1 then
                gSounds['cantSelect']:play()
            else
                self.selectedPanel = self.selectedPanel-1
                -- Change song
                self.previewSong:stop()
                self.previewSong = self.levels[self.selectedPanel].song
                self.previewSong:play()
                -- Jump at halfway in
                self.previewSong:seek(self.previewSong:getDuration()/2)
                gSounds['select']:play()
            end
        elseif love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            self.previewSong:stop()
            gSounds['selected']:play()
            self.fadeOut = 0
            Timer.tween(LEVEL_START_FADE_TIME, {[self] = {fadeOut = 255}}):finish(function()
                gStateMachine:change("play", self.levels[self.selectedPanel])
            end)
        elseif love.keyboard.wasPressed('escape') then
            self.previewSong:stop()
            gSounds['select']:play()
            self.fadeOut = 0
            Timer.tween(LEVEL_START_FADE_TIME, {[self] = {fadeOut = 255}}):finish(function()
                gStateMachine:change("titleScreen")
            end)
        end
    end
end

function LevelSelectState:render()

    -- No levels text
    if not self.levels or #self.levels == 0 then
        love.graphics.setColor(255,255,255,255)
        love.graphics.setFont(gFonts["recapSmall"])
        love.graphics.print("No levels found! Check your level folder!", 20, 20)
        return
    end

    -- Render selected background
    if self.levels[self.selectedPanel].background then
        local bg = self.levels[self.selectedPanel].background
        love.graphics.setColor(255,255,255,150)
        love.graphics.draw(bg,0,0,0,VIRTUAL_WIDTH/bg:getWidth(), VIRTUAL_HEIGHT/bg:getHeight())
    end

    -- Render "LEVEL SELECT"
    local select = love.graphics.newText(gFonts["infoBig"], "LEVEL SELECT")
    love.graphics.setColor(0,0,0,255)
    love.graphics.draw(select, 45, 45)
    love.graphics.setColor(200,200,230,255)
    love.graphics.draw(select, 40, 40)

    -- Render levels
    for i,level in ipairs(self.panels) do
        -- Set height depending on selection
        level.y = LEVEL_SELECT_PANEL_POS.y + (20+LEVEL_PANEL_SIZE.height)*(i-self.selectedPanel)
        if i == self.selectedPanel then
            level.xscale,level.yscale = 1.2,1.2
            level.x = LEVEL_SELECT_PANEL_POS.x-50
        else
            level.xscale,level.yscale,level.x = 1,1,LEVEL_SELECT_PANEL_POS.x
        end

        -- Move down levels past the selected one, since its scaled, to avoid overlapping
        if i > self.selectedPanel then
            level.y = level.y + 20
        end

        -- Render level panel
        level:render()
    end

    -- Fetch highscore
    local highscore = self.highscores[self.levels[self.selectedPanel].path]
    local texts = nil
    local values = nil
    -- Render highscore panel
    if highscore then
        texts = {love.graphics.newText(gFonts['recapSmall'], "Highscore: "),
            love.graphics.newText(gFonts['recapSmall'], "Accuracy: "),
            love.graphics.newText(gFonts['recapSmall'], "Max Combo: ")}
        values = {love.graphics.newText(gFonts['recapSmall'], highscore.score),
            love.graphics.newText(gFonts['recapSmall'], string.format("%.2f", tonumber(highscore.acc)) .. "%"),
            love.graphics.newText(gFonts['recapSmall'], "x"..highscore.combo)}

        for i=1,#texts do
            love.graphics.setColor(255,255,255,255)
            love.graphics.draw(texts[i], HIGHSCORE_PANEL_POS.x+20, 10+HIGHSCORE_PANEL_POS.y+(i-1)*(texts[1]:getHeight()+20))
            love.graphics.setColor(180,180,180,255)
            love.graphics.draw(values[i], HIGHSCORE_PANEL_POS.x+texts[i]:getWidth()+20, 10+HIGHSCORE_PANEL_POS.y+(i-1)*(texts[1]:getHeight()+20))
        end
    else
        love.graphics.setColor(255,255,255,255)
        texts = {love.graphics.newText(gFonts['recapSmall'], "No highscore yet!")}
        love.graphics.draw(texts[1], HIGHSCORE_PANEL_POS.x+20, 10+HIGHSCORE_PANEL_POS.y)
    end
    --Outline
    love.graphics.setColor(255,255,255,255)
    love.graphics.rectangle('line', HIGHSCORE_PANEL_POS.x, HIGHSCORE_PANEL_POS.y, VIRTUAL_WIDTH / 3.5, highscore and texts[1]:getHeight()*3+60 or texts[1]:getHeight()+20)

    -- Render box with information
    local infoWidth, infoHeight = 260,110
    local infoX, infoY = 40, VIRTUAL_HEIGHT - 40 - infoHeight
    love.graphics.setColor(255,255,255,255)
    love.graphics.rectangle('line',infoX,infoY,infoWidth,infoHeight)

    local texts = {love.graphics.newText(gFonts['infoSmall'], "Up/Down: "),
    love.graphics.newText(gFonts['infoSmall'], "Enter: "),
    love.graphics.newText(gFonts['infoSmall'], "Esc: ")}

    local values = {love.graphics.newText(gFonts['infoSmall'], "Select Level"),
        love.graphics.newText(gFonts['infoSmall'], "Play Level"),
        love.graphics.newText(gFonts['infoSmall'], "Back to Title")}

    -- Keep track of where to draw
    local ycursor = infoY + 10
    local xcursor = infoX + 10
    -- Fill the rectangle
    for i=1,3 do
        xcursor = infoX + 10
        love.graphics.setColor(150,150,150,255) --Gray
        love.graphics.draw(texts[i], xcursor, ycursor)
        xcursor = xcursor + texts[i]:getWidth()
        love.graphics.setColor(255,255,255,255) --White
        love.graphics.draw(values[i], xcursor, ycursor)
        ycursor = ycursor + values[i]:getHeight() + INFO_PANEL_PADDING
    end

    -- Fade out
    if self.fadeOut then
        love.graphics.setColor(255, 255, 255, self.fadeOut)
        love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    end
end

-- Loads levels from disk. Levels should be in the levels directory
-- specified in the constants file. The level directory should be organized
-- as follows: there must be one subdirectory per song, containing said song
-- in an mp3 file, and within that subdirectory there must be all the levels
-- that use the song (.50m files). Each subdirectory may contain a png/jpg background
-- for levels in that directory.
function LevelSelectState:parseLevels()

    local levels = {}

    for _,directory in pairs(getDirContentsRelative(LEVEL_DIRECTORY)) do

        local songName = nil
        local bgName = nil
        -- First fetch the song and the bg image
        for _,element in pairs(getDirContentsRelative(LEVEL_DIRECTORY .. "/" .. directory)) do
            if element:sub(-3) == "mp3" then
                songName = element
            end

            if element:sub(-3) == "png" or element:sub(-3) == "jpg" then
                bgName = element
            end
        end

        local music = nil
        local bg = nil

        -- Create a sound object
        if songName then
            music = love.audio.newSource(getPath(LEVEL_DIRECTORY.."/".. directory .. "/" .. songName), "stream")
        else
            goto continue
        end

        -- Create the background graphic
        if bgName then
            bg = love.graphics.newImage(getPath(LEVEL_DIRECTORY.."/".. directory .. "/" .. bgName))
        end

        -- Fetch all the levels (50m files) in the folder
        for _,element in pairs(getDirContentsRelative(LEVEL_DIRECTORY .. "/" .. directory)) do
            if element:sub(-3) == "50m" then
                -- Parse the file
                local chart = ChartParser(LEVEL_DIRECTORY.."/".. directory .. "/" .. element)
                if chart then
                    local level = Level(music,chart,bg,directory .. "/" .. element)
                    levels[#levels+1] = level
                end
            end
        end

        ::continue::

    end

    return levels
end

-- Generate the visualizations of each level (panels)
function LevelSelectState:generatePanels() 

    local panels = {}
    local x,y = LEVEL_SELECT_PANEL_POS.x, LEVEL_SELECT_PANEL_POS.y

    for _,level in ipairs(self.levels) do

        -- Compute mark
        local mark = nil
        if self.highscores[level.path] then
            for i,threshold in ipairs(MARKS_THRESHOLDS) do
                if tonumber(self.highscores[level.path].acc) >= threshold then
                    mark = i
                    break
                end
            end
            if not mark then mark = #MARKS_THRESHOLDS + 1 end
        end

        local panel = LevelInfoPanel(level.chart, x, y, mark)
        panels[#panels+1]=panel
        y = y + LEVEL_PANEL_SIZE.height + 50
    end

    return panels
end