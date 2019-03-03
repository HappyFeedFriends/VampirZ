-----------------------------------------------------
--Gunner Weakness/Base ability
-----------------------------------------------------

Gunner_Weakness = class({})

--------------------------------------------------------------------------------

function Gunner_Weakness:GetIntrinsicModifierName()
	return "modifier_gunner_weakness"
end

LinkLuaModifier( "modifier_gunner_weakness", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_weakness = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    OnCreated               = function(self) self.Attacks = 0 self:StartIntervalThink(0.1) end,
    DeclareFunctions        = function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED} end,
})

function modifier_gunner_weakness:OnIntervalThink()
	if IsServer()  then
		local caster = self:GetParent()
		if caster:IsUpgrade("SpecialUpgrade_1_Gunner_3") then
			local radius = caster:GetUpgradeData("SpecialUpgrade_1_Gunner_3").Value
			local target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
			local target_types = DOTA_UNIT_TARGET_HERO
			local target_flags = DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
			local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, target_team, target_types, target_flags, FIND_CLOSEST, false)
			if #units > 0 then
				for count, hero in ipairs(units) do
	                if hero ~= caster and hero:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
					    hero:AddNewModifier( caster, self:GetAbility(), "modifier_gunner_weakness", { duration = 1.0 } )
	                end
				end
			end
		end
	end
end

function modifier_gunner_weakness:OnAttackLanded(k)
	local caster = self:GetParent()
	local target = k.target
	local attacker = k.attacker
	local chance = self:GetAbility():GetSpecialValueFor("chance")
    if caster:IsUpgrade("SpecialUpgrade_3_Gunner_2") then
        chance = caster:GetUpgradeData("SpecialUpgrade_3_Gunner_2").Value
    end
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	local attacksNeed = self:GetAbility():GetSpecialValueFor("attacks")
    if caster:IsUpgrade("SpecialUpgrade_3_Gunner_4") then
        local aReduce = caster:GetUpgradeData("SpecialUpgrade_3_Gunner_4").Value
        attacksNeed = attacksNeed - aReduce
    end

	if caster == attacker and caster:GetTeam() ~= target:GetTeam() then
		self.Attacks = self.Attacks + 1
		if self.Attacks < attacksNeed + 1 then
			self:SetStackCount(self.Attacks)
		elseif self.Attacks == attacksNeed + 1 then
			self.Attacks = 0
			self:SetStackCount(self.Attacks)
			local damageInfo = 
			{
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
				ability = self:GetAbility(), 
			}

            if caster:IsUpgrade("SpecialUpgrade_2_Gunner_6") then
                local duration = caster:GetUpgradeData("SpecialUpgrade_2_Gunner_6").Duration
                target:AddNewModifier( caster, self:GetAbility(), "modifier_gunner_hunters_mark", { duration = duration } )
            end
			
			ApplyDamage( damageInfo )

			if RollPercentage(chance) then
				target:AddNewModifier( caster, self:GetAbility(), "modifier_stunned", { duration = duration } )
			end
		end
	end
end

LinkLuaModifier( "modifier_gunner_hunters_mark", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_hunters_mark = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) self:StartIntervalThink(0.1) end,
    DeclareFunctions        = function(self) return {MODIFIER_EVENT_ON_DEATH} end,
})

function modifier_gunner_hunters_mark:OnIntervalThink()
    local unit = self:GetParent()

    AddFOWViewer(self:GetCaster():GetTeam(), unit:GetAbsOrigin(), 125, 0.04, false)
end

function modifier_gunner_hunters_mark:OnDeath()
    local AllHero = HeroList:GetAllHeroes()
    local caster = self:GetCaster()
    for _,unit in ipairs(AllHero) do
        if unit:GetTeam() == self:GetCaster():GetTeam() then
            local duration = caster:GetUpgradeData("SpecialUpgrade_2_Gunner_6").BDuration
            unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_gunner_hunters_mark_buff", { duration = duration } )
        end
    end
end

LinkLuaModifier( "modifier_gunner_hunters_mark_buff", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_hunters_mark_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end,
    GetModifierPreAttack_BonusDamage = function(self) return self:GetSharedKey('Damage') end,
})
function modifier_gunner_hunters_mark_buff:OnCreated()
	if IsServer() then
        self:SetSharedKey('Damage', self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Gunner_6").Damage)
    end
end
-----------------------------------------------------
--Unstable Ammonite/Base ability
-----------------------------------------------------

Gunner_Unstable_Ammonite = class({})

--------------------------------------------------------------------------------

function Gunner_Unstable_Ammonite:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("bullets_duration")
	caster:AddNewModifier( caster, self, "modifier_gunner_ammonite", { duration = duration } )
end

LinkLuaModifier( "modifier_gunner_ammonite", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_ammonite = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED} end,
    GetAttributes           = function(self) return {MODIFIER_ATTRIBUTE_MULTIPLE} end,
})

function modifier_gunner_ammonite:OnCreated()
	if IsServer() then
	    local Attacks = self:GetAbility():GetSpecialValueFor("attacks") 
	    if self:GetParent():IsUpgrade("SpecialUpgrade_1_Gunner_1") then
	    	local bonus = self:GetCaster():GetUpgradeData("SpecialUpgrade_1_Gunner_1").Value
	    	Attacks = Attacks + bonus
	    end
	    self:GetParent():SetModifierStackCount( "modifier_gunner_ammonite", self:GetAbility(), Attacks )
	end
end

function modifier_gunner_ammonite:OnAttackLanded(k)
	local caster = self:GetParent()
	local target = k.target
	local attacker = k.attacker
	local duration = self:GetAbility():GetSpecialValueFor("duration")

	if caster == attacker then
		self:DecrementStackCount()
		if self:GetStackCount() < 1 then
			self:Destroy()
		elseif self:GetStackCount() > 0 then
			if not target:HasModifier("modifier_gunner_ammonite_burn") then
				local modifier = target:AddNewModifier( caster, self:GetAbility(), "modifier_gunner_ammonite_burn", { duration = duration } )
				modifier:SetStackCount(1)
				modifier:SetDuration(duration, true)
			elseif target:HasModifier("modifier_gunner_ammonite_burn") then
				local modifier = target:FindModifierByName("modifier_gunner_ammonite_burn")
				modifier:SetStackCount(modifier:GetStackCount() + 1)
				modifier:SetDuration(duration, true)
			end
            if caster:IsUpgrade("SpecialUpgrade_3_Gunner_3") then
            	local data = caster:GetUpgradeData("SpecialUpgrade_3_Gunner_3")
                local Chance = data.Chance
                if RollPercentage(Chance) then
                    local D = data.Duration
                    target:AddNewModifier( caster, self:GetAbility(), "modifier_stunned", { duration = D } )
                    local radius = data.Radius
                    local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
                    local target_types = DOTA_UNIT_TARGET_HERO
                    local target_flags = DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
                    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, target_team, target_types, target_flags, FIND_CLOSEST, false)
                    if #units > 0 then
                        for count, hero in ipairs(units) do
                            if hero ~= target then
                                if not target:HasModifier("modifier_gunner_ammonite_burn") then
                                    local modifier = target:AddNewModifier( caster, self:GetAbility(), "modifier_gunner_ammonite_burn", { duration = duration } )
                                    modifier:SetStackCount(1)
                                    modifier:SetDuration(duration, true)
                                elseif target:HasModifier("modifier_gunner_ammonite_burn") then
                                    local modifier = target:FindModifierByName("modifier_gunner_ammonite_burn")
                                    modifier:SetStackCount(modifier:GetStackCount() + 1)
                                    modifier:SetDuration(duration, true)
                                end
                            end
                        end
                    end
                end
            end
		end
	end
