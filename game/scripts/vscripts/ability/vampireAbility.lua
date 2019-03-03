LinkLuaModifier ("modifier_VampireTransformBat", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireShield", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireShadowMistAura", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireClaws", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampirBloodCauldron", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_vampireShadowVeil", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_DevourerSpecialUpgrade", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireFlar", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireStigma_debuff", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_vampireattack_buff", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_vampire_devourment_debuff", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_vampireDarkScar_buff", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireBloodPulse_buff", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireMirrorEdge_buff", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireShield_buff", "ability/vampireAbility", LUA_MODIFIER_MOTION_NONE)
-- upgrades list for abilities
local dataName = {
	"SpecialUpgrade_2_Alpha_1", -- Alpha
	"SpecialUpgrade_2_Alpha_2",
	"SpecialUpgrade_2_Alpha_3",--//
	"SpecialUpgrade_2_Alpha_4",--//
	"SpecialUpgrade_2_Alpha_5",--//
	"SpecialUpgrade_2_Alpha_6",--//
	"SpecialUpgrade_2_Alpha_7", --
	"SpecialUpgrade_2_Alpha_8", --
	
	"SpecialUpgrade_1_Beta_1", -- Support (9 - 16)
	"SpecialUpgrade_1_Beta_2",
	"SpecialUpgrade_1_Beta_3",
	"SpecialUpgrade_1_Beta_4",
	"SpecialUpgrade_1_Beta_5",
	"SpecialUpgrade_1_Beta_6",
	"SpecialUpgrade_1_Beta_7",
	"SpecialUpgrade_1_Beta_8",
	
	"SpecialUpgrade_2_Beta_1", -- Attacking (17 - 25)
	"SpecialUpgrade_2_Beta_2", 
	"SpecialUpgrade_2_Beta_3", 
	"SpecialUpgrade_2_Beta_4", 
	"SpecialUpgrade_2_Beta_5", 
	"SpecialUpgrade_2_Beta_6", 
	"SpecialUpgrade_2_Beta_7", 
	"SpecialUpgrade_2_Beta_8", 
	
	"SpecialUpgrade_3_Beta_1", -- Defense (26 - 34)
	"SpecialUpgrade_3_Beta_2",
	"SpecialUpgrade_3_Beta_3",
	"SpecialUpgrade_3_Beta_4",
	"SpecialUpgrade_3_Beta_5",
	"SpecialUpgrade_3_Beta_6",
	"SpecialUpgrade_3_Beta_7",
	"SpecialUpgrade_3_Beta_8",
}
if not VampireBatTransform then
	VampireBatTransform = class({})
end

function VampireBatTransform:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster,self,"modifier_VampireTransformBat",{duration = self:GetSpecialValueFor("duration")})
end

if not modifier_VampireTransformBat then
	modifier_VampireTransformBat = class({})
end 

modifier_VampireTransformBat = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return {MODIFIER_PROPERTY_MODEL_CHANGE} end,
	GetModifierModelChange  = function(self) return "models/items/death_prophet/exorcism/awakened_thirst_bats/awakened_thirst_bats.vmdl" end,
})

