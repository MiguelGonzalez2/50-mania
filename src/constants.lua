--[[
    GD50 Final Project
    50!Mania

    A rythm-based DDR-like game made with LOVE (2D) for
    CS50 Games track.

    Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)
]]

-- Resolution
WINDOW_HEIGHT = 720
WINDOW_WIDTH = 1280
VIRTUAL_HEIGHT = 720
VIRTUAL_WIDTH = 1280

-- Notes
NOTE_WIDTH = 80 -- Pixels
NOTE_HEIGHT = 20 -- Pixels
NOTE_SPEED = 1000 -- Pixels/second

COLUMN_OFFSET = VIRTUAL_WIDTH / 2 - 2*NOTE_WIDTH

-- RGBA colors for each column
NOTE_COLORS = {{0,255,0,255},{0,0,255,255},{0,0,255,255},{0,255,0,255}}
GRADIENT_HEIGHT = 800

-- Judge
JUDGE_LINE_POS = 600 -- Pixels
KEYS = {"D","F","J","K"}
-- Timing windows in seconds (best to worst, can be expanded)
TIMING_WINDOWS = {0.017, 0.044, 0.077, 0.107, 0.131, 0.168}
-- Scores for each window
JUDGE_SCORES = {320, 300, 200, 100, 50, 0}
MAX_SCORE = 1000000
SCORE_UPDATE_TIME = 0.05
COMBO_UPDATE_ATTACK_TIME = 0.15
COMBO_UPDATE_RELEASE_TIME = 0.05
-- HP
MAX_HP = 100
HEALTH_BAR_HEIGHT = 300
HEALTH_BAR_WIDTH = 20
HP_UPDATE_TIME = 0.5
LOW_HP_THRESHOLD = 50 -- Used to display LOW HP indicator
-- How much does HP get modified upon hitting each window
HP_VALUES = {3,2,-1,-2,-7,-10}
-- Weights for accuracy computation
ACC_WEIGHTS = {300, 300, 200, 100, 50, 0}
-- Texts
JUDGE_TEXTS = {'PERFECT!', 'EXCELLENT', 'GREAT', 'GOOD', 'BAD', 'MISS'}
JUDGE_TEXT_APPEAR_TIME = 0.1 -- Seconds it takes for the judgement to tween in
JUDGE_TEXT_HOLD_TIME = 1 -- Max seconds the text is held before fading away
-- Colors (RGBA)
JUDGE_COLORS = {{232,14,228,255},{235,200,21,255},{47,70,222,255},{61,196,51,255},{156,156,156,255},{237,28,17,255}}
-- Particles
HIT_PARTICLE_DURATION = 30 -- Frames
PARTICLE_COLOR = {20,210,210,150,20,210,210,50} -- RGBA (2 points for gradient)
-- Long notes give combo while held each X seconds
LONG_NOTE_COMBO_DELAY = 0.15

-- Displaying judgement
COMBO_TEXT_POS = 300
JUDGE_TEXT_POS = 400

-- Displaying remaining song time
CLOCK_POS = {x = 20, y = 20}
CLOCK_RADIUS = 40

-- Level complete
MARKS = {"X", "S", "A", "B", "C", "D"}
MARKS_THRESHOLDS = {100, 95, 90, 80, 70} -- Thresholds required to receive a mark. Last mark given if no threshold is met
MARKS_COLORS = {{232,14,228,255},{235,200,21,255},{47,70,222,255},{61,196,51,255},{156,156,156,255},{237,28,17,255}}
MARK_PANEL_POS = {x=3*VIRTUAL_WIDTH/4+50,y=20}
RECAP_INFO_PANEL_POS = {x = MARK_PANEL_POS.x, y = VIRTUAL_HEIGHT-92}
INFO_PANEL_PADDING = 7
RECAP_SCREEN_SPACING = 50 --Space between entries (judgements) at the recap screen panel
JUDGE_PANEL_POS = {x=20,y=20} -- Position for the judge panel
RECAP_PANEL_FADE_TIME = 2 -- Seconds for the judgements panel to display fully
RECAP_FADE_SEPARATION = 1 -- Seconds in between fadeins
SCORES_PANEL_POS = {x=20, y=VIRTUAL_HEIGHT/2}
SCORES_PANEL_PADDING = 30 -- Distance between elements in the scores panel
GRAPH_PANEL_POS = {x=20, y=VIRTUAL_HEIGHT/2+100}
GRAPH_PANEL_SAMPLES = 100 -- How many samples are taken to draw the graph
GRAPH_DELAY = 4 -- Time it takes to draw the graph
GRAPH_RADIUS = 5 -- Radius of each sample

-- Filesystem
LEVEL_DIRECTORY = "levels"
SAVE_FILE_NAME = "highscores.dat"

-- Level select
LEVEL_PANEL_SIZE = {width = 800, height = 120}
LEVEL_SELECT_PANEL_POS = {x=VIRTUAL_WIDTH - LEVEL_PANEL_SIZE.width+50,y=VIRTUAL_HEIGHT/3}
HIGHSCORE_PANEL_POS = {x=40,y=LEVEL_SELECT_PANEL_POS.y-100}
LEVEL_START_FADE_TIME = 0.4

-- Game Over
GAME_OVER_SONG_DECAY = 2.5 -- Time it takes for the song to decay on game over

-- Pause
PAUSE_TRANSITION_TIME = 0.2 -- Time it takes for the pause menu to show up.

-- Scroll speed tweaking
MAX_SCROLL_SPEED = 2000
MIN_SCROLL_SPEED = 300
CHANGE_SCROLL_SPEED = 100