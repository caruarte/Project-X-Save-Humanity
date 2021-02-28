Player = Class{}
require 'Animation'
require 'Bullet'

local GRAVITY = 10
local BULLET_SPEED = 250

local NO_GUN_SPEED = 80
local NO_GUN_JUMP_SPEED = 300

local GUN_SPEED = 50
local GUN_JUMP_SPEED = 200
	

function Player:init(map)
    self.width = 14
    self.height = 16

    self.x = map.tileWidth * 4
    self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height

    self.dx = 0
    self.dy = 0

    self.moveSpeed = NO_GUN_SPEED
    self.jumpSpeed = NO_GUN_JUMP_SPEED

    self.immune = false
    self.deathTimer = 0
    self.deathInterval = 2

    self.sounds = {
        ['laser'] = love.audio.newSource('sounds/laser.wav', 'static'),
        ['pick-heart'] = love.audio.newSource('sounds/pick-heart.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['reload'] = love.audio.newSource('sounds/reload.wav', 'static'),
        ['footsteps'] = love.audio.newSource('sounds/footsteps.wav', 'static'),
        ['use-gun'] = love.audio.newSource('sounds/use-gun.wav', 'static')
    }
    self.sounds['reload']:setVolume(0.1)
    self.sounds['use-gun']:setVolume(0.5)
    self.sounds['footsteps']:setLooping(true)

    self.appear = true
    
    self.bullets = {}
    self.bulletsAmmo = 5
    self.bulletsCurrent = self.bulletsAmmo

    self.startLives = 3
    self.lives = self.startLives

    self.map = map
    self.texture = love.graphics.newImage('graphics/Astronaut.png')
    self.frames = generateQuads(self.texture, 14, 16)

    self.state = 'idle'
    self.direction = 'right'

    self.animations = {
        ['idle'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[1]
            },
            interval = 1,
            loop = true
        },
        ['walking'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[2], self.frames[3], self.frames[4]
            },
            interval = 0.15,
            loop = true
        },
        ['jumping'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[5]
            },
            interval = 1,
            loop = true
        },
        ['gun_idle'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[6]
            },
            interval = 1,
            loop = true
        },
        ['gun_walking'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[6], self.frames[7], self.frames[8]
            },
            interval = 0.15,
            loop = true
        },
        ['gun_jumping'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[9]
            },
            interval = 1,
            loop = true
        }
    }

    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()

    self.behaviours = {
        ['idle'] = function(dt)
            if love.keyboard.wasPressed('space') then
                self.sounds['jump']:play()
                self.sounds['footsteps']:pause()
                self.dy = -self.jumpSpeed
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            elseif love.keyboard.isDown('a') then
                self.sounds['footsteps']:play()
                self.direction = 'left'
                self.dx = -self.moveSpeed
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('d') then
                self.sounds['footsteps']:play()
                self.direction = 'right'
                self.dx = self.moveSpeed
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
            elseif love.keyboard.wasPressed('e') then
                self.sounds['use-gun']:play()
                self.state = 'gun_idle'
                self.moveSpeed = GUN_SPEED
                self.jumpSpeed = GUN_JUMP_SPEED
                self.animation = self.animations['gun_idle']
                self.map.currentGunUI = 2
            else
                self.state = 'idle'
                self.dx = 0
                self.animation = self.animations['idle']
            end
            self:checkRightCollision()
            self:checkLeftCollision()
            self:checkDownCollision()
        end,
        ['walking'] = function(dt)
            if love.keyboard.wasPressed('space') then
                self.sounds['jump']:play()
                self.sounds['footsteps']:pause()
                self.dy = -self.jumpSpeed
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            elseif love.keyboard.wasPressed('e') then
                self.sounds['use-gun']:play()
                self.state = 'gun_walking'
                self.moveSpeed = GUN_SPEED
                self.jumpSpeed = GUN_JUMP_SPEED
                self.animation = self.animations['gun_walking']
                self.map.currentGunUI = 2
            elseif love.keyboard.isDown('a') then
                self.dx = -self.moveSpeed
                self.state = 'walking'
                self.direction = 'left'
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('d') then
                self.dx = self.moveSpeed
                self.state = 'walking'
                self.direction = 'right'
                self.animation = self.animations['walking']
            else
                self.sounds['footsteps']:pause()
                self.state = 'idle'
                self.dx = 0
                self.animation = self.animations['idle']
            end

            self:checkRightCollision()
            self:checkLeftCollision()
            self:checkDownCollision()

            if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
            not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                self.sounds['footsteps']:pause()
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            end

        end,
        ['jumping'] = function(dt)
            if love.keyboard.wasPressed('e') then
                self.sounds['use-gun']:play()
                self.state = 'gun_jumping'
                self.moveSpeed = GUN_SPEED
                self.jumpSpeed = GUN_JUMP_SPEED
                self.animation = self.animations['gun_jumping']
                self.map.currentGunUI = 2
            elseif love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -self.moveSpeed
            elseif love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = self.moveSpeed
            else
                self.dx = 0
            end

            self.dy = self.dy + GRAVITY

            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
            self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
            end
            
            self:checkRightCollision()
            self:checkLeftCollision()
            self:checkDownCollision()
            
        end,
        ['gun_idle'] = function(dt)
            if love.keyboard.wasPressed('space') then
                self.sounds['jump']:play()
                self.sounds['footsteps']:pause()
                self.dy = -self.jumpSpeed
                self.state = 'gun_jumping'
                self.animation = self.animations['gun_jumping']
            elseif love.keyboard.isDown('a') then
                self.sounds['footsteps']:play()
                self.direction = 'left'
                self.dx = -self.moveSpeed
                self.state = 'gun_walking'
                self.animations['gun_walking']:restart()
                self.animation = self.animations['gun_walking']
            elseif love.keyboard.isDown('d') then
                self.sounds['footsteps']:play()
                self.direction = 'right'
                self.dx = self.moveSpeed
                self.state = 'gun_walking'
                self.animations['gun_walking']:restart()
                self.animation = self.animations['gun_walking']
            elseif love.keyboard.wasPressed('e') then
                self.state = 'idle'
                self.moveSpeed = NO_GUN_SPEED
                self.jumpSpeed = NO_GUN_JUMP_SPEED
                self.animation = self.animations['idle']
                self.map.currentGunUI = 1
            else
                self.state = 'gun_idle'
                self.dx = 0
                self.animation = self.animations['gun_idle']
            end
            self:checkRightCollision()
            self:checkLeftCollision()
            self:checkDownCollision()
        end,
        ['gun_walking'] = function(dt)
            if love.keyboard.wasPressed('space') then
                self.sounds['jump']:play()
                self.sounds['footsteps']:pause()
                self.dy = -self.jumpSpeed
                self.state = 'gun_jumping'
                self.animation = self.animations['gun_jumping']
            elseif love.keyboard.wasPressed('e') then
                self.state = 'walking'
                self.moveSpeed = NO_GUN_SPEED
                self.jumpSpeed = NO_GUN_JUMP_SPEED
                self.animation = self.animations['walking']
                self.map.currentGunUI = 1
            elseif love.keyboard.isDown('a') then
                self.dx = -self.moveSpeed
                self.state = 'gun_walking'
                self.direction = 'left'
                self.animation = self.animations['gun_walking']
            elseif love.keyboard.isDown('d') then
                self.dx = self.moveSpeed
                self.state = 'gun_walking'
                self.direction = 'right'
                self.animation = self.animations['gun_walking']
            else
                self.sounds['footsteps']:pause()
                self.state = 'gun_idle'
                self.dx = 0
                self.animation = self.animations['gun_idle']
            end

            self:checkRightCollision()
            self:checkLeftCollision()
            self:checkDownCollision()

            if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
            not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                self.sounds['footsteps']:pause()
                self.state = 'gun_jumping'
                self.animation = self.animations['gun_jumping']
            end

        end,
        ['gun_jumping'] = function(dt)
            if love.keyboard.wasPressed('e') then
                self.state = 'jumping'
                self.moveSpeed = NO_GUN_SPEED
                self.jumpSpeed = NO_GUN_JUMP_SPEED
                self.animation = self.animations['jumping']
                self.map.currentGunUI = 1
            elseif love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -self.moveSpeed
            elseif love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = self.moveSpeed
            else
                self.dx = 0
            end

            self.dy = self.dy + GRAVITY

            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
            self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                self.dy = 0
                self.state = 'gun_idle'
                self.animation = self.animations['gun_idle']
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
            end
            
            self:checkRightCollision()
            self:checkLeftCollision()
            self:checkDownCollision()
            
        end
    }
