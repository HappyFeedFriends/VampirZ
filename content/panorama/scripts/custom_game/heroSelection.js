var other = {			// Худы
	1:"minimap_container",
	2:"lower_hud",
	//3:"HudChat",
	4:"NetGraph",
	5:"quickstats",
	6:"CustomShopButton",
};
var types = {			// Типы 
	1:"DOTA_ATTRIBUTE_STRENGTH",
	2:"DOTA_ATTRIBUTE_AGILITY",
	3:"DOTA_ATTRIBUTE_INTELLECT",
};
var prefixEffect = " > ";
var textColor = {
	PositivityText:"LimeGreen;", // Позитивные Эффекты
	NegativityText:"Crimson;", // Негативные Эффекты 
	NotEffect:"yellow",	// Нету эффектов
} 

var KeyTable = "HeroSelection";
var KeyTableEffects = "Effects";
var Main = FindDotaHudElement('MainPickHero');
var BG = FindDotaHudElement('BackgroundPanel');
var SelectionHeroMain = FindDotaHudElement('MainSelectionHero');
var TimerTime = FindDotaHudElement('HeroSelectionTimer');
var FORCE_PICKED_HERO = CustomNetTables.GetTableValue(KeyTable,"settings")["Hero"];
var TimeToPick = 0;
var t,h,PickedHeroName;
var PickHeroes = PickHeroes || {}
var AllHero = AllHero || {};
if (!AllHero["1"]){
	for (i in types){
		t = CustomNetTables.GetTableValue(KeyTable,types[i]);
		for (j in t){
			h = t[j];
			AllHero[Number(LengthTable(AllHero)) + 1] = h;
		}
	}
}
var StagePick = {
	1:"picking_hero",
	2:"selection_hero",
}

function CreateTimer(data){	
	TimeToPick = data.time;
	var Timer = TimerTime.FindChild( "time" );
	if (!Timer){
		Timer = $.CreatePanel( "Label", TimerTime, "time" );   
	}	
	var TimerInfo = TimerTime.FindChild( "time_info" );
	if (!TimerInfo){
		TimerInfo = $.CreatePanel( "Label", TimerTime, "time_info" );   
		TimerInfo.style.fontSize = "20px;";
		TimerInfo.style.marginTop = "-20px";
	}
	if (TimeToPick <=0) {
		Timer.text = secondsToMS(0, true) 
		$.Schedule(0.3,PickedRandom)
		return 
	}
	//$.Schedule(1,CreateTimer);
	Timer.text = secondsToMS(TimeToPick, true);
	TimerInfo.text = IsHiddenPanel(SelectionHeroMain) && $.Localize("stage_" + StagePick[1]) || $.Localize("stage_" + StagePick[2]);
}
function GetPickTime(){
	return TimeToPick
}
function FillHeroSelection(){
	for (i in types){
		Fill(types[i]);
	}
	UnHiddenPanel(Main);
	HidePanel(SelectionHeroMain);  
	//HiddenOther();
} 

function OpenHero(data){
	var TimerInfo = TimerTime.FindChild( "time_info" );
	if (TimerInfo)
	TimerInfo.text = IsHiddenPanel(SelectionHeroMain) && $.Localize("stage_" + StagePick[1]) || $.Localize("stage_" + StagePick[2]);
	var name = data.heroName;
	var abilities = CustomNetTables.GetTableValue(KeyTable,name);
	var information = SelectionHeroMain.FindChild( "information" );
	if (!information){
		information = $.CreatePanel( "Panel", SelectionHeroMain, "information" );   
		information.SetHasClass( "information", true );
	}
	var heroDataPanel = information.FindChild( "heroDataPanel" );
	if (!heroDataPanel){
		heroDataPanel = $.CreatePanel( "Panel", information, "heroDataPanel" );
		heroDataPanel.SetHasClass( "heroDataPanel", true );		
	}	
	CreateAbilitiesPanelUI(heroDataPanel,abilities);
	CreateScenePanelUI(heroDataPanel,name);
	CreateButtonPanelsUI(heroDataPanel,name,data); 
	CreateHeroInformationUI(information,name);
}
function CreateAbilitiesPanelUI(heroDataPanel,abilities){
	var abilityHero = heroDataPanel.FindChild( "abilityHero" );
	if (!abilityHero){
		abilityHero = $.CreatePanel( "Panel", heroDataPanel, "abilityHero" ); 
		abilityHero.SetHasClass( "abilityHero", true );
	}
	var ability,panel,RefreshMin;
	for (i in abilities){
		ability = abilities[i];
		panel = abilityHero.FindChild( "Ability_hero_" + i );
		if (!panel){
			panel = $.CreatePanel( "DOTAAbilityImage", abilityHero, "Ability_hero_" + i );
			panel.SetHasClass( "AbilityPanel", true );
		}
			panel.abilityname = ability;
			panel.SetPanelEvent( "onmouseover", ShowAbilityTooltip( panel ) );
			panel.SetPanelEvent( "onmouseout", HideAbilityTooltip( panel ) );
		RefreshMin = i;
	};
	RefreshAbilityList(Number(RefreshMin) + 1,abilityHero);
}
function CreateButtonPanelsUI(heroDataPanel,name,data){
	var ButtonPickHero = heroDataPanel.FindChild( "ButtonPickHero" );
		//PickedHeroName = name;
	if (!ButtonPickHero){
		ButtonPickHero = $.CreatePanel("Panel", heroDataPanel, "ButtonPickHero"); 
		ButtonPickHero.SetHasClass("ButtonPickHero",true);
	}
	var ButtonLabel = ButtonPickHero.FindChild( "ButtonPickLabel" );
	if (!ButtonLabel){
		ButtonLabel = $.CreatePanel("Label", ButtonPickHero, "ButtonPickLabel"); 
	}
	var ButtonRepickHero  = heroDataPanel.FindChild( "ButtonRepickHero" );
	if (!ButtonRepickHero){
		ButtonRepickHero = $.CreatePanel("Panel", heroDataPanel, "ButtonRepickHero"); 
		ButtonRepickHero.SetHasClass("ButtonRepickHero",true);
		ButtonRepickHero.SetPanelEvent( "onactivate", RepickHero() );
	}
	var ButtonRepickHeroLabel = ButtonRepickHero.FindChild( "ButtonRepickHeroLabel" );
	if (!ButtonRepickHeroLabel){
		ButtonRepickHeroLabel = $.CreatePanel("Label", ButtonRepickHero, "ButtonRepickHeroLabel");   
	}
	ButtonRepickHeroLabel.text = $.Localize("#repick_hero");
	ButtonLabel.text = $.Localize("#playing_hero") + " " + $.Localize(name);
	ButtonPickHero.SetPanelEvent( "onactivate", PickedHero( data ) );
}
 
function CreateHeroInformationUI(information,name){
	var HeroInformation = information.FindChild( "HeroInformation" );
	if (!HeroInformation){
		HeroInformation = $.CreatePanel( "Panel", information, "HeroInformation" );
		HeroInformation.SetHasClass( "HeroInformation", true );		
	}
	var HeroEffects = HeroInformation.FindChild( "HeroEffects" );
	if (!HeroEffects){
		HeroEffects = $.CreatePanel( "Panel", HeroInformation, "HeroEffects" );
		HeroEffects.SetHasClass( "HeroEffects", true );
	}
	CreatePositivInfoPanelUI(HeroEffects,name);
	CreateNegativityInfoPanelUI(HeroEffects,name);
}
function CreatePositivInfoPanelUI(HeroEffects,name){
	var PositivInfo = HeroEffects.FindChild( "PositivInfo" );
	if (!PositivInfo){
		PositivInfo = $.CreatePanel( "Panel", HeroEffects, "PositivInfo" );
		PositivInfo.SetHasClass( "EffectPanelInfo", true );
	}
	var HeroEffectsLabelPositiv = PositivInfo.FindChild( "HeroEffectsLabelPositiv" );
	if (!HeroEffectsLabelPositiv){
		HeroEffectsLabelPositiv = $.CreatePanel( "Label", PositivInfo, "HeroEffectsLabelPositiv" );
		HeroEffectsLabelPositiv.SetHasClass( "HeroEffectLabel", true );
		HeroEffectsLabelPositiv.text = $.Localize("#positivity_effects"); 
		HeroEffectsLabelPositiv.style.color = textColor.PositivityText; 
	}
	var effect_list = CustomNetTables.GetTableValue(KeyTable,KeyTableEffects);
	var hideStart;
	if (effect_list[name] && effect_list[name].POSITIVITY){
		var positivity = effect_list[name].POSITIVITY;
		var effect;
		var l = 1;
		var HeroEffectPositivy = PositivInfo.FindChild( "HeroEffectPositivy" );
		if (!HeroEffectPositivy){
			HeroEffectPositivy = $.CreatePanel( "Panel", PositivInfo, "HeroEffectPositivy" );
			HeroEffectPositivy.SetHasClass( "HeroEffectPanel", true );
		}
		for (i in positivity){
			effect = TransformEffectText(i,positivity[i],"positive");
			var PositivEffectLabel = HeroEffectPositivy.FindChild( "PositivEffectLabel_" + l ); 
			if (!PositivEffectLabel){
				PositivEffectLabel = $.CreatePanel( "Label", HeroEffectPositivy, "PositivEffectLabel_" + l );
				PositivEffectLabel.text = prefixEffect + effect;
			} 
			l++
			hideStart = l;
		}
	}else{
		var HeroEffectPositivy = PositivInfo.FindChild( "HeroEffectPositivy" );
		if (!HeroEffectPositivy){
			HeroEffectPositivy = $.CreatePanel( "Panel", PositivInfo, "HeroEffectPositivy" );
			HeroEffectPositivy.SetHasClass( "HeroEffectPanel", true );
		}
		var PositivEffectLabel = HeroEffectPositivy.FindChild( "PositivEffectLabel_1" );
		if (!PositivEffectLabel){
			PositivEffectLabel = $.CreatePanel( "Label", HeroEffectPositivy, "PositivEffectLabel_1" );
		}
		PositivEffectLabel.text = $.Localize("#not_positivity_effects"); 
		PositivEffectLabel.style.color = textColor.NotEffect;
		hideStart = 1;
	}
	RefreshPanelInfo(PositivInfo,"positive",Number(hideStart) + 1,name);
}
function CreateNegativityInfoPanelUI(HeroEffects,name){
	var NegativePanelInfo = HeroEffects.FindChild( "NegativePanelInfo" );
	if (!NegativePanelInfo){
		NegativePanelInfo = $.CreatePanel( "Panel", HeroEffects, "NegativePanelInfo" );
		NegativePanelInfo.SetHasClass( "EffectPanelInfo", true );
	}
	var HeroNegativeLabel = NegativePanelInfo.FindChild( "HeroNegativeLabel" );
	if (!HeroNegativeLabel){
		HeroNegativeLabel = $.CreatePanel( "Label", NegativePanelInfo, "HeroNegativeLabel" );
		HeroNegativeLabel.SetHasClass( "HeroEffectLabel", true );
		HeroNegativeLabel.style.color = textColor.NegativityText;
		HeroNegativeLabel.text = $.Localize("#negativity_effects");   
	}
	var effect_list = CustomNetTables.GetTableValue(KeyTable,KeyTableEffects);
	var hideStart
	if (effect_list[name] && effect_list[name].NEGATIVITY){
		var negativity = effect_list[name].NEGATIVITY;
		var effect,NegativeEffectLabel;
		var HeroEffectNegativity = NegativePanelInfo.FindChild( "HeroEffectNegativity" );
		if (!HeroEffectNegativity){
			HeroEffectNegativity = $.CreatePanel( "Panel", NegativePanelInfo, "HeroEffectNegativity" );
			HeroEffectNegativity.SetHasClass( "HeroEffectPanel", true );
		}
		var l = 1;
		for (i in negativity){
			effect = negativity[i];
			NegativeEffectLabel = HeroEffectNegativity.FindChild( "NegativeEffect_" + l );
			if (!NegativeEffectLabel){
				NegativeEffectLabel = $.CreatePanel( "Label", HeroEffectNegativity, "NegativeEffect_" + l );
			}
			l++
			hideStart = l;
		}
	}else{
		var HeroEffectNegativity = NegativePanelInfo.FindChild( "HeroEffectNegativity" );
		if (!HeroEffectNegativity){
			HeroEffectNegativity = $.CreatePanel( "Panel", NegativePanelInfo, "HeroEffectNegativity" );
			HeroEffectNegativity.SetHasClass( "HeroEffectPanel", true );
		}
		NegativeEffectLabel = HeroEffectNegativity.FindChild( "NegativeEffect_1" );
		if (!NegativeEffectLabel){
			NegativeEffectLabel = $.CreatePanel( "Label", HeroEffectNegativity, "NegativeEffect_1" ); 
		}
		NegativeEffectLabel.text = $.Localize("not_negativity_effects");  
		NegativeEffectLabel.style.color = textColor.NotEffect;
		hideStart = 1;
	}  
	RefreshPanelInfo(NegativePanelInfo,"negative",Number(hideStart) + 1,name);
}
function RefreshPanelInfo(panel,effect,hideStart,name){
	if (effect === "negative"){
	var effect_list = CustomNetTables.GetTableValue(KeyTable,KeyTableEffects);
		var effects;
		var HeroEffectNegativity = panel.FindChild( "HeroEffectNegativity" );
		if (effect_list[name]){
			var negativity = effect_list[name].NEGATIVITY;
			var l = 1;
			for (i in negativity){
				effects = TransformEffectText(i,negativity[i],"negative");
				var NegativeEffectLabel = HeroEffectNegativity.FindChild( "NegativeEffect_" + l );
				NegativeEffectLabel.text = prefixEffect + effects; 
				NegativeEffectLabel.style.color = textColor.NegativityText;
				l++;
			}
		}
		for (var i=hideStart; i <= 24; i++){
			var Label = HeroEffectNegativity.FindChild( "NegativeEffect_" + i );
			if (Label)
				HidePanel(Label);
		}	
		for (var i=1; i < hideStart; i++){
			var Label = HeroEffectNegativity.FindChild( "NegativeEffect_" + i );
			if (Label)
				UnHiddenPanel(Label);
		}
	}else if (effect === "positive"){
		var effect_list = CustomNetTables.GetTableValue(KeyTable,KeyTableEffects);
		var HeroEffectPositivy = panel.FindChild( "HeroEffectPositivy" );
		if (effect_list[name]){
			var positivity = effect_list[name].POSITIVITY;
			var effects;
			var l = 1;
			for (i in positivity){
				effects = TransformEffectText(i,positivity[i],"positive");
				var PositivEffectLabel = HeroEffectPositivy.FindChild( "PositivEffectLabel_" + l ); 
				PositivEffectLabel.text = prefixEffect + effects; 
				PositivEffectLabel.style.color = textColor.PositivityText;
				l++;
			}
		}
		for (var i=hideStart; i <= 24; i++){
			var Label = HeroEffectPositivy.FindChild( "PositivEffectLabel_" + i );
			if (Label)
				HidePanel(Label);
		}	
		for (var i=1; i < hideStart; i++){
			var Label = HeroEffectPositivy.FindChild( "PositivEffectLabel_" + i );
			if (Label)
				UnHiddenPanel(Label);
		}
	}
}

function TransformEffectText(localizes,text,type){
	var new_text =  $.Localize("tooltip_effect_" + type + "_" + localizes);
	new_text = new_text.replace("{increase_attack_speed}",text);
	new_text = new_text.replace("{increase_movespeed}",text);
	new_text = new_text.replace("{increase_damage}",text);
	new_text = new_text.replace("{increase_health}",text);
	
	new_text = new_text.replace("{slow_movespeed}",text);
	new_text = new_text.replace("{reduced_damage}",text);
	new_text = new_text.replace("{reduced_health}",text);
	new_text = new_text.replace("{slow_attack_speed}",text);
	return new_text
}

function CreateScenePanelUI(heroDataPanel,name){
	var ScenePanel = heroDataPanel.FindChild( "ScenePanel" );
	if (!ScenePanel){
		ScenePanel = $.CreatePanel("Panel", heroDataPanel, "ScenePanel"); 
		ScenePanel.SetHasClass("ScenePanelHero",true);
		ScenePanel.style.opacityMask = 'url("s2r://panorama/images/masks/hero_model_opacity_mask_png.vtex");';
	}
	var heroImageXML = '<DOTAScenePanel style="width:100%; height:100%;" particleonly="false" ' + 'allowrotation="true" unit="' + name + '" />';
		//(IsDotaHeroName(name)
		//	? 'map="scenes/heroes" camera="' + name + '" />'
		//	: 'allowrotation="true" unit="' + name + '" />');
	ScenePanel.RemoveAndDeleteChildren();
	ScenePanel.BCreateChildren(heroImageXML);
}
function RefreshAbilityList(RefreshMin,abilityHero){
	for (var i = RefreshMin;i <= 24;i++){
		if (abilityHero.FindChild( "Ability_hero_" + i ))
		HidePanel(abilityHero.FindChild( "Ability_hero_" + i ));
	}
	for (var i = 1;i < RefreshMin;i++){
		if (abilityHero.FindChild( "Ability_hero_" + i ))
			UnHiddenPanel(abilityHero.FindChild( "Ability_hero_" + i ));
	}
}
 
function Fill(type){
	if (!Main) return 
	var heroes = CustomNetTables.GetTableValue(KeyTable,type);
	var PanelHero,name;
	type = type.replace("DOTA_ATTRIBUTE_","");
	var AttributesPanel = Main.FindChild( type );
	if (!AttributesPanel){
		AttributesPanel = $.CreatePanel( "Panel", Main, type );  
		AttributesPanel.SetHasClass( "AttributesPanel", true );
	};
	for (i in heroes){
		name = heroes[i];
		PanelHero = AttributesPanel.FindChild( name );
		if ( !PanelHero )
		{
			PanelHero = $.CreatePanel( "DOTAHeroImage", AttributesPanel, name );  
			PanelHero.SetHasClass( "HeroPanel", true );  
			PanelHero.data = {
				heroName:name,
				pID:Game.GetLocalPlayerInfo().player_id,
			};
			PanelHero.SetPanelEvent( "onactivate", OpenInfoHero( PanelHero ));			
			PanelHero.heroname = name;
			PanelHero.heroimagestyle = "portrait";
		}
	}	
}

function PickedRandom(){
	if (Game.GetPlayerInfo(Game.GetLocalPlayerInfo().player_id).player_selected_hero != FORCE_PICKED_HERO || PickHeroes[Game.GetLocalPlayerInfo().player_id]) return 
	var LengthAllTables = 0;
	for (i in types){
		LengthAllTables += LengthTable(CustomNetTables.GetTableValue(KeyTable,types[i]));
	}
	var RandomHero = AllHero[String(GetRandomInt(1,LengthAllTables))];
	var data = {
		heroName:RandomHero,
		pID:Game.GetLocalPlayerInfo().player_id,
	};
	HidePanel(Main);
	UnHiddenPanel(SelectionHeroMain);
	OpenHero(data); 
	$.Schedule(1,PickedHero(data))
	
}    

function PickedHero( data ){
	return function(){ 
		if (!PickHeroes[data.pID]){
			PickHeroes[data.pID] = data.heroName;
			GameEvents.SendCustomGameEventToServer( "SetHeroPicked", data );
		}
		if (PickedHeroName && PickedHeroName != data.heroName)
			data.heroName = PickedHeroName;
		var ButtonRepickHero = FindDotaHudElement('ButtonRepickHero');
		var ButtonPickHero = FindDotaHudElement('ButtonPickHero');
		if (GetPickTime() <= 0){
			HidePanel(Main.GetParent())
			GameEvents.SendCustomGameEventToServer( "PickedHero", data );
			ButtonPickHero.enabled = true;
			ButtonRepickHero.enabled = true;
			//UnHiddenOther();
			Main.GetParent().DeleteAsync(0);
		}else{
			 ButtonPickHero.enabled = false;
			 ButtonRepickHero.enabled = false;
			 $.Schedule(1,PickedHero(data));	
		}
	};
} 

function RepickHero(){
	return function(){
		var TimerInfo = TimerTime.FindChild( "time_info" );
		if (TimerInfo)
		TimerInfo.text = IsHiddenPanel(Main) && $.Localize("stage_" + StagePick[1]) || $.Localize("stage_" + StagePick[2]);
		HidePanel(SelectionHeroMain);
		UnHiddenPanel(Main);
	}
}

function HiddenOther(){
	for (var k in other){
		if (FindDotaHudElement(other[k]))
		HidePanel(FindDotaHudElement(other[k]));
	}
	$.Schedule(0.3,function(){
	if (FindDotaHudElement("CustomShopButton").GetParent())
	HidePanel(FindDotaHudElement("CustomShopButton").GetParent())
	})
}

function UnHiddenOther(){
	for (var k in other){
		if (FindDotaHudElement(other[k]))
		UnHiddenPanel(FindDotaHudElement(other[k]));
	}
	$.Schedule(0.3,function(){
	if (FindDotaHudElement("CustomShopButton").GetParent())
	UnHiddenPanel(FindDotaHudElement("CustomShopButton").GetParent())
	})
}

function OpenInfoHero(Panel){
	return function(){
		HidePanel(Main);
		UnHiddenPanel(SelectionHeroMain);
		OpenHero(Panel.data);
	}
}

function HideAllPanels(){
	//HidePanel(Main);
	//HidePanel(BG);
	//HidePanel(SelectionHeroMain);
	//HidePanel(TimerTime); 
	//HidePanel(Main.GetParent()); 
	Main.GetParent().DeleteAsync(0);
}

(function(){
	if (Game.GetPlayerInfo(Game.GetLocalPlayerInfo().player_id).player_selected_hero == FORCE_PICKED_HERO){
		FillHeroSelection();  
		var tables = CustomNetTables.GetTableValue(KeyTable,"picks"); 
		if (tables && tables[Game.GetLocalPlayerInfo().player_id] && IsHeroName(tables[Game.GetLocalPlayerInfo().player_id])){
			var dataInfo = {
				heroName:tables[Game.GetLocalPlayerInfo().player_id],
				pID:Game.GetLocalPlayerInfo().player_id, 
			}
			OpenHero( dataInfo );
			HidePanel(Main);
			UnHiddenPanel(SelectionHeroMain);
			PickedHero( dataInfo )
		} 
	}else{
		HideAllPanels();
	}
	if (Players.GetTeam(Players.GetLocalPlayer()) == DOTA_TEAM_SPECTATOR)
		HideAllPanels();
	GameEvents.Subscribe('HeroSelection_picked', HideAllPanels);
	GameEvents.Subscribe('HeroSelectionTimer', CreateTimer);
	FindDotaHudElement('LabelMap').text = $.Localize(Game.GetMapInfo().map_display_name); 
})(); 