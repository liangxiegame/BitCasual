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
    -- 注册
    app.gameModel.scene = self 

    app.gameModel:initModel()
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
            -- for i=1,8 do
            --     for j=1,8 do
            --         item = self.gameBox.items[i][j]
            --         if item then
            --             item:moveBack()
            --         end        
            --     end
            -- end

            -- self.three_validated = false

            -- self.direction = DIRECTION_NORMAL
        end
    end)
        
    self:setTouchSwallowEnabled(false) 
    self:setTouchEnabled(true)
    self:schedule(self.logic, 1.0 / 10.0)
end

function GameScene:onTouchBegan(x, y)
    self.touchBeganX = x
    self.touchBeganY = y
    -- 1010 模式
    if self.matrixNode:inRect(x,y) then
        
        app.gameModel.fsm:HandleEvent("1010")
        self.matrixNode:pos(x - ITEM_DISTANCE * 1.5,y - ITEM_DISTANCE * 0.5)
        self.gameBox:cancelSelected()
    -- 否则是其他 模式 要确定模式
    else
        if self.gameBox:inSelected(x,y) then

            app.gameModel.fsm:HandleEvent("crush")
        else
            app.gameModel.fsm:HandleEvent("three")

            self.gameBox:cancelSelected()
        end
    end

    return true
end


function GameScene:onTouchMoved(x, y)

    if app.gameModel.fsm.mCurState.mName == "1010" then
        self.matrixNode:pos(x - ITEM_DISTANCE * 1.5,y - ITEM_DISTANCE * 0.5)
        self.gameBox:move1010(self.matrixNode)

    elseif self.model.fsm.mCurState.mName == "idle" or self.model.fsm.mCurState.mName == "crush" then

        self.distance = cc.p(x - self.touch_began_x,y - self.touch_began_y)

        if self.direction == DIRECTION_NORMAL and cc.pGetDistance(cc.p(x ,y), cc.p(self.touchBeganX, self.touchBeganY)) > 5 then
            self.state = GAME_THREE

            local dist_x = x - self.touch_began_x
            local dist_y = y - self.touch_began_y

            if dist_x > math.abs(dist_y) then
                print("right")

                self.direction = DIRECTION_RIGHT
            end

            if -dist_x > math.abs(dist_y) then

                print("left")

                self.direction = DIRECTION_LEFT

            end

            if dist_y > math.abs(dist_x) then

                print("up")

                self.direction = DIRECTION_UP

            end

            if -dist_y > math.abs(dist_x) then

                print("down")

                self.direction = DIRECTION_DOWN
            end

            self.gameBox:cancelSelected()
        end

    -- 在滑动的时候能确定是 小三模式
    elseif self.state ==  GAME_THREE then
        self.distance = cc.p(x - self.touch_began_x,y - self.touch_began_y)
    end
end

function GameScene:crushMatrixObject()
    self.row_bricks = {}
    self.col_bricks = {}
    for i=1,ROW_COUNT do
        local tagRow = 0
        local tagCol = 0            
        for j=1,COL_COUNT do
            if self.gameBox.base_data[j][i] == 3 then
                tagRow = tagRow + 1
            end
        end

        for j=1,COL_COUNT do
            if self.gameBox.base_data[i][j] == 3 then
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
                local brick = self.gameBox.items[i][j]
                if brick then
                    line_count = line_count + 1
                    self.gameBox.base_data[i][j] = 0
                    self.gameBox.items[i][j]:removeFromParent()
                    self.gameBox.items[i][j] = nil
                end
            end
        end
    end

    if lineCountForTime(line_count) ~= 0 then 
        self.gameClock.number:AddNumber(10 - self.gameClock.number:getNumber())
    end 

    self.scoreLabel.number:AddNumber(line_count * 10)

    if line_count ~= 0 then
        self.gameClock:ResetTime()
        audio.playSound("res/sound/crushline.wav", false)
    end
end

