modifier_IsVampire = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_DISABLE_HEALING,
	} end,
	
	GetModifierMoveSpeedBonus_Percentage = function(self) return self:GetSharedKey("IsDay") == 1 and 0 or 9999 end,
	GetModifierMoveSpeed_AbsoluteMax = function(self) return self:GetSharedKey("IsDay") == 1 and 440 or 700 end,
	GetModifierIgnoreMovespeedLimit = function(self) return self:GetSharedKey("IsDay") == 1 and 440 or 700 end,
	GetModifierPreAttack_BonusDamage = function(self)  return self:GetSharedKey("IsDay") == 1 and 0  or tonumber(self:GetSharedKey("pctDamage"))  end,
	GetDisableHealing = function(self) 
	if self:GetSharedKey('IsHealing') == 1 then 
		return 1 
	end 
		return  (self:GetSharedKey("IsHealing2") == 1 and not self:GetCaster():IsUpgrade("SpecialUpgrade_2_Alpha_3")) and 1 or 0 
	end,
})

function modifier_IsVampire:OnCreated()
	self:StartIntervalThink(0.3)
end 

function modifier_IsVampire:OnIntervalThink()
	if IsServer() then
		local sum_damage = math.floor(self:GetParent():GetAverageTrueAttackDamage(self:GetParent()))	
		if self:GetParent():IsUpgrade("SpecialUpgrade_2_Alpha_3") and GameRules:IsDaytime() then
			local data = self:GetParent():GetUpgradeData("SpecialUpgrade_2_Alpha_3")
			sum_damage = sum_damage + (sum_damage/100 * data.Value)
		end 
		local pct = math.floor(sum_damage/100 * 35)
		local IsDay =  (not self:GetParent():IsUpgrade("SpecialUpgrade_2_Alpha_5") and GameRules:IsDaytime())
		if self:GetParent():HasModifier('modifier_cave') then
			IsDay = false
		end
		if self:GetSharedKey("IsDay") ~= IsDay then 
			self:SetSharedKey("IsDay",IsDay) 
		end
		if self:GetSharedKey('IsHealing') ~= self:GetParent():IsUpgrade("SpecialUpgrade_2_Alpha_4") then
			self:SetSharedKey('IsHealing',self:GetParent():IsUpgrade("SpecialUpgrade_2_Alpha_4"))
		end
		if self:GetSharedKey('IsHealing2') ~= self:GetParent():IsUpgrade("SpecialUpgrade_2_Alpha_3") then
			self:SetSharedKey('IsHealing2',self:GetParent():IsUpgrade("SpecialUpgrade_2_Alpha_3"))
		end
		if pct ~= self:GetSharedKey("pctDamage") then self:SetSharedKey("pctDamage", pct) end
	end
end

modifier_hero_out_of_game = class({
	IsHidden =      function() return true end,
	IsPurgable =    function() return false end,
	IsPermanent =   function() return true end,
	RemoveOnDeath = function() return false end,
})

function modifier_hero_out_of_game:CheckState()
	return {
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_BLIND] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_HEXED] = true
	}
end

if IsServer() then
	function modifier_hero_out_of_game:OnCreated()
		self:GetParent():AddNoDraw()
	end

	function modifier_hero_out_of_game:OnDestroy()
		self:GetParent():RemoveNoDraw()
	end
end

modifier_global_aura = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	IsAura 					=	function(self) return true end,
    GetAuraRadius			= 	function(self) return -1  end,
    GetAuraSearchFlags      = 	function(self) return DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE end,
    GetAuraSearchTeam      	= 	function(self) return DOTA_UNIT_TARGET_TEAM_BOTH end,
    GetAuraSearchType      	= 	function(self) return DOTA_UNIT_TARGET_HERO end,
    GetModifierAura 		=	function(self) return "modifier_global_aura_effect" end,
})

modifier_global_aura_effect = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	OnCreated				= function(self) self:StartIntervalThink(1.5) end,
})

function modifier_global_aura_effect:OnIntervalThink()
	if IsServer() and self:GetParent():IsRealHero() and self:GetParent():GetPlayerID() ~= nil then
		if self:GetParent():IsVampire() then
			self:GetParent():ModifyBlood(4)
			self:GetParent():AddExperience(25.0,0,true,true)
		else
			Gold:ModifyGold(self:GetParent():GetPlayerID(),2)
		end
	end 
end
