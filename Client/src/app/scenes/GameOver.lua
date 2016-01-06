local GameOver = class("GameOver",function (  )
	return display.newScene("GameOver")
end)

function GameOver:ctor()

    -- 白色背景
	local colorWhite = cc.LayerColor:create(cc.c4b(255,255,255,255))
                        :addTo(self)

    local game_over = cc.Label:createWithSystemFont("Game Over","Arial",72)
    					:pos(display.cx,display.cy * 1.5)
    					:addTo(self)

    game_over:setColor(display.COLOR_BLACK)


    -- 点击重新开始
    local tap_replay = cc.Label:createWithSystemFont("Tap anywhere to replay","Arial",36)
    					:pos(display.cx,72)
    					:addTo(self)
    tap_replay:setColor(display.COLOR_BLACK)

    -- 闪烁效果
    tap_replay:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.2),cca.delay(0.3),cc.FadeOut:create(0.2),cca.delay(0.2))))


    -- 最高分
    local hscore = cc.UserDefault:getInstance():getIntegerForKey("highscore", 0)

    -- 当前分数
    local cscore = cc.UserDefault:getInstance():getIntegerForKey("score", 0)


    local high_score = cc.Label:createWithSystemFont("high score:"..hscore,"Arial",48)
    					:pos(display.cx * 1.5,display.cy)
    					:addTo(self)

    high_score:setColor(display.COLOR_BLACK)

    high_score:setAnchorPoint(1,0)


   local score = cc.Label:createWithSystemFont("score:"..cscore,"Arial",48)
    					:pos(display.cx * 1.5,display.cy - 48)
    					:addTo(self)

    score:setColor(display.COLOR_BLACK)
    score:setAnchorPoint(1,0)

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