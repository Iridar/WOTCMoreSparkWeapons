class X2Item_Ammo extends X2Item config(ArtilleryCannon);

var localized string strDodgeReduction;
var localized string strDefenseReduction;
var localized string strSquadsightPenaltyReduction;

var config bool bShowSpecialCannonShellsOnSparkBody;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_Ammo_Sabot());
	
	Templates.AddItem(Create_Shell_HEAT());
	Templates.AddItem(Create_Shell_HE());
	Templates.AddItem(Create_Shell_Shrapnel());

	Templates.AddItem(Create_Shell_HEDP());
	Templates.AddItem(Create_Shell_HESH());
	Templates.AddItem(Create_Shell_Flechette());

	Templates.AddItem(Create_Shells_T1());
	Templates.AddItem(Create_Shells_T2());

	return Templates;
}

//	===================================================================
//			SABOT AMMO
//	===================================================================

static function X2DataTemplate Create_Ammo_Sabot()
{
	local X2AmmoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2AmmoTemplate', Template, 'IRI_Ammo_Sabot');

	Template.strImage = "img:///IRIRestorativeMist.UI.UI_SabotAmmo";

	Template.EquipSound = "StrategyUI_Ammo_Equip";
	Template.CanBeBuilt = false;
	Template.Tier = 1;
	Template.RewardDecks.AddItem('ExperimentalAmmoRewards');

	Template.Abilities.AddItem('IRI_Ammo_Sabot_Ability');

	if (class'X2Effect_SabotAmmo'.default.CounterSquadsightPenalty > 0)
	Template.SetUIStatMarkup(default.strSquadsightPenaltyReduction,, int(class'X2Effect_SabotAmmo'.default.CounterSquadsightPenalty * 100),, "%");
	if (class'X2Effect_SabotAmmo'.default.CounterDefense > 0)
	Template.SetUIStatMarkup(default.strDefenseReduction,, int(class'X2Effect_SabotAmmo'.default.CounterDefense * 100),, "%");
	if (class'X2Effect_SabotAmmo'.default.CounterDodge > 0)
	Template.SetUIStatMarkup(default.strDodgeReduction,, int(class'X2Effect_SabotAmmo'.default.CounterDodge * 100),,  "%");

	Template.TradingPostValue = 30;
		
	Template.GameArchetype = "IRIRestorativeMist.Projectiles.PJ_Sabot";
	
	return Template;
}

//	===================================================================
//			SPECIAL HEAVY CANNON SHELLS
//	===================================================================

static function X2DataTemplate Create_Shell_HEAT()
{
	local X2WeaponTemplate Template;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_Shell_HEAT');
	
	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.ItemCat = 'utility';
	Template.WeaponCat = 'iri_auxiliary_weapon';
	Template.InventorySlot = class'X2StrategyElement_AuxSlot'.default.AuxiliaryWeaponSlot;
	Template.StowedLocation = eSlot_LeftBack;
	Template.NumUpgradeSlots = 0;
	
	Template.Tier = 1;
	
	Template.strImage = "img:///IRIArtilleryCannon.UI.Inv_Shell_HEAT";

	if (default.bShowSpecialCannonShellsOnSparkBody)
	Template.GameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Shells_HEAT";

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_HEAT_Passive');
	Template.Abilities.AddItem('IRI_Shell_HEAT_Passive');

	Template.HideIfResearched = 'IRI_ImprovedShells_Tech';

	return Template;
}

static function X2DataTemplate Create_Shell_HE()
{
	local X2WeaponTemplate Template;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_Shell_HE');

	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.ItemCat = 'utility';
	Template.WeaponCat = 'iri_auxiliary_weapon';
	Template.InventorySlot = class'X2StrategyElement_AuxSlot'.default.AuxiliaryWeaponSlot;
	Template.StowedLocation = eSlot_LeftBack;
	Template.NumUpgradeSlots = 0;
	
	Template.Tier = 1;
	
	Template.strImage = "img:///IRIArtilleryCannon.UI.Inv_Shell_HE";

	if (default.bShowSpecialCannonShellsOnSparkBody)
	Template.GameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Shells_HE";

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;

	Template.HideIfResearched = 'IRI_ImprovedShells_Tech';

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_HE_Passive');
	Template.Abilities.AddItem('IRI_Shell_HE_Passive');

	return Template;
}

static function X2DataTemplate Create_Shell_Shrapnel()
{
	local X2WeaponTemplate Template;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_Shell_Shrapnel');
	
	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.ItemCat = 'utility';
	Template.WeaponCat = 'iri_auxiliary_weapon';
	Template.InventorySlot = class'X2StrategyElement_AuxSlot'.default.AuxiliaryWeaponSlot;
	Template.StowedLocation = eSlot_LeftBack;
	Template.NumUpgradeSlots = 0;
	
	Template.Tier = 1;
	
	Template.strImage = "img:///IRIArtilleryCannon.UI.Inv_Shell_Shrapnel";

	if (default.bShowSpecialCannonShellsOnSparkBody)
	Template.GameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Shells_Shrapnel";

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;

	Template.HideIfResearched = 'IRI_ImprovedShells_Tech';

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_Shrapnel_Passive');
	Template.Abilities.AddItem('IRI_Shell_Shrapnel_Passive');

	return Template;
}

//	===================================================================
//			SPECIAL HEAVY CANNON SHELLS T2
//	===================================================================

static function X2DataTemplate Create_Shell_HEDP()
{
	local X2WeaponTemplate Template;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_Shell_HEDP');
	
	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.ItemCat = 'utility';
	Template.WeaponCat = 'iri_auxiliary_weapon';
	Template.InventorySlot = class'X2StrategyElement_AuxSlot'.default.AuxiliaryWeaponSlot;
	Template.StowedLocation = eSlot_LeftBack;
	Template.NumUpgradeSlots = 0;

	Template.Tier = 1;
	
	Template.strImage = "img:///IRIArtilleryCannon.UI.Inv_Shell_HEDP";

	if (default.bShowSpecialCannonShellsOnSparkBody)
	Template.GameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Shells_HEDP";

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;

	Template.BaseItem = 'IRI_Shell_HEAT';
	Template.CreatorTemplateName = 'IRI_ImprovedShells_Tech';

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_HEAT_Passive');
	Template.Abilities.AddItem('IRI_Shell_HEDP_Passive');

	return Template;
}

static function X2DataTemplate Create_Shell_HESH()
{
	local X2WeaponTemplate Template;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_Shell_HESH');
	
	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.ItemCat = 'utility';
	Template.WeaponCat = 'iri_auxiliary_weapon';
	Template.InventorySlot = class'X2StrategyElement_AuxSlot'.default.AuxiliaryWeaponSlot;
	Template.StowedLocation = eSlot_LeftBack;
	Template.NumUpgradeSlots = 0;

	Template.Tier = 1;
	
	Template.strImage = "img:///IRIArtilleryCannon.UI.Inv_Shell_HESH";

	if (default.bShowSpecialCannonShellsOnSparkBody)
	Template.GameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Shells_HESH";

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;
	
	Template.BaseItem = 'IRI_Shell_HE';
	Template.CreatorTemplateName = 'IRI_ImprovedShells_Tech';

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_HE_Passive');
	Template.Abilities.AddItem('IRI_Shell_HESH_Passive');

	return Template;
}

static function X2DataTemplate Create_Shell_Flechette()
{
	local X2WeaponTemplate Template;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_Shell_Flechette');
	
	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.ItemCat = 'utility';
	Template.WeaponCat = 'iri_auxiliary_weapon';
	Template.InventorySlot = class'X2StrategyElement_AuxSlot'.default.AuxiliaryWeaponSlot;
	Template.StowedLocation = eSlot_LeftBack;
	Template.NumUpgradeSlots = 0;
	
	Template.Tier = 1;

	Template.strImage = "img:///IRIArtilleryCannon.UI.Inv_Shell_Flechette";

	if (default.bShowSpecialCannonShellsOnSparkBody)
	Template.GameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Shells_Flechette";

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;
	
	Template.BaseItem = 'IRI_Shell_Shrapnel';
	Template.CreatorTemplateName = 'IRI_ImprovedShells_Tech';

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_Shrapnel_Passive');
	Template.Abilities.AddItem('IRI_Shell_Flechette_Passive');

	return Template;
}

//	==============================================================
//			GUN RACKS
//	==============================================================

static function X2DataTemplate Create_Shells_T1()
{
	local X2WeaponTemplate Template;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_Shells_T1');
	
	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'iri_spark_gun_rack';
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_LeftBack;
	Template.NumUpgradeSlots = 0;
	
	Template.Tier = 1;
	
	Template.strImage = "img:///IRIArtilleryCannon.UI.Inv_Shells_T1";

	if (default.bShowSpecialCannonShellsOnSparkBody)
	{
		Template.GameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Shells_T1";

		Template.AltGameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Shells_T1_BM";
		Template.ArmorTechCatForAltArchetype = 'powered';
	}

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_HEAT_Passive');
	Template.Abilities.AddItem('IRI_Shell_HEAT_Passive');

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_HE_Passive');
	Template.Abilities.AddItem('IRI_Shell_HE_Passive');

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_Shrapnel_Passive');
	Template.Abilities.AddItem('IRI_Shell_Shrapnel_Passive');

	Template.HideIfResearched = 'IRI_ImprovedShells_Tech';

	return Template;
}

static function X2DataTemplate Create_Shells_T2()
{
	local X2WeaponTemplate Template;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_Shells_T2');
	
	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'iri_spark_gun_rack';
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_LeftBack;
	Template.NumUpgradeSlots = 0;
	
	Template.Tier = 2;
	
	//Template.strImage = "img:///IRIArtilleryCannon.UI.Inv_Shells_T2";
	Template.strImage = "img:///IRIArtilleryCannon.UI.Inv_Shells_T2_BM";

	if (default.bShowSpecialCannonShellsOnSparkBody)
	{
		Template.GameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Shells_T2";

		Template.AltGameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Shells_T2_BM";
		Template.ArmorTechCatForAltArchetype = 'powered';
	}

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;

	Template.BaseItem = 'IRI_Shells_T1';
	Template.CreatorTemplateName = 'IRI_ImprovedShells_Tech';

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_HEAT_Passive');
	Template.Abilities.AddItem('IRI_Shell_HEDP_Passive');

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_HE_Passive');
	Template.Abilities.AddItem('IRI_Shell_HESH_Passive');

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_Shrapnel_Passive');
	Template.Abilities.AddItem('IRI_Shell_Flechette_Passive');

	return Template;
}