if item_aspen_stake == nil then
    item_aspen_stake = class({})
end

--------------------------------------------------------------------------------

function item_aspen_stake:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damageV = self:GetSpecialValueFor("damage")
	local damage = target:GetMaxHealth() / 100 * damageV

	local damageInfo = 
	{
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		damage_flags = self:GetAbilityTargetFlags(),
		ability = self, 
	}
	
	ApplyDamage( damageInfo )
end