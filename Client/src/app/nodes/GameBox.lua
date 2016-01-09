--[[
	游戏区域
]]
local GameBox = class("GameBox", function (  )
	return display.newNode()
end)

local GameItem = require("app.nodes.GameItem")

function GameBox:ctor()
  self:initData()

  DrawUtil.DrawRect(self,cc.p(0,0), cc.p(ITEM_DISTANCE * ROW_COUNT,ITEM_DISTANCE * COL_COUNT), cc.c4f(1, 0, 0, 1))
end

-- 初始化数据
function GameBox:initData()
    -- 数据相关
  self:pos((display.width - ITEM_DISTANCE * COL_COUNT) / 2,(display.width - ITEM_DISTANCE * ROW_COUNT) / 2)

  -- 矩阵块 这个应该不需要以后 to do 改成直接计算就ok了 整除计算 获取坐标
  self.rects = {}

  local BoxData = require("app.Game.BoxData")

  self.boxData = BoxData.new()
  self.hitItems = {}
  self.gameItems = {}
  self.selectedItems = {}

  self.first_touch = true         -- 第一次触摸?

  -- 初始化区域块、游戏项
  for rowIndex = 1,ROW_COUNT do 
    self.rects[rowIndex] = {}
    self.hitItems[rowIndex] = {}

    for colIndex = 1,COL_COUNT do 

      -- 计算区域的块
      self.rects[rowIndex][colIndex] = cc.rect((rowIndex - 1) * ITEM_DISTANCE ,(colIndex - 1) * ITEM_DISTANCE,ITEM_DISTANCE,ITEM_DISTANCE)

        local item = GameItem.new()
                :pos((rowIndex - 0.5) * ITEM_DISTANCE ,(colIndex - 0.5) * ITEM_DISTANCE)
                :hide()
                :addTo(self)

        item:setKind(2)
        item:refresh()

        self.hitItems[rowIndex][colIndex] = item
    end 
  end 

  self.state = CRUSH_IDLE
end


-- @public
-- 是否按到item
function GameBox:inSelectedItems(x,y)
  local nodePosX = x - self:getPositionX()
  local nodePosY = y - self:getPositionY()

  -- local bRet = false
  local indexX 
  local indexY

  -- 是选择的items
  for i = 1,#self.selectedItems do 
      indexX = self.selectedItems[i].index_x
      indexY = self.selectedItems[i].index_y
      if cc.rectContainsPoint(self.rects[indexX][indexY],cc.p(nodePosX,nodePosY)) then
          return true
      end
  end 

  return false
end

-- @public 
-- 第一次ended 则选定items
function GameBox:selectItems(x,y)
  local nodePosX = x - self:getPositionX()
  local nodePosY = y - self:getPositionY()

  for rowIndex = 1,ROW_COUNT do 
    for colIndex = 1,COL_COUNT do 
      if cc.rectContainsPoint(self.rects[rowIndex][colIndex],cc.p(nodePosX,nodePosY)) then
        self:iter(rowIndex,colIndex)
        break
      end
    end 
  end 

  if #self.selectedItems <= 1 then 
    self:cancelSelected()
    return false 
  else 
    audio.playSound("res/sound/select.wav",false)
    return true
  end 
end

