DataManager = class("DataManager")

DataManager.Score = 0				-- 分数
DataManager.BestScore = 0			-- 最高分

function DataManager.Load()
	DataManager.BestScore = cc.UserDefault:getInstance():getIntegerForKey("BestScore", 0)
end


function DataManager.Save()
	if DataManager.Score > DataManager.BestScore then
		DataManager.BestScore = DataManager.Score
	end 

	cc.UserDefault:getInstance():setIntegerForKey("BestScore", DataManager.BestScore)
	cc.UserDefault:getInstance():flush()
end