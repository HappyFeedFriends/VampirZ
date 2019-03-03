var RequestPanel = $.GetContextPanel().FindChildTraverse("RequestPanel"); // MAIN
var MainPanel = $.GetContextPanel().FindChildTraverse("PlayerProfile");
var UserProfile = MainPanel.FindChildTraverse("UserProfileMain");
var RankingList = MainPanel.FindChildTraverse("RatingList");
var FriendRanks = RankingList.FindChildTraverse("FriendsRating");
var GlobalRanks = RankingList.FindChildTraverse("GlobalRating");
var TopBarButton = $.GetContextPanel().FindChildTraverse("PlayerProfileTopBar");
var RatingRanksPanels = GlobalRanks.FindChildTraverse("ratingRanks");
var RatingUsersPanels = GlobalRanks.FindChildTraverse("ratingUsers");
var RatingMMRsPanels = GlobalRanks.FindChildTraverse("ratingMMR");
var GameBox = UserProfile.FindChildTraverse("PlayerGamesBox");
  
 var MMRtexture = {
	0:"rank0",
	1000:"rank1",
	1600:"rank2",
	2100:"rank3",  
	2600:"rank4",   
	3200:"rank5",
	4000:"rank6",
	5000:"rank7",
} 
var ItemList = {
	// DK	
	//20480: 220,
	//20550: 320,	
	//20480: 220,
	//20863: 300,
	//20986: 390,
	//21174: 750,
	//21092: 1000,

	// LifeStealer
	20499: 320,
	21089: 360,
	20431: 450,
	9215:  550,
	20706: 550,
	//9199: 450, -- Bonus

	// Sniper
	20321: 270,
	20819: 250,
	21024: 210,
	20899: 350,
	21087: 440,
	21164: 650,
	9197:  1000,
	9455:  450,
	// Night Stalker
	21230: 800,
	21055: {styles:2,cost:450,},

	// OmnikNight 
	20066:320,
	20643:320,
	21064:450,
	20646:330,
	20787:320,
	21152:{styles:2,cost:440,},
	20046:330,
};

function ToggleProfile(){
	if (IsHiddenPanel(RequestPanel)){
		UnHiddenPanel(RequestPanel);
		HidePanel(FindDotaHudElement("CustomShopList"));
		HidePanel(FindDotaHudElement("HeroUpgradeMain")); 
	}
	else 
		HidePanel(RequestPanel);
} 
 
