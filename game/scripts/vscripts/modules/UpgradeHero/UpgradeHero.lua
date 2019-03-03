
if not UpgradeHero then
	UpgradeHero = class({})
	UpgradeHero.NotDeleteAbility = {
		['Vampire_Claws'] = true,
		['VampireShield'] = true,
		['Gunner_Weakness'] = true,
		['Gunner_Unstable_Ammonite'] = true,
		['generic_hidden'] = true,
		['Healer_vow_to_God'] = true,
		['Healer_inquisition'] = true,
		['Healer_call_to_angels'] = true,
		['Healer_divine_touch'] = true,
	}
end
ModuleRequire(...,"data")
function UpgradeHero:PreLoad()
	--CustomNetTables:SetTableValue("UpgradeHero", "AllClasses", ALL_CLASSES)
	--CustomNetTables:SetTableValue("UpgradeHero", "Settings", SETTINGS_CLASSES)
	PlayerTables:CreateTable("UpgradeHeroKV", UPGRADE_CLASS_SETTING,true)		
	PlayerTables:CreateTable("UpgradeHeroSetting", {
		SavesUpgrades = {},
		LockedUpgrade = {},
		Images = UpgradeHero:GetImages(),
	},true)		
end 

function UpgradeHero:SetClassHero(data,adm)
	if data.pID >= 0 then
		local t = PlayerTables:GetTableValue("DataPlayer", "info")
		if not t then print("[UpgradeHero] Critical Error: Table = ",t) return  end
		t[data.pID].classHero = data.class or GetKeyValueByHeroName(data.heroName or PlayerResource:GetSelectedHeroEntity( data.pID ):GetUnitName(), "HeroClassName")  or -1
		PlayerTables:SetTableValue("DataPlayer", "info", t)
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.pID), "UpdateUpgradeHero", {})
	end
end

function UpgradeHero:AddUpgradeClass(data)
	local pID = data.PlayerID
	local UpgradeName = data.UpgradeName
	local IsLocked = data.IsLocked == 0
	local IsNotUpgrade = data.IsNoUpgradePrevious == 0
	local hero = PlayerResource:GetSelectedHeroEntity( pID )
	if IsLocked then Containers:DisplayError(pID,"#hud_error_locked_upgrade") return end
	if IsNotUpgrade then Containers:DisplayError(pID,"#hud_error_not_previous_upgrade") return end
	local data = UpgradeHero:GetUpgradeData(UpgradeName,pID)
	if data.AbilityCaster and not hero:FindAbilityByName(data.AbilityCaster) then  Containers:DisplayError(pID,"#hud_error_not_found_ability_class") return end
	local t = PlayerTables:GetTableValue("UpgradeHeroSetting", "SavesUpgrades")
	if not t[pID] or type(t[pID]) ~= "table" then t[pID] = {} end
	t[pID][UpgradeName] = true 
	PlayerTables:SetTableValue("UpgradeHeroSetting", "SavesUpgrades", t) 
	if data and type(data) == "table" then
		if data.GetAddAbility and type(data.GetAddAbility) == "string" and hero and not hero:FindAbilityByName( data.GetAddAbility ) then
			local ability = hero:AddAbility(data.GetAddAbility)
			ability:SetLevel( 1 )
			if data.Swap then
				local abilitySwap = hero:FindAbilityByName( "generic_hidden" )
				if abilitySwap then
					hero:SwapAbilities("generic_hidden",data.GetAddAbility, false, true)
				end 
			end 
		end	
		if data.GetAddModifier and type(data.GetAddModifier) == "string" and hero and not hero:FindModifierByName( data.GetAddModifier ) then
			hero:AddNewModifier(hero,data.AbilityCaster and hero:FindAbilityByName(data.AbilityCaster) or nil,data.GetAddModifier,(data.dataModifier or {
				duration = (data.duration or -1)
			}))
		end 
		if data.SwapTable then
			for k,v in pairs(data.SwapTable) do
				hero:SwapAbility(v,k,true)
			end 
		end 
	end 
end 

