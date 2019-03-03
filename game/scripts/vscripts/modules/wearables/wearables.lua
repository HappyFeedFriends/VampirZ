if not wearables then
	wearables = class({})
	wearables.WearablesSets = {}
end

ModuleRequire(...,"data")

function wearables:FirstSpawnHero( hero )
	self:SetDefaultWearables(hero)
end

function wearables:SetDefaultWearables( hero )
	RemoveWearables( hero )
	for k,v in pairs(DEFAULT_WEARABLES[hero:GetUnitName()] or {}) do
		--SpawnEntityFromTableSynchronous("prop_dynamic", {model = v}):FollowEntity(hero, true)
		wearables:SetWearables( hero,v )
	end
end

function wearables:OnDressingItem(data)
	local pID = data.PlayerID
	local itemDef = data.itemDef
	local itemCost = data.itemCost
	local style = data.style
	local styles = data.styles
	local IsRandom = data.IsRandom == 1
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	request:GetDataServer(function(data)
		local IsBuy = data.IsBuy
		local IsOldBuy = data.IsOldBuy
		local coin = data.NewCoin
		local itemList = data.itemList
		data['IsRandomBuyError'] = IsOldBuy and IsRandom
		if IsBuy  then
			wearables:SetWearables( hero,itemDef,nil,true )
			local t = CustomNetTables:GetTableValue('request',tostring(pID)) or {}
			t['ItemList'] = itemList or t['ItemList']
			t['Coin'] = coin or t['Coin']
			CustomNetTables:SetTableValue("request", tostring(pID), t)
		end
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pID),"WearableUpdate", data) 
	end ,pID,GET_TYPE_BUY_WEARABLES,nil,{
		itemCost = itemCost,
		itemDef = itemDef,
		styles = styles,
		IsRandom = IsRandom,
	})
end

function wearables:OnEquipItemWearable( data )
	local pID = data.PlayerID
	local itemDef = data.itemDef
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	wearables:SetWearables( hero,itemDef,data.style,true )
end

function wearables:SetWearables( hero,itemDef,style,IsRemoveWearable )
	local itemDefs,Particles,pattach,useableHeroes,isSet = wearables:GetModelsByItemDef( itemDef,style )
	local heroName = hero:GetUnitName()
	if IsRemoveWearable and useableHeroes[heroName] then
		RemoveWearables( hero )
	end
	wearables.WearablesSets[hero:GetPlayerID()] = wearables.WearablesSets[hero:GetPlayerID()] or {}
	if useableHeroes and useableHeroes[heroName] then
		for k,v in pairs(hero.particle or {}) do
			ParticleManager:DestroyParticle(v,true)
		end 
		hero.particle = {} 
		for k,v in pairs(itemDefs) do
			--local k = wearables:GetItemDefByName( v,wearables.WearablesSets[hero:GetPlayerID()] )
			local prop = SpawnEntityFromTableSynchronous("prop_dynamic", {model = v})
			prop:FollowEntity(hero, true)
			for key,value in pairs(((Particles or {})[k] or {})) do
				if type(value) == "string"  then
					local pattachPoint = pattach[k] and pattach[k]['attach_type'] and Pattachs[pattach[k]['attach_type']:upper()] or PATTACH_ABSORIGIN_FOLLOW
					local target = pattach[k] and pattach[k]['attach_entity'] == "parent" and  hero or prop
					target = WEARABLES_SETTING.Sets[tonumber(itemDef)] and prop or target
					local particle = ParticleManager:CreateParticle(value, pattachPoint, target)
					if pattach[k] and pattach[k].control_points then
						for point,attach in pairs(pattach[k].control_points) do
							ParticleManager:SetParticleControlEnt(particle, attach.control_point_index, target, Pattachs[attach['attach_type']:upper()], attach.attachment, target:GetAbsOrigin(), true)
						end 
					end 
					table.insert(hero.particle,particle)
				end
			end
		end
	end
end

function wearables:GetItemDefByName( name,table )
	for k,v in pairs(table) do
		if v == name then
			return k
		end
	end
end

function wearables:GetModelsByItemDef( ItemDef,style )
	local kvFile = ITEMS_GAME['items']
	local SearchItems = ITEMS_GAME['items'][tostring(ItemDef)]['bundle']
	local tableDef = {}
	--local itemSlots = {}
	local tableParticle = {} 
	local particleCreateQueue = {}
	local useableHeroes = ITEMS_GAME['items'][tostring(ItemDef)].used_by_heroes
	if  SearchItems == nil then 
		local item = ITEMS_GAME['items'][tostring(ItemDef)]
		if item then
			ItemDef = tostring(ItemDef)
			tableDef[ItemDef] = item.model_player
			--itemSlots[ItemDef] = item.item_slot or item.item_type_name
			--self.WearablesSets[]
			for names, visual in pairs(item.visuals or {}) do
				if string.find(names, "asset_modifier") and (style == nil or visual.style == style) then
					local t = visual.type
					if type(visual.modifier) ~= "table" and visual.modifier ~= "arcana_type"  then
						tableParticle[ItemDef] = type(tableParticle[ItemDef]) ~= 'table' and {} or tableParticle[ItemDef]
						if visual.modifier then
							table.insert(tableParticle[ItemDef],visual.modifier)
						else
							for k,v in pairs(visual.customModifier or {}) do
								table.insert(tableParticle[ItemDef],v)
							end
						end
						if t == "particle_create" then
							for _, system in pairs(ITEMS_GAME.attribute_controlled_attached_particles) do
								if system.system == visual.modifier then
									particleCreateQueue[ItemDef] = system
								end
							end
						end
					end
				end
			end
		end
		return tableDef,tableParticle,particleCreateQueue,useableHeroes,false--itemSlots
	end
		style = style and style > 1 and style or nil
		for k,v in pairs(SearchItems) do
			local up = k:upper()
			if up:find('LOADING') then
				SearchItems[k] = nil
			end
		end 
		for k,v in pairs(kvFile) do
		local name = v.name
		if name and SearchItems[name]  then
			tableDef[k] = v.model_player
			--itemSlots[k] = v.item_slot or v.item_type_name
			if v.visuals then
				for names, visual in pairs(v.visuals) do
					if string.find(names, "asset_modifier") and (style == nil or visual.style == style) then
		              	local t = visual.type
						tableParticle[k] = type(tableParticle[k]) ~= 'table' and {} or tableParticle[k]
						table.insert(tableParticle[k],visual.modifier)
						if t == "particle_create" then
							for _, system in pairs(ITEMS_GAME.attribute_controlled_attached_particles) do
								if system.system == visual.modifier then
									particleCreateQueue[k] = system
		                       	end
	                        end
	                    end
	                end
	           	end
			end
		end 
	end
	return tableDef,tableParticle,particleCreateQueue,useableHeroes,true--itemSlots
end
