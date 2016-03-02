local QNumber = class("QNumber",function (  )
	return display.newNode()
end)

-- 这次是使用纹理实现数字精灵
function QNumber:ctor()
	self.numSprites = {}
end

--@public
-- 作为Lable的基本设置
function QNumber:setSpace( space ) self.space = space end
function QNumber:setAlign( align ) self.align = align end
function QNumber:setType(name )
	local tc = cc.Director:getInstance():getTextureCache()

	if name == "normal" then 
		imagePrefix = ""
	else 
		QPrint("no image name called:",name)
		return 
	end 
	self.name = name
    self.mImagePrefix = ""
end

-- @public 
-- 设置数字
function QNumber:setNumber(num)
    self.curNum = num
    --数字转换为数组
    local numArray = QMathUtil.ArrayForNumber(num)
    
    self.frameSize = display.newSprite(display.newSpriteFrame("2.png")):getContentSize()

    self:setFrames(numArray)
end

function QNumber:getNumber( )
    return self.curNum
end

--处理后显示数字 没有变数过程
function QNumber:replaceNumber(num)
    self:setFrames(QMathUtil.ArrayForNumber(num))
end

--更改数字
function QNumber:AddNumber(num)
    
    local isAdd

    if num > 0 then 
        isAdd = true
    elseif num < 0 then
        isAdd = false
    else
        return
    end
    
    --间隔
    local duration
    
    local times

    local abs_num = math.abs(num)

    if abs_num < 10 then

        times = abs_num
        
    elseif abs_num < 33 then

        times = 10
    else
        times = 33
    end    
        
    if self.isScheduleUpdate == true then
        if num + self.becomeNumber < 0 then
            return false
        end
        --将要变成的数字
        self.becomeNumber = num + self.becomeNumber 
        --差
        local distance = self.becomeNumber - self.tempNumber
        duration = math.modf(distance / times)
        
    else
        if num + self.curNum < 0 then
            return false
        end
        --获取当前的数字
        self.tempNumber = self.curNum
        --将要变成的数字
        self.becomeNumber = num + self.curNum
        --间隔
        duration = math.modf(num / times)
    end
   
    
    self.numsArray = QMathUtil.ArrayForNumber(self.becomeNumber)
    
    local function counter(dt)
        self.tempNumber = self.tempNumber + duration
        local nums = QMathUtil.ArrayForNumber(self.tempNumber)
--        QPrint(self.tempNumber)
        
        if isAdd == true and self.tempNumber + duration > self.becomeNumber then
            self:unscheduleUpdate()                  -- 取消定时器
            QPrint(self.becomeNumber)
            self.curNum = self.becomeNumber 
            self:setFrames(QMathUtil.ArrayForNumber(self.becomeNumber ))
            
            if self.func then
                self.func()
            end
            self.changing = false
            return
        end
        
        if isAdd == false and self.tempNumber + duration < self.becomeNumber then
            self:unscheduleUpdate()                  -- 取消定时器
            QPrint(self.tempNumber)
            QPrint(self.becomeNumber)
            self.curNum = self.becomeNumber 
            self:setFrames(QMathUtil.ArrayForNumber(self.becomeNumber ))
            
            if self.func then
                self.func()
            end
            
            return
        end
        self:setFrames(nums)
    end
    self:scheduleUpdateWithPriorityLua(counter,0)
    self.isScheduleUpdate = true

    return true
end

function QNumber:setFrames(numArray)
    --获取纹理

    --左对齐
    if self.align == "left" then
        for i = 1,#numArray do
            
            if self.numSprites[i] then 
                self.numSprites[i]:setSpriteFrame(display.newSpriteFrame(""..numArray[i]..".png"))
                self.numSprites[i]:pos((#numArray - i)  * self.frameSize.width  * self.space,0)
            else 
                self.numSprites[i] = display.newSprite(display.newSpriteFrame(""..numArray[i]..".png"),(#numArray - i)  * self.frameSize.width  * self.space,0)
                :addTo(self)
            end 

            self.numSprites[i].num = numArray[i] 
                
        end
        --居中
    elseif self.align == "center" then
        local initPosX = (#numArray - 1) / 2
        for i = 1,#numArray do

            if self.numSprites[i] then 
                self.numSprites[i]:setSpriteFrame(display.newSpriteFrame(""..numArray[i]..".png"))
                self.numSprites[i]:pos((initPosX - i + 1) * self.frameSize.width  * self.space,0)
            else 
                self.numSprites[i] = display.newSprite(display.newSpriteFrame(""..numArray[i]..".png"),(initPosX - i + 1) * self.frameSize.width  * self.space,0)
                    :addTo(self)
            end 

            self.numSprites[i].num = numArray[i] + 0
        end
    end
    
    -- 要比较
    for i = 1,#self.numSprites do 
        if numArray[i] == self.numSprites[i].num then 
            self.numSprites[i]:show()
        else 
            self.numSprites[i]:hide()
        end 
    end 
end

return QNumber