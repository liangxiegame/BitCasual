local QNumber = class("QNumber",function (  )
	return display.newNode()
end)

function QNumber:ctor()
	self.sprites = {}
end

function QNumber:setSpace( space ) self.space = space end
function QNumber:setAlign( align ) self.align = align end

function QNumber:setType(name )
	local tc = cc.Director:getInstance():getTextureCache()

	if name == "normal" then 
		imageName = ""
	else 
		QPrint("no image name called:",name)
		return 
	end 

	-- 通过image获取图片,加载到纹理缓存中,并命名
	local image = cc.Image:new()

	image:initWithImageFile(imageName)

	tc:addImage(image, name)

	self.name = name
end

-- 处理数字的位数 
local function handleNum( num )
	-- 存储美味数字的数组
	local numArray = {}

	-- 用来计算的下角标
	local flag = 0

	-- 临时的
	local tempNum = num 
	local eLoop = true 
	while eloop do
		--移动下角标
		flag = flag + 1

		--获取第flag位的数字
		numArray[flag] = math.modf(tempNum % 10)

		-- 删除第flag位的数字
		tempNum = tempNum / 10

		if tempNum - 0 < 1 then 
			eLoop = false
		end 
		-- 移动下角标
	end

	numArray.count = flag 

	return numArray
end

function QNumber:setNumber(num)
    self.currentNum = num
    --数字转换为数组
    local nums = handleNum(num)
    
    --获取纹理
    local tc = cc.Director:getInstance():getTextureCache()
    local texture = tc:getTextureForKey(self.name)
    local size = texture:getContentSize()
    
    --左对齐
    if self.align == "left" then
        for i = 1,7 do
            
            if nums[i] == nil then
                nums[i] = 0
            end            

            local spFrame = cc.SpriteFrame:createWithTexture(texture,cc.rect(size.width / 10.0 * nums[i],0,size.width / 10.0,size.height))
            self.sprites[i] = cc.Sprite:createWithSpriteFrame(spFrame)
                :pos((nums.count - i)  * size.width / 10 * self.space,0)
                :addTo(self)   
            self.sprites[i].num = nums[i] 
        end

    --居中
    elseif self.align == "center" then
        local initPosX = (nums.count - 1) / 2
        for i = 1,7 do
            if nums[i] == nil then
                nums[i] = 0
            end

            local spFrame = cc.SpriteFrame:createWithTexture(texture,cc.rect(size.width / 10.0 * nums[i],0,size.width / 10.0,size.height))

            self.sprites[i] = cc.Sprite:createWithSpriteFrame(spFrame)
                :pos((initPosX - i + 1) * size.width / 10.0 * self.space,0)
                :addTo(self)
            self.sprites[i].num = nums[i]
        end
    end

    self:changeTextures(handleNum(self.currentNum))
end

--处理后显示数字 没有变数过程
function QNumber:replaceNumber(num)
    self:changeTextures(handleNum(num))
end

--更改数字
function QNumber:changeNumber(num)
    
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
        if num + self.currentNum < 0 then
            return false
        end
        --获取当前的数字
        self.tempNumber = self.currentNum
        --将要变成的数字
        self.becomeNumber = num + self.currentNum
        --间隔
        duration = math.modf(num / times)
    end
   
    
    self.numsArray = handleNum(self.becomeNumber)
    
    local function counter(dt)
        self.tempNumber = self.tempNumber + duration
        local nums = handleNum(self.tempNumber)
--        print(self.tempNumber)
        
        if isAdd == true and self.tempNumber + duration > self.becomeNumber then
            self:unscheduleUpdate()                  -- 取消定时器
            print(self.becomeNumber)
            self.currentNum = self.becomeNumber 
            self:changeTextures(handleNum(self.becomeNumber ))
            
            if self.func then
                self.func()
            end
            self.changing = false
            return
        end
        
        if isAdd == false and self.tempNumber + duration < self.becomeNumber then
            self:unscheduleUpdate()                  -- 取消定时器
            print(self.tempNumber)
            print(self.becomeNumber)
            self.currentNum = self.becomeNumber 
            self:changeTextures(handleNum(self.becomeNumber ))
            
            if self.func then
                self.func()
            end
            
            return
        end
        self:changeTextures(nums)
    end
    self:scheduleUpdateWithPriorityLua(counter,0)
    self.isScheduleUpdate = true

    return true
end

function QNumber:changeTextures(nums)
    --获取纹理
    local tc = cc.Director:getInstance():getTextureCache()
    local texture = tc:getTextureForKey(self.name)
    local size = texture:getContentSize()

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

            self.sprites[i]:setSpriteFrame(spFrame)
                :pos((nums.count - i)  * size.width / 10.0 * self.space,0)
                
            self.sprites[i].num = tempNum
        end
        --居中
    elseif self.align == "center" then
        local initPosX = (nums.count - 1) / 2
        for i = 1,7 do
            local tempNum
            
            if nums[i] == nil then
                tempNum = 0
            else
                tempNum = nums[i]
            end
            
            local spFrame = cc.SpriteFrame:createWithTexture(texture,cc.rect(size.width / 10.0 * tempNum,0,size.width / 10.0,size.height))

            self.sprites[i]:setSpriteFrame(spFrame)
                :pos((initPosX - i + 1) * size.width / 10.0 * self.space,0)
            self.sprites[i].num = tempNum
        end
    end
    
    local tempIndex

    local hideZero = false

    for i = 1, 6 do

        tempIndex = 8 - i 

        if self.sprites[tempIndex] == nil then
        
        elseif self.sprites[tempIndex].num == nil then

            self.sprites[tempIndex]:setVisible(false)

        elseif self.sprites[tempIndex].num == 0 then
            if hideZero == false then
                self.sprites[tempIndex]:setVisible(false)
            else 
                self.sprites[tempIndex]:setVisible(true)
            end
        else 
            hideZero = true
            self.sprites[tempIndex]:setVisible(true)
        end 
    end
end



return QNumber