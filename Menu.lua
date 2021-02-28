require 'Util'
require 'Button'

Menu = Class{}

STARS_1 = 3
STARS_2 = 4
STARS_3 = 5
EMPTY = 6

function Menu:init(gameOver)
    self.spritesheet = love.graphics.newImage('graphics/textures.png')
    self.logo = love.graphics.newImage('graphics/Project-X.png')
    self.howToPlay = love.graphics.newImage('graphics/book.png')
    self.mission = love.graphics.newImage('graphics/mission_book.png')
    

    self.gameOver = gameOver

    self.music = love.audio.newSource('sounds/sky-loop.wav', 'static')
    self.music:setLooping(true)
    self.music:play()

    self.sounds = {
        ['click'] = love.audio.newSource('sounds/ui-click.wav', 'static')
    }

    self.buttons = {}
    self.howToPlayButton = Button(65, 160, {love.graphics.newImage('graphics/How-to-Play.png'), love.graphics.newImage('graphics/How-to-Play_hover.png')}, true, 0.4)
    self.missionButton = Button(VIRTUAL_WIDTH - 189, 160, {love.graphics.newImage('graphics/mission_button.png'), love.graphics.newImage('graphics/mission_button_hover.png')}, true, 0.4)
    self.exitButton = Button(10, 10, {love.graphics.newImage('graphics/exit.png'), love.graphics.newImage('graphics/exit_hover.png')}, true, 0.3)
    self.cancelButton = Button(VIRTUAL_WIDTH - 90, 20, {love.graphics.newImage('graphics/cancelButton.png'), love.graphics.newImage('graphics/cancelButtonHover.png')}, true)
    self.buttons[1] = self.howToPlayButton
    self.buttons[2] = self.missionButton
    self.buttons[3] = self.exitButton
    self.buttons[4] = self.cancelButton
    

    self.menuState = 'menu'

    self.tileWidth = 16
    self.tileHeight = 16

    self.highestLevel = self.gameOver.highestLevel
    self.mostKills = self.gameOver.mostKills

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

function Menu:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

function Menu:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

local textInterval = 1
local textTimer = 0
local textAppear = true
local logoY = 30
local logody = 10
local logomaxY = 35
local logominY = 25

function Menu:update(dt)

    logoY = logoY + logody * dt
    if logoY > logomaxY then
        logoY = logomaxY
        logody = -logody
    elseif logoY < logominY then
        logoY = logominY
        logody = -logody
    end
    
    self.highestLevel = self.gameOver.highestLevel
    self.mostKills = self.gameOver.mostKills
    textTimer = textTimer + dt
    if textTimer >= textInterval then
        textTimer = 0
        if textAppear == true then
            textAppear = false
        else
            textAppear = true
        end
    end
    if self.menuState == 'menu' then
        self.howToPlayButton:update(dt)
        self.missionButton:update(dt)
        self.exitButton:update(dt)
        for i = 1 , 3 do
            if self.buttons[i].hover == true then
                love.mouse.setCursor(hand_cursor)
                break
            end
            love.mouse.setCursor(arrow_cursor)
        end
    elseif self.menuState == 'howToPlay' then
        self.cancelButton:update(dt)
        love.mouse.setCursor(arrow_cursor)
        if self.buttons[4].hover == true then
            love.mouse.setCursor(hand_cursor)
        end
    elseif self.menuState == 'mission' then
        self.cancelButton:update(dt)
        love.mouse.setCursor(arrow_cursor)
        if self.buttons[4].hover == true then
            love.mouse.setCursor(hand_cursor)
        end
    end
end

function Menu:mouseclicked(x, y, button)
    if button == 1 then
        if self.menuState == 'menu' then
            if self.howToPlayButton.hover == true then
                self.howToPlayButton.pressed = true
                self.menuState = 'howToPlay'
                self.sounds['click']:play()
            elseif self.missionButton.hover == true then
                self.missionButton.pressed = true
                self.menuState = 'mission'
                self.sounds['click']:play()
            elseif self.exitButton.hover == true then
                self.exitButton.pressed = true
                self.sounds['click']:play()
                love.event.quit()
            end
        elseif self.menuState == 'howToPlay' then
            if self.cancelButton.hover == true then
                self.cancelButton.pressed = true
                self.menuState = 'menu'
                self.sounds['click']:play()
            end
        elseif self.menuState == 'mission' then
            if self.cancelButton.hover == true then
                self.cancelButton.pressed = true
                self.menuState = 'menu'
                self.sounds['click']:play()
            end
        end
    end
end

function Menu:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)], (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end
    if self.menuState == 'menu' then
        love.graphics.draw(self.logo, 65, logoY)
        self.howToPlayButton:render()
        self.missionButton:render()
        self.exitButton:render()
        
        love.graphics.setFont(smallFont)
        love.graphics.printf('Highest level: ' .. tostring(self.highestLevel), 70, 135, VIRTUAL_WIDTH)
        love.graphics.printf('Most kills: ' .. tostring(self.mostKills), 250, 135, VIRTUAL_WIDTH)
        
        love.graphics.setFont(levelFont)
        if textAppear == true then
            love.graphics.printf('PRESS ENTER TO START', 0, 210, VIRTUAL_WIDTH, 'center')
        end
    elseif self.menuState == 'howToPlay' then
        love.graphics.draw(self.howToPlay, 40, -3, 0, .6)
        self.cancelButton:render()
    elseif self.menuState == 'mission' then
        love.graphics.draw(self.mission, 40, -3, 0, .6)
        love.graphics.setFont(smallFont)
        smallFont:setLineHeight(1.5)
        love.graphics.setColor(30 / 255, 30 / 255, 30 / 255, 1)
        love.graphics.printf('Hundreds of aliens have invaded the moon and now threaten to attack the Earth!\nThe NASA along with the U.S. government asked you, Dr. Hart, to launch to the moon and kill as many aliens as you can.', 70, 45, VIRTUAL_WIDTH / 2 - 80)
        love.graphics.printf('After each trip, you will find moon bases where you can rest and get more supplies.\nWith great honor, we wish you the best of luck!', 230, 50, VIRTUAL_WIDTH / 2 - 80)
        love.graphics.setColor(1, 1, 1, 1)
        smallFont:setLineHeight(1.0)
        self.cancelButton:render()
    end
end