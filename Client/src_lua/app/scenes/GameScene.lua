local GameScene = class("GameScene", function ()
	return display.newScene("GameScene")
end)

--[[
    总的场景 职责:管理所有场景中的东西
]]

local GameItem = require("app.nodes.GameItem")
local GameMatrix = require("app.nodes.GameMatrix")
local GameBox = require("app.nodes.GameBox")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

function GameScene:ctor()

    self:initData() -- 初始化数据
    self:setupNodes() -- 设置所有子节点
    self:registerEvent() -- 注册事件

    -- NativeUtil.PreloadFullAd() -- 预加载广告
end

-- 初始化模型数据 
function GameScene:initData()
        -- 初始化数据
    DataManager.InitData()
    DataManager.Load()

    -- 注册
    app.gameModel.scene = self 

    app.gameModel:initModel()

        -- 这个忘了有没有用
    self.touchID = -1
    self.objectCount = 0

    -- 设置方向
    self.direction = DIRECTION_IDLE

    -- 是否已经验证
    self.threeValidated = false 

    local BoxData = require("app.Game.BoxData")

    -- 临时存储的数据
    self.tempBoxData = BoxData.new()

    self.removeItems = {}


end

function GameScene:setupNodes()
    --设置白色背景
    --8 * 16  + 7 , 12 * 16 + 14, 15 * 16 + 15
    cc.LayerColor:create(cc.c4b(255,255,255,255))
                :addTo(self)

    -- 1010 块 唯一一个
    self.matrixNode = GameMatrix.new()
                        :reset()
                        :addTo(self)
    
    self.matrixNode:genNewOne()

    -- 屏幕适配
    -- if cc.PLATFORM_OS_IPAD == targetPlatform then
    --     game_matrix:scale(0.5)
    --     game_matrix:pos(display.cx - 33 * 1.5,display.height - 33 * 5)
    -- end

    -- 游戏区域
    self.gameBox = GameBox.new()
                :addTo(self)


    local GameClock = require("app.nodes.GameClock")

    self.gameClock = GameClock.new()
                :pos(display.cx * 0.6,display.cy * 1.5)
                :addTo(self)

    local ScoreLabel = require("app.nodes.ScoreLabel")

    self.scoreLabel = ScoreLabel.new()
                :pos(display.cx * 0.72,display.cy * 1.7)
                :addTo(self)
end

-- 注册触摸事件
function GameScene:registerEvent()

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return self:onTouchBegan(event.x, event.y)
        elseif event.name == "moved" then
            self:onTouchMoved(event.x, event.y)
        elseif event.name == "ended" then
            self:onTouchEnded(event.x, event.y)
        elseif event.name == "cancel" then
            self.gameBox:cancelSelected()

        end
    end)
        
    self:setTouchSwallowEnabled(false) 
    self:setTouchEnabled(true)
    self:schedule(self.logic, 1.0 / 30.0)
end

function GameScene:onTouchBegan(x, y)
    self.touchBeganX = x
    self.touchBeganY = y
    -- 1010 模式
    if self.matrixNode:inRect(x,y) then
        
        app.gameModel.fsm:HandleEvent("1010")
        self.matrixNode:pos(x - ITEM_DISTANCE * 1.5,y - ITEM_DISTANCE * 0.5)
        self.gameBox:cancelSelected()

    -- 第二次的时候 优先级比较高一些
    elseif self.gameBox:inSelectedItems(x,y)  then 
        -- app.gameModel.fsm:HandleEvent("crush")
    else 
        -- app.gameModel.fsm:HandleEvent("three")

        -- self.gameBox:cancelSelected()
        -- 第二次的时候
        -- if sthen
            -- if self.gameBox.state == CRUSH_IDLE then 
                -- self.gameBox.state = CRUSH_BEGAN1  
            -- end 
        -- else
            -- app.gameModel.fsm:HandleEvent("three")

            -- self.gameBox:cancelSelected()
        -- end
    end

    return true
