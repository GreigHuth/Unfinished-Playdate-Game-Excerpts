---Place for effects like enemy death animations or the background bubble


--local imports
local gfx = playdate.graphics

--Explosion class
class('Explosion').extends(gfx.sprite)
function Explosion:init()
	Explosion.super.init(self) --this doesnt work idk why
	self.images = gfx.imagetable.new("images/explosion/BubblesAnim-table-64-64")
	self:setZIndex(DRAW_LAYER.ENEMY2)
end

function Explosion:update()
	if stagetime % 2 == 0 then self.frame += 1 end --animate on 2s
	if self.frame > #self.images then
		self:remove()
	else
		self:setImage(self.images[self.frame])
	end
end

function Explosion:spawn(xStart, yStart)
	local copy = self:copy()
	copy.frame = 1
	copy:moveTo(xStart, yStart)
	copy:add()
end



class('Bubble').extends(gfx.sprite)
function Bubble:init()
	Bubble.super.init(self)
    self:setImage(gfx.image.new("images/bubble"))
    self:setZIndex(DRAW_LAYER.BUBBLES)
end

function Bubble:update()
    self:moveBy(self.xVel, self.yVel)
    if self.y < -5 then --reset when they hit the top of the scren
        --randomise velocity on respawn
        self.xVel = math.random(-5, -1) * (30 / playdate.display.getRefreshRate())
        self.yVel = math.random(-7, -1) * (30 / playdate.display.getRefreshRate())
        self:moveTo(math.random(0, 450), 200)
    end
end

function Bubble:spawn()
	local copy = self:copy()
	copy.xVel = math.random(-5, -1) * (30 / playdate.display.getRefreshRate()) --sprite needs to remember velocity and be able to change it
	copy.yVel = math.random(-7, -1) * (30 / playdate.display.getRefreshRate())
	copy:add()
end

local bubbleList = {}
local maxBubbles = 15
bubbleCount = 0

--initialise all the bubbles at the start
local function initBubbles()
	for i = 1, maxBubbles, 1 do
		bubbleList[i] = Bubble()
		bubbleCount += 1
		bubbleList[i]:spawn()
	end
end
