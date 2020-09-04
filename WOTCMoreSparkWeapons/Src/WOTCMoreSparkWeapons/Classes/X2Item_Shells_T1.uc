class X2Item_Shells_T1 extends X2Item config(ArtilleryCannon);

var config string IMAGE;
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
var config name HIDE_IF_TECH_RESEARCHED;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_Item());

	return Templates;
}

static function X2DataTemplate Create_Item()
{
	local X2WeaponTemplate Template;
	local WeaponAttachment Attach;
	local ArtifactCost Resources;
	local int i;
	
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_Shells_T1');
	
	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
	Template.EquipSound = "StrategyUI_Ammo_Equip";
	Template.StowedLocation = eSlot_LeftBack;

	Template.ItemCat = default.ITEM_CATEGORY;
	Template.WeaponCat = default.WEAPON_CATEGORY;
	Template.InventorySlot = default.INVENTORY_SLOT;
	Template.NumUpgradeSlots = default.NUM_UPGRADE_SLOTS;
	Template.Abilities = default.ABILITIES;
	
	Template.WeaponTech = default.WEAPON_TECH;
	
	Template.Tier = default.SORTING_TIER;
	
	if (class'X2Item_Ammo'.default.bShowSpecialCannonShellsOnSparkBody)
	{
		Template.GameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Rack_Hip";

		Template.AltGameArchetype = "IRIHeavyCannonShells.Archetypes.WP_Rack_Hip_BM";
		Template.ArmorTechCatForAltArchetype = 'powered';

		Attach.AttachSocket = 'iri_hip_shells';
		Attach.AttachMeshName = "IRIHeavyCannonShells.Meshes.SM_Shells_T1";
		Attach.AttachToPawn = true;
		Template.DefaultAttachments.AddItem(Attach);
	}
	Template.strImage = default.IMAGE;

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
	Template.HideIfResearched = default.HIDE_IF_TECH_RESEARCHED;
	
	return Template;
}