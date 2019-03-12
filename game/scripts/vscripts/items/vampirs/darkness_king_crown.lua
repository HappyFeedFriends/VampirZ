LinkLuaModifier( "modifier_darkness_king_crown", "items/vampirs/darkness_king_crown.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_darkness_king_crown_zombies", "items/vampirs/darkness_king_crown.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_darkness_king_crown_humans", "items/vampirs/darkness_king_crown.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_darkness_king_crown_vampirs", "items/vampirs/darkness_king_crown.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_darkness_king_crown_if_target", "items/vampirs/darkness_king_crown.lua" ,LUA_MODIFIER_MOTION_NONE )

if item_darkness_king_crown == nil then
    item_darkness_king_crown = class({})
end

--------------------------------------------------------------------------------

function item_darkness_king_crown:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()
	local human_dur = self:GetSpecialValueFor("vision_if_human_dur")
	local point_dur = self:GetSpecialValueFor("vision_if_point_dur")
	local vision = self:GetSpecialValueFor("vision_if_point")

	if target ~= nil then
		target:AddNewModifier( caster, self, "modifier_darkness_king_crown_if_target", { duration = human_dur } )
	elseif target == nil then
		AddFOWViewer(caster:GetTeamNumber(), point, vision, point_dur, false)
	end
end

--------------------------------------------------------------------------------

function item_darkness_king_crown:GetIntrinsicModifierName()
	return "modifier_darkness_king_crown"
end

--------------------------------------------------------------------------------


modifier_darkness_king_crown = class({
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
	})


--------------------------------------------------------------------------------

function modifier_darkness_king_crown:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.01)
	end
end

--------------------------------------------------------------------------------

function modifier_darkness_king_crown:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local aura_radius = ability:GetSpecialValueFor("aura_radius")

	local Units = FindUnitsInRadius(caster:GetTeamNumber(),
									caster:GetAbsOrigin(),
									nil,
									aura_radius,
									DOTA_UNIT_TARGET_TEAM_BOTH,
									ability:GetAbilityTargetType(),
									ability:GetAbilityTargetFlags(),
									0, 
									false)
	for count, unit in ipairs(Units) do
		if unit:GetTeam() == caster:GetTeam() then
			if unit:IsCreature() then
				unit:AddNewModifier( caster, ability, "modifier_darkness_king_crown_zombies", { duration = 1.0 } )
			elseif unit:IsRealHero() then
				unit:AddNewModifier( caster, ability, "modifier_darkness_king_crown_vampirs", { duration = 1.0 } )
			end
		else
			unit:AddNewModifier( caster, ability, "modifier_darkness_king_crown_humans", { duration = 1.0 } )
		end
	end
end

--------------------------------------------------------------------------------

function modifier_darkness_king_crown:IsPurgable() return false end
function modifier_darkness_king_crown:IsDebuff() return false end
function modifier_darkness_king_crown:IsHidden() return true end

--------------------------------------------------------------------------------


modifier_darkness_king_crown_zombies = class({
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
	})


--------------------------------------------------------------------------------

function modifier_darkness_king_crown_zombies:DeclareFunctions()
	local funcs = { 
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_darkness_king_crown_zombies:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("zombies_regen")
end

--------------------------------------------------------------------------------

function modifier_darkness_king_crown_zombies:IsPurgable() return false end
function modifier_darkness_king_crown_zombies:IsDebuff() return false end
function modifier_darkness_king_crown_zombies:IsHidden() return false end

--------------------------------------------------------------------------------


modifier_darkness_king_crown_vampirs = class({
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
	})


--------------------------------------------------------------------------------

function modifier_darkness_king_crown_vampirs:DeclareFunctions()
	local funcs = { 
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_darkness_king_crown_vampirs:GetBonusDayVision()
    return self:GetAbility():GetSpecialValueFor("vampirs_vision_bonus")
end

--------------------------------------------------------------------------------

function modifier_darkness_king_crown_vampirs:GetBonusNightVision()
    return self:GetAbility():GetSpecialValueFor("vampirs_vision_bonus")
end

--------------------------------------------------------------------------------

function modifier_darkness_king_crown_vampirs:IsPurgable() return false end
function modifier_darkness_king_crown_vampirs:IsDebuff() return false end
function modifier_darkness_king_crown_vampirs:IsHidden() return false end

--------------------------------------------------------------------------------


modifier_darkness_king_crown_humans = class({
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
	})


--------------------------------------------------------------------------------

function modifier_darkness_king_crown_humans:DeclareFunctions()
	local funcs = { 
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_darkness_king_crown_humans:GetBonusVisionPercentage()
    return self:GetAbility():GetSpecialValueFor("humans_vision_reduce")
end

--------------------------------------------------------------------------------

function modifier_darkness_king_crown_humans:IsPurgable() return false end
function modifier_darkness_king_crown_humans:IsDebuff() return false end
function modifier_darkness_king_crown_humans:IsHidden() return false end

--------------------------------------------------------------------------------


modifier_darkness_king_crown_if_target = class({
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
	})


--------------------------------------------------------------------------------

function modifier_darkness_king_crown_if_target:DeclareFunctions()
	local funcs = { 
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_darkness_king_crown_if_target:GetBonusVisionPercentage()
    return self:GetAbility():GetSpecialValueFor("vision_if_human")
end

--------------------------------------------------------------------------------

function modifier_darkness_king_crown_if_target:IsPurgable() return false end
function modifier_darkness_king_crown_if_target:IsDebuff() return false end
function modifier_darkness_king_crown_if_target:IsHidden() return false end