CAVE_SETTINGS = {
    Aura_Radius = 1100,
    Spawns = Vector(-9488,3586,128),
}

LinkLuaModifier( "modifier_cave_aura", "modules/cave/cave.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cave", "modules/cave/cave.lua", LUA_MODIFIER_MOTION_NONE )

if not Cave then
    Cave = class({})
end

function Cave:Create()
    local Prop = CreateUnitByName("npc_dummy_unit", CAVE_SETTINGS["Spawns"], true, nil, nil, DOTA_TEAM_BADGUYS)
    Prop:AddNewModifier(Prop, nil, "modifier_cave_aura", {duration = -1})
end

modifier_cave_aura = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    IsAura                  = function(self) return true end,
    GetModifierAura         = function(self) return "modifier_cave" end,
    GetAuraRadius           = function(self) return CAVE_SETTINGS.Aura_Radius end,
    GetAuraSearchTeam       = function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
    GetAuraSearchType       = function(self) return DOTA_UNIT_TARGET_HERO end,
    RemoveOnDeath           = function(self) return false end,
    GetAttributes           = function(self) return {MODIFIER_ATTRIBUTE_PERMANENT} end,
})

function modifier_cave_aura:CheckState()
    local state = {}
    if IsServer() then
        state[MODIFIER_STATE_UNSELECTABLE] = true
        state[MODIFIER_STATE_STUNNED] = true
        state[MODIFIER_STATE_ATTACK_IMMUNE] = true
        state[MODIFIER_STATE_MAGIC_IMMUNE] = true
        state[MODIFIER_STATE_NO_HEALTH_BAR] = true
        state[MODIFIER_STATE_NO_UNIT_COLLISION] = true
        state[MODIFIER_STATE_NOT_ON_MINIMAP] = true
        state[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true
        state[MODIFIER_STATE_INVULNERABLE] = true
    end
    
    return state
end

modifier_cave = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE} end,
    GetModifierHealthRegenPercentage = function(self) return 3 end,
    GetModifierTotalPercentageManaRegen = function(self) return 5 end,
})