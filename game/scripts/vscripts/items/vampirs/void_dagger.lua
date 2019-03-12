LinkLuaModifier( "modifier_void_dagger", "items/vampirs/void_dagger.lua" ,LUA_MODIFIER_MOTION_NONE )

if item_void_dagger == nil then
    item_void_dagger = class({})
end

--------------------------------------------------------------------------------

function item_void_dagger:GetIntrinsicModifierName()
	return "modifier_void_dagger"
end

--------------------------------------------------------------------------------


modifier_void_dagger = class({
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
	})


--------------------------------------------------------------------------------

function modifier_void_dagger:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.03)
	end
end

--------------------------------------------------------------------------------

function modifier_void_dagger:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local distance_value = ability:GetSpecialValueFor("distance_value")
	local max_distance = ability:GetSpecialValueFor("max_distance")
	local min_distance = 1--ability:GetSpecialValueFor("min_distance")

	local distance = max_distance
	local AllHeroes = HeroList:GetAllHeroes()
	for _,hero in ipairs(AllHeroes) do
		local D = (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
		if D <= max_distance and D >= min_distance then
			distance = D < distance and D or distance
		end
	end
	local stacks = max_distance/distance_value - math.floor(distance/distance_value)
	caster:SetModifierStackCount( "modifier_void_dagger", ability, stacks)
end

--------------------------------------------------------------------------------

function modifier_void_dagger:DeclareFunctions()
	local funcs = { 
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_void_dagger:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed_per_distance") * self:GetStackCount()
end

--------------------------------------------------------------------------------

function modifier_void_dagger:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("vision_per_distance") * self:GetStackCount()
end

--------------------------------------------------------------------------------

function modifier_void_dagger:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("vision_per_distance") * self:GetStackCount()
end

--------------------------------------------------------------------------------

function modifier_void_dagger:IsPurgable() return false end
function modifier_void_dagger:IsDebuff() return false end
function modifier_void_dagger:IsHidden() return false end