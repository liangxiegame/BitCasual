local PlayerState = require("app.Game.PlayerFSM.PlayerState")

local PlayerThreeState = class("PlayerThreeState",PlayerState)

-- 小三传奇 主要是 滑动
function PlayerThreeState:OnEnter()
	QPrint("Three:onEnter")
end

function PlayerThreeState:OnExit()
	QPrint("Three:onExit")
end


return PlayerThreeState