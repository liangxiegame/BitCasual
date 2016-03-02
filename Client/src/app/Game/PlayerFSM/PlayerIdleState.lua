
local PlayerState = require("app.Game.PlayerFSM.PlayerState")

local PlayerIdleState = class("PlayerIdleState",PlayerState)

-- 默认状态
function PlayerIdleState:OnEnter()
	QPrint("Idle:OnEnter")
end

function PlayerIdleState:OnExit()
	QPrint("Idle:OnExit")
end

return PlayerIdleState