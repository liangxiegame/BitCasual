
local PlayerState = class("PlayerState",FSMState)

function PlayerState:ctor(name,model)
	FSMState.ctor(self,name)
	self.model = model
end

return PlayerState