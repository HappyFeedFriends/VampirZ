KEYVALUES_VERSION = "1.00"

--[[
	Simple Lua KeyValues library, modified version
	Author: Martin Noya // github.com/MNoya

	Installation:
	- require this file inside your code

	Usage:
	- Your npc custom files will be validated on require, error will occur if one is missing or has faulty syntax.
	- This allows to safely grab key-value definitions in npc custom abilities/items/units/heroes

		"some_custom_entry"
		{
			"CustomName" "Barbarian"
			"CustomKey"  "1"
			"CustomStat" "100 200"
		}

		With a handle:
			handle:GetKeyValue() -- returns the whole table based on the handles baseclass
			handle:GetKeyValue("CustomName") -- returns "Barbarian"
			handle:GetKeyValue("CustomKey")  -- returns 1 (number)
			handle:GetKeyValue("CustomStat") -- returns "100 200" (string)
			handle:GetKeyValue("CustomStat", 2) -- returns 200 (number)

		Same results with strings:
			GetKeyValue("some_custom_entry")
			GetKeyValue("some_custom_entry", "CustomName")
			GetKeyValue("some_custom_entry", "CustomStat")
			GetKeyValue("some_custom_entry", "CustomStat", 2)

	- Ability Special value grabbing:

		"some_custom_ability"
		{
			"AbilitySpecial"
			{
				"01"
				{
					"var_type"    "FIELD_INTEGER"
					"some_key"    "-3 -4 -5"
				}
			}
		}

		With a handle:
			ability:GetAbilitySpecial("some_key") -- returns based on the level of the ability/item

		With string:
			GetAbilitySpecial("some_custom_ability", "some_key")    -- returns "-3 -4 -5" (string)
			GetAbilitySpecial("some_custom_ability", "some_key", 2) -- returns -4 (number)

	Notes:
	- In case a key can't be matched, the returned value will be nil
	- Don't identify your custom units/heroes with the same name or it will only grab one of them.
]]

--if not KeyValues then
	KeyValues = {}
	KeyValues.NameHero = {}
	KeyValues.NameUnits = {}
	KeyValues.NamesAbility = {}
	KeyValues.NameItems = {}
--end

-- Load all the necessary key value files
function LoadGameKeyValues()
	local scriptPath = "scripts/npc/"
	local override = LoadKeyValues(scriptPath.."npc_abilities_override.txt")
	--local heroes = LoadKeyValues(scriptPath.."npc_heroes_custom.txt")
	local files = {
		AbilityKV = {base = "npc_abilities",custom = "npc_abilities_custom"},
		ItemKV = {base = "items", custom = "npc_items_custom"},
		UnitKV = {base = "npc_units", custom = "npc_units_custom"},
		HeroKV = {base = "npc_heroes", custom = "npc_heroes_custom"}
	}
	if not override then
		error("[KeyValues] Critical Error on "..override..".txt")
	end
	-- Load and validate the files
	
	--[[
		
		for k,v in pairs(heroes) do
			if file[k] then
				if type(v) == "table" then
					table.merge(file[k], v)
				else
				--if v:find("tinker") then
					file[k] = v
				end
			end
		end
	]]
	
	for KVType,KVFilePaths in pairs(files) do
		local file = LoadKeyValues(scriptPath .. KVFilePaths.base .. ".txt")
		-- Replace main game keys by any match on the override file
		for k,v in pairs(override) do
			if file[k] then
				if type(v) == "table" then
					table.merge(file[k], v)
				else
					file[k] = v
				end
			end
		end		
		local custom_file = LoadKeyValues(scriptPath .. KVFilePaths.custom .. ".txt")
		if custom_file then
			if KVType == "HeroKV" then
				for k,v in pairs(custom_file) do
					if not file[k] then
						file[k] = {}
						table.deepmerge(file[k], v)
					else
						table.deepmerge(file[k], v)
					end
				end
			else
				table.deepmerge(file, custom_file)
			end												
		else 
			error("[KeyValues] Critical Error on " .. KVFilePaths.custom .. ".txt")
		end
		file.Version = nil
		KeyValues[KVType] = file
	end

	-- Merge All KVs
	KeyValues.All = {}
	for name,path in pairs(files) do
		for key,value in pairs(KeyValues[name]) do
			KeyValues.All[key] = value 
		end
	end
	-- Merge units and heroes (due to them sharing the same class CDOTA_BaseNPC)
	for key,value in pairs(KeyValues.HeroKV) do
		if not KeyValues.UnitKV[key] then
			KeyValues.UnitKV[key] = value
		end
	end	
	for UnitsName,Kv_info in pairs(KeyValues.UnitKV) do 
		if (UnitsName:find("npc_dota_hero_") or UnitsName:find("npc_vampirZ_hero") ) and not UnitsName:find("dummy") and not UnitsName:find("base") then
			table.insert(KeyValues.NameHero,UnitsName)
		else
			table.insert(KeyValues.NameUnits,UnitsName)
		end
	end	
	for AbilityName,Kv_info in pairs(KeyValues["AbilityKV"]) do
		if not AbilityName:find("base") then 
			table.insert(KeyValues.NamesAbility,AbilityName)
		end
	end	
	for ItemName,Kv_info in pairs(KeyValues["ItemKV"]) do
		if not ItemName:find("base") and Kv_info ~= "REMOVE" then
			table.insert(KeyValues.NameItems,ItemName)
		end
	end 
	KeyValues.HeroKV = nil
