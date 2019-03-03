USUAL_ACCESS = 1
CHEAT_LOBBY_ACCESS = 2
DEV_ACCESS = 3

CHAT_COMMANDS =
{
	["VAMPIRE_ON"] = 
	{
		ACCESS = DEV_ACCESS,
		funcs = function(args,PlayerId)
			Vampires:RemoveAlpha(PlayerId,true)
			Vampires:SetVampire(PlayerId)
		end
	},
	["CLEAR_UPGRADES"] = 
	{
		ACCESS = DEV_ACCESS,
		funcs = function(args,PlayerId)
			local t = PlayerTables:GetTableValue("UpgradeHeroSetting", "LockedUpgrade") or {}
			local t2 = PlayerTables:GetTableValue("UpgradeHeroSetting", "SavesUpgrades") or {}
			t[PlayerId] = {}
			t2[PlayerId] = {}
			PlayerTables:SetTableValue("UpgradeHeroSetting", "LockedUpgrade", t) 
			PlayerTables:SetTableValue("UpgradeHeroSetting", "SavesUpgrades", t2)
			PrintTable(PlayerTables:GetTableValue("UpgradeHeroSetting", "LockedUpgrade"))
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PlayerId), "UpdateUpgradeHero", {})
		end
	},		
	["VAMPIRE_OFF"] = 
	{
		ACCESS = DEV_ACCESS,
		funcs = function(args,PlayerId)
			Vampires:RemoveVampire(PlayerId)
		end
	},		
	["REMOVE_ALPHA"] = 
	{
		ACCESS = DEV_ACCESS,
		funcs = function(args,PlayerId)
			Vampires:RemoveAlpha(PlayerId,true)
		end
	},	
	["SET_CLASS"] = 
	{
		ACCESS = DEV_ACCESS,
		funcs = function(args,PlayerId)
			UpgradeHero:SetClassHero({
				class = args or PlayerResource:GetPlayer(PlayerId):GetAssignedHero():GetUnitName(),
				pID = PlayerId,
				
			},true)
		end
	},	
	["SET_ALPHA"] = 
	{
		ACCESS = DEV_ACCESS,
		funcs = function(args,PlayerId)
			Vampires:SetAlpha(PlayerId)
		end
	},		
	["SPAWNWAVES"] = 
	{
		ACCESS = DEV_ACCESS,
		funcs = function(args,PlayerId)
			SpawnNeutrals:Init()
		end
	},		
	["SPAWN_OFF"] = 
	{
		ACCESS = DEV_ACCESS,
		funcs = function(args,PlayerId)
			SPAWN_UNIT = false
		end
	},	
	["SPAWN_ON"] = 
	{
		ACCESS = DEV_ACCESS,
		funcs = function(args,PlayerId)
			SPAWN_UNIT = false
		end
	},	
	["REMOVEALLUNITS"] = 
	{
		ACCESS = DEV_ACCESS,
		funcs = function(args,PlayerId)
			RemoveAllSpawnedUnits()
		end
	},	
	["BLOOD"] = 
	{
		ACCESS = CHEAT_LOBBY_ACCESS,
		funcs = function(args,PlayerId)
			Vampires:ModifyBlood(PlayerId,tonumber(args))
			USER_DATA[PlayerId]["UsableCheat"] = not IsDev(PlayerId)
		end
	},	
	["GOLD"] = 
	{
		ACCESS = CHEAT_LOBBY_ACCESS,
		funcs = function(args,PlayerId)
			Gold:ModifyGold(PlayerId,tonumber(args))
			USER_DATA[PlayerId]["UsableCheat"] = not IsDev(PlayerId)
		end
	},
}