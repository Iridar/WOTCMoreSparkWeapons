class X2Item_HeavyAutogun extends X2Item config(AutogunHeavyWeapon);

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

var config array<name> REWARD_DECKS;
var config bool INFINITE_AMMO;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_Item());

	return Templates;
}

static function X2DataTemplate Create_Item()
{
	local X2WeaponTemplate Template;
	local ArtifactCost Resources;
	local AltGameArchetypeUse GameArch;
	local int i;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_Heavy_Autogun');

	Template.StowedLocation = eSlot_HeavyWeapon;
	Template.EquipSound = "StrategyUI_Heavy_Weapon_Equip";

	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';		

	Template.ItemCat = default.ITEM_CATEGORY;
	Template.WeaponCat = default.WEAPON_CATEGORY;
	Template.InventorySlot = default.INVENTORY_SLOT;
	Template.NumUpgradeSlots = default.NUM_UPGRADE_SLOTS;
	Template.Abilities = default.ABILITIES;
	
	Template.WeaponTech = default.WEAPON_TECH;
	
	Template.iTypicalActionCost = default.TYPICAL_ACTION_COST;
	
	Template.Tier = default.SORTING_TIER;
	Template.InfiniteAmmo = default.INFINITE_AMMO;
	Template.bHideClipSizeStat = default.INFINITE_AMMO;

	Template.RangeAccuracy = default.RANGE;
	Template.BaseDamage = default.DAMAGE;
	Template.ExtraDamage = default.EXTRA_DAMAGE;
	Template.Aim = default.AIM;
	Template.CritChance = default.CRITCHANCE;
	Template.iClipSize = default.ICLIPSIZE;
	Template.iSoundRange = default.ISOUNDRANGE;
	Template.iEnvironmentDamage = default.IENVIRONMENTDAMAGE;
	Template.DamageTypeTemplateName = default.DAMAGE.DamageType;
	
	Template.iPhysicsImpulse = 5;
	Template.fKnockbackDamageAmount = 5.0f;
	Template.fKnockbackDamageRadius = 0.0f;
	
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

	Template.RewardDecks = default.REWARD_DECKS;
	
	Template.PointsToComplete = 0;
	Template.CreatorTemplateName = default.CREATOR_TEMPLATE_NAME; // The schematic which creates this item
	Template.BaseItem = default.BASE_ITEM; // Which item this will be upgraded from

	//	Regular archetype for Soldiers.
	Template.GameArchetype = "IRISparkHeavyWeapons.Archetypes.WP_Heavy_LAC";

	//	Regular archetype for soldiers using powered armor. Both of these also double for SPARKs without BIT.
	Template.AltGameArchetype = "IRISparkHeavyWeapons.Archetypes.WP_Heavy_LAC_Powered";
	Template.ArmorTechCatForAltArchetype = 'powered';

	//	Alternative archetype if this Autogun is in the BIT Heavy Weapon slot
	GameArch.UseGameArchetypeFn = SparkHeavyWeaponCheck;
	GameArch.ArchetypeString = "IRISparkHeavyWeapons.Archetypes.WP_Heavy_LAC_Spark_with_BIT";
	Template.AltGameArchetypeArray.AddItem(GameArch);

	//	Use alternative alternative archetype for the BIT itself.
	GameArch.UseGameArchetypeFn = BitHeavyWeaponCheck;
	GameArch.ArchetypeString = "IRISparkHeavyWeapons.Archetypes.WP_Heavy_LAC_Bit";
	Template.AltGameArchetypeArray.AddItem(GameArch);
	
	return Template;
}

static function bool SparkHeavyWeaponCheck(XComGameState_Item ItemState, XComGameState_Unit UnitState, string ConsiderArchetype)
{
	return ItemState.InventorySlot == class'X2StrategyElement_BITHeavyWeaponSlot'.default.BITHeavyWeaponSlot;
}

static function bool BitHeavyWeaponCheck(XComGameState_Item ItemState, XComGameState_Unit UnitState, string ConsiderArchetype)
{
	return UnitState.GetMyTemplate().bIsCosmetic;
}