end


function GameScene:onTouchMoved(x, y)

    if app.gameModel.fsm.mCurState.mName == "1010" then

        self.matrixNode:pos(x - ITEM_DISTANCE * 1.5,y - ITEM_DISTANCE * 0.5)
        self.gameBox:move1010(self.matrixNode)

    elseif app.gameModel.fsm.mCurState.mName == "idle" then
        QPrint("move")
        self.distance = cc.p(x - self.touchBeganX,y - self.touchBeganY)

        if self.direction == DIRECTION_IDLE and cc.pGetDistance(cc.p(x ,y), cc.p(self.touchBeganX, self.touchBeganY)) > 5 then

            if self.distance.x > math.abs(self.distance.y) then
                self.direction = DIRECTION_RIGHT
            end
            if -self.distance.x > math.abs(self.distance.y) then
                self.direction = DIRECTION_LEFT
            end
            if self.distance.y > math.abs(self.distance.x) then
                self.direction = DIRECTION_UP
            end
            if -self.distance.y > math.abs(self.distance.x) then
                self.direction = DIRECTION_DOWN
            end

            app.gameModel.fsm:HandleEvent("three")
        end

    -- -- 在滑动的时候能确定是 小三模式
    elseif app.gameModel.fsm.mCurState.mName == "three" then
        self.distance = cc.p(x - self.touchBeganX,y - self.touchBeganY)
    end
end

function GameScene:onTouchEnded(x, y)

    if app.gameModel.fsm.mCurState.mName == "1010" then
        -- 放下了
        if self.gameBox:push(self.matrixNode) then

            self.matrixNode:genNewOne()
            audio.playSound("res/sound/push.wav", false)
        end

        self.matrixNode:reset() -- 初始化
        app.gameModel.fsm:HandleEvent("idle")
    elseif app.gameModel.fsm.mCurState.mName == "three" then
        if self.distance.x < -ITEM_DISTANCE * 0.5 or self.distance.x > ITEM_DISTANCE * 0.5 or self.distance.y < -ITEM_DISTANCE * 0.5 or self.distance.y > ITEM_DISTANCE * 0.5 then

            local temp = {}

            -- 删除掉
            local index_x = 0
            local index_y = 0
            local item = nil

            for i=1,#self.removeItems do
                item = self.removeItems[i]
                index_x = item.index_x
                index_y = item.index_y

                item:removeFromParent()
                self.removeItems[i] = nil

                self.gameBox.gameItems[index_x][index_y] = nil
            end

            self.removeItems = {}

            local item = nil

            for i=1,ROW_COUNT do
                for j=1,COL_COUNT do
                    item = self.gameBox.gameItems[i][j]
                    if item then
                        item:step(self.direction)  

                        TableUtil:push(temp, item)
                    end    

                    self.gameBox.boxData[i][j] =  self.tempBoxData[i][j]    
                end

                self.gameBox.gameItems[i] = {}
            end

            for i,v in ipairs(temp) do
                self.gameBox.gameItems[v.index_x][v.index_y] = v
            end
        else
            for i=1,ROW_COUNT do
                for j=1,COL_COUNT do
                    item = self.gameBox.gameItems[i][j]
                    if item then
                        item:moveBack()
                    end        
                end
            end
        end
        self.threeValidated = false

        self.direction = DIRECTION_IDLE

        app.gameModel.fsm:HandleEvent("idle")
    elseif app.gameModel.fsm.mCurState.mName == "idle" then
        if self.gameBox:selectItems(x,y) then 
            app.gameModel.fsm:HandleEvent("crush")
        end 
    elseif app.gameModel.fsm.mCurState.mName == "crush" then 
        if self.gameBox:crush(x,y) then 
            app.gameModel.fsm:HandleEvent("idle")
        elseif self.gameBox:selectItems(x,y) then 
        else
            app.gameModel.fsm:HandleEvent("idle")
        end 
    end

    self:crushMatrixObject()
