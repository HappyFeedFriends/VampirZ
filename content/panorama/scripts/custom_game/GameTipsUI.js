// Disabled
var TitleLabel = FindDotaHudElement("GameTipsTitle");
var DescriptionLabel = FindDotaHudElement("GameTipsDescription");
var GameTipsMainPanel = FindDotaHudElement("GameTipsUI_Main");
var d = {
	TitleText:"TipsMain",
	DescriptionText:"{description} {tips}",
	duration:20,
	DescriptionVariable: {
		"{tips}": 1212121,
	},
	Button:{
		"{description}":{
			Class:'GameTipsButton',
			Image:'s2r://panorama/images/custom_game/custom_icon/blood.png',
			color:'red',
		}
	}, 
} 
 function RefreshingDescription(data,type){
	 var text = $.Localize(data.DescriptionText)
	 if (data.DescriptionVariable){
		 for (var k in data.DescriptionVariable) {
			text = text.replace(k, $.Localize(data.DescriptionVariable[k]));
		}
	 }	
	 if (data.Button){
		 for (var k in data.Button) {
			if (data.Button[k]){ 
				newClass = "<img src='"+ data.Button[k].Image +"' class='"+ data.Button[k].Class || 'GameTipsButton' +"'/> <font color="+ data.Button[k].color || 'red' +"></font>"
				text = text.replace(k,newClass);
			}
		}
	 }
	 return text;
 }
function CreateCustomTips(data){
	if (IsHiddenPanel(GameTipsMainPanel)){
		UnHiddenPanel(GameTipsMainPanel);
		GameTipsMainPanel.RemoveClass("AnimationClass2"); 
		GameTipsMainPanel.AddClass("AnimationClass1");
	} 
	DescriptionLabel.text = RefreshingDescription(data);
	TitleLabel.text = $.Localize(data.TitleText || "GameTips");
	$.Schedule(data.duration, function() {
		GameTipsMainPanel.RemoveClass("AnimationClass1");    
		GameTipsMainPanel.AddClass('AnimationClass2'); 
		$.Schedule(0.44, function() {
		HidePanel(GameTipsMainPanel);   
		});
	});
}

(function (){
	HidePanel(GameTipsMainPanel);
	CreateCustomTips(d);
})();