function GameScene:onTouchEnded(x, y)

    if app.gameModel.fsm.mCurState.mName == "1010" then

        if self.gameBox:push(self.matrixNode) then

            self.matrixNode:genNewOne()
            audio.playSound("res/sound/push.wav", false)
        end

        self.matrixNode:reset()

    -- if cc.PLATFORM_OS_IPAD == targetPlatform then
    --     self.cur_matrix:scale(0.5)
    --     self.cur_matrix:pos(display.cx - ITEM_DISTANCE * 1.5,display.height - ITEM_DISTANCE * 5)
    -- end        

        app.gameModel.fsm:HandleEvent("idle")

    elseif self.state == GAME_THREE then
        self.state =GAME_IDLE 
        if self.distance.x < -ITEM_DISTANCE * 0.5 or self.distance.x > ITEM_DISTANCE * 0.5 or self.distance.y < -ITEM_DISTANCE * 0.5 or self.distance.y > ITEM_DISTANCE * 0.5 then

            local temp = {}

            -- 删除掉
            local index_x = 0
            local index_y = 0
            local item = nil

            for i=1,table.nums(self.remove_items) do
                item = self.remove_items[i]
                index_x = item.index_x
                index_y = item.index_y

                item:removeFromParent()
                self.remove_items[i] = nil

                self.gameBox.items[index_x][index_y] = nil
            end

            self.remove_items = {}

            local item = nil

            for i=1,ROW_COUNT do

                for j=1,COL_COUNT do
                    
                    item = self.gameBox.items[i][j]

                    if item then
                        
                        item:step(self.direction)  

                        TableUtil:push(temp, item)

                    end    

                    self.gameBox.base_data[i][j] =  self.temp_data[i][j]    

                end

                self.gameBox.items[i] = {}
            end

            for i,v in ipairs(temp) do

                self.gameBox.items[v.index_x][v.index_y] = v

            end

        else
            for i=1,8 do
                for j=1,8 do
                    item = self.gameBox.items[i][j]

                    if item then
                        item:moveBack()
                    end        
                end
            end
        end
            --todo
        self.three_validated = false

        self.direction = DIRECTION_NORMAL
    else
        -- print("···")
        -- print("------------------------")
        -- print("first touch",self.gameBox.first_touch)

        self.gameBox:ended(x, y)

        -- print("first touch",self.gameBox.first_touch)
        -- print("------------------------")
    end

    self:crushMatrixObject()
end

