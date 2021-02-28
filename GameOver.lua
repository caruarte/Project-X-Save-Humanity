require 'Util'
require 'Button'

GameOver = Class{}

STARS_1 = 3
STARS_2 = 4
STARS_3 = 5
EMPTY = 6

function GameOver:init()
    self.spritesheet = love.graphics.newImage('graphics/textures.png')
    self.logo = love.graphics.newImage('graphics/Project-X.png')
    
    self.gameOver = love.graphics.newImage('graphics/Game-Over.png')

    self.music = love.audio.newSource('sounds/sky-loop.wav', 'static')
    self.music:setLooping(true)

    self.sounds = {
        ['click'] = love.audio.newSource('sounds/ui-click.wav', 'static')
    }

    self.menuButton = Button(155, 170, {love.graphics.newImage('graphics/menu.png'), love.graphics.newImage('graphics/menu_hover.png')}, true, 0.4)

    self.tileWidth = 16
    self.tileHeight = 16

    self.level = 0
    self.kills = 0

    self.highestLevel = 0
    self.mostKills = 0

    self.mapWidthPixels = VIRTUAL_WIDTH
    self.mapHeightPixels = VIRTUAL_HEIGHT + 13
    self.mapWidth = self.mapWidthPixels / self.tileWidth
    self.mapHeight = self.mapHeightPixels / self.tileHeight
    self.tiles = {}
    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    local x = 1
    while x <= self.mapWidth do
        for y = 1, self.mapHeight do
            self:setTile(x, y, math.random(3, 6))
        end
        x = x + 1
    end
end

function GameOver:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

function GameOver:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

local textInterval = 1
local textTimer = 0
local textAppear = true

function GameOver:update(dt)
    self.menuButton:update(dt)
    textTimer = textTimer + dt
    if textTimer >= textInterval then
        textTimer = 0
        if textAppear == true then
            textAppear = false
        else
            textAppear = true
        end
    end
    love.mouse.setCursor(arrow_cursor)
    if self.menuButton.hover == true then
        love.mouse.setCursor(hand_cursor)
    end
end

function GameOver:mouseclicked(x, y, button)
    if button == 1 then
        if self.menuButton.hover == true then
            self.menuButton.pressed = true
            self.sounds['click']:play()
            gameState = 'menu'
        end
    end
end

function GameOver:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)], (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end

    self.menuButton:render()
    love.graphics.draw(self.logo, 140, 15, 0, .5)
    love.graphics.draw(self.gameOver, 55, 65, 0, .8)
    
    love.graphics.setFont(smallFont)

    love.graphics.printf('Level: ' .. tostring(self.level), 70, 130, VIRTUAL_WIDTH)
    love.graphics.printf('Kills: ' .. tostring(self.kills), 250, 130, VIRTUAL_WIDTH)

    love.graphics.printf('Highest level: ' .. tostring(self.highestLevel), 70, 150, VIRTUAL_WIDTH)
    love.graphics.printf('Most kills: ' .. tostring(self.mostKills), 250, 150, VIRTUAL_WIDTH)
    
    love.graphics.setFont(levelFont)
    if textAppear == true then
        love.graphics.printf('PRESS ENTER TO RESTART', 0, 210, VIRTUAL_WIDTH, 'center')
    end
    
end