function modifier_VampireTransformBat:CheckState()
	return {
		[MODIFIER_STATE_HEXED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
end

if not VampireShield then
	VampireShield = class({})
end

function VampireShield:OnSpellStart()
	local caster = self:GetCaster()
	local absorbDamage = self:GetSpecialValueFor("absorb_damage")
	local duration = self:GetSpecialValueFor("duration")
	if not caster:HasModifier("modifier_VampireShield") then
		caster:AddStackModifier({	
			ability = self,
			modifier = "modifier_VampireShield",
			duration = duration,
			count = absorbDamage * (self:GetCaster():IsUpgrade("SpecialUpgrade_3_Beta_7") and self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Beta_7").Value or 1),
		})
	end
	if self:GetCaster():IsUpgrade("SpecialUpgrade_3_Beta_7") then
		self:NewCooldown(self:GetCooldown(self:GetLevel()) + self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Beta_7").RemoveSec )
	end 	
	if self:GetCaster():IsUpgrade("SpecialUpgrade_3_Beta_5") then
		caster:AddNewModifier(caster,self,"modifier_VampireShield_buff",{duration = duration})
	end 
end 

modifier_VampireShield_buff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end,
	GetModifierMoveSpeedBonus_Percentage = function(self) return self:GetSharedKey("movespeed") end,
})

function modifier_VampireShield_buff:OnCreated()
	if IsServer() then
		self:SetSharedKey("movespeed",self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Beta_5").ValueMS)
		self:StartIntervalThink(self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Beta_5").Value)
	end
end

function modifier_VampireShield_buff:OnIntervalThink()
	self:GetCaster():Purge(false, true, false, true, true)
end

modifier_VampireShield = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return {MODIFIER_EVENT_ON_TAKEDAMAGE} end,
})

function modifier_VampireShield:OnTakeDamage(keys)
	if keys.unit == self:GetCaster() and IsServer() then
		if self:GetCaster():GetModifierStackCount( "modifier_VampireShield", self:GetAbility() ) > 0 then
			local hp = self:GetCaster():GetHealth()
			local current_stack = self:GetCaster():GetModifierStackCount( "modifier_VampireShield", self:GetAbility() )
			local damage = keys.damage
			--local absorb = (current_stack - damage) >= 0 and (current_stack - damage) or damage > current_stack and damage-current_stack or 0
			self:GetCaster():SetHealth(self:GetCaster():GetHealth() + damage)
			self:GetCaster():SetModifierStackCount( "modifier_VampireShield", self:GetAbility(), current_stack - damage )
			if self:GetCaster():GetModifierStackCount( "modifier_VampireShield", self:GetAbility() ) <= 0 then
				self:Destroy()
			end 
		else
			self:Destroy()
		end
	end
end

function modifier_VampireShield:OnCreated()
	if IsServer() then
		local shield_size = 80 * self:GetCaster():GetModelScale()
		self.particle = ParticleManager:CreateParticle("particles/vampirz/vampireshieldmain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(self.particle, 1, Vector(shield_size,0,shield_size))		
		ParticleManager:SetParticleControl(self.particle, 2, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(self.particle, 4, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(self.particle, 5, Vector(shield_size,0,0))
		ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	end
end

function modifier_VampireShield:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.particle, false)
		if self:GetCaster():IsUpgrade(dataName[2]) then
			local data = self:GetCaster():GetUpgradeData(dataName[2])
			local Damage = data.Value
			local Radius = data.Radius
			local DurationStun = data.DurationStun
			local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,Radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER, false)
			for k,v in pairs(units) do
				ApplyDamage({
					victim = v,
					attacker = self:GetCaster(),
					damage = Damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
				})
				v:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_stunned",{duration = DurationStun})
			end 
		end 
	end 
end 

if not VampireShadowMist then
	VampireShadowMist = class({})
end

function VampireShadowMist:OnSpellStart()
	self.point = self:GetCursorTarget() and self:GetCursorTarget():GetAbsOrigin() or self:GetCaster():GetAbsOrigin()
	local duration = self:GetSpecialValueFor("delay")
	CreateModifierThinker(self:GetCaster(),self, "modifier_VampireShadowMistAura", {duration = duration},  self.point, self:GetCaster():GetTeamNumber(), false)
end 

modifier_VampireShadowMistAura = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	IsAura 					= function(self) return true end,
	GetAuraRadius 			= function(self) return self:GetAbility():GetSpecialValueFor("radius") end,
})
function modifier_VampireShadowMistAura:OnCreated()
	if IsServer() then
		self.size = self:GetAuraRadius()
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(self.particle, 0, self:GetAbility().point)
		ParticleManager:SetParticleControl(self.particle, 1, Vector(self.size,self.size,self.size))
		ParticleManager:SetParticleControl(self.particle, 15, Vector(228,8,8))
		ParticleManager:SetParticleControl(self.particle, 16, Vector(self.size,self.size,self.size))
	end
end 

function modifier_VampireShadowMistAura:OnDestroy()
	if IsServer() then
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetAbility().point,nil,self.size,DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for _,v in pairs(units) do
			ApplyDamage({
				victim = v,
				attacker = self:GetCaster(),
				damage = self:GetAbility():GetSpecialValueFor("damage"),
				damage_type = self:GetAbility():GetAbilityDamageType(),
			})
		end 
		ParticleManager:DestroyParticle(self.particle, true)
	end
end 

if not Vampire_Claws then
	Vampire_Claws = class({})
end

function Vampire_Claws:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_VampireClaws",{duration = -1})
	else
		self:GetCaster():RemoveModifierByName("modifier_VampireClaws")
	end
end 

modifier_VampireClaws = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED} end,
}) 

