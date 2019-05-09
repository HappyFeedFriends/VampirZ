
function GetDOTATimeInMinutesFull()
	return math.floor(GameRules:GetDOTATime(false, false)/60)
end

function GetDotaFormatTime(time)
	time = time or GameRules:GetDOTATime(false, false)
	local minutes = math.floor(time / 60)
    local seconds = time - (minutes * 60)
	seconds = math.round(seconds)
	minutes = math.round(minutes)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)    
   return m10 .. m01 .. ":" .. s10 .. s01
end

function DebugPrint(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    print(...)
  end
end

function GetTableAllCost()
	local tables = {}
	for k,v in pairs(CUSTOM_SHOP) do
		for a,d in pairs(v) do
			for e,q in pairs(d) do
				if not table.FindStringTable(q,tables) then
					tables[q] = GetTrueItemCost(q)
				end 
			end 
		end 
	end 
	return tables
end

-- Ark120202
function GetTrueItemCost(name)
	local cost = GetItemCost(name)
	if cost <= 0 then
		local tempItem = CreateItem(name, nil, nil)
		if not tempItem then
			print("[GetTrueItemCost] Warning: " .. name)
		else
			cost = tempItem:GetCost()
			UTIL_Remove(tempItem)
		end
	end
	return cost
end
function IsDev(playerId)
	return PlayerResource:GetSteamAccountID(playerId) == 311310226 
end

function CDOTA_BaseNPC:GetModifierLifeSteal()
	local lifesteal = 0
	for _, modifier in pairs(self:FindAllModifiers()) do
		if modifier.GetModifierLifeSteal then
			lifesteal = lifesteal + modifier:GetModifierLifeSteal()
		end
	end
	return lifesteal
end

function RemoveAbilityWithModifiers(unit, ability)
	for _,v in ipairs(unit:FindAllModifiers()) do
		if v:GetAbility() == ability then
			v:Destroy()
		end
	end
end

function RemoveAllUnitsByName(name)
	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _,v in ipairs(units) do
		if v:GetUnitName():match(name) then
			v:ForceKill(true)
			UTIL_Remove(v)
		end
	end
end

function TooltipMessage(number,victim,types)
	if number > 0 then
		local vector2 = types == "BLOOD" and Vector( 108, 211, 246 )
		local vector1 = string.len( math.floor( number ) ) + 1
		local particle = ParticleManager:CreateParticle( "particles/msg_fx/msg_goldbounty.vpcf", PATTACH_POINT_FOLLOW, victim)
		ParticleManager:SetParticleControl( particle, 0, Vector( 40, 0, 75 ) )
		ParticleManager:SetParticleControl( particle, 1, Vector( 0, number, 4 ) )
		ParticleManager:SetParticleControl( particle, 2, Vector( 1, vector1, 1 ) )
		ParticleManager:SetParticleControl( particle, 3, vector2 )
	end		
end

function GetAccesCheatsPlayer(playerId)
	if IsDev(playerId) then
		return DEV_ACCESS
	elseif GameRules:IsCheatMode() then
		return	CHEAT_LOBBY_ACCESS
	end
	return USUAL_ACCESS
end

function FindAllOwnedUnits(player)
	local summons = {}
	local pid = type(player) == "number" and player or player:GetPlayerID()
	local units = FindUnitsInRadius(PlayerResource:GetTeam(pid), Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)
	for _,v in ipairs(units) do
		if type(player) == "number" and ((v.GetPlayerID ~= nil and v:GetPlayerID() or v:GetPlayerOwnerID()) == pid) or v:GetPlayerOwner() == player then
			if not (v:HasModifier("modifier_dummy_unit") or v:HasModifier("modifier_containers_shopkeeper_unit") or v:HasModifier("modifier_teleport_passive")) and v ~= hero then
				table.insert(summons, v)
			end
		end
	end
	return summons
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    PrintTable(...)
  end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end

function HideWearables( hero )
	hero.hiddenWearables = {} 
	local model = hero:FirstMoveChild()
	while model ~= nil do 
		if model:GetClassname() == "dota_item_wearable" or model:GetClassname() == "prop_dynamic" then
			model:AddEffects(EF_NODRAW) 
			table.insert(hero.hiddenWearables, model)
		end
		model = model:NextMovePeer()
	end
end

function RemoveWearables( hero )
	local RemoveWearables = {} 
	local model = hero:FirstMoveChild()
	while model ~= nil do 
		if model:GetClassname() == "dota_item_wearable" or model:GetClassname() == "prop_dynamic" then
			table.insert(RemoveWearables, model)
		end
		model = model:NextMovePeer()
	end
	for k,v in pairs(RemoveWearables) do
		UTIL_Remove(v)
	end 
end

function ShowWearables( unit )

  for i,v in pairs(unit.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end

function GetDirectoryFromPath(path)
	return path:match("(.*[/\\])")
end

function ModuleRequire(path,file)
	return require(GetDirectoryFromPath(path) .. file)
end

function UnitVarToPlayerID(unitvar)
  if unitvar then
    if type(unitvar) == "number" then
      return unitvar
    elseif type(unitvar) == "table" and not unitvar:IsNull() and unitvar.entindex and unitvar:entindex() then
      if unitvar.GetPlayerID and unitvar:GetPlayerID() > -1 then
        return unitvar:GetPlayerID()
      elseif unitvar.GetPlayerOwnerID then
        return unitvar:GetPlayerOwnerID()
      end
    end
  end
  return -1
end

function CDOTA_BaseNPC_Hero:CalculateRespawnTime()
	if self.OnDuel then return 1 end
	local time = (5 + 3.8*self:GetLevel()) + (self.RespawnTimeModifierBloodstone or 0) + (self.RespawnTimeModifierSaiReleaseOfForge or 0)
	return math.max(time, 3)
end
 
function CDOTA_BaseNPC:SetRespawnTime()
local respawn = self:CalculateRespawnTime()
	if respawn > 25 then respawn = 25 end
	self:SetTimeUntilRespawn( math.max(respawn,1) )
end

function PickRandomShuffle( reference_list, bucket )
    if ( #reference_list == 0 ) then
        return nil
    end
    
    if ( #bucket == 0 ) then
        for k, v in pairs(reference_list) do
            bucket[k] = v
        end
    end
    local pick_index = RandomInt( 1, #bucket )
    local result = bucket[ pick_index ]
    table.remove( bucket, pick_index )
    return result
end

function PickRandomValueTable(table)
	 return table[RandomInt( 1, #table )]
end 

function CDOTA_BaseNPC:GetMoveCapability() 
	return 	self:HasFlyMovementCapability() and DOTA_UNIT_CAP_MOVE_FLY or 
		self:HasGroundMovementCapability() and DOTA_UNIT_CAP_MOVE_GROUND or DOTA_UNIT_CAP_MOVE_NONE 
end

function CDOTA_BaseNPC:GetVectorBehind()
	local victim_angle = self:GetAnglesAsVector()
	local victim_angle_rad = victim_angle.y * math.pi/180
	local victim_position = self:GetAbsOrigin()
	local new_position = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)
	return new_position
end

function CDOTA_BaseNPC:Healing(healing,vampire,offparticle,caster)
	vampire = vampire == nil and self:IsVampire() or vampire
	if vampire then 
		self:SetHealth(self:GetHealth() + healing)
	else
		self:Heal(healing,caster or self)
	end
	if not offparticle then
		local player = PlayerResource:GetPlayer(UnitVarToPlayerID(self))
		SendOverheadEventMessage(player, OVERHEAD_ALERT_HEAL, player, math.floor(healing), player)
		local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
		ParticleManager:SetParticleControl(lifesteal_pfx, 0, self:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
	end
end

function CDOTA_BaseNPC:DropItem(itemName,Origin)
if not itemName then return end
   	local newItem = CreateItem(itemName, nil, nil)
	local v = Origin or (self:GetOrigin() + RandomVector(RandomFloat(0,250)))
	local drop = CreateItemOnPositionForLaunch( v, newItem )
	newItem:LaunchLootInitialHeight( false, 0, 500, 0.75, v) 
   	Timers:CreateTimer({
          endTime = 60,
          callback = function()
			if newItem and IsValidEntity(newItem) and not newItem:GetOwnerEntity() then 
				UTIL_Remove(newItem)
				UTIL_Remove(drop)
			end
			return nil
     end})
   	return newItem,drop
end

function CDOTA_BaseNPC:GetCountItem()
local k = 0
	for i=0, 5 do
		if self:GetItemInSlot(i) then
			k = k + 1
		end 
	end
	return k
end

function CDOTABaseAbility:FireLinearProjectile(FX, velocity, distance, width, data, bDelete, bVision, vision)
	local internalData = data or {}
	local delete = false
	if bDelete then delete = bDelete end
	local provideVision = true
	if bVision then provideVision = bVision end
	local info = {
		EffectName = FX,
		Ability = self,
		vSpawnOrigin = internalData.origin or self:GetCaster():GetAbsOrigin(), 
		fStartRadius = width,
		fEndRadius = internalData.width_end or width,
		vVelocity = velocity,
		fDistance = distance or 1000,
		Source = internalData.source or self:GetCaster(),
		iUnitTargetTeam = internalData.team or DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = internalData.type or DOTA_UNIT_TARGET_ALL,
		iUnitTargetFlags = internalData.type or DOTA_UNIT_TARGET_FLAG_NONE,
		bDeleteOnHit = delete,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bProvidesVision = provideVision,
		iVisionRadius = vision or 100,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		ExtraData = internalData.extraData
	}

	return ProjectileManager:CreateLinearProjectile( info )
end

function ParticleManager:FireParticle(effect, attach, owner, cps)
	local FX = ParticleManager:CreateParticle(effect, attach, owner)
	if cps then
		for cp, value in pairs(cps) do
			if type(value) == "userdata" then
				ParticleManager:SetParticleControl(FX, tonumber(cp), value)
			elseif type(value) == "table" then
				ParticleManager:SetParticleControlEnt(FX, cp, value.owner or owner, value.attach or attach, value.point or "attach_hitloc", (value.owner or owner):GetAbsOrigin(), true)
			else
				ParticleManager:SetParticleControlEnt(FX, cp, owner, attach, value, owner:GetAbsOrigin(), true)
			end
		end
	end
	ParticleManager:ReleaseParticleIndex(FX)
end

function CDOTA_BaseNPC:Teleport(position)
	self.TeleportPosition = position
	self:Stop()

	local playerId = self:GetPlayerOwnerID()
	PlayerResource:SetCameraTarget(playerId, self)

	FindClearSpaceForUnit(self, position, true)

	Timers:CreateTimer(0.1, function()
		if not IsValidEntity(self) or self.TeleportPosition ~= position then return end
		if (self:GetAbsOrigin() - position):Length2D() > 256 then
			FindClearSpaceForUnit(self, position, true)
			return 0.1
		end

		self.TeleportPosition = nil
		PlayerResource:SetCameraTarget(playerId, nil)
		self:Stop()
	end)
end

function CDOTA_Buff:SetSharedKey(key, value)
	local t = CustomNetTables:GetTableValue("modifiers_value", self:GetParent():GetEntityIndex() .. "_" .. self:GetName()) or {}
	t[key] = value
	CustomNetTables:SetTableValue("modifiers_value", self:GetParent():GetEntityIndex() .. "_" .. self:GetName(), t)
end

function CDOTA_Buff:GetSharedKey(key)
	local t = CustomNetTables:GetTableValue("modifiers_value", self:GetParent():GetEntityIndex() .. "_" .. self:GetName()) or {} 
	return t[key]
end

--[[
	ability
	modifier
	duration
	count
	updateStack
]]
function CDOTA_BaseNPC:AddStackModifier(data)
	if self:HasModifier(data.modifier) then
		local current_stack = self:GetModifierStackCount( data.modifier, data.ability )
		if data.updateStack then
			self:AddNewModifier(self, data.ability,data.modifier,{duration = (data.duration or -1)})
		end
		self:SetModifierStackCount( data.modifier, data.ability, current_stack + (data.count or 1) )
	else
		self:AddNewModifier(self, data.ability,data.modifier,{duration = (data.duration or -1)})
		self:SetModifierStackCount( data.modifier, data.ability, (data.count or 1) )
	end
end

function CDOTABaseAbility:NewCooldown(cooldown)
	if not self then return end
	self:EndCooldown()
	return self:StartCooldown(cooldown or self:GetCooldown())
end 

function CDOTA_BaseNPC:SwapAbility(ability1,ability2,LevelUp)
	local ability1 = self:AddAbility(ability1)
	local ability2 = self:FindAbilityByName(ability2)
	if not ability2 then print('[SwapAbility] Critical error, Ability:'.. ability2 ..' not found') return end
	if LevelUp then
		local level = type(LevelUp) == "boolean" and ability1:GetLevel() or LevelUp
		ability1:SetLevel(level)
	end 
	self:SwapAbilities(ability1:GetAbilityName(),ability2:GetAbilityName(),true,true)
	RemoveAbilityWithModifiers(self, ability2)
	self:RemoveAbility(ability2:GetAbilityName())
end 

function CDOTA_Item:UpdateCharge(amount,bonus)
	local newCharges = self:GetCurrentCharges() + (bonus and (amount or 1) or ( - (amount or 1)))
	if newCharges <= 0 and not bonus then
		UTIL_Remove(self)
	else
		self:SetCurrentCharges(newCharges)
	end
end
function CDOTA_BaseNPC:CreateParticleOfAction(data)
	self:AddNewModifier(self,nil,'modifier_debuff_fire',{duration = 5})
	if data.shockwave then
		local fx = ParticleManager:CreateParticle("particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
		ParticleManager:SetParticleControl(fx, 0, data.point or self:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, Vector(data.radius or 100,0,0))
		ParticleManager:SetParticleControl(fx, 2, Vector(2,0,15))
		ParticleManager:SetParticleControl(fx, 3, Vector(230,22,22))
		ParticleManager:SetParticleControl(fx, 4, Vector(208,70,70))
		ParticleManager:ReleaseParticleIndex(fx)
		return fx
	end
	-- Particle by Boss Hunter
	local fx = ParticleManager:CreateParticle("particles/generic_radius_warning.vpcf", PATTACH_WORLDORIGIN, self)
	ParticleManager:SetParticleControl(fx, 0, data.point or self:GetAbsOrigin() )
	ParticleManager:SetParticleControl(fx, 1, Vector(data.radius or 100,200,0))
	ParticleManager:ReleaseParticleIndex(fx)
	return fx
end

function CDOTA_BaseNPC:CreateParticleRage()
	local fx = ParticleManager:CreateParticle("particles/econ/generic/generic_buff_1/generic_buff_1.vpcf", PATTACH_POINT_FOLLOW, self )
	ParticleManager:SetParticleControl(fx, 14, Vector(1,1,1))
	ParticleManager:SetParticleControl(fx, 15, Vector(255,232,130))
	ParticleManager:ReleaseParticleIndex(fx)
	return fx
end