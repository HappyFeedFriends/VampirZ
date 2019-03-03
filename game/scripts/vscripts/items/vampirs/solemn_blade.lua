LinkLuaModifier( "modifier_solemn_blade", "items/vampirs/solemn_blade.lua" ,LUA_MODIFIER_MOTION_NONE )

if item_solemn_blade == nil then
    item_solemn_blade = class({})
end

--------------------------------------------------------------------------------

function item_solemn_blade:GetIntrinsicModifierName()
	return "modifier_solemn_blade"
end

--------------------------------------------------------------------------------


modifier_solemn_blade = class({})


--------------------------------------------------------------------------------

function modifier_solemn_blade:DeclareFunctions()
	local funcs = { 
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_solemn_blade:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("damage")
end

--------------------------------------------------------------------------------

function modifier_solemn_blade:OnTakeDamage(params)
    if params.attacker == self:GetParent() then
        local hero = self:GetParent()
        local lifesteal_pct = self:GetAbility():GetSpecialValueFor("vampirism") / 100
        local dmg = params.damage

        local heal_amount = dmg * lifesteal_pct 

        if heal_amount > 0 and hero:GetHealth() ~= hero:GetMaxHealth() then
            hero:Heal(heal_amount, self:GetAbility())
            ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, hero)
        end
    end
end

--------------------------------------------------------------------------------

function modifier_solemn_blade:IsPurgable() return false end
function modifier_solemn_blade:IsDebuff() return false end
function modifier_solemn_blade:IsHidden() return true end