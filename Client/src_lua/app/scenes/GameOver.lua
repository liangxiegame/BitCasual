local GameOver = class("GameOver",function (  )
	return display.newScene("GameOver")
end)

function GameOver:ctor()

    DataManager.Save()
    -- 白色底
    cc.LayerColor:create(cc.c4b(255,255,255,255))
                        :addTo(self)

    -- 游戏结束
    display.newSprite(display.newSpriteFrame("over_logo.png"), display.cx,display.cy * 1.6)
                        :addTo(self)
    -- 点击重新开始
    display.newSprite(display.newSpriteFrame("tap_anywhere.png"), display.cx, display.cy * 0.1)
                        :scale(0.8)
                        :addTo(self)
                        :runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.2),cca.delay(0.3),cc.FadeOut:create(0.2),cca.delay(0.2))))


    -- best
    display.newSprite(display.newSpriteFrame("best.png"), display.cx * 0.5,display.cy * 1.1)
                        :addTo(self)
    -- :
    display.newSprite(display.newSpriteFrame("split.png"), display.cx * 0.5 + 90 , display.cy * 1.1)
                        :addTo(self)

    local bestScoreLabel = GUIUtil.number("left", "normal", 0, display.cx * 0.5 + 120, display.cy * 1.1, 1.2)
            :addTo(self)


    -- score
    display.newSprite(display.newSpriteFrame("score.png"), display.cx * 0.56, display.cy * 0.9)
                        :addTo(self)

    -- :
    display.newSprite(display.newSpriteFrame("split.png"), display.cx * 0.56 + 110, display.cy * 0.9)
                        :addTo(self)

    local scoreLabel = GUIUtil.number("left", "normal", 0, display.cx * 0.56 + 140, display.cy * 0.9, 1.2)
                        :addTo(self)


    bestScoreLabel:AddNumber(DataManager.BestScore)
    scoreLabel:AddNumber(DataManager.Score)

    self:registerEvent()
end


function GameOver:registerEvent(  )
    
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)

        if event.name == "began" then
        
            -- return self:onTouchBegan(event.x, event.y)
            app:enterScene("GameScene")

        elseif event.name == "moved" then
        
            -- self:onTouchMoved(event.x, event.y)

        elseif event.name == "ended" then

            -- self:onTouchEnded(event.x, event.y)

        elseif event.name == "cancel" then
        
        end

        return bRet

    end)
        
    self:setTouchSwallowEnabled(false) 
    self:setTouchEnabled(true)

    -- self:schedule(self.logic, 1.0 / 60.0)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()

    local supportObjectCBridge  = false
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform)  then
        supportObjectCBridge = true
    end
    
        if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
            local args = { num1 = 2 , num2 = 3 }
            local luaoc = require "cocos.cocos2d.luaoc"
            local className = "LuaObjectCBridgeTest"
            local ok,ret  = luaoc.callStaticMethod(className,"isFullLoadedOC")
            -- local ok,ret  = luaoc.callStaticMethod(className,"isFullLoadedOC",args)
            if not ok then
                cc.Director:getInstance():resume()
            else
                print("The ret is:", ret)

                if ret == 1 or ret == "1" then
                    
                    cc.Director:getInstance():stopAnimation()

                    cc.Director:getInstance():pause()

                    luaoc.callStaticMethod(className,"showFullOC")



                else

                    luaoc.callStaticMethod(className,"loadFullOC")

                end
            end

            local function callback(param)
                if "success" == param then
                    print("object c call back success")
                end
            end
            luaoc.callStaticMethod(className,"registerScriptHandler", {scriptHandler = callback } )
            luaoc.callStaticMethod(className,"callbackScriptHandler")
        end
end


function GameOver:onEnter()
    


end
return GameOver