end


-- @private
-- 消除横行和竖行
function GameScene:crushMatrixObject()
    self.row_bricks = {}
    self.col_bricks = {}

    for i=1,ROW_COUNT do
        local tagRow = 0
        local tagCol = 0            
        for j=1,COL_COUNT do
            if self.gameBox.boxData[j][i] == CHILD then
                tagRow = tagRow + 1
            end
        end

        for j=1,COL_COUNT do
            if self.gameBox.boxData[i][j] == CHILD then
                tagCol = tagCol + 1
            end
        end

        if tagRow == ROW_COUNT then
            self.row_bricks[i] = 1
        else 
            self.row_bricks[i] = 0
        end 

        if tagCol == COL_COUNT then
            self.col_bricks[i] = 1
        else
            self.col_bricks[i] = 0
        end
    end

    local line_count = 0

    for i=1,ROW_COUNT do
        for j=1,COL_COUNT do
            if self.col_bricks[i] == 1 or self.row_bricks[j] == 1 then
                local item = self.gameBox.gameItems[i][j]
                if item then
                    line_count = line_count + 1
                    self.gameBox.boxData[i][j] = 0

                    item:removeFromParent()
                    item = nil
                    self.gameBox.gameItems[i][j] = nil
                end
            end
        end
    end

    if lineCountForTime(line_count) ~= 0 then 
        self.gameClock.number:AddNumber(10 - self.gameClock.number:getNumber())
    end 

    line_count = math.modf(line_count / 6)
    self.scoreLabel:AddScore(line_count * 100)

    if line_count ~= 0 then
        self.gameClock:ResetTime()
        audio.playSound("res/sound/crushline.wav", false)
    end
end

