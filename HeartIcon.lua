HeartIcon = Class{}
require 'Animation'

function HeartIcon:init(map)
    self.width = 16
    self.height = 16

    self.map = map

    self.x = math.random(self.map.tileWidth * 6, self.map.mapWidthPixels - self.map.tileWidth * 4)
    for y = 1, self.map.mapHeight do
        if self.map:tileAt(self.x + self.width / 2, (y - 1) * self.map.tileHeight).id == 1 then
            self.y = (self.map:tileAt(self.x + self.width / 2, (y - 1) * self.map.tileHeight).y - 1) * self.map.tileHeight - self.height
            break
        end
    end

    self.texture = love.graphics.newImage('graphics/heart.png')
    self.frames = generateQuads(self.texture, 16, 16)

    self.animations = {
        ['active'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[1], self.frames[2], self.frames[3], self.frames[4]
            },
            interval = 0.15,
            loop = true
        }
    }

    self.animation = self.animations['active']
    self.currentFrame = self.animation:getCurrentFrame()
end

function HeartIcon:update(dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
end

function HeartIcon:render()
    love.graphics.draw(self.texture, self.currentFrame, 
    self.x, self.y)
end