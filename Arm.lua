import 'CoreLibs/crank'

armController = {
    rotation = 0
}

--local imports
local gfx = playdate.graphics
local efs = playdate.easingFunctions


local ARM_IMAGES = {
    [1] = "armNormal",
    [2] = "armLaser",
    [7] = "armGlove"
}


class("Arm").extends(gfx.sprite)
function Arm:init(index, b_xoff, b_yoff)
    Arm.super.init(self)
    self:setImage(gfx.image.new("images/arms/armNormal" .. index))

    self.charge = 0 --POWERUPS_STARTUP[type]

    self.count = 0 --bullet count associated with each arm

    self.b_xoff = b_xoff --bullet spawn point offset from arm pos 
    self.b_yoff = b_yoff

    self.count = 0 --number of bullets associated with arm

    self.maxBullets = POWERUP_MAX_COUNT[type]
    self.index = index

    self.ocd = false --is the current arm on cooldown

    self.currentRotation = 0

    self:setZIndex(DRAW_LAYER.ARM)
end

function Arm:addArm(arm_type)

    self:setImage(gfx.image.new("images/arms/" .. ARM_IMAGES[arm_type] .. self.index))

    self.maxBullets = POWERUP_MAX_COUNT[arm_type] --update bullet cap for new powerup
    self.charge = 0 --update charge

    self.arm_type = arm_type

    self:add()
end

 function Arm:rotateBy(angle)
     if self.index == 1 or self.index == 3 then
         self.currentRotation = self.currentRotation - angle
     else
         self.currentRotation = self.currentRotation + angle
     end

     self:setRotation(self.currentRotation) --set rotation accordingly
 end

function Arm:rotateTo(angle)
     if self.index == 1 or self.index == 3 then
         self.currentRotation = angle
     else
         self.currentRotation = -angle
     end

     self:setRotation(self.currentRotation) --set rotation accordingly
 end
