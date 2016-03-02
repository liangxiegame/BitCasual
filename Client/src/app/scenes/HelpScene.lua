local HelpScene = class("HelpScene",function (  )
	return display.newScene("HelpScene")
end)


function HelpScene:ctor()
		

	self:setupNodes()

	self:registerEvent()

end

function HelpScene:setupNodes()
   -- 白色背景
	display.newColorLayer(cc.c4b(255, 255, 255,255))
		:zorder(-1)
		:addTo(self)


	display.newSprite("image/help.png", display.cx, display.cy * 1.2)
		:scale(0.9)
		:addTo(self)
end

-- 注册触摸事件
function HelpScene:registerEvent()

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then

        	app:enterScene("HomeScene")

            -- return self:onTouchBegan(event.x, event.y)
        elseif event.name == "moved" then
            -- self:onTouchMoved(event.x, event.y)
        elseif event.name == "ended" then
            -- self:onTouchEnded(event.x, event.y)
        elseif event.name == "cancel" then
            -- self.gameBox:cancelSelected()

        end
    end)
        
    self:setTouchSwallowEnabled(true) 
    self:setTouchEnabled(true)
    -- self:schedule(self.logic, 1.0 / 30.0)
end


return HelpScene


