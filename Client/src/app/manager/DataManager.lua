DataManager = class("DataManager")

DataManager.Score = 0				-- 分数
DataManager.BestScore = 0			-- 最高分

DataManager.HomeMusicOn = false 
DataManager.GameMusicOn = false
-- 初始化水
function DataManager.InitData()
	DataManager.Score = 0
end

function DataManager.Load()
	DataManager.BestScore = cc.UserDefault:getInstance():getIntegerForKey("BestScore", 0)
end


function DataManager.Save()
	QPrint("DataManager.Save:",DataManager.Score,DataManager.BestScore)
	if DataManager.Score > DataManager.BestScore then
		DataManager.BestScore = DataManager.Score
	end 

	cc.UserDefault:getInstance():setIntegerForKey("BestScore", DataManager.BestScore)
	cc.UserDefault:getInstance():flush()
end