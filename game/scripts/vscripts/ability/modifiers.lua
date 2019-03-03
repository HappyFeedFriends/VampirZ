modifier_VampireBetaSupport1 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	IsAura					= function(self) return true end,
	GetAuraSearchFlags		= function(self) return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS end,
	GetAuraSearchTeam		= function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
	GetAuraSearchType		= function(self) return DOTA_UNIT_TARGET_HERO end,
	GetAuraRadius			= function(self) return self.radius end,
	GetModifierAura			= function(self) return "modifier_VampireBetaSupport1_effect" end,
})

function modifier_VampireBetaSupport1:OnCreated(kv)
	self.radius = kv.radius
	self.value = kv.value
end 

modifier_VampireBetaSupport1_effect = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions 		= function(self) return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}	end,
	GetModifierPreAttack_BonusDamage = function(self) return self:GetSharedKey("Value") end
})

modifier_VampireBetaSupport2 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	IsAura					= function(self) return true end,
	GetAuraSearchFlags		= function(self) return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS end,
	GetAuraSearchTeam		= function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
	GetAuraSearchType		= function(self) return DOTA_UNIT_TARGET_HERO end,
	GetAuraRadius			= function(self) return self.radius end,
	GetModifierAura			= function(self) return "modifier_VampireBetaSupport2_effect" end,
})

function modifier_VampireBetaSupport2:OnCreated(kv)
	self.radius = kv.radius
end 

modifier_VampireBetaSupport2_effect = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	GetModifierLifeSteal 	= function(self) return UpgradeHero:GetUpgradeData("SpecialUpgrade_1_Beta_2",self:GetCaster():GetPlayerID()).dataModifier.value or 0  end
})

modifier_VampireBetaSupport3 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	IsAura					= function(self) return true end,
	GetAuraSearchFlags		= function(self) return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end,
	GetAuraSearchTeam		= function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
	GetAuraSearchType		= function(self) return DOTA_UNIT_TARGET_HERO end,
	GetAuraRadius			= function(self) return 500 end,
	GetModifierAura			= function(self) return "modifier_VampireBetaSupport3_effect" end,
})

function modifier_VampireBetaSupport3:OnCreated()
	if IsServer() then
		local data = UpgradeHero:GetUpgradeData("SpecialUpgrade_1_Beta_7",self:GetCaster():GetPlayerID()) 
		self.radius = data.radius
	end 
end

modifier_VampireBetaSupport3_effect = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions 		= function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED}	end,
})

function modifier_VampireBetaSupport3_effect:OnAttackLanded(data)
	local dataUpgrade = UpgradeHero:GetUpgradeData("SpecialUpgrade_1_Beta_6",self:GetCaster():GetPlayerID()) 
	local damage = data.damage
	local attacker = data.attacker
	local target = data.target
	if target == self:GetParent() and target:IsVampire() and target ~= self:GetCaster() then
		target:SetHealth(target:GetHealth() + damage / 100 * dataUpgrade.Value)
		ApplyDamage({
			victim = self:GetCaster(),
			attacker = attacker,
			damage = damage / 100 * dataUpgrade.Value,
			damage_type = DAMAGE_TYPE_PURE,
		})
	end 
end 
 
modifier_VampireBetaDefense1 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions 		= function(self) return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end,
	GetModifierPhysicalArmorBonus 	= function(self) return self:GetSharedKey("value") end,
})

function modifier_VampireBetaDefense1:OnCreated()
	if IsServer() then
		self:SetSharedKey("value",UpgradeHero:GetUpgradeData("SpecialUpgrade_3_Beta_1",self:GetCaster():GetPlayerID()).Value )
	end
end 

modifier_VampireBetaDefense2 = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions 		= function(self) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_HEALTH_BONUS} end,
	GetModifierHealthBonus 	= function(self) return self:GetSharedKey("health") end,
	GetModifierMoveSpeedBonus_Percentage 	= function(self) return self:GetSharedKey("movespeed") end,
})

function modifier_VampireBetaDefense2:OnCreated()
	if IsServer() then
		self:SetSharedKey("health",UpgradeHero:GetUpgradeData("SpecialUpgrade_3_Beta_2",self:GetCaster():GetPlayerID()).Value )
		self:SetSharedKey("movespeed",UpgradeHero:GetUpgradeData("SpecialUpgrade_3_Beta_2",self:GetCaster():GetPlayerID()).MoveSpeed )
	end
end 


