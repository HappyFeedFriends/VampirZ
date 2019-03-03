if not kills then
	kills = ({})
end
ModuleRequire(...,"data")
function kills:OnEntityKilled(killer,killedUnit)
	local data
	if killer:IsHero() and not killedUnit:IsCourier() then
		data = 
		{
			type = "kill",
			killerPlayer = killer:GetPlayerID(),
			victimPlayer = killedUnit:GetPlayerID(),
			gold = kills:GetPlayerStreak(killedUnit:GetPlayerID()),
		}
		if PlayerResource:GetStreak(killedUnit:GetPlayerID()) > 1 and killer:GetPlayerID() ~= killedUnit:GetPlayerID() then
			data.type = "generic"
			data.text = "#custom_toast_killed_streak"
			data.variables = {
				["{kill_streak}"] = PlayerResource:GetStreak(killedUnit:GetPlayerID()),
			}
		end 
		if Vampires:IsVampire(killer:GetPlayerID()) then
			data.vampire = true
		end
		if killer ~= killedUnit then
			kills:ModifyMoneyKill(kills:GetPlayerStreak(killedUnit:GetPlayerID()),killer,killedUnit) 
		end 
		kills:CreateCustomToast(data)
	elseif killer:IsCreep() then
		kills:KillerCreeps(killer,killedUnit)
	end 
end

function kills:KillerCreeps(killer,killedUnit)
	local data = {
			type = "kill",
			victimPlayer = killedUnit:GetPlayerID(),
	}
	kills:CreateCustomToast(data)
end 

function kills:ModifyMoneyKill(gold,killer)
	if not ( killer )then return end
	local plId = -1
	if killer.GetPlayerID then
		plId = killer:GetPlayerID()
	end
	if plId == -1 and killer.GetPlayerOwnerID then
		plId = killer:GetPlayerOwnerID()
	end
	if plId == -1 then return end
	if Vampires:IsVampire(plId) then
		Vampires:ModifyBlood(plId, gold)
	else
		Gold:ModifyGold(plId, gold) 
	end
end 

function kills:GetStreak(Player)
	if Vampires:IsVampire(Player) then
		return (table.nearestOrLowerKey(KILL_STREAK_SETTINGS.KILL_STREAK_BLOOD, PlayerResource:GetStreak(Player)) * (PlayerResource:GetStreak(Player) > 0 and PlayerResource:GetStreak(Player) or 1))
	end
	return (table.nearestOrLowerKey(KILL_STREAK_SETTINGS.KILL_STREAK_GOLD, PlayerResource:GetStreak(Player)) * (PlayerResource:GetStreak(Player) > 0 and PlayerResource:GetStreak(Player) or 1))
end  

function kills:GetPlayerStreak(Player)
	if not Vampires:IsVampire(Player) then
		return math.round(KILL_STREAK_SETTINGS.DEFAULT_BLOOD + kills:GetStreak(Player))
	end
	return math.round(KILL_STREAK_SETTINGS.DEFAULT_GOLD + kills:GetStreak(Player))
end 
function kills:CreateCustomToast(data,type,killerPlayer,victimPlayer,gold,player,victimUnitName,team,runeType,variables)
	CustomGameEventManager:Send_ServerToAllClients("create_custom_toast", data or {
	type = type,
	killerPlayer = killerPlayer,
	victimPlayer = victimPlayer,
	gold = gold,
	player = player,
	victimUnitName = victimUnitName,
	team = team,
	runeType = runeType,
	variables = variables, -- table
	})
end