end

LinkLuaModifier( "modifier_gunner_ammonite_burn", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_ammonite_burn = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    GetAttributes           = function(self) return {MODIFIER_ATTRIBUTE_MULTIPLE} end,
    OnCreated               = function(self) local interval = self:GetAbility():GetSpecialValueFor("interval") self:StartIntervalThink(interval) if self.TimeDelete == nil then self.TimeDelete = 0 end end,
})

function modifier_gunner_ammonite_burn:OnIntervalThink()
	if IsServer()  then
		local target = self:GetParent()
		local caster = self:GetCaster()
		local damagePerStack = self:GetAbility():GetSpecialValueFor("damage") * self:GetStackCount()

		local damageInfo = 
		{
			victim = target,
			attacker = caster,
			damage = damagePerStack,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), 
		}
		
		ApplyDamage( damageInfo )

		self.TimeDelete = self.TimeDelete + 1

		if self.TimeDelete == 3 then
			self.TimeDelete = 0
			self:DecrementStackCount()
		end
	end
end

-----------------------------------------------------
--Medkit/Additional ability
-----------------------------------------------------

Gunner_Medkit = class({})

--------------------------------------------------------------------------------
function Gunner_Medkit:GetCooldown(nLevel)
	local caster = self:GetCaster() 
	local cooldown = self.BaseClass.GetCooldown(self, nLevel) 
	return IsServer() and caster:IsUpgrade("SpecialUpgrade_1_Gunner_7") and 0 or cooldown

end
function Gunner_Medkit:OnSpellStart()
	local caster = self:GetCaster()
	local heal = self:GetSpecialValueFor("heal")
	if caster:IsUpgrade("SpecialUpgrade_1_Gunner_8") then
		local bonus = caster:GetUpgradeData("SpecialUpgrade_1_Gunner_8").Value
		heal = heal + bonus
	end
	caster:Purge(false, true, false, false, false)
	if caster:IsUpgrade("SpecialUpgrade_1_Gunner_4") then
		local radius = caster:GetUpgradeData("SpecialUpgrade_1_Gunner_4").Value
        local target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
        local target_types = DOTA_UNIT_TARGET_HERO
        local target_flags = DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
        local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, target_team, target_types, target_flags, FIND_CLOSEST, false)
        if #units > 0 then
            for count, hero in ipairs(units) do
                if hero ~= caster then
                    hero:Heal(heal, caster)
                end
            end
        end
	end
	caster:Heal(heal, caster)
end

-----------------------------------------------------
--Trap Hunter/Additional ability
-----------------------------------------------------

Gunner_Trap_hunter = class({})

--------------------------------------------------------------------------------

function Gunner_Trap_hunter:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local Trap = CreateUnitByName("npc_gunner_trap_hunter", point, true, nil, nil, caster:GetTeamNumber())
	Trap:SetOwner(caster)
end

function Gunner_Trap_hunter:GetCooldown(nLevel)
    local caster = self:GetCaster()
    local cooldown = self.BaseClass.GetCooldown(self, nLevel)
    
    if IsServer() then
        if caster:IsUpgrade("SpecialUpgrade_2_Gunner_7") then
            local reduce = caster:GetUpgradeData("SpecialUpgrade_2_Gunner_7").Value
            cooldown = cooldown - reduce

            return cooldown
        end
    end

    return cooldown
end

-----------------------------------------------------
--Trap(Unit)/Unit ability
-----------------------------------------------------

Gunner_Trap_hunter_Unit = class({})

--------------------------------------------------------------------------------

function Gunner_Trap_hunter_Unit:GetIntrinsicModifierName()
	return "modifier_Trap_sekeeng_hunter"
end

LinkLuaModifier( "modifier_Trap_sekeeng_hunter", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_Trap_sekeeng_hunter = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) self:StartIntervalThink(0.03) end,
})

function modifier_Trap_sekeeng_hunter:CheckState()
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

function modifier_Trap_sekeeng_hunter:OnIntervalThink()
	local caster = self:GetParent():GetOwner()
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO
	local target_flags = DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
	local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 250, target_team, target_types, target_flags, FIND_CLOSEST, false)
	if #units > 0 then
		for count, hero in ipairs(units) do
			hero:AddNewModifier( caster, self:GetAbility(), "modifier_Trap_hunter_slow", { duration = duration } )
			local damage = self:GetAbility():GetSpecialValueFor("damage")

			local damageInfo = 
			{
				victim = hero,
				attacker = caster,
				damage = damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
				ability = self:GetAbility(), 
			}
			
			ApplyDamage( damageInfo )

            if caster:IsUpgrade("SpecialUpgrade_2_Gunner_7") then
                local durationB = caster:GetUpgradeData("SpecialUpgrade_2_Gunner_7").Duration
                hero:AddNewModifier( caster, self:GetAbility(), "modifier_Trap_hunter_blood_loss", { duration = durationB } )
            end
		end
		self:GetParent():ForceKill(true)
		self:Destroy()
	end
end

LinkLuaModifier( "modifier_Trap_hunter_slow", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_Trap_hunter_slow = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end,
    GetModifierMoveSpeedBonus_Percentage = function(self) return self:GetAbility():GetSpecialValueFor("slow") end,
})

LinkLuaModifier( "modifier_Trap_hunter_blood_loss", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_Trap_hunter_blood_loss = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) self:StartIntervalThink(1.0) end,
})

function modifier_Trap_hunter_blood_loss:OnIntervalThink()
    local target = self:GetParent()

    local damage = self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Gunner_7").Damage

    local damageInfo = 
    {
        victim = target,
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility(), 
    }
    
    ApplyDamage( damageInfo )
end

