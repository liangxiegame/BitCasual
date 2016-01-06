local HomeScene = class("HomeScene",function (  )
	return display.newScene("HomeScene")
end)

--[[
  主界面
  ]]
function HomeScene:ctor()
	QPrint("HomeScene:ctor()")	

	self:initData();
	self:setupNodes();
end

function HomeScene:initData()
	-- MsgDispatcher.RegLogicMsg("setupnodes",self,self.setupNodes)
        -- 测试一下状态机
    require("app.Game.PlayerFSM.Player1010State")
    require("app.Game.PlayerFSM.PlayerCrushState")
    require("app.Game.PlayerFSM.PlayerIdleState")
    require("app.Game.PlayerFSM.PlayerThreeState")

    local fsm = FSM:new()

    local state1010 = Player1010State:new("1010",self)
    local stateCrush = PlayerCrushState:new("Crush",self)
    local stateIdle = PlayerIdleState:new("Idle",self)
    local stateThree = PlayerThreeState:new("Three",self)

    fsm:AddState(state1010)
    fsm:AddState(stateCrush)
    fsm:AddState(stateIdle)
    fsm:AddState(stateThree)

    fsm:Start(state1010)

end

function HomeScene:setupNodes()
    -- 白色背景
	display.newColorLayer(cc.c4b(255, 255, 255,255))
		:addTo(self)

    -- logo
	display.newSprite(display.newSpriteFrame("logo.png"), display.cx, display.cy  * 1.5)
		:addTo(self)	

    -- 开始按钮
	cc.ui.UIPushButton.new(nil, {scale9 = false})
        :setButtonSize(200, 80)
        -- :setButtonLabel(cc.ui.UILabel.new({text = "REFRESH"}))
        :setColor(display.COLOR_BLACK)
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            app:enterScene("GameScene", nil, "fade")
        end)
        :pos(display.cx, display.cy * 0.5)
        :addTo(self)
        :addChild(display.newSprite(display.newSpriteFrame("start.png"), 0, 0))
end

function HomeScene:onEnter()
	-- MsgDispatcher.SendLogicMsg("sutupnodes") -- 消息机制
    -- 应该有个Controller层
	-- app:enterScene("GameScene")
end

function HomeScene:onExit()
	QPrint("HomeScene:onExit")
end

return HomeScene