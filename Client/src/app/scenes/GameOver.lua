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

    NativeUtil.PreloadFullAd()
end


function GameOver:onEnter()
    


end
return GameOver