function UpdateButtonTopBar(){
	_.each(TopBarButton.Children(),function(child) {
	var id = child.id;
	child.SetPanelEvent("onactivate", function(){
			//if (id == "Button4") return;
			var name = id == "Button1" && "UserProfileMain"  || 
			id == "Button2" && "RatingList" || 
			id == "Button3" && "ModelShop" || 
			id == "Button4" && "News" || "RequestPanel";
			if (name == "RequestPanel"){
				HidePanel(RequestPanel);
				return;
			} 
			/*if (name != 'ModelShop')
				MainPanel.FindChildTraverse("ModelShopContainer").RemoveAndDeleteChildren()
			else
				UpdateModelShop();
			*/
			if (IsHiddenPanel(MainPanel.FindChildTraverse(name)) == false) return; 
			_.each(MainPanel.Children(),function(childs){
				var id = childs.id;	
				// Animation
				if (id != "PlayerProfileTopBar")
					if (id != name)
						HidePanel(childs);
					else{
						var classPanel = id == "UserProfileMain" && 'SwapRightProfile' || 'SwapLeftRating';
						childs.AddClass(classPanel);
							UnHiddenPanel(childs);
						$.Schedule(0.7,function(){
							childs.RemoveClass(classPanel);
						});
					}
			});
		});
	});
	var panelNo = MainPanel.FindChildTraverse("NoBuyItem")
	panelNo.SetPanelEvent("onactivate", function(){
		HidePanel(MainPanel.FindChildTraverse("IsBuyItem"));
	});
}
// Page: User Profile 
function UpdateProfileList(){
	var tableUser = GetDataServer();
	var SteamID = Game.GetLocalPlayerInfo().player_steamid;
	var MMR = tableUser["MMR"] || 'TBD'; 
	var Rank = tableUser["Rank"] || 'TBD';  
	var data = tableUser["data"] || {}; 
	var texture = Rank <= 10 && "rank8c" || 
	Rank <= 100 && "rank8b" ||
	Rank <= 1000 && "rank8" || tableUser['MMR'] == "TBD" && "pip_empty" || 
	nearestOrLowerKey(MMRtexture,Number(tableUser['MMR'])) || "pip_empty";
	UserProfile.FindChildTraverse("UserAvatar").steamid = SteamID;
	UserProfile.FindChildTraverse("UserName").steamid = SteamID;
	UserProfile.FindChildTraverse("UserMMR").text = "MMR: " + MMR;
	UserProfile.FindChildTraverse("PlaceRanking").text = Rank;
	UserProfile.FindChildTraverse("RankingInfoImage").style.backgroundImage = "url('file://{images}/rank_tier_icons/" + texture + ".psd')"; 
	UserProfile.FindChildTraverse("RankUserTextMedal").text = Rank <= 1000 ? Rank : "";
	_.each(UserProfile.FindChildTraverse("StatsList").Children(),function(childs){
		childs.FindChildTraverse("ProfileStat").style.opacity = "1";
		childs.FindChildTraverse("ProfileStat").style.color = "#FF943FFF";
		childs.FindChildTraverse("ProfileStat").text = data[childs.id] || 0;
	}); 
	MainPanel.FindChildTraverse('VCoinValue').text = $.Localize('countCoins').replace('{coins}',tableUser.Coin);
	var image1 = MainPanel.FindChildTraverse('VCoinValue').Children()[0]
	image1.SetImage("s2r://panorama/images/custom_game/custom_icon/coin.png")
	UpdateModelShop();
	CreateItemList();    
	//var IsWin = true
	//var detalisBox = GameBox.FindChildTraverse("Details")
	//detalisBox.FindChildTraverse("HeroName").text = $.Localize(Game.GetLocalPlayerInfo().player_selected_hero)
	//detalisBox.FindChildTraverse("HeroMovie").heroname = Game.GetLocalPlayerInfo().player_selected_hero
	//detalisBox.FindChildTraverse("classGame").text = $.Localize(GetClassHero()); 
	//detalisBox.FindChildTraverse("map").text = $.Localize("vampirz_dark_forest");
	//detalisBox.FindChildTraverse("kda").text = "5 / 8 / 10";
	//detalisBox.FindChildTraverse("duration").text = "24:32";
	//HidePanel(detalisBox.FindChildTraverse(IsWin ? "Loss" : "Win"));
	//UnHiddenPanel(detalisBox.FindChildTraverse(IsWin ? "Win" : "Loss"));
	//detalisBox.FindChildTraverse("Date").text = "14.01.19";
	//detalisBox.FindChildTraverse("Time").text = "23:54";	
}

function CreateItemList(table){
	var itemContainer = UserProfile.FindChildTraverse('ItemContainer')
	itemContainer.RemoveAndDeleteChildren();
	table = table || GetDataServer().ItemList;
	for (itemdef in table) { 
		var itemModel = itemContainer.FindChild('EconDef_' + itemdef) || $.CreatePanel( "Panel", itemContainer, 'EconDef_' + itemdef );
		var styles = table[itemdef];    
		itemModel.BLoadLayoutSnippet('ItemSlot');
		var itemModelMain = itemModel.FindChild('PlayerItemSlot');
		itemModelMain.stylesCustom = 1;
		$.DispatchEvent( 'DOTAEconSetPreviewSetItemDef', itemModel.FindChild('PlayerItemSlot'), itemdef, "", "", itemModelMain.stylesCustom, true, true );
		itemModel.SetPanelEvent("onactivate",OnClickItemModel(itemModelMain,itemdef));
		if (styles > 1){
			var ItemButtonRight = itemModel.FindChild('EconButtonStyleRight') || $.CreatePanel( "Button", itemModel, 'EconButtonStyleRight' );
			var ItemButtonLeft = itemModel.FindChild('EconButtonStyleLeft') || $.CreatePanel( "Button", itemModel, 'EconButtonStyleLeft' );
			ItemButtonLeft.AddClass('EconButton');
			ItemButtonRight.AddClass('EconButton');
			ItemButtonLeft.style.horizontalAlign = "Left";
			ItemButtonRight.style.horizontalAlign = "Right";
			ItemButtonLeft.style.backgroundImage = "url('s2r://panorama/images/control_icons/arrow_solid_left_png.vtex')";
			ItemButtonRight.style.backgroundImage = "url('s2r://panorama/images/control_icons/arrow_solid_right_png.vtex')";
			ItemButtonRight.SetPanelEvent( "onactivate", RightSwapModel(itemModelMain,itemdef,styles));			
			ItemButtonLeft.SetPanelEvent( "onactivate", LeftSwapModel(itemModelMain,itemdef,styles));
		}
	}
}

