-- 管理图像的工具
ImageUtil = {}

-- 
function ImageUtil:frameForFile(file_name)
	local texture = ImageUtil:textureForFile(file_name)

	return ImageUtil:frameForTexture(texture)
end

function ImageUtil:frameForTexture(texture)
	local size = texture:getContentSize()

	return cc.SpriteFrame:createWithTexture(texture,cc.rect(0,0,size.width,size.height))
end


function ImageUtil:textureForFile( file_name )
	return cc.Director:getInstance():getTextureCache():addImage(file_name)
end

return ImageUtil