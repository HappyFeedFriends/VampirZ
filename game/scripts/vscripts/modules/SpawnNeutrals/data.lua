NEUTRALS_SPAWN_SETTINGS = {
	CreepPerSpawn = 6,
	SpawnChanceMiniBoss = 35,
	WavesDelay = 4 * 60,
	Limits = {
		CreepMapLimit = 100,
		MiniBossLimit = 4,
		CountActiveSpawns = 3,
	},
}
if SPAWN_UNIT == nil then
	SPAWN_UNIT = true
end
NEUTRALS_SPAWN_UNITS = {
	["npc_VampirZ_zombie"] = {
		StatsPerSpawn = {
			health = 78,
			armor = 0.1,
			damage = 16,
			AttackSpeed = 25,
			MoveSpeed = 25,
			xp = 5,
			gold = 4,
			healthRegen = 0
		},
		Models ={
		 [1] = "models/heroes/undying/undying_minion_torso.vmdl",
		 [5] = "models/heroes/undying/undying_minion.vmdl",
		 [8] = "models/items/undying/idol_of_ruination/ruin_wight_minion_gold.vmdl",
		 [12] = "models/items/undying/idol_of_ruination/ruin_wight_minion.vmdl",
		},
		MiniBoss = {
			ModelScale = 1.5,
			MultiplyStats = 1.7,
			Models = {
				"models/items/undying/flesh_golem/davy_jones_set_davy_jones_set_kraken/davy_jones_set_davy_jones_set_kraken.vmdl",
				"models/items/undying/flesh_golem/corrupted_scourge_corpse_hive/corrupted_scourge_corpse_hive.vmdl",
				"models/items/undying/flesh_golem/ti8_undying_miner_flesh_golem/ti8_undying_miner_flesh_golem.vmdl",
				"models/items/undying/flesh_golem/deathmatch_dominator_golem/deathmatch_dominator_golem.vmdl",
			},
			Ability = {
				"Zombie_low",
				"Zombie_attack_speed",
			},
		},
	},
	["npc_VampirZ_skeleton"] = {
		StatsPerSpawn = {
			health = 78,
			armor = 0.5,
			damage = 26,
			AttackSpeed = 40,
			MoveSpeed = 25,
			xp = 6,
			gold = 10,
			healthRegen = 2.0
		},
		Models ={
			[1]  = "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl",
		},
		MiniBoss = {
			ModelScale = 2.9,
			MultiplyStats = 3.7,
			Models = {
				"models/items/wraith_king/wk_ti8_creep/wk_ti8_creep.vmdl",
				"models/items/wraith_king/wk_ti8_creep/wk_ti8_creep_crimson.vmdl",
				"models/creeps/lane_creeps/creep_dire_hulk/creep_dire_diretide_ancient_hulk.vmdl",
			},
			Ability = {
				"Skeleton_attack_speed",
				"Skeleton_slow",
			},
		},
	},		
	["npc_VampirZ_angry_spirit"] = {
		StatsPerSpawn = {
			health = 90,
			armor = 1.0,
			damage = 30,
			AttackSpeed = 32,
			MoveSpeed = 320,
			xp = 4,
			gold = 10,
			healthRegen = 0,
		},
		Models = {
			[1] = "models/creeps/neutral_creeps/n_creep_ghost_b/n_creep_ghost_frost.vmdl",
			[5] = "models/creeps/neutral_creeps/n_creep_ghost_b/n_creep_ghost_b.vmdl",
		},
		MiniBoss = {
			ModelScale = 2,
			MultiplyStats = 2.7,
			Models = {
				"models/creeps/neutral_creeps/n_creep_ghost_b/n_creep_ghost_red.vmdl",
				"models/creeps/neutral_creeps/n_creep_ghost_a/n_creep_ghost_a.vmdl",
				"models/items/invoker/forge_spirit/nightlord_crypt_sentinel/nightlord_crypt_sentinel.vmdl",
			},
			Ability = {
				"angry_spirit_miniboss2",
				"angry_spirit_miniboss1",
			},
		},
	},
}

