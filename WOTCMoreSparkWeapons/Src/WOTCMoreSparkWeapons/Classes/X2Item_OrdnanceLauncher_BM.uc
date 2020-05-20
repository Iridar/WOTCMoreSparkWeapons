class X2Item_OrdnanceLauncher_BM extends X2Item config(GameData_WeaponData);

var config int BEAM_LAUNCHER_RADIUSBONUS;
var config int BEAM_LAUNCHER_RANGEBONUS;

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
/*
DAMAGE = (Damage=0, Spread=0, PlusOne=0, Crit=0, Pierce=0, Shred=0, Tag="", DamageType="Projectile_Conventional")
; DamageType="Projectile_MagXCom"
; 
IENVIRONMENTDAMAGE = 0
AIM = 0
CRITCHANCE = 0
ICLIPSIZE = 99
ISOUNDRANGE = 10
RANGE[0] = 0

IMAGE = "img:///Image.Path";
GAME_ARCHETYPE = "Archetype.Path"

TYPICAL_ACTION_COST = 1
+ABILITIES = "StandardShot"
+ABILITIES = "Overwatch"
+ABILITIES = "OverwatchShot"
+ABILITIES = "Reload"
+ABILITIES = "HotLoadAmmo"

INVENTORY_SLOT = eInvSlot_PrimaryWeapon
ITEM_CATEGORY = "weapon"
WEAPON_CATEGORY = "rifle"
WEAPON_TECH = "conventional"
; magnetic
; beam
NUM_UPGRADE_SLOTS = 0
SORTING_TIER = -1

STARTING_ITEM = false
INFINITE_ITEM = false
CREATOR_TEMPLATE_NAME = "SchematicName"
BASE_ITEM = "ItemName"
CAN_BE_BUILT = true
+REQUIRED_TECHS = "ModularWeapons"

BUILD_COST_TYPE[0] = "Supplies"
BUILD_COST_QUANTITY[0] = 200
BUILD_COST_TYPE[1] = "EleriumDust"
BUILD_COST_QUANTITY[1] = 15
BUILD_COST_TYPE[2] = "AlienAlloy"
BUILD_COST_QUANTITY[2] = 25

BLACKMARKET_VALUE = 25
*/

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_Item());

	return Templates;
}

static function X2DataTemplate Create_Item()
{
	local X2GrenadeLauncherTemplate Template;
	local ArtifactCost Resources;
	local int i;
	
	`CREATE_X2TEMPLATE(class'X2GrenadeLauncherTemplate', Template, 'IRI_OrdnanceLauncher_CV');

	Template.StowedLocation = eSlot_RightBack;
	switch (default.WEAPON_TECH)
	{
		case 'conventional': 
			Template.EquipSound = "Secondary_Weapon_Equip_Conventional";
			break;
		case 'magnetic':
			Template.EquipSound = "Secondary_Weapon_Equip_Magnetic";
			break;
		case 'beam':
			Template.EquipSound = "Secondary_Weapon_Equip_Beam";
			break;
	}
	Template.IncreaseGrenadeRadius = default.BEAM_LAUNCHER_RADIUSBONUS;
	Template.IncreaseGrenadeRange = default.BEAM_LAUNCHER_RANGEBONUS;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.GrenadeRadiusBonusLabel, , default.BEAM_LAUNCHER_RADIUSBONUS);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.GrenadeRangeBonusLabel, , default.BEAM_LAUNCHER_RANGEBONUS);	

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
	
	//Template.iPhysicsImpulse = 5;
	//Template.fKnockbackDamageAmount = 5.0f;
	//Template.fKnockbackDamageRadius = 0.0f;
	
	Template.GameArchetype = default.GAME_ARCHETYPE;
	Template.strImage = default.IMAGE;
	
	//Template.AddDefaultAttachment('Mag', "ConvAssaultRifle.Meshes.SM_ConvAssaultRifle_MagA", , "img:///UILibrary_Common.ConvAssaultRifle.ConvAssault_MagA");

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