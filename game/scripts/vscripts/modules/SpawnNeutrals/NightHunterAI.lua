function Spawn( entityKeyValues ) 
	
    if not IsServer() or not thisEntity then
        return
    end
    Ability1 = thisEntity:FindAbilityByName( "NightHunter_ability1" )
    Ability2 = thisEntity:FindAbilityByName( "NightHunter_ability2" )
    Ability3 = thisEntity:FindAbilityByName( "NightHunter_ability3" )
    Ability4 = thisEntity:FindAbilityByName( "NightHunter_ability4" )
    Ability5 = thisEntity:FindAbilityByName( 'NightHunter_ability5' )
    Ability6 = thisEntity:FindAbilityByName( 'NightHunter_ability6' )
    Ability7 = thisEntity:FindAbilityByName( 'NightHunter_ability7' )
    Ability8 = thisEntity:FindAbilityByName( 'NightHunter_ability8' )


    thisEntity:SetContextThink( "Think", ThinkEntity, 1.5 )
end

function ThinkEntity()
    if ( not thisEntity or not thisEntity:IsAlive() ) then     
        return -1
    end
    if GameRules:IsGamePaused() then   
		return 0.1 
	end
	thisEntity.stage = thisEntity:GetHealthPercent() >= 50 and 1 or
    				   thisEntity:GetHealthPercent() >= 25 and 2 or 3
	if thisEntity.stage == 1 then
		-- [radius stun]
		local enemiesAbility1 = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,Ability1:GetSpecialValueFor('radius') - 300,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
		if #enemiesAbility1 > 0 and Ability1:IsFullyCastable() then
			thisEntity:CastAbilityNoTarget(Ability1, -1)
			return Ability1:GetCastPoint() + 0.4
		end 
		-- [damage end hero]
		local enemiesAbility2 = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,Ability2:GetSpecialValueFor('radius'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
		if #enemiesAbility2 > 0 and Ability2:IsFullyCastable() then
			thisEntity:CastAbilityNoTarget( Ability2, -1 )
			thisEntity:CreateParticleOfAction({
				radius = Ability2:GetSpecialValueFor('radius'),
			})
			return Ability2:GetCastPoint() + 0.4
		end
	end

	if thisEntity.stage == 2 then
		-- [AOE BLOOD RITE]
		local enemiesAbility3 = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,Ability3:GetSpecialValueFor('radius'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
		if #enemiesAbility3 > 0 and Ability3:IsFullyCastable() then
			thisEntity:CastAbilityNoTarget( Ability3, -1 )
			thisEntity:CreateParticleOfAction({
				radius = Ability3:GetSpecialValueFor('radius'),
				shockwave = true,
			})
			return Ability3:GetCastPoint() + 0.4
		end
		-- [METEORS]
		local enemiesAbility4 = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,Ability4:GetSpecialValueFor('radius'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
		if #enemiesAbility4 > 0 and Ability4:IsFullyCastable() then
			thisEntity:CastAbilityNoTarget( Ability4, -1 )
			return Ability4:GetCastPoint() + 0.4
		end
		-- [LESHRACK, 50% HEALTH DAMAGE]
		local enemiesAbility5 = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,Ability5:GetSpecialValueFor('radius'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
		if #enemiesAbility5 > 0 and Ability5:IsFullyCastable() then
			thisEntity:CastAbilityNoTarget( Ability5, -1 )
			return Ability5:GetCastPoint() + 0.4
		end
	end

	if thisEntity.stage == 3 then
		-- [SPAWN ZOMBIES]
		if  Ability6:IsFullyCastable() then
			thisEntity:CastAbilityNoTarget( Ability6, -1 )
			return Ability6:GetCastPoint() + 0.4
		end
		-- [DEBUFF HERO RING]
		local enemiesAbility7 = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,Ability7:GetSpecialValueFor('radius'),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
		if  #enemiesAbility7 > 0 and Ability7:IsFullyCastable() then
			thisEntity:CastAbilityNoTarget( Ability7, -1 )
			return Ability7:GetCastPoint() + 0.4
		end
	end
    return 1.5
end