--[[
	游戏区域
]]
local GameBox = class("GameBox", function (  )
	return display.newNode()
end)

local GameItem = require("app.nodes.GameItem")

function GameBox:ctor()
	-- 数据相关
	self:pos((display.width - ITEM_DISTANCE * COL_COUNT) / 2,(display.width - ITEM_DISTANCE * ROW_COUNT) / 2)

	self.rects = {}

	self.base_data = {}

  self.items = {}

  self.dst_items = {}

  self.selected_items = {}

  self.first_touch = true

  self.base_data[0] = {}

  self.base_data[6] = {}

  	for i=1,ROW_COUNT do
      self.base_data[0][i] = -1
      self.base_data[ROW_COUNT][i] = -1
      self.base_data[i] = {}


      self.base_data[i][0] = -1
      self.base_data[i][COL_COUNT] = -1
  		self.rects[i] = {}

      self.items[i] = {}
  
      self.dst_items[i] = {}

  		for j=1,COL_COUNT do
  			
  			-- 区域块
  			self.rects[i][j] = cc.rect((i - 1) * ITEM_DISTANCE ,(j - 1) * ITEM_DISTANCE,ITEM_DISTANCE,ITEM_DISTANCE)

   			local dst_item = GameItem.new()
   							:pos((i - 0.5) * ITEM_DISTANCE ,(j - 0.5) * ITEM_DISTANCE)
                :hide()
   							:addTo(self)

   			dst_item:setKind(2)
   			dst_item:refresh()

   			-- 设置
        -- self.items[i][j] = item
        self.dst_items[i][j] = dst_item

   			self.base_data[i][j] = 0
  		end
  	end
	--设置所有子节点
  DrawUtil.DrawRect(self,cc.p(0,0), cc.p(ITEM_DISTANCE * ROW_COUNT,ITEM_DISTANCE * COL_COUNT), cc.c4f(1, 0, 0, 1))

end

function GameBox:inSelected(x,y)
  local node_pos_x = x - self:getPositionX()
  local node_pos_y = y - self:getPositionY()

  -- local bRet = false
  local index_x 
  local index_y

  for i,item in ipairs(self.selected_items) do
      index_x = item.index_x
      index_y = item.index_y
      if cc.rectContainsPoint(self.rects[index_x][index_y],cc.p(node_pos_x,node_pos_y)) then
          return true
      end
  end

  return false

end

function GameBox:ended(x,y)
  
  local node_pos_x = x - self:getPositionX()
  local node_pos_y = y - self:getPositionY()

  if self.first_touch == true then

      for i=1,ROW_COUNT do

        for j=1,COL_COUNT do
          if cc.rectContainsPoint(self.rects[i][j],cc.p(node_pos_x,node_pos_y)) then
            self:iter(i,j)
            break
          end
        end
      end

      if table.nums(self.selected_items) <= 1 then
        self:cancelSelected()
        print("began false")
        return false
      else
        print("began true")
        self.first_touch = false
        audio.playSound("res/sound/select.wav",false)
        return true
      end
  else
    local can_clear = self:inSelected(x, y)
    if can_clear == true then
      self:getParent().time = self:getParent().time +  crushCountForTime(table.nums(self.selected_items))

      self:getParent():addCount(table.nums(self.selected_items))

      for i,v in ipairs(self.selected_items) do


        self.base_data[v.index_x][v.index_y] = 0

        self.items[v.index_x][v.index_y] = nil

        v:removeFromParent()


        self.selected_items[i] = nil


        audio.playSound("res/sound/crush.wav",false)
        
      end

      print("crush true")

      self.selected_items = {}

      -- return true

    else

      print("crush false")

      self.first_touch = true

      self:cancelSelected()

      -- return false

    end

  end

end


