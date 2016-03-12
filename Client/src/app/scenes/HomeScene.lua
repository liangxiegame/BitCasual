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
    if not DataManager.HomeMusicOn then 
        audio.playMusic("sound/home2.mp3", true)
        DataManager.HomeMusicOn = true
        DataManager.GameMusicOn = false
    end 
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
        :setButtonSize(400, 100)
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
        :pos(display.cx, display.cy * 0.6)
        :addTo(self)
        :addChild(display.newSprite(display.newSpriteFrame("start.png"), 0, 0))

    -- 帮助按钮
    cc.ui.UIPushButton.new(nil,{scale = false})
        :setButtonSize(400,100)
        :setColor(display.COLOR_BLACK)
        :onButtonPressed(function (event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function (event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function (  )
            app:enterScene("HelpScene",nil,"fade")
        end)
        :pos(display.cx,display.cy * 0.4)
        :addTo(self)
        :addChild(display.newSprite("image/howto.png", 0, 0))
end

function HomeScene:onEnter()
	-- MsgDispatcher.SendLogicMsg("sutupnodes") -- 消息机制
    -- 应该有个Controller层
	-- app:enterScene("H")
end

function HomeScene:onExit()
	QPrint("HomeScene:onExit")
end

return HomeScene