-- @public 
-- 第二次ended 则crush 或者取消
function GameBox:crush(x,y)
  if self:inSelectedItems(x,y) then 

    local item = nil

    for i = 1,#self.selectedItems do 
      item = self.selectedItems[i]
      item:setSelected(false)
      self.boxData[item.index_x][item.index_y] = 0

      table.removebyvalue(self.gameItems , item, true)

      item:hide()
      item:stopAllActions()
      item:rotation(0)

      audio.playSound("res/sound/crush.wav",false)

    end

    self:getParent().gameClock.number:AddNumber(20 - self:getParent().gameClock.number:getNumber())

    self:getParent().scoreLabel:AddScore((#self.selectedItems - 2) * 2 + 2)

    self.selectedItems = {}

    return true 

  else 
    self:cancelSelected()
    return false 
  end 
end



--  递归
function GameBox:iter(i,j)

  local obj = self.hitItems[i][j]

  if obj ~= nil and not obj.selected and obj.kind == CHILD then

      print(i,j)

      obj:setSelected(true)

      -- TableUtil:push(self.selectedItems, obj)
      self.selectedItems[#self.selectedItems + 1] = obj 

      local cur_type = self.boxData[i][j]

      local right_type 
      local up_right
      local down_right

      if self.boxData[i + 1] then 
        right_type = self.boxData[i + 1][j]
        up_right = self.boxData[i + 1][j + 1]
        down_right = self.boxData[i + 1][j - 1]
      end 

      local left_type
      local up_left
      local down_left

      if self.boxData[i - 1] then 
        left_type = self.boxData[i - 1][j]
        up_left = self.boxData[i - 1][j + 1]
        down_left = self.boxData[i - 1][j - 1]
      end 
      
      local up_type = self.boxData[i][j + 1]
      local down_type = self.boxData[i][j - 1]

      if cur_type == up_type then
        self:iter(i,j + 1)
      end

      if cur_type == down_type then
         self:iter(i, j - 1)
      end

      if cur_type == left_type then
         self:iter(i - 1,j)
      end

      if cur_type == right_type then
         self:iter(i + 1,j)
      end

      if cur_type == up_left then
         self:iter(i - 1,j + 1)
      end

      if cur_type == up_right then
         self:iter(i + 1,j+1)
      end

      if cur_type == down_left then
         self:iter(i - 1,j - 1)
      end

      if cur_type == down_right then
         self:iter(i + 1,j - 1)
      end
  end  
end


function GameBox:cancelSelected()

    for i,item in ipairs(self.selectedItems) do
    
      -- item.selected = false

      item:setSelected(false)

      self.selectedItems[i] = nil

    end

    self.selectedItems = {}

    self.first_touch = true

end


function GameBox:canPush(matrix,i,j)
  for x=1,4 do
    for y=1,4 do
      if matrix.matrix_data[x][y] ~= 0 then
        if x + i < ROW_COUNT + 2 and y + j < COL_COUNT + 2 then
            local sum = self.boxData[x + i - 1][y + j - 1] + matrix.matrix_data[x][y]
            local product = self.boxData[x + i - 1][y + j - 1] * matrix.matrix_data[x][y]
            if sum ~= 3 and product ~= 0 then
              return false
            end
        else
          return false
        end
      end
    end
  end

  return true
end


function GameBox:willPush( matrix,i,j )
  self:hideDST()

  for x=1,4 do
    for y=1,4 do
      if matrix.matrix_data[x][y] ~= 0 then
        local sum = self.boxData[x + i - 1][y + j - 1] + matrix.matrix_data[x][y]
          local product = self.boxData[x + i - 1][y + j - 1] * matrix.matrix_data[x][y]
            if sum == 3  then
              self.hitItems[i + x - 1][j + y - 1]:setKind(3)
              self.hitItems[i + x - 1][j + y - 1]:complete()
            else
              self.hitItems[i + x - 1][j + y - 1]:setKind(matrix.matrix_data[x][y])
              self.hitItems[i + x - 1][j + y - 1]:half()
              self.hitItems[i + x - 1][j + y - 1]:show()
            end
      end
    end
  end
end

-- 是否可以放置
function GameBox:move1010(matrix)
  local matrixPosX = matrix:getPositionX()
  local matrixPosY = matrix:getPositionY()
  local nodePosX = matrixPosX - self:getPositionX()
  local nodePosY = matrixPosY - self:getPositionY()

  for i=1,ROW_COUNT do
    for j=1,COL_COUNT do
      if cc.rectContainsPoint(self.rects[i][j],cc.p(nodePosX,nodePosY)) then
          local can_push = self:canPush(matrix,i,j)
          -- 可以全部放置
          if can_push then
            
            self:willPush(matrix,i,j)
            return 
          end
      end
    end
  end
end


-- 放置
function GameBox:push( matrix )

  local nodePosX = matrix:getPositionX() - self:getPositionX()

  local nodePosY = matrix:getPositionY() - self:getPositionY()

  for i=1,ROW_COUNT do
    for j=1,COL_COUNT do
      if cc.rectContainsPoint(self.rects[i][j],cc.p(nodePosX,nodePosY)) then
          -- 可以全部放置
          if self:canPush(matrix,i,j) then
              for x=1,4 do
                for y=1,4 do
                  
                    if matrix.matrix_data[x][y] ~= 0 then
                      
                        local sum = self.boxData[x + i - 1][y + j - 1] + matrix.matrix_data[x][y]
                      
                        local product = self.boxData[x + i - 1][y + j - 1] * matrix.matrix_data[x][y]

                        if sum == 3  then

                            self.hitItems[x + i - 1][y + j - 1]:setKind(3)

                            self.boxData[x + i - 1][y + j - 1] = 3

                        else
                            self.hitItems[x + i - 1][y + j - 1]:setIndex(x + i - 1,y + j - 1)
                            self.hitItems[x + i - 1][y + j - 1]:setKind(matrix.matrix_data[x][y])
                            
                            self.boxData[x + i - 1][y + j - 1] = matrix.matrix_data[x][y]
                            self.gameItems[#self.gameItems + 1] = self.hitItems[x + i - 1][y + j - 1]
 
                        end

                     end                    

                  end

                end

              self:hideDST()

              return true

              end
            
            end
          end
      end
    self:hideDST()
    return false
end

function GameBox:hideDST()
    for i=1,ROW_COUNT do
      for j=1,COL_COUNT do
        self.hitItems[i][j]:hide()
        self.hitItems[i][j]:setKind(self.boxData[i][j])
      end
    end

    for i = 1,#self.gameItems do 
      self.gameItems[i]:complete()

      self.gameItems[i]:show()
    end 
end

return GameBox