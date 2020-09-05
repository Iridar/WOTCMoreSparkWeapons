class X2Item_SparkArsenal extends X2Item config(SparkArsenal);

var config array<LootTable> ExperimentalMagazineLootEntry;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_IRI_Spark_XPad());

	Templates.AddItem(Create_ExperimentalMagazine());
	Templates.AddItem(Create_SpeedLoader());

	return Templates;
}

static function X2DataTemplate Create_IRI_Spark_XPad()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_Spark_XPad');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_X4";

	Template.ItemCat = 'tech';
	Template.WeaponCat = 'utility';
	Template.iRange = 15;
	Template.iRadius = 240;
	Template.iItemSize = 0;
	Template.Tier = -1;

	Template.InventorySlot = eInvSlot_Utility;
	Template.StowedLocation = eSlot_LowerBack;
	Template.Abilities.AddItem('Hack');
	Template.Abilities.AddItem('Hack_Chest');
	Template.Abilities.AddItem('Hack_Workstation');
	Template.Abilities.AddItem('Hack_ObjectiveChest');
	Template.Abilities.AddItem('Hack_Scan');
			
	Template.GameArchetype = "IRISparkArsenal.Archetypes.WP_SPARK_HackingKit";

	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	return Template;
}

//	===================================================================
//			WEAPON UPGRADES
//	===================================================================


static function X2DataTemplate Create_ExperimentalMagazine()
{
	local X2WeaponUpgradeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponUpgradeTemplate', Template, 'IRI_ExperimentalMagazine_Upgrade');

	class'X2Item_DefaultUpgrades'.static.SetUpWeaponUpgrade(Template);
	//class'X2Item_DefaultUpgrades'.static.SetUpCritUpgrade(Template);
	class'X2Item_DefaultUpgrades'.static.SetUpTier2Upgrade(Template);

	Template.MutuallyExclusiveUpgrades.AddItem('IRI_ExperimentalMagazine_Upgrade');
	Template.MutuallyExclusiveUpgrades.AddItem('ClipSizeUpgrade');
	Template.MutuallyExclusiveUpgrades.AddItem('ClipSizeUpgrade_Bsc');
	Template.MutuallyExclusiveUpgrades.AddItem('ClipSizeUpgrade_Adv');
	Template.MutuallyExclusiveUpgrades.AddItem('ClipSizeUpgrade_Sup');

	//Template.BonusAbilities.AddItem('IRI_ExperimentalMagazine_Passive');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.MagAssaultRifle_MagB_inv";
	
	return Template;
}

static function X2DataTemplate Create_SpeedLoader()
{
	local X2WeaponUpgradeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponUpgradeTemplate', Template, 'IRI_SpeedLoader_Upgrade');

	class'X2Item_DefaultUpgrades'.static.SetUpWeaponUpgrade(Template);
	//class'X2Item_DefaultUpgrades'.static.SetUpCritUpgrade(Template);
	class'X2Item_DefaultUpgrades'.static.SetUpTier2Upgrade(Template);

	Template.MutuallyExclusiveUpgrades.AddItem('IRI_SpeedLoader_Upgrade');
	Template.MutuallyExclusiveUpgrades.AddItem('ReloadUpgrade');
	Template.MutuallyExclusiveUpgrades.AddItem('ReloadUpgrade_Bsc');
	Template.MutuallyExclusiveUpgrades.AddItem('ReloadUpgrade_Adv');
	Template.MutuallyExclusiveUpgrades.AddItem('ReloadUpgrade_Sup');

	Template.BonusAbilities.AddItem('IRI_SpeedLoader_Passive');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.MagAssaultRifle_MagC_inv";
	
	return Template;
}

static function PatchWeaponUpgrades()
{
	local X2WeaponUpgradeTemplate FirstTemplate, SecondTemplate;
	local X2ItemTemplateManager ItemTemplateManager;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	//	EXPERIMENTAL MAGAZINE
	FirstTemplate = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate('ClipSizeUpgrade_Adv'));
	SecondTemplate = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate('IRI_ExperimentalMagazine_Upgrade'));

	//	Copy visual weapon attachments from Advanced Extended Magazines to Experimental Magazine.
	if (FirstTemplate != none && SecondTemplate != none)
	{
		SecondTemplate.UpgradeAttachments = FirstTemplate.UpgradeAttachments;

		FirstTemplate.MutuallyExclusiveUpgrades.AddItem('IRI_ExperimentalMagazine_Upgrade');
	}

	//	Make all tiers of Extended Mags mutually exclusive with Experimental Magazine
	FirstTemplate = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate('ClipSizeUpgrade'));
	if (FirstTemplate != none)
	{
		FirstTemplate.MutuallyExclusiveUpgrades.AddItem('IRI_ExperimentalMagazine_Upgrade');
	}

	FirstTemplate = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate('ClipSizeUpgrade_Bsc'));
	if (FirstTemplate != none)
	{
		FirstTemplate.MutuallyExclusiveUpgrades.AddItem('IRI_ExperimentalMagazine_Upgrade');
	}

	FirstTemplate = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate('ClipSizeUpgrade_Sup'));
	if (FirstTemplate != none)
	{
		FirstTemplate.MutuallyExclusiveUpgrades.AddItem('IRI_ExperimentalMagazine_Upgrade');
	}

	//	SPEED LOADER
	FirstTemplate = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate('ReloadUpgrade_Adv'));
	SecondTemplate = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate('IRI_SpeedLoader_Upgrade'));

	//	Copy visual weapon attachments from Advanced Extended Magazines to Experimental Magazine.
	if (FirstTemplate != none && SecondTemplate != none)
	{
		SecondTemplate.UpgradeAttachments = FirstTemplate.UpgradeAttachments;

		FirstTemplate.MutuallyExclusiveUpgrades.AddItem('IRI_SpeedLoader_Upgrade');
	}

	//	Make all tiers of Extended Mags mutually exclusive with Experimental Magazine
	FirstTemplate = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate('ReloadUpgrade'));
	if (FirstTemplate != none)
	{
		FirstTemplate.MutuallyExclusiveUpgrades.AddItem('IRI_SpeedLoader_Upgrade');
	}

	FirstTemplate = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate('ReloadUpgrade_Bsc'));
	if (FirstTemplate != none)
	{
		FirstTemplate.MutuallyExclusiveUpgrades.AddItem('IRI_SpeedLoader_Upgrade');
	}

	FirstTemplate = X2WeaponUpgradeTemplate(ItemTemplateManager.FindItemTemplate('ReloadUpgrade_Sup'));
	if (FirstTemplate != none)
	{
		FirstTemplate.MutuallyExclusiveUpgrades.AddItem('IRI_SpeedLoader_Upgrade');
	}

	AddLootTables();
	
}

static function AddLootTables()
{
	local X2LootTableManager	LootManager;
	local LootTable				LootBag;
	local LootTableEntry		Entry;
	
	LootManager = X2LootTableManager(class'Engine'.static.FindClassDefaultObject("X2LootTableManager"));

	Foreach default.ExperimentalMagazineLootEntry(LootBag)
	{
		if ( LootManager.default.LootTables.Find('TableName', LootBag.TableName) != INDEX_NONE )
		{
			foreach LootBag.Loots(Entry)
			{
				class'X2LootTableManager'.static.AddEntryStatic(LootBag.TableName, Entry, true);
			}
		}	
	}
}