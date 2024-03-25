---Bullet.lua
POWERUPS = {
    NORMAL = 1, --basic shot
    LASER = 2, --laser
    STRONG = 3,
    WORM = 4,
    ROBOT = 5,
    BATTERY = 6,
    GLOVE = 7, --melee attack
    CHARGE = 8,
    BIG_LASER = 9,
	WEAK = 10
}

--the max amount of each bullet allowed on the screen
POWERUP_MAX_COUNT = {
    [1] = 15,
    [2] = 20,
    [7] = 1
}

POWERUPS_RANGE = {
	[1] = 300,
	[2] = 600,
	[7] = 1000
}

POWERUP_COOLDOWNS = {
    [1] = 9,
    [2] = 1,
    [7] = 20
}

POWERUPS_STARTUP = {
    [1] = 0,
    [2] = 50,
    [7] = 30
}

--local imports
local cos = math.cos
local sin = math.sin
local pi  = math.pi
local abs = math.abs
local gfx = playdate.graphics
local frameTimer = playdate.frameTimer
local vector2D = playdate.geometry.vector2D
local Point = playdate.geometry.point


class('Bullet').extends(gfx.sprite)
function Bullet:init() --overload to initialise
	Bullet.super.init(self)
	self:setZIndex(DRAW_LAYER.BULLET)
	self:setGroups(COLLIDE_GROUPS.BULLET)
	self:setCollidesWithGroups(COLLIDE_GROUPS.ENEMY)
end

function Bullet:collisionResponse(other)

	if other.isEnemy then
		player.score += ENEMY_SCORE[other.ID]
	end

	return gfx.sprite.kCollisionTypeOverlap
end

function Bullet:spawn()
	local copy = self:copy()
	return copy
end

-- Utility Functions
function Bullet:inRange()
	if (abs(self.position.x) - player.x) > POWERUPS_RANGE[self.type] then
		return false
	else
		return true
	end
end


class('BulletNormal').extends(Bullet)
function BulletNormal:init()
	BulletNormal.super.init(self)

	local w = 16
	local h = 16

	local image = gfx.image.new("images/bullets/doubleBullet")
	--local image = gfx.image.new(w, h, playdate.graphics.kColorWhite)
	self:setImage(image)
	self:setCollideRect(3, 2, w, h)

	self.w = w
	self.h = h

	self.cooldown = POWERUP_COOLDOWNS[POWERUPS.NORMAL]
	self.cooldownTimer = frameTimer.new(self.cooldown, 0, self.cooldown)

	self.currentRotation = 0
	self.type = POWERUPS.NORMAL
	self.speed_mod = 11.6
end

function BulletNormal:update() --update function run every frame

	if self.isEnemy ~= true then
		local aX, aY, collisions, length = self:checkCollisions(self.position)
		for i=1, length do
			if collisions[i].other.isEnemy == true then
				self:remove()
				collisions[i].other:hit(1)
				removeFromList(self, bullet_list)
			end
		end
	else
		local aX, aY, collisions, length = self:checkCollisions(self.position)
		for i=1, length do
			if collisions[i].other.isPlayer == true then
				self:remove()
				collisions[i].other.lives -= 1
				removeFromList(self, bullet_list)
			end
		end

	end
end


class('BulletLaser').extends(Bullet)
function BulletLaser:init()
	BulletLaser.super.init(self)

	local w = 64
	local h = 32

	local image = gfx.image.new("images/bullets/laserBullet")
	self:setImage(image)
	self:setCollideRect(0, 6, w, 20 )

	self.hp = 3 --laser can hit multiple times

	self.cooldown = POWERUP_COOLDOWNS[POWERUPS.LASER]
	self.cooldownTimer = frameTimer.new(self.cooldown, 0, self.cooldown)

	self.maxCharge = 10 --different to "startup"
	
	self.speed_mod = 16
	
	self.type = POWERUPS.LASER

	self.w = w
	self.h = h
end


--resizes laser after it hits an enemy
function BulletLaser:reduceBeam()
	self.w = self.w/2
	self:setBounds(0, 0, self.w, self.h)
	self:setCollideRect(0,0, self.w, self.h)
	self.hp -= 1
end

function BulletLaser:update() --update function run every frame
	local actualX, actualY, collisions, length = self:checkCollisions(self.position)
	for i = 1, length do
		local collision = collisions[i]
		if collision.other.isEnemy == true then
			collision.other:hit(1) --1 damage
			--self:reduceBeam()
			self.hp -= 1
			
			if self.hp <= 0 then
				self:remove()
				removeFromList(self, bullet_list)
			end
			break
		end
	end
end


class('Bullet_Glove').extends(Bullet)
function Bullet_Glove:init()
	Bullet_Glove.super.init(self)

	local w = 30
	local h = 30
	
	local image = gfx.image.new("images/bullets/GloveBullet")
	self:setImage(image)
	self:setCollideRect(0, 0, w, h)

	self.speed_mod = 4
	self.count = 0
end

function Bullet_Glove:reset()
	self.rotMod = 0
end

function Bullet_Glove:inRange()
	return true
end

function Bullet_Glove:spawn(arm)

	local copy = self:copy()

	copy.time = 0

	return copy
end

function Bullet_Glove:update()

	self.time += 1

	if self.time == 7 then
		self:remove()
		removeFromList(self, bullet_list)
	end

	local actualX, actualY, collisions, length = self:moveWithCollisions(self.position)
	for i = 1, length do
		local collision = collisions[i]
		if collision.other.isEnemy == true then
			collision.other:hit(2) --trigger hit function in enemy
		end
	end
end

class('Bullet_Robot').extends(Bullet)
function Bullet_Robot:init()
	self.width = 24
	self.height = 24
	self.image = gfx.image.new(self.width, self.height, gfx.kColorBlack)
end