-----------------------------------------------------
--Hawk/Additional ability
-----------------------------------------------------

Gunner_Hawk = class({})

--------------------------------------------------------------------------------

function Gunner_Hawk:OnSpellStart()
	local caster = self:GetCaster()
    local player = caster:GetPlayerID()
	local duration = self:GetSpecialValueFor("duration")
    local n = 1
    if caster:IsUpgrade("SpecialUpgrade_2_Gunner_5") then
        local bonus = caster:GetUpgradeData("SpecialUpgrade_2_Gunner_5").Value
        n = bonus
    end
    for i=1,n do
	   local Hawk = CreateUnitByName("npc_gunner_hawk", caster:GetAbsOrigin() + RandomVector(RandomFloat(10, 75)), true, nil, nil, caster:GetTeamNumber())
    	Hawk:SetOwner(caster)
        Hawk:SetControllableByPlayer(player, true)
    	Hawk:AddNewModifier(caster, self, "modifier_kill", {Duration = duration})
    	Hawk:AddNewModifier( caster, self, "modifier_gunner_hawk", { duration = inf } )
    	Hawk:AddNewModifier( caster, self, "modifier_invisible", { duration = inf } )
    end
    if _G.GTest == false then
        _G.GTest = true
    elseif _G.GTest == true then
        _G.GTest = false
    end
end

LinkLuaModifier( "modifier_gunner_hawk", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_hawk = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) self:StartIntervalThink(0.03) end,
})

function modifier_gunner_hawk:OnIntervalThink()
	local hawk = self:GetParent()

	AddFOWViewer(hawk:GetTeam(), hawk:GetAbsOrigin(), hawk:GetDayTimeVisionRange(), 0.04, false)
end

