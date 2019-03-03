if not HealthBar then
	HealthBar = class({})
	HealthBar.oldArray = {}
end
local SEARCH_RADIUS = 3000
function HealthBar:FindBossByHero(hero)
	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,hero:GetAbsOrigin(),nil,SEARCH_RADIUS,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,FIND_CLOSEST,false)
	for k,v in pairs(units) do
		if v:IsMiniBoss() then
			return {
				HeroName = v:GetUnitName(),
				health = v:GetHealth(),
				HealthMax = v:GetMaxHealth(),
				HealthRegen = v:GetHealthRegen(),
				Mana = v:GetMana()  >= 0 and v:GetMaxMana() > 0 and v:GetMana() or -1,
				ManaMax = v:GetMaxMana() > 0 and v:GetMaxMana() or -1,
				ManaRegen = v:GetManaRegen() >= 0 and v:GetManaRegen() or -1,
			}
		end
	end 
	return false
end 

function HealthBar:Init()
	Timers:CreateTimer(0.2,function()
		local hero,array,find
		if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
			CustomGameEventManager:Send_ServerToAllClients("UpdateHealthBar", {stop = true}) 
			return
		end
		for i = 0, DOTA_MAX_PLAYERS - 1 do
			if PlayerResource:IsValidPlayerID(i) and not IsPlayerAbandoned(i)  then
				hero = PlayerResource:GetPlayer(i):GetAssignedHero()
				if PlayerResource:GetTeam(i) ~= DOTA_TEAM_BADGUYS and hero then
					find = HealthBar:FindBossByHero(hero)
					array = not find and {stop = true} or find
					if type(HealthBar.oldArray[i]) ~= "table" then HealthBar.oldArray[i] = {} end
					if type(HealthBar.oldArray[i]) == "table" and not  table.equals(array, HealthBar.oldArray[i]) then 
						HealthBar.oldArray[i] = array
						CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i),"UpdateHealthBar", array) 
					end
				else
					array = {stop = true}
					HealthBar.oldArray[i] = array
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i),"UpdateHealthBar", array) 
				end
			end
		end
		return 0.2
	end)
end 