--  递归
function GameBox:iter(i,j)

  local obj = self.items[i][j]


  if obj ~= nil and not obj.selected and obj.kind == 3 then


      print(i,j)


      obj:setSelected(true)


      TableUtil:push(self.selected_items, obj)


      local cur_type = self.base_data[i][j]

      local up_type = self.base_data[i][j + 1]

      local down_type = self.base_data[i][j - 1]

      local left_type = self.base_data[i - 1][j]

      local right_type = self.base_data[i + 1][j]

      local up_left = self.base_data[i - 1][j + 1]

      local up_right = self.base_data[i + 1][j + 1]

      local down_left = self.base_data[i - 1][j - 1]

      local down_right = self.base_data[i + 1][j - 1]

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

    for i,item in ipairs(self.selected_items) do
    
      -- item.selected = false

      item:setSelected(false)



      self.selected_items[i] = nil

    end

    self.selected_items = {}

    self.first_touch = true

end


function GameBox:canPush(matrix,i,j)
  for x=1,4 do
    for y=1,4 do
      if matrix.matrix_data[x][y] ~= 0 then

        if x + i < ROW_COUNT + 2 and y + j < COL_COUNT + 2 then
          
            local sum = self.base_data[x + i - 1][y + j - 1] + matrix.matrix_data[x][y]
          
            local product = self.base_data[x + i - 1][y + j - 1] * matrix.matrix_data[x][y]

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
        local sum = self.base_data[x + i - 1][y + j - 1] + matrix.matrix_data[x][y]
          local product = self.base_data[x + i - 1][y + j - 1] * matrix.matrix_data[x][y]
            if sum == 3  then
              self.dst_items[i + x - 1][j + y - 1]:setKind(3)
              self.dst_items[i + x - 1][j + y - 1]:complete()
            else
              self.dst_items[i + x - 1][j + y - 1]:setKind(matrix.matrix_data[x][y])
              self.dst_items[i + x - 1][j + y - 1]:half()
              self.dst_items[i + x - 1][j + y - 1]:show()
            end
      end
    end
  end
end

-- 是否可以放置
function GameBox:move1010(matrix)
  local pos_x = matrix:getPositionX()
  local pos_y = matrix:getPositionY()
  local node_pos_x = pos_x - self:getPositionX()
  local node_pos_y = pos_y - self:getPositionY()

  for i=1,ROW_COUNT do
    for j=1,COL_COUNT do
      if cc.rectContainsPoint(self.rects[i][j],cc.p(node_pos_x,node_pos_y)) then
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

  local pos_x = matrix:getPositionX()

  local pos_y = matrix:getPositionY()

  local node_pos_x = pos_x - self:getPositionX()

  local node_pos_y = pos_y - self:getPositionY()

  for i=1,ROW_COUNT do

    for j=1,COL_COUNT do
      
      if cc.rectContainsPoint(self.rects[i][j],cc.p(node_pos_x,node_pos_y)) then

          local can_push = self:canPush(matrix,i,j)

          -- 可以全部放置
          if can_push then

              for x=1,4 do
                for y=1,4 do
                  
                    if matrix.matrix_data[x][y] ~= 0 then
                      
                        local sum = self.base_data[x + i - 1][y + j - 1] + matrix.matrix_data[x][y]
                      
                        local product = self.base_data[x + i - 1][y + j - 1] * matrix.matrix_data[x][y]

                        if sum == 3  then

                            self.items[x + i - 1][y + j - 1]:setKind(3)

                            self.base_data[x + i - 1][y + j - 1] = 3

                        else

                            local item = GameItem.new()
                                          :pos((i + x - 1- 0.5) * ITEM_DISTANCE ,(j  + y - 1 - 0.5) * ITEM_DISTANCE)
                                          :addTo(self)

                            item:setIndex(x + i - 1,y + j - 1)

                            item:setKind(matrix.matrix_data[x][y])

                            self.items[x + i - 1][y + j - 1] = item
                            
                            self.base_data[x + i - 1][y + j - 1] = matrix.matrix_data[x][y]

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
        self.dst_items[i][j]:hide()

        -- print(self.base_data[i][j])
      end
    end
end

return GameBox