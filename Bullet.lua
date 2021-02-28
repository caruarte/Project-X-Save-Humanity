Bullet = Class{}
local BULLET_SPEED = 250

function Bullet:init(object, map, width, height, hittable)
    self.object = object
    self.map = map
    self.dx = 0
    self.hittable = hittable
    self.width = width
    self.height = height
    self.delete = false
    self.y = self.object.y + self.object.height / 2

    if self.object.direction == 'right' then
        self.x = self.object.x + self.object.width / 2
        self.dx = BULLET_SPEED
    else
        self.x = self.object.x + self.object.width / 2 - self.width
        self.dx = -BULLET_SPEED
    end
end

function Bullet:update(dt)
    self.x = self.x + self.dx * dt
    if self.dx > 0 then
        if self.x >= self.map.mapWidthPixels or self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            self.delete = true
        end
        for i = 1, #self.hittable do
            if self.hittable[i] == 'Alien' then
                for a = 1, #self.map.aliens do
                    if math.floor(self.x + self.width) >= math.floor(self.map.aliens[a].x) and math.floor(self.x + self.width) <= math.floor(self.map.aliens[a].x + self.map.aliens[a].width) and self.y + self.height > self.map.aliens[a].y and self.y < self.map.aliens[a].y + self.map.aliens[a].height then
                        self.delete = true
                        if self.map.aliens[a].state ~= 'dying' then
                            self.map.aliens[a].sounds['kill']:play()
                            self.map.kills = self.map.kills + 1
                        end
                        self.map.aliens[a].state = 'dying'
                    end
                end
            elseif self.hittable[i] == 'RedKnight' then
                if self.map.level >= self.map.redKnightAppearanceLevel then
                    for a = 1, #self.map.redKnights do
                        if math.floor(self.x + self.width) >= math.floor(self.map.redKnights[a].x) and math.floor(self.x + self.width) <= math.floor(self.map.redKnights[a].x + self.map.redKnights[a].width) and self.y + self.height > self.map.redKnights[a].y and self.y < self.map.redKnights[a].y + self.map.redKnights[a].height then
                            self.delete = true
                            if self.map.redKnights[a].state ~= 'dying_frontHit' and self.map.redKnights[a].state ~= 'dying_backHit' then
                                self.map.redKnights[a].sounds['kill']:play()
                                self.map.kills = self.map.kills + 1
                            end
                            if self.map.redKnights[a].direction == 'right' then
                                self.map.redKnights[a].state = 'dying_backHit'
                            else
                                self.map.redKnights[a].state = 'dying_frontHit'
                            end
                        end
                    end
                end
            elseif self.hittable[i] == 'Player' then
                if self.map.player.immune == false then
                    if math.floor(self.x + self.width) >= math.floor(self.map.player.x) and math.floor(self.x + self.width) <= math.floor(self.map.player.x + self.map.player.width) and self.y + self.height > self.map.player.y and self.y < self.map.player.y + self.map.player.height then
                        self.map.player.sounds['hit']:play()
                        self.delete = true
                        self.map.player.lives = self.map.player.lives - 1
                        self.map.player.immune = true
                    end
                end
            end
        end
    else
        if self.x + self.width <= 0 or self.map:collides(self.map:tileAt(self.x, self.y)) or self.map:collides(self.map:tileAt(self.x, self.y + self.height - 1)) then
            self.delete = true
        end
        for i = 1, #self.hittable do
            if self.hittable[i] == 'Alien' then
                for a = 1, #self.map.aliens do
                    if self.x <= self.map.aliens[a].x + self.map.aliens[a].width and self.x >= self.map.aliens[a].x and self.y + self.height > self.map.aliens[a].y and self.y < self.map.aliens[a].y + self.map.aliens[a].height then
                        self.delete = true
                        if self.map.aliens[a].state ~= 'dying' then
                            self.map.aliens[a].sounds['kill']:play()
                            self.map.kills = self.map.kills + 1
                        end
                        self.map.aliens[a].state = 'dying'
                    end
                end
            elseif self.hittable[i] == 'RedKnight' then
                if self.map.level >= self.map.redKnightAppearanceLevel then
                    for a = 1, #self.map.redKnights do
                        if self.x <= self.map.redKnights[a].x + self.map.redKnights[a].width and self.x >= self.map.redKnights[a].x and self.y + self.height > self.map.redKnights[a].y and self.y < self.map.redKnights[a].y + self.map.redKnights[a].height then
                            self.delete = true
                            if self.map.redKnights[a].state ~= 'dying_frontHit' and self.map.redKnights[a].state ~= 'dying_backHit' then
                                self.map.redKnights[a].sounds['kill']:play()
                                self.map.kills = self.map.kills + 1
                            end
                            if self.map.redKnights[a].direction == 'right' then
                                self.map.redKnights[a].state = 'dying_frontHit'
                            else
                                self.map.redKnights[a].state = 'dying_backHit'
                            end
                        end
                    end
                end
            elseif self.hittable[i] == 'Player' then
                if self.map.player.immune == false then
                    if self.x <= self.map.player.x + self.map.player.width and self.x >= self.map.player.x and self.y + self.height > self.map.player.y and self.y < self.map.player.y + self.map.player.height then
                        self.map.player.sounds['hit']:play()
                        self.delete = true
                        self.map.player.lives = self.map.player.lives - 1
                        self.map.player.immune = true
                    end
                end
            end
        end
    end
end

function Bullet:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end