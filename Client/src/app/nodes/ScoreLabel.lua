local ScoreLabel = class("ScoreLabel",function (  )
	return display.newNode()
end)

function ScoreLabel:ctor( )
	-- body
	self:initData()
	self:setupNodes()
end


function ScoreLabel:initData()
	self.score = 0
	
end

function ScoreLabel:setupNodes()
	display.newSprite(display.newSpriteFrame("score.png"),-110,0)
		:addTo(self)

	display.newSprite(display.newSpriteFrame("split.png"), 0, 0)
		:addTo(self)

	self.number = GUIUtil.number("left", "normal", self.score, 30, 0, 1.1)
		:addTo(self)
end

function ScoreLabel:AddScore(score)
	self.number:AddNumber(score)
	DataManager.Score = DataManager.Score + score
end

return ScoreLabel