DrawUtil = {}

function DrawUtil.DrawRect(parent,lc,size,color)
  local drawNode = cc.NVGDrawNode:create()
  drawNode:addTo(parent)
  drawNode:drawRect(lc,size,color)
end

return DrawUtil1