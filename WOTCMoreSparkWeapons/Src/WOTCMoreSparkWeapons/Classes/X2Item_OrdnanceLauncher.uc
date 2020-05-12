class X2Item_OrdnanceLauncher extends X2Item config(GameData_WeaponData);

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

*/

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_OrdnanceLauncher_CV());
	Templates.AddItem(Create_OrdnanceLauncher_MG());

	return Templates;
}

static function X2GrenadeLauncherTemplate Create_OrdnanceLauncher_CV()
{
	local X2GrenadeLauncherTemplate Template;

	`CREATE_X2TEMPLATE(class'X2GrenadeLauncherTemplate', Template, 'IRI_OrdnanceLauncher_CV');

	Template.strImage = "img:///UILibrary_Common.ConvSecondaryWeapons.ConvGrenade";
	Template.EquipSound = "Secondary_Weapon_Equip_Conventional";

	Template.BaseDamage = default.DAMAGE;
	Template.ExtraDamage = default.EXTRA_DAMAGE;
	
	Template.iSoundRange = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_ISOUNDRANGE;
	Template.iEnvironmentDamage = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_IENVIRONMENTDAMAGE;
	Template.TradingPostValue = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_TRADINGPOSTVALUE;
	Template.iClipSize = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_ICLIPSIZE;
	Template.Tier = 0;

	Template.IncreaseGrenadeRadius = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RADIUSBONUS;
	Template.IncreaseGrenadeRange = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RANGEBONUS;

	Template.WeaponTech = 'conventional';
	//Template.WeaponTech = 'beam';
	Template.GameArchetype = "IRIOrdnanceLauncher.Archetypes.WP_OrdnanceLauncher_CV";
	Template.WeaponCat = 'iri_ordnance_launcher';
	//Template.Abilities.AddItem('IRI_LaunchOrdnance');
	
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.GrenadeRangeBonusLabel, , class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RANGEBONUS);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.GrenadeRadiusBonusLabel, , class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RADIUSBONUS);

	return Template;
}

static function X2GrenadeLauncherTemplate Create_OrdnanceLauncher_MG()
{
	local X2GrenadeLauncherTemplate Template;

	`CREATE_X2TEMPLATE(class'X2GrenadeLauncherTemplate', Template, 'IRI_OrdnanceLauncher_MG');

	Template.strImage = "img:///UILibrary_Common.ConvSecondaryWeapons.ConvGrenade";
	Template.EquipSound = "Secondary_Weapon_Equip_Conventional";

	Template.BaseDamage = default.DAMAGE;
	Template.ExtraDamage = default.EXTRA_DAMAGE;
	
	Template.iSoundRange = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_ISOUNDRANGE;
	Template.iEnvironmentDamage = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_IENVIRONMENTDAMAGE;
	Template.TradingPostValue = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_TRADINGPOSTVALUE;
	Template.iClipSize = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_ICLIPSIZE;
	Template.Tier = 0;

	Template.IncreaseGrenadeRadius = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RADIUSBONUS;
	Template.IncreaseGrenadeRange = class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RANGEBONUS;

	Template.WeaponTech = 'magnetic';
	//Template.WeaponTech = 'beam';
	Template.GameArchetype = "IRIOrdnanceLauncher.Archetypes.WP_OrdnanceLauncher_MG";
	Template.WeaponCat = 'iri_ordnance_launcher';
	//Template.Abilities.AddItem('IRI_LaunchOrdnance');
	
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.GrenadeRangeBonusLabel, , class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RANGEBONUS);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.GrenadeRadiusBonusLabel, , class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RADIUSBONUS);

	return Template;
}

static function X2DataTemplate Create_Item()
{
	local X2WeaponTemplate Template;
	local ArtifactCost Resources;
	local int i;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'Name');
	
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
	
	Template.Aim = default.AIM;
	Template.CritChance = default.CRITCHANCE;
	Template.iClipSize = default.ICLIPSIZE;
	Template.iSoundRange = default.ISOUNDRANGE;
	Template.iEnvironmentDamage = default.IENVIRONMENTDAMAGE;
	Template.DamageTypeTemplateName = default.DAMAGE.DamageType;
	
	Template.iPhysicsImpulse = 5;
	Template.fKnockbackDamageAmount = 5.0f;
	Template.fKnockbackDamageRadius = 0.0f;
	
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