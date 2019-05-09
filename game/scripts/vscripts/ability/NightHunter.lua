NightHunter_ability1 = class({})
NightHunter_ability2 = class({})
NightHunter_ability3 = class({})
NightHunter_ability4 = class({})
NightHunter_ability5 = class({})
NightHunter_ability6 = class({})
NightHunter_ability7 = class({})
NightHunter_ability8 = class({})

function NightHunter_ability1:OnSpellStart()
	local caster = self:GetCaster()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetOrigin(),nil,self:GetSpecialValueFor('radius'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_FARTHEST,false)
	if #enemies > 0 then
		local duration  = self:GetSpecialValueFor('duration_stunned')
		local dur = 0
		enemies[1]:AddNewModifier(caster,self,'modifier_stunned',{duration = duration})
		enemies[1]:AddNewModifier(caster,self,'modifier_debuff_fire',{
			duration = 3,
			tick_interval = 0.3,
			fullDamage = self:GetSpecialValueFor('damage'),
			DamageType = DAMAGE_TYPE_MAGICAL,
		})
	end 
end

function NightHunter_ability2:OnSpellStart()
	local caster = self:GetCaster()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetOrigin(),nil,self:GetSpecialValueFor('radius'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
	local particle = ParticleManager:CreateParticle('particles/neutral_fx/roshan_slam.vpcf', PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, v, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)
	for k,v in pairs(enemies) do
		if v ~= caster then
			ApplyDamage({
				victim =  v, 
				attacker =  caster, 
				damage =  self:GetSpecialValueFor('damage'), 
				damage_type =  DAMAGE_TYPE_PURE,  
				ability =  self, 
			})
			v:AddNewModifier(caster,self,'modifier_stunned',{duration = self:GetSpecialValueFor('duration_stunned')})
		end
	end 
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Centaur.HoofStomp", caster)
end

function NightHunter_ability3:OnAbilityPhaseStart()
	local radius = self:GetSpecialValueFor('radius')
	self.startabs = self:GetCaster():GetAbsOrigin()
	self.particle = ParticleManager:CreateParticle('particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_ring_lv.vpcf', PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( self.particle, 0, self.startabs )
	ParticleManager:SetParticleControl( self.particle, 1, Vector( radius, radius, radius ) )
	EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "Hero_Bloodseeker.BloodRite.Cast", self:GetCaster())
	EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "Hero_Bloodseeker.BloodRite", self:GetCaster())
	return true
end