function OnClickItemModel(itemModel,ItemDef,random){
	return function(){
		GameEvents.SendCustomGameEventToServer('OnEquipItemWearable', {
			itemDef:ItemDef,
			style:itemModel.stylesCustom || 1,
		});
	}
}

function UpdateModelShop(){
	var ModelShop = MainPanel.FindChildTraverse("ModelShopContainer");
	var sortable = [];
	for (var vehicle in ItemList){
		sortable.push({
			ItemDef: vehicle,
			Value: typeof(ItemList[vehicle]) == "object" && ItemList[vehicle].cost || ItemList[vehicle],
		}); 	
	}
	sortable.sort(function(a,b){
		if (a.Value > b.Value) return 1;
		if (a.Value < b.Value) return -1;
	})
	var heroImageXML = '<DOTAUIEconSetPreview allowrotation="false" id="EconDef" class="EconItem" hittest="true" />';
	var ItemNum = 0;   
	var panelRandom = ModelShop.FindChild('Item0') || $.CreatePanel( "Panel", ModelShop, 'Item0' );
	panelRandom.BCreateChildren(heroImageXML); 
	panelRandom.AddClass('EconPanel');
	panelRandom.FindChild('EconDef').style.brightness = 0.03;
	$.DispatchEvent( 'DOTAEconSetPreviewSetItemDef', panelRandom.FindChild('EconDef'), 7385, "", "", 1, true, true );	
	var buttomRandom = panelRandom.FindChild('RandomButton') || $.CreatePanel( "Panel", panelRandom, 'RandomButton' );
	var itemCostLabel = panelRandom.FindChild('EconCost') || $.CreatePanel( "Label", panelRandom, 'EconCost' );
	itemCostLabel.AddClass('EconCost');
	itemCostLabel.html = true;       
	itemCostLabel.text = 120 + "</font> <img class='CoinIcon' /> ";
	var image2 = itemCostLabel.Children()[0];
	image2.SetImage("s2r://panorama/images/custom_game/custom_icon/coin.png");
	buttomRandom.SetPanelEvent('onactivate',function(){
		var def = GetRandomDef();
		if (!IsHiddenPanel(MainPanel.FindChildTraverse("LoadingPanel")) || !IsHiddenPanel(MainPanel.FindChildTraverse("MainText"))) return;
		UnHiddenPanel(MainPanel.FindChildTraverse("IsBuyItem"))
			_.each(MainPanel.FindChildTraverse("IsBuyItem").Children(),function(child) {
				if (child.id == "IsBuyItems" || child.id == "ItemsButtons") UnHiddenPanel(child); else HidePanel(child);
			});
			MainPanel.FindChildTraverse("YesBuyItem").SetPanelEvent('onactivate',function(){
			GameEvents.SendCustomGameEventToServer('OnDressingItem', {
				itemDef:def,
				itemCost: 120,
				style: typeof(ItemList[def]) == "object" ? ItemList[def].styles : 1,
				styles:  typeof(ItemList[def]) == "object" ? ItemList[def].styles : 1,
				IsRandom: true,
			}); 
			_.each(MainPanel.FindChildTraverse("IsBuyItem").Children(),function(child) {
				if (child.id != "LoadingPanel") HidePanel(child); else UnHiddenPanel(child);
			});
		});
	});
	sortable.forEach(function(data){
		ItemNum++;  
		var itemCost = data.Value;
		var ItemDef = data.ItemDef; 
		var styles = typeof(ItemList[ItemDef]) == "object" ? ItemList[ItemDef].styles : 1;
		var panelItem = ModelShop.FindChild('Item' + ItemNum) || $.CreatePanel( "Panel", ModelShop, 'Item' + ItemNum );
		panelItem.AddClass('EconPanel');
		panelItem.BCreateChildren(heroImageXML); 
		var itemModel = panelItem.FindChild('EconDef') || $.CreatePanel( "DOTAEconItem", panelItem, 'EconDef' );
		itemModel.style.align = "center center"
		itemModel
		itemModel.stylesCustom = 1; 
		itemModel.SetPanelEvent('onactivate',function(){
			if (!IsHiddenPanel(MainPanel.FindChildTraverse("LoadingPanel")) || !IsHiddenPanel(MainPanel.FindChildTraverse("MainText"))) return;
			UnHiddenPanel(MainPanel.FindChildTraverse("IsBuyItem"))
			_.each(MainPanel.FindChildTraverse("IsBuyItem").Children(),function(child) {
				if (child.id == "IsBuyItems" || child.id == "ItemsButtons") UnHiddenPanel(child); else HidePanel(child);
			});
			MainPanel.FindChildTraverse("YesBuyItem").SetPanelEvent('onactivate',function(){
				GameEvents.SendCustomGameEventToServer('OnDressingItem', {
					itemDef:ItemDef,
					itemCost: itemCost,
					style: itemModel.stylesCustom,
					styles:  styles,

				});
				_.each(MainPanel.FindChildTraverse("IsBuyItem").Children(),function(child) {
					if (child.id != "LoadingPanel") HidePanel(child); else UnHiddenPanel(child);
				});
			});
		}); 
		$.DispatchEvent( 'DOTAEconSetPreviewSetItemDef', itemModel, ItemDef, "", "", itemModel.stylesCustom, true, true );	
		var itemCostLabel = panelItem.FindChild('EconCost') || $.CreatePanel( "Label", panelItem, 'EconCost' );
		itemCostLabel.AddClass('EconCost');
		itemCostLabel.html = true;       
		itemCostLabel.text = itemCost + "</font> <img class='CoinIcon' /> ";
		var image2 = itemCostLabel.Children()[0];
		image2.SetImage("s2r://panorama/images/custom_game/custom_icon/coin.png");
		if (GetDataServer()['ItemList'][ItemDef]){
			var IsBuy = panelItem.FindChild('AlreadyOwnedIcon') || $.CreatePanel( "Panel", panelItem, 'AlreadyOwnedIcon' );
			IsBuy.SetPanelEvent('onmouseover',ShowText(IsBuy,'#DOTA_StoreItem_AlreadyOwned'));
			IsBuy.SetPanelEvent('onmouseout',HideText()); 
		}
		if (styles > 1){
			var ItemButtonRight = panelItem.FindChild('EconButtonStyleRight') || $.CreatePanel( "Button", panelItem, 'EconButtonStyleRight' );
			var ItemButtonLeft = panelItem.FindChild('EconButtonStyleLeft') || $.CreatePanel( "Button", panelItem, 'EconButtonStyleLeft' );
			ItemButtonLeft.AddClass('EconButton');
			ItemButtonRight.AddClass('EconButton');
			ItemButtonLeft.style.horizontalAlign = "Left";
			ItemButtonRight.style.horizontalAlign = "Right";
			ItemButtonLeft.style.backgroundImage = "url('s2r://panorama/images/control_icons/arrow_solid_left_png.vtex')";
			ItemButtonRight.style.backgroundImage = "url('s2r://panorama/images/control_icons/arrow_solid_right_png.vtex')";
			ItemButtonRight.SetPanelEvent( "onactivate", RightSwapModel(itemModel,ItemDef,styles));			
			ItemButtonLeft.SetPanelEvent( "onactivate", LeftSwapModel(itemModel,ItemDef,styles));
		}  
	})
}
function LeftSwapModel(Model,itemSwap,max){
	return function(){
		Model.stylesCustom = Model.stylesCustom <= 1 ? max : (Model.stylesCustom  - (Model.stylesCustom  == 1 ? 0 : 1 ) );
		$.DispatchEvent( 'DOTAEconSetPreviewSetItemDef', Model, itemSwap, "", "", Model.stylesCustom, true, true );	
	}
}
function RightSwapModel(Model,itemSwap,max){
	return function(){
		Model.stylesCustom = max <= Model.stylesCustom   ? 1 : (Model.stylesCustom || 1) + 1;
		$.DispatchEvent( 'DOTAEconSetPreviewSetItemDef', Model, itemSwap, "", "", Model.stylesCustom, true, true );
	}
}

