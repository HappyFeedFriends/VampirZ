var Settings ={
	fixedNumber:1, 
}
var FixedSchedule = FixedSchedule || false;
var HealthBar = FindDotaHudElement("HBBarMain"); // Main Panel
var UnitNameLabel = HealthBar.FindChildTraverse("UnitNameHB"); // Name Unit Panel
var HealthBarMain = HealthBar.FindChildTraverse("HealthBarMainUI"); // Health Panel
var HP = HealthBarMain.FindChildTraverse("HealthBarLabel"); // health text
var HealthRegenLabel = HealthBarMain.FindChildTraverse("HealthBarRegenLabel"); // health regen text
var HealthBG = HealthBar.FindChildTraverse("UnitNameHealthBarBG"); // Health background


var ManaBarMain = HealthBar.FindChildTraverse("ManaBarMainUI"); // Mana Panel
var ManaBarLabel = ManaBarMain.FindChildTraverse("ManaBarLabel"); //Mana text
var ManaBarBG = HealthBar.FindChildTraverse("UnitNameManaBarBG"); // Mana background
var ManaBarRegenLabel = HealthBar.FindChildTraverse("ManaBarRegenLabel"); // Mana regen text


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
	//CloseHealthBar();
	CloseManaBar();
	//CloseNameUnit();
	HidePanel($('#HBBarMain'))
}
function OpenAllBars(){
	OpenHealthBar();
	OpenManaBar();
	OpenNameUnit();
	UnHiddenPanel($('#HBBarMain'))
}
var allData
function UpdateHealthBarInfo(data){
	if (data && !data.stop){
		UpdateManaBar(data);
		UpdateHpBar(data);
		OpenNameUnit();
		UnHiddenPanel($('#HBBarMain'))
		CreateModifiersPanel(data.index);
		$('#BossStage').SetHasClass('IsBoss',data.stage != null)
		$('#BossStage').SetDialogVariable('color',data.stage == 1 ? 'lime' : data.stage == 2 ? 'orange' : 'red')
		$('#BossStage').SetDialogVariable('stage',data.stage || 0)
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
	data.Mana = Entities.GetMana(data.index) > 0 ? Entities.GetMana(data.index) : -1;
	data.ManaMax = Entities.GetMaxMana(data.index) > 0 ? Entities.GetMaxMana(data.index) : -1;;
	data.ManaRegen = Entities.GetManaThinkRegen(data.index);
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
	data.health = Entities.GetHealth(data.index);
	data.HealthMax = Entities.GetMaxHealth(data.index);
	data.HealthRegen = Entities.GetHealthThinkRegen(data.index);
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
		UnitNameLabel.text = $.Localize(Entities.GetUnitName( data.index ));
		HP.text = hpText; 
		HealthRegenLabel.text = "+ " + HpRegen;
		HealthBG.style.clip = "rect( 0% ," + pctHp + "%" + ", 100% ,0% )";
}

function CreateModifiersPanel(sUnit){
	var buffContainer = $('#buffs');
	var debuffContainer = $('#debuffs'); 
	_.forEach(buffContainer.Children(),function(child){
		if (Buffs.GetName(sUnit, child.BuffID )  == "" && Buffs.GetParent( sUnit, child.BuffID ) != sUnit){
			HidePanel(child)
			child.DeleteAsync(0)
		}
	})
	_.forEach(debuffContainer.Children(),function(child){
		if (Buffs.GetName(sUnit, child.BuffID )  == "" && Buffs.GetParent( sUnit, child.BuffID ) != sUnit){
			HidePanel(child)
			child.DeleteAsync(0)
		}
	})
	for (var i = 0; i < Entities.GetNumBuffs(sUnit); i++) {
		var buffID = Entities.GetBuff(sUnit, i)
		if (!Buffs.IsHidden(sUnit, buffID ) ){
			var IsDebuff = Buffs.IsDebuff(sUnit, buffID)
			var Container = IsDebuff ? debuffContainer : buffContainer
			var panel = Container.FindChild('Buff_' + buffID);
			if (!panel){
				panel = $.CreatePanel( "Panel", Container, 'Buff_' + buffID );
				panel.BuffID = buffID
				panel.BLoadLayoutSnippet('BuffSnippet');
				panel.SetPanelEvent("onmouseover", onMouseOverBuff(panel,sUnit)); 
				panel.SetPanelEvent("onmouseout", onMouseOutBuff(panel));
			} 
			var StackCount = Buffs.GetStackCount( sUnit, buffID );
			if (StackCount > 0)
				panel.FindChildTraverse('StackCount').text = StackCount
			panel.FindChildTraverse('StackCount').SetHasClass('has_stacks',StackCount > 0)
			var buffImage = Abilities.IsItem( Buffs.GetAbility(sUnit, buffID ) )
			? 'file://{images}/items/'+ Buffs.GetTexture( sUnit, buffID ).replace('item_','')  + '.png'
			: Buffs.GetTexture( sUnit, buffID ) == "" 
				? "file://{images}/spellicons/empty.png"
				: 'raw://resource/flash3/images/spellicons/'+ Buffs.GetTexture( sUnit, buffID ) +'.png';
			panel.FindChildTraverse('BuffImage').SetImage(buffImage);
			var completion = Buffs.GetDuration( sUnit, buffID ) == -1 || Buffs.GetRemainingTime(sUnit, buffID ) <= 0 
			? 360
			: Math.max( 0, 360 * (Buffs.GetRemainingTime(sUnit, buffID ) / Buffs.GetDuration(sUnit, buffID )) );
			panel.FindChildTraverse('CircularDuration').SetHasClass('is_debuff',IsDebuff);
			panel.FindChildTraverse('CircularDuration').style.clip = "radial(50% 50%, "+ -completion +"deg, " + completion + "deg)";
		}
	}
	buffContainer.RemoveClass('BuffBorder') 
}

function onMouseOverBuff(panel,sUnit)
{
	return function(){
		$.DispatchEvent( "DOTAShowBuffTooltip", panel, sUnit, panel.BuffID, Entities.IsEnemy( sUnit ) );
	}
}
function onMouseOutBuff(panel)
{
	return function(){
		$.DispatchEvent( "DOTAHideBuffTooltip", panel );
	}
}

(function(){
	GameEvents.Subscribe('UpdateHealthBar', Updating);
	if (!FixedSchedule){
		Update();
	}
	FixedSchedule = true
	CloseAllBars(); 
})()