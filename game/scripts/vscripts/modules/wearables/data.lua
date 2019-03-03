DEFAULT_WEARABLES = {
	['npc_dota_hero_night_stalker'] = {337,338,339},
	['npc_dota_hero_sniper'] = {281,282,283,284,285},
	['npc_dota_hero_dragon_knight'] = {63,64,65,66,67,68},
	['npc_dota_hero_life_stealer'] = {},
	['npc_dota_hero_omniknight'] = {42,43,44,45,46},
}
-- "arms"
-- "head"
-- "back"
-- "shoulder"
-- "misc"
-- "mount"
-- "neck"
-- "armor"
-- "legs"
-- "belt"
-- "gloves"
Pattachs = {
	['INVALID']	= PATTACH_INVALID,
	['ABSORIGIN'] =	PATTACH_ABSORIGIN,
	['ABSORIGIN_FOLLOW'] = PATTACH_ABSORIGIN_FOLLOW,	
	['CUSTOMORIGIN'] = PATTACH_CUSTOMORIGIN,	
	['CUSTOMORIGIN_FOLLOW'] = PATTACH_CUSTOMORIGIN_FOLLOW,	
	['POINT'] = PATTACH_POINT,	
	['POINT_FOLLOW'] = PATTACH_POINT_FOLLOW,	
	['EYES_FOLLOW'] = PATTACH_EYES_FOLLOW,
	['OVERHEAD_FOLLOW'] = PATTACH_OVERHEAD_FOLLOW,	
	['WORLDORIGIN'] = PATTACH_WORLDORIGIN,
	['ROOTBONE_FOLLOW'] = PATTACH_ROOTBONE_FOLLOW,	
	['RENDERORIGIN_FOLLOW'] = PATTACH_RENDERORIGIN_FOLLOW,	
	['MAIN_VIEW'] = PATTACH_MAIN_VIEW,	
	['WATERWAKE'] = PATTACH_WATERWAKE,	
	['MAX_PATTACH_TYPES'] = MAX_PATTACH_TYPES,
}

ITEMS_GAME['items']['9215'].visuals.asset_modifier = {
	type = "particle_create",
	customModifier = {
		"particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_ambient_outline_l.vpcf",
		"particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_ambient_outline_r.vpcf",
	},
	style = 1,
}
ITEMS_GAME['items']['9199'].visuals.asset_modifier = {
	type = "particle_create",
	customModifier = {
		"particles/econ/items/lifestealer/lifestealer_immortal_backbone/lifestealer_immortal_backbone_ambient_outline_l.vpcf",
		"particles/econ/items/lifestealer/lifestealer_immortal_backbone/lifestealer_immortal_backbone_ambient_outline_r.vpcf",
	},
	style =	1,
}
ITEMS_GAME['items']['9455'].visuals.asset_modifier = {
	type = 			"particle_create",
	modifier = 		"particles/econ/items/sniper/sniper_immortal_cape_golden/sniper_immortal_cape_golden_ambient.vpcf",
	style = 		1,
}
ITEMS_GAME['items']['9197'].visuals.asset_modifier = {
	type = 		"particle_create",
	modifier = 		"particles/econ/items/sniper/sniper_immortal_cape/sniper_immortal_cape_ambient.vpcf",
	style = 		1,
} 

WEARABLES_SETTING = {
	Sets = {	-- Sets prop Synchronous 
		[21055] = true, 
		[21230] = true,
		[20499] = true,
	},
}

ITEMS_GAME['items']['20066']['bundle']["Omniknight's Cape"] = 1
ITEMS_GAME['items']['20066']['bundle']["Omniknight's Head"] = 1
ITEMS_GAME['items']['20066']['bundle']["Omniknight's Hair"] = 1
ITEMS_GAME['items']['20643']['bundle']["Omniknight's Head"] = 1 
ITEMS_GAME['items']['21064']['bundle']["Omniknight's Head"] = 1 
ITEMS_GAME['items']['20646']['bundle']["Omniknight's Head"] = 1 
ITEMS_GAME['items']['20787']['bundle']["Omniknight's Head"] = 1
ITEMS_GAME['items']['21152']['bundle']["Omniknight's Head"] = 1
ITEMS_GAME['items']['20046']['bundle']["Omniknight's Head"] = 1 