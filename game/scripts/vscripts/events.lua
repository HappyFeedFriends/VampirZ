function VampireZ:StartGameEvents()
  	ListenToGameEvent('entity_killed', Dynamic_Wrap(VampireZ, 'OnEntityKilled'), self)
  	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(VampireZ, 'OnGameRulesStateChange'), self)
  	ListenToGameEvent('npc_spawned', Dynamic_Wrap(VampireZ, 'OnNPCSpawned'), self)
  --	ListenToGameEvent("player_reconnected", Dynamic_Wrap(VampireZ, 'On_player_reconnected '), self)
  	ListenToGameEvent("player_chat", Dynamic_Wrap(VampireZ, 'OnPlayerChat'), self)
  	CustomGameEventManager:RegisterListener("BuyItem", Dynamic_Wrap(CustomShop, 'BuyItem'))

  	--CustomGameEventManager:RegisterListener("PickedHero", Dynamic_Wrap(HeroSelection, 'PickedHero'))
  	--CustomGameEventManager:RegisterListener("SetHeroPicked", Dynamic_Wrap(HeroSelection, 'SetHeroPicked'))
  	CustomGameEventManager:RegisterListener("SetClassHero", Dynamic_Wrap(UpgradeHero, 'SetClassHero'))
 	CustomGameEventManager:RegisterListener("PickedTeamHero", Dynamic_Wrap(VampireZ, 'PickedTeamHero'))
  	CustomGameEventManager:RegisterListener("AddUpgradeClass", Dynamic_Wrap(UpgradeHero, 'AddUpgradeClass'))
  	CustomGameEventManager:RegisterListener("LockedUpgrades", Dynamic_Wrap(UpgradeHero, 'LockedUpgrades'))
  	CustomGameEventManager:RegisterListener("OnDressingItem", Dynamic_Wrap(wearables, 'OnDressingItem'))
	CustomGameEventManager:RegisterListener("OnEquipItemWearable", Dynamic_Wrap(wearables, 'OnEquipItemWearable'))

	CustomGameEventManager:RegisterListener("SelectHero", Dynamic_Wrap(HeroSelection2, 'SelectHero'))
end

function VampireZ:OnGameRulesStateChange(keys) 
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		request:PreLoad()
	end
	if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		VampireZ:HeroSelection()
	end	
	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		VampireZ:PreGame()
	end 	
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		VampireZ:OnGameInProgress()
	end 
end

function VampireZ:OnNPCSpawned(keys)
local SpawnedUnit = EntIndexToHScript(keys.entindex)
	if not SpawnedUnit:IsNull() and SpawnedUnit:IsRealHero() then
		local pID = SpawnedUnit:GetPlayerID()
		if  SpawnedUnit.FirstSpawn == nil then
			SpawnedUnit.FirstSpawn = true
			UpgradeHero:RemoveDotaAbility(SpawnedUnit)
			wearables:FirstSpawnHero( SpawnedUnit )
			if not SpawnedUnit:IsVampire() then
				Gold:SetGold(pID,START_GOLD)
			end
			--local data = not Vampires:IsVampire(pID) and {pID = pID,heroName = SpawnedUnit:GetUnitName()} or 
			--Vampires:IsAlpha(pID) and {pID = pID,class = 'Alpha'} or 
			--{pID = pID,class = 'Beta'}
			--if SpawnedUnit:GetUnitName() ~= 'npc_dota_hero_target_dummy' then
				--UpgradeHero:SetClassHero({
				--	pID = pID,
				--	heroName = SpawnedUnit:GetUnitName()
				--})
			--end
		end
		if SpawnedUnit.vampireSet then
			SpawnedUnit.vampireSet = nil
			SpawnedUnit:Teleport(Entities:FindByName(nil,'VampirFirstSpawn'):GetAbsOrigin());
			Vampires:SetVampire(pID)
		end
		--if Vampires:IsVampire(pID) then
		--	SpawnedUnit:AddNewModifier(SpawnedUnit,nil,"modifier_IsVampire",{duration = -1})
		--else
		--	SpawnedUnit:RemoveModifierByName("modifier_IsVampire")
		--end
		if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			SpawnedUnit:AddNewModifier(SpawnedUnit,nil,"modifier_stunned",{duration = -1})
		end 
	end
