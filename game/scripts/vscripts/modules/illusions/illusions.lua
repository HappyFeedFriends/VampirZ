-- Author: Angel arena Black Star
Illusions = Illusions or {}

function Illusions:_copyAbilities(unit, illusion)
	for slot = 0, unit:GetAbilityCount() - 1 do
		local illusionAbility = illusion:GetAbilityByIndex(slot)
		local unitAbility = unit:GetAbilityByIndex(slot)

		if unitAbility then
			local newName = unitAbility:GetAbilityName()
			if illusionAbility then
				if illusionAbility:GetAbilityName() ~= newName then
					illusion:RemoveAbility(illusionAbility:GetAbilityName())
					illusionAbility = illusion:AddNewAbility(newName, true)
				end
			else
				illusionAbility = illusion:AddNewAbility(newName, true)
			end
			illusionAbility:SetHidden(unitAbility:IsHidden())
			local ualevel = unitAbility:GetLevel()
			if ualevel > 0 and illusionAbility:GetAbilityName() ~= "meepo_divided_we_stand" then
				illusionAbility:SetLevel(ualevel)
			end
		elseif illusionAbility then
			illusion:RemoveAbility(illusionAbility:GetAbilityName())
		end
	end
end

function Illusions:_copyItems(unit, illusion)
	for slot = 0, 5 do
		local illusionItem = illusion:GetItemInSlot(slot)
		if illusionItem then
			illusion:RemoveItem(illusionItem)
		end
	end

	for slot = 0, 5 do
		local item = unit:GetItemInSlot(slot)
		if item then
			local illusionItem = CreateItem(item:GetName(), illusion, illusion)
			illusionItem:SetCurrentCharges(item:GetCurrentCharges())
			illusionItem.suggestedSlot = slot
			illusion:AddItem(illusionItem)
		end
	end
end

function Illusions:_copyLevel(unit, illusion)
	local level = unit:GetLevel()
	for i = 1, level - 1 do
		illusion:HeroLevelUp(false)
	end
end

function Illusions:_copyAppearance(unit, illusion)
	illusion:SetModelScale(unit:GetModelScale())
	if unit:GetModelName() ~= illusion:GetModelName() then
		illusion.ModelOverride = unit:GetModelName()
		illusion:SetModel(illusion.ModelOverride)
		illusion:SetOriginalModel(illusion.ModelOverride)
	end
	local rc = unit:GetRenderColor()
	if rc ~= Vector(255, 255, 255) then
		illusion:SetRenderColor(rc.x, rc.y, rc.z)
	end
end

function Illusions:_copyEverything(unit, illusion)
	illusion:SetAbilityPoints(0)
	Illusions:_copyAbilities(unit, illusion)
	Illusions:_copyItems(unit, illusion)
	Illusions:_copyAppearance(unit, illusion)
	illusion.UnitName = unit.UnitName
	local heroName = unit:GetFullName()
	if not NPC_HEROES[heroName] and NPC_HEROES_CUSTOM[heroName] then
		TransformUnitClass(illusion, NPC_HEROES_CUSTOM[heroName], true)
	end

	illusion:SetHealth(unit:GetHealth())
	illusion:SetMana(unit:GetMana())
end
--[[
	unit
	ability
	origin --
	isOwned --
	damageOutgoing
	damageIncoming
	duration
	team --
	
]]
function Illusions:create(info)
	local ability = info.ability
	local unit = info.unit
	local origin = info.origin or unit:GetAbsOrigin()
	local team = info.team or unit:GetTeamNumber()
	local isOwned = info.isOwned
	if isOwned == nil then isOwned = true end
	local illusion = CreateUnitByName(
		unit:GetUnitName(),
		origin,
		true,
		isOwned and unit or nil,
		isOwned and unit:GetPlayerOwner() or nil,
		team
	)
	if isOwned then illusion:SetControllableByPlayer(unit:GetPlayerID(), true) end
	FindClearSpaceForUnit(illusion, origin, true)
	illusion:SetForwardVector(unit:GetForwardVector())

	Illusions:_copyLevel(unit, illusion)

	illusion.isCustomIllusion = true
	illusion:AddNewModifier(unit, ability, "modifier_illusion", {
		duration = info.duration,
		outgoing_damage = info.damageOutgoing - 100,
		incoming_damage = info.damageIncoming - 100,
	})
	illusion:MakeIllusion()

	return illusion
end