--[[NEUTRALS_SPAWN_BOSSES = {
	["npc_VampirZ_Boss_Zombie"] = {
		Ability = {
			"boss_respawn_creep",
			"boss_health_damage",
		},
		RandomModels  ={
			"models/heroes/undying/undying_flesh_golem.vmdl",
			"models/items/undying/flesh_golem/davy_jones_set_davy_jones_set_kraken/davy_jones_set_davy_jones_set_kraken.vmdl",
			"models/items/undying/flesh_golem/ti8_undying_miner_flesh_golem/ti8_undying_miner_flesh_golem.vmdl",
			"models/items/undying/flesh_golem/deathmatch_dominator_golem/deathmatch_dominator_golem.vmdl",
			"models/items/undying/flesh_golem/corrupted_scourge_corpse_hive/corrupted_scourge_corpse_hive.vmdl",
		},
	},		
	["npc_VampirZ_Boss_Skeleton"] = {
		OriginalModel = "models/heroes/wraith_king/wraith_king.vmdl",
		Ability = {
			"boss_respawn_creep",
			"boss_health_damage",
		},
		RandomModels  ={
			[1] = {
				"models/items/wraith_king/ti8_wk_stonebeast_armor_armor/ti8_wk_stonebeast_armor_armor.vmdl",
				"models/items/wraith_king/ti8_wk_stonebeast_armor_arms/ti8_wk_stonebeast_armor_arms.vmdl",
				"models/items/wraith_king/ti8_wk_stonebeast_armor_back/ti8_wk_stonebeast_armor_back.vmdl",
				"models/items/wraith_king/ti8_wk_stonebeast_armor_shoulder/ti8_wk_stonebeast_armor_shoulder.vmdl",
				"models/items/wraith_king/ti8_wk_stonebeast_armor_weapon/ti8_wk_stonebeast_armor_weapon.vmdl",
			},								
			[2] = {
				"models/items/wraith_king/kings_spite_head/kings_spite_head.vmdl",
				"models/items/wraith_king/kings_spite_back/kings_spite_back.vmdl",
				"models/items/wraith_king/kings_spite_arms/kings_spite_arms.vmdl",
				"models/items/wraith_king/kings_spite_armor/kings_spite_armor.vmdl",
				"models/items/wraith_king/kings_spite_weapon/kings_spite_weapon.vmdl",
				"models/items/wraith_king/kings_spite_shoulder/kings_spite_shoulder.vmdl",
			},				
			[3] = {
				"models/items/wraith_king/the_scourge_of_winter_weapon/the_scourge_of_winter_weapon.vmdl",
				"models/items/wraith_king/the_scourge_of_winter_shoulder/the_scourge_of_winter_shoulder.vmdl",
				"models/items/wraith_king/the_scourge_of_winter_head/the_scourge_of_winter_head.vmdl",
				"models/items/wraith_king/the_scourge_of_winter_back/the_scourge_of_winter_back.vmdl",
				"models/items/wraith_king/the_scourge_of_winter_arms/the_scourge_of_winter_arms.vmdl",
				"models/items/wraith_king/the_scourge_of_winter_armor/the_scourge_of_winter_armor.vmdl",
			},
		},
	},	
	["npc_VampirZ_Boss_angry_spirit"] = {
		OriginalModel = "models/heroes/death_prophet/death_prophet.vmdl",
		Ability = {
			"boss_respawn_creep",
			"boss_health_damage",
		},
		RandomModels  ={
			[1] = {
				"models/items/death_prophet/awakened_thirst_head/awakened_thirst_head.vmdl",
				"models/items/death_prophet/awakened_thirst_legs/awakened_thirst_legs.vmdl",
				"models/items/death_prophet/awakened_thirst_armor/awakened_thirst_armor.vmdl",
				"models/items/death_prophet/awakened_thirst_belt/awakened_thirst_belt.vmdl",
				"models/items/death_prophet/awakened_thirst_misc/awakened_thirst_misc.vmdl",
				"models/items/death_prophet/awakened_thirst_misc_alt/awakened_thirst_misc_alt.vmdl",
			},								
			[2] = {
				"models/items/death_prophet/mothbinders_omen_head/mothbinders_omen_head.vmdl",
				"models/items/death_prophet/mothbinders_omen_legs/mothbinders_omen_legs.vmdl",
				"models/items/death_prophet/mothbinders_omen_legs/mothbinders_omen_legs_vortex.vmdl",
				"models/items/death_prophet/mothbinders_omen_misc/mothbinders_omen_misc.vmdl",
				"models/items/death_prophet/mothbinders_omen_belt/mothbinders_omen_belt.vmdl",
				"models/items/death_prophet/mothbinders_omen_armor/mothbinders_omen_armor.vmdl",
			},				
			[3] = {
				"models/items/death_prophet/mermaids_queen_head/mermaids_queen_head.vmdl",
				"models/items/death_prophet/mermaids_queen_armor/mermaids_queen_armor.vmdl",
				"models/items/death_prophet/mermaids_queen_belt/mermaids_queen_belt.vmdl",
				"models/items/death_prophet/mermaids_queen_legs/mermaids_queen_legs.vmdl",
			},
		},
	},
}]]