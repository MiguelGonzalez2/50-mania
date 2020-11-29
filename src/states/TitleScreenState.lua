--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    State which shows the title screen.
]]

TitleScreenState = Class {__includes = BaseState}

function TitleScreenState:enter() 

    -- Particle system for visuals
    self.psystem = love.graphics.newParticleSystem(gTextures['hitParticle'], 3000)
    self.psystem:setParticleLifetime(3)
    self.psystem:setEmissionRate(500)
    self.psystem:setLinearAcceleration(-60,-60,60,60)
    self.psystem:setSizes(3,2)
    self.psystem:setAreaSpread('uniform', VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    local colors = {}
    for i=1,32 do
        table.insert(colors, math.random(i%4==0 and 200 or 1,255))
    end
    self.psystem:setColors(unpack(colors))
    self.psystem:emit(500)

    -- Alpha for fades
    self.fadeIn = 0

    -- Text bouncing to the beat
    self.textScale = 1.1
    self.bounceTimer = 16*(60/138) -- When next bounce should occur, init at first beat of the song.
    self.bouncing = false

    -- Start bouncing on beat
    gSounds['title']:setLooping(1)
    gSounds['title']:play()
    gSounds['title']:seek(16*(60/138))

    self.titleColors = {}
    for i=1,9 do
        table.insert(self.titleColors, math.random(i%4==0 and 255 or 1,255))
    end

    self.notes = {} -- Random notes for fun
    self.notePointer = 1
    self.noteTimer = Timer.every(60/138/1.5, function()
       self.notes[self.notePointer] = Note(math.random(1,2), gSounds['title']:tell()+VIRTUAL_HEIGHT/NOTE_SPEED, nil)
       self.notes[self.notePointer].x = math.random(0,VIRTUAL_WIDTH-NOTE_WIDTH)
       self.notePointer = (self.notePointer + 1) % 10
    end)

    self.backgroundColor = {r=math.random(1,50),g=math.random(1,50),b=math.random(1,50)} --Random background color

end

function TitleScreenState:update(dt)
    self.psystem:update(dt)

    -- Bounce if needed.
    if gSounds['title']:tell() > self.bounceTimer then
        -- Update bounce timer to reflect next bounce, adding 1 beats since BPM is 72
        self.bounceTimer = self.bounceTimer + 60/138
        self.bouncing = true -- Set bouncing
        Timer.tween(0.1, {[self] = {textScale = 1.18}}):finish(function()self.bouncing=false end)
        Timer.tween(0.2, {[self.backgroundColor] = {r=math.random(1,50),g=math.random(1,50),b=math.random(1,50)}})
    end

    -- Restart if song loops
    if gSounds['title']:tell() < self.bounceTimer - 60/138 then
        self.bounceTimer = 0
    end

    if not self.bouncing then
        self.textScale = self.textScale - 0.4*dt
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['selected']:play()
        Timer.tween(LEVEL_START_FADE_TIME, {[self] = {fadeIn = 255}}):finish(function()gStateMachine:change('levelSelect')end)
    elseif love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    for _,note in pairs(self.notes) do
        note:update(gSounds['title']:tell())
    end

end

function TitleScreenState:render()

    -- background
    love.graphics.clear(self.backgroundColor.r,self.backgroundColor.g,self.backgroundColor.b)

    -- notes
    for _,note in pairs(self.notes) do
        note:render()
    end

    love.graphics.setColor(255,255,255,255)

    -- Particles
    love.graphics.draw(self.psystem)    

    -- title text. Each of the texts is painted sepearately since it has a separate color, and has a shadow beneath.
    local BASE = VIRTUAL_WIDTH/2 - 300
    local fifty = love.graphics.newText(gFonts['gameOver'], "50")
    love.graphics.setColor(200,200,200,255-self.fadeIn)
    love.graphics.draw(fifty, BASE, 150+5,0,self.textScale,self.textScale,fifty:getWidth()/2, fifty:getHeight()/2)
    love.graphics.setColor(self.titleColors[1],self.titleColors[2],self.titleColors[3],255-self.fadeIn)
    love.graphics.draw(fifty, BASE, 150,0,self.textScale,self.textScale,fifty:getWidth()/2, fifty:getHeight()/2)
    local excl = love.graphics.newText(gFonts['gameOver'], "!")
    love.graphics.setColor(200,200,200,255-self.fadeIn)
    love.graphics.draw(excl, BASE+5+fifty:getWidth()-90, 150+5,0,self.textScale,self.textScale,excl:getWidth()/2, excl:getHeight()/2)
    love.graphics.setColor(self.titleColors[4],self.titleColors[5],self.titleColors[6],255-self.fadeIn)
    love.graphics.draw(excl, BASE+fifty:getWidth()-90, 150,0,self.textScale,self.textScale,excl:getWidth()/2, excl:getHeight()/2)
    local mania = love.graphics.newText(gFonts['gameOver'], "Mania")
    love.graphics.setColor(200,200,200,255-self.fadeIn)
    love.graphics.draw(mania, BASE+5+fifty:getWidth()+excl:getWidth()-90, 150+5,0,self.textScale,self.textScale,excl:getWidth()/2, excl:getHeight()/2)
    love.graphics.setColor(self.titleColors[7],self.titleColors[8],self.titleColors[9],255-self.fadeIn)
    love.graphics.draw(mania, BASE+fifty:getWidth()+excl:getWidth()-90, 150,0,self.textScale,self.textScale,excl:getWidth()/2, excl:getHeight()/2)

    -- Instructions
    local enter = love.graphics.newText(gFonts['infoBig'], "ENTER: Start Playing")
    love.graphics.setColor(200,200,200,255-self.fadeIn)
    love.graphics.draw(enter, VIRTUAL_WIDTH/2+2, 150+2+fifty:getHeight()+50,0,self.textScale,self.textScale,enter:getWidth()/2, enter:getHeight()/2)
    love.graphics.setColor(0,0,180,255-self.fadeIn)
    love.graphics.draw(enter, VIRTUAL_WIDTH/2, 150+fifty:getHeight()+50,0,self.textScale,self.textScale,enter:getWidth()/2, enter:getHeight()/2)

    local esc = love.graphics.newText(gFonts['infoBig'], "ESC: Quit")
    love.graphics.setColor(200,200,200,255-self.fadeIn)
    love.graphics.draw(esc, VIRTUAL_WIDTH/2+2, 150+2+fifty:getHeight()+enter:getHeight()+50+50,0,self.textScale,self.textScale,esc:getWidth()/2, esc:getHeight()/2)
    love.graphics.setColor(0,180,0,255-self.fadeIn)
    love.graphics.draw(esc, VIRTUAL_WIDTH/2, 150+fifty:getHeight()+enter:getHeight()+50+50,0,self.textScale,self.textScale,esc:getWidth()/2, esc:getHeight()/2)

    -- FADE IN
    if self.fadeIn then
        love.graphics.setColor(255, 255, 255, self.fadeIn)
        love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    end
end

function TitleScreenState:exit()
    self.noteTimer:remove()
    gSounds['title']:stop()
end