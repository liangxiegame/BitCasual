
require("app.Game.PlayerFSM.PlayerState")

PlayerThreeState = class("PlayerThreeState",PlayerState)

function PlayerThreeState:OnEnter()
	QPrint("player Three state: on enter")
end