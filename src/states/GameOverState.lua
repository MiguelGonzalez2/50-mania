--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)

    State that shows when a player loses all their hp.
]]

GameOverState = Class {__includes = BaseState}

function GameOverState:enter(level) 
    self.level = level

    -- Schedule the fade
    self.fadeIn = 255
    Timer.tween(GAME_OVER_SONG_DECAY, {[self] = {fadeIn = 0}})

    -- Particle system for visuals
    self.psystem = love.graphics.newParticleSystem(gTextures['hitParticle'], 1000)
    self.psystem:setParticleLifetime(3)
    self.psystem:setEmissionRate(300)
    self.psystem:setLinearAcceleration(-10,-10,10,10)
    self.psystem:setSizes(2,1)
    self.psystem:setAreaSpread('uniform', VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    self.psystem:setColors(255,255,255,255)

    -- Text bouncing to the beat
    self.textScale = 1.1
    self.bounceTimer = 2.5 -- When next bounce should occur, init at first beat of the song.
    self.bouncing = false

    -- Start bouncing on beat
    gSounds['gameOver']:setLooping(1)
    gSounds['gameOver']:play()

    -- Reset level
    self.level:reset()
end

function GameOverState:update(dt)
    self.psystem:update(dt)

    -- Bounce if needed.
    if gSounds['gameOver']:tell() > self.bounceTimer then
        -- Update bounce timer to reflect next bounce, adding 4 beats since BPM is 72
        self.bounceTimer = self.bounceTimer + 60/72*4
        self.bouncing = true -- Set bouncing
        Timer.tween(0.1, {[self] = {textScale = 1.15}}):finish(function()self.bouncing=false end)
    end

    -- Restart if song loops
    if gSounds['gameOver']:tell() < self.bounceTimer - 60/72*4 then
        self.bounceTimer = 2.5
    end

    if not self.bouncing then
        self.textScale = self.textScale - 0.07*dt
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['selected']:play()
        Timer.tween(LEVEL_START_FADE_TIME, {[self] = {fadeIn = 255}}):finish(function()gStateMachine:change('play', self.level)end)
    elseif love.keyboard.wasPressed('escape') then
        gSounds['select']:play()
        Timer.tween(LEVEL_START_FADE_TIME, {[self] = {fadeIn = 255}}):finish(function()gStateMachine:change('levelSelect')end)
    end

end

function GameOverState:render()

    -- background
    if self.level.background then
        local bg = self.level.background
        love.graphics.setColor(255,255,255,math.min(255-self.fadeIn,130))
        love.graphics.draw(bg,0,0,0,VIRTUAL_WIDTH/bg:getWidth(), VIRTUAL_HEIGHT/bg:getHeight())
    end

    -- Particles
    love.graphics.draw(self.psystem)    

    -- Game over text
    local gameOver = love.graphics.newText(gFonts['gameOver'], "GAME OVER")
    love.graphics.setColor(200,200,200,255-self.fadeIn)
    love.graphics.draw(gameOver, VIRTUAL_WIDTH/2+5, 150+5,0,self.textScale,self.textScale,gameOver:getWidth()/2, gameOver:getHeight()/2)
    love.graphics.setColor(180,0,0,255-self.fadeIn)
    love.graphics.draw(gameOver, VIRTUAL_WIDTH/2, 150,0,self.textScale,self.textScale,gameOver:getWidth()/2, gameOver:getHeight()/2)

    -- Instructions
    local enter = love.graphics.newText(gFonts['infoBig'], "ENTER: Replay Level")
    love.graphics.setColor(200,200,200,255-self.fadeIn)
    love.graphics.draw(enter, VIRTUAL_WIDTH/2+2, 150+2+gameOver:getHeight()+50,0,self.textScale,self.textScale,enter:getWidth()/2, enter:getHeight()/2)
    love.graphics.setColor(0,0,180,255-self.fadeIn)
    love.graphics.draw(enter, VIRTUAL_WIDTH/2, 150+gameOver:getHeight()+50,0,self.textScale,self.textScale,enter:getWidth()/2, enter:getHeight()/2)

    local esc = love.graphics.newText(gFonts['infoBig'], "ESC: Level Select")
    love.graphics.setColor(200,200,200,255-self.fadeIn)
    love.graphics.draw(esc, VIRTUAL_WIDTH/2+2, 150+2+gameOver:getHeight()+enter:getHeight()+50+50,0,self.textScale,self.textScale,esc:getWidth()/2, esc:getHeight()/2)
    love.graphics.setColor(0,180,0,255-self.fadeIn)
    love.graphics.draw(esc, VIRTUAL_WIDTH/2, 150+gameOver:getHeight()+enter:getHeight()+50+50,0,self.textScale,self.textScale,esc:getWidth()/2, esc:getHeight()/2)

    -- FADE IN
    if self.fadeIn then
        love.graphics.setColor(255, 255, 255, self.fadeIn)
        love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    end
end

function GameOverState:exit()
    gSounds['gameOver']:stop()
end 