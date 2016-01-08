local GameClock = class("GameClock",function (  )
	return display.newNode()
end)

function GameClock:ctor()
	self:pos(display.cx,display.cy)
	self:setupNodes()

	DrawUtil.DrawPoint(self, 0, 0, cc.c4b(0,0,0,0))
end


function GameClock:setupNodes()
	display.newSprite(display.newSpriteFrame("time.png"), -100, 0)
		:addTo(self)

	display.newSprite(display.newSpriteFrame("split.png"), 50, 0)
		:addTo(self)

	self.numberLabel = GUIUtil.number("center", "normal", 10, 100, 0, 1.1)
		:addTo(self)

	self.numberLabel:AddNumber(10)
end

return GameClock


