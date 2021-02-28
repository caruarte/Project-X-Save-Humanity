require 'Util'
require 'Player'
require 'Alien'
require 'RedKnight'
require 'HeartIcon'
require 'BulletIcon'
require 'GameOver'

Map = Class{}

MOON_TOP = 1
MOON_BOTTOM = 2
STARS_1 = 3
STARS_2 = 4
STARS_3 = 5
EMPTY = 6
EARTH = 7
MARS = 8
SHIP_TOP_LEFT = 9
SHIP_TOP_RIGHT = 10
SHIP_BOTTOM_LEFT = 11
SHIP_BOTTOM_RIGHT = 12
ENTRANCE = 34
MERCURY = 37
VENUS = 38
JUPITER = 39
SATURN = 40
URANUS = 41
NEPTUNE = 42

function Map:init(gameOver)
    self.spritesheet = love.graphics.newImage('graphics/textures.png')
    
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.tiles = {}
    self.planets = {MERCURY, VENUS, EARTH, MARS, JUPITER, SATURN, URANUS, NEPTUNE}

    self.music = love.audio.newSource('sounds/video-game-land.wav', 'static')
    
    
    self.alienStartCount = 5
    self.redKnightStartCount = 5
    self.redKnightAppearanceLevel = 10
    self.heartStartCount = 1
    self.extraBulletStartCount = 1

    self.gameOver = gameOver

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    self.camX = 0
    self.camY = 0

    self.livesUI = love.graphics.newImage('graphics/heart.png')
    self.livesUISprites = generateQuads(self.livesUI, 16, 16)

    self.gunUI = love.graphics.newImage('graphics/Gun_UI.png')
    self.gunUISprites = generateQuads(self.gunUI, 32, 32)
    self.currentGunUI = 1

    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    self.level = 0

    self.kills = 0

    self:start(self.mapWidth)

    self.music:setLooping(true)
    self.music:play()

end

