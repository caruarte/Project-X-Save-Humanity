Button = Class{}

function Button:init(x, y, img, multiple, scale)
    self.x = x
    self.y = y
    self.width = 0
    self.height = 0
    self.image = img
    self.currentImage = 1
    self.sounds = {
        ['hover'] = love.audio.newSource('sounds/ui-hover.wav', 'static')
    }
    self.sounds['hover']:setVolume(0.1)
    self.multiple = multiple
    self.hover = false
    self.pressed = false
    self.scale = scale or 1
end

function Button:update(dt)
    mouseX, mouseY = love.mouse.getPosition()
    mouseX = math.floor(mouseX / love.graphics.getWidth() * VIRTUAL_WIDTH)
    mouseY = math.floor(mouseY / love.graphics.getHeight() * VIRTUAL_HEIGHT)
    if self.multiple == true then
        self.width, self.height = self.image[self.currentImage]:getDimensions()
    else
        self.width, self.height = self.image:getDimensions()
    end
    self.width = self.width * self.scale
    self.height = self.height * self.scale
    if mouseX >= self.x and mouseX <= self.x + self.width and mouseY >= self.y and mouseY <= self.y + self.height then
        if self.hover == false then
            self.sounds['hover']:play()
        end
        self.hover = true
    else
        self.hover = false
        
    end
    if self.multiple == true then
        if self.hover == true then
            self.currentImage = 2
        else
            self.currentImage = 1
        end
    end
end

function Button:render()
    if self.multiple == true then
        love.graphics.draw(self.image[self.currentImage], self.x, self.y, 0, self.scale)
    else
        love.graphics.draw(self.image, self.x, self.y, 0, self.scale)
    end
    
end