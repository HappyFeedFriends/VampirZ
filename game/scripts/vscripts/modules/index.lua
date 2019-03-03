local MODULES =
{
	"vampire",
	"gold",
	"kills",
	--"HeroSelection",
	"UpgradeHero",
	"SpawnNeutrals",
	"HealthBar",
	"CustomShop",
	"illusions",
	"request",
	"wearables",
	"HeroSelection2",
	"Cave",
}

for k,v in pairs(MODULES) do
	ModuleRequire(...,v .. "/" .. v )
end 