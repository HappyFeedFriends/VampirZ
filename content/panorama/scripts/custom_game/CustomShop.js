var MainPanel = FindDotaHudElement('CustomShopList');
var VampireShop = MainPanel.FindChildTraverse('CustomShopVampire');

var ManShop = MainPanel.FindChildTraverse('CustomShopMan');
var MainPanelUpgrade = MainPanel.FindChildTraverse('CustomShopUpgrades');
var MainPanelAll = MainPanel.FindChildTraverse('CustomShopAll');
var ItemsCost = CustomNetTables.GetTableValue( "Shops", "ItemCost" ); 
var SearchingFor; 
          
function FillTypeShop(ShopData,panels){
	var Panel,cost;
	var i = 1;
	if (!panels) return
	for (var type in ShopData){
		Panel = panels.FindChild( type );
		if ( !Panel )
		{   
			Panel = $.CreatePanel( "Panel", panels, type );  
			Panel.SetHasClass( "MainShopPanel", true );         
		}
		for ( var ItemName in ShopData[type] ){  
			cost = ShopData[type][ItemName] && !ShopData[type][ItemName] == 0;
			if (cost){  
				var ItemPanel = Panel.FindChild( ShopData[type][ItemName] );		
				if ( !ItemPanel )
				{ 
					ItemPanel = $.CreatePanel( "Button", Panel, ShopData[type][ItemName] );  
					ItemPanel.SetHasClass( "CustomShopItem", true );
					ItemPanel.data = {
						PlayerId: Game.GetLocalPlayerInfo().player_id,
						ItemName: ShopData[type][ItemName],
					}; 
					UpdateItemPanelByCost(ItemPanel);
					var ItemPanelImage = $.CreatePanel( "DOTAItemImage", ItemPanel, 'Image' );  
					ItemPanelImage.itemname = ShopData[type][ItemName];
					ItemPanel.SetPanelEvent( "oncontextmenu", BuyItem( ItemPanel ) );
				}
			}
		}
	}
}
function FillUpgrade(Main){
	var Panel = Main.FindChild( 'Upgrade1' );
		if ( !Panel )
		{   
			Panel = $.CreatePanel( "Panel", Main, 'Upgrade1' );  
			Panel.SetHasClass( "MainShopPanel", true );        
		}
}
function FillShop(){
	FillTypeShop(CustomNetTables.GetTableValue( "Shops", "Vampire" ),VampireShop)
	FillTypeShop(CustomNetTables.GetTableValue( "Shops", "Mans" ),ManShop)
}

function UpdateItemPanelByCost(itemPanel){
	if (itemPanel) {
		var gold = IsVampire(GetPlayerID()) && GetBlood(GetPlayerID()) || GetGold(GetPlayerID());
		itemPanel.SetHasClass("BuyingItem",gold >= ItemsCost[itemPanel.id])
	}
} 
 function SearchItems(){
	 var searchStr  = MainPanel.FindChildTraverse("SearchTextEntry").text; 
	 var ShopSearch = IsVampire(GetPlayerID()) && VampireShop || ManShop;
	 if (searchStr  !== SearchingFor){
		SearchingFor = searchStr; 
		if (SearchingFor.length > 0){
			_.each(ShopSearch.Children(),function(child) {
				if (child){
					_.each(child.Children(),function(childs) {
						var localize = $.Localize("Dota_tooltip_ability_" + childs.id).toLowerCase();
						
						if (!localize.match(SearchingFor.toLowerCase())) 
							HidePanel(childs);
						else
							UnHiddenPanel(childs);
					});
					if (IsAllChildrenHide(child))
						HidePanel(child);
					else
						UnHiddenPanel(child);				
				}
			}); 
		}else{
			_.each(ShopSearch.Children(),function(child) {
				if (IsHiddenPanel(child))
				UnHiddenPanel(child)
				_.each(child.Children(),function(childs) {
					if (IsHiddenPanel(childs))
					UnHiddenPanel(childs)
				}); 
			}); 
		}
	}
 }

function UpdateItems(){
	var ShopSearch = IsVampire(GetPlayerID()) && VampireShop || ManShop;
	_.each(ShopSearch.Children(),function(child) {
		_.each(child.Children(),function(childs) {
			UpdateItemPanelByCost(childs);
		}); 
	});
}  
 
function SelectShopTab(Panel) { 
	var n = Panel === "GridBasicTab" && "GridModeUpgradesTab" || "GridBasicTab";
	Panel = $.GetContextPanel().FindChildTraverse(Panel);
	Panel.style.backgroundColor = "#57646d77;";
	Panel.FindChildTraverse("ButtonShop").style.color = "white";
	//$.GetContextPanel().FindChildTraverse(n).style.backgroundColor = "black";
	//$.GetContextPanel().FindChildTraverse(n).FindChildTraverse("ButtonShop").style.color = "#5b6872";
	//HidePanel(Panel.id === "GridBasicTab" && MainPanelUpgrade || MainPanelAll);
	//UnHiddenPanel(Panel.id === "GridModeUpgradesTab" && MainPanelUpgrade || MainPanelAll); 
}

function DataChange(){
	if (FindDotaHudElement('CustomShopButton')){
		var playerID = GetPlayerID();
		UpdateButtonShopLabel(playerID);
		UpdateItems(); 
		FindDotaHudElement('CustomShopButton').GetParent().FindChildTraverse('ClassIcon').SetImage(IsVampire(playerID) && 'file://{images}/custom_game/custom_icon/blood.png' || 
		'file://{images}/custom_game/custom_icon/UpgradeButton.png')
	}
}

 function AutoUpdate(){
	$.Schedule(0.1, AutoUpdate);
	SearchItems();
	if (IsVampire(GetPlayerID())){
		UnHiddenPanel(VampireShop);
		HidePanel(ManShop);
	}else{
		UnHiddenPanel(ManShop);
		HidePanel(VampireShop);
	}
} 
    
function UpdateButtonShopLabel(pID){
	 var GoldLabel = FindDotaHudElement('CustomShopButton').FindChildTraverse('CustomShopButtonLabel');
	GoldLabel.text = " <font color='"+ (IsVampire(pID) && 'red' || 'gold') +"'>" + FormatGold((IsVampire(pID) && GetBlood(pID) || GetGold(pID))) + "</font> <img class='" + (IsVampire(pID) && 'BloodIcons' || 'GoldIcons') +"' /> ";
	var CostLabel = FindDotaHudElement("BuyCostLabel");
	var ItemCostIcon = FindDotaHudElement("ItemCostIcon"); 
	if (ItemCostIcon)
		ItemCostIcon.style.backgroundImage =  IsVampire(pID) && "url('file://{images}/custom_game/custom_icon/blood.png')" || "url('s2r://panorama/images/hud/icon_gold_psd.vtex')";
	if (CostLabel)
		CostLabel.style.color = IsVampire(pID) && "#FF0000" || "#FFCC33";
}

function HiddenButtonShop(){
	HidePanel(FindDotaHudElement("quickbuy"))
	HidePanel(FindDotaHudElement("shop_launcher_bg"))	
	//HidePanel(FindDotaHudElement("shop"))	
	HidePanel(FindDotaHudElement("stash_bg"))
	HidePanel(FindDotaHudElement("StatBranch")); 
	HidePanel(FindDotaHudElement("statbranchdialog")); 
	HidePanel(FindDotaHudElement("level_stats_frame")); 
}

function OpenShop(){
	var shop = FindDotaHudElement('CustomShopList');
	if (IsHiddenPanel(shop)){
		UnHiddenPanel(shop);
		HidePanel(FindDotaHudElement("RequestPanel"));
		HidePanel(FindDotaHudElement("HeroUpgradeMain"));
	}
	else
		HidePanel(shop);
}

function BuyItem(Panel){
	return function()
	{
		GameEvents.SendCustomGameEventToServer('BuyItem', Panel.data );
	}
}

(function(){      
	FillShop();
	HiddenButtonShop();
	PlayerTables.SubscribeNetTableListener('DataPlayer', DataChange);
	RegisterKeyBind('ShopToggle', OpenShop);
	AutoUpdate(); 
	HidePanel(MainPanel);
	DataChange();
	if (Players.GetTeam(Players.GetLocalPlayer()) == DOTA_TEAM_SPECTATOR)
		HidePanel(MainPanel);

})();