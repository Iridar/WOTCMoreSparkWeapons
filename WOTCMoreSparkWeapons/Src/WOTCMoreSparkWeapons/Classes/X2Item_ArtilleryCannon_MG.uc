class X2Item_ArtilleryCannon_MG extends X2Item config(ArtilleryCannon);

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

	Templates.AddItem(Create_ArtilleryCannon_MG());

	return Templates;
}

static function X2DataTemplate Create_ArtilleryCannon_MG()
{
	local X2WeaponTemplate						Template;
	local ArtifactCost							Resources;
	local X2Effect_ApplyDirectionalWorldDamage	WorldDamage;
	//local X2Effect_IRI_TriggerEvent	TriggerEvent;
	local int i;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_ArtilleryCannon_MG');
	
	Template.WeaponPanelImage = "_ConventionalCannon";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon';
	Template.bIsLargeWeapon = true;

	WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';
	WorldDamage.bUseWeaponDamageType = true;
	WorldDamage.bUseWeaponEnvironmentalDamage = false;
	WorldDamage.EnvironmentalDamageAmount = default.IENVIRONMENTDAMAGE;
	WorldDamage.bApplyOnHit = true;
	WorldDamage.bApplyOnMiss = true;
	WorldDamage.bApplyToWorldOnHit = true;
	WorldDamage.bApplyToWorldOnMiss = true;
	WorldDamage.bHitAdjacentDestructibles = true;
	WorldDamage.PlusNumZTiles = 1;
	WorldDamage.bHitTargetTile = true;
	Template.BonusWeaponEffects.AddItem(WorldDamage);

	//TriggerEvent = new class'X2Effect_IRI_TriggerEvent';
	//TriggerEvent.TriggerEventName = 'IRI_FireCannonShot_Event';
	//TriggerEvent.ApplyChance = 100;
	//TriggerEvent.bApplyOnHit = true;
	//TriggerEvent.bApplyOnMiss = false;
	//TriggerEvent.AllowedAbilities.AddItem('StandardShot');
	//TriggerEvent.AllowedAbilities.AddItem('OverwatchShot');	
	//Template.BonusWeaponEffects.AddItem(TriggerEvent);

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

	Template.AddDefaultAttachment('Handle', "IRIArtilleryCannon.Meshes_MG.SM_ArtilleryCannon_MG_BoltHandle");
	Template.AddDefaultAttachment('Optic', "IRIArtilleryCannon.Meshes_MG.SM_ArtilleryCannon_MG_Scope");
	Template.AddDefaultAttachment('Stock', "IRIArtilleryCannon.Meshes_MG.SM_ArtilleryCannon_MG_Stock");
	//Template.AddDefaultAttachment('Suppressor', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Suppressor");
	Template.AddDefaultAttachment('Trigger', "IRIArtilleryCannon.Meshes_MG.SM_ArtilleryCannon_MG_Trigger");

	Template.WeaponPrecomputedPathData.InitialPathTime = 1.5;
	Template.WeaponPrecomputedPathData.MaxPathTime = 2.5;
	Template.WeaponPrecomputedPathData.MaxNumberOfBounces = 0;

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



static function UpdateMods() {
	local X2ItemTemplateManager ItemTemplateManager;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	AddCritUpgrade_T1(ItemTemplateManager, 'CritUpgrade_Bsc');
	AddCritUpgrade_T2(ItemTemplateManager, 'CritUpgrade_Adv');
	AddCritUpgrade_T3(ItemTemplateManager, 'CritUpgrade_Sup');

	AddAimBonusUpgrade_T1(ItemTemplateManager, 'AimUpgrade_Bsc');
	AddAimBonusUpgrade_T2(ItemTemplateManager, 'AimUpgrade_Adv');
	AddAimBonusUpgrade_T3(ItemTemplateManager, 'AimUpgrade_Sup');

	//AddClipSizeBonusUpgrade(ItemTemplateManager, 'ClipSizeUpgrade_Bsc');
	//AddClipSizeBonusUpgrade(ItemTemplateManager, 'ClipSizeUpgrade_Adv');
	//AddClipSizeBonusUpgrade(ItemTemplateManager, 'ClipSizeUpgrade_Sup');

	AddFreeFireBonusUpgrade(ItemTemplateManager, 'FreeFireUpgrade_Bsc');
	AddFreeFireBonusUpgrade(ItemTemplateManager, 'FreeFireUpgrade_Adv');
	AddFreeFireBonusUpgrade(ItemTemplateManager, 'FreeFireUpgrade_Sup');

	AddReloadUpgrade(ItemTemplateManager, 'ReloadUpgrade_Bsc');
	AddReloadUpgrade(ItemTemplateManager, 'ReloadUpgrade_Adv');
	AddReloadUpgrade(ItemTemplateManager, 'ReloadUpgrade_Sup');

	AddMissDamageUpgrade_T1(ItemTemplateManager, 'MissDamageUpgrade_Bsc');
	AddMissDamageUpgrade_T2(ItemTemplateManager, 'MissDamageUpgrade_Adv');
	AddMissDamageUpgrade_T3(ItemTemplateManager, 'MissDamageUpgrade_Sup');

	AddFreeKillUpgrade_T1(ItemTemplateManager, 'FreeKillUpgrade_Bsc');
	AddFreeKillUpgrade_T2(ItemTemplateManager, 'FreeKillUpgrade_Adv');
	AddFreeKillUpgrade_T3(ItemTemplateManager, 'FreeKillUpgrade_Sup');
}


//	LASER SIGHT
static function AddCritUpgrade_T1(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Optic', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Optic', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_LaserSight_T1", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.LaserSight_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_scope");
	Template.AddUpgradeAttachment('RearSight', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Optic', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_RearSight", "", 'IRI_ArtilleryCannon_CV', , "", "", "");
}
static function AddCritUpgrade_T2(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Optic', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Optic', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_LaserSight_T2", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.LaserSight_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_scope");
}
static function AddCritUpgrade_T3(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Optic', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Optic', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_LaserSight_T3", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.LaserSight_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_scope");
}

//	SCOPE
static function AddAimBonusUpgrade_T1(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Optic', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Optic', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Scope_T1", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.Scope_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_scope");	
	Template.AddUpgradeAttachment('FrontSight', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Optic', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_FrontSight", "", 'IRI_ArtilleryCannon_CV', , "", "", "");
}
static function AddAimBonusUpgrade_T2(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Optic', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Optic', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Scope_T2", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.Scope_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_scope");	
	Template.AddUpgradeAttachment('FrontSight', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Optic', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_FrontSight", "", 'IRI_ArtilleryCannon_CV', , "", "", "");
}
static function AddAimBonusUpgrade_T3(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Optic', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Optic', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Scope_T3", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.Scope_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_scope");	
}


//	HAIR TRIGGER
static function AddFreeFireBonusUpgrade(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Trigger', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Mag', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_HairTrigger", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.HairTrigger_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_trigger");

	//Template.AddUpgradeAttachment('Trigger', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Mag', "MagAttachments.Meshes.SM_MagTriggerB", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.HairTrigger_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_trigger");
}

//	EX MAG
/*
static function AddClipSizeBonusUpgrade(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	//Template.AddUpgradeAttachment('Mag', 'UIPawnLocation_WeaponUpgrade_Shotgun_Mag', "MagSMG.Meshes.SM_HOR_Mag_SMG_MagA", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.ExMag_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_clip");	
}*/

//	AUTO LOADER
static function AddReloadUpgrade(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Handle', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Mag', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_AutoLoader", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.AutoLoader_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_clip");
}

//	STOCK
static function AddMissDamageUpgrade_T1(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Stock', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Stock', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Stock_T1", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.Stock_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_stock");
}
static function AddMissDamageUpgrade_T2(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Stock', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Stock', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Stock_T2", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.Stock_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_stock");
}
static function AddMissDamageUpgrade_T3(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Stock', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Stock', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Stock_T3", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.Stock_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_stock");
}

//	SUPPRESSOR
static function AddFreeKillUpgrade_T1(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Suppressor', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Suppressor_T1", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.Suppressor_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");	
}

static function AddFreeKillUpgrade_T2(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Suppressor', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Suppressor_T2", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.Suppressor_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");	
}

static function AddFreeKillUpgrade_T3(X2ItemTemplateManager ItemTemplateManager, Name TemplateName)
{
	local X2WeaponUpgradeTemplate Template;

	Template = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate(TemplateName));

	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Suppressor', "IRIArtilleryCannon.Meshes.SM_ArtilleryCannon_CV_Suppressor_T3", "", 'IRI_ArtilleryCannon_CV', , "", "img:///AdventPistol_MG.UI.Suppressor_Inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");	
}