function Map:start(mapW)
    
    if mapW then
        self.mapWidth = mapW
        self.level = 1
        self.mapWidthPixels = self.mapWidth * self.tileWidth
        self.alienCount = self.alienStartCount
        self.heartCount = self.heartStartCount
        self.extraBulletCount = self.extraBulletStartCount
        
    else
        self.level = self.level + 1
        self.mapWidth = self.mapWidth + 5
        self.mapWidthPixels = self.mapWidth * self.tileWidth

        self.alienCount = self.alienStartCount + 1
        self.alienStartCount = self.alienCount
        
        if self.level == self.redKnightAppearanceLevel then
            self.redKnightCount = self.redKnightStartCount
        elseif self.level > self.redKnightAppearanceLevel then
            self.redKnightCount = self.redKnightStartCount + 1
            self.redKnightStartCount = self.redKnightCount
        end
        if self.level % 5 == 0 then
            self.heartCount = self.heartStartCount + 1
            self.heartStartCount = self.heartCount
            self.extraBulletCount = self.extraBulletStartCount + 1
            self.extraBulletStartCount = self.extraBulletCount
        else
            self.heartCount = self.heartStartCount
            self.extraBulletCount = self.extraBulletStartCount
        end
    end

    local x = 1
    local mercuryDrawn = false
    local venusDrawn = false
    local earthDrawn = false
    local marsDrawn = false
    local jupiterDrawn = false
    local saturnDrawn = false
    local uranusDrawn = false
    local neptuneDrawn = false

    local startMapY = self.mapHeight / 2
    local relativeY = 0
    local MapY = startMapY - relativeY
    local deltaMapY = 0

    while x <= self.mapWidth do

        for y = 1, MapY - 1 do
            self:setTile(x, y, math.random(3, 6))
        end
        
        if x >= 4 then
            if math.random(20) == 1 and mercuryDrawn == false then
                self:setTile(x, math.random(3, MapY - 3), MERCURY)
                mercuryDrawn = true
            elseif math.random(20) == 1 and venusDrawn == false and self.level >= 5 then
                self:setTile(x, math.random(3, MapY - 3), VENUS)
                venusDrawn = true
            elseif math.random(20) == 1 and earthDrawn == false and self.level >= 10 then
                self:setTile(x, math.random(3, MapY - 3), EARTH)
                earthDrawn = true
            elseif math.random(20) == 1 and marsDrawn == false and self.level >= 15 then
                self:setTile(x, math.random(3, MapY - 3), MARS)
                marsDrawn = true
            elseif math.random(20) == 1 and jupiterDrawn == false and self.level >= 20 then
                self:setTile(x, math.random(3, MapY - 3), JUPITER)
                jupiterDrawn = true
            elseif math.random(20) == 1 and saturnDrawn == false and self.level >= 25 then
                self:setTile(x, math.random(3, MapY - 3), SATURN)
                saturnDrawn = true
            elseif math.random(20) == 1 and uranusDrawn == false and self.level >= 30 then
                self:setTile(x, math.random(3, MapY - 3), URANUS)
                uranusDrawn = true
            elseif math.random(20) == 1 and neptuneDrawn == false and self.level >= 35 then
                self:setTile(x, math.random(3, MapY - 3), NEPTUNE)
                neptuneDrawn = true
            end
        end
        if mapW then
            if x == 2 then
                self:setTile(x, MapY - 2, SHIP_TOP_LEFT)
                self:setTile(x, MapY - 1, SHIP_BOTTOM_LEFT)
            elseif x == 3 then
                self:setTile(x, MapY - 2, SHIP_TOP_RIGHT)
                self:setTile(x, MapY - 1, SHIP_BOTTOM_RIGHT)
            end
        else
            if x == 1 then
                self:setTile(x, MapY - 8, 43)
                self:setTile(x, MapY - 7, 44)
                self:setTile(x, MapY - 6, 46)
                self:setTile(x, MapY - 5, 48)
                self:setTile(x, MapY - 4, 50)
                self:setTile(x, MapY - 3, 52)
                self:setTile(x, MapY - 2, 54)
                self:setTile(x, MapY - 1, 57)
            elseif x == 2 then
                self:setTile(x, MapY - 7, 45)
                self:setTile(x, MapY - 6, 47)
                self:setTile(x, MapY - 5, 49)
                self:setTile(x, MapY - 4, 51)
                self:setTile(x, MapY - 3, 53)
                self:setTile(x, MapY - 2, 55)
                self:setTile(x, MapY - 1, 58)
            elseif x == 3 then
                self:setTile(x, MapY - 2, 56)
                self:setTile(x, MapY - 1, 59)
            end
        end
       
        if x > 6 and x < self.mapWidth - 2 then
            if MapY > 8 and MapY < self.mapHeight - 2 then
                if deltaMapY == 0 then
                    if math.random(5) == 1 then
                        deltaMapY = 1
                    elseif math.random(5) == 2 then 
                        deltaMapY = -1
                        self:setTile(x, MapY, math.random(3, 6))
                    else
                        deltaMapY = 0
                    end
                elseif deltaMapY == 1 then
                    if math.random(5) == 1 then
                        deltaMapY = 0
                    elseif math.random(10) == 2 then 
                        deltaMapY = -1
                        self:setTile(x, MapY, math.random(3, 6))
                    else
                        deltaMapY = 1
                    end
                else
                    if math.random(5) == 1 then
                        deltaMapY = 0
                    elseif math.random(10) == 2 then 
                        deltaMapY = 1
                    else
                        deltaMapY = -1
                        self:setTile(x, MapY, math.random(3, 6))
                    end
                end
            elseif MapY <= 8 then
                if math.random(10) == 1 then 
                    deltaMapY = -1
                    self:setTile(x, MapY, math.random(3, 6))
                else
                    deltaMapY = 0
                end
            else
                if math.random(10) == 1 then 
                    deltaMapY = 1
                else
                    deltaMapY = 0
                end
            end
            relativeY = relativeY + deltaMapY
            MapY = startMapY - relativeY
        elseif x == self.mapWidth - 2 then
            self:setTile(x, MapY - 2, 31)
            self:setTile(x, MapY - 1, ENTRANCE)
        elseif x == self.mapWidth - 1 then
            self:setTile(x, MapY - 7, 17)
            self:setTile(x, MapY - 6, 20)
            self:setTile(x, MapY - 5, 23)
            self:setTile(x, MapY - 4, 26)
            self:setTile(x, MapY - 3, 29)
            self:setTile(x, MapY - 2, 32)
            self:setTile(x, MapY - 1, 35)
        elseif x == self.mapWidth then
            self:setTile(x, MapY - 8, 15)
            self:setTile(x, MapY - 7, 18)
            self:setTile(x, MapY - 6, 21)
            self:setTile(x, MapY - 5, 24)
            self:setTile(x, MapY - 4, 27)
            self:setTile(x, MapY - 3, 30)
            self:setTile(x, MapY - 2, 33)
            self:setTile(x, MapY - 1, 36)
        end
        
        self:setTile(x, MapY, MOON_TOP)
        for y = MapY + 1, self.mapHeight do
            self:setTile(x, y, MOON_BOTTOM)
        end
        x = x + 1
    end

    
    self.aliens = {}
    for i = 1, self.alienCount do
        self.aliens[i] = Alien(self)
    end

    if self.level >= self.redKnightAppearanceLevel then
        self.redKnights = {}
        for i = 1, self.redKnightCount do
            self.redKnights[i] = RedKnight(self)
        end
    end
    

    
    self.hearts = {}
    for i = 1, self.heartCount do
        self.hearts[i] = HeartIcon(self)
    end

    
    self.extraBullets = {}
    for i = 1, self.extraBulletCount do
        self.extraBullets[i] = BulletIcon(self)
    end

    self.player = Player(self)
