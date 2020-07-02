class X2Item_Ammo extends X2Item;

var localized string strDodgeReduction;
var localized string strDefenseReduction;
var localized string strSquadsightPenaltyReduction;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_Ammo_Sabot());

	return Templates;
}

static function X2DataTemplate Create_Ammo_Sabot()
{
	local X2AmmoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2AmmoTemplate', Template, 'IRI_Ammo_Sabot');

	Template.strImage = "img:///IRIRestorativeMist.UI.UI_SabotAmmo";

	Template.EquipSound = "StrategyUI_Ammo_Equip";
	Template.CanBeBuilt = false;
	Template.TradingPostValue = 30;
	Template.PointsToComplete = 0;
	Template.Tier = 1;
	Template.RewardDecks.AddItem('ExperimentalAmmoRewards');

	Template.Abilities.AddItem('IRI_Ammo_Sabot_Ability');

	Template.SetUIStatMarkup(default.strSquadsightPenaltyReduction,, int(class'X2Effect_SabotAmmo'.default.CounterSquadsightPenalty * 100),, "%");
	Template.SetUIStatMarkup(default.strDefenseReduction,, int(class'X2Effect_SabotAmmo'.default.CounterDefense * 100),, "%");	
	Template.SetUIStatMarkup(default.strDodgeReduction,, int(class'X2Effect_SabotAmmo'.default.CounterDodge * 100),, "%");	
		
	//FX Reference
	Template.GameArchetype = "IRIRestorativeMist.Projectiles.PJ_Sabot";
	
	return Template;
}