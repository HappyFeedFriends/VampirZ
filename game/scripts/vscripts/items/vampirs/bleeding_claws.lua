LinkLuaModifier( "modifier_bleeding_claws", "items/vampirs/bleeding_claws.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bleeding_claws_debuff", "items/vampirs/bleeding_claws.lua" ,LUA_MODIFIER_MOTION_NONE )

if item_bleeding_claws == nil then
    item_bleeding_claws = class({
    	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
    	})
end

--------------------------------------------------------------------------------

function item_bleeding_claws:GetIntrinsicModifierName()
	return "modifier_bleeding_claws"
end

--------------------------------------------------------------------------------


modifier_bleeding_claws = class({
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
	})


--------------------------------------------------------------------------------

function modifier_bleeding_claws:DeclareFunctions()
	local funcs = { 
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_bleeding_claws:OnAttackLanded(keys)
	local caster = self:GetParent()
	local target = keys.target
	local attacker = keys.attacker
	local chance = self:GetAbility():GetSpecialValueFor("chance")

	if RollPercentage(chance) then
		if caster == attacker and caster:GetTeam() ~= target:GetTeam() then
			local duration = self:GetAbility():GetSpecialValueFor("duration")
			target:AddNewModifier( caster, self:GetAbility(), "modifier_bleeding_claws_debuff", { duration = duration } )
		end
	end
end

--------------------------------------------------------------------------------

function modifier_bleeding_claws:IsPurgable() return false end
function modifier_bleeding_claws:IsDebuff() return false end
function modifier_bleeding_claws:IsHidden() return true end

--------------------------------------------------------------------------------


modifier_bleeding_claws_debuff = class({
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
	})


--------------------------------------------------------------------------------

function modifier_bleeding_claws_debuff:OnCreated()
	if IsServer() then
		local interval = self:GetAbility():GetSpecialValueFor("interval")
		self:StartIntervalThink(interval)
	end
end

--------------------------------------------------------------------------------

function modifier_bleeding_claws_debuff:OnIntervalThink()
	local target = self:GetParent()
	local Damage = self:GetAbility():GetSpecialValueFor("damage")

	local damageInfo = 
	{
		victim = target,
		attacker = self:GetCaster(),
		damage = Damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		damage_flags = self:GetAbility():GetAbilityTargetFlags(),
		ability = self:GetAbility(), 
	}
	ApplyDamage( damageInfo )
end

--------------------------------------------------------------------------------

function modifier_bleeding_claws_debuff:IsPurgable() return false end
function modifier_bleeding_claws_debuff:IsDebuff() return true end
function modifier_bleeding_claws_debuff:IsHidden() return false end