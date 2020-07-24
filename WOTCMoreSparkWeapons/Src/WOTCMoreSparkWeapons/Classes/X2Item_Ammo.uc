class X2Item_Ammo extends X2Item;

var localized string strDodgeReduction;
var localized string strDefenseReduction;
var localized string strSquadsightPenaltyReduction;

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

	return Templates;
}

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
	
	Template.strImage = "img:///IRIRestorativeMist.UI.UI_SabotAmmo";
	//Template.GameArchetype = default.GAME_ARCHETYPE;

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_HEAT_Passive');

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
	
	Template.strImage = "img:///IRIRestorativeMist.UI.UI_SabotAmmo";
	//Template.GameArchetype = default.GAME_ARCHETYPE;

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;

	Template.HideIfResearched = 'IRI_ImprovedShells_Tech';

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
	
	Template.strImage = "img:///IRIRestorativeMist.UI.UI_SabotAmmo";
	//Template.GameArchetype = default.GAME_ARCHETYPE;

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;

	Template.HideIfResearched = 'IRI_ImprovedShells_Tech';

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_Shrapnel_Passive');

	return Template;
}

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
	
	Template.strImage = "img:///IRIRestorativeMist.UI.UI_SabotAmmo";
	//Template.GameArchetype = default.GAME_ARCHETYPE;

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;

	Template.BaseItem = 'IRI_Shell_HEAT';
	Template.CreatorTemplateName = 'IRI_ImprovedShells_Tech';

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_HEAT_Passive');

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
	
	Template.strImage = "img:///IRIRestorativeMist.UI.UI_SabotAmmo";
	//Template.GameArchetype = default.GAME_ARCHETYPE;

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;
	
	Template.BaseItem = 'IRI_Shell_HE';
	Template.CreatorTemplateName = 'IRI_ImprovedShells_Tech';

	//Template.Abilities.AddItem('IRI_LoadSpecialShell_HE');

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
	
	Template.strImage = "img:///IRIRestorativeMist.UI.UI_SabotAmmo";
	//Template.GameArchetype = default.GAME_ARCHETYPE;

	Template.StartingItem = false;
	Template.bInfiniteItem = true;
	Template.CanBeBuilt = false;
	
	Template.BaseItem = 'IRI_Shell_Shrapnel';
	Template.CreatorTemplateName = 'IRI_ImprovedShells_Tech';

	Template.Abilities.AddItem('IRI_FireArtilleryCannon_Shrapnel_Passive');

	return Template;
}


static function SetUpWeaponUpgrade(out X2WeaponUpgradeTemplate Template)
{
	Template.CanApplyUpgradeToWeaponFn = CanApplyUpgradeToWeapon;
	
	Template.CanBeBuilt = false;
	Template.MaxQuantity = 1;
	Template.bInfiniteItem = true;

	Template.BlackMarketTexts = class'X2Item_DefaultUpgrades'.default.UpgradeBlackMarketTexts;
	Template.LootStaticMesh = StaticMesh'UI_3D.Loot.WeapFragmentA';
	/*
	if (Template.DataName != 'IRI_CannonAmmo_HEAT') Template.MutuallyExclusiveUpgrades.AddItem('IRI_CannonAmmo_HEAT');
	if (Template.DataName != 'IRI_CannonAmmo_SABOT') Template.MutuallyExclusiveUpgrades.AddItem('IRI_CannonAmmo_SABOT');
	if (Template.DataName != 'IRI_CannonAmmo_HE') Template.MutuallyExclusiveUpgrades.AddItem('IRI_CannonAmmo_HE');
	if (Template.DataName != 'IRI_CannonAmmo_Shrapnel') Template.MutuallyExclusiveUpgrades.AddItem('IRI_CannonAmmo_Shrapnel');*/
}

static function bool CanApplyUpgradeToWeapon(X2WeaponUpgradeTemplate UpgradeTemplate, XComGameState_Item Weapon, int SlotIndex)
{
	local array<X2WeaponUpgradeTemplate> AttachedUpgradeTemplates;
	local X2WeaponUpgradeTemplate AttachedUpgrade; 
	local int iSlot;

	//	Can equip Ammo Upgrades only in the 0th slot.
	//if (SlotIndex != 0) return false;

	//	Can only apply these Ammo Upgrades to Artillery Cannons.
	switch (Weapon.GetMyTemplateName())
	{
		case 'IRI_ArtilleryCannon_CV':
		case 'IRI_ArtilleryCannon_MG':
		case 'IRI_ArtilleryCannon_BM':
			break;
		default:
			return false;
	}
		
	AttachedUpgradeTemplates = Weapon.GetMyWeaponUpgradeTemplates();

	foreach AttachedUpgradeTemplates(AttachedUpgrade, iSlot)
	{
		// Slot Index indicates the upgrade slot the player intends to replace with this new upgrade
		if (iSlot == SlotIndex)
		{
			// The exact upgrade already equipped in a slot cannot be equipped again
			// This allows different versions of the same upgrade type to be swapped into the slot
			if (AttachedUpgrade == UpgradeTemplate)
			{
				return false;
			}
		}
		else if (UpgradeTemplate.MutuallyExclusiveUpgrades.Find(AttachedUpgrade.DataName) != INDEX_NONE)
		{
			// If the new upgrade is mutually exclusive with any of the other currently equipped upgrades, it is not allowed
			return false;
		}
	}

	return true;
}