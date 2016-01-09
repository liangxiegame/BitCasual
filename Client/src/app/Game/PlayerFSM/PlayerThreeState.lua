local PlayerState = require("app.Game.PlayerFSM.PlayerState")

local PlayerThreeState = class("PlayerThreeState",PlayerState)

-- 小三传奇 主要是 滑动
function PlayerThreeState:OnEnter()
	QPrint("Three:onEnter")
end

function PlayerThreeState:OnExit()
	QPrint("Three:onExit")
	        for i=1,ROW_COUNT do
                for j=1,COL_COUNT do
                    item = app.gameModel.scene.gameBox.gameItems[i][j]
                    if item then
                        item:moveBack()
                    end        
                end
            end

            app.gameModel.scene.threeValidated = false

            app.gameModel.scene.direction = DIRECTION_IDLE
end


return PlayerThreeState