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
		--MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_DISABLE_HEALING,
	} end,
	
	GetModifierMoveSpeedBonus_Percentage = function(self) return self:GetSharedKey("IsDay") == 1 and 0 or 9999 end,
	GetModifierMoveSpeed_AbsoluteMax = function(self) return self:GetSharedKey("IsDay") == 1 and 440 or 700 end,
	GetModifierIgnoreMovespeedLimit = function(self) return self:GetSharedKey("IsDay") == 1 and 440 or 700 end,
	--GetModifierPreAttack_BonusDamage = function(self)  return self:GetSharedKey("IsDay") == 1 and -tonumber(self:GetSharedKey("pctDamage"))  or tonumber(self:GetSharedKey("pctDamage"))  end,
	GetDisableHealing = function(self) if self:GetCaster():IsUpgrade("SpecialUpgrade_2_Alpha_4") then return 1 end return  (self:GetSharedKey("IsDay") == 1 and  not self:GetCaster():IsUpgrade("SpecialUpgrade_2_Alpha_3")) and 1 or 0 end,
})

function modifier_IsVampire:OnCreated()
	self:StartIntervalThink(0.3)
end 

function modifier_IsVampire:OnIntervalThink()
	if IsServer() then
		local sum_damage = math.floor(self:GetParent():GetAverageTrueAttackDamage(self:GetParent()))	
		--if self:GetCaster():IsUpgrade("SpecialUpgrade_2_Alpha_3") and GameRules:IsDaytime() then
		--	local data = self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Alpha_3")
		--	sum_damage = sum_damage + (sum_damage/100 * data.Value)
		--end 
		--local pct = math.floor(sum_damage/100 * 25)
		local IsDay = not self:GetCaster():IsUpgrade("SpecialUpgrade_2_Alpha_5") and GameRules:IsDaytime()
		--if pct ~= self:GetSharedKey("pctDamage") then self:SetSharedKey("pctDamage", pct) end
		if self:GetSharedKey("IsDay") ~= ( IsDay or not self:GetParent():HasModifier('modifier_cave')) then 
			self:SetSharedKey("IsDay",IsDay or not self:GetParent():HasModifier('modifier_cave')) 
		end
	end
end