--[[
    逻辑 定时器 滑动的处理 游戏数据的处理应该 定义一个Model
]]
function GameScene:logic(dt)
    if self.state == GAME_THREE and self.direction ~= DIRECTION_NORMAL then
        if not self.three_validated then
            self.three_validated = true

            for i=1,ROW_COUNT do
                for j=1,COL_COUNT do
                    self.temp_data[i][j] = self.gameBox.base_data[i][j]
                end
            end

            -- 四种方向 重复的代码太多
            if self.direction == DIRECTION_LEFT then
                for y=1,ROW_COUNT do
                    for x=2,COL_COUNT do
                        local item = self.gameBox.items[x][y]
                        if item then

                            local dst_item = self.gameBox.items[x - 1][y]
                            
                            if self.temp_data[x - 1][y] ~= 0 then

                                if dst_item == nil then

                                    self.temp_data[x - 1][y] = 0

                                    self.gameBox.base_data[x - 1][y] = 0

                                elseif dst_item.kind + item.kind == 3 then

                                    item.enable_left = true

                                    self.temp_data[x][y] = 3

                                    self.temp_data[x - 1][y] = self.temp_data[x][y]

                                    self.temp_data[x][y] = 0

                                    item:become3()

                                    TableUtil:push(self.remove_items, dst_item)

                                else 

                                    item.enable_left = false

                                end

                            else
                                
                                item.enable_left = true

                                self.temp_data[x - 1][y] = self.temp_data[x][y]

                                self.temp_data[x][y] = 0

                            end

                        end
                    end
                end


            elseif  self.direction == DIRECTION_RIGHT then

                for y=1,COL_COUNT do
                    for x=ROW_COUNT - 1,1,-1 do

                        local item = self.gameBox.items[x][y]

                        if item then

                            local dst_item = self.gameBox.items[x + 1][y]
                            
                            if self.temp_data[x + 1][y] ~= 0 then

                                if dst_item == nil then

                                    self.temp_data[x + 1][y] = 0

                                    self.gameBox.base_data[x + 1][y] = 0

                                elseif dst_item.kind + item.kind == 3 then

                                    item.enable_right = true

                                    self.temp_data[x][y] = 3

                                    self.temp_data[x + 1][y] = self.temp_data[x][y]

                                    self.temp_data[x][y] = 0

                                    item:become3()


                                    TableUtil:push(self.remove_items, dst_item)


                                else 

                                    item.enable_right = false

                                end

                            else
                                
                                item.enable_right = true

                                self.temp_data[x + 1][y] = self.temp_data[x][y]

                                self.temp_data[x][y] = 0

                            end

                        end
                    end
                end
            elseif self.direction == DIRECTION_UP then
                for x=1,ROW_COUNT do
                    for y=COL_COUNT,1,-1 do

                        local item = self.gameBox.items[x][y]

                        if item then

                            local dst_item = self.gameBox.items[x][y + 1]
                            
                            if self.temp_data[x][y + 1] ~= 0 then

                                if dst_item == nil then

                                    self.temp_data[x][y + 1] = 0

                                    self.gameBox.base_data[x][y + 1] = 0

                                elseif dst_item.kind + item.kind == 3 then

                                    item.enable_up = true

                                    self.temp_data[x][y] = 3

                                    self.temp_data[x][y + 1] = self.temp_data[x][y]

                                    self.temp_data[x][y] = 0

                                    item:become3()


                                    TableUtil:push(self.remove_items, dst_item)


                                else 

                                    item.enable_up = false

                                end

                            else
                                
                                item.enable_up = true

                                self.temp_data[x][y + 1] = self.temp_data[x][y]

                                self.temp_data[x][y] = 0

                            end

                        end
                    end
                end

            elseif self.direction == DIRECTION_DOWN then
                for x=1,ROW_COUNT do
                    for y=2,COL_COUNT do

                        local item = self.gameBox.items[x][y]

                        if item then

                            local dst_item = self.gameBox.items[x][y - 1]
                            
                            if self.temp_data[x][y - 1] ~= 0 then

                                if dst_item == nil then

                                    self.temp_data[x][y - 1] = 0

                                    self.gameBox.base_data[x][y - 1] = 0

                                elseif dst_item.kind + item.kind == 3 then

                                    item.enable_down = true

                                    self.temp_data[x][y] = 3

                                    self.temp_data[x][y - 1] = self.temp_data[x][y]

                                    self.temp_data[x][y] = 0

                                    item:become3()


                                    TableUtil:push(self.remove_items, dst_item)


                                else 

                                    item.enable_down = false

                                end

                            else
                                
                                item.enable_down = true

                                self.temp_data[x][y - 1] = self.temp_data[x][y]

                                self.temp_data[x][y] = 0

                            end

                        end
                    end
                end
            end

            print("base_data")

            local a = self.gameBox.base_data

            for i=ROW_COUNT,1,-1 do

                print(a[1][i],a[2][i],a[3][i],a[4][i],a[5][i],a[6][i])

            end


            print("temp_data")

            for i=COL_COUNT,1,-1 do

                print(self.temp_data[1][i],self.temp_data[2][i],self.temp_data[3][i],self.temp_data[4][i],self.temp_data[5][i],self.temp_data[6][i])

            end

        end

    end

    if self.three_validated and self.direction ~= DIRECTION_NORMAL then
        local item = nil
        for i=1,ROW_COUNT do
            for j=1,COL_COUNT do
                item = self.gameBox.items[i][j]
                if item then
                    item:moveThree(self.direction,self.distance)
                end
            end
        end
    end
end

return GameScene