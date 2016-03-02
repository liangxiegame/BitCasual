--[[
    调用原生接口,封装SDK用,平台检测
]]

NativeUtil = {}

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

function NativeUtil.PreloadFullAd()
    
     -- self:schedule(self.logic, 1.0 / 60.0)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()

    local supportObjectCBridge  = false
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform)  then
        supportObjectCBridge = true
    end
    
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = { num1 = 2 , num2 = 3 }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "LuaObjectCBridgeTest"
        local ok,ret  = luaoc.callStaticMethod(className,"isFullLoadedOC")
        -- local ok,ret  = luaoc.callStaticMethod(className,"isFullLoadedOC",args)
        if not ok then
            cc.Director:getInstance():resume()
        else
            print("The ret is:", ret)

            if ret == 1 or ret == "1" then
                
                cc.Director:getInstance():stopAnimation()

                cc.Director:getInstance():pause()

                luaoc.callStaticMethod(className,"showFullOC")



            else

                luaoc.callStaticMethod(className,"loadFullOC")

            end
        end

        local function callback(param)
            if "success" == param then
                print("object c call back success")
            end
        end
        luaoc.callStaticMethod(className,"registerScriptHandler", {scriptHandler = callback } )
        luaoc.callStaticMethod(className,"callbackScriptHandler")

    elseif cc.PLATFORM_OS_ANDROID == targetPlatform then
        local args = { num1 = 2,num2 = 3}
        local luaj = require "cocos.cocos2d.luaj"
        -- local class = ""

                -- if device.platform ~= "android" then
                --     print("please run this on android device")
                --     btn:setButtonLabel(cc.ui.UILabel.new({text = "please run this on android device", size = 32}))
                --     return
                -- end
                
                -- call Java method
                local javaClassName = "org/cocos2dx/lua/AppActivity"
                -- local javaMethodName = "showAlertDialog"
                local javaMethodName = "getFullIsLoadedJNI"
                -- local javaParams = {
                --     "How are you ?",
                --     "I'm great !",
                --     function(event)
                --         local str = "Java method callback value is [" .. event .. "]"
                --         btn:setButtonLabel(cc.ui.UILabel.new({text = str, size = 32}))
                --     end
                -- }
                -- local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;I)V"
                -- local javaParams = {}
                -- local javaMethodSig = "()Z"
        -- local ok,value = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        -- if value  then 
            luaj.callStaticMethod(javaClassName,"showAdmobFull",{},"()V")
        -- end 
    end
end
