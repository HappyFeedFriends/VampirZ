modifier_wearable_visuals = class({})

if IsServer() then
    function modifier_wearable_visuals:OnCreated()
        self:StartIntervalThink(1 / 30)
        self.notDrawing = false
    end

    function modifier_wearable_visuals:OnIntervalThink( ... )
        if self:GetStackCount() > 100 then
            if not self.notDrawing then
                self:GetParent():AddNoDraw()
                self.notDrawing = true
            end
        else
            if self.notDrawing then
                self:GetParent():RemoveNoDraw()
                self.notDrawing = false
            end
        end
    end
end

function modifier_wearable_visuals:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_BLIND] = true
    }

    return state
end

function modifier_wearable_visuals:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return funcs
end

if IsClient() then
    function modifier_wearable_visuals:GetModifierInvisibilityLevel(params)
        local stacks = self:GetStackCount()

        if (stacks > 100) then
            return (stacks - 101) / 100
        end

        return stacks / 100
    end
end

modifier_wearable_visuals_status_fx = class({})

function modifier_wearable_visuals_status_fx:GetStatusEffectName()
    return CustomNetTables:GetTableValue("wearables", tostring(self:GetParent():GetEntityIndex())).fx
end

function modifier_wearable_visuals_status_fx:StatusEffectPriority()
    return 1
end

modifier_wearable_visuals_hero_fx = class({})

function modifier_wearable_visuals_hero_fx:GetHeroEffectName()
    return CustomNetTables:GetTableValue("wearables", tostring(self:GetParent():GetEntityIndex())).fx
end

function modifier_wearable_visuals_hero_fx:HeroEffectPriority()
    return 1
end

modifier_wearable_visuals_activity = class({})

function modifier_wearable_visuals_activity:IsHidden()
    return true
end

function modifier_wearable_visuals_activity:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_wearable_visuals_activity:GetActivityTranslationModifiers()
    local activity = self.activity or CustomNetTables:GetTableValue("wearables", "activity_"..tostring(self:GetCaster():GetEntityIndex())).activity
    self.activity = activity

    return activity
end

function modifier_wearable_visuals_activity:RemoveOnDeath()
    return false
end

function modifier_wearable_visuals_activity:IsPurgable()
    return false
end

function modifier_wearable_visuals_activity:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_debuff_fire = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return false end,
})

function modifier_debuff_fire:OnCreated(data)
    if IsServer() then
        self.tick_interval = data.tick_interval or 1.0
        self.fullDamage = data.fullDamage or 1.0
        self:StartIntervalThink(self.tick_interval)
        self.DamageType = data.DamageType or DAMAGE_TYPE_PURE
        self.fx = ParticleManager:CreateParticle("particles/neutral_fx/black_dragon_fireball.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
    end
end

function modifier_debuff_fire:OnDestroy()
    if IsServer() and self.fx then
        ParticleManager:DestroyParticle(self.fx, true)
    end
end

function modifier_debuff_fire:OnIntervalThink()
    if IsServer() then
        ApplyDamage({
            victim =  self:GetParent(), 
            attacker =  self:GetCaster(), 
            damage =  self.fullDamage, 
            damage_type =  self.DamageType,  
        })
    end
end
