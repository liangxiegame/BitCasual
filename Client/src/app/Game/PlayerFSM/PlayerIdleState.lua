
require("app.Game.PlayerFSM.PlayerState")

PlayerIdleState = class("PlayerIdleState",PlayerState)

function PlayerIdleState:OnEnter()
	QPrint("player Idle state: on enter")
end