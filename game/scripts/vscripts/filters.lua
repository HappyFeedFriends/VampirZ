function VampireZ:FiltersOn()
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(VampireZ, 'ExecuteOrderFilter'), self )
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(VampireZ, 'DamageFilter'), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(VampireZ, 'ModifyGoldFilter'), self)
	--GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(VampireZ, 'ModifyModifierFilter'), self)
end

function VampireZ:ModifyGoldFilter(filterTable)
	filterTable.gold = 0
	return false
end

function VampireZ:ExecuteOrderFilter(filterTable)
	local order_type = filterTable.order_type
	local unit = EntIndexToHScript(filterTable.units["0"])
	local playerId = filterTable.issuer_player_id_const
	local target = EntIndexToHScript(filterTable.entindex_target)
	local ability = EntIndexToHScript(filterTable.entindex_ability)
	local abilityname
	if ability and ability.GetAbilityName then
		abilityname = ability:GetAbilityName()
	end
	if order_type == DOTA_UNIT_ORDER_CAST_POSITION or 
	order_type == DOTA_UNIT_ORDER_CAST_TARGET or
	order_type == DOTA_UNIT_ORDER_CAST_TARGET_TREE  or
	order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET  or
	order_type  == DOTA_UNIT_ORDER_CAST_TOGGLE then
		local kvName = ability:GetKeyValue("AbilityBloodCostPct") and  "AbilityBloodCostPct" or "AbilityBloodCost"
		local kv = ability:GetKeyValue(kvName)
		if ability and abilityname and kv and not unit:IsUpgrade("SpecialUpgrade_2_Alpha_6") then 
			local BloodCost = kvName == "AbilityBloodCostPct" and (unit:GetMaxHealth() / 100 * ability:GetKeyValue(kvName, ability:GetLevel())) or 
			ability:GetKeyValue("AbilityBloodCost", ability:GetLevel())
			if unit:GetHealth() < BloodCost then Containers:DisplayError(unit:GetPlayerID(),"hud_error_enought_health") return false end
			unit:SetHealth(unit:GetHealth() - BloodCost)
		end 
	end
	if order_type == DOTA_UNIT_ORDER_SELL_ITEM then
		local cost = ability:GetCost() or 0
		if unit:IsVampire() then
			unit:ModifyBlood(cost)
		else
			unit:ModifyGold(cost)
		end
	end
	return true
end

function VampireZ:DamageFilter(filterDamage)
-- Fix Swap Hero
		local attacker = filterDamage.entindex_attacker_const and EntIndexToHScript(filterDamage.entindex_attacker_const) 
		if not attacker then return true end 
		local ability,abilityName
		local victim = EntIndexToHScript(filterDamage.entindex_victim_const)
		if filterDamage.entindex_inflictor_const then
			ability = EntIndexToHScript(filterDamage.entindex_inflictor_const )
			if ability and ability.GetAbilityName and ability:GetAbilityName() then
				abilityName = ability:GetAbilityName()
			end
		end
		if attacker:GetModifierLifeSteal() > 0 then
			local lifesteal = attacker:GetModifierLifeSteal()
			attacker:Healing(lifesteal,attacker:IsVampire())
		end 
		local TYPE = filterDamage.damagetype_const
		if victim:HasModifier("modifier_serafims_mantle") then
			local abilities = victim:FindAbilityByName("item_serafims_mantle")
			if abilities then
				local blockV = abilities:GetSpecialValueFor("block")
				local Block = math.floor((filterDamage["damage"] / 100) * blockV)
				filterDamage["damage"] = filterDamage["damage"] - Block 
				SendOverheadEventMessage(victim, OVERHEAD_ALERT_BLOCK, victim, Block, nil)
			end
		end
		if attacker:IsHero() and attacker:IsUpgrade("SpecialUpgrade_2_Gunner_4") then
			if victim:HasModifier("modifier_Trap_hunter_slow") or victim:HasModifier("modifier_gunner_chain_vacum") or victim:HasModifier("modifier_gunner_chain_rope") then
				local bonus = attacker:GetUpgradeData("SpecialUpgrade_2_Gunner_4").Value
				local DpDamage = filterDamage["damage"] * (bonus/100)
				filterDamage["damage"] = filterDamage["damage"] + DpDamage
			end
		end
		if attacker:IsHero() and attacker:IsUpgrade("SpecialUpgrade_3_Gunner_1") then
			local bonus = attacker:GetUpgradeData("SpecialUpgrade_3_Gunner_1").Value
			local DpDamage = filterDamage["damage"] * (bonus/100)
			filterDamage["damage"] = filterDamage["damage"] + DpDamage
		end
	return true
end