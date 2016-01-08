
local PlayerState = require("app.Game.PlayerFSM.PlayerState")

local Player1010State = class("Player1010State",PlayerState)

-- 1010状态 主要是拖拽
function Player1010State:OnEnter()
	QPrint("1010:OnEnter")
	
	-- 播放声音
	audio.playSound("res/sound/push.wav", false)


    self.mScene.matrixBeganPosX = self.mScene.matrixNode:getPositionX()
    self.mScene.matrixBeganPosY = self.mScene.matrixNode:getPositionY()

    self.mScene.deltaX = self.mScene.touchBeganX - self.mScene.matrixBeganPosX
    self.mScene.deltaY = self.mScene.touchBeganY - self.mScene.matrixBeganPosY

    self.mScene.matrixNode:scale(1.0)

end

function Player1010State:OnExit()
	QPrint("1010:OnExit")
end

return Player1010State

