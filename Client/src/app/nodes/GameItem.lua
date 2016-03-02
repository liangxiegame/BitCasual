local GameItem = class("GameItem", function (  )
	return display.newNode()
end)

-- 
function GameItem:ctor()
	self:initData()

	self:setupNodes()

	self:setScale(0.95)
end

function GameItem:initData()

end

function GameItem:setupNodes()
	self.sprite_a = display.newSprite(display.newSpriteFrame("boy100.png"))
					:hide()
					:addTo(self)

	self.sprite_b = display.newSprite(display.newSpriteFrame("girl100.png"))
					:hide()
					:addTo(self)

	self.sprite_c = display.newSprite(display.newSpriteFrame("child100.png"))
					:hide()
					:addTo(self)
	-- if device.platform == "mac" then

	-- else

		-- self.berlin_c = my.QBerlinSprite:create()
		-- 				:hide()
		-- 				:addTo(self)

		-- self.berlin_c:setSpriteFrame(display.newSpriteFrame("child100.png"))
		-- self.berlin_c:setShaders("res/shader/noise.vsh","res/shader/noise.fsh")
		-- self.berlin_c:setNoiseTexture(ImageUtil:textureForFile("res/shader/noise.png"))

		-- math.newrandomseed()
		-- local tick_count = math.random(10) * 0.01

		-- local function tick(dt)
		-- 	tick_count = tick_count + 0.05

		-- 	if tick_count >= 3.141592653 * 2 then
		-- 		tick_count = 0.0
		-- 	end
		-- 	-- self.berlin_a:setUniformTime(tick_count)

		-- 	-- self.berlin_b:setUniformTime(tick_count)
		-- 	self.berlin_c:setUniformTime(tick_count)
		-- end

		-- self:schedule(tick, 1.0 / 30)
	-- end
end

function GameItem:setIndex( i,j )
	self.index_x = i

	self.index_y = j
end

function GameItem:setKind( kind )

	if self.kind == kind  then return end

	self.kind = kind

	if self.kind == BOY then
		self.sprite_a:show()
		self.sprite_b:hide()
		self.sprite_c:hide()
	elseif self.kind == GIRL then
		self.sprite_a:hide()
		self.sprite_b:show()
		self.sprite_c:hide()
	elseif self.kind == CHILD then
		self.sprite_a:hide()
		self.sprite_b:hide()
		self.sprite_c:show()
	end
end

function GameItem:become3()
	self.m_become3 = true
end


function GameItem:setSelected(value)

	self.selected = value

	-- if device.platform == "mac" then

		if self.selected == true then

      		self:rotateBy(10, 1000) -- 临时的被选定效果 最后这个要改成shader
		else
			self:stopAllActions()
      		-- item:rotation(0)

      		self:rotateTo(0.1, 0)
		end

		return
	-- end


	-- if self.selected == true then
	-- 	--todo
	-- 	-- if self.kind == A then
	
	-- 	-- 	self.sprite_a:hide()
	-- 	-- 	self.berlin_a:show()
	-- 		-- self.sprite_b:hide()
	-- 		-- self.sprite_c:hide()

	-- 	-- elseif self.kind == B then

	-- 	-- 	-- self.sprite_a:hide()
	-- 	-- 	self.sprite_b:hide()
	-- 	-- 	self.berlin_b:show()

	-- 		-- self.sprite_c:hide()

	-- 	-- elseif self.kind == AB then
	-- 		-- self.sprite_a:hide()
	-- 		-- self.sprite_b:hide()
	-- 		self.sprite_c:hide()
	-- 		self.berlin_c:show()
	-- 	-- end
	-- else
	-- 	-- if self.kind == A then
	-- 	-- 	self.sprite_a:show()
	-- 	-- 	self.berlin_a:hide()
	-- 	-- 	-- self.sprite_b:hide()
	-- 	-- 	-- self.sprite_c:hide()

	-- 	-- elseif self.kind == B then

	-- 	-- 	-- self.sprite_a:hide()
	-- 	-- 	self.sprite_b:show()
	-- 	-- 	self.berlin_b:hide()

	-- 	-- 	-- self.sprite_c:hide()

	-- 	-- elseif self.kind == AB then

	-- 		-- self.sprite_a:hide()
	-- 		-- self.sprite_b:hide()
	-- 		self.sprite_c:show()
	-- 		self.berlin_c:hide()

	-- 	-- end

	-- end

end



function GameItem:inRect(x,y)

	return cc.rectContainsPoint(cc.rect(self:getPositionX() - ITEM_DISTANCE,self:getPositionY() - ITEM_DISTANCE, ITEM_DISTANCE,ITEM_DISTANCE),cc.p(x, y))

end
function GameItem:refresh()

	if self.kind == BOY then
	
		self.sprite_a:show()
		self.sprite_b:hide()
		self.sprite_c:hide()

	elseif self.kind == GIRL then

		self.sprite_a:hide()
		self.sprite_b:show()
		self.sprite_c:hide()

	elseif self.kind == CHILD then

		self.sprite_a:hide()
		self.sprite_b:hide()
		self.sprite_c:show()
	end
end

function GameItem:half()
	self.sprite_a:opacity(128)
	self.sprite_b:opacity(128)
	self.sprite_c:opacity(128)
end

function GameItem:complete()
	self.sprite_a:opacity(255)
	self.sprite_b:opacity(255)
	self.sprite_c:opacity(255)
end

function GameItem:moveThree(direction,distance)
		if self.index_x ~= 1 and direction == DIRECTION_LEFT and self.enable_left then  
			if distance.x < 0 and distance.x > -ITEM_DISTANCE then
				self:setPositionX(self.index_x * ITEM_DISTANCE + distance.x - ITEM_DISTANCE * 0.5)
			elseif distance.x <= -ITEM_DISTANCE then
				self:setPositionX((self.index_x - 1) * ITEM_DISTANCE - ITEM_DISTANCE * 0.5)
			elseif distance.x >= 0 then
				self:setPositionX(self.index_x * ITEM_DISTANCE - ITEM_DISTANCE * 0.5)
			end
		end
		
		if self.index_x ~= ROW_COUNT and direction == DIRECTION_RIGHT and self.enable_right then  
			if distance.x > 0 and distance.x < ITEM_DISTANCE then
				self:setPositionX(self.index_x * ITEM_DISTANCE + distance.x - ITEM_DISTANCE * 0.5)
			elseif distance.x >= ITEM_DISTANCE then
				self:setPositionX((self.index_x + 1) * ITEM_DISTANCE - ITEM_DISTANCE * 0.5)
			elseif distance.x <= 0 then
				self:setPositionX(self.index_x * ITEM_DISTANCE - ITEM_DISTANCE * 0.5)
			end
		end
		
		if self.index_y ~= 1 and direction == DIRECTION_DOWN and self.enable_down then  
			if distance.y < 0 and distance.y > -ITEM_DISTANCE then
				self:setPositionY(self.index_y * ITEM_DISTANCE + distance.y - ITEM_DISTANCE * 0.5)
			elseif distance.y <= -ITEM_DISTANCE then
				self:setPositionY((self.index_y - 1) * ITEM_DISTANCE - ITEM_DISTANCE * 0.5)
			elseif distance.y >= 0 then
				self:setPositionY(self.index_y * ITEM_DISTANCE - ITEM_DISTANCE * 0.5)
			end
		end
		
		if self.index_y ~= COL_COUNT and direction == DIRECTION_UP and self.enable_up then  
			if distance.y > 0 and distance.y < ITEM_DISTANCE then
				self:setPositionY(self.index_y * ITEM_DISTANCE + distance.y - ITEM_DISTANCE * 0.5)
			elseif distance.y >= ITEM_DISTANCE then
				self:setPositionY((self.index_y + 1) * ITEM_DISTANCE - ITEM_DISTANCE * 0.5)
			elseif distance.y <= 0 then
				self:setPositionY(self.index_y * ITEM_DISTANCE - ITEM_DISTANCE * 0.5)
			end
		end
end

function GameItem:moveBack()
	self:stopAllActions()
	self:moveTo(0.05, self.index_x * ITEM_DISTANCE - ITEM_DISTANCE * 0.5, self.index_y * ITEM_DISTANCE - ITEM_DISTANCE * 0.5)
end

function GameItem:step(direction)
		if self.index_x ~= 1 and direction == DIRECTION_LEFT and self.enable_left then  
			self.index_x = self.index_x - 1
		end
		
		if self.index_x ~= ROW_COUNT and direction == DIRECTION_RIGHT and self.enable_right then  
			self.index_x = self.index_x + 1
		end
		
		if self.index_y ~= 1 and direction == DIRECTION_DOWN and self.enable_down then  
			self.index_y = self.index_y - 1
		end
		
		if self.index_y ~= COL_COUNT and direction == DIRECTION_UP and self.enable_up then  
			self.index_y = self.index_y + 1
		end

	if self.m_become3 == true then
		self:setKind(3)
	end

	self:moveTo(0.1, self.index_x * ITEM_DISTANCE - ITEM_DISTANCE * 0.5, self.index_y * ITEM_DISTANCE - ITEM_DISTANCE * 0.5)
end

return GameItem