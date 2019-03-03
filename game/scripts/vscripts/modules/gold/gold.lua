if not Gold then
	Gold = class({})
end
function Gold:ModifyGold(pID,golds,message)
	if Vampires:IsVampire(pID) then return end
	if message and golds > 0 then
		Gold:AddGoldWithMessage(pID, golds)
	end
	local gold = Gold:GetGold(pID)
	Gold:SetGold(pID,gold + golds)
end
function Gold:GetGold(pID)
	return PlayerTables:GetTableValue("DataPlayer", "info")[pID].gold or 0
end 

function Gold:SetGold(pID,gold)
	if not Vampires:IsVampire(pID) and pID >= 0 then
		local t = PlayerTables:GetTableValue("DataPlayer", "info")
		t[pID].gold = math.max(gold,0)
		PlayerTables:SetTableValue("DataPlayer", "info", t)
	end 
end

function Gold:AddGoldWithMessage(optPlayerID, gold)
  local player = PlayerResource:GetPlayer(optPlayerID)
  SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, PlayerResource:GetSelectedHeroEntity(optPlayerID), math.floor(gold), player)
end

function Gold:SetMan(pID,spawn)
	Vampires:RemoveVampire(pID,spawn)
end 