
local PlayerState = require("app.Game.PlayerFSM.PlayerState")

local Player1010State = class("Player1010State",PlayerState)

-- 1010状态 主要是拖拽
function Player1010State:OnEnter()
	QPrint("1010:OnEnter")
	
	-- 播放声音
	audio.playSound("res/sound/push.wav", false)

end

function Player1010State:OnExit()
	QPrint("1010:OnExit")
end

return Player1010State