function UpgradeHero:RemoveDotaAbility(hero)
	for i=0,24 do 
		if hero:GetAbilityByIndex(i) and  not UpgradeHero.NotDeleteAbility[hero:GetAbilityByIndex(i):GetAbilityName()] then
			hero:RemoveAbility(hero:GetAbilityByIndex(i):GetAbilityName())
		end
	end 
end 


function UpgradeHero:LockedUpgrades(data)
	local pID = data.PlayerID
	local t = PlayerTables:GetTableValue("UpgradeHeroSetting", "LockedUpgrade")
	if not t[pID] or type(t[pID]) ~= "table" then t[pID] = {} end
	for k,_ in pairs(data.data) do
		if k:match("SpecialUpgrade") then
			t[pID][k] = true
		end
	end 
	PlayerTables:SetTableValue("UpgradeHeroSetting", "LockedUpgrade", t) 
end 

function UpgradeHero:GetImages()
	local array = {}
	for k,v in pairs(SETTING_DATA_UPGRADES) do
		for ClassNames,class in pairs(v) do
			for indexTable,arrayq in  pairs(class) do
				for key,value in pairs(arrayq) do
					--if value.Image or value.GetAddAbility then
						if type(array[k]) ~= "table" then array[k] = {} end
						if type(array[k][ClassNames]) ~= "table" then array[k][ClassNames] = {} end
						if type(array[k][ClassNames][indexTable]) ~= "table" then array[k][ClassNames][indexTable] = {} end
						if type(array[k][ClassNames][indexTable][key]) ~= "table" then array[k][ClassNames][indexTable][key] = {} end
						array[k][ClassNames][indexTable][key]  = value.Image or value.GetAddAbility or "not_found"
					--end 
				end
			end
		end
	end
	return array
end 

function CDOTA_BaseNPC:IsUpgrade(Name)
	local pID = self:GetPlayerID()
	return UpgradeHero:IsUpgrade(pID,Name)
end

function UpgradeHero:IsUpgrade(PlayerID,Name)
	if UpgradeHero:GetClassHero(PlayerID) ~= UpgradeHero:GetClassByName(Name) then  return false end
	return PlayerTables:GetTableValue("UpgradeHeroSetting", "SavesUpgrades")[PlayerID] and PlayerTables:GetTableValue("UpgradeHeroSetting", "SavesUpgrades")[PlayerID][Name]
end 

function UpgradeHero:GetClassByName(Name)
	Name = Name:gsub("SpecialUpgrade_","")
	Name = Name:gsub("_","")
	Name = Name:gsub("%d","")
	return Name
end 

function UpgradeHero:GetReplaceUpgrade(Name)
	return "SpecialUpgrade_" .. Name:reverse():sub(1,1);
end 

function UpgradeHero:GetIndexObject(Name)
	return tonumber(Name:gsub("SpecialUpgrade_",""):sub(1,1))
end

function UpgradeHero:GetUpgradeData(Names,pID)
	local t = SETTING_DATA_UPGRADES[Vampires:IsVampire(pID) and "Vampires" or "Mans"]
	local Class = UpgradeHero:GetClassHero(pID)
	local id = UpgradeHero:GetIndexObject(Names)
	local name = UpgradeHero:GetReplaceUpgrade(Names)
	return t and t[Class] and t[Class][id] and t[Class][id][name]
end
function CDOTA_BaseNPC:GetUpgradeData(Names)
	local pID = self:GetPlayerID()
	return UpgradeHero:GetUpgradeData(Names,pID)
end
function UpgradeHero:GetUpgradedClasses(pID)
	return PlayerTables:GetTableValue("UpgradeHeroSetting", "SavesUpgrades") and PlayerTables:GetTableValue("UpgradeHeroSetting", "SavesUpgrades")[pID]
end 

function UpgradeHero:GetClassHero(pID)
	return pID >= 0 and PlayerTables:GetTableValue("DataPlayer", "info") and PlayerTables:GetTableValue("DataPlayer", "info")[pID].classHero or -1
end
