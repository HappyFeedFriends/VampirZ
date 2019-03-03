if not HeroSelection then
	HeroSelection = class({})

	HeroPick = {}
	STAGE_SELECTION = -1
	STAGE_SELECTION_START = 0
	STAGE_SELECTION_PICKED_HERO = 1
	STAGE_SELECTION_END = 2
	HERO_SELECTION_PICKING_TIME = 30
end

local a_table = a_table or {}
if not a_table[0] then
	for i=0,23 do
		a_table[i] = 0
	end
end
function HeroSelection:Init()
	HeroSelection:StartingTimer()
	STAGE_SELECTION = STAGE_SELECTION_START
end
function HeroSelection:StartingTimer()
	Timers:CreateTimer(1,function()
	CustomGameEventManager:Send_ServerToAllClients("HeroSelectionTimer", {
		time = HERO_SELECTION_PICKING_TIME,
	})
		if HERO_SELECTION_PICKING_TIME > 0 then
			HERO_SELECTION_PICKING_TIME = HERO_SELECTION_PICKING_TIME - 1;
			STAGE_SELECTION = STAGE_SELECTION_PICKED_HERO
			return 1
		else
			STAGE_SELECTION = STAGE_SELECTION_END
			HeroSelection:PickedHeroEnd()
		end 
	end)
end
function HeroSelection:GetSelectionStage()
	return STAGE_SELECTION
end

function HeroSelection:PreLoad()
	local t = {
		agility = {},
		strength = {},
		intellect = {},
	}
	local t_,TableAttributes
	for _,HeroName in pairs(GetAllHeroesNames()) do
		if GetKeyValueByHeroName(HeroName, "HeroClassName") then
			TableAttributes = GetKeyValueByHeroName(HeroName, "AttributePrimary")
			t_ = TableAttributes == "DOTA_ATTRIBUTE_STRENGTH" and t.strength or 
			TableAttributes == "DOTA_ATTRIBUTE_AGILITY" and t.agility or 
			TableAttributes == "DOTA_ATTRIBUTE_INTELLECT" and t.intellect
			table.insert(t_,HeroName)
			CustomNetTables:SetTableValue("HeroSelection", HeroName, HeroSelection:HeroAbility(HeroName))
		end
	end

	CustomNetTables:SetTableValue("HeroSelection", "DOTA_ATTRIBUTE_AGILITY", t.agility)	
	CustomNetTables:SetTableValue("HeroSelection", "DOTA_ATTRIBUTE_STRENGTH", t.strength)	
	CustomNetTables:SetTableValue("HeroSelection", "DOTA_ATTRIBUTE_INTELLECT", t.intellect)	
	CustomNetTables:SetTableValue("HeroSelection", "Effects", GetAllHeroesTablesEffects())
	CustomNetTables:SetTableValue("HeroSelection", "picks", a_table)
	CustomNetTables:SetTableValue("HeroSelection", "settings", {
		["Hero"] = FORCE_PICKED_HERO,
	})
end

function GetAllHeroesTablesEffects()
	local t = {}
	local HeroEffects
	for _,HeroName in pairs(GetAllHeroesNames()) do
		HeroEffects = GetTableEffectsByHero(HeroName)
		if HeroEffects then
			t[HeroName] = HeroEffects
		end
	end
	return t
end 
function GetTableEffectsByHero(HeroName)
	local t = {}
	if GetKeyValueByHeroName(HeroName, "POSITIVITY") then
		t["POSITIVITY"] = GetKeyValueByHeroName(HeroName, "POSITIVITY")
	end
	if GetKeyValueByHeroName(HeroName, "NEGATIVITY") then
		t["NEGATIVITY"] = GetKeyValueByHeroName(HeroName, "NEGATIVITY")
	end
	if not (t["NEGATIVITY"] and t["POSITIVITY"]) then return false  end
	return t
end

function HeroSelection:PickedHero(data)
	if not (data.PlayerID or data.heroName) then return end
	local function PickHero() 
		local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
		if hero:GetUnitName() == data.heroName then Containers:DisplayError(data.PlayerID,"#hud_error_picking_hero") return end
			PlayerResource:ReplaceHeroWith(data.PlayerID, data.heroName, 0, 0 )
			UTIL_Remove(hero)
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID),"HeroSelection_picked", {})
	end
	if not PickPrecacheHero[data.heroName] then
		PrecacheUnitByNameAsync(data.heroName, PickHero,data.PlayerID)
		PickPrecacheHero[data.heroName] = true
	else
		 PickHero()
	end
end 

function HeroSelection:SetHeroPicked(data) 
	local t = CustomNetTables:GetTableValue("HeroSelection","picks")
	t[tostring(data.pID)] = data.heroName
	CustomNetTables:SetTableValue("HeroSelection", "picks", t)

end

function HeroSelection:HeroAbility(hero)
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

function HeroSelection:PickedHeroEnd()
	if HeroSelection:GetSelectionStage() == STAGE_SELECTION_END then
			--HeroSelection:SetRandomVampire()
		HealthBar:Init()		
	end
end 

function HeroSelection:SetRandomVampire()
	local Pickers = false
	local VampireSet = false
	local PlayersID = {}
	for index,value in pairs(PickersHeroes) do
		if value and value == DOTA_TEAM_BADGUYS then
			Pickers = true
			break
		end
	end 
	if Pickers then
		for PlayerID,_ in pairs(PickersHeroes) do
			if RollPercentage(50) and PlayerResource:IsValidPlayerID(PlayerID) and not IsPlayerAbandoned(PlayerID) then
				VampireSet = true
				Vampires:SetAlpha(PlayerID)
				return 
			end 
		end
		if not VampireSet then
			for PlayerID,_ in pairs(PickersHeroes) do
				if PlayerResource:IsValidPlayerID(PlayerID) and not IsPlayerAbandoned(PlayerID) then
					VampireSet = true
					Vampires:SetAlpha(PlayerID)
					return 
				end
			end 
		end 
	else
		for i = 0, DOTA_MAX_PLAYERS - 1 do
			if PlayerResource:IsValidPlayerID(i) and not IsPlayerAbandoned(i) then
				VampireSet = true
				Vampires:SetAlpha(i)
				return 
			end
		end
	end 
end


