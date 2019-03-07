AllPlayersInterval = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23}
AllPlayersIntervalArray = {}
for k,v in pairs(AllPlayersInterval) do 
	AllPlayersIntervalArray[v] = {}
end 
if VampireZ == nil then
    _G.VampireZ = class({})
	PickersHeroes = {}
end
if not USER_DATA then
	USER_DATA = {}
	for i=0, 23 do
		USER_DATA[i] = {}
	end 
end
local RequireList = {
	"settings",
	"events",
	"filters",
	["libraries"] = {
		"timers",
		"physics",
		"projectiles",
		"notifications",
		"containers",
		"playertables",
		"json",
		--"attachments",
		--"modmaker",
		--"pathgraph",
		--"selection",
	},
	["util"] = {
		"funcs",
		"math",
		"PlayerResource",
		"string",
		"table",
		"keyvalues",
	},
}

for k,v in pairs(RequireList) do
	if type(v) == "table" then
		for _,value in pairs(v) do
			require(k .. "/" .. value)
		end 
	else
		require(v)
	end
end
require("modules/index")
function VampireZ:OnHeroInGame(hero)
end

function VampireZ:OnGameInProgress()
	SpawnNeutrals:Init()
	--HeroSelection:SetRandomVampire()
	Vampires:SetAlpha(HeroSelection2.FirstVampire)
	DUMMY_UNIT:AddNewModifier(DUMMY_UNIT,nil,'modifier_global_aura',{duration = -1})
	Cave:Create()
	for i = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(i) then
			local hero = PlayerResource:GetSelectedHeroEntity(i)
			hero:RemoveModifierByName("modifier_stunned")
		end
	end
end

function VampireZ:PreGame()
	HeroSelection2:PreLoad()
	PlayerTables:CreateTable("DataPlayer", {
		info = PLAYER_DATA,
	},PLAYER_DATA)	
	CustomNetTables:SetTableValue("UpgradeHeroSetting", "info", {})
	if DUMMY_UNIT == nil then
		DUMMY_UNIT = CreateUnitByName('npc_dummy_unit', Vector(0,0,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
		DUMMY_UNIT:AddNewModifier(DUMMY_UNIT,nil,'modifier_hero_out_of_game',{duration = -1})
	end
	--HeroSelection:Init()
end
function VampireZ:HeroSelection()
end 
function VampireZ:Init()

	GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
	GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
	GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
	GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
	GameRules:SetPreGameTime( HeroSelection2.DurationSelection + 15 )
	GameRules:SetPostGameTime( POST_GAME_TIME )
	GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
	GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
	GameRules:SetGoldPerTick(GOLD_PER_TICK)
	GameRules:SetGoldTickTime(GOLD_TICK_TIME)
	GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
	GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
	GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
	GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
	GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )
	GameRules:SetFirstBloodActive( ENABLE_FIRST_BLOOD )
	GameRules:SetHideKillMessageHeaders( HIDE_KILL_BANNERS )
	GameRules:SetCustomGameEndDelay( GAME_END_DELAY )
	GameRules:SetCustomVictoryMessageDuration( VICTORY_MESSAGE_DURATION )
	GameRules:SetStartingGold( STARTING_GOLD )
	local mode = GameRules:GetGameModeEntity()        
	mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
	mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
	mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
	mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
	mode:SetBuybackEnabled( BUYBACK_ENABLED )
	mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
	mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
	mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
	mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
	mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
	mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )
	mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
	mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
	mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )
	mode:SetAlwaysShowPlayerInventory( SHOW_ONLY_PLAYER_INVENTORY )
	mode:SetAnnouncerDisabled( DISABLE_ANNOUNCER )
	if FORCE_PICKED_HERO ~= nil then
		mode:SetCustomGameForceHero( FORCE_PICKED_HERO )
	end
	mode:SetFixedRespawnTime( FIXED_RESPAWN_TIME ) 
	mode:SetFountainConstantManaRegen( FOUNTAIN_CONSTANT_MANA_REGEN )
	mode:SetFountainPercentageHealthRegen( FOUNTAIN_PERCENTAGE_HEALTH_REGEN )
	mode:SetFountainPercentageManaRegen( FOUNTAIN_PERCENTAGE_MANA_REGEN )
	mode:SetLoseGoldOnDeath( LOSE_GOLD_ON_DEATH )
	mode:SetMaximumAttackSpeed( MAXIMUM_ATTACK_SPEED )
	mode:SetMinimumAttackSpeed( MINIMUM_ATTACK_SPEED )
	mode:SetStashPurchasingDisabled ( DISABLE_STASH_PURCHASING )
	for rune, spawn in pairs(ENABLED_RUNES) do
		mode:SetRuneEnabled(rune, spawn)
	end
	mode:SetUnseenFogOfWarEnabled( USE_UNSEEN_FOG_OF_WAR )
	mode:SetDaynightCycleDisabled( DISABLE_DAY_NIGHT_CYCLE )
	mode:SetKillingSpreeAnnouncerDisabled( DISABLE_KILLING_SPREE_ANNOUNCER )
	mode:SetStickyItemDisabled( DISABLE_STICKY_ITEM )
	GameRules:SetCustomGameSetupAutoLaunchDelay( AUTO_LAUNCH_DELAY )
	GameRules:LockCustomGameSetupTeamAssignment( LOCK_TEAM_SETUP )
	GameRules:EnableCustomGameSetupAutoLaunch( ENABLE_AUTO_LAUNCH )
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 12)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	if USE_CUSTOM_TEAM_COLORS then
		for team,color in pairs(TEAM_COLORS) do
			SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
		end
	end
	VampireZ:StartGameEvents()
	VampireZ:FiltersOn()
	PlayerTables:CreateTable("player_hero_indexes", {}, AllPlayersInterval)
	GameRules:GetGameModeEntity():SetHudCombatEventsDisabled( true )
	--HeroSelection:PreLoad()
	UpgradeHero:PreLoad()
	SpawnNeutrals:PreLoad()
	CustomShop:PreLoad()
	VampireZ:Think()	
end

function VampireZ:PickedTeamHero(data)
	local team = data.Team
	local pID = data.pID
	PickersHeroes[pID] = team
end 

function VampireZ:Think()
	Timers:CreateTimer(0.1,function()
		for i = 0, 23 do
			if PlayerResource:IsValidPlayerID(i) then
				if PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_CONNECTED then
					USER_DATA[i].IsAbandoned = false
				elseif PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_ABANDONED then
					USER_DATA[i].IsAbandoned = true
				end
			end
		end
		if GameRules:GetDOTATime(false,false) >= GAME_TIME_TO_WIN then
				request:SetWinner(DOTA_TEAM_GOODGUYS)
				return
		end
		return 1
	end)
end
