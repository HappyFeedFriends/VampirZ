-----------------------------------------------------
--Warrior Gloves
-----------------------------------------------------

item_warrior_gloves = class({})

--------------------------------------------------------------------------------

function item_warrior_gloves:GetIntrinsicModifierName()
	return "modifier_warrior_gloves"
end

LinkLuaModifier( "modifier_warrior_gloves", "items/humans/other.lua", LUA_MODIFIER_MOTION_NONE )

modifier_warrior_gloves = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end,
    GetModifierPhysicalArmorBonus = function(self) return self:GetAbility():GetSpecialValueFor("armor") end,
    GetModifierBonusStats_Strength = function(self) return self:GetAbility():GetSpecialValueFor("str") end,
})

-----------------------------------------------------
--Ring of Magic
-----------------------------------------------------

item_ring_of_magic = class({})

--------------------------------------------------------------------------------

function item_ring_of_magic:GetIntrinsicModifierName()
	return "modifier_ring_of_magic"
end

LinkLuaModifier( "modifier_ring_of_magic", "items/humans/other.lua", LUA_MODIFIER_MOTION_NONE )

modifier_ring_of_magic = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end,
    GetModifierConstantManaRegen = function(self) return self:GetAbility():GetSpecialValueFor("mp_regen") end,
    GetModifierBonusStats_Intellect = function(self) return self:GetAbility():GetSpecialValueFor("int") end,
})

-----------------------------------------------------
--Bendable plate
-----------------------------------------------------

item_bendable_plate = class({})

--------------------------------------------------------------------------------

function item_bendable_plate:GetIntrinsicModifierName()
	return "modifier_bendable_plate"
end

LinkLuaModifier( "modifier_bendable_plate", "items/humans/other.lua", LUA_MODIFIER_MOTION_NONE )

modifier_bendable_plate = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end,
    GetModifierAttackSpeedBonus_Constant = function(self) return self:GetAbility():GetSpecialValueFor("as") end,
    GetModifierBonusStats_Agility = function(self) return self:GetAbility():GetSpecialValueFor("agi") end,
})

-----------------------------------------------------
--Traveller Boots
-----------------------------------------------------

item_traveller_boots = class({})

--------------------------------------------------------------------------------

function item_traveller_boots:GetIntrinsicModifierName()
	return "modifier_traveller_boots"
end

LinkLuaModifier( "modifier_traveller_boots", "items/humans/other.lua", LUA_MODIFIER_MOTION_NONE )

modifier_traveller_boots = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end,
    GetModifierMoveSpeedBonus_Constant = function(self) return self:GetAbility():GetSpecialValueFor("ms") end,
})

-----------------------------------------------------
--Hoop
-----------------------------------------------------

item_hoop = class({})

--------------------------------------------------------------------------------

function item_hoop:GetIntrinsicModifierName()
	return "modifier_hoop"
end

LinkLuaModifier( "modifier_hoop", "items/humans/other.lua", LUA_MODIFIER_MOTION_NONE )

modifier_hoop = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end,
    GetModifierBonusStats_Strength = function(self) return self:GetAbility():GetSpecialValueFor("all_attr") end,
    GetModifierBonusStats_Agility = function(self) return self:GetAbility():GetSpecialValueFor("all_attr") end,
    GetModifierBonusStats_Intellect = function(self) return self:GetAbility():GetSpecialValueFor("all_attr") end,
})

-----------------------------------------------------
--Manastone
-----------------------------------------------------

item_manastone = class({})

--------------------------------------------------------------------------------

function item_manastone:GetIntrinsicModifierName()
	return "modifier_manastone"
end

LinkLuaModifier( "modifier_manastone", "items/humans/other.lua", LUA_MODIFIER_MOTION_NONE )

modifier_manastone = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE,MODIFIER_PROPERTY_MANA_BONUS} end,
    GetModifierPercentageManacost = function(self) return self:GetAbility():GetSpecialValueFor("manacast") end,
    GetModifierManaBonus = function(self) return self:GetAbility():GetSpecialValueFor("mana") end,
})

-----------------------------------------------------
--Magic Wreath
-----------------------------------------------------

item_magic_wreath = class({})

--------------------------------------------------------------------------------

function item_magic_wreath:GetIntrinsicModifierName()
	return "modifier_magic_wreath"
end

LinkLuaModifier( "modifier_magic_wreath", "items/humans/other.lua", LUA_MODIFIER_MOTION_NONE )

modifier_magic_wreath = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE,MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end,
    GetModifierPercentageManacost = function(self) return self:GetAbility():GetSpecialValueFor("manacast") end,
    GetModifierManaBonus = function(self) return self:GetAbility():GetSpecialValueFor("mana") end,
    GetModifierBonusStats_Strength = function(self) return self:GetAbility():GetSpecialValueFor("all_attr") end,
    GetModifierBonusStats_Agility = function(self) return self:GetAbility():GetSpecialValueFor("all_attr") end,
    GetModifierBonusStats_Intellect = function(self) return self:GetAbility():GetSpecialValueFor("all_attr") end,
    GetModifierConstantManaRegen = function(self) return self:GetAbility():GetSpecialValueFor("mp_regen") end,
})