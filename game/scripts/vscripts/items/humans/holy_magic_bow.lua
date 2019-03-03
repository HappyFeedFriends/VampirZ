LinkLuaModifier( "modifier_holy_magic_bow", "items/humans/holy_magic_bow.lua" ,LUA_MODIFIER_MOTION_NONE )

if item_holy_magic_bow == nil then
    item_holy_magic_bow = class({})
end

--------------------------------------------------------------------------------

function item_holy_magic_bow:GetIntrinsicModifierName()
	return "modifier_holy_magic_bow"
end

--------------------------------------------------------------------------------


modifier_holy_magic_bow = class({})


--------------------------------------------------------------------------------

function modifier_holy_magic_bow:DeclareFunctions()
	local funcs = { 
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_holy_magic_bow:OnAttackLanded(keys)
	local caster = self:GetParent()
	local target = keys.target
	local attacker = keys.attacker
	local damage = self:GetAbility():GetSpecialValueFor("damage")

	if caster == attacker and caster:GetTeam() ~= target:GetTeam() then
		local damageInfo = 
		{
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility(), 
		}
		ApplyDamage( damageInfo )
	end
end

--------------------------------------------------------------------------------

function modifier_holy_magic_bow:IsPurgable() return false end
function modifier_holy_magic_bow:IsDebuff() return false end
function modifier_holy_magic_bow:IsHidden() return true end