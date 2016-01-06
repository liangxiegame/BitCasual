
require("app.Game.PlayerFSM.PlayerState")

Player1010State = class("Player1010State",PlayerState)

function Player1010State:OnEnter()
	QPrint("player 1010 state: on enter")
end