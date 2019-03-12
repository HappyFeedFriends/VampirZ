LinkLuaModifier( "modifier_item_colt_buff", "items/humans/bullets" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_pistol_buff", "items/humans/bullets" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_automatic_buff", "items/humans/bullets" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_awp_buff", "items/humans/bullets" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_rifle_buff", "items/humans/bullets" ,LUA_MODIFIER_MOTION_NONE )

item_colt = class({
	GetIntrinsicModifierName = function(self) return "modifier_item_colt_buff" end
})

modifier_item_colt_buff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED} end,
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
})

function modifier_item_colt_buff:OnAttackLanded(data)
	local target = data.target
	if target:IsAlive() and data.attacker == self:GetCaster() then
		target:Kill(self:GetAbility(),self:GetCaster())
		self:GetCaster().KilledUnitColt = (self:GetCaster().KilledUnitColt or 0) + 1
		if self:GetCaster().KilledUnitColt >= 2  then
			self:GetCaster():RemoveItem(self:GetAbility())
		end 
	end 
end

item_pistol = class({
	GetIntrinsicModifierName = function(self) return "modifier_item_pistol_buff" end
})

modifier_item_pistol_buff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end,
	GetModifierPreAttack_BonusDamage = function(self) return self:GetSharedKey("damage") end,
	GetModifierAttackSpeedBonus_Constant = function(self) return self:GetSharedKey("as") end,
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
})

function modifier_item_pistol_buff:OnCreated()
	if IsServer() then
		self:SetSharedKey("damage",self:GetAbility():GetSpecialValueFor("damage"))
		self:SetSharedKey("as",self:GetAbility():GetSpecialValueFor("attack_speed"))
	end
end 

item_automatic = class({
	GetIntrinsicModifierName = function(self) return "modifier_item_automatic_buff" end
})

modifier_item_automatic_buff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end,
	GetModifierPreAttack_BonusDamage = function(self) return self:GetSharedKey("damage") end,
	GetModifierAttackSpeedBonus_Constant = function(self) return self:GetSharedKey("as") end,
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
})

function modifier_item_automatic_buff:OnCreated()
	if IsServer() then
		self:SetSharedKey("damage",self:GetAbility():GetSpecialValueFor("damage"))
		self:SetSharedKey("as",self:GetAbility():GetSpecialValueFor("attack_speed"))
	end
end 
item_awp = class({
	GetIntrinsicModifierName = function(self) return "modifier_item_awp_buff" end
})

modifier_item_awp_buff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end,
	GetModifierPreAttack_BonusDamage 		= function(self) return self:GetSharedKey("damageAWP") end,
	GetModifierAttackSpeedBonus_Constant 	= function(self) return self:GetSharedKey("as") end,
	GetModifierAttackRangeBonus 			= function(self) return self:GetSharedKey("attackRange") end,
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
})
function modifier_item_awp_buff:OnCreated()
	if IsServer() then
		self:SetSharedKey("damageAWP",self:GetAbility():GetSpecialValueFor("damage"))
		self:SetSharedKey("as",self:GetAbility():GetSpecialValueFor("attack_speed"))
		self:SetSharedKey("attackRange",self:GetAbility():GetSpecialValueFor("attack_range") or 0)
	end
end 
item_rifle = class({
	GetIntrinsicModifierName = function(self) return "modifier_item_rifle_buff" end
})

modifier_item_rifle_buff = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED} end,
	GetAttributes = function(  ) return MODIFIER_ATTRIBUTE_MULTIPLE end
})

function modifier_item_rifle_buff:OnAttackLanded(data)
	local target = data.target
	local caster = self:GetParent()
	if target:IsAlive() and data.attacker == self:GetCaster() then
			local ability = self:GetAbility()
			local minDamage = ability:GetSpecialValueFor("damage_min")
			local maxDamage = ability:GetSpecialValueFor("damage_max")
		local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
		ApplyDamage({
			victim = target,
			attacker = caster,
			damage = math.max(maxDamage - ((distance - 200) * 0.4),minDamage),
			damage_type = DAMAGE_TYPE_PURE,
		})
	end
end
