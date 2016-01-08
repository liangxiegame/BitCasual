local GameClock = class("GameClock",function (  )
	return display.newNode()
end)

function GameClock:ctor()
	self:initData()
	self:setupNodes()

	self:startTick()

	-- DrawUtil.DrawPoint(self, 0, 0, cc.c4b(0,0,0,255))
end

function GameClock:initData()
	self.remainTime = 10
end

function GameClock:setupNodes()
	display.newSprite(display.newSpriteFrame("time.png"), -90, 0)
		:addTo(self)

	display.newSprite(display.newSpriteFrame("split.png"), 0, 0)
		:addTo(self)

	self.number = GUIUtil.number("left", "normal", 0, 30, 0, 1.1)
		:addTo(self)

	self.number:AddNumber(10)
end

-- @public
function GameClock:getNumber()
	return self.number.curNum
end


function GameClock:startTick()
	-- body

	local speed = 0.05

	local function tick()
		if self.number:AddNumber(-1) then 
			audio.playSound("res/sound/tick.wav", false)
		else 
			QPrint("game_over")
			self:stop()

			app:enterScene("GameOver")
		end 
	end

	action = self:schedule(tick,1.0)
end

return GameClock


