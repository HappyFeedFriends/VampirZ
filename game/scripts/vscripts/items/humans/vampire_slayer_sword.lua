LinkLuaModifier( "modifier_vampire_slayer_sword", "items/humans/vampire_slayer_sword.lua" ,LUA_MODIFIER_MOTION_NONE )

if item_vampire_slayer_sword == nil then
    item_vampire_slayer_sword = class({})
end

--------------------------------------------------------------------------------

function item_vampire_slayer_sword:GetIntrinsicModifierName()
	return "modifier_vampire_slayer_sword"
end

--------------------------------------------------------------------------------


modifier_vampire_slayer_sword = class({})


--------------------------------------------------------------------------------

function modifier_vampire_slayer_sword:DeclareFunctions()
	local funcs = { 
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_vampire_slayer_sword:OnAttackLanded(keys)
	local caster = self:GetParent()
	local target = keys.target
	local attacker = keys.attacker
	local chance = self:GetAbility():GetSpecialValueFor("chance")

	if RollPercentage(chance) then
		if caster == attacker and caster:GetTeam() ~= target:GetTeam() then
			local duration = self:GetAbility():GetSpecialValueFor("duration") + (PlayerResource:GetKills(caster:GetPlayerID()) * 0.2)
			target:AddNewModifier( caster, self:GetAbility(), "modifier_stunned", { duration = duration } )
		end
	end
end

--------------------------------------------------------------------------------

function modifier_vampire_slayer_sword:IsPurgable() return false end
function modifier_vampire_slayer_sword:IsDebuff() return false end
function modifier_vampire_slayer_sword:IsHidden() return true end