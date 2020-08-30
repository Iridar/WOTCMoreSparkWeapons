class X2Item_SparkArsenal extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_IRI_Spark_XPad());

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