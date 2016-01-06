GUIUtil = {}

local QNumebr = require("app.gui.QNumber")

function GUIUtil.number(align,type,num,posX,posY,space )

	if space == nil then space = 1 end 
	local number = QNumber:new()
	number:setAlign(align)
	number:setType(type)
	number:setSpace(space)
	number:setNumber(num)
	number:setPosition(posX,posY)

	return number
end

function GUIUtil.button(target,self,end_callback)
	local move_count = 0

	local function touchEvent( sender,eventType )
		if eventType == ccui.TouchEventType.began then 

		elseif eventType == ccui.TouchEventType.moved then 

		elseif eventType == ccui.TouchEventType.ended then 
			end_callback(self)
		elseif eventType == ccui.TouchEventType.canceled then 

		end 
	end

	target:AddTouchEventListener(touchEvent)

	return target
end

function GUIUtil:test()

	    cc.ui.UIPushButton.new("Button01.png", {scale9 = true})
        :setButtonSize(200, 80)
        :setButtonLabel(cc.ui.UILabel.new({text = "REFRESH"}))
        :setColor(display.COLOR_BLACK)
        :onButtonPressed(function(event)
            event.target:setScale(1.1)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function()
            app:enterScene("GameScene", nil, "flipy")
        end)
        :pos(display.cx, display.bottom + 100)
        :addTo(self)

end

return GUIUtil