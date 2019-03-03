/*
	Style: Crumbling Island Arena
	JS PANORAMA: VampirZ
*/

function AddTooltip(panel){
	var data = {
		heroName:'npc_dota_hero_warlock',  
		buffs:{  
			"increase_movespeed": 12,
			"increase_damage": 14,
			"increase_health": 16,
			"increase_attack_speed":16, 
		},
		debuffs:{
			"slow_movespeed": -12,
			"reduced_damage": -14,
			"reduced_health": -16,
			"slow_attack_speed":-16, 
		},
	}
	var dataStr = 'heroName='+ data.heroName +
				  '&buffs=' + (LengthTable(data.buffs) > 0 ? JSON.stringify(data.buffs) : null) +
				  '&debuffs=' + (LengthTable(data.debuffs) > 0 ? JSON.stringify(data.debuffs) : null) // FindChildTraverse('')  
	var tooltipPanel = FindDotaHudElement('HeroInfoTooltip')
	//var content = tooltipPanel.FindChildTraverse('content')
	//FindDotaHudElement('HeroInfoTooltip').DeleteAsync(0) 
	panel.SetPanelEvent( "onmouseover", function(){
		$.DispatchEvent("UIShowCustomLayoutParametersTooltip", panel, "HeroInfoTooltip", 
			"file://{resources}/layout/custom_game/tooltips/tooltip_ClassInfo.xml", dataStr);
	});   
		panel.SetPanelEvent( "onmouseout",function() { 
		$.DispatchEvent("UIHideCustomLayoutTooltip", panel, "HeroInfoTooltip"); 
	});	
}

function UpdateHeroData(heroName){
	var heroInfo = $('#HeroInfo')
	var abilityList = CustomNetTables.GetTableValue('HeroSelection','HeroList')[heroName]['ability'];
	var GetClass =  CustomNetTables.GetTableValue('HeroSelection','HeroList')[heroName]['class'];
	var AbilityPanel = heroInfo.FindChildTraverse('HeroAbilities');
	if (heroInfo.FindChildTraverse('LabelName').text == $.Localize('Class_name_' + GetClass))  return;
	heroInfo.FindChildTraverse('LabelName').text = $.Localize('Class_name_' + GetClass)
	AbilityPanel.RemoveAndDeleteChildren();
	for (var i in abilityList){
		var panel = $.CreatePanel('Panel',AbilityPanel,"");
		panel.AddClass('AbilityRow');
		var panelImage = $.CreatePanel('DOTAAbilityImage',panel,"")
		panelImage.abilityname = abilityList[i];
		panelImage.SetPanelEvent('onmouseover',ShowAbilityTooltip(panelImage))
		panelImage.SetPanelEvent('onmouseout',HideAbilityTooltip(panelImage))
		var LabelAbility = $.CreatePanel('Label',panel,"")
		LabelAbility.text = $.Localize('Dota_tooltip_ability_' + abilityList[i]);
	}
	var ScenePanel = heroInfo.FindChildTraverse('ScenePanelContainer')
	var heroImageXML = '<DOTAScenePanel  id="ScenePanel" particleonly="false" ' + 'allowrotation="true" unit="' + heroName + '" />';
	ScenePanel.RemoveAndDeleteChildren();
	ScenePanel.BCreateChildren(heroImageXML); 
	UnHiddenPanel(heroInfo); 
}

function FillHeroesPanel(){
	var panel = $('#Heroes');
	var array = [];   
	var PTList = CustomNetTables.GetTableValue('HeroSelection','HeroList');
	var firstVampire = CustomNetTables.GetTableValue('HeroSelection','Setting')['FirstVampire'];
	for (var i in PTList){
		array.push(i);
	}
	var oldclickPanel; 
	var countClick = GetPlayerID() == firstVampire ? 2 : 0;
	var isClick = true; 
	var isvampire = IsVampire(GetPlayerID()) || GetPlayerID() == firstVampire
	panel.RemoveAndDeleteChildren()
	_.forEach(array,function(HeroName){ 
		if ( !PTList[HeroName].IsLocked && ((PTList[HeroName].IsVampire == 1) == isvampire)){
		var HeroPanel = $.CreatePanel('Image',panel,'');
		HeroPanel.hero = HeroName;
		HeroPanel.AddClass('SelectionImage');
		HeroPanel.SetImage(TransformTextureToPath(HeroName, 'portrait'));
		HeroPanel.SetScaling('stretch-to-fit-x-preserve-aspect');
		HeroPanel.SetPanelEvent('onmouseover',function(){
			if (countClick < 2){ 
				UnHiddenPanel($('#HeroInfo'))
				UpdateHeroData(HeroName);
				$.DispatchEvent("DOTAShowTextTooltip", HeroPanel, 'IsPicking');
				$('#PlayersContent').FindChildTraverse('Player_' + GetPlayerID()).SetImage(TransformTextureToPath(HeroName, 'landscape'));
			} 
		}); 
		HeroPanel.SetPanelEvent('onactivate',function(){
			$.Schedule(0.2,function(){isClick = true;}) 
			if ( countClick >= 2 || !isClick ) return; 
			countClick = oldclickPanel == HeroPanel ?  countClick + 1 : 1;  
			if (countClick < 2){
				_.forEach($('#Heroes').Children(),function(child){
					child.SetHasClass('IsSelectionHero',child == HeroPanel);
					child.SetHasClass('IsSelectionHeroFirst',child == HeroPanel && countClick < 2)
				})  
				UpdateHeroData(HeroName);
				oldclickPanel = HeroPanel;
			}else{  
				//$('#PlayersContent').FindChildTraverse('Player_' + GetPlayerID()).AddClass('IsSelectionPlayer');
				SelectHero(HeroPanel,countClick);
			}
			isClick = false
		}); 
		HeroPanel.SetPanelEvent('onmouseout',function(){
			$.DispatchEvent("DOTAHideTextTooltip");
			if ( countClick < 1 )
				HidePanel($('#HeroInfo'));
			if ( oldclickPanel )
				UpdateHeroData(oldclickPanel.hero);
		});
	}});  
	panel = $('#PlayersContent');
	panel.RemoveAndDeleteChildren() 
	Game.GetAllPlayerIDs().forEach(function(PlayerID){
		var data = Game.GetPlayerInfo( PlayerID )
		var teamPanel = $.CreatePanel('Panel',panel,'');
		teamPanel.AddClass('TeamPlayer');
		var IsVampireImage = $.CreatePanel('Image',teamPanel,'IsVampire');
		IsVampireImage.SetImage('s2r://panorama/images/custom_game/custom_icon/IsVampire.png');
		IsVampireImage.style.opacity = PlayerID == firstVampire ? 1 : 0;
		IsVampireImage.SetPanelEvent('onmouseover',ShowText(IsVampireImage,"IsVampireDescription"));
		IsVampireImage.SetPanelEvent('onmouseout',HideText()); 
		var HeroImage = $.CreatePanel('Image',teamPanel,'Player_' + PlayerID); 
		HeroImage.AddClass('SelectHero')
		HeroImage.SetHasClass('IsSelectionPlayer',firstVampire == PlayerID)
		HeroImage.SetImage(TransformTextureToPath(PlayerID == firstVampire ? 'npc_dota_hero_night_stalker' : data.player_selected_hero, 'landscape'));
		HeroImage.SetScaling('stretch-to-fit-x-preserve-aspect');
		var PlayerName = $.CreatePanel('Label',teamPanel,'');
		PlayerName.text = data.player_name; 

 
	});  
	if (GetPlayerID() == firstVampire){
		_.forEach($('#Heroes').Children(),function(child){
			child.enabled = false
		});
		UpdateHeroData('npc_dota_hero_night_stalker');	
		GameEvents.SendCustomGameEventToServer( "SelectHero", {
			heroName: 'npc_dota_hero_night_stalker',

		});	
	}
}
 
