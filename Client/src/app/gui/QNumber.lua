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
    QPrint("frame width",self.frameSize.width)
    --左对齐
    if self.align == "left" then
        for i = 1,#numArray do

            local spFrame = cc.SpriteFrame:createWithTexture(texture,cc.rect(self.frameSize.width  * nums[i],0,self.frameSize.width / 10.0,self.frameSize.height))

            self.numSprites[i] = cc.Sprite:createWithSpriteFrame(spFrame)
                :pos((nums.count - i)  * size.width / 10 * self.space,0)
                :addTo(self) 

            self.numSprites[i].num = nums[i] 
        end

    --居中
    elseif self.align == "center" then
        QPrint(#numArray,"numArray")
        local initPosX = (#numArray - 1) / 2
        for i = 1,#numArray do

            if self.numSprites[i] then 
                self.numSprites[i]:setSpriteFrame(display.newSpriteFrame(""..numArray[i]..".png"))
                self.numSprites[i]:pos((initPosX - i + 1) * self.frameSize.width  * self.space,0)
            else 
                self.numSprites[i] = display.newSprite(display.newSpriteFrame(""..numArray[i]..".png"),(initPosX - i + 1) * self.frameSize.width  * self.space,0)
                :addTo(self)
            end 

            self.numSprites[i].num = numArray[i]
        end
    end

    -- self:setFrames(QMathUtil.ArrayForNumber())
    -- self:setFrames(numArray)
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
        for i = 1,7 do
            
            local tempNum 
            if nums[i] == nil then
                tempNum = 0
            else 
                tempNum = nums[i]
            end
            
            local spFrame = cc.SpriteFrame:createWithTexture(texture,cc.rect(size.width / 10.0 * tempNum,0,size.width / 10.0,size.height))

            self.numSprites[i]:setSpriteFrame(spFrame)
                :pos((nums.count - i)  * size.width / 10.0 * self.space,0)
                
            self.numSprites[i].num = tempNum
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
    
    local tempIndex

    local hideZero = false

    for i = 1, 6 do

        tempIndex = 8 - i 

        if self.numSprites[tempIndex] == nil then
        
        elseif self.numSprites[tempIndex].num == nil then

            self.numSprites[tempIndex]:hide()

        elseif self.numSprites[tempIndex].num == 0 then
            if hideZero == false then
                self.numSprites[tempIndex]:hide()
            else 
                self.numSprites[tempIndex]:show()
            end
        else 
            hideZero = true
            self.numSprites[tempIndex]:show()
        end 
    end
end

return QNumber