--[[
	用来处理多边形碰撞等常用函数
]]
QMathUtil = {}

require("app.utils.QTimer")

local function CC_RADIANS_TO_DEGREES(angle)
	return  angle * 57.29577951
end

local function CC_DEGREES_TO_RADIANS(angle)
	return angle * 0.01745329252
end

-- 这个以后要做优化
function QMathUtil:inShape(vectors,point,num)
	-- QTimer:beganTime()

	local verts = {}
	local verts_length = {}
	local vector_count = 0

	if num == nil then
		vector_count = table.nums(vectors)
	else
		vector_count = num
	end

	for i=1,vector_count do
		verts[i] = cc.pSub(vectors[i], point)
	
		if math.abs(verts[i].x) < 0.0001 and math.abs(verts[i].y) < 0.0001 then
			verts[i] = cc.p(0.0001,0.0001)
		end		

		verts_length[i] = cc.pGetLength(verts[i])
	end

	local angle = 0

	for i=1,vector_count - 1 do
		angle = angle + math.acos(cc.pDot(verts[i], verts[i + 1]) / (verts_length[i] * verts_length[i + 1]))
	end

	angle = angle + math.acos(cc.pDot(verts[vector_count], verts[1]) / (verts_length[vector_count] * verts_length[1]))

	angle = CC_RADIANS_TO_DEGREES(angle)

	if 	math.abs(angle - 360) < 0.001 then
		return true
	else
		return false
	end
end

-- 数字转换为数组
function QMathUtil.ArrayForNumber(num)
	-- 存储美味数字的数组
	local numArray = {}
	QPrint("num",num)
	-- 用来计算的下角标
	local flag = 0

	-- 临时的
	local tempNum = num

	local eLoop = true 
	while eLoop do
		--移动下角标
		flag = flag + 1

		--获取第flag位的数字
		numArray[flag] = math.modf(tempNum % 10)
		QPrint(numArray[flag])
		-- 删除第flag位的数字
		tempNum = tempNum / 10

		if tempNum - 0 < 1 then 
			eLoop = false
		end 
		-- 移动下角标
	end

	return numArray
end