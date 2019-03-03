if not CustomShop then
	CustomShop = class({})
end

function CustomShop:PreLoad()
	CustomShop.AllCost = GetTableAllCost()
	CustomNetTables:SetTableValue ("Shops", "Vampire", CUSTOM_SHOP["vampire"])
	CustomNetTables:SetTableValue ("Shops", "Mans", CUSTOM_SHOP["man"])
	CustomNetTables:SetTableValue ("Shops", "ItemCost", CustomShop.AllCost)
end 
function CustomShop:GetItemRecipe(item)
	local recipe = "item_recipe_" .. item:gsub("item_","")
	local kv = GetItemKV(recipe)
	if not kv then return false end
	return {
		Result = kv.ItemResult or -1,
		Recipe = kv.ItemRequirements,
		Cost = kv.ItemCost or 0,
	}
end 

function CustomShop:BuyItem(data)
	local item = data.ItemName
	local pID = data.PlayerId
	if not (item or pID) or pID < 0 then return end
	if item == "item_colt" and CustomShop.coltBuy then Containers:DisplayError(pID, "#hud_error_colt_is_buy") return end
	local hero = PlayerResource:GetSelectedHeroEntity( pID )
	local gold = Vampires:IsVampire(pID) and Vampires:GetBlood(pID) or Gold:GetGold(pID)
	if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		Containers:DisplayError(pID, "#hud_error_state_game_low")
		return
	end 
	if gold < CustomShop.AllCost[item] then 
		if Vampires:IsVampire(pID) then
			Containers:DisplayError(pID, "#hud_error_not_enought_blood") 
		else
			Containers:DisplayError(pID, "#hud_error_not_enought_gold") 
		end
		return 
	end
	if hero:GetCountItem() >= 6 then Containers:DisplayError(pID, "#hud_error_inventory_full") return end
	if Vampires:IsVampire(pID) then 
		Vampires:ModifyBlood(pID,-CustomShop.AllCost[item])
	else
		Gold:ModifyGold(pID,-CustomShop.AllCost[item])
	end
	EmitSoundOn("General.Buy",PlayerResource:GetPlayer(pID))
	if item == "item_colt" then CustomShop.coltBuy = true end
	hero:AddItemByName(item)
end 