end
function GetAllHeroesNames()
	return KeyValues.NameHero
end

function GetAllUnitsNames()
	return KeyValues.NameUnits
end

function GetAllAbilityName()
	return KeyValues.NamesAbility
end
function GetAllItemName()
	return KeyValues.NameItems
end 
-- Works for heroes and units on the same table due to merging both tables on game init
function CDOTA_BaseNPC:GetKeyValue(key, level, bOriginalHero)
	return GetUnitKV(bOriginalHero and self:GetUnitName() or self:GetFullName(), key, level)
end
 
-- Dynamic version of CDOTABaseAbility:GetAbilityKeyValues()
function CDOTABaseAbility:GetKeyValue(key, level)
	if level then return GetAbilityKV(self:GetAbilityName(), key, level)
	else return GetAbilityKV(self:GetAbilityName(), key) end
end

function CDOTA_Item:GetKeyValue(key, level)
	if level then return GetItemKV(self:GetAbilityName(), key, level)
	else return GetItemKV(self:GetAbilityName(), key) end
end

function CDOTABaseAbility:GetAbilitySpecial(key)
	return GetAbilitySpecial(self:GetAbilityName(), key, self:GetLevel())
end

function GetKeyValueByHeroName(hero_name, key)
	return GetUnitKV(hero_name, key)
end

-- Global functions
-- Key is optional, returns the whole table by omission
-- Level is optional, returns the whole value by omission
function GetKeyValue(name, key, level, tbl)
	local t = tbl or KeyValues.All[name]
	if key and t then
		if t[key] and level then
			local s = string.split(t[key])
			if s[level] then
				return tonumber(s[level]) or s[level] -- Try to cast to number
			else
				return tonumber(s[#s]) or s[#s]
			end
		else
			return t[key]
		end
	else
		return t
	end
end

function GetUnitKV(unitName, key, level)
	return GetKeyValue(unitName, key, level, KeyValues.UnitKV[unitName])
end

function GetAbilityKV(abilityName, key, level)
	return GetKeyValue(abilityName, key, level, KeyValues.AbilityKV[abilityName])
end

function GetItemKV(itemName, key, level)
	return GetKeyValue(itemName, key, level, KeyValues.ItemKV[itemName])
end

function GetAbilitySpecial(name, key, level, t)
	if not t then t = KeyValues.All[name] end
	if t then
		local AbilitySpecial = t.AbilitySpecial
		if AbilitySpecial then
			if key then
				-- Find the key we are looking for
				for _,values in pairs(AbilitySpecial) do
					if values[key] then
						return GetValueInStringForLevel(values[key], level)
					end
				end
			else
				local o = {}
				for _,values in pairs(AbilitySpecial) do
					for k,v in pairs(values) do
						if k ~= 'var_type' and k ~= 'CalculateSpellDamageTooltip' and k ~= 'levelkey' then
						  o[k] = v
						end
					end
				end
				return o
			end
		end
	end
end

function GetValueInStringForLevel(str, level)
	if not level then
		return str
	else
		local s = string.split(str)
		if s[level] then
			-- If we match the level, return that one
			return tonumber(s[level])
		else
			-- Otherwise, return the max
			return tonumber(s[#s])
		end
	end
end

function GetItemNameById(itemid)
	for name,kv in pairs(KeyValues.ItemKV) do
		if kv and type(kv) == "table" and kv.ID and kv.ID == itemid then
			return name
		end
	end
end

function GetItemIdByName(itemName)
	return KeyValues.ItemKV[itemName].ID
end
LoadGameKeyValues()