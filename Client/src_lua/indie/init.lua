require("indie.FSM")
require("indie.MsgDispatcher")

function QPrint( ... )
	if DEBUG ~= 0 then 
		print(...)
	end 
end