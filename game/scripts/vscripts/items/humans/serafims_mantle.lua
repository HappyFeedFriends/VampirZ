LinkLuaModifier( "modifier_serafims_mantle", "items/humans/serafims_mantle.lua" ,LUA_MODIFIER_MOTION_NONE )

if item_serafims_mantle == nil then
    item_serafims_mantle = class({})
end

--------------------------------------------------------------------------------

function item_serafims_mantle:GetIntrinsicModifierName()
	return "modifier_serafims_mantle"
end

--------------------------------------------------------------------------------


modifier_serafims_mantle = class({})


--------------------------------------------------------------------------------

function modifier_serafims_mantle:IsPurgable() return false end
function modifier_serafims_mantle:IsDebuff() return false end
function modifier_serafims_mantle:IsHidden() return true end