--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)
]]

-- Libraries
Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife/timer'
require 'lib/gradient'

require 'src/fileUtils'

-- Constants
require 'src/constants'

-- Parser and levels
require 'src/Level'
require 'src/ChartParser'

-- States
require 'src/StateMachine'
require 'src/states/BaseState'
require 'src/states/PlayState'
require 'src/states/LevelCompleteState'
require 'src/states/LevelSelectState'
require 'src/states/GameOverState'
require 'src/states/TitleScreenState'

-- Game classes
require 'src/Note'
require 'src/Judge'

-- Level select screen
require 'src/LevelInfoPanel'

-- Recap screen
require 'src/RecapScreen/FadeInPanel'
require 'src/RecapScreen/JudgementRecap'
require 'src/RecapScreen/MarkDisplay'
require 'src/RecapScreen/ScoresPanel'
require 'src/RecapScreen/GraphPanel'
require 'src/RecapScreen/InfoPanel'

-- Fonts
gFonts = {
    ['judge'] = love.graphics.newFont('fonts/lasercorps.ttf',50),
    ['score'] = love.graphics.newFont('fonts/lasercorps.ttf',70),
    ['mark'] = love.graphics.newFont('fonts/lasercorps.ttf',300),
    ['acc'] = love.graphics.newFont('fonts/nasalization-rg.ttf',30),
    ['combo'] = love.graphics.newFont('fonts/simple.ttf',50),
    ['recapSmall'] = love.graphics.newFont('fonts/nasalization-rg.ttf', 31),
    ['infoSmall'] = love.graphics.newFont('fonts/nasalization-rg.ttf', 20),
    ['infoBig'] = love.graphics.newFont('fonts/nasalization-rg.ttf', 60),
    ['gameOver'] = love.graphics.newFont('fonts/nasalization-rg.ttf', 150)
}

-- Textures
gTextures = {
    ['hitParticle'] = love.graphics.newImage('graphics/hitParticle.png')
}

-- Sounds
gSounds = {
    ['recap'] = love.audio.newSource('sounds/recap.mp3', 'stream'),
    ['gameOver'] = love.audio.newSource('sounds/gameOver.mp3','stream'),
    ['title'] = love.audio.newSource('sounds/title.mp3','stream'),
    ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
    ['cantSelect'] = love.audio.newSource('sounds/cantSelect.wav', 'static'),
    ['selected'] = love.audio.newSource('sounds/selected.wav', 'static')
}