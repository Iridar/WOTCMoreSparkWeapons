class X2Item_ArtilleryCannon_CV extends X2Item config(ArtilleryCannon);

var config WeaponDamageValue DAMAGE;
var config array <WeaponDamageValue> EXTRA_DAMAGE;
var config int IENVIRONMENTDAMAGE;
var config int AIM;
var config int CRITCHANCE;
var config int ICLIPSIZE;
var config int ISOUNDRANGE;
var config array<int> RANGE;

var config string IMAGE;
var config string GAME_ARCHETYPE;

var config int TYPICAL_ACTION_COST;
var config array<name> ABILITIES;

var config name ITEM_CATEGORY;
var config name WEAPON_CATEGORY;
var config int SORTING_TIER;
var config EInventorySlot INVENTORY_SLOT;
var config name WEAPON_TECH;
var config int NUM_UPGRADE_SLOTS;

var config bool STARTING_ITEM;
var config bool INFINITE_ITEM;
var config name CREATOR_TEMPLATE_NAME;
var config name BASE_ITEM;
var config bool CAN_BE_BUILT;
var config array<name> REQUIRED_TECHS;
var config array<name> BUILD_COST_TYPE;
var config array<int> BUILD_COST_QUANTITY;
var config int BLACKMARKET_VALUE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_ArtilleryCannon_CV());

	Templates.AddItem(Create_Ammo_HEAT());

	return Templates;
}

static function X2DataTemplate Create_ArtilleryCannon_CV()
{
	local X2WeaponTemplate Template;
	local ArtifactCost Resources;
	local int i;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_ArtilleryCannon_CV');
	
	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
	switch (default.WEAPON_TECH)
	{
		case 'conventional': 
			Template.EquipSound = "Conventional_Weapon_Equip";
			break;
		case 'magnetic':
			Template.EquipSound = "Magnetic_Weapon_Equip";
			break;
		case 'beam':
			Template.EquipSound = "Beam_Weapon_Equip";
			break;
	}

	Template.ItemCat = default.ITEM_CATEGORY;
	Template.WeaponCat = default.WEAPON_CATEGORY;
	Template.InventorySlot = default.INVENTORY_SLOT;
	Template.NumUpgradeSlots = default.NUM_UPGRADE_SLOTS;
	Template.Abilities = default.ABILITIES;
	
	Template.WeaponTech = default.WEAPON_TECH;
	
	Template.iTypicalActionCost = default.TYPICAL_ACTION_COST;
	
	Template.Tier = default.SORTING_TIER;

	Template.RangeAccuracy = default.RANGE;
	Template.BaseDamage = default.DAMAGE;
	Template.ExtraDamage = default.EXTRA_DAMAGE;
	Template.Aim = default.AIM;
	Template.CritChance = default.CRITCHANCE;
	Template.iClipSize = default.ICLIPSIZE;
	Template.iSoundRange = default.ISOUNDRANGE;
	Template.iEnvironmentDamage = default.IENVIRONMENTDAMAGE;
	Template.DamageTypeTemplateName = default.DAMAGE.DamageType;
	
	Template.iPhysicsImpulse = 15;
	Template.fKnockbackDamageAmount = 10.0f;
	Template.fKnockbackDamageRadius = 16.0f;
	
	Template.GameArchetype = default.GAME_ARCHETYPE;
	Template.strImage = default.IMAGE;

	Template.AddDefaultAttachment('Handle', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_BoltHandle");
	Template.AddDefaultAttachment('Optic', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_IrongSights");
	Template.AddDefaultAttachment('Stock', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Stock");
	Template.AddDefaultAttachment('Handle', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_BoltHandle");
	Template.AddDefaultAttachment('Suppressor', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Suppressor");
	Template.AddDefaultAttachment('Trigger', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Trigger");

	Template.StartingItem = default.STARTING_ITEM;
	Template.bInfiniteItem = default.INFINITE_ITEM;
	Template.CanBeBuilt = default.CAN_BE_BUILT;
	
	if (!Template.bInfiniteItem)
	{
		Template.TradingPostValue = default.BLACKMARKET_VALUE;
		
		if (Template.CanBeBuilt)
		{
			Template.Requirements.RequiredTechs = default.REQUIRED_TECHS;
			
			for (i = 0; i < default.BUILD_COST_TYPE.Length; i++)
			{
				if (default.BUILD_COST_QUANTITY[i] > 0)
				{
					Resources.ItemTemplateName = default.BUILD_COST_TYPE[i];
					Resources.Quantity = default.BUILD_COST_QUANTITY[i];
					Template.Cost.ResourceCosts.AddItem(Resources);
				}
			}
		}
	}
	
	Template.PointsToComplete = 0;
	Template.CreatorTemplateName = default.CREATOR_TEMPLATE_NAME; // The schematic which creates this item
	Template.BaseItem = default.BASE_ITEM; // Which item this will be upgraded from
	
	return Template;
}


static function X2DataTemplate Create_Ammo_HEAT()
{
	local X2WeaponUpgradeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponUpgradeTemplate', Template, 'IRI_CannonAmmo_HEAT');

	SetUpWeaponUpgrade(Template);
	Template.Tier = 3;

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.ConvAssault_OpticB_inv";
		
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