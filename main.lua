WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

push = require 'push'
Class = require 'class'
require 'Util'
require 'Map'
require 'Menu'
require 'GameOver'

function love.load()

    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    levelFont = love.graphics.newFont('fonts/font.ttf', 16)
    smallFont = love.graphics.newFont('fonts/smallFont.ttf', 8)

    

    love.window.setTitle('Project X: Save Humanity')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        resizable = true,
        vsync = true
    })

    love.keyboard.keysPressed = {}

    hand_cursor = love.mouse.getSystemCursor("hand")
    arrow_cursor = love.mouse.getSystemCursor("arrow")

    gameOver = GameOver()
    gameState = 'menu'
    menu = Menu(gameOver)
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'menu' and menu.menuState == 'menu' then
            gameState = 'play'
            love.mouse.setVisible(false)
            love.audio.stop(menu.music)
            love.audio.stop(gameOver.music)
            map = Map(gameOver)
        elseif gameState == 'gameOver' then
            gameState = 'play'
            love.mouse.setVisible(false)
            love.audio.stop(gameOver.music)
            map = Map(gameOver)
        end
    end

    love.keyboard.keysPressed[key] = true
end

function love.mousepressed(x, y, button)
    if gameState == 'play' then
        map.player:mouseclicked(x, y, button)
    elseif gameState == 'menu' then
        menu:mouseclicked(x, y, button)
    elseif gameState == 'gameOver' then
        gameOver:mouseclicked(x, y, button)
    end
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    if gameState == 'menu' then
        menu:update(dt)
    elseif gameState == 'play' then
        map:update(dt)
    elseif gameState == 'gameOver' then
        gameOver:update(dt)
    end
    
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:apply('start')
    if gameState == 'menu' then
        menu:render()
    elseif gameState == 'play' then
        love.graphics.translate(math.floor(-map.camX), math.floor(-map.camY))
        love.graphics.clear(6 / 255, 6 / 255, 6 / 255, 255 / 255)
        map:render()
        love.graphics.setColor(1, 0, 0)
    elseif gameState == 'gameOver' then
        gameOver:render()
    end
    
    push:apply('end')
end