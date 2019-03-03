if not Vampires then
	Vampires = class({})
	Vampires.CountDeath = 0
end 
START_GOLD = 200
START_BLOOD = 50

function Vampires:ModifyBlood(pID,modify)
	if not Vampires:IsVampire(pID) then return end
	local blood = Vampires:GetBlood(pID)
	Vampires:SetBlood(pID,blood + modify)
end

function CDOTA_BaseNPC:ModifyBlood(modify)
	local pID = self:GetPlayerID()
	Vampires:ModifyBlood(pID,modify)
end

function Vampires:GetBlood(pID)
	return pID >= 0 and PlayerTables:GetTableValue("DataPlayer", "info") and PlayerTables:GetTableValue("DataPlayer", "info")[pID].blood or 0
end 

function Vampires:SetBlood(pID,bloods)
	if Vampires:IsVampire(pID) then
		local t = PlayerTables:GetTableValue("DataPlayer", "info")
		t[pID].blood = math.max(bloods,0)
		PlayerTables:SetTableValue("DataPlayer", "info", t)
	end 
end

function Vampires:SetVampire(pID,alpha)
if tonumber(pID) < 0 or Vampires:IsVampire(pID) then return end
	local t = PlayerTables:GetTableValue("DataPlayer", "info")
	local entityHero = PlayerResource:GetPlayer(pID):GetAssignedHero()
	t[pID].vampire = true
	t[pID].blood = START_BLOOD
	t[pID].gold = 0
	PlayerTables:SetTableValue("DataPlayer", "info", t)
	if alpha and not entityHero:IsNull() then
		entityHero:Teleport(Entities:FindByName(nil,'VampirFirstSpawn'):GetAbsOrigin());
	end 
	if not alpha then
		Vampires.CountDeath = Vampires.CountDeath + 1
		USER_DATA[pID]["DurationLife"] = GameRules:GetDOTATime(false, false)
		USER_DATA[pID]["Lose"] = Vampires.CountDeath >= request.CountLimit
		USER_DATA[pID]["DeathNumber"] = Vampires.CountDeath + 1
	end 
	UpgradeHero:SetClassHero({
		pID = pID,
	})
	HeroSelection2:SelectHero({
		heroName = alpha and "npc_dota_hero_night_stalker" or "npc_dota_hero_life_stealer",
		PlayerID = pID,
	})
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, GameRules:GetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS) + 1)
	PlayerResource:SetPlayerTeam(pID, DOTA_TEAM_BADGUYS)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, GameRules:GetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS) - 1)
	if GetTeamPlayerCount(DOTA_TEAM_GOODGUYS) <= 0 then
		request:SetWinner(DOTA_TEAM_BADGUYS)
		return
	end
end

function Vampires:SetAlpha(pID)
if tonumber(pID) < 0 then return end
	Vampires:SetVampire(pID,true)
end

function Vampires:RemoveAlpha(pID,adm)
if tonumber(pID) < 0 then return end
	local entityHero = PlayerResource:GetPlayer(pID):GetAssignedHero()
	Vampires:RemoveVampire(pID)
end

function Vampires:RemoveVampire(pID,spawn)
if pID < 0 or not Vampires:IsVampire(pID)  then return end
	local t = PlayerTables:GetTableValue("DataPlayer", "info") or {}
	t[pID].vampire = false
	t[pID].blood = 0
	t[pID].gold = START_GOLD
	PlayerTables:SetTableValue("DataPlayer", "info", t)
	local entityHero = PlayerResource:GetPlayer(pID):GetAssignedHero()
	UpgradeHero:SetClassHero({
		heroName = entityHero:GetUnitName(),
		pID = pID,
	})
	if not spawn then
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, GameRules:GetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS) + 1)
		PlayerResource:SetPlayerTeam(pID, DOTA_TEAM_GOODGUYS)
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, GameRules:GetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS) - 1)
	end
	PlayerResource:SetCameraTarget(pID, nil)
end

function Vampires:Think()
	Timers:CreateTimer(3,function()
		if GameRules:State_Get() > DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return end
		for i = 0, 23 do
			if PlayerResource:IsValidPlayer(i) then
				if Vampires:IsVampire(i) then
					Vampires:ModifyBlood(i,4)
					PlayerResource:GetPlayer(i):GetAssignedHero():AddExperience(30.0,0,true,true)
				else
					Gold:ModifyGold(i,2)
				end
			end
		end
		return 3
	end)
end

function Vampires:IsVampire(pID)
	return pID >= 0 and PlayerTables:GetTableValue("DataPlayer", "info") and PlayerTables:GetTableValue("DataPlayer", "info")[pID].vampire
end

function CDOTA_BaseNPC:IsVampire()
	return Vampires:IsVampire(self:GetPlayerID())
end 

function Vampires:IsAlpha(pID)
	return pID >= 0 and (UpgradeHero:GetClassHero(pID) == "Alpha" or HeroSelection2.FirstVampire == pID)
end 

function  CDOTA_BaseNPC:IsAlpha()
	return Vampires:IsAlpha(self:GetPlayerID())
end 