end

function Player:mouseclicked(x, y, button)
    if self.state == 'gun_idle' or self.state == 'gun_walking' or self.state == 'gun_jumping' then
        if button == 1  and self.bulletsCurrent > 0 then
            self.sounds['laser']:play()
            table.insert(self.bullets, Bullet(self, self.map, 10, 2, {'Alien', 'RedKnight'}))
            self.bulletsCurrent = self.bulletsCurrent - 1
        end
    end
end

local disappearTimer = 0
local disappearInterval = 0.25

function Player:update(dt)
    self.behaviours[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = math.max(0, math.min(self.x + self.dx * dt, self.map.mapWidthPixels - self.width))
    self.y = math.max(0, math.min(self.y + self.dy * dt, self.map.mapHeightPixels - self.height))

    if self.lives <= 0 then
        self.map:gameEnd()
    end
    
    if self.immune == true then
        if self.deathTimer == 0 then
            self.appear = false
        end
        self.deathTimer = self.deathTimer + dt
        disappearTimer = disappearTimer + dt
        
        if self.deathTimer >= self.deathInterval then
            self.immune = false
            self.appear = true
            self.deathTimer = 0
        else
            if disappearTimer >= disappearInterval then
                disappearTimer = 0
                if self.appear == true then
                    self.appear = false
                else
                    self.appear = true
                end
            end
        end
    else
        self.deathTimer = 0
    end

    for i = 1, #self.bullets do
        self.bullets[i]:update(dt)
        if self.bullets[i].delete == true then
            table.remove(self.bullets, i)
            break
        end
    end
end

function Player:checkLeftCollision()
    if self.dx < 0 then
        if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
        self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then

            self.dx = 0
            self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
        end
    end
    if self.immune == false then
        for i = 1, #self.map.aliens do
            if self.map.aliens[i].state ~= 'dying' then
                if self.x < self.map.aliens[i].x + self.map.aliens[i].width and self.x > self.map.aliens[i].x and self.y + self.height > self.map.aliens[i].y and self.y + 1 < self.map.aliens[i].y + self.map.aliens[i].height then
                    self.sounds['hit']:play()
                    self.lives = self.lives - 1
                    self.immune = true
                    break
                end
            end
        end
    end
    for i = 1, self.map.heartCount do
        if self.x <= self.map.hearts[i].x + self.map.hearts[i].width and self.x >= self.map.hearts[i].x and self.y + self.height > self.map.hearts[i].y and self.y < self.map.hearts[i].y + self.map.hearts[i].height then
            self.sounds['pick-heart']:play()
            self.lives = self.lives + 1
            if self.lives > self.startLives then
                self.lives = self.startLives
            end
            self.map.heartCount = self.map.heartCount - 1
            table.remove(self.map.hearts, i)
            break
        end
    end
    for i = 1, self.map.extraBulletCount do
        if self.x <= self.map.extraBullets[i].x + self.map.extraBullets[i].width and self.x >= self.map.extraBullets[i].x and self.y + self.height > self.map.extraBullets[i].y and self.y < self.map.extraBullets[i].y + self.map.extraBullets[i].height then
            self.sounds['reload']:play()
            self.bulletsCurrent = self.bulletsCurrent + 1
            if self.bulletsCurrent > self.bulletsAmmo then
                self.bulletsCurrent = self.bulletsAmmo
            end
            self.map.extraBulletCount = self.map.extraBulletCount - 1
            table.remove(self.map.extraBullets, i)
            break
        end
    end
end

function Player:checkRightCollision()
    if self.dx > 0 then
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            if self.map:tileAt(self.x + self.width, self.y).id == ENTRANCE or self.map:tileAt(self.x + self.width, self.y + self.height - 1).id == ENTRANCE then
                self.x = map.tileWidth * 4
                self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height
                self.bulletsCurrent = self.bulletsAmmo
                self.lives = self.startLives
                self.sounds['footsteps']:pause()
                self.map:start()
                return
            end
            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
        end
    end
    if self.immune == false then
        for i = 1, #self.map.aliens do
            if self.map.aliens[i].state ~= 'dying' then
                if self.x + self.width > self.map.aliens[i].x and self.x + self.width < self.map.aliens[i].x + self.map.aliens[i].width and self.y + self.height > self.map.aliens[i].y and self.y + 1 < self.map.aliens[i].y + self.map.aliens[i].height then
                    self.sounds['hit']:play()
                    self.lives = self.lives - 1
                    self.immune = true
                    break
                end
            end
        end
    end
    for i = 1, self.map.heartCount do
        if self.x + self.width >= self.map.hearts[i].x and self.x + self.width <= self.map.hearts[i].x + self.map.hearts[i].width and self.y + self.height > self.map.hearts[i].y and self.y < self.map.hearts[i].y + self.map.hearts[i].height then
            self.sounds['pick-heart']:play()
            self.lives = self.lives + 1
            if self.lives > self.startLives then
                self.lives = self.startLives
            end
            self.map.heartCount = self.map.heartCount - 1
            table.remove(self.map.hearts, i)
            break
        end
    end
    for i = 1, self.map.extraBulletCount do
        if self.x + self.width >= self.map.extraBullets[i].x and self.x + self.width <= self.map.extraBullets[i].x + self.map.extraBullets[i].width and self.y + self.height > self.map.extraBullets[i].y and self.y < self.map.extraBullets[i].y + self.map.extraBullets[i].height then
            self.sounds['reload']:play()
            self.bulletsCurrent = self.bulletsCurrent + 1
            if self.bulletsCurrent > self.bulletsAmmo then
                self.bulletsCurrent = self.bulletsAmmo
            end
            self.map.extraBulletCount = self.map.extraBulletCount - 1
            table.remove(self.map.extraBullets, i)
            break
        end
    end
end

function Player:checkDownCollision()
    if self.dy < 0 then
        if self.map:collides(self.map:tileAt(self.x, self.y - 1)) or self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y - 1)) then
            self.dy = 0
        end
    end
    if self.immune == false then
        for i = 1, #self.map.aliens do
            if self.map.aliens[i].state ~= 'dying' then
                if self.y + self.height > self.map.aliens[i].y and self.x + self.width > self.map.aliens[i].x and self.x < self.map.aliens[i].x + self.map.aliens[i].width and self.y + self.height < self.map.aliens[i].y + self.map.aliens[i].height then
                    self.sounds['hit']:play()
                    self.lives = self.lives - 1
                    self.immune = true
                    break
                end
            end
        end
    end
    for i = 1, self.map.heartCount do
        if self.y + self.height >= self.map.hearts[i].y and self.x + self.width > self.map.hearts[i].x and self.x < self.map.hearts[i].x + self.map.hearts[i].width then
            self.sounds['pick-heart']:play()
            self.lives = self.lives + 1
            if self.lives > self.startLives then
                self.lives = self.startLives
            end
            self.map.heartCount = self.map.heartCount - 1
            table.remove(self.map.hearts, i)
            break
        end
    end
    for i = 1, self.map.extraBulletCount do
        if self.y + self.height >= self.map.extraBullets[i].y and self.x + self.width > self.map.extraBullets[i].x and self.x < self.map.extraBullets[i].x + self.map.extraBullets[i].width then
            self.sounds['reload']:play()
            self.bulletsCurrent = self.bulletsCurrent + 1
            if self.bulletsCurrent > self.bulletsAmmo then
                self.bulletsCurrent = self.bulletsAmmo
            end
            self.map.extraBulletCount = self.map.extraBulletCount - 1
            table.remove(self.map.extraBullets, i)
            break
        end
    end
end

function Player:render()

    if self.appear == true then
        local scaleX
        if self.direction == 'right' then
            scaleX = 1
        else
            scaleX = -1
        end
        love.graphics.draw(self.texture, self.currentFrame, 
        math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2),
        0, scaleX, 1,
        self.width / 2, self.height / 2)
    end
    
    love.graphics.setColor(1, 0, 0)
    for i = 1, #self.bullets do
        self.bullets[i]:render()
    end
    love.graphics.setColor(1, 1, 1, 1)
end