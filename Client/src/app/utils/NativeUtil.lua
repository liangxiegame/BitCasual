--[[
	调用原生接口,封装SDK用,平台检测
]]

NativeUtil = {}


function NativeUtil.PreloadFullAd()
	
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