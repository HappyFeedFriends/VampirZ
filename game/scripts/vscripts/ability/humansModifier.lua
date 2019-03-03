-----------------------------------------------------
--Blood loss/5 Talent
-----------------------------------------------------

--------------------------------------------------------------------------------

modifier_vampires_blood_loss = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    GetAttributes           = function(self) return {MODIFIER_ATTRIBUTE_PERMANENT} end,
    DeclareFunctions        = function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED} end,
})

function modifier_vampires_blood_loss:OnAttackLanded(k)
	local caster = self:GetParent()
	local target = k.target
	local attacker = k.attacker
	if caster == attacker and target:IsRealHero() and target:IsVampire() then
		local modf = caster:GetUpgradeData("SpecialUpgrade_1_Gunner_5").Value
		target:ModifyBlood(modf)
	end
end

-----------------------------------------------------
--Wild hunt aura/6 Talent
-----------------------------------------------------

--------------------------------------------------------------------------------


modifier_wild_hunt_aura = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    IsAura                  = function(self) return true end,
    GetModifierAura         = function(self) return "modifier_wild_hunt" end,
    GetAuraRadius           = function(self) return self:GetParent():GetUpgradeData("SpecialUpgrade_1_Gunner_6").Radius end,
    GetAuraSearchTeam       = function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
    GetAuraSearchType       = function(self) return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end,
    RemoveOnDeath           = function(self) return false end,
    GetAttributes           = function(self) return {MODIFIER_ATTRIBUTE_PERMANENT} end,
})

modifier_wild_hunt = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end,
    GetModifierMoveSpeedBonus_Percentage = function(self) return self:GetSharedKey('MSpeed') end,
    GetModifierAttackSpeedBonus_Constant = function(self) return self:GetSharedKey('ASpeed') end,
})

function modifier_wild_hunt:OnCreated()
    if IsServer() then
        self:SetSharedKey('MSpeed', self:GetParent():GetUpgradeData("SpecialUpgrade_1_Gunner_6").MSpeed)
        self:SetSharedKey('ASpeed', self:GetParent():GetUpgradeData("SpecialUpgrade_1_Gunner_6").ASpeed)
    end
end

-----------------------------------------------------
--Wild hunt aura/6 Talent
-----------------------------------------------------

--------------------------------------------------------------------------------



modifier_gunner_bonus_vision_ms = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_BONUS_DAY_VISION, MODIFIER_PROPERTY_BONUS_NIGHT_VISION, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end,
    GetBonusDayVision = function(self) return self:GetSharedKey('vision') end,
    GetBonusNightVision = function(self) return self:GetSharedKey('vision') end,
    GetModifierMoveSpeedBonus_Constant = function(self) return self:GetSharedKey('ms') end,
})

function modifier_gunner_bonus_vision_ms:OnCreated()
    if IsServer() then
        self:SetSharedKey('vision', self:GetParent():GetUpgradeData("SpecialUpgrade_2_Gunner_1").Vision)
        self:SetSharedKey('ms', self:GetParent():GetUpgradeData("SpecialUpgrade_2_Gunner_1").Ms)
    end
end 