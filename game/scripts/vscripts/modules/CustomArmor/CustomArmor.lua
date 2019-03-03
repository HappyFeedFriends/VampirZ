if not CustomDamage then
	CustomDamage = class({})
end

if not CustomArmor then
	CustomArmor = class({})
end

function CustomArmor:GetArmorResistance(unit)
	local armor = math.round(unit:GetPhysicalArmorValue())
	return math.min(math.floor((0.06 * armor)/(1 + 0.06 * armor)*100),100)
end
function CustomDamage:ApplyDamage(unit,attacker,damage)
	ApplyDamage({
	victim = unit,
	attacker = attacker,
	damage = damage/100*CustomArmor:GetArmorResistance(unit),
	damage_type = DAMAGE_TYPE_PURE,
	})
end
