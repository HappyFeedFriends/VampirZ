LinkLuaModifier( "modifier_dragon_shell", "items/humans/dragon_shell.lua" ,LUA_MODIFIER_MOTION_NONE )

if item_dragon_shell == nil then
    item_dragon_shell = class({})
end

--------------------------------------------------------------------------------

function item_dragon_shell:GetIntrinsicModifierName()
	return "modifier_dragon_shell"
end

--------------------------------------------------------------------------------


modifier_dragon_shell = class({
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
	})


--------------------------------------------------------------------------------

function modifier_dragon_shell:DeclareFunctions()
	local funcs = { 
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_dragon_shell:OnTakeDamage(params)
    if params.attacker ~= self:GetParent() and self:GetParent() == self:GetAbility():GetCaster() then
        local hero = self:GetParent()
        local returnDamage = self:GetAbility():GetSpecialValueFor("return") / 100
        local dmg = params.damage

        local returnAmount = dmg * returnDamage 

        local damageInfo = 
		{
			victim = params.attacker,
			attacker = hero,
			damage = returnAmount,
			damage_type = params.damage_type,
			damage_flags = params.damage_flags,
			ability = self:GetAbility(), 
		}
		ApplyDamage( damageInfo )
    end
end

--------------------------------------------------------------------------------

function modifier_dragon_shell:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("str")
end

--------------------------------------------------------------------------------

function modifier_dragon_shell:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armor")
end

--------------------------------------------------------------------------------

function modifier_dragon_shell:IsPurgable() return false end
function modifier_dragon_shell:IsDebuff() return false end
function modifier_dragon_shell:IsHidden() return true end