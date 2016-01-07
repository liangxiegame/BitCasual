
local PlayerState = class("PlayerState",FSMState)

function PlayerState:ctor(name,scene)
	FSMState.ctor(self,name)
	self.mScene = scene
end

return PlayerState