function GetRandomDef(){
	var length = LengthTable(ItemList);
	var RandomNumber = GetRandomInt(1, length);
	var q = 0;
	for (var num in ItemList){
		q++;
		if (q == RandomNumber)
			return num;
	}
}
function UpdateTopList(){
	var table = GetDataServer("TopRating")
	var length = LengthTable(table);
	var sortable = [];
	for (var vehicle in table){
		sortable.push({
			SteamID: vehicle,
			Value: Number(table[vehicle])});	
	}      
	sortable.sort(function(a,b){
		if (a.Value > b.Value) return -1;
		if (a.Value < b.Value) return 1;
	});	
	RatingUsersPanels.RemoveAndDeleteChildren();
	RatingRanksPanels.RemoveAndDeleteChildren();
	for (var i = 1;length >= i;i++){
		// Numbers 
		var ranks = RatingRanksPanels.FindChild( "ranks"+i ) || $.CreatePanel( "Label", RatingRanksPanels, "ranks"+i );
		ranks.text = i;
		// Users
		var userPanel = $.CreatePanel( "Panel", RatingUsersPanels, '' )
		userPanel.BLoadLayoutSnippet('Player'); 
		var userAvatar = userPanel.FindChild( "userAvatar" );
		var userName = userPanel.FindChild( "UserName" ); 
		userAvatar.steamid = sortable[i-1].SteamID;
		userName.steamid = sortable[i-1].SteamID; 
		// MMR
		var mmrPanel = RatingMMRsPanels.FindChild( "user"+i ) || $.CreatePanel( "Label", RatingMMRsPanels, "user"+i );
		mmrPanel.text = sortable[i-1].Value;
	}
	UpdateFriendsList();
} 
  
