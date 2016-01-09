local GameModel = class("GameModel",cc.mvc.ModelBase)

-- @private
-- 游戏的数据和状态管理 应该是个单例 
function GameModel:ctor()
	app.gameModel = self -- 交给app来管理

	self:setupFSM()
end

-- @private
-- 设置状态机
function GameModel:setupFSM( )
	    -- 状态机设置
    self.fsm = FSM.new()

    local Player1010State = require("app.Game.PlayerFSM.Player1010State")
    local PlayerCrushState = require("app.Game.PlayerFSM.PlayerCrushState")
    local PlayerIdleState = require("app.Game.PlayerFSM.PlayerIdleState")
    local PlayerThreeState = require("app.Game.PlayerFSM.PlayerThreeState")

    GAME_IDLE = PlayerIdleState.new("idle",self)
    GAME_CRUSH = PlayerCrushState.new("crush",self)
    GAME_1010  = Player1010State.new("1010",self)
    GAME_THREE = PlayerThreeState.new("three",self)

    self.fsm:AddState(GAME_IDLE)
    self.fsm:AddState(GAME_CRUSH)
    self.fsm:AddState(GAME_1010)
    self.fsm:AddState(GAME_THREE)

    self.fsm:AddTranslation(GAME_IDLE, "1010", GAME_1010)
    self.fsm:AddTranslation(GAME_IDLE, "crush", GAME_CRUSH)
    self.fsm:AddTranslation(GAME_IDLE, "three", GAME_THREE)

    self.fsm:AddTranslation(GAME_CRUSH, "1010", GAME_1010)
    
    self.fsm:AddTranslation(GAME_1010, "idle", GAME_IDLE)
    self.fsm:AddTranslation(GAME_CRUSH,"idle", GAME_IDLE)
    self.fsm:AddTranslation(GAME_THREE,"idle", GAME_IDLE)

end

-- public 
-- 初始化数据
function GameModel:initModel()

	-- 初始化状态 
    self.fsm:Start(GAME_IDLE)

    -- 这个忘了有没有用
    self.touchID = -1
    self.objectCount = 0

    -- 设置方向
    self.direction = DIRECTION_IDLE

    -- 是否已经验证
    self.threeValidated = false 

    local BoxData = require("app.Game.BoxData")

    -- 临时存储的数据
    self.tempBoxData = BoxData.new()


end

return GameModel