end

function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:collides(tile) -- tile number in the spritesheet
    local collidables = {
        MOON_TOP, MOON_BOTTOM, SHIP_TOP_LEFT, SHIP_TOP_RIGHT, SHIP_BOTTOM_LEFT, SHIP_BOTTOM_RIGHT, 15, 17, 18, 20, 21, 23, 24, 26, 27, 29, 30, 31, 32, 33, 34, 35, 36, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59
    }

    for _, v in ipairs(collidables) do
        if tile.id == v then 
            return true
        end
    end

    return false
end

function Map:gameEnd()
    gameState = 'gameOver'
    love.audio.stop(self.music)
    love.audio.stop(self.player.sounds['footsteps'])
    self.gameOver.music:play()
    love.mouse.setVisible(true)
    self.gameOver.level = self.level
    self.gameOver.kills = self.kills
    if self.level > self.gameOver.highestLevel then
        self.gameOver.highestLevel = self.level
    end
    if self.kills > self.gameOver.mostKills then
        self.gameOver.mostKills = self.kills
    end
end

function Map:update(dt)
    
    self.player:update(dt)
    for i = 1, self.alienCount do
        if self.aliens[i] ~= nil then
            self.aliens[i]:update(dt)
        end
    end
    if self.level >= self.redKnightAppearanceLevel then
        for i = 1, self.redKnightCount do
            if self.redKnights[i] ~= nil then
                self.redKnights[i]:update(dt)
            end
        end
    end
    for i = 1, self.heartCount do
        if self.hearts[i] ~= nil then
            self.hearts[i]:update(dt)
        end
    end
    for i = 1, self.extraBulletCount do
        if self.extraBullets[i] ~= nil then
            self.extraBullets[i]:update(dt)
        end
    end
    for i = 1, #self.aliens do
        if self.aliens[i].state == 'dying' then
            if self.aliens[i].readyToDie == true then
                table.remove(self.aliens, i)
                self.alienCount = self.alienCount - 1
                return
            end
        end
    end
    if self.level >= self.redKnightAppearanceLevel then
        for i = 1, #self.redKnights do
            if self.redKnights[i].state == 'dying_frontHit' or self.redKnights[i].state == 'dying_backHit' then
                if self.redKnights[i].readyToDie == true then
                    table.remove(self.redKnights, i)
                    self.redKnightCount = self.redKnightCount - 1
                    return
                end
            end
        end
    end
    
    self.camX = math.max(0, math.min(self.player.x - VIRTUAL_WIDTH / 2 + self.player.width / 2, self.mapWidthPixels - VIRTUAL_WIDTH))
    self.camY = math.max(0, math.min(math.floor(self.player.y) - VIRTUAL_HEIGHT / 2 + self.player.height / 2, self.mapHeightPixels - VIRTUAL_HEIGHT))
    
end

function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)], (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end

    self.player:render()

    for i = 1, self.alienCount do
        self.aliens[i]:render()
    end

    if self.level >= self.redKnightAppearanceLevel then
        for i = 1, self.redKnightCount do
            self.redKnights[i]:render()
        end
    end

    for i = 1, self.heartCount do
        self.hearts[i]:render()
    end

    for i = 1, self.extraBulletCount do
        self.extraBullets[i]:render()
    end

    love.graphics.setFont(levelFont)
    love.graphics.printf('LEVEL ' .. tostring(self.level), math.floor(self.camX + 10), math.floor(self.camY + 10), VIRTUAL_WIDTH)
    
    love.graphics.draw(self.gunUI, self.gunUISprites[self.currentGunUI], math.floor(self.camX + VIRTUAL_WIDTH - 42), math.floor(self.camY + 10))
    local livesWidth = 8
    for i = 1, self.player.lives do
        love.graphics.draw(self.livesUI, self.livesUISprites[1], math.floor(self.camX + livesWidth), math.floor(self.camY + 25))
        livesWidth = livesWidth + 15
    end
    for i = 1, self.player.startLives - self.player.lives do
        love.graphics.draw(self.livesUI, self.livesUISprites[5], math.floor(self.camX + livesWidth), math.floor(self.camY + 25))
        livesWidth = livesWidth + 15
    end
    love.graphics.printf(tostring(self.player.bulletsCurrent) .. "/" .. tostring(self.player.bulletsAmmo), math.floor(self.camX + VIRTUAL_WIDTH - 80), math.floor(self.camY + 20), VIRTUAL_WIDTH)

    love.graphics.setFont(smallFont)
    love.graphics.printf('Kills: ' .. tostring(self.kills), math.floor(self.camX), math.floor(self.camY + 10), VIRTUAL_WIDTH, 'center')
end