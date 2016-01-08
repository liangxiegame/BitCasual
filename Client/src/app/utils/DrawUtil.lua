DrawUtil = {}

function DrawUtil.DrawRect(parent,lc,size,color)
  local drawNode = cc.NVGDrawNode:create()
  drawNode:addTo(parent)
  drawNode:drawRect(lc,size,color)
end

function DrawUtil.DrawPoint(parent,x,y,color)

	local drawNode = cc.NVGDrawNode:create()
	drawNode:addTo(parent)
	drawNode:drawPoint(cc.p(x,y),color)
end

return DrawUtil1