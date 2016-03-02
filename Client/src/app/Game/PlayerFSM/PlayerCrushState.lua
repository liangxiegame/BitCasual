
local PlayerState = require("app.Game.PlayerFSM.PlayerState")

local PlayerCrushState = class("PlayerCrushState",PlayerState)

-- 消除 主要是点击
function PlayerCrushState:OnEnter()
	QPrint("Crush:OnEnter")
end

function PlayerCrushState:OnExit()
	QPrint("Crush:OnExit")
	app.gameModel.scene.gameBox:cancelSelected()

end

return PlayerCrushState