function UpdateNewsPanel(){
	var mainNews = MainPanel.FindChildTraverse('NewsColon')
	var q = 0; 
	UnHiddenPanel(MainPanel.FindChildTraverse('GlobalNewsIcon'));
	HidePanel(MainPanel.FindChildTraverse('MainPostPanel'))
	var dataNews = GetDataServer('News');
	var dataArray = []; 
	for (var vehicle in dataNews)
		dataArray.push(dataNews[vehicle]);	
	dataArray.forEach(function(data){
		q++;
		var dataByID = data; 
		var titleText = $.Language() == 'ukrainian' ? dataByID.uk : $.Language() == 'russians' ? dataByID.ru  : ($.Language() == "schinese" || $.Language() == "tchinese") ? dataByID.zh : dataByID.en; 
		var LabelText = $.Language() == 'ukrainian' ? dataByID.Labeluk : $.Language() == 'russians' ? dataByID.LabelRu : ($.Language() == "schinese" || $.Language() == "tchinese")? dataByID.Labelzh : dataByID.LabelEn; 
		var panel = mainNews.FindChild('News_' + q) || $.CreatePanel( "Image", mainNews, 'News_' + q );
		var TextLabelColon = panel.FindChild('TextLabelColon') || $.CreatePanel( "Label", panel, 'TextLabelColon' );
		var TextTitleColon = panel.FindChild('TextTitleColon') || $.CreatePanel( "Label", panel, 'TextTitleColon' );
		TextTitleColon.text = $.Localize('addon_game_name');
		TextLabelColon.text = LabelText;  
		panel.SetImage(dataByID.image);
		panel.SetPanelEvent('onactivate',function(){
			var postPanel = MainPanel.FindChildTraverse('MainPostPanel');
			var image = postPanel.FindChild('ImagePost');
			postPanel.FindChild('LabelPost').text = LabelText;
			image.SetImage(dataByID.image);
			postPanel.FindChild('TitlePost').text = titleText;
			var model = postPanel.FindChild('SetPost');
			HidePanel(model)
			if ( dataByID.ItemDef && dataByID.ItemDef != 0 ){ 
				$.DispatchEvent( 'DOTAEconSetPreviewSetItemDef', model, dataByID.ItemDef, "", "", 1, true, true );	
				UnHiddenPanel(model);
			} 
			UnHiddenPanel(postPanel);
			HidePanel(MainPanel.FindChildTraverse('GlobalNewsIcon'));
		});
	});

}
function UpdateFriendsList(){
	var tableUser = GetDataServer()
	tableUser.FriendList = tableUser.FriendList || {};
	tableUser.FriendList[String(Game.GetLocalPlayerInfo().player_steamid)] = tableUser["MMR"] 
	var sortable = []; 
	for (var vehicle in tableUser.FriendList){
		if (Number(tableUser.FriendList[vehicle]) != null && tableUser.FriendList[vehicle] != "TBD")
		sortable.push({
			SteamID: vehicle,
			Value: Number(tableUser.FriendList[vehicle])
		});	
	}
	sortable.sort(function(a,b){
		if (a.Value > b.Value) return -1;
		if (a.Value < b.Value) return 1;
	});	 
	var panel = FriendRanks.FindChildTraverse("ratingUsers") 
	var number = 0; 
	panel.RemoveAndDeleteChildren();
	FriendRanks.FindChildTraverse('rating').style.marginLeft ="130px";
	GlobalRanks.FindChildTraverse('rating').style.marginLeft ="35px";
	sortable.forEach(function(data){
		number++;
		var ranks = FriendRanks.FindChildTraverse("ratingRanks").FindChildTraverse( "ranks"+number ) || $.CreatePanel( "Label", FriendRanks.FindChildTraverse("ratingRanks"), "ranks"+number );
		var MMR = data.Value;
		var SteamID = data.SteamID;
		var panelUser = $.CreatePanel( "Panel", panel, '' )
		panelUser.BLoadLayoutSnippet('Player'); 
		var UserAvatar = panelUser.FindChildTraverse("userAvatar"); 		
		var UserName = panelUser.FindChildTraverse("UserName") || $.CreatePanel( "DOTAUserName", panelUser, "UserName" ); 
		var mainMMR = FriendRanks.FindChildTraverse("ratingMMR");
		var mmrPanel = mainMMR.FindChildTraverse( "friend"+number ) || $.CreatePanel( "Label", mainMMR, "friend"+number );
		mmrPanel.text = MMR; 
		ranks.text = number;
		UserName.steamid = SteamID;
		UserAvatar.steamid = SteamID;
	})
} 

