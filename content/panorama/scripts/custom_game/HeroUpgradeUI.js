var MainPanel = $.GetContextPanel().FindChildTraverse('HeroUpgradeMain');   
var Settings = PlayerTables.GetAllTableValues('UpgradeHeroSetting');
var Images = PlayerTables.GetTableValue('UpgradeHeroSetting','Images');
var AllPanels = AllPanels || {};
var ForcePick = CustomNetTables.GetTableValue('HeroSelection','Setting')['defaultHero'];
 
var UpdateCount = 0;
var OldClass = -1;
 
function UpdateAllPanels(){
	var SettingTable = PlayerTables.GetAllTableValues('UpgradeHeroKV'); 
	var ClassesSetting = IsVampire(GetPlayerID()) && SettingTable.Vampires || SettingTable.Mans 
	var Image = IsVampire(GetPlayerID()) && Images.Vampires || Images.Mans 
	var classSetting = ClassesSetting[GetClassHero()];    
	var number;
	var Levels = [];
	for (var vehicle in SettingTable.levels) 
		Levels.push(SettingTable.levels[vehicle]);
	if (GetClassHero() == -1) return;
	Levels.reverse();
	for (i=1;i<=3;i++){
		number = 0;   
		lvl = 0;   
		var Panel = MainPanel.FindChild('HeroUpgrade' + i) 
		Panel.FindChild('HeroUpgradeLabel').text = $.Localize('HeroUpgrade_' + GetClassHero() + "_" + i) 
		if (classSetting && classSetting[i] !== 'locked'){
			var info = classSetting[i];
			Panel.enabled = true;
			Panel.hittest = true;			
			var sortable = [];
			for (var vehicle in info) 
				sortable.push(info[vehicle]);
			sortable.reverse();    
			_.each(Panel.Children(),function(child){
				UnHiddenPanel(child);
				if (child.id.match('HeroUpgradeLevel')){
					if (lvl >= 4) lvl = 0; 
					_.each(child.Children(),function(childs){
						if (childs.id.match("HeroUpgrade_")){
							var title = sortable[number].replace('_',"_" + i + "_" + GetClassHero() + "_"); 
							AllPanels[title] = child;
							var lvls = Levels[lvl];
							var IiD = i;
							var data = {   
								UpgradeName:title,
							}
							childs.UpgradeName = title;    
							var texture = Image[GetClassHero()][i][sortable[number]];
							childs.SetImage(TransformTextureToPath(texture == "HeroIcon"
								? (Game.GetLocalPlayerInfo().player_selected_hero) 
								: ("customImages/" + texture),texture == "HeroIcon" ? 'icon' : "AbilityRaw")) 
							childs.SetPanelEvent( "onmouseover", function(){
										$.DispatchEvent("UIShowCustomLayoutParametersTooltip", childs, "UpgradeTooltip", 
									"file://{resources}/layout/custom_game/tooltips/test_tooltip.xml", 'Level='+ lvls + '&Name=' + title + '&PanelName=' + child.id + '&Ability=' + texture);
							});  
							childs.SetPanelEvent( "onmouseout",function() { 
								$.DispatchEvent("UIHideCustomLayoutTooltip", childs, "UpgradeTooltip");
							});	
							childs.SetPanelEvent( "onactivate",OnactivateChilds(child,childs,IiD,lvls,data));
							number++;
							if (number >= 8) number = 0;
						}
					});
					lvl++;
				}
			});
		}else{
			Panel.enabled = false;
			Panel.hittest = false;
			_.each(Panel.Children(),function(childs){
				HidePanel(childs);
			});
		}
	}
} 

function OnactivateChilds(child,childs,IiD,lvls,data){
	return function(){
		if (IsUpgradePreviousPanels(child.id,child.GetParent()) || child.id == "HeroUpgradeLevel1"){
			if (Players.GetLevel(GetPlayerID()) >= lvls)
				DisabledPanelsByName(child.id,childs.id,'HeroUpgrade' + IiD);
			}
		data.IsLocked = Players.GetLevel(GetPlayerID()) >= lvls;
		data.IsNoUpgradePrevious = IsUpgradePreviousPanels(child.id,child.GetParent()) || child.id == "HeroUpgradeLevel1";
		GameEvents.SendCustomGameEventToServer('AddUpgradeClass', data )
	}
}
function IsUpgradePreviousPanels(PanelName,attachPanel){
	var r = false;
	 _.each(MainPanel.Children(),function(childs){
		 var lvl = childs.FindChildTraverse(PanelName).id.replace("HeroUpgradeLevel","");
		 var OldPanel = "HeroUpgradeLevel" + String((Number(lvl) == 1 && 2 || Number(lvl)) - 1);
		 _.each(attachPanel.FindChildTraverse(OldPanel).Children(),function(child){
		 	if (child.enabled == false && !IsHiddenPanel(childs.FindChildTraverse(OldPanel)))
		 		r = true
		 }) 
	});
	return r;
}  
/*
function DisabledPanelsByName(PanelName,childName,MainChild){
	var data = {}
	_.each(MainPanel.Children(),function(childs){
		if (childName && (childName === 'HeroUpgrade_1' || childName === 'HeroUpgrade_2') && PanelName === 'HeroUpgradeLevel3' ){
			var lvlChild = childName.replace("HeroUpgrade_","");  
			lvlChild = lvlChild == "1" && "3" || "1";
			var lvlPanel = PanelName.replace("HeroUpgradeLevel",""); 
			var NewPanel = "HeroUpgradeLevel" + String(Number(lvlPanel) + 1);
			var NewPanelChild1 = "HeroUpgrade_" + String(Number(lvlChild));  
			var NewPanelChild2 = "HeroUpgrade_" + String(Number(lvlChild) + 1);			
			childs.FindChildTraverse(NewPanel).FindChildTraverse(NewPanelChild1).enabled = false;
			childs.FindChildTraverse(NewPanel).FindChildTraverse(NewPanelChild2).enabled = false;
			data[childs.FindChildTraverse(NewPanel).FindChildTraverse(NewPanelChild2).UpgradeName] = true;
			data[childs.FindChildTraverse(NewPanel).FindChildTraverse(NewPanelChild1).UpgradeName] = true;
			if (MainChild && childs.id != MainChild && !IsHiddenPanel(childs)){
				_.each(childs.Children(),function(child){
					_.each(child.Children(),function(childes){
						if (childes.id.match("HeroUpgrade_")){
							//childes.enabled = false;
							data[childes.UpgradeName] = true;
						}
					});
				});
			}
		} 
		var OffPanel = childs.FindChildTraverse(PanelName);
		OffPanel.enabled = false;
	}); 
	if (LengthTable(data) > 0) 
	GameEvents.SendCustomGameEventToServer('LockedUpgrades', {data:data} );

function IsUpgradePreviousPanels(PanelName){
	var r = false;
	 _.each(MainPanel.Children(),function(childs){
		 var lvl = childs.FindChildTraverse(PanelName).id.replace("HeroUpgradeLevel","");
		 var OldPanel = "HeroUpgradeLevel" + String((Number(lvl) == 1 && 2 || Number(lvl)) - 1);
		 if (childs.FindChildTraverse(OldPanel).enabled == true && !IsHiddenPanel(childs.FindChildTraverse(OldPanel))){
			 r = true;
		 }
	});
	return !(r || false);
}  
} 
*/
function DisabledPanelsByName(PanelName,childName,MainChild){
	var data = {}
	_.each(MainPanel.Children(),function(childs){
		if (childName && (childName === 'HeroUpgrade_1' || childName === 'HeroUpgrade_2') && PanelName === 'HeroUpgradeLevel3' ){
			var lvlChild = childName.replace("HeroUpgrade_","");  
			lvlChild = lvlChild == "1" && "3" || "1";
			var lvlPanel = PanelName.replace("HeroUpgradeLevel",""); 
			var NewPanel = "HeroUpgradeLevel" + String(Number(lvlPanel) + 1);
			var NewPanelChild1 = "HeroUpgrade_" + String(Number(lvlChild));  
			var NewPanelChild2 = "HeroUpgrade_" + String(Number(lvlChild) + 1);			
			childs.FindChildTraverse(NewPanel).FindChildTraverse(NewPanelChild1).enabled = false;
			childs.FindChildTraverse(NewPanel).FindChildTraverse(NewPanelChild2).enabled = false;
			data[childs.FindChildTraverse(NewPanel).FindChildTraverse(NewPanelChild2).UpgradeName] = true;
			data[childs.FindChildTraverse(NewPanel).FindChildTraverse(NewPanelChild1).UpgradeName] = true;
			if (MainChild && childs.id != MainChild && !IsHiddenPanel(childs)){
				_.each(childs.Children(),function(child){
					_.each(child.Children(),function(childes){
						if (childes.id.match("HeroUpgrade_")){
							childes.enabled = false;
							data[childes.UpgradeName] = true;
						}
					});
				});
			}
		} 
		if (MainChild && childs.id != MainChild && !IsHiddenPanel(childs)){
			if (MainChild && childs.id != MainChild && !IsHiddenPanel(childs)){
				_.each(childs.Children(),function(child){
					_.each(child.Children(),function(childes){
						if (childes.id.match("HeroUpgrade_")){
							childes.enabled = false;
							data[childes.UpgradeName] = true;
						}
					});
				});
			}
			//childs.enabled = false;
		}
		var OffPanel = childs.FindChildTraverse(PanelName);
		OffPanel.enabled = false;
	}); 
	var panel = MainPanel.FindChild(MainChild) && 
	MainPanel.FindChild(MainChild).FindChild(PanelName) && 
	MainPanel.FindChild(MainChild).FindChild(PanelName).FindChild(childName);
	if (!panel) return 
	data[panel.UpgradeName] = true;
	panel.enabled = false;
	if (LengthTable(data) > 0) 
	GameEvents.SendCustomGameEventToServer('LockedUpgrades', {data:data} );
}    
function EnabledAllPanels(){
	_.each(MainPanel.Children(),function(childs){
		if (!IsHiddenPanel(childs))
		_.each(childs.Children(),function(child){
			_.each(child.Children(),function(childes){
				childes.enabled = true
				childes.ActivateDisable = false
			});
		});  
	});
}

function DisablePanelByTitle(title){ 
	_.each(MainPanel.Children(),function(childs){
		if (!IsHiddenPanel(childs))
		_.each(childs.Children(),function(child){
			_.each(child.Children(),function(childes){
				if (childes.UpgradeName == title)
					childes.enabled = false;
			});
		});
	});
}  
function Update(){ 
	EnabledAllPanels();
	UpdateAllPanels();  
	var ClassesUpgradeSaves = PlayerTables.GetTableValue('UpgradeHeroSetting','SavesUpgrades');
	var LockedClasses = PlayerTables.GetTableValue('UpgradeHeroSetting','LockedUpgrade');
	if (UpdateCount < 1){
		UpdateCount++;
		RegisterKeyBind("LearnStats", ToggleHeroUpgradePanel);
	}

	if (ClassesUpgradeSaves[GetPlayerID()]){  
		for (var name in ClassesUpgradeSaves[GetPlayerID()]){
			var panel = AllPanels[name]
			if (panel && OldClass !== GetClassHero())
				DisabledPanelsByName(panel.id)
		} 
	} 	       
	if (LockedClasses[GetPlayerID()]){ 
		for (var name in LockedClasses[GetPlayerID()]){
			DisablePanelByTitle(name)
		}
	}
	OldClass = GetClassHero();
	var classIcon = FindDotaHudElement("ClassIcon");
	if (classIcon) {
		classIcon.SetPanelEvent('onactivate',function() {
			ToggleHeroUpgradePanel();
		})
		var text = $.Localize('heroupgrade_icon_description').replace('{key}',GameUI.CustomUIConfig().GetKeyBind('LearnStats'))
		classIcon.SetPanelEvent('onmouseover',ShowText(classIcon,text));
		classIcon.SetPanelEvent('onmouseout',HideText());
	}
}  

function ToggleHeroUpgradePanel(){
	if (IsHiddenPanel(MainPanel)){
		UnHiddenPanel(MainPanel)
		HidePanel(FindDotaHudElement("RequestPanel"));
		HidePanel(FindDotaHudElement("CustomShopList"));
	}
	else
		HidePanel(MainPanel)
}

(function(){    
	HidePanel(MainPanel); 
	if (Game.GetPlayerInfo(Game.GetLocalPlayerInfo().player_id).player_selected_hero != ForcePick)
		Update();
	GameEvents.Subscribe('UpdateUpgradeHero',Update);

		GameUI.SetMouseCallback(function (eventName, arg) {
		if (GameUI.GetClickBehaviors() == CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE) {
			if (eventName == "pressed" && !IsHiddenPanel(MainPanel)) {
				var cursorPos = GameUI.GetCursorPosition();
				if (cursorPos[0] < MainPanel.actualxoffset ||
					(MainPanel.actualxoffset + MainPanel.contentwidth) < cursorPos[0] ||
					cursorPos[1] < MainPanel.actualyoffset ||
					(MainPanel.actualyoffset + MainPanel.contentheight) < cursorPos[1]) {
					ToggleHeroUpgradePanel();
				} 
			}
		}
		return false;
	});
	
})(); 