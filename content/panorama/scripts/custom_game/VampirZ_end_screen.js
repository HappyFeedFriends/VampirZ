var MainPanel = $.GetContextPanel().FindChildTraverse("EndScreenPanel");
var TeamPanel = MainPanel.FindChildTraverse('TeamPanel');

function SnippetPanel(){
	TeamPanel.RemoveAndDeleteChildren(); 
	UnHiddenPanel(TeamPanel);
	UnHiddenPanel(MainPanel.FindChildTraverse('Title')); 
	HidePanel(MainPanel.FindChildTraverse('LoadingPanel'));
	Game.GetAllPlayerIDs().forEach(function(PlayerID){ 
		if (Game.GetPlayerInfo(PlayerID).player_connection_state != 1){
			var table =  CustomNetTables.GetTableValue("game_state_end", String(PlayerID)) || {};
			var IsLocalPlayer = PlayerID == GetPlayerID();
			var playerInfo = Game.GetPlayerInfo(PlayerID);
			var IsWin = table['IsWin'];
			var RankString;
				if (typeof table['Rank'] === 'number') {
					if (typeof table['OLD_Rank'] === 'number') {
						var delta = table['Rank'] - table['OLD_Rank'];
						RankString = delta < 0 ?
							'<font color="lime">' + delta + '</font>' :
							delta > 0 ? '<font color="red">+' + delta + '</font>' : '';
						RankString = table['OLD_Rank'] + ' ' + RankString;
					} else RankString = 'TBD -> ' + table['Rank'];
				} else RankString = 'TBD';
				var mmrString;
				if (typeof table['MMR'] === 'number') {
					if (typeof table['OLD_MMR'] === 'number') {
						var delta = table['MMR'] - table['OLD_MMR'];
						mmrString = delta > 0 ?
							'<font color="lime">+' + delta + '</font>' :
							delta < 0 ? '<font color="red">' + delta + '</font>' : '±0';
						mmrString = table['OLD_MMR'] + ' (' + mmrString + ')';
					} else mmrString = 'TBD -> <font color="lime">' + table['MMR'] + '</font>';
				} else mmrString = 'TBD';
				var panel = $.CreatePanel('Panel', TeamPanel, '');
				panel.BLoadLayoutSnippet('Player');   
				panel.SetHasClass('IsLocalPlayer', true); //1e90ff
				panel.style.blur = "gaussian( 0 )";
				panel.FindChildTraverse('UserName').steamid = playerInfo.player_steamid;
				panel.FindChildTraverse('Avatar').steamid = playerInfo.player_steamid;
				panel.FindChildTraverse('deaths').text = Players.GetDeaths( PlayerID );
				panel.FindChildTraverse('assistance').text = Players.GetAssists( PlayerID );
				panel.FindChildTraverse('kills').text = Players.GetKills( PlayerID );
				panel.FindChildTraverse('GlobalRank').text = RankString;
				panel.FindChildTraverse('durationLife').text = table['LifeDuration']  ? secondsToMS(table['LifeDuration'],true) : "-";
				panel.FindChildTraverse('rating').text = mmrString;
				panel.FindChildTraverse('Coin').text = table['Coin'] && table['Coin'] + "</font> <img class='CoinIcon' /> " || '';
				panel.index = PlayerID; 
				
				//if (GetPlayerID() == PlayerID){
					var xp = 0;
					var bonusxp = 1;
					var progressBar = panel.FindChildTraverse('StatusProgress')
					progressBar.max = 1;
					//progressBar.SetPanelEvent( "onmouseover", ShowText( progressBar, ('XP - ' + (xp + bonusxp)) ) );
					//progressBar.SetPanelEvent( "onmouseout", HideText() );
					progressBar.value = 1;
					progressBar.FindChildTraverse('xpBonus').text = progressBar.max; 
					//test(xp + bonusxp,progressBar); 
				//}
		};
	});
}
     
function test(max,progressBar){ 
	$.Msg(progressBar)
	//var progressBar = MainPanel.FindChildTraverse('StatusProgress')
	if (progressBar.value >= progressBar.max){
		progressBar.value = 0;
		max -= progressBar.max;
		$.Msg(max)
		var table = GetXpTable()
		level = level + 1;
		progressBar.max = table[GetLevelXp()] 
		progressBar.FindChildTraverse('xpBonus').text = progressBar.max;
	}
	progressBar.value = Math.min(progressBar.value + progressBar.max/100,max)
	if (progressBar.value < max)
		$.Schedule(1/30,function(){
				test(max,progressBar);
		});
}

(function(){
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false );
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME_CHAT, false );
	HidePanel(TeamPanel);
	HidePanel(MainPanel.FindChildTraverse('Title')); 
	//SnippetPanel()
	$.Schedule(5,function(){
		if (!IsHiddenPanel(TeamPanel))
			MainPanel.FindChildTraverse('LoadingMessage').text = "connection error";
	})   
	CustomNetTables.SubscribeNetTableListener("game_state_end",SnippetPanel);
})();