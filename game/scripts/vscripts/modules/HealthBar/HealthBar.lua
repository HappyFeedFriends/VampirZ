if not HealthBar then
	HealthBar = class({})
	HealthBar.oldArray = {}
	HealthBar.NightHunter = nil
end

local SEARCH_RADIUS = 3000
function HealthBar:FindBossByHero(hero)
	if HealthBar.NightHunter then
		return {
			index = HealthBar.NightHunter:entindex(),
			stage = HealthBar.NightHunter.stage
		}
	end 
	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,hero:GetAbsOrigin(),nil,SEARCH_RADIUS,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,FIND_CLOSEST,false)
	for k,v in pairs(units) do
		if v:IsMiniBoss() then
			return {
				index = v:entindex(),
				stage = v.stage
			}
		end
	end 
	return false
end 

function HealthBar:AltToModify(event)
	--print ("show asura core count")
	local pID = event.pID
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero()
	local isDebuff = true
	local color = isDebuff and 'red' or 'lime';
	local message = 'Effect: <font color="{color}">{countStack} {effectName}</font> valid on {targetBoss} {sec}'
	message = message:gsub('{color}',color) 
	hero.tellBuffDelayTimer = hero.tellBuffDelayTimer or 0
	if GameRules:GetGameTime() > hero.tellBuffDelayTimer + 1 then
		Say(player, message, true)
		GameRules:SendCustomMessage(message, pID, 0)
		hero.tellBuffDelayTimer = GameRules:GetGameTime()
	end
end

function HealthBar:Init()
	CustomGameEventManager:RegisterListener('AltToModify', Dynamic_Wrap( HealthBar, 'AltToModify'))
	Timers:CreateTimer(0.2,function()
		local hero,array,find
		if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
			CustomGameEventManager:Send_ServerToAllClients("UpdateHealthBar", {stop = true}) 
			return
		end
		for i = 0, DOTA_MAX_PLAYERS - 1 do
			if PlayerResource:IsValidPlayerID(i) and not IsPlayerAbandoned(i) and PlayerResource:GetPlayer(i):GetAssignedHero()  then
				hero = PlayerResource:GetPlayer(i):GetAssignedHero()
				if PlayerResource:GetTeam(i) ~= DOTA_TEAM_BADGUYS then
					find = HealthBar:FindBossByHero(hero)
					array = not find and {stop = true} or find
					if type(HealthBar.oldArray[i]) ~= "table" then HealthBar.oldArray[i] = {} end
					if not table.equals(array, HealthBar.oldArray[i]) then
						HealthBar.oldArray[i] = array
						CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i),"UpdateHealthBar", array) 
					end
				elseif not table.equals({stop = true}, HealthBar.oldArray[i] or {}) then
					array = {stop = true}
					HealthBar.oldArray[i] = array
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i),"UpdateHealthBar", array) 
				end
			end
		end
		return 0.2
	end)
end 