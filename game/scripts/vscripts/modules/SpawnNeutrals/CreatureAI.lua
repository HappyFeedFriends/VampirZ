local radius = 299999
function Spawn( entityKeyValues ) 
	
    if not IsServer() or not thisEntity then
        return
    end
	thisEntity.startPosition = thisEntity:GetAbsOrigin()
    thisEntity:SetContextThink( "Think", ThinkEntity, 1 )  
end

function ThinkEntity()
    if ( not thisEntity or not thisEntity:IsAlive() ) then     
        return -1
    end

    if GameRules:IsGamePaused() then   
		return 1 
	end
	local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(),thisEntity:GetOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
	if #enemies > 0 and not thisEntity.aggresive then
		for _,target in pairs(enemies) do	
			if --[[ thisEntity.targetAttack ~= target and ]] target:GetUnitName() ~= "npc_dummy_unit" and target:GetUnitName() ~= "npc_dota_hero_target_dummy" and target:IsAlive()  then
				--thisEntity.targetAttack = target
				--ExecuteOrderFromTable({
				--	UnitIndex = thisEntity:entindex(),
				--	OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				--	TargetIndex = target:entindex(),
				--	Position  = target:GetAbsOrigin(),
				--})
				thisEntity:SetForceAttackTarget(target)			
				break
			end
		end
	else
		thisEntity:Stop()
	end 
    return 0.5
end
function BackToStart()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = thisEntity.startPosition or thisEntity:GetAbsOrigin()
	})
end 
