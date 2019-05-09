if HeroSelection2 == nil then
	HeroSelection2 = class({})
	PickPrecacheHero = {}
	HeroSelection2.DurationSelection = 70
end
function HeroSelection2:PreLoad()
	HeroSelection2:UpdateTimer()
	local heroList = {}
	for _,HeroName in pairs(GetAllHeroesNames()) do
		if GetKeyValueByHeroName(HeroName, "HeroClassName")   then
			heroList[HeroName] = {
				ability = HeroSelection2:HeroAbility(HeroName),
				class = GetKeyValueByHeroName(HeroName, "HeroClassName"),
				IsVampire = GetKeyValueByHeroName(HeroName, "IsVampire") == 1,
				IsLocked = GetKeyValueByHeroName(HeroName, "PickLocked") == 1
			}
		end
	end
	CustomNetTables:SetTableValue("HeroSelection", 'HeroList', heroList)
	CustomNetTables:SetTableValue("HeroSelection", 'SelectedHeroes', {})
	CustomNetTables:SetTableValue("HeroSelection", 'Setting', {
			defaultHero = FORCE_PICKED_HERO,
			FirstVampire = HeroSelection2:SetFirstVampire(),
			DurationSelection = HeroSelection2.DurationSelection,
	})
end 

function HeroSelection2:UpdateTimer()
	Timers:CreateTimer(function()
		local t = CustomNetTables:GetTableValue('HeroSelection','Setting') or {}
		t['DurationSelection'] = math.max(t['DurationSelection'] - 1,0)
		CustomNetTables:SetTableValue("HeroSelection", 'Setting', t)
		CustomGameEventManager:Send_ServerToAllClients("HeroSelectionUpdateTimer", {})
		if t['DurationSelection'] <= 0 then
			HealthBar:Init()
		end
		return t['DurationSelection'] > 0 and 1 or nil
	end)
end

function HeroSelection2:SelectHero(data) 
	if not (data.PlayerID or data.heroName) then return end
	local function PickHero() 
		local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
		if hero:GetUnitName() == data.heroName then return end
			PlayerResource:ReplaceHeroWith(data.PlayerID, data.heroName, 0, 0 )
			UTIL_Remove(hero)
			PickPrecacheHero[data.heroName] = true
			HeroSelection2:SafeSelectionHeroes(data.PlayerID,data.heroName)
			CustomGameEventManager:Send_ServerToAllClients("HeroSelectionUpdateRight", {
				PlayerID = data.PlayerID,
				HeroName = data.heroName,
			})
			UpgradeHero:SetClassHero({
				pID = data.PlayerID
			})
			
	end
	if not PickPrecacheHero[data.heroName] then
		PrecacheUnitByNameAsync(data.heroName, PickHero,data.PlayerID)
	else
		 PickHero()
	end
end
function HeroSelection2:SafeSelectionHeroes(pID,heroName)
	local table = CustomNetTables:GetTableValue('HeroSelection','SelectedHeroes') or {}
	table[pID] = heroName
	CustomNetTables:SetTableValue("HeroSelection", 'SelectedHeroes', table)
end

function HeroSelection2:HeroAbility(hero)
local full = KeyValues.UnitKV
local heroes = {}
	for i = 1,24 do
		if full[hero]["Ability" .. i] and	not 
		full[hero]["Ability" .. i]:find("special_bonus_") and 
		full[hero]["Ability" .. i] ~= "" and
		full[hero]["Ability" .. i] ~= "generic_hidden" then
			table.insert(heroes, full[hero]["Ability" .. i])
		end
	end
	return heroes
end

function HeroSelection2:RandomPickHero()
	PlayerResource:PlayerIterate(function(pID)
		if PlayerResource:GetSelectedHeroName(pID) == FORCE_PICKED_HERO then
			HeroSelection2:SelectHero({
				PlayerID = pID,
				heroName = HeroSelection2:GetRandomHero(pID),
				}) 
		end
	end)
end 

function HeroSelection2:GetRandomHero(pID)
	local heroes = CustomNetTables:GetTableValue("HeroSelection", 'HeroList')
	local heroList = {}
	if Vampires:IsAlpha(pID) then return "npc_dota_hero_night_stalker" end
	if Vampires:IsVampire(pID) then
		for k,v in pairs(heroes) do 
			if v.IsVampire == 1 and v.IsLocked ~= 1 then
				table.insert(heroList,k)
			end 
		end
		return heroList[RandomInt(1,#heroList)]
	else
		for k,v in pairs(heroes) do 
			if v.IsVampire == 0 and v.IsLocked ~= 1 then
				table.insert(heroList,k)
			end 
		end
		return heroList[RandomInt(1,#heroList)]
	end
end
function HeroSelection2:SetFirstVampire()
	if HeroSelection2.FirstVampire then return HeroSelection2.FirstVampire end
		for index,value in pairs(PickersHeroes) do 
			if ( RollPercentage(50) and PlayerResource:IsValidPlayerID(index) and not IsPlayerAbandoned(index) and value == DOTA_TEAM_BADGUYS) then
				HeroSelection2.FirstVampire = index
				break
			end
		end 
		if not HeroSelection2.FirstVampire then
			for index,value in pairs(PickersHeroes) do 
				if ( PlayerResource:IsValidPlayerID(index) and not IsPlayerAbandoned(index) and value == DOTA_TEAM_BADGUYS) then
					HeroSelection2.FirstVampire = index
					break
				end
			end 
		end
		if not HeroSelection2.FirstVampire then
			for i = 0, DOTA_MAX_PLAYERS - 1 do
				if PlayerResource:IsValidPlayerID(i) and not IsPlayerAbandoned(i) then
					HeroSelection2.FirstVampire = i
					break 
				end
			end
		end
	--HeroSelection2.FirstVampire = 1
	return HeroSelection2.FirstVampire 
end
--PlayerResource:GetSelectedHeroEntity(0):RemoveModifierByName('modifier_stunned')