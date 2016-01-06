
require("app.Game.PlayerFSM.PlayerState")

PlayerCrushState = class("PlayerCrushState",PlayerState)

function PlayerCrushState:OnEnter()
	QPrint("player Crush state: on enter")
end