function NightHunter_ability3:OnSpellStart()
	local thisEntity = self:GetCaster()
	local enemiesAbility3 = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,self:GetSpecialValueFor('radius'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
	for k,v in pairs(enemiesAbility3) do 
		ApplyDamage({
			victim =  v, 
			attacker =  thisEntity, 
			damage =  self:GetSpecialValueFor('damage'), 
			damage_type =  DAMAGE_TYPE_PURE,  
			ability =  self, 
		})
		EmitSoundOn("hero_bloodseeker.bloodRite.silence", v)
	end 
    if IsServer() and self.particle then
    	local radius = self:GetSpecialValueFor('radius')
        ParticleManager:DestroyParticle(self.particle, true)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = ParticleManager:CreateParticle('particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_explode.vpcf', PATTACH_CUSTOMORIGIN, thisEntity)
		ParticleManager:SetParticleControl( self.particle, 0, self.startabs )
		ParticleManager:SetParticleControl( self.particle, 1, Vector( radius, radius, radius ) )
		Timers:CreateTimer(0.5,function()
			ParticleManager:DestroyParticle(self.particle, true)
        	ParticleManager:ReleaseParticleIndex(self.particle)
		end)
    end
end

function NightHunter_ability4:OnSpellStart()
	local count = 0 
	Timers:CreateTimer(0.5,function()
		self:CreateFireMeteor()
		count = count+1
		return count <= self:GetSpecialValueFor('countMeteor') and 0.5 or nil
	end)
end 

function NightHunter_ability4:CreateFireMeteor()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin() + RandomVector(RandomFloat(100,self:GetSpecialValueFor('radius') + 100))
	local particle = ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_POINT, caster, {
		[0] = point + Vector(0,0,1000),
		[1] = point,
		[2] = Vector(1.3,0,0)
	 })
	caster:CreateParticleOfAction({
		radius = self:GetSpecialValueFor('radiusMeteor'),
		point = point
	})
	 Timers:CreateTimer(1.3, function()
	 	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetOrigin(),nil,self:GetSpecialValueFor('radiusMeteor'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
	 	for k,v in pairs(enemies) do 
			ApplyDamage({
				victim =  v, 
				attacker =  caster, 
				damage =  self:GetSpecialValueFor('damage'), 
				damage_type =  DAMAGE_TYPE_PURE,  
				ability =  self, 
			})
			v:AddNewModifier(caster,self,'modifier_debuff_fire',{
				duration = 3,
				tick_interval = 0.3,
				fullDamage = 30,
				DamageType = DAMAGE_TYPE_PURE,
			})
	 	end 
       	EmitSoundOnLocationWithCaster(point, "Hero_Invoker.ChaosMeteor.Impact", caster)
	end)
end

function NightHunter_ability5:OnAbilityPhaseStart()
	local thisEntity = self:GetCaster()
	local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,self:GetSpecialValueFor('radius'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
	if #enemies > 0 then
		self.abs = enemies[1]:GetAbsOrigin()
		thisEntity:CreateParticleOfAction({
			radius = self:GetSpecialValueFor('radius_damage'),
			point = self.abs,
		})
	end
	return true
end

function NightHunter_ability5:OnSpellStart()
	local thisEntity = self:GetCaster()
	local radius = self:GetSpecialValueFor('radius_damage')
	if not self.abs then
		return
	end
	local particle = ParticleManager:CreateParticle('particles/econ/items/leshrac/leshrac_tormented_staff/leshrac_split_tormented.vpcf', PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl( particle, 0, self.abs )
	ParticleManager:SetParticleControl( particle, 1, Vector( radius, radius, radius ) )
	local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(),self.abs,nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
	for k,v in pairs(enemies) do
		local target = v;
		ApplyDamage({
			victim =  target, 
			attacker =  self:GetCaster(), 
			damage =  target:GetHealth() /100 *self:GetSpecialValueFor('damage'), 
			damage_type =  DAMAGE_TYPE_MAGICAL,  
			ability =  self, 
		})
	end
	EmitSoundOnLocationWithCaster(thisEntity:GetAbsOrigin(), "Hero_Leshrac.Split_Earth", thisEntity)
end

function NightHunter_ability6:OnSpellStart()
	local count = self:GetSpecialValueFor('countUnit')
	local caster = self:GetCaster()
	local abs = caster:GetAbsOrigin()
	local units = {
		'npc_vampirZ_boss_zombie_unit',
		'npc_vampirZ_boss_angry_spirit_unit',
	}
	for i=1, count do 
		local unit = CreateUnitByName(units[RandomInt(1,#units)], abs + RandomVector(RandomFloat(120,300)), true, nil, nil, caster:GetTeamNumber())
		unit:AddNewModifier(self:GetCaster(),self,'modifier_kill',{duration = 40})
	end
end

function NightHunter_ability7:OnAbilityPhaseStart()
	local thisEntity = self:GetCaster()
	local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,self:GetSpecialValueFor('radius'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
	self.target = enemies[RandomInt(1,#enemies)]
	self.abs = self.target:GetAbsOrigin()
	thisEntity:CreateParticleOfAction({
		radius = self:GetSpecialValueFor('ring_radius'),
		point = self.abs,
	})
	return true
end

function NightHunter_ability7:OnSpellStart()
	local thisEntity = self:GetCaster()
	local abs = thisEntity:GetAbsOrigin()
	local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(),self.abs,nil,self:GetSpecialValueFor('ring_radius'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
	if #enemies < 1 then
		return 
	end 
	local radius = self:GetSpecialValueFor('ring_radius')
	for k,v in pairs(enemies) do
		v:AddNewModifier(thisEntity,self,'modifier_ability7',{duration = self:GetSpecialValueFor('duration')})
		self.particle = ParticleManager:CreateParticle('particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_ring_lv.vpcf', PATTACH_CUSTOMORIGIN, thisEntity)
		ParticleManager:SetParticleControl( self.particle, 0, self.abs )
		ParticleManager:SetParticleControl( self.particle, 1, Vector( radius, radius, radius ) )
		Timers:CreateTimer(self:GetSpecialValueFor('duration'),function()
			ParticleManager:DestroyParticle(self.particle, true)
        	ParticleManager:ReleaseParticleIndex(self.particle)
		end)
	end

end

modifier_ability7 = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
})
LinkLuaModifier("modifier_ability7", "ability/NightHunter", LUA_MODIFIER_MOTION_NONE)
function modifier_ability7:OnCreated()
	if IsServer() then
		self.startabs = self:GetParent():GetAbsOrigin()
	end
end

function modifier_ability7:OnDestroy()
	if IsServer() then
		local radius = self:GetAbility():GetSpecialValueFor('ring_radius')
        self.particle = ParticleManager:CreateParticle('particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_explode.vpcf', PATTACH_CUSTOMORIGIN, thisEntity)
		ParticleManager:SetParticleControl( self.particle, 0, self.startabs )
		ParticleManager:SetParticleControl( self.particle, 1, Vector( radius, radius, radius ) )
		Timers:CreateTimer(0.5,function()
			ParticleManager:DestroyParticle(self.particle, true)
        	ParticleManager:ReleaseParticleIndex(self.particle)
		end)
	end
end

function modifier_ability7:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
    }

    return state
end