function SelectHero(HeroPanel,countClick){
	_.forEach($('#Heroes').Children(),function(child){
		child.enabled = child == HeroPanel;
		child.SetHasClass('IsSelectionHeroFirst',child == HeroPanel && countClick < 2) 
	}) 
	GameEvents.SendCustomGameEventToServer( "SelectHero", {
		heroName: HeroPanel.hero
	});
}
  
function HideAllPanels(){
	_.each($.GetContextPanel().Children(),function(child){
		HidePanel(child);
	});
}

function GetRandomHeroIsPicking(){
	var heroList = CustomNetTables.GetTableValue('HeroSelection','HeroList') || {};
	var t = {}
	for (var Name in heroList){
		if (heroList[Name].IsLocked ) continue;
		var index = heroList[Name].IsVampire ? 'Vampire' :'Human';
		if (!t[index]) t[index] = [];
		t[index].push(Name);
	}
	var table = t[IsVampire(GetPlayerID()) ? 'Vampire' :'Human'];
	var count = table.length - 1;
	return RandomHero = table[GetRandomInt(0,count)]; 
}
 
(function(){
	FillHeroesPanel();
 	var panel = $('#PlayersContent');
	GameEvents.Subscribe('HeroSelectionUpdateRight', function(data){
		var pID = data.PlayerID;
		var HeroName = data.HeroName;
		var image = panel.FindChildTraverse('Player_' + pID);
		if (image){
			image.SetImage(TransformTextureToPath(HeroName,'landscape'));
			image.AddClass('IsSelectionPlayer')
		}
	}); 
	GameEvents.Subscribe('HeroSelectionUpdateTimer', function(){
		var time = CustomNetTables.GetTableValue('HeroSelection','Setting')['DurationSelection'];
		$('#TimerText').text = secondsToMS(time,false);
		if (time <= 5 && !CustomNetTables.GetTableValue('HeroSelection','SelectedHeroes')[GetPlayerID()]){
			var hero = GetRandomHeroIsPicking();
			GameEvents.SendCustomGameEventToServer( "SelectHero", {
				heroName: hero, 
			});
			var image = panel.FindChildTraverse('Player_' + GetPlayerID());
			image.SetImage(TransformTextureToPath(hero,'landscape')); 
			image.AddClass('IsSelectionPlayer'); 
			_.forEach($('#Heroes').Children(),function(child){
				child.SetHasClass('IsSelectionHero',child.hero == hero);
				child.enabled = false; 
			});
		}
		if (time <= 0) 
			HideAllPanels();
	}); 
	var table = CustomNetTables.GetTableValue('HeroSelection','SelectedHeroes');
	 for (var pID in table){
		var image = panel.FindChildTraverse('Player_' + pID);
		image.SetImage(TransformTextureToPath(table[pID],'landscape')); 
		image.AddClass('IsSelectionPlayer');
 	} 
 
 	if (table[GetPlayerID()]){
 		if (CustomNetTables.GetTableValue('HeroSelection','Setting')['DurationSelection'] <= 0 && table[GetPlayerID()] != Game.GetPlayerInfo( GetPlayerID() ).player_selected_hero)
			GameEvents.SendCustomGameEventToServer( "SelectHero", {
				heroName: table[GetPlayerID()],
			});
		if (CustomNetTables.GetTableValue('HeroSelection','Setting')['DurationSelection'] > 0){
	 		UpdateHeroData(table[GetPlayerID()]);
	 		_.forEach($('#Heroes').Children(),function(child){
				child.SetHasClass('IsSelectionHero',child.hero == table[GetPlayerID()]);
				child.enabled = false; 
			});
	 	}
		//UnHiddenPanel($.GetContextPanel());
 	} 
 	if (CustomNetTables.GetTableValue('HeroSelection','Setting')['DurationSelection'] <= 0) 
 		 HideAllPanels();    
})();