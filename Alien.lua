Alien = Class{}
require 'Animation'

local MOVE_SPEED = 40

function Alien:init(map)
    self.width = 16
    self.height = 16

    self.map = map

    self.x = math.random(6, self.map.mapWidth - 5) * self.map.tileWidth
    for y = 1, self.map.mapHeight do
        if self.map:tileAt(self.x, (y - 1) * self.map.tileHeight).id == 1 then
            self.y = (self.map:tileAt(self.x, (y - 1) * self.map.tileHeight).y - 1) * self.map.tileHeight- self.height
            break
        end
    end

    self.sounds = {
        ['kill'] = love.audio.newSource('sounds/kill.wav', 'static')
    }
    self.sounds['kill']:setVolume(0.5)

    
    self.dx = 0
    self.dy = 0
    self.readyToDie = false

    self.texture = love.graphics.newImage('graphics/Alien.png')
    self.frames = generateQuads(self.texture, 16, 16)

    self.state = 'walking'
    
    if math.random(2) == 1 then
        self.direction = 'right'
    else
        self.direction = 'left'
    end

    self.animations = {
        ['walking'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[1], self.frames[2], self.frames[3]
            },
            interval = 0.15,
            loop = true
        },
        ['dying'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[4], self.frames[5], self.frames[6], self.frames[7]
            },
            interval = 0.15,
            loop = false
        }
    }

    self.animation = self.animations['walking']
    self.currentFrame = self.animation:getCurrentFrame()

    self.behaviours = {
        ['walking'] = function(dt)
            if self.direction == 'right' then
                self.dx = MOVE_SPEED
                self.state = 'walking'
                self.direction = 'right'
                self.animation = self.animations['walking']
            else 
                self.dx = -MOVE_SPEED
                self.state = 'walking'
                self.direction = 'left'
                self.animation = self.animations['walking']
            end
            
            self:checkRightCollision()
            self:checkLeftCollision()
            self:checkRightFall()
            self:checkLeftFall()
           
        end,
        ['dying'] = function(dt)
            if self.direction == 'right' then
                self.dx = 0
                self.state = 'dying'
                self.direction = 'right'
                self.animation = self.animations['dying']
            else 
                self.dx = 0
                self.state = 'dying'
                self.direction = 'left'
                self.animation = self.animations['dying']
            end
        end
    }
end

function Alien:update(dt)
    self.behaviours[self.state](dt)
    finished = self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = math.max(0, math.min(self.x + self.dx * dt, self.map.mapWidthPixels - self.width))
    self.y = self.y + self.dy * dt
    if finished == 'finished' then
        self.readyToDie = true
    end
end

function Alien:checkLeftCollision()
    if self.dx < 0 then
        if (self.map:collides(self.map:tileAt(self.x - 8, self.y)) or
        self.map:collides(self.map:tileAt(self.x - 8, self.y + self.height - 1))) and
         (self.map:collides(self.map:tileAt(self.x + self.width + 8, self.y)) or
          self.map:collides(self.map:tileAt(self.x + self.width + 8, self.y + self.height - 1))) then
            self.x = self.map:tileAt(self.x - 8, self.y).x * self.map.tileWidth
            self.direction = 'left'
        elseif self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
        self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
            self.direction = 'right'
        end
        if self.x <= 0 then
            self.x = 0
            self.direction = 'right'
        end
    end
end

function Alien:checkRightCollision()
    if self.dx > 0 then
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
            self.direction = 'left'
        end
        if self.x >= self.map.mapWidthPixels - self.width then
            self.x = self.map.mapWidthPixels - self.width
            self.direction = 'left'
        end
    end
end

function Alien:checkLeftFall()
    if (not self.map:collides(self.map:tileAt(self.x - 8, self.y + self.height))) and (not self.map:collides(self.map:tileAt(self.x + self.width + 8, self.y + self.height))) then
        self.x = self.map:tileAt(self.x - 8, self.y + self.height).x * self.map.tileWidth
        self.direction = 'left'

    elseif (not self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height))) and (self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1))) then
        self.x = self.map:tileAt(self.x - 1, self.y + self.height).x * self.map.tileWidth + 1
        self.direction = 'left'
    elseif not self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height)) then
        self.x = self.map:tileAt(self.x - 1, self.y + self.height).x * self.map.tileWidth + 1
        self.direction = 'right'
    end
end

function Alien:checkRightFall()
    if (not self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height))) and (self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
    self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1))) then
        self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
        self.direction = 'right'
    elseif not self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height)) then
        self.x = (self.map:tileAt(self.x + self.width, self.y + self.height).x - 1) * self.map.tileWidth - self.width
        self.direction = 'left'
    end
end

function Alien:render()
    local scaleX
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end
    if self.readyToDie == false then
        love.graphics.draw(self.texture, self.currentFrame, 
        math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2),
        0, scaleX, 1,
        self.width / 2, self.height / 2)
    end
end