--[[
    逻辑 定时器 滑动的处理 游戏数据的处理应该 定义一个Model
]]
function GameScene:logic(dt)
    if app.gameModel.fsm.mCurState.mName == "three" and self.direction ~= DIRECTION_NORMAL then
        if not self.threeValidated then
            self.threeValidated = true

            for rowIndex=1,ROW_COUNT do
                for colIndex=1,COL_COUNT do
                    self.tempBoxData[rowIndex][colIndex] = self.gameBox.boxData[rowIndex][colIndex]
                end
            end

            -- 四种方向 重复的代码太多
            if self.direction == DIRECTION_LEFT then
                for y=1,ROW_COUNT do
                    for x=2,COL_COUNT do
                        local item = self.gameBox.gameItems[x][y]
                        if item then
                            local dst_item = self.gameBox.gameItems[x - 1][y]
                            
                            if self.tempBoxData[x - 1][y] ~= 0 then
                                if dst_item == nil then
                                    self.tempBoxData[x - 1][y] = 0

                                    self.gameBox.boxData[x - 1][y] = 0
                                elseif dst_item.kind + item.kind == 3 then
                                    item.enable_left = true

                                    self.tempBoxData[x][y] = 3

                                    self.tempBoxData[x - 1][y] = self.tempBoxData[x][y]

                                    self.tempBoxData[x][y] = 0

                                    item:become3()

                                    TableUtil:push(self.removeItems, dst_item)

                                else 

                                    item.enable_left = false

                                end

                            else
                                
                                item.enable_left = true

                                self.tempBoxData[x - 1][y] = self.tempBoxData[x][y]

                                self.tempBoxData[x][y] = 0

                            end

                        end
                    end
                end


            elseif  self.direction == DIRECTION_RIGHT then

                for y=1,COL_COUNT do
                    for x=ROW_COUNT - 1,1,-1 do

                        local item = self.gameBox.gameItems[x][y]

                        if item then

                            local dst_item = self.gameBox.gameItems[x + 1][y]
                            
                            if self.tempBoxData[x + 1][y] ~= 0 then

                                if dst_item == nil then

                                    self.tempBoxData[x + 1][y] = 0

                                    self.gameBox.boxData[x + 1][y] = 0

                                elseif dst_item.kind + item.kind == 3 then

                                    item.enable_right = true

                                    self.tempBoxData[x][y] = 3

                                    self.tempBoxData[x + 1][y] = self.tempBoxData[x][y]

                                    self.tempBoxData[x][y] = 0

                                    item:become3()


                                    TableUtil:push(self.removeItems, dst_item)


                                else 

                                    item.enable_right = false

                                end

                            else
                                
                                item.enable_right = true

                                self.tempBoxData[x + 1][y] = self.tempBoxData[x][y]

                                self.tempBoxData[x][y] = 0

                            end

                        end
                    end
                end
            elseif self.direction == DIRECTION_UP then
                for x=1,ROW_COUNT do
                    for y=COL_COUNT - 1,1,-1 do

                        local item = self.gameBox.gameItems[x][y]

                        if item then

                            local dst_item = self.gameBox.gameItems[x][y + 1]
                            
                            if self.tempBoxData[x][y + 1] ~= 0 then

                                if dst_item == nil then

                                    self.tempBoxData[x][y + 1] = 0

                                    self.gameBox.boxData[x][y + 1] = 0

                                elseif dst_item.kind + item.kind == 3 then

                                    item.enable_up = true

                                    self.tempBoxData[x][y] = 3

                                    self.tempBoxData[x][y + 1] = self.tempBoxData[x][y]

                                    self.tempBoxData[x][y] = 0

                                    item:become3()

                                    self.removeItems[#self.removeItems + 1] = dst_item

                                else 

                                    item.enable_up = false

                                end

                            else
                                
                                item.enable_up = true

                                self.tempBoxData[x][y + 1] = self.tempBoxData[x][y]

                                self.tempBoxData[x][y] = 0

                            end

                        end
                    end
                end

            elseif self.direction == DIRECTION_DOWN then
                for x=1,ROW_COUNT do
                    for y=2,COL_COUNT do

                        local item = self.gameBox.gameItems[x][y]

                        if item then

                            local dst_item = self.gameBox.gameItems[x][y - 1]
                            
                            if self.tempBoxData[x][y - 1] ~= 0 then

                                if dst_item == nil then

                                    self.tempBoxData[x][y - 1] = 0

                                    self.gameBox.boxData[x][y - 1] = 0

                                elseif dst_item.kind + item.kind == 3 then

                                    item.enable_down = true

                                    self.tempBoxData[x][y] = 3

                                    self.tempBoxData[x][y - 1] = self.tempBoxData[x][y]

                                    self.tempBoxData[x][y] = 0

                                    item:become3()


                                    TableUtil:push(self.removeItems, dst_item)
                                else 

                                    item.enable_down = false

                                end
                            else
                                item.enable_down = true

                                self.tempBoxData[x][y - 1] = self.tempBoxData[x][y]

                                self.tempBoxData[x][y] = 0
                            end
                        end
                    end
                end
            end

            print("boxData")

            local a = self.gameBox.boxData

            for i=ROW_COUNT,1,-1 do

                print(a[1][i],a[2][i],a[3][i],a[4][i],a[5][i],a[6][i])

            end


            print("temp_data")

            for i=COL_COUNT,1,-1 do

                print(self.tempBoxData[1][i],self.tempBoxData[2][i],self.tempBoxData[3][i],self.tempBoxData[4][i],self.tempBoxData[5][i],self.tempBoxData[6][i])

            end

        end

    end

    if self.threeValidated and self.direction ~= DIRECTION_NORMAL then
        local item = nil
        for i=1,ROW_COUNT do
            for j=1,COL_COUNT do
                item = self.gameBox.gameItems[i][j]
                if item then
                    item:moveThree(self.direction,self.distance)
                end
            end
        end
    end
end

return GameScene