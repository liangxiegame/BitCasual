local GameMatrix = class("GameMatrix",function (  )
	return display.newNode()
end)

local GameItem = require("app.nodes.GameItem")

function GameMatrix:ctor()
	self:initData()

	self:setupNodes()
	-- self:setContentSize(cc.size(ITEM_DISTANCE * 4,ITEM_DISTANCE * 4))
end

function GameMatrix:initData()
	self.direction = -1
	self.type = -1
	self.items = {}
	self.matrix_data = {}

	for i=1,4 do
		self.matrix_data[i] = {}
	end
end

function GameMatrix:setupNodes()
   
   DrawUtil.DrawRect(self, cc.p(0,0), cc.p(ITEM_DISTANCE * 3,ITEM_DISTANCE * 3), cc.c4f(1, 0, 0, 1))

    for i=1,4 do
    	self.items[i] = {}
    	for j=1,4 do
    		local item = GameItem.new()
    					:pos(ITEM_DISTANCE * (i - 1), ITEM_DISTANCE * (j - 1))
    					:addTo(self)
    		item:setIndex(i,j)
    		self.items[i][j] = item
    	end
    end
end

-- 设置方向和类型
function GameMatrix:setTypeAndDirection(kind,direction)
	self.kind = kind
	self.direction = direction
end

-- 刷新
function GameMatrix:refresh()
	-- 交替出现种类
	if self.item_type == 1 then 
		self.item_type = 2 
	else 
		self.item_type = 1 
	end 

	local count = 0

	for i=1,4 do
		for j=1,4 do
			QPrint(i,j,self.kind,self.direction)
			if matrices[self.kind][self.direction][i][j] ~= 0 then

				self.matrix_data[i][j] = self.item_type
				-- if count < seg1 then
				-- 	self.matrix_data[i][j] = random1
				-- elseif count < seg2 then
				-- 	self.matrix_data[i][j] = random2
				-- else
				-- 	self.matrix_data[i][j] = random3
				-- end 

				count = count + 1

				self.items[i][j]:setKind(self.matrix_data[i][j])
				self.items[i][j]:refresh()
				self.items[i][j]:show()
			else
				self.matrix_data[i][j] = 0

				self.items[i][j]:hide()
			end
		end
	end
end

function GameMatrix:reset()
	self:posCenter(display.cx * 1.5 , display.cy)
	self:scale(0.5)
	return self
end

function GameMatrix:posCenter(x,y)
	self:pos(-ITEM_DISTANCE * 1.5 + x,ITEM_DISTANCE * 1.5 + y)
	return self 
end

function GameMatrix:genNewOne()
	local kind = math.random(#matrices)
    local direction = math.random(4)

   	QPrint("kind:",kind,"direction:",direction) 
    self:setTypeAndDirection(kind, direction);
    self:refresh();
end

function GameMatrix:inRect(x,y)
	local pos_x = self:getPositionX()
	local pos_y = self:getPositionY()

	local origin_x = -ITEM_DISTANCE * 0.5 + pos_x
	local origin_y = -ITEM_DISTANCE * 0.5 + pos_y

	local size = cc.size(ITEM_DISTANCE * 4, ITEM_DISTANCE * 4)
	local rect = cc.rect(origin_x, origin_y, size.width, size.height)

	-- local drawNode4 = cc.NVGDrawNode:create()
 --   	self:addChild(drawNode4)
 --   	drawNode4:drawRect(cc.p(-ITEM_DISTANCE * 0.5, -ITEM_DISTANCE * 0.5), cc.p(size.width,size.height), cc.c4f(1, 0, 0, 1))

	return cc.rectContainsPoint(rect, cc.p(x,y))
end

return GameMatrix