--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)
]]

require 'src/dependencies'

function love.load()
    
    --love.profiler = require("profile")
    --love.profiler.start()

    -- Garbage collect more often, otherwise notable performance spikes occur due
    -- to lot of timers/tweens beeing dereferenced through the play state, and freed all at once
    collectgarbage("setpause",100) 

    -- Random seed
    math.randomseed(os.time())

    -- Title
    love.window.setTitle('50!Mania')

    -- love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Setup virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- State initialization
    gStateMachine = StateMachine {
        ['play'] = function() return PlayState() end,
        ['recap'] = function() return LevelCompleteState() end,
        ['levelSelect'] = function() return LevelSelectState() end,
        ['gameOver'] = function() return GameOverState() end,
        ['titleScreen'] = function() return TitleScreenState() end
    }
    gStateMachine:change('titleScreen')

    -- Keyboard tracker
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

-- Push resizing
function love.resize(w, h)
    push:resize(w, h)
end

-- Keyboard buffer updates
function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end
function love.keyboard.wasReleased(key)
    return love.keyboard.keysReleased[key]
end

-- Update game
--love.frame = 0
function love.update(dt)

    --love.frame = love.frame + 1

    Timer.update(dt)
    gStateMachine:update(dt)
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}

    --if love.frame%100 == 0 then
    --   love.report = love.profiler.report(20)
    --    love.profiler.reset()
    --end
end

-- Render game
function love.draw()
    push:start()
    gStateMachine:render()
    --love.graphics.setColor(255,0,0,255)
    --love.graphics.print(love.report or "Please wait...")
    --love.graphics.print(tonumber(collectgarbage("count")))
    push:finish()
end