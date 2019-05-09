LinkLuaModifier ("modifier_VampireBetaSupport1", "ability/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireBetaSupport1_effect", "ability/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireBetaSupport2", "ability/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireBetaSupport2_effect", "ability/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireBetaSupport3", "ability/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireBetaSupport3_effect", "ability/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireBetaDefense1", "ability/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_VampireBetaDefense2", "ability/modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_vampires_blood_loss", "ability/humansModifier.lua", LUA_MODIFIER_MOTION_NONE )	
LinkLuaModifier( "modifier_wild_hunt_aura", "ability/humansModifier.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wild_hunt", "ability/humansModifier.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gunner_bonus_vision_ms", "ability/humansModifier.lua", LUA_MODIFIER_MOTION_NONE )
require("ability/modifiers")

SETTING_DATA_UPGRADES = {
	Vampires = {
		["Alpha"] = {
			[2] = {
				["SpecialUpgrade_1"] = { -- Апгрейд
					Value = 2,
					Image = "Vampire_Claws",
				},
				["SpecialUpgrade_2"] = { -- Апгрейд
					Value = 230,
					Radius = 450,
					DurationStun = 1.1,
					Image = "VampireShield",
				},
				["SpecialUpgrade_3"] = { 
					GetAddAbility = "VampireShadowMist",
					Value = 25,
				},
				["SpecialUpgrade_4"] = {
					GetAddAbility = "VampireDevourer",
					Value = 250,
				},
				["SpecialUpgrade_5"] = {
					GetAddAbility = "VampireShadow_Veil",
				},
				["SpecialUpgrade_6"] = {
					GetAddAbility = "Vampir_BloodCauldron",
					SuperNaturalCostHeal = 0,
					Value = 30,
				},
				["SpecialUpgrade_7"] = {
					GetAddAbility = "VampireFlair",
					Value = 35,
					Duration = 15,
					ModelScale = 1.6,
				},
				["SpecialUpgrade_8"] = {
					Image = "VampireDevourer",
					Value = 5,
				},
			},		 	
		},
		["Beta"] = {
			[1] = { -- Support
				["SpecialUpgrade_1"] = {
					Image = "HeroIcon",
					GetAddModifier = "modifier_VampireBetaSupport1",
					dataModifier = {
						duration = -1,
						value = 55,
						radius = 700,
					},
				},
				["SpecialUpgrade_2"] = {
					Image = "HeroIcon",
					GetAddModifier = "modifier_VampireBetaSupport2",
					dataModifier = {
						duration = -1,
						value = 25,
						radius = 1200,
					},
				},
				["SpecialUpgrade_3"] = {
					Image = "VampireDevourer",
					Value = 25,
				},
				["SpecialUpgrade_4"] = {
					GetAddAbility = "VampireAutophagy",
				},
				["SpecialUpgrade_5"] = {
					GetAddAbility = "VampireCallOfAlpha",
				},
				["SpecialUpgrade_6"] = {
					Image = "HeroIcon",
					GetAddModifier = "modifier_VampireBetaSupport3",
					Value = 20,
					radius = 500,
				},
				["SpecialUpgrade_7"] = {
					Image = "VampireAutophagy",
					Duration = 2.3,
					Cooldown = 65,
				},
				["SpecialUpgrade_8"] = {
					GetAddAbility = "VampireSearchHumans",
					DurationStun = 0.7,
					Duration = 3,
				},
			},			
			[2] = { -- Attacking
				["SpecialUpgrade_1"] = {
					GetAddAbility = "VampireStigma",
				},
				["SpecialUpgrade_2"] = {
					GetAddAbility = "VampireAttack",
				},
				["SpecialUpgrade_3"] = {
					Image = "VampireStigma",
					Value = 90,
				},
				["SpecialUpgrade_4"] = {
					Image = "VampireAttack",
					ActiveCritical = 450,
					NumberAttack = 2,
				},
				["SpecialUpgrade_5"] = {
					Image = "VampireStigma",
					Value = 700,
				},
				["SpecialUpgrade_6"] = {
					Swap = true,
					GetAddAbility = "VampireDarkScar",
				},
				["SpecialUpgrade_7"] = {
					Swap = true,
					GetAddAbility = "VampireDevourment",
				},
				["SpecialUpgrade_8"] = {
					Image = "VampireAttack",
					Value =  0.55,
				},
			},			
			[3] = { -- Defense
				["SpecialUpgrade_1"] = {
					Value = 15,
					GetAddModifier = "modifier_VampireBetaDefense1",
					Image = "HeroIcon",
				},
				["SpecialUpgrade_2"] = {
					Value = 750,
					MoveSpeed = -10,
					GetAddModifier = "modifier_VampireBetaDefense2",
					Image = "HeroIcon",
				},
				["SpecialUpgrade_3"] = {
					GetAddAbility = "VampireBloodPulse",
				},
				["SpecialUpgrade_4"] = {
					GetAddAbility = "VampireMirrorEdge",
				},
				["SpecialUpgrade_5"] = {
					Value = 0.4,
					ValueMS = 30,
					Image = "VampireShield",
				},
				["SpecialUpgrade_6"] = {
					Value = 7,
					Image = "VampireBloodPulse",
				},
				["SpecialUpgrade_7"] = {
					Value = 2,
					RemoveSec = 5,
					Image = "VampireShield",
				},
				["SpecialUpgrade_8"] = {
					Image = "VampireMirrorEdge",
				},
			},
		},
	},
	Mans = {
        ['Priest'] = {
            [1] = {            
                ["SpecialUpgrade_1"] = {
                    Image = "Healer_call_to_angels",
                    Value = 60,
                },  
                ["SpecialUpgrade_2"] = {
                    Image = "Healer_vow_to_God",
                },
                ["SpecialUpgrade_3"] = {
                    Image = "Healer_divine_touch",
                    Resist = 25,
                },  
                ["SpecialUpgrade_4"] = {
                    Image = "HeroIcon",
                    GetAddModifier = "modifier_healer_cast_range_bonus",
                    Range = 350,
                },
                ["SpecialUpgrade_5"] = {
                    Image = "Healer_divine_touch",
                    Ms = 150,
                },
                ["SpecialUpgrade_6"] = {
                    Image = "Healer_divine_touch",
                    Sr = 25,
                },
                ["SpecialUpgrade_7"] = {
                    Image = "Healer_vow_to_God",
                    In = 2,
                },
                ["SpecialUpgrade_8"] = {
                    Image = "Healer_inquisition",
                },
            },         
            [2] = {            
                ["SpecialUpgrade_1"] = {
                    Image = "HeroIcon",
                    SwapTable = {
	                   	Healer_call_to_angels = "Healer_call_to_hell",
	                    Healer_divine_touch = "Healer_pentagram",
	                    Healer_vow_to_God = "Healer_pact_with_the_devil",
	                    Healer_inquisition = "Healer_opening_the_seal",
                	},
                },  
                ["SpecialUpgrade_2"] = {
                    Image = "Healer_pact_with_the_devil",
                },
                ["SpecialUpgrade_3"] = {
                    Image = "Healer_opening_the_seal",
                    Bonus = 25,
                },  
                ["SpecialUpgrade_4"] = {
                    Image = "Healer_pentagram",
                    dBonus = 2,
                },
                ["SpecialUpgrade_5"] = {
                    Image = "Healer_opening_the_seal",
                    Bonus = 20,
                },
                ["SpecialUpgrade_6"] = {
                    Image = "Healer_opening_the_seal",
                    Bonus = 25,
                },
                ["SpecialUpgrade_7"] = {
                    Image = "Healer_pentagram",
                    As = 150,
                },
                ["SpecialUpgrade_8"] = {
                    Image = "Healer_pentagram",
                    Phys = 30,
                    Mag = 30,
                },
            },         
            [3] = {            
                ["SpecialUpgrade_1"] = {
                    Image = "HeroIcon",
                    SwapTable = {
	                    Healer_call_to_angels = "Healer_surge_of_strength",
	                    Healer_divine_touch = "Healer_victim",
	                    Healer_vow_to_God = "Healer_holiness",
	                    Healer_inquisition = "Healer_blood_ties",
                	}
                },  
                ["SpecialUpgrade_2"] = {
                    Image = "Healer_holiness",
                },
                ["SpecialUpgrade_3"] = {
                    Image = "Healer_victim",
                    Phys = 25,
                    Mag = 25,
                },  
                ["SpecialUpgrade_4"] = {
                    Image = "Healer_blood_ties",
                    Value = 20,
                },
                ["SpecialUpgrade_5"] = {
                    Image = "Healer_victim",
                    Bonus = 30,
                },  
                ["SpecialUpgrade_6"] = {
                    Image = "Healer_victim",
                    Value = 2,
                },
                ["SpecialUpgrade_7"] = {
                    Image = "Healer_blood_ties",
                    Value = 30,
                },
                ["SpecialUpgrade_8"] = {
                    Image = "Healer_blood_ties",
                    Block = 20,
                    Resist = 25,
                }, 
            },
        },		
        ['Gunner'] = {
            [1] = {
                ["SpecialUpgrade_1"] = {
                    Image = "Gunner_Weakness",
                    Value = 5,
                },
                ["SpecialUpgrade_2"] = {
                    GetAddAbility = "Gunner_Medkit",
                },
                ["SpecialUpgrade_3"] = {
                    Image = "Gunner_Weakness",
                    Value = 1100,
                },
                ["SpecialUpgrade_4"] = {
                    Image = "Gunner_Medkit",
                    Value = 350,
                },
                ["SpecialUpgrade_5"] = {
                    Image = "HeroIcon",
                    GetAddModifier = "modifier_vampires_blood_loss",
                    Value = -7,
                },
                ["SpecialUpgrade_6"] = {
                    Image = "HeroIcon",
                    GetAddModifier = "modifier_wild_hunt_aura",
                    Radius = 1100,
                    MSpeed = 10,
                    ASpeed = 50,
                },
                ["SpecialUpgrade_7"] = {
                    Image = "Gunner_Medkit",
                    GetAddModifier = "modifier_charges",
                    AbilityCaster = "Gunner_Medkit",
                    dataModifier = { 
						max_count = 3, 
						start_count = 3, 
						replenish_time = 22, 
					},
                },
                ["SpecialUpgrade_8"] = {
                    Image = "Gunner_Medkit",
                    Value = 440,
                },
            },         
            [2] = {
                ["SpecialUpgrade_1"] = {
                    Image = "HeroIcon",
                    GetAddModifier = "modifier_gunner_bonus_vision_ms",
                    Vision = 300,
                    Ms = 15,
                },
                ["SpecialUpgrade_2"] = {
                    GetAddAbility = "Gunner_Trap_hunter",
                },
                ["SpecialUpgrade_3"] = {
                    GetAddAbility = "Gunner_Hawk",
                },
                ["SpecialUpgrade_4"] = {
                    Image = "Gunner_Trap_hunter",
                    Value = 25,
                },
                ["SpecialUpgrade_5"] = {
                    Image = "Gunner_Hawk",
                    Value = 5,
                },
                ["SpecialUpgrade_6"] = {
                    Image = "Gunner_Weakness",
                    Duration = 30,
                    BDuration = 7,
                    Damage = 45,
                },
                ["SpecialUpgrade_7"] = {
                    Image = "Gunner_Trap_hunter",
                    CReduce = 20,
                    Duration = 3,
                    Damage = 100,
                },
                ["SpecialUpgrade_8"] = {
                    GetAddAbility = "Gunner_Hunters_chain",
                },
            },         
            [3] = {
                ["SpecialUpgrade_1"] = {
                    Image = "HeroIcon",
                    Value = 10,
                },
                ["SpecialUpgrade_2"] = {
                    Image = "Gunner_Weakness",
                    Value = 100,
                },
                ["SpecialUpgrade_3"] = {
                    Image = "Gunner_Unstable_Ammonite",
                    Radius = 325,
                    Chance = 50,
                    Duration = 0.5,
                },
                ["SpecialUpgrade_4"] = {
                    Image = "Gunner_Weakness",
                    Value = 1,
                },
                ["SpecialUpgrade_5"] = {
                    Image = "HeroIcon",
                },
                ["SpecialUpgrade_6"] = {
                    GetAddAbility = "Gunner_machine_gun_mode",
                },
                ["SpecialUpgrade_7"] = {
                    GetAddAbility = "Gunner_kill_shot",
                },
                ["SpecialUpgrade_8"] = {
                    GetAddAbility = "Gunner_second_life",
                },
            },
        },
	}
}

UPGRADE_CLASS_SETTING = {
	levels = {
		[1] = 5,
		[2] = 10,
		[3] = 18,
		[4] = 25,
	},
	Vampires = {
		["Beta"] = {
			[1] = {
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8",
			},			
			[2] = {
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8",
			},			
			[3] = {
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8",
			},
		},		
		["Alpha"] = {
			[1] = "locked",
			[2] = {
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8",
			},
			[3] = "locked",		 	
		},
	},
	Mans = {
		['Warrior'] = {
			[1] = {				
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8",
			},			
			[2] = {				
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8",
			},			
			[3] = {				
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8", 
			},
		},	
		['Priest'] = {
			[1] = {				
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8",
			},			
			[2] = {				
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8",
			},			
			[3] = {				
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8", 
			},
		},	
		['Gunner'] = {
			[1] = {
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8",
			},			
			[2] = {
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8",
			},			
			[3] = {
				"SpecialUpgrade_1", -- 1 UPGRADE
				"SpecialUpgrade_2", -- 2 UPGRADE
				"SpecialUpgrade_3", -- 3 UPGRADE
				"SpecialUpgrade_4",
				"SpecialUpgrade_5", -- 4 UPGRADE
				"SpecialUpgrade_6",
				"SpecialUpgrade_7", 
				"SpecialUpgrade_8",
			},
		},
	},
	
}

--[[SETTING_UPGRADES = {
	Vampires = {
		["Alpha"] = {
			[2] = {
				["SpecialUpgrade_1"] = "Vampire_Claws",
				["SpecialUpgrade_2"] = "VampireShield",
				["SpecialUpgrade_3"] = "VampireShadowMist",
				["SpecialUpgrade_4"] = "VampireDevourer",
				["SpecialUpgrade_5"] = "VampireShadow_Veil",
				["SpecialUpgrade_6"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_7"] = "VampireFlair",
				["SpecialUpgrade_8"] = "Vampire_Claws",
			},		 	
		},
		["Beta"] = {
			[1] = {
				["SpecialUpgrade_1"] = "VampireBatTransform",
				["SpecialUpgrade_2"] = "Vampire_Claws",
				["SpecialUpgrade_3"] = "VampireBatTransform",
				["SpecialUpgrade_4"] = "VampireBatTransform",
				["SpecialUpgrade_5"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_6"] = "Vampire_Claws",
				["SpecialUpgrade_7"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_8"] = "Vampire_Claws",
			},			
			[2] = {
				["SpecialUpgrade_1"] = "Vampire_Claws",
				["SpecialUpgrade_2"] = "Vampire_Claws",
				["SpecialUpgrade_3"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_4"] = "VampireBatTransform",
				["SpecialUpgrade_5"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_6"] = "Vampire_Claws",
				["SpecialUpgrade_7"] = "VampireBatTransform",
				["SpecialUpgrade_8"] = "Vampir_BloodCauldron",
			},			
			[3] = {
				["SpecialUpgrade_1"] = "VampireShadowMist",
				["SpecialUpgrade_2"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_3"] = "VampireBatTransform",
				["SpecialUpgrade_4"] = "VampireShadowMist",
				["SpecialUpgrade_5"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_6"] = "VampireBatTransform",
				["SpecialUpgrade_7"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_8"] = "VampireShadowMist",
			},
		},
	},
	Mans = {
		['Warrior'] = {
			[1] = {				
				["SpecialUpgrade_1"] = "VampireShadowMist",
				["SpecialUpgrade_2"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_3"] = "VampireShadowMist",
				["SpecialUpgrade_4"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_5"] = "VampireShadowMist",
				["SpecialUpgrade_6"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_7"] = "VampireShadowMist",
				["SpecialUpgrade_8"] = "Vampir_BloodCauldron",
			},			
			[2] = {				
				["SpecialUpgrade_1"] = "VampireBatTransform",
				["SpecialUpgrade_2"] = "VampireShadowMist",
				["SpecialUpgrade_3"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_4"] = "VampireShadowMist",
				["SpecialUpgrade_5"] = "VampireShadowMist",
				["SpecialUpgrade_6"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_7"] = "VampireShadowMist",
				["SpecialUpgrade_8"] = "Vampir_BloodCauldron",
			},			
			[3] = {				
				["SpecialUpgrade_1"] = "VampireBatTransform",
				["SpecialUpgrade_2"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_3"] = "VampireShadowMist",
				["SpecialUpgrade_4"] = "VampireBatTransform",
				["SpecialUpgrade_5"] = "VampireShield",
				["SpecialUpgrade_6"] = "VampireShadowMist",
				["SpecialUpgrade_7"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_8"] = "VampireShield",
			},
		},		
		['BowMan'] = {
			[1] = {
				["SpecialUpgrade_1"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_2"] = "VampireBatTransform",
				["SpecialUpgrade_3"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_4"] = "VampireShadowMist",
				["SpecialUpgrade_5"] = "VampireShield",
				["SpecialUpgrade_6"] = "Vampir_BloodCauldron",
				["SpecialUpgrade_7"] = "VampireBatTransform",
				["SpecialUpgrade_8"] = "VampireShadowMist",
			},			
			[2] = {
				["SpecialUpgrade_1"] = "Vampire_Claws",
				["SpecialUpgrade_2"] = "VampireShadowMist",
				["SpecialUpgrade_3"] = "VampireBatTransform",
				["SpecialUpgrade_4"] = "VampireShadowMist",
				["SpecialUpgrade_5"] = "VampireBatTransform",
				["SpecialUpgrade_6"] = "VampireShield",
				["SpecialUpgrade_7"] = "VampireShadowMist",
				["SpecialUpgrade_8"] = "VampireShield",
			},			
			[3] = {
				["SpecialUpgrade_1"] = "VampireShield",
				["SpecialUpgrade_2"] = "VampireBatTransform",
				["SpecialUpgrade_3"] = "Vampire_Claws",
				["SpecialUpgrade_4"] = "VampireShadowMist",
				["SpecialUpgrade_5"] = "Vampire_Claws",
				["SpecialUpgrade_6"] = "VampireBatTransform",
				["SpecialUpgrade_7"] = "VampireShield",
				["SpecialUpgrade_8"] = "Vampire_Claws",
			},
		},
	}
} ]]