end

function VampireZ:OnItemPickedUp(keys)
end

function VampireZ:OnEntityKilled( keys )
local killedUnit = EntIndexToHScript( keys.entindex_killed )
local killerEntity
local killerAbility
local damagebits = keys.damagebits
	if keys.entindex_attacker ~= nil then killerEntity = EntIndexToHScript( keys.entindex_attacker ) end
	if keys.entindex_inflictor ~= nil then killerAbility = EntIndexToHScript( keys.entindex_inflictor ) end
	if killedUnit:IsRealHero() then
		killedUnit:SetRespawnTime()
		if killerEntity then
			kills:OnEntityKilled(killerEntity,killedUnit)
		end
		if not Vampires:IsVampire(killedUnit:GetPlayerID()) then
			killedUnit.vampireSet = true
		end 
	end
	if not killedUnit:IsNull() and killedUnit:IsCreep() then
		local gold = 0
		if killedUnit:IsWaveUnit() then
			SpawnNeutrals.UnitsCount = SpawnNeutrals:GetUnitCountToMap() - 1
		end		
		if killedUnit:IsMiniBoss() and SpawnNeutrals.MiniBossCount > 0 then
			SpawnNeutrals.MiniBossCount = SpawnNeutrals.MiniBossCount - 1
		end
		if killerEntity and killerEntity:IsHero() then
			local pID = killerEntity:GetPlayerID()
			gold = gold + killedUnit:GetGoldBounty()
			PlayerResource:PlayerIterate(function(ID)
				if PlayerResource:GetTeam(ID) == PlayerResource:GetTeam(pID) then
					Gold:ModifyGold(ID,gold,true)
					if pID ~= ID then
						PlayerResource:GetSelectedHeroEntity(ID):AddExperience(killedUnit:GetDeathXP(),0,true,true)
					end
				end
			end)
		end 
	end 
	if killerEntity and killedUnit:IsRealHero() and killedUnit:IsVampire() then
		if killerEntity:IsUpgrade("SpecialUpgrade_3_Gunner_5") then
			for i=0, 8 do
				local current_item = killerEntity:GetItemInSlot(i)
				if current_item and not current_item:IsCooldownReady() then
					current_item:EndCooldown()
				end
			end
			for i=0,5 do
				local abilityF = killerEntity:GetAbilityByIndex(i)
				if abilityF and not abilityF:IsCooldownReady() then
					abilityF:EndCooldown()
				end
			end
		end
	end
end

function VampireZ:OnPlayerChat(keys)
	local text = keys.text
	local ID = keys.userid
	local PlayerId = keys.playerid
	if PlayerId and PlayerId >= 0 then
		--local teamOnly = keys.teamonly
		--local SteamdID = PlayerResource:GetSteamAccountID(PlayerId)
		local player = PlayerResource:GetPlayer(PlayerId)
		--local playerName = PlayerResource:GetPlayerName(PlayerId)
		--local hero = player:GetAssignedHero()
		--local team = PlayerResource:GetTeam(PlayerId)
		--local hero_table = PlayerResource:GetSelectedHeroEntity(PlayerId)	
		local commands = {}
		for v in string.gmatch(string.sub(text, 2), "%S+") do 
			table.insert(commands, v) 
		end		
		local command = table.remove(commands, 1)
		if command == "-" or not command then return end
		local prob =  text:find(" ") or 0
		local numbers = string.sub(text, prob+1)
		local cmd = CHAT_COMMANDS[command:upper()]	
		if cmd and cmd.ACCESS <= GetAccesCheatsPlayer(PlayerId) then
			cmd.funcs(numbers,PlayerId)
		end 
	end
end