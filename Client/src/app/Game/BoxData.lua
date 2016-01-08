--[[
	游戏区域的数据结构 6 x 6
]]

local BoxData = class("BoxData")

function BoxData:ctor()
	self:initData()
end


-- @public
-- 重置数据
function BoxData:initData()
	for row_index = 1,ROW_COUNT do 
		self[row_index] = {}
		for col_index = 1,COL_COUNT do 
			self[col_index] = 0
		end 
	end 
end

return BoxData 