
function IsUpgradePreviousPanels(PanelName){
	var MainPanel = FindDotaHudElement('HeroUpgradeMain');
	var lvl = PanelName.replace("HeroUpgradeLevel","");
	var OldPanel = "HeroUpgradeLevel" + ((lvl == 1 && 2 || lvl) - 1);
	return MainPanel.FindChildTraverse(OldPanel).enabled == false;
}

function LocalizationChange(text,change){  
	var newText = $.Localize(text);
	newText = UpdateLocalizeText(newText,function(count){
		return count % 2 ? 'orange' : 'red'
	});
	while (newText.match('{ability}'))
		newText = newText.replace('{ability}',"<font color='" + (IsVampire(GetPlayerID()) && "red" || "orange") + "'>" + $.Localize("Dota_tooltip_ability_" + change) + "</span></font>");
	return newText;
}

function setupTooltipSpecialUpgrade(){		  
	var Level = $.GetContextPanel().GetAttributeString("Level", "not found")
	var UpgradeName = $.GetContextPanel().GetAttributeString("Name", "not found")
	var PanelName = $.GetContextPanel().GetAttributeString("PanelName", "not found")
	var AbilityUpgradeName = $.GetContextPanel().GetAttributeString("Ability", "not found")
	var color = Players.GetLevel( GetPlayerID() ) >= Number(Level) && IsUpgradePreviousPanels(PanelName) &&  "orange" || "white";
	$("#Level").text = $.Localize('Level') + ": "  + Level;
	$("#Level").style.color = color;
	$("#Title").text = $.Localize(UpgradeName);
	$("#Description").text = LocalizationChange(UpgradeName + "_description",AbilityUpgradeName);
}

function SetupTooltipProfile(){	
	var SteamID = $.GetContextPanel().GetAttributeString("SteamID", "not found")
	$("Avatar").steamid = SteamID;
}