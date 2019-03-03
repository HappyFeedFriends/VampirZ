LinkLuaModifier( "modifier_dark_prince_ring", "items/vampirs/dark_prince_ring.lua" ,LUA_MODIFIER_MOTION_NONE )

if item_dark_prince_ring == nil then
    item_dark_prince_ring = class({})
end

--------------------------------------------------------------------------------

function item_dark_prince_ring:GetIntrinsicModifierName()
	return "modifier_dark_prince_ring"
end

--------------------------------------------------------------------------------


modifier_dark_prince_ring = class({})


--------------------------------------------------------------------------------

function modifier_dark_prince_ring:DeclareFunctions()
	local funcs = { 
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
 
	return funcs
end

--------------------------------------------------------------------------------

function modifier_dark_prince_ring:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("resistance")
end

--------------------------------------------------------------------------------

function modifier_dark_prince_ring:IsPurgable() return false end
function modifier_dark_prince_ring:IsDebuff() return false end
function modifier_dark_prince_ring:IsHidden() return true end