function updateRequest() {
	UpdateTopList();  
	UpdateProfileList(); 
}

function WearableUpdate(data){
	var error = data.err;
	var IsBuy = data.IsBuy == 1; 
	var IsOldBuy = data.IsOldBuy == 1
	var coin = data.NewCoin
	var list = data.itemList 
	var IsRandomBuyError = data.IsRandomBuyError == 1
	HidePanel(MainPanel.FindChildTraverse('LoadingPanel'));
	var panel  = MainPanel.FindChildTraverse('MainText');
	panel.text = $.Localize(IsRandomBuyError
		? 'buy_ok_2'  //IsRandomBuyError
		: (error != null 
			? 'buy_error' 
			: (IsOldBuy 
				? 'buy_ok_2'
				: (IsBuy
					? 'buy_ok' 
					: 'buy_error_2'))));
	if ( error != null )
		panel.text = panel.text.replace('{error}',error);
	if ( coin != null) 
		MainPanel.FindChildTraverse('VCoinValue').text = $.Localize('countCoins').replace('{coins}',coin);
	if (IsBuy && !IsOldBuy && list) 
			CreateItemList(list)
	var image = MainPanel.FindChildTraverse('VCoinValue').Children()[0]
	image.SetImage("s2r://panorama/images/custom_game/custom_icon/coin.png")
	UnHiddenPanel(panel);
	$.Schedule(1,function(){
		HidePanel(panel.GetParent());
		HidePanel(panel)
	});

}    
function ReplaceIconModel(){
	$.Msg($('#IconModel').FindChild('SortScore'))
}

(function(){
	HidePanel(MainPanel.FindChildTraverse('MainText'));
	HidePanel(RequestPanel);
	HidePanel(MainPanel.FindChildTraverse('IsBuyItem'));
	HidePanel(MainPanel.FindChildTraverse("LoadingPanel")); 
	UnHiddenPanel(MainPanel.FindChildTraverse("IsBuyItems")); 
	UnHiddenPanel(MainPanel.FindChildTraverse("ItemsButtons")); 
	UpdateButtonTopBar();
	updateRequest();
	UpdateNewsPanel();
	$.Msg($('#buttonModel'))
	GameEvents.Subscribe('WearableUpdate', WearableUpdate);
	RegisterKeyBind("F2", ToggleProfile,true)
	//CustomNetTables.SubscribeNetTableListener("request",updateRequest)
	GameEvents.Subscribe('request', updateRequest);
	//MainPanel.FindChildTraverse('News1').SetImage('https://dota2.ru/img/uploads/19/02/1052536.jpg')
})();