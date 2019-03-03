LinkLuaModifier( "modifier_saintly_bell_passive", "items/humans/saintly_bell.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_saintly_bell_agr", "items/humans/saintly_bell.lua" ,LUA_MODIFIER_MOTION_NONE )

if item_saintly_bell == nil then
    item_saintly_bell = class({})
end

--------------------------------------------------------------------------------

function item_saintly_bell:OnSpellStart()
	local caster = self:GetCaster()
	self.point = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local speed = self:GetSpecialValueFor("bell_speed")

	local Direction = self.point - caster:GetAbsOrigin()
	--Direction.z = 0.0

	local Direction = Direction * self:GetCastRange(caster:GetAbsOrigin(),caster)

	local bell = 
	{
		Ability = self,
		EffectName = "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_headflame.vpcf",
		vSpawnOrigin = caster:GetOrigin(),
		fDistance = self:GetCastRange(caster:GetAbsOrigin(),caster),
		fStartRadius = radius,
		fEndRadius = radius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		vVelocity = Direction:Normalized() * speed,
	}
	ProjectileManager:CreateLinearProjectile(bell)
end

--------------------------------------------------------------------------------

function item_saintly_bell:OnProjectileHit(hTarget)
	if IsServer() and hTarget and not hTarget:IsAlpha() then
		local caster = self:GetCaster()

		if hTarget and hTarget:IsRealHero() then
			local duration = self:GetSpecialValueFor("duration")
			local order = 
			{
				UnitIndex = hTarget:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position  = self.point
			}
			hTarget:Stop()
			ExecuteOrderFromTable(order)
			hTarget:AddNewModifier( caster, self, "modifier_saintly_bell_agr", { duration = duration } )
		end
	end
end

--------------------------------------------------------------------------------

function item_saintly_bell:GetIntrinsicModifierName()
	return "modifier_saintly_bell_passive"
end

--------------------------------------------------------------------------------


modifier_saintly_bell_passive = class({})


--------------------------------------------------------------------------------

function modifier_saintly_bell_passive:DeclareFunctions()
	local funcs = { 
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_saintly_bell_passive:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("regen")
end

--------------------------------------------------------------------------------

function modifier_saintly_bell_passive:IsPurgable() return false end
function modifier_saintly_bell_passive:IsDebuff() return false end
function modifier_saintly_bell_passive:IsHidden() return false end

--------------------------------------------------------------------------------


modifier_saintly_bell_agr = class({})

function modifier_saintly_bell_agr:OnCreated()
	self:GetParent().aggresive = true
end

function modifier_saintly_bell_agr:OnDestroy()
	self:GetParent().aggresive = nil
end

--------------------------------------------------------------------------------

function modifier_saintly_bell_agr:CheckState()
	local state = {}
	if IsServer() then
		state[MODIFIER_STATE_DISARMED] = true
		state[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	end
	
	return state
end

--------------------------------------------------------------------------------

function modifier_saintly_bell_agr:IsPurgable() return false end
function modifier_saintly_bell_agr:IsDebuff() return true end
function modifier_saintly_bell_agr:IsHidden() return false end