-----------------------------------------------------
--Hunter`s chain/Additional ability
-----------------------------------------------------

Gunner_Hunters_chain = class({})

--------------------------------------------------------------------------------

function Gunner_Hunters_chain:OnSpellStart()
	local caster = self:GetCaster()
	self.point = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO
	local target_flags = DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
	local units = FindUnitsInRadius(caster:GetTeamNumber(), self.point, nil, radius, target_team, target_types, target_flags, FIND_CLOSEST, false)
	if units then
		if #units > 0 then
			for _,unit in ipairs(units) do
				unit:AddNewModifier(caster, self, "modifier_gunner_chain_vacum", {Duration = 0.2})
			end
		end
	end
end

LinkLuaModifier( "modifier_gunner_chain_vacum", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_chain_vacum = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
})

function modifier_gunner_chain_vacum:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.03)
		self.distance = (self:GetAbility().point - self:GetParent():GetAbsOrigin()):Length2D()
	end
end

function modifier_gunner_chain_vacum:OnIntervalThink()
	if IsServer() then
		local unit = self:GetParent()
		local Vector_distance = (self:GetAbility().point - unit:GetAbsOrigin())
		local Direction = Vector_distance:Normalized()

	    local speed = 300 * 1/30
	    if self.distance > 0 then
	        unit:SetAbsOrigin(unit:GetAbsOrigin() + Direction * speed)
	        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), false)
	        self.distance = self.distance - speed
	    elseif self.distance <= 0 then
	        self:Destroy()
	    end
	end
end

function modifier_gunner_chain_vacum:OnDestroy()
	if IsServer() then
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gunner_chain_rope", {Duration = duration})
	end
end

LinkLuaModifier( "modifier_gunner_chain_rope", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_chain_rope = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_EVENT_ON_UNIT_MOVED} end,
})

function modifier_gunner_chain_rope:OnCreated()
	if IsServer() then
		self.SlowM = false
		self.MCap = self:GetParent():GetMoveCapability()
	end
end

function modifier_gunner_chain_rope:OnDestroy()
	if IsServer() then
		self:GetParent():SetMoveCapability(self.MCap)
	end
end

function modifier_gunner_chain_rope:OnUnitMoved()
	local caster = self:GetCaster()
	local target = self:GetParent()
	local ability = self:GetAbility()
	local radius = ability:GetSpecialValueFor("radius")
	
	local distance = (target:GetAbsOrigin() - ability.point):Length2D()
	local distance_from_border = distance - radius

	local target_angle = target:GetAnglesAsVector().y

	local origin_difference =  ability.point - target:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	origin_difference_radian = origin_difference_radian * 180
	local angle_from_center = origin_difference_radian / math.pi
	angle_from_center = angle_from_center + 180.0
	
	if distance_from_border < 0 and math.abs(distance_from_border) <= 20 and (math.abs(target_angle - angle_from_center)<90 or math.abs(target_angle - angle_from_center)>270) then
		target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
        target:SetAbsOrigin(target:GetAbsOrigin() + (target:GetForwardVector() * -1) * 15)
        target:SetMoveCapability(self.MCap)
	else
		target:SetMoveCapability(self.MCap)
	end
end

-----------------------------------------------------
--Machine Gun Mode/Additional ability
-----------------------------------------------------

Gunner_machine_gun_mode = class({})

--------------------------------------------------------------------------------

function Gunner_machine_gun_mode:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_gunner_machine_gun_mode", {Duration = duration})
end

LinkLuaModifier( "modifier_gunner_machine_gun_mode", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_machine_gun_mode = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK} end,
    GetModifierAttackSpeedBonus_Constant = function(self) return self:GetAbility():GetSpecialValueFor("attack_speed") end,
    GetModifierDamageOutgoing_Percentage = function(self) return self:GetAbility():GetSpecialValueFor("damage_reduce") end,
})

function modifier_gunner_machine_gun_mode:OnAttack(k)
	local caster = self:GetParent()
	local attacker = k.attacker
	local target = k.target
	local ability = self:GetAbility()
	if caster == attacker then
		local knockback = ability:GetSpecialValueFor("knockback")
		local BackPos = (caster:GetForwardVector() * -1) * knockback
		caster:SetAbsOrigin(caster:GetAbsOrigin() + BackPos)
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)
	end
end

-----------------------------------------------------
--Kill Shot/Additional ability
-----------------------------------------------------

Gunner_kill_shot = class({})

--------------------------------------------------------------------------------

function Gunner_kill_shot:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage = self:GetSpecialValueFor("damage")
	caster:PerformAttack(hero, true, true, true, false, true, true, true)
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self})
end

-----------------------------------------------------
--Second life/Additional ability
-----------------------------------------------------

Gunner_second_life = class({})

--------------------------------------------------------------------------------

function Gunner_second_life:GetIntrinsicModifierName()
	return "modifier_gunner_second_life"
end

LinkLuaModifier( "modifier_gunner_second_life", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_second_life = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    OnCreated				= function(self) return self:StartIntervalThink(0.03) end,
    DeclareFunctions        = function(self) return {MODIFIER_EVENT_ON_TAKEDAMAGE} end,
})

function modifier_gunner_second_life:OnIntervalThink()
    if IsServer() then
        local caster = self:GetParent()
        if caster:HasModifier("modifier_gunner_second_life_safe") == false and self:GetAbility():GetCooldownTimeRemaining() == 0 then
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_gunner_second_life_safe", {Duration = inf})
        end
    end
end

function modifier_gunner_second_life:OnTakeDamage(k)
    if IsServer() then
        local caster = self:GetParent()
        local health = caster:GetHealth() / caster:GetMaxHealth()
        local min_hp = self:GetAbility():GetSpecialValueFor("min_hp") / 100
        local duration = self:GetAbility():GetSpecialValueFor("duration")
        local cooldown = self:GetAbility():GetSpecialValueFor("cooldown")

        if health < min_hp and self:GetAbility():GetCooldownTimeRemaining() == 0 then
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_gunner_second_life_tooltip", {Duration = duration})
            self:GetAbility():StartCooldown(cooldown)
            caster:RemoveModifierByName("modifier_gunner_second_life_safe")
        end
    end
end

LinkLuaModifier( "modifier_gunner_second_life_safe", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_second_life_safe = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MIN_HEALTH} end,
    GetMinHealth			= function(self) return self:GetAbility():GetSpecialValueFor("min_hp") end,
})

LinkLuaModifier( "modifier_gunner_second_life_tooltip", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_gunner_second_life_tooltip = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end,
    GetMinHealth			= function(self) return self:GetAbility():GetSpecialValueFor("min_hp") end,
    GetModifierAttackSpeedBonus_Constant = function(self) return self:GetAbility():GetSpecialValueFor("attack_speed") end,
    GetModifierPreAttack_BonusDamage = function(self) return self:GetAbility():GetSpecialValueFor("damage") end,
})


-----------------------------------------------------
--Call to Angels/Base Ability
-----------------------------------------------------

Healer_call_to_angels = Healer_call_to_angels or class({})

--------------------------------------------------------------------------------
--function Healer_call_to_angels:GetAbilityTextureName()
--	return "customImages/Healer_call_to_angels"..(FireOnAbility['Healer_call_to_angels'] and FireOnAbility['Healer_call_to_angels'].FireOn and "_2" or "") 
--end

function Healer_call_to_angels:CastFilterResultTarget( hTarget )
    if IsServer() then
        if self:GetCaster():GetTeam() == hTarget:GetTeam() then
            if self.FireOn == nil or self.FireOn == false then
                return UF_SUCCESS
            elseif self.FireOn == true then
                if self.Fire == nil or self.Fire == false then
                    return UF_FAIL_CUSTOM
                elseif self.Fire == true then
                    return UF_SUCCESS
                end
            end
        end

        if self:GetCaster():GetTeam() ~= hTarget:GetTeam() then
            if self.FireOn == nil or self.FireOn == false then
                return UF_FAIL_CUSTOM
            elseif self.FireOn == true then
                return UF_SUCCESS
            end
        end
    end

    return UF_SUCCESS
end

function Healer_call_to_angels:GetCustomCastErrorTarget( hTarget )
    if self:GetCaster():GetTeam() == hTarget:GetTeam() then
        if self.FireOn == true then
            if self.Fire == nil or self.Fire == false then
                return "#dota_hud_error_cant_cast_on_ally"
            end
        end
    end

    if self:GetCaster():GetTeam() ~= hTarget:GetTeam() then
        if self.FireOn == nil or self.FireOn == false then
            return "#dota_hud_error_cant_cast_on_enemy"
        end
    end

    return ""
end

function Healer_call_to_angels:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local heal = self:GetSpecialValueFor("heal")
    if caster:IsUpgrade("SpecialUpgrade_1_Priest_1") then
        local bonus = caster:GetUpgradeData("SpecialUpgrade_1_Priest_1").Value
        heal = heal + bonus
    end
    if caster:GetTeam() == target:GetTeam() then
        target:Healing(heal,nil,nil,caster)
    elseif caster:GetTeam() ~= target:GetTeam() then
        local damage = caster:IsUpgrade("SpecialUpgrade_1_Priest_7") and heal * caster:GetUpgradeData("SpecialUpgrade_1_Priest_7").In or heal
        local damageInfo = 
        {
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self, 
        }
        
        ApplyDamage( damageInfo )
    end
end
 
-----------------------------------------------------
--Divine Touch/Base Ability
-----------------------------------------------------

Healer_divine_touch = class({})

--------------------------------------------------------------------------------

--function Healer_divine_touch:GetAbilityTextureName() 
--	return "customImages/Healer_divine_touch".. (FireOnAbility['Healer_divine_touch'] and FireOnAbility['Healer_divine_touch'].FireOn and "_2" or "") 
--
--end

function Healer_divine_touch:CastFilterResultTarget( hTarget )
    if IsServer() then
        if self:GetCaster():GetTeam() == hTarget:GetTeam() then
            if self.FireOn == nil or self.FireOn == false then
                return UF_SUCCESS
            elseif self.FireOn == true then
                if self.Fire == nil or self.Fire == false then
                    return UF_FAIL_CUSTOM
                elseif self.Fire == true then
                    return UF_SUCCESS
                end
            end
        end

        if self:GetCaster():GetTeam() ~= hTarget:GetTeam() then
            if self.FireOn == nil or self.FireOn == false then
                return UF_FAIL_CUSTOM
            elseif self.FireOn == true then
                return UF_SUCCESS
            end
        end
    end

    return UF_SUCCESS
end

function Healer_divine_touch:GetCustomCastErrorTarget( hTarget )
    if self:GetCaster():GetTeam() == hTarget:GetTeam() then
        if self.FireOn == true then
            if self.Fire == nil or self.Fire == false then
                return "#dota_hud_error_cant_cast_on_ally"
            end
        end
    end

    if self:GetCaster():GetTeam() ~= hTarget:GetTeam() then
        if self.FireOn == nil or self.FireOn == false then
            return "#dota_hud_error_cant_cast_on_enemy"
        end
    end

    return ""
end

function Healer_divine_touch:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local Bonus = caster:GetUpgradeData("SpecialUpgrade_1_Priest_3").Resist
    CustomNetTables:SetTableValue("modifiers_value", tostring(caster:GetEntityIndex()), {rbonus=Bonus})
    if caster:GetTeam() == target:GetTeam() then
        target:AddNewModifier(caster, self, "modifier_healer_buff_phys_resist", {Duration = duration})
    elseif caster:GetTeam() ~= target:GetTeam() then
        target:AddNewModifier(caster, self, "modifier_healer_debuff_phys_resist", {Duration = duration})
    end
    if caster:IsUpgrade("SpecialUpgrade_1_Priest_5") then
        if caster:GetTeam() == target:GetTeam() then
            target:AddNewModifier(caster, self, "modifier_healer_buff_movespeed_bonus", {Duration = duration})
        elseif caster:GetTeam() ~= target:GetTeam() then
            target:AddNewModifier(caster, self, "modifier_healer_debuff_movespeed_bonus", {Duration = duration})
        end
    end
    if caster:IsUpgrade("SpecialUpgrade_1_Priest_6") then
        if caster:GetTeam() == target:GetTeam() then
            target:AddNewModifier(caster, self, "modifier_healer_buff_s_resistance_bonus", {Duration = duration})
        elseif caster:GetTeam() ~= target:GetTeam() then
            target:AddNewModifier(caster, self, "modifier_healer_debuff_s_resistance_bonus", {Duration = duration})
        end
    end
end

LinkLuaModifier( "modifier_healer_buff_phys_resist", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_buff_phys_resist = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE} end,
    GetModifierIncomingPhysicalDamage_Percentage = function(self)
    local netTable = CustomNetTables:GetTableValue("modifiers_value", tostring(self:GetCaster():GetEntityIndex()))
    local nbonus = netTable and netTable.rbonus or 0
    local bonus = self:GetCaster():IsUpgrade("SpecialUpgrade_1_Priest_3") and nbonus or 0
    return self:GetAbility():GetSpecialValueFor("phys_resist") - bonus
    end,
})

LinkLuaModifier( "modifier_healer_debuff_phys_resist", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_debuff_phys_resist = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE} end,
    GetModifierIncomingPhysicalDamage_Percentage = function(self)
    local netTable = CustomNetTables:GetTableValue("modifiers_value", tostring(self:GetCaster():GetEntityIndex()))
    local nbonus = netTable and netTable.rbonus or 0
    local bonus = self:GetCaster():IsUpgrade("SpecialUpgrade_1_Priest_3") and nbonus or 0
    return self:GetAbility():GetSpecialValueFor("phys_resist") * (-1) + bonus
    end,
})

LinkLuaModifier( "modifier_healer_buff_movespeed_bonus", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_buff_movespeed_bonus = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) 
    if IsServer() then self:SetSharedKey("Ms", self:GetCaster():GetUpgradeData("SpecialUpgrade_1_Priest_5").Ms) end end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end,
    GetModifierMoveSpeedBonus_Constant = function(self) return self:GetSharedKey("Ms") end,
})

LinkLuaModifier( "modifier_healer_debuff_movespeed_bonus", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_debuff_movespeed_bonus = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) 
    if IsServer() then self:SetSharedKey("Ms", self:GetCaster():GetUpgradeData("SpecialUpgrade_1_Priest_5").Ms) end end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end,
    GetModifierMoveSpeedBonus_Constant = function(self) return self:GetSharedKey("Ms") * (-1) end,
})

LinkLuaModifier( "modifier_healer_buff_s_resistance_bonus", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_buff_s_resistance_bonus = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) 
    if IsServer() then self:SetSharedKey("Sr", self:GetCaster():GetUpgradeData("SpecialUpgrade_1_Priest_6").Sr) end end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_STATUS_RESISTANCE} end,
    GetModifierStatusResistance = function(self) return self:GetSharedKey("Sr") end,
})

LinkLuaModifier( "modifier_healer_debuff_s_resistance_bonus", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_debuff_s_resistance_bonus = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self)  if IsServer() then self:SetSharedKey("Sr", self:GetCaster():GetUpgradeData("SpecialUpgrade_1_Priest_6").Sr) end end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_STATUS_RESISTANCE} end,
    GetModifierStatusResistance = function(self) return self:GetSharedKey("Sr") * (-1) end,
})

-----------------------------------------------------
--Vow to God/Base ability
-----------------------------------------------------

Healer_vow_to_God = Healer_vow_to_God or class({
	GetAbilityTargetTeam	 	= function(self) return self.Fire and DOTA_UNIT_TARGET_TEAM_BOTH or self.FireOn and DOTA_UNIT_TARGET_TEAM_ENEMY or DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
	GetIntrinsicModifierName 	= function(self) return "modifier_vow_to_god" end,
})

--function Healer_vow_to_God:GetAbilityTextureName() 
--	return "customImages/Healer_vow_to_God"..(FireOnAbility['Healer_vow_to_God'] and FireOnAbility['Healer_vow_to_God'].FireOn and "_2" or "") 
--end

LinkLuaModifier( "modifier_vow_to_god", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_vow_to_god = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end,
    IsAura 					=	function(self) return true end,
    GetAuraRadius			= 	function(self) return self.radius  end,
    GetAuraSearchFlags      = 	function(self) return self.flags end,
    GetAuraSearchTeam      	= 	function(self) return self:GetAbility():GetAbilityTargetTeam() end,
    GetAuraSearchType      	= 	function(self) return self.targetType end,
    GetModifierAura 		=	function(self) return (self:GetAuraSearchTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY or self:GetAuraSearchTeam() == DOTA_UNIT_TARGET_TEAM_BOTH ) and "modifier_vow_to_god_aura_buff" or "modifier_vow_to_god_aura_debuff" end,
})

function modifier_vow_to_god:GetAuraEntityReject(entity) 
	return ((self:GetAuraSearchTeam() == DOTA_UNIT_TARGET_TEAM_BOTH and entity:GetTeam() ~= self:GetCaster():GetTeam() and self:GetModifierAura() == "modifier_vow_to_god_aura_buff")) or self:GetModifierAura() == "modifier_vow_to_god_aura_debuff" and entity:GetTeam() == self:GetCaster():GetTeam()
end

function modifier_vow_to_god:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
	    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_BOTH, self:GetAuraSearchType(), self:GetAuraSearchFlags(), FIND_CLOSEST, false)
		for count, hero in ipairs(units) do
			if caster:IsUpgrade("SpecialUpgrade_1_Priest_2") and hero:GetTeam() == caster:GetTeam() then
				hero:AddNewModifier( caster,self:GetAbility(), 'modifier_vow_to_god_mana', { duration = 1.0 } )
			end
			if hero:GetTeam() ~= caster:GetTeam() and self:GetAuraSearchTeam() == DOTA_UNIT_TARGET_TEAM_BOTH then
				hero:AddNewModifier( caster,self:GetAbility(), 'modifier_vow_to_god_aura_debuff', { duration = 1.0 } )
			end
		end
	end
end

function modifier_vow_to_god:OnCreated() 
	self:StartIntervalThink(0.8)
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.flags = DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
	self.targetType = DOTA_UNIT_TARGET_HERO
end

LinkLuaModifier( "modifier_vow_to_god_aura_buff", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_vow_to_god_aura_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end,
    GetModifierConstantHealthRegen = function(self) return self:GetAbility():GetSpecialValueFor("hp_regen") end,

})

LinkLuaModifier( "modifier_vow_to_god_aura_debuff", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_vow_to_god_aura_debuff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) self:StartIntervalThink(0.5) end,
})

function modifier_vow_to_god_aura_debuff:OnIntervalThink()
    if IsServer() then
        local target = self:GetParent()
        local damage = self:GetCaster():IsUpgrade("SpecialUpgrade_1_Priest_7") and self:GetAbility():GetSpecialValueFor("hp_regen") * self:GetCaster():GetUpgradeData("SpecialUpgrade_1_Priest_7").In or self:GetAbility():GetSpecialValueFor("hp_regen")
        local damageInfo = 
        {
            victim = target,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self:GetAbility(), 
        }
            
        ApplyDamage( damageInfo )
    end
end

LinkLuaModifier( "modifier_vow_to_god_mana", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_vow_to_god_mana = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end,
    GetModifierConstantManaRegen = function(self) return self:GetAbility():GetSpecialValueFor("hp_regen")/2 end,
})

-----------------------------------------------------
--Inquisition/Base ability
-----------------------------------------------------

Healer_inquisition = class({})

--------------------------------------------------------------------------------

function Healer_inquisition:OnToggle()
    local caster = self:GetCaster()

    if self:GetToggleState() then
        SetEnemyFireHealer(caster, true)
    else
        SetEnemyFireHealer(caster, false)
    end
end

function SetEnemyFireHealer(h, b)
    local FindsAbil = {"Healer_call_to_angels","Healer_divine_touch","Healer_vow_to_God"}
    for k,v in pairs(FindsAbil) do
        local a = h:FindAbilityByName(v)
        a.FireOn = b
        if type(FireOnAbility[a:GetAbilityName()]) ~= "table" then
        	FireOnAbility[a:GetAbilityName()] = {}
    	end
    	FireOnAbility[a:GetAbilityName()].FireOn = b
        if h:IsUpgrade("SpecialUpgrade_1_Priest_8") then
            a.Fire = b
            FireOnAbility[a:GetAbilityName()].Fire = b
        end
    end
end

-----------------------------------------------------
--Call to Hell/Additional ability
-----------------------------------------------------

Healer_call_to_hell = class({})

--------------------------------------------------------------------------------

function Healer_call_to_hell:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local mana = self:GetSpecialValueFor("mana")
    target:GiveMana(mana)
end

-----------------------------------------------------
--Pentagram/Additional ability
-----------------------------------------------------

Healer_pentagram = class({})

--------------------------------------------------------------------------------

function Healer_pentagram:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local max_duration = self:GetSpecialValueFor("max_duration")
    local min_duration = self:GetSpecialValueFor("min_duration")
    local dur = RandomFloat(min_duration, max_duration)
    local duration = caster:IsUpgrade("SpecialUpgrade_2_Priest_4") and dur + caster:GetUpgradeData("SpecialUpgrade_2_Priest_4").dBonus or dur
    target:AddNewModifier( caster, self, "modifier_healer_pentagram", { duration = duration } )
    if caster:IsUpgrade("SpecialUpgrade_2_Priest_8") then
        target:AddNewModifier( caster, self, "modifier_healer_pentagram_debuff", { duration = duration } )
    end
end

LinkLuaModifier( "modifier_healer_pentagram", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_pentagram = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_EVENT_ON_ATTACK_START} end,
})

function modifier_healer_pentagram:CheckState()
    local state = {}
    if IsServer() then
        state[MODIFIER_STATE_STUNNED] = true
    end
    
    return state
end

function modifier_healer_pentagram:OnAttackStart(k)
    local caster = self:GetCaster()
    if caster:IsUpgrade("SpecialUpgrade_2_Priest_7") then
        local target = self:GetParent()
        local attacker = k.attacker
        local attacked = k.target

        if attacked == target then
            attacker:AddNewModifier( caster, self:GetAbility(), "modifier_healer_pentagram_as_buff", { duration = 0.75 } )
        end
    end
end

LinkLuaModifier( "modifier_healer_pentagram_as_buff", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_pentagram_as_buff = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) 
    if IsServer() then self:SetSharedKey("bonus_as", self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Healer_7").As) end end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end,
    GetModifierAttackSpeedBonus_Constant = function(self) return self:GetSharedKey("bonus_as") end,
})

LinkLuaModifier( "modifier_healer_pentagram_debuff", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_pentagram_debuff = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) 
	    if IsServer() then 
	    	self:SetSharedKey("phys", self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Priest_8").Phys) 
	    	self:SetSharedKey("mag", self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Priest_8").Mag) 
	    end 
    end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE} end,
    GetModifierIncomingPhysicalDamage_Percentage = function(self) return self:GetSharedKey("phys") end,
    GetModifierMagicalResistanceBonus = function(self) return (self:GetSharedKey("mag") or 0) * (-1) end,
})

-----------------------------------------------------
--Pact with the Devil/Additional ability
-----------------------------------------------------

Healer_pact_with_the_devil = class({})

--------------------------------------------------------------------------------

function Healer_pact_with_the_devil:GetIntrinsicModifierName()
    return "modifier_pact_with_the_devil"
end

LinkLuaModifier( "modifier_pact_with_the_devil", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_pact_with_the_devil = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) self:StartIntervalThink(0.1) end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end,
    GetModifierConstantManaRegen = function(self) return self:GetAbility():GetSpecialValueFor("mp_regen") end,
})

function modifier_pact_with_the_devil:OnIntervalThink()
	if IsServer() then
	    local caster = self:GetParent()
	    if caster:IsUpgrade("SpecialUpgrade_1_Priest_2") then
	        caster:AddNewModifier( caster, self:GetAbility(), "modifier_pact_with_the_devil_hp_regen", { duration = 1.0 } )
	    end
	    local target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	    local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	    local target_flags = DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
	    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), target_team, target_types, target_flags, FIND_CLOSEST, false)
	    if #units > 0 then
	        for count, hero in ipairs(units) do
	            if hero ~= caster then
	                if caster:IsUpgrade("SpecialUpgrade_2_Priest_2") then
	                    hero:AddNewModifier( caster, self:GetAbility(), "modifier_pact_with_the_devil_hp_regen", { duration = 1.0 } )
	                end
	                hero:AddNewModifier( caster, self:GetAbility(), "modifier_pact_with_the_devil_aura_buff", { duration = 1.0 } )
	            end
	        end
	    end
	end
end

LinkLuaModifier( "modifier_pact_with_the_devil_aura_buff", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_pact_with_the_devil_aura_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end,
    GetModifierConstantManaRegen = function(self) return self:GetAbility():GetSpecialValueFor("mp_regen") end,
})

LinkLuaModifier( "modifier_pact_with_the_devil_hp_regen", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_pact_with_the_devil_hp_regen = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end,
    GetModifierConstantHealthRegen = function(self) return self:GetAbility():GetSpecialValueFor("mp_regen")/2 end,
})

-----------------------------------------------------
--Opening the Seal/Additional ability
-----------------------------------------------------

Healer_opening_the_seal = class({})

--------------------------------------------------------------------------------

function Healer_opening_the_seal:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(caster, self, "modifier_healer_buff_mag_resist", {Duration = duration})
    if caster:IsUpgrade("SpecialUpgrade_2_Priest_5") then
        target:AddNewModifier( caster, self, "modifier_healer_ots_damage", { duration = duration } )
    end
    if caster:IsUpgrade("SpecialUpgrade_2_Priest_6") then
        target:AddNewModifier( caster, self, "modifier_healer_ots_lifesteal", { duration = duration } )
    end
end

LinkLuaModifier( "modifier_healer_buff_mag_resist", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_buff_mag_resist = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) 
    	if IsServer() then
    		local bonus = (self:GetCaster():IsUpgrade("SpecialUpgrade_2_Priest_3") and self:GetAbility():GetSpecialValueFor("mag_resist") or 0) + self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Priest_3").Bonus
   			self:SetSharedKey("mag_resist_bonus", bonus) 
   		end
    end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end,
    GetModifierMagicalResistanceBonus = function(self) return self:GetSharedKey("mag_resist_bonus") end,
})

LinkLuaModifier( "modifier_healer_ots_damage", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_ots_damage = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) 
    if IsServer() then self:SetSharedKey("bonus_damage", self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Priest_5").Bonus) end end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE} end,
    GetModifierDamageOutgoing_Percentage = function(self) return self:GetSharedKey("bonus_damage") end,
})

LinkLuaModifier( "modifier_healer_ots_lifesteal", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_ots_lifesteal = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_EVENT_ON_TAKEDAMAGE} end,
})


function modifier_healer_ots_lifesteal:OnTakeDamage(params)
    if params.attacker == self:GetParent() then
        local hero = self:GetParent()
        local lifesteal_pct = self:GetCaster():GetUpgradeData("SpecialUpgrade_2_Priest_6").Bonus / 100
        local dmg = params.damage

        local heal_amount = dmg * lifesteal_pct 

        if heal_amount > 0 and hero:GetHealth() ~= hero:GetMaxHealth() then
            hero:Heal(heal_amount, self:GetAbility())
            ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, hero)
        end
    end
end

-----------------------------------------------------
--Surge of Strength/Additional ability
-----------------------------------------------------

Healer_surge_of_strength = class({})

--------------------------------------------------------------------------------

function Healer_surge_of_strength:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local mana = self:GetSpecialValueFor("mana")
    local health = self:GetSpecialValueFor("health")
    caster:ReduceMana(mana)
    local rHeal = math.max(caster:GetHealth() - health,1)
    caster:SetHealth(rHeal)
    target:GiveMana(mana)
    target:Healing(health)
end

-----------------------------------------------------
--Victim/Additional ability
-----------------------------------------------------

Healer_victim = class({})

--------------------------------------------------------------------------------

function Healer_victim:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    if caster == target then
    	self:EndCooldown()
    	caster:GiveMana(self:GetManaCost(self:GetLevel()))
    	return
    end
    caster:AddNewModifier(caster, self, "modifier_healer_debuff_resist", {Duration = duration})
    target:AddNewModifier(caster, self, "modifier_healer_buff_resist", {Duration = duration})
    if caster:IsUpgrade("SpecialUpgrade_3_Priest_5") then
        caster:AddNewModifier(caster, self, "modifier_healer_debuff_damage", {Duration = duration})
        target:AddNewModifier(caster, self, "modifier_healer_buff_damage", {Duration = duration})
    end
end

LinkLuaModifier( "modifier_healer_buff_resist", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )
modifier_healer_buff_resist = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) 
	    if IsServer() then 
	    	self:SetSharedKey("phys", ((self:GetCaster():IsUpgrade("SpecialUpgrade_3_Priest_3") and self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Priest_3").Phys or 0) + (self:GetAbility():GetSpecialValueFor("phys_resist")) * (-1))) 
	    	self:SetSharedKey("mag", (self:GetCaster():IsUpgrade("SpecialUpgrade_3_Priest_3") and self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Priest_3").Mag or 0) + self:GetAbility():GetSpecialValueFor("mag_resist")) 
	    end 
    end,
    DeclareFunctions        						= function(self) return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE} end,
    GetModifierIncomingPhysicalDamage_Percentage 	= function(self) return self:GetSharedKey("phys") end,
	GetModifierMagicalResistanceBonus 				= function(self) return self:GetSharedKey("mag") end,
})

LinkLuaModifier( "modifier_healer_debuff_resist", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_debuff_resist = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) 
	    if IsServer() then 
	    	self:SetSharedKey("phys",self:GetAbility():GetSpecialValueFor("phys_resist" )/(self:GetCaster():IsUpgrade('SpecialUpgrade_3_Priest_6') and self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Priest_6").Value or 1)) 
	    	self:SetSharedKey("mag", ((self:GetAbility():GetSpecialValueFor("mag_resist") * -1 ))/(self:GetCaster():IsUpgrade('SpecialUpgrade_3_Priest_6') and self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Priest_6").Value or 1)) 
	    end 
    end,
    DeclareFunctions        							= function(self) return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE} end,
    GetModifierIncomingPhysicalDamage_Percentage 		= function(self) return self:GetSharedKey("phys") end,
   	GetModifierMagicalResistanceBonus 					= function(self)  return self:GetSharedKey("mag") end,
})

LinkLuaModifier( "modifier_healer_buff_damage", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_buff_damage = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) 
    if IsServer() then self:SetSharedKey("bonus_damage", self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Priest_5").Bonus) end end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE} end,
    GetModifierDamageOutgoing_Percentage = function(self) return self:GetSharedKey("bonus_damage") end,
})

LinkLuaModifier( "modifier_healer_debuff_damage", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_debuff_damage = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE} end,
    OnCreated               = function(self) 
    if IsServer() then self:SetSharedKey("self_damage", self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Priest_5").Bonus) end end,
    GetModifierIncomingPhysicalDamage_Percentage = function(self) return self:GetSharedKey("self_damage") end,
})

-----------------------------------------------------
--Holiness/Additional ability
-----------------------------------------------------

Healer_holiness = class({})

--------------------------------------------------------------------------------

function Healer_holiness:GetIntrinsicModifierName()
    return "modifier_healer_holiness"
end

LinkLuaModifier( "modifier_healer_holiness", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_holiness = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) self:StartIntervalThink(0.1) self:SetStackCount(1) end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end,
    GetModifierConstantManaRegen = function(self) return self:GetAbility():GetSpecialValueFor("mp_hp_regen") * self:GetStackCount() end,
    GetModifierConstantHealthRegen = function(self) return self:GetAbility():GetSpecialValueFor("mp_hp_regen") * self:GetStackCount() end,
})

function modifier_healer_holiness:OnIntervalThink()
    local caster = self:GetParent()
    if IsServer() then
	    if caster:IsUpgrade("SpecialUpgrade_3_Priest_2") and self:GetStackCount() ~= 2 then
	        self:SetStackCount(2)
	    end
	end
end


-----------------------------------------------------
--Blood Ties/Additional ability
-----------------------------------------------------

Healer_blood_ties = class({})

--------------------------------------------------------------------------------

function Healer_blood_ties:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if caster == target then
    	self:EndCooldown()
    	caster:GiveMana(self:GetManaCost(self:GetLevel()))
    	return
    end
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(caster, self, "modifier_healer_blood_ties_buff", {Duration = duration})
    caster:AddNewModifier(caster, self, "modifier_healer_blood_ties_tooltip", {Duration = duration})
    if caster:IsUpgrade("SpecialUpgrade_3_Priest_4") then
        caster:AddNewModifier(caster, self, "modifier_healer_blood_ties_movespeed", {Duration = duration})
        target:AddNewModifier(caster, self, "modifier_healer_blood_ties_movespeed", {Duration = duration})
    end
    if caster:IsUpgrade("SpecialUpgrade_3_Priest_7") then
        caster:AddNewModifier(caster, self, "modifier_healer_blood_ties_vampirism", {Duration = duration})
        target:AddNewModifier(caster, self, "modifier_healer_blood_ties_vampirism", {Duration = duration})
    end
    if caster:IsUpgrade("SpecialUpgrade_3_Priest_8") then
        caster:AddNewModifier(caster, self, "modifier_healer_blood_ties_self_guard", {Duration = duration})
    end
end

LinkLuaModifier( "modifier_healer_blood_ties_buff", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_blood_ties_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    OnCreated               = function(self) self:StartIntervalThink(0.1) end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end,
    GetModifierConstantManaRegen = function(self) return self:GetCaster():GetManaRegen() end,
    GetModifierIncomingDamage_Percentage = function(self) return self:GetAbility():GetSpecialValueFor("block") * (-1) end,
})

function modifier_healer_blood_ties_buff:OnIntervalThink()
    local target = self:GetParent()
    local caster = self:GetCaster()
    local max_range = self:GetAbility():GetSpecialValueFor("max_range")
    local Distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
    target:Heal(caster:GetHealthRegen()/10, caster)
    if Distance > max_range then
        caster:RemoveModifierByName("modifier_healer_blood_ties_tooltip")
        if caster:IsUpgrade("SpecialUpgrade_3_Priest_4") then
            caster:RemoveModifierByName("modifier_healer_blood_ties_movespeed")
            target:RemoveModifierByName("modifier_healer_blood_ties_movespeed")
        end
        if caster:IsUpgrade("SpecialUpgrade_3_Priest_7") then
            caster:RemoveModifierByName("modifier_healer_blood_ties_vampirism")
            target:RemoveModifierByName("modifier_healer_blood_ties_vampirism")
        end
        if caster:IsUpgrade("SpecialUpgrade_3_Priest_8") then
            caster:RemoveModifierByName("modifier_healer_blood_ties_self_guard")
        end
        self:Destroy()
    end
end

LinkLuaModifier( "modifier_healer_blood_ties_movespeed", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_blood_ties_movespeed = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end,
    OnCreated               = function(self) 
    if IsServer() then self:SetSharedKey("movespeed", self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Priest_4").Value) end end,
    GetModifierMoveSpeedBonus_Percentage = function(self) return self:GetSharedKey("movespeed") end,
})

LinkLuaModifier( "modifier_healer_blood_ties_vampirism", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_blood_ties_vampirism = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_EVENT_ON_TAKEDAMAGE} end,
})


function modifier_healer_blood_ties_vampirism:OnTakeDamage(params)
    if params.attacker == self:GetParent() then
        local hero = self:GetParent()
        local lifesteal_pct = self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Priest_7").Value / 100
        local dmg = params.damage

        local heal_amount = dmg * lifesteal_pct 

        if heal_amount > 0 and hero:GetHealth() ~= hero:GetMaxHealth() then
            hero:Heal(heal_amount, self:GetAbility())
            ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, hero)
        end
    end
end

LinkLuaModifier( "modifier_healer_blood_ties_self_guard", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_blood_ties_self_guard = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end,
    OnCreated               = function(self) 
    if IsServer() then self:SetSharedKey("phys", self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Priest_8").Resist) self:SetSharedKey("mag", self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Priest_8").Resist) self:SetSharedKey("block", self:GetCaster():GetUpgradeData("SpecialUpgrade_3_Priest_8").Block) end end,
    GetModifierIncomingPhysicalDamage_Percentage = function(self) return self:GetSharedKey("phys") * (-1) end,
    GetModifierMagicalResistanceBonus = function(self) return self:GetSharedKey("mag") end,
    GetModifierIncomingDamage_Percentage = function(self) return self:GetSharedKey("block") * (-1) end,
})

LinkLuaModifier( "modifier_healer_blood_ties_tooltip", "ability/humansAbility.lua", LUA_MODIFIER_MOTION_NONE )

modifier_healer_blood_ties_tooltip = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
})

LinkLuaModifier( "modifier_healer_cast_range_bonus", "ability/humansModifier.lua", LUA_MODIFIER_MOTION_NONE ) 

modifier_healer_cast_range_bonus = class({ 
	IsHidden = function(self) return true end, 
	IsPurgable = function(self) return false end, 
	IsDebuff = function(self) return false end, 
	IsBuff = function(self) return true end, 
	RemoveOnDeath = function(self) return true end, 
	OnCreated = function(self) 
	self:SetSharedKey("Range", GetUpgradeData("SpecialUpgrade_1_Healer_4").Range) end, 
	DeclareFunctions = function(self) return {MODIFIER_PROPERTY_CAST_RANGE_BONUS} end, 
	GetModifierCastRangeBonus = function(self) return self:GetSharedKey("Range") end, 
})