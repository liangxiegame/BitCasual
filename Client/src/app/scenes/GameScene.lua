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

    -- 平台区分 用来加第三方平台的
     if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
        local args = { num1 = 2 , num2 = 3 }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "LuaObjectCBridgeTest"
        -- local ok,ret  = luaoc.callStaticMethod(className,"isFullLoadedOC")
        -- local ok,ret  = luaoc.callStaticMethod(className,"isFullLoadedOC",args)
        -- if not ok then
            -- cc.Director:getInstance():resume()
        -- else
            -- print("The ret is:", ret)
        -- end
            luaoc.callStaticMethod(className,"loadFullOC")

            local function callback(param)
            if "success" == param then
                print("object c call back success")
            end
        end

        luaoc.callStaticMethod(className,"registerScriptHandler", {scriptHandler = callback } )
        luaoc.callStaticMethod(className,"callbackScriptHandler")
    end
end

-- 初始化数据
function GameScene:initData()

    self.touch_id = -1
    self.remain_step = 100
    self.object_count = 0
    self.result_step = 0

    self.state = GAME_IDLE -- 设置游戏为默认状态
    self.direction = DIRECTION_NORMAL
    self.three_validated = false
    self.remove_items = {}
    self.temp_data = {}

    for i=1,ROW_COUNT do
        self.temp_data[i] = {}
        for j=1,COL_COUNT do
            self.temp_data[i][j] = 0
        end
    end
end

function GameScene:setupNodes()
    --设置白色背景
    --8 * 16  + 7 , 12 * 16 + 14, 15 * 16 + 15
    local colorWhite = cc.LayerColor:create(cc.c4b(255,255,255,255))
                        :addTo(self)

    -- 测试组快
    local game_matrix = GameMatrix.new()
                        :pos(display.width - ITEM_DISTANCE * 1.5,display.height - ITEM_DISTANCE * 5)
                        :addTo(self)

    if cc.PLATFORM_OS_IPAD == targetPlatform then
        game_matrix:scale(0.5)
        game_matrix:pos(display.cx - 33 * 1.5,display.height - 33 * 5)
    end

    game_matrix:setName("matrix")
    math.newrandomseed()
    game_matrix:setTypeAndDirection(math.random(#matrices),2)
    game_matrix:refresh()

    self.game_box = GameBox.new()
                :addTo(self)

    -- 时间 to do 要改成QNumber
    self.time_label = cc.Label:createWithSystemFont("60.00","Arial",40)
                    :pos(display.cx * 1.5,display.height - 30)
                    :addTo(self)
    self.time = 60

    self.time_label:setColor(display.COLOR_BLACK)

    -- 定时的东西 要分给定时器来
    local speed = 0.05
    local schedule_id
    local last_int_part = 59
    local cur_int_part = 60

    local function tick()
        speed = speed * 1.001
        if speed >= 0.15 then
            speed = 0.15
        end

        self.time = self.time - speed
        local cur_int_part = math.modf(self.time)

        if cur_int_part - last_int_part > 1.1 then
            last_int_part = cur_int_part
        end

        if last_int_part > cur_int_part then
            last_int_part = cur_int_part

            audio.playSound("res/sound/tick.wav", false)
        end

        self.time_label:setString(string.format("%.2f", self.time))

        if self.time <= 0.1 then
            local high_score = cc.UserDefault:getInstance():getIntegerForKey("highscore")

            if high_score ~= nil and self.count > high_score then
                cc.UserDefault:getInstance():setIntegerForKey("highscore", self.count)
            end

            cc.UserDefault:getInstance():setIntegerForKey("score", self.count)
            cc.UserDefault:getInstance():flush()

            app:enterScene("GameOver")
        end
    end

    schedule_id = self:schedule(tick, 0.1)

    self.count_label = cc.Label:createWithSystemFont("score:0","Arial",40)
                    :pos(display.cx * 0.5,display.height - 30)
                    :addTo(self)

    self.count_label:setColor(display.COLOR_BLACK)

    self.count = 0
end


-- 增加分数
function GameScene:addCount(count)
    self.count = self.count + count

    self.count_label:setString(string.format("score:%d", self.count))
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
            self.game_box:cancelSelected()
            for i=1,8 do
                for j=1,8 do
                    item = self.game_box.items[i][j]
                    if item then
                        item:moveBack()
                    end        
                end
            end

            self.three_validated = false

            self.direction = DIRECTION_NORMAL
        end

        return bRet

    end)
        
    self:setTouchSwallowEnabled(false) 
    self:setTouchEnabled(true)
    self:schedule(self.logic, 1.0 / 60.0)
end

function GameScene:onTouchBegan(x, y)
    local game_matrix = self:getChildByName("matrix")
            -- 获取初始坐标
    self.began_pos_x = game_matrix:getPositionX()
    self.began_pos_y = game_matrix:getPositionY()
    self.touch_began_x = x
    self.touch_began_y = y

    -- 1010 模式
    if game_matrix:inRect(x,y) then
        self.delta_x = x - self.began_pos_x
        self.delta_y = y - self.began_pos_y

        self.cur_matrix = game_matrix

        self.cur_matrix:scale(1.0)
        
        self.state = GAME_1010

        self.game_box:cancelSelected()

        print(1010)

        audio.playSound("res/sound/push.wav", false)

    -- 否则是其他 模式 要确定模式
    else
        if self.game_box:inSelected(x,y) then
            self.state = GAME_CRUSH
        else
            self.state = GAME_IDLE 

            self.game_box:cancelSelected()
        end
    end

    return true
end


function GameScene:onTouchMoved(x, y)
    if self.state == GAME_1010 then

        self.cur_matrix:pos(x - self.delta_x,y - self.delta_y)
        self.game_box:move1010(self.cur_matrix)

    elseif self.state == GAME_IDLE or self.state == GAME_CRUSH then
        self.distance = cc.p(x - self.touch_began_x,y - self.touch_began_y)

        if self.direction == DIRECTION_NORMAL and cc.pGetDistance(cc.p(x ,y), cc.p(self.touch_began_x, self.touch_began_y)) > 5 then
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

            self.game_box:cancelSelected()
        end

    -- 在滑动的时候能确定是 小三模式
    elseif self.state ==  GAME_THREE then
        self.distance = cc.p(x - self.touch_began_x,y - self.touch_began_y)
    end
end

function GameScene:crushMatrixObject()
    self.row_bricks = {}
    self.col_bricks = {}
    for i=1,8 do
        local tagRow = 0
        local tagCol = 0            
        for j=1,8 do
            if self.game_box.base_data[j][i] == 3 then
                tagRow = tagRow + 1
            end
        end

        for j=1,8 do
            if self.game_box.base_data[i][j] == 3 then
                tagCol = tagCol + 1
            end
        end

        if tagRow == 8 then
            self.row_bricks[i] = 1
        else 
            self.row_bricks[i] = 0
        end 

        if tagCol == 8 then
            self.col_bricks[i] = 1
        else
            self.col_bricks[i] = 0
        end
    end

    local line_count = 0

    for i=1,8 do
        for j=1,8 do
            if self.col_bricks[i] == 1 or self.row_bricks[j] == 1 then
                local brick = self.game_box.items[i][j]
                if brick then
                    line_count = line_count + 1
                    self.game_box.base_data[i][j] = 0
                    self.game_box.items[i][j]:removeFromParent()
                    self.game_box.items[i][j] = nil
                end
            end
        end
    end

    self.time = self.time + lineCountForTime(line_count)
    self:addCount(line_count * 10)
    self.row_bricks = {}
    self.col_bricks = {}

    if line_count ~= 0 then
        audio.playSound("res/sound/crushline.wav", false)
    end
end

function GameScene:onTouchEnded(x, y)
    if self.state == GAME_1010 then
        if self.game_box:push(self.cur_matrix) then
            self.cur_matrix:genNewOne()

            audio.playSound("res/sound/push.wav", false)
        end
        self.cur_matrix:pos(display.cx - 66 * 1.5,display.height - 66 * 5)

    if cc.PLATFORM_OS_IPAD == targetPlatform then
        self.cur_matrix:scale(0.5)
        self.cur_matrix:pos(display.cx - 33 * 1.5,display.height - 33 * 5)
    end
        self.cur_matrix = nil
        self.state =GAME_IDLE 
    elseif self.state == GAME_THREE then
        self.state =GAME_IDLE 
        if self.distance.x < -66 * 0.5 or self.distance.x > 66 * 0.5 or self.distance.y < -66 * 0.5 or self.distance.y > 66 * 0.5 then

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

                self.game_box.items[index_x][index_y] = nil
            end

            self.remove_items = {}

            local item = nil

            for i=1,8 do

                for j=1,8 do
                    
                    item = self.game_box.items[i][j]

                    if item then
                        
                        item:step(self.direction)  

                        TableUtil:push(temp, item)

                    end    

                    self.game_box.base_data[i][j] =  self.temp_data[i][j]    

                end

                self.game_box.items[i] = {}
            end

            for i,v in ipairs(temp) do

                self.game_box.items[v.index_x][v.index_y] = v

            end

        else
            for i=1,8 do
                for j=1,8 do
                    item = self.game_box.items[i][j]

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
        -- print("first touch",self.game_box.first_touch)

        self.game_box:ended(x, y)

        -- print("first touch",self.game_box.first_touch)
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

            for i=1,8 do
                for j=1,8 do
                    self.temp_data[i][j] = self.game_box.base_data[i][j]
                end
            end

            -- 四种方向 重复的代码太多
            if self.direction == DIRECTION_LEFT then
                for y=1,8 do
                    for x=2,8 do
                        local item = self.game_box.items[x][y]
                        if item then

                            local dst_item = self.game_box.items[x - 1][y]
                            
                            if self.temp_data[x - 1][y] ~= 0 then

                                if dst_item == nil then

                                    self.temp_data[x - 1][y] = 0

                                    self.game_box.base_data[x - 1][y] = 0

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

                for y=1,8 do
                    for x=7,1,-1 do

                        local item = self.game_box.items[x][y]

                        if item then

                            local dst_item = self.game_box.items[x + 1][y]
                            
                            if self.temp_data[x + 1][y] ~= 0 then

                                if dst_item == nil then

                                    self.temp_data[x + 1][y] = 0

                                    self.game_box.base_data[x + 1][y] = 0

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
                for x=1,8 do
                    for y=7,1,-1 do

                        local item = self.game_box.items[x][y]

                        if item then

                            local dst_item = self.game_box.items[x][y + 1]
                            
                            if self.temp_data[x][y + 1] ~= 0 then

                                if dst_item == nil then

                                    self.temp_data[x][y + 1] = 0

                                    self.game_box.base_data[x][y + 1] = 0

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
                for x=1,8 do
                    for y=2,8 do

                        local item = self.game_box.items[x][y]

                        if item then

                            local dst_item = self.game_box.items[x][y - 1]
                            
                            if self.temp_data[x][y - 1] ~= 0 then

                                if dst_item == nil then

                                    self.temp_data[x][y - 1] = 0

                                    self.game_box.base_data[x][y - 1] = 0

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

            local a = self.game_box.base_data

            for i=8,1,-1 do

                print(a[1][i],a[2][i],a[3][i],a[4][i],a[5][i],a[6][i],a[7][i],a[8][i])

            end


            print("temp_data")

            for i=8,1,-1 do

                print(self.temp_data[1][i],self.temp_data[2][i],self.temp_data[3][i],self.temp_data[4][i],self.temp_data[5][i],self.temp_data[6][i],self.temp_data[7][i],self.temp_data[8][i])

            end

        end

    end

    if self.three_validated and self.direction ~= DIRECTION_NORMAL then
        local item = nil
        for i=1,8 do
            for j=1,8 do
                item = self.game_box.items[i][j]
                if item then
                    item:moveThree(self.direction,self.distance)
                end
            end
        end
    end
end

return GameScene