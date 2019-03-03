var Settings ={
	regenerationSize:"18",
	regenerationFamily:'Radiance',
	regenerationMargin:"90%",
	fixedNumber:1,
}
var FixedSchedule = FixedSchedule || false;
var HealthBar = FindDotaHudElement("HBBarMain"); // Main Panel
var UnitNameLabel = HealthBar.FindChildTraverse("UnitNameHB"); // Name Unit Panel
var HealthBarMain = HealthBar.FindChildTraverse("HealthBarMainUI"); // Health Panel
var HP = HealthBarMain.FindChildTraverse("HealthBarLabel"); // health text
var HealthRegenLabel = HealthBarMain.FindChildTraverse("HealthBarRegenLabel"); // health regen text
var HealthBG = HealthBar.FindChildTraverse("UnitNameHealthBarBG"); // Health background
HealthRegenLabel.style.fontFamily = Settings.regenerationFamily;
HealthRegenLabel.style.fontSize = Settings.regenerationSize;
HealthRegenLabel.style.marginLeft = Settings.regenerationMargin;

var ManaBarMain = HealthBar.FindChildTraverse("ManaBarMainUI"); // Mana Panel
var ManaBarLabel = ManaBarMain.FindChildTraverse("ManaBarLabel"); //Mana text
var ManaBarBG = HealthBar.FindChildTraverse("UnitNameManaBarBG"); // Mana background
var ManaBarRegenLabel = HealthBar.FindChildTraverse("ManaBarRegenLabel"); // Mana regen text
ManaBarRegenLabel.style.fontFamily = Settings.regenerationFamily; 
ManaBarRegenLabel.style.fontSize = Settings.regenerationSize;
ManaBarRegenLabel.style.marginLeft = Settings.regenerationMargin;

function CloseHealthBar(){
	HidePanel(HealthBarMain);
}
function CloseManaBar(){
	HidePanel(ManaBarMain);
}
function CloseNameUnit(){
	HidePanel(UnitNameLabel);
}
function OpenManaBar(){
	UnHiddenPanel(ManaBarMain);
}
function OpenNameUnit(){
	UnHiddenPanel(UnitNameLabel);
}
function OpenHealthBar(){
	UnHiddenPanel(HealthBarMain);
}

function CloseAllBars(){
	CloseHealthBar();
	CloseManaBar();
	CloseNameUnit();
}
function OpenAllBars(){
	OpenHealthBar();
	OpenManaBar();
	OpenNameUnit();
}
var allData
function UpdateHealthBarInfo(data){
	if (data && !data.stop){
		UpdateManaBar(data);
		UpdateHpBar(data);
		OpenNameUnit();
	}else{
		CloseAllBars();
	}
}
function Update(){
	$.Schedule(0.1,Update)
	if (allData)
	UpdateHealthBarInfo(allData);
}
function Updating(data){
	allData = data;
}

function UpdateManaBar(data){
	var pctMp,MpText,MpRegen;
	if (data.Mana >= 0 && data.ManaMax >= 0){
		if (IsHiddenPanel(ManaBarMain)) OpenManaBar(); 
		pctMp = (data.Mana/data.ManaMax * 100) || 0; 
		if (GetNumberOfDecimal(pctMp) > Settings.fixedNumber )  pctMp = pctMp.toFixed(Settings.fixedNumber); 
		if (!GameUI.IsAltDown()){ 
			MpText = data.Mana + " / " + data.ManaMax; 
			MpRegen = data.ManaRegen; 
			if (GetNumberOfDecimal(MpRegen) > Settings.fixedNumber )  MpRegen = MpRegen.toFixed(Settings.fixedNumber);
		}else{
			MpText = pctMp + "% / 100%";
			MpRegen = (data.ManaRegen*100/data.ManaMax) || 0;
			if (GetNumberOfDecimal(MpRegen) > Settings.fixedNumber )  MpRegen = MpRegen.toFixed(Settings.fixedNumber);
			MpRegen += "%"
		}
		ManaBarRegenLabel.text = "+ " + MpRegen; 
		ManaBarLabel.text = MpText;
		ManaBarBG.style.clip = "rect( 0% ," + pctMp + "%" + ", 100% ,0% )";
	}else{
		CloseManaBar();
	}
} 

function UpdateHpBar(data){
	if (IsHiddenPanel(HealthBarMain)) OpenHealthBar();
		var pctHp = (data.health/data.HealthMax * 100) || 0;
		if (GetNumberOfDecimal(pctHp) > Settings.fixedNumber )  pctHp = pctHp.toFixed(Settings.fixedNumber);
		var HpRegen,hpText,ManaRegen,ManaText;
		if (!GameUI.IsAltDown()){
			hpText = data.health + " / " + data.HealthMax;
			HpRegen = data.HealthRegen;
			if (GetNumberOfDecimal(HpRegen) > Settings.fixedNumber )  HpRegen = HpRegen.toFixed(Settings.fixedNumber);
		}else{
			HpRegen = (data.HealthRegen*100/data.HealthMax) || 0;
			if (GetNumberOfDecimal(HpRegen) > Settings.fixedNumber )  HpRegen = HpRegen.toFixed(Settings.fixedNumber);
			HpRegen += "%";			
			hpText = pctHp + "% / 100%";
		}
		UnitNameLabel.text = $.Localize(data.HeroName);
		HP.text = hpText; 
		HealthRegenLabel.text = "+ " + HpRegen;
		HealthBG.style.clip = "rect( 0% ," + pctHp + "%" + ", 100% ,0% )";
}

(function(){
	GameEvents.Subscribe('UpdateHealthBar', Updating);
	if (!FixedSchedule){
		Update();
	}
	FixedSchedule = true
	CloseAllBars(); 
})()