function modifier_VampireClaws:OnAttackLanded(data)
	if data.attacker == self:GetCaster() and IsServer() and ( self:GetCaster():IsUpgrade(dataName[1]) or self:GetCaster():GetHealth() > self:GetAbility():GetSpecialValueFor("healthCost") + 1) then
		if not self:GetCaster():IsUpgrade(dataName[1]) then
			self:GetCaster():Heal(self:GetAbility():GetSpecialValueFor("healthCost"),self:GetCaster())
		else
			local mana = self:GetCaster():GetUpgradeData(dataName[1]).Value * self:GetAbility():GetSpecialValueFor("healthCost")
			if self:GetCaster():GetMana() < -mana then return end
			self:GetCaster():ReduceMana(-mana)
		end
		ApplyDamage({
			victim = data.target,
			attacker = self:GetCaster(),
			damage = self:GetAbility():GetSpecialValueFor("bonus_damage"),
			damage_type = self:GetAbility():GetAbilityDamageType(),
		})
	end 
end 

if not Vampir_BloodCauldron then
	Vampir_BloodCauldron = class({})
end 

function Vampir_BloodCauldron:OnSpellStart()
	local target = self:GetCursorTarget()
	target:AddNewModifier(self:GetCaster(),self,"modifier_VampirBloodCauldron",{duration = 0.4})
end 

modifier_VampirBloodCauldron = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
}) 

function modifier_VampirBloodCauldron:OnDestroy()
	if IsServer() then
		local target = self:GetParent()
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),target:GetAbsOrigin(),nil,self:GetAbility():GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
		self.particle = ParticleManager:CreateParticle("particles/vampirz/vampir_bloodcauldronmain.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		ParticleManager:SetParticleControl(self.particle, 0, target:GetAbsOrigin())
		Timers:CreateTimer(2,function()
			ParticleManager:DestroyParticle(self.particle, true)
		end)
		for _,v in pairs(units) do
			ApplyDamage({
				victim = v,
				attacker = self:GetCaster(),
				damage = self:GetAbility():GetSpecialValueFor("damage") + (#units * (self:GetCaster():GetHealth()/100 * self:GetAbility():GetSpecialValueFor("damage_bonus"))),
				damage_type = self:GetAbility():GetAbilityDamageType(),
			})
		end 
	end 
end

if not VampireDevourer then
	VampireDevourer = class({})
end 

function VampireDevourer:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster == target then 
		self:EndCooldown()
		return 
	end 
	local cost = self:GetSpecialValueFor("healing")
	if target:GetHealthPercent() < cost + 1 then
		Containers:DisplayError(caster:GetPlayerID(),"hud_error_enought_health")
		self:EndCooldown()
		return 
	end 
	local heal = target:GetMaxHealth()/100 * cost
	if target:IsUpgrade(dataName[11]) then
		heal = heal + target:GetUpgradeData(dataName[11]).Value
	end
	caster:SetHealth(caster:GetHealth() + heal)
	if target:IsUpgrade(dataName[8]) then
		target:Kill(self,caster)
		local data = caster:GetUpgradeData(dataName[8])
		caster:ModifyStrength(data.Value)
		caster:ModifyAgility(data.Value)
		caster:ModifyIntellect(data.Value)
		return 
	end 
	if not caster:IsUpgrade(dataName[7]) then
		target:Heal(-heal,target)
	else
		local data = caster:GetUpgradeData(dataName[7])
		local value = data.Value
		local dur = data.Duration
		local modelScale = data.ModelScale
		caster:AddNewModifier(caster,self,"modifier_DevourerSpecialUpgrade",{
			duration = dur,
			value = value,
			ModelScale = modelScale,
		})
	end
	
end 

modifier_DevourerSpecialUpgrade = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions 		= function(self) return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}	end,
	GetModifierBonusStats_Intellect = function(self) return self:GetSharedKey("valueStats") end,
	GetModifierBonusStats_Agility 	= function(self) return self:GetSharedKey("valueStats") end,
	GetModifierBonusStats_Strength 	= function(self) return self:GetSharedKey("valueStats") end,
})

function modifier_DevourerSpecialUpgrade:OnCreated(kv)
	if IsServer() then
		self:SetSharedKey("valueStats", kv.value)
		self.oldScale = self:GetCaster():GetModelScale()
		self:GetCaster():SetModelScale(kv.ModelScale)
	end
end 
function modifier_DevourerSpecialUpgrade:OnDestroy()
	if IsServer() then
		self:GetCaster():SetModelScale(self.oldScale)
	end
end 
if not VampireShadow_Veil then
	VampireShadow_Veil = class({})
end

function VampireShadow_Veil:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster,self,"modifier_vampireShadowVeil",{duration = -1})
		caster:AddNewModifier(caster,self,"modifier_invisible",{duration = -1})
	else
		caster:RemoveModifierByName("modifier_vampireShadowVeil")
		caster:RemoveModifierByName("modifier_invisible")
	end
end 

modifier_vampireShadowVeil = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	OnCreated 				= function(self) self:StartIntervalThink(0.3) end,
	DeclareFunctions 		= function(self) return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}	end,
})

function modifier_vampireShadowVeil:OnAttackLanded(data)
	if data.attacker == self:GetCaster() or data.target == self:GetCaster() then
		self:GetAbility():ToggleAbility()
		self:GetAbility():OnToggle()
	end 
end 

function modifier_vampireShadowVeil:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local movement_damage_pct = (caster:GetMaxHealth()/100)*self:GetAbility():GetSpecialValueFor("cost")/100
		local damage = 0
		if caster.positionShadow == nil then
			caster.positionShadow = caster:GetAbsOrigin()
		end
		local vector_distance = caster.positionShadow - caster:GetAbsOrigin()
		local distance = (vector_distance):Length2D()
		if distance > 0 then
			damage = distance * movement_damage_pct
		end
		caster.positionShadow = caster:GetAbsOrigin()
		if damage ~= 0  then
			if caster:GetHealth() > damage then
				ApplyDamage({
				victim = caster,
				attacker = caster,
				damage = damage, 
				damage_type = DAMAGE_TYPE_MAGICAL,
			})
			else
				self:GetAbility():ToggleAbility()
				self:GetAbility():OnToggle()
			end 
		end
	end
end

if not VampireRage then 
	VampireRage = class({})
end

if not VampireFlair then 
	VampireFlair = class({})
end
-- AbilityBloodCost
function VampireFlair:OnSpellStart()
	local caster = self:GetCaster()
	local units = FindUnitsInRadius(caster:GetTeamNumber(),
	caster:GetAbsOrigin(),
	nil,
	self:GetSpecialValueFor("radius"),
	DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_HERO,
	DOTA_UNIT_TARGET_FLAG_NONE,
	FIND_ANY_ORDER,
	false)
	if #units < 1 then 
		Containers:DisplayError(caster:GetPlayerID(),"hud_error_enought_units") 
		caster:SetHealth((self:GetKeyValue("AbilityBloodCost") or 0) + caster:GetHealth())
		return 
	end
	for _,v in pairs(units) do
		v:AddNewModifier(caster,self,"modifier_VampireFlar",{duration = self:GetSpecialValueFor("duration")})
	end 

end

modifier_VampireFlar = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
	IsBuff                  = function(self) return false end,
	RemoveOnDeath 			= function(self) return true end,
	CheckState 				= function(self) return {
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}	end,
	GetEffectName = 		function(self) return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf" end,
	GetEffectAttachType	=	function(self) return PATTACH_OVERHEAD_FOLLOW end,
})

if not VampireBloodSpear then -- +1
	VampireBloodSpear = class({})
end 

if not VampireAutophagy then
	VampireAutophagy = class({})
end 
 
function VampireAutophagy:OnSpellStart()
--	if VampireAutophagy:GetBehavior() == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
	local target = self:GetCursorTarget() or self:GetCaster()
	if not self:GetCaster():IsUpgrade(dataName[15]) then
		target:Purge( false, true, false, true, false )
		if not self.particle then
			self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_demonic_purge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			Timers:CreateTimer(1,function() 
				ParticleManager:DestroyParticle(self.particle, true) 
				self.particle = nil
			end)
		end
	else
		local data = UpgradeHero:GetUpgradeData(dataName[15],self:GetCaster():GetPlayerID()) 
		self:NewCooldown(data.Cooldown)
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
		target:GetAbsOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)
		for _,unit in pairs(units) do
		unit:AddNewModifier(self:GetCaster(),self,"modifier_magic_immune",{duration = data.Duration})
		unit:Purge( false, true, false, true, true )
			if not unit.particle then
				unit.particleAutophagy = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_demonic_purge.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
				Timers:CreateTimer(1,function() 
					ParticleManager:DestroyParticle(unit.particleAutophagy, true) 
					unit.particleAutophagy = nil
				end)
			end
		end
	end
end 

VampireCallOfAlpha = class({})
function VampireCallOfAlpha:OnSpellStart()
	local caster = self:GetCaster()
	local alpha
	for i = 0,23 do
		if PlayerResource:IsValidPlayerID(i) and Vampires:IsAlpha(i) and caster:GetPlayerID() ~= i then
			alpha = PlayerResource:GetSelectedHeroEntity(i)
			caster:Teleport(alpha:GetAbsOrigin())
			return 
		end 
	end 
	Containers:DisplayError(caster:GetPlayerID(),"hud_error_not_search_alpha")
	self:EndCooldown()
	caster:SetHealth(caster:GetHealth() + (self:GetKeyValue("AbilityBloodCost") or 0));
end
VampireSearchHumans = class({})

function VampireSearchHumans:OnSpellStart()
	local radius = -1
	local data = self:GetCaster():GetUpgradeData(dataName[16])
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER, false)
	local unitsFriendly = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER, false)
	Timers:CreateTimer(data.Duration,function()
		for k,v in pairs(unitsFriendly) do
			v:AddNewModifier(self:GetCaster(),self,"modifier_stunned",{duration = data.Duration})
		end
	end)
	for k,v in pairs(units) do
		v:AddNewModifier(self:GetCaster(),self,"modifier_VampireFlar",{duration = data.Duration})
	end 
end 

VampireStigma = class({})

function VampireStigma:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local dur =self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster,self,"modifier_VampireStigma_debuff",{duration = dur})
end 

modifier_VampireStigma_debuff = class({
	IsHidden 				= 	function(self) return false end,
	IsPurgable 				= 	function(self) return false end,
	IsDebuff 				= 	function(self) return true end,
	IsBuff                  = 	function(self) return false end,
	RemoveOnDeath 			= 	function(self) return true end,
	GetEffectName 			=	function(self) return "particles/econ/items/bounty_hunter/bounty_hunter_hunters_hoard/bounty_hunter_hoard_shield_mark.vpcf" end,
	GetEffectAttachType		=	function(self) return PATTACH_OVERHEAD_FOLLOW end,
	DeclareFunctions 		= 	function(self) return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH,
	}	end,
})
function modifier_VampireStigma_debuff:OnDeath()
	local caster = self:GetCaster()
	if caster:IsUpgrade("SpecialUpgrade_2_Beta_5") then
		local value = self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Beta_5").Value
		caster:ModifyBlood(value)
	end 
end 
function modifier_VampireStigma_debuff:OnAttackLanded(data)
	local target = data.target
	local attacker = data.attacker
	local caster = self:GetCaster()
	if target == self:GetParent() and attacker == caster then
		local damage = data.damage
		local healData = self:GetAbility():GetSpecialValueFor("healing")
		caster:Healing(caster:GetMaxHealth() / 100 * healData,caster:IsVampire(),true)
		if caster:IsUpgrade("SpecialUpgrade_2_Beta_3") then
			local value = self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Beta_3").Value
			ApplyDamage({ 
				victim = target,
				attacker = caster,
				damage = value,
				damage_type = DAMAGE_TYPE_MAGICAL,
			})
		end 
	end 
end 

VampireAttack = class({})
function VampireAttack:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	FindClearSpaceForUnit(caster, target:GetVectorBehind(), true)
	if caster:IsUpgrade("SpecialUpgrade_2_Beta_4") then
		local data = caster:GetUpgradeData("SpecialUpgrade_2_Beta_4")
		local critical = data.ActiveCritical
		local num = data.NumberAttack
		caster:AddNewModifier(caster,self,"modifier_vampireattack_buff",{duration = -1})
		caster:AddStackModifier({
			ability = self,
			modifier = "modifier_vampireattack_buff",
			count = num,
		})
	end 
	if caster:IsUpgrade("SpecialUpgrade_2_Beta_8") then
		target:AddNewModifier(caster,self,"modifier_stunned",{duration = caster:GetUpgradeData("SpecialUpgrade_2_Beta_8").Value})
	end 
end

modifier_vampireattack_buff = class({
	IsHidden 				= 	function(self) return false end,
	IsPurgable 				= 	function(self) return false end,
	IsDebuff 				= 	function(self) return false end,
	IsBuff                  = 	function(self) return true end,
	RemoveOnDeath 			= 	function(self) return false end,
	DeclareFunctions 		= 	function(self) return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}	end,
})

function modifier_vampireattack_buff:GetModifierPreAttack_CriticalStrike()
	local current_stack = self:GetCaster():GetModifierStackCount( "modifier_vampireattack_buff", self:GetAbility() )
	if current_stack > 0 then
		self:GetCaster():SetModifierStackCount( "modifier_vampireattack_buff", self:GetAbility(), current_stack - 1 )
	end 
	current_stack = self:GetCaster():GetModifierStackCount( "modifier_vampireattack_buff", self:GetAbility() )
	if current_stack <= 0 then
		self:Destroy()
	end 
	return self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Beta_4").ActiveCritical 
end 
VampireDevourment = class({})

modifier_vampire_devourment_debuff = class({
	IsHidden 				= 	function(self) return true end,
	IsPurgable 				= 	function(self) return false end,
	IsDebuff 				= 	function(self) return true end,
	IsBuff                  = 	function(self) return false end,
	RemoveOnDeath 			= 	function(self) return true end,
})
function modifier_vampire_devourment_debuff:OnCreated()
	self:StartIntervalThink(0.5)
end 

function modifier_vampire_devourment_debuff:OnIntervalThink()
	ApplyDamage{
		victim = self:GetParent(),
		attacker = self:GetAbility():GetCaster(),
		damage = self:GetAbility():GetSpecialValueFor("bleedingDamage"),
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
end 

function VampireDevourment:OnSpellStart()
	local Radius  = self:GetSpecialValueFor("radius")
	local bleedingDuration  = self:GetSpecialValueFor("bleedingDuration")
	local point = self:GetCursorPosition()
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
	point,
	nil,
	Radius,
	DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_HERO,
	DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	FIND_CLOSEST, 
	false)
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(self.particle, 3, point)		
	for _,unit in pairs(units) do
		unit:Teleport(point)
		unit:AddNewModifier(caster,self,"modifier_treant_natures_guise_root",{duration = bleedingDuration})
	end 
	if #units > 0 then
		local last = units[1]
		last:AddNewModifier(caster,self,"modifier_vampire_devourment_debuff",{duration = bleedingDuration})
	end 

end 

VampireDarkScar = class({})

function VampireDarkScar:OnSpellStart()
	local caster = self:GetCaster()
	local numberAttack = self:GetSpecialValueFor("bonus_attack")
	caster:AddStackModifier({
			ability = self,
			modifier = "modifier_vampireDarkScar_buff",
			count = numberAttack,
		})
end

modifier_vampireDarkScar_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions 		= function(self) return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}	end,
	GetModifierPreAttack_BonusDamage = function(self) return self:GetSharedKey("Value") end,
})
function modifier_vampireDarkScar_buff:OnCreated()
	self:SetSharedKey("Value", self:GetAbility():GetSpecialValueFor("bonus_damage"))
end 
function modifier_vampireDarkScar_buff:OnAttackLanded(data)
	if data.attacker == self:GetCaster() then
		local current_stack = self:GetCaster():GetModifierStackCount( "modifier_vampireDarkScar_buff", self:GetAbility() )
		if current_stack > 0 then
			self:GetCaster():SetModifierStackCount( "modifier_vampireDarkScar_buff", self:GetAbility(), current_stack - 1 )
		end 
		current_stack = self:GetCaster():GetModifierStackCount( "modifier_vampireDarkScar_buff", self:GetAbility() )
		if current_stack <= 0 then
			self:Destroy()
		end 
	end
end 
VampireMirrorEdge = class({
	GetIntrinsicModifierName = function(self) return "modifier_VampireMirrorEdge_buff" end,
})

modifier_VampireMirrorEdge_buff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions 		= function(self) return {MODIFIER_EVENT_ON_TAKEDAMAGE}	end,
})

function modifier_VampireMirrorEdge_buff:OnTakeDamage(data)
	local attacker = data.attacker
	local target = data.unit
	if target == self:GetCaster() then
		if RollPercentage(self:GetAbility():GetSpecialValueFor("chance")) and self:GetAbility():IsCooldownReady() then
			target:Healing(data.damage,target:IsVampire(),true)
			ApplyDamage({
				victim = attacker,
				attacker = target,
				damage_type = DAMAGE_TYPE_PURE,
				damage = data.damage,
			})
			if not self:GetCaster():IsUpgrade("SpecialUpgrade_3_Beta_8") then
				self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
			end 
		end
	end
end 
VampireBloodPulse = class({})

function VampireBloodPulse:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster,self,"modifier_VampireBloodPulse_buff",{duration = self:GetSpecialValueFor("duration")})
end 

modifier_VampireBloodPulse_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	GetEffectName 			= function(self) return "particles/units/heroes/hero_lich/lich_ice_age.vpcf" end,
	GetEffectAttachType		= function(self) return PATTACH_ABSORIGIN end,
	OnCreated				= function(self)  self:StartIntervalThink(1)  end,
})

function modifier_VampireBloodPulse_buff:OnIntervalThink()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	if self:GetCaster():IsUpgrade("SpecialUpgrade_3_Beta_6") then
		self:GetCaster():Healing(self:GetCaster():GetMaxHealth() / 100 * self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Beta_6").Value)
	end
	self.particle = ParticleManager:CreateParticle("particles/vampirz/vampir_pulse.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())		
	ParticleManager:SetParticleControl(self.particle, 1, self:GetCaster():GetAbsOrigin())				
	ParticleManager:SetParticleControl(self.particle, 2, Vector(radius,radius,radius))	
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,	FIND_ANY_ORDER, false)	
	for _,unit in pairs(units) do
		ApplyDamage({
			victim = unit,
			attacker = self:GetCaster(),
			damage = self:GetAbility():GetSpecialValueFor("damage"),
			damage_type = DAMAGE_TYPE_PHYSICAL,
		})
	end 
end 