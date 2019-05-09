function ShowLocationName(data)
	local activator = data.activator
	local caller = data.caller
	local heroName = activator:GetName()
	local triggerName = caller:GetName()
	if (heroName ~= FORCE_PICKED_HERO) then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(activator:GetPlayerID()),"LocationName", {
			text = triggerName,
		})
	end
end 