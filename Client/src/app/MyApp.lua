require("config")

require("cocos.init")
require("framework.init")
require("indie.init")

require("app.model.matrices")
require("app.model.algorithm")

require("app.utils.ImageUtil")
require("app.utils.GUIUtil")
require("app.utils.TableUtil")
require("app.utils.QTimer")
require("app.utils.NativeUtil")
require("app.utils.DrawUtil")

require("app.AppConstants")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")

    -- 加载图像
    cc.Director:getInstance():getTextureCache():addImage("pvr/all.pvr.ccz")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("pvr/all.plist")

    -- 预先加载音效
    audio.preloadSound("res/sound/crush.wav")
    audio.preloadSound("res/sound/piu.wav")
    audio.preloadSound("res/sound/push.wav")
    audio.preloadSound("res/sound/select.wav")
    audio.preloadSound("res/sound/tick.wav")
    audio.preloadSound("res/sound/crushline.wav")

    -- 平台区分 屏幕适配
    if device.platform == "ios" then

		if device.model == "ipad" then
        	cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.FIXED_HEIGHT)
		else
			cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.FIXED_WIDTH)
		end
	end
    self:enterScene("HomeScene")
end

return MyApp
