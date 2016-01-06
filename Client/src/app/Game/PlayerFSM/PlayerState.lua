
PlayerState = class("PlayerState",FSMState)

function PlayerState:ctor(name,player)
	FSMState.ctor(self,name)
	self.mPlayer = player
end

return PlayerState