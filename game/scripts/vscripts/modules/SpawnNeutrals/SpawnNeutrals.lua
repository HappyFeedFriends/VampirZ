if not SpawnNeutrals then 
	SpawnNeutrals = class({})
	SpawnNeutrals.EntitySpawners = {}
	SpawnNeutrals.UnitsList = {}
	SpawnNeutrals.SpawnCount = 0
	SpawnNeutrals.MiniBossCount = 0
	SpawnNeutrals.UnitsCount = 0
end

ModuleRequire(...,"data")
function SpawnNeutrals:PreLoad()
	for name,value in pairs(NEUTRALS_SPAWN_UNITS) do
		if name and value then
			table.insert(SpawnNeutrals.UnitsList, name)
		end 
	end	 
end 

function CDOTA_BaseNPC:IsMiniBoss()
	return self.miniBoss
end

function CDOTA_BaseNPC:IsWaveUnit()
	return self.WaveUnit
end

function SpawnNeutrals:GetSpawnNumber()
	return SpawnNeutrals.SpawnCount
end

function SpawnNeutrals:RandomSpawns()
	self.EntitySpawners = {}
	local entity = Entities:FindAllByClassname("info_target")
	for _,v in ipairs(entity) do
		local entname = v:GetName()
		if string.find(entname, "spawn_neutrals") then
			table.insert(SpawnNeutrals.EntitySpawners, v)
		end
	end
	local SpawnsCount = #self.EntitySpawners
	local ActiveSpawns = SpawnNeutrals:GetLimits().CountActiveSpawns
	local SpawnsToDelete = SpawnsCount - ActiveSpawns
	for i=1, SpawnsToDelete do
		SpawnsCount = #self.EntitySpawners
		local Random = RandomInt(1, SpawnsCount)
		table.remove(SpawnNeutrals.EntitySpawners, Random)
	end
end

function SpawnNeutrals:Init()
	local Origin
	Timers:CreateTimer(1,function()
		if SPAWN_UNIT then
			SpawnNeutrals:RandomSpawns()
			SpawnNeutrals.SpawnCount = SpawnNeutrals:GetSpawnNumber() + 1
			for _,v in pairs(self.EntitySpawners) do
				Origin = v:GetAbsOrigin()
				SpawnNeutrals:SpawnByEntityUnits(Origin)
			end
		end
	return NEUTRALS_SPAWN_SETTINGS.WavesDelay
	end)
end
			SpawnNeutrals:RandomSpawns()
			SpawnNeutrals.SpawnCount = SpawnNeutrals:GetSpawnNumber() + 1
			for _,v in pairs(SpawnNeutrals.EntitySpawners) do
				Origin = v:GetAbsOrigin()
				SpawnNeutrals:SpawnByEntityUnits(Origin)
			end
function SpawnNeutrals:GetRandomUnitName() 
	return PickRandomValueTable(SpawnNeutrals.UnitsList)
end 
function SpawnNeutrals:GetSettingMBossByName(UnitName) 
	return NEUTRALS_SPAWN_UNITS[UnitName].MiniBoss
end

function SpawnNeutrals:GetStatsTable(UnitName)
	return NEUTRALS_SPAWN_UNITS[UnitName].StatsPerSpawn
end 
function SpawnNeutrals:GetLimits() 
	return NEUTRALS_SPAWN_SETTINGS.Limits
end
function SpawnNeutrals:GetUnitCountToMap() 
	return SpawnNeutrals.UnitsCount
end

function SpawnNeutrals:GetMultiply(UnitName)
	return NEUTRALS_SPAWN_UNITS[UnitName].MiniBoss.MultiplyStats or 1
end
function SpawnNeutrals:SetNewModel(unit)
	local modelScale = unit:IsMiniBoss() and SpawnNeutrals:GetSettingMBossByName(unit:GetUnitName()).ModelScale or 1
	local model =  unit:IsMiniBoss() and PickRandomValueTable(SpawnNeutrals:GetSettingMBossByName(unit:GetUnitName()).Models) or table.nearestOrLowerKey(NEUTRALS_SPAWN_UNITS[unit:GetUnitName()].Models, SpawnNeutrals:GetSpawnNumber())
	if model then
		unit:SetModel(model)
		unit:SetOriginalModel(model)
	end
	unit:SetModelScale(modelScale)
end 

function SpawnNeutrals:CreateUnitByName(Origin,miniboss)

	if SpawnNeutrals:GetUnitCountToMap() < SpawnNeutrals:GetLimits().CreepMapLimit then 
		local UnitName = SpawnNeutrals:GetRandomUnitName()
		local unit = CreateUnitByName(UnitName, Origin, true, nil, nil, DOTA_TEAM_BADGUYS)
		local stats = SpawnNeutrals:GetStatsTable(UnitName)
		local SpawnNumber = SpawnNeutrals:GetSpawnNumber()	
		local xp,gold,health,damage,armor,healthRegen = stats.xp * SpawnNumber,stats.gold * SpawnNumber,stats.health * SpawnNumber,stats.damage * SpawnNumber,stats.armor * SpawnNumber,stats.healthRegen * SpawnNumber
		
		if miniboss then
			local Mult = SpawnNeutrals:GetMultiply(UnitName)
			local settingMB = SpawnNeutrals:GetSettingMBossByName(UnitName)
			unit.miniBoss = miniboss
			xp = xp * Mult
			gold = gold * Mult
			health = health * Mult
			damage = damage * Mult
			armor = armor * Mult
			healthRegen = healthRegen * Mult
		end
		unit:SetDeathXP(xp * SpawnNumber)
		unit:SetMinimumGoldBounty(gold)
		unit:SetMaximumGoldBounty(gold)
		unit:SetMaxHealth(health)
		unit:SetBaseMaxHealth(health)
		unit:SetHealth(health)
		unit:SetBaseDamageMin(damage)
		unit:SetBaseDamageMax(damage)
		unit:SetPhysicalArmorBaseValue(armor)
		unit:SetBaseMagicalResistanceValue(25)
		unit:SetBaseHealthRegen(healthRegen)
		SpawnNeutrals:SetNewModel(unit)
		SpawnNeutrals.UnitsCount = SpawnNeutrals:GetUnitCountToMap() + 1
		unit.WaveUnit = true
	end
end
function SpawnNeutrals:SpawnByEntityUnits(Origin)
	local unit,miniboss
	for i=1,NEUTRALS_SPAWN_SETTINGS.CreepPerSpawn do
		miniboss = false	
		if RollPercentage(NEUTRALS_SPAWN_SETTINGS.SpawnChanceMiniBoss) and SpawnNeutrals.MiniBossCount < SpawnNeutrals:GetLimits().MiniBossLimit and not boss then
			SpawnNeutrals.MiniBossCount = SpawnNeutrals.MiniBossCount + 1
			miniboss = true
		end 
		unit = SpawnNeutrals:CreateUnitByName(Origin,miniboss)
	end 
end 
function RemoveAllSpawnedUnits()
	for k,v in pairs(SpawnNeutrals.UnitsList) do
		RemoveAllUnitsByName(v)
	end	
end

function SpawnNeutrals:SpawnNightHunter()
	SpawnNeutrals:RandomSpawns()
	local Origin = self.EntitySpawners[RandomInt(1,#self.EntitySpawners)]:GetAbsOrigin()
	local unit = CreateUnitByName(NIGHT_HUNTER_DATA.name, Origin, true, nil, nil, DOTA_TEAM_BADGUYS)
	unit:SetModelScale(1.8)
	unit:SetMinimumGoldBounty(0)
	unit:SetMaximumGoldBounty(0)
	unit:SetMaxHealth(NIGHT_HUNTER_DATA.STATS.health)
	unit:SetBaseMaxHealth(NIGHT_HUNTER_DATA.STATS.health)
	unit:SetHealth(NIGHT_HUNTER_DATA.STATS.health)
	unit:SetBaseDamageMin(NIGHT_HUNTER_DATA.STATS.Damage[1]/2)
	unit:SetBaseDamageMax(NIGHT_HUNTER_DATA.STATS.Damage[1] * 2)
	unit:SetPhysicalArmorBaseValue(NIGHT_HUNTER_DATA.STATS.armor)
	unit:SetBaseMagicalResistanceValue(NIGHT_HUNTER_DATA.STATS.magicResist)
	unit:SetBaseHealthRegen(NIGHT_HUNTER_DATA.STATS.healthRegen)
	unit:SetDeathXP(NIGHT_HUNTER_DATA.Xp)
	unit.IsNightHunter = true
	unit.stage = 1
	HealthBar.NightHunter = unit
	kills:CreateCustomToast({
		type = "generic",
		text = "#custom_toast_nightHunterAlive"
	})
	AddFOWViewer( DOTA_TEAM_GOODGUYS, Origin, 900, 5*60, false )

end