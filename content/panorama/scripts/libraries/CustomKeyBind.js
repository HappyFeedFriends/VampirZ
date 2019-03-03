// Author: Ark120202
Game.Events = {};
var contextPanel = $.GetContextPanel();


function GetCommandName(name) {
	return 'VampirZ_' + name.toLowerCase().replace(/[^a-z]+/g, '_'); 
}
function GetKeyBind(name) {
	contextPanel.BCreateChildren('<DOTAHotkey keybind="' + name + '" />');
	var keyElement = contextPanel.GetChild(contextPanel.GetChildCount() - 1);
	keyElement.DeleteAsync(0);
	return keyElement.GetChild(0).text;
}
function RegisterKeyBindHandler(name) {
	Game.Events[name] = {};
	Game.AddCommand(GetCommandName(name), function() {
		for (var key in Game.Events[name]) {
			Game.Events[name][key]();
		}
	}, '', 0);
}

function RegisterKeyBind(name, callback,IsKey) {
	if (Game.Events[name] == null) {
		RegisterKeyBindHandler(name);
		var key = IsKey && name || GetKeyBind(name);
		if (key !== '') Game.CreateCustomKeyBind(key, GetCommandName(name));
	}
	Game.Events[name][callback.name] = callback;
};
 
GameUI.CustomUIConfig().RegisterKeyBind = RegisterKeyBind;
GameUI.CustomUIConfig().GetKeyBind = GetKeyBind;