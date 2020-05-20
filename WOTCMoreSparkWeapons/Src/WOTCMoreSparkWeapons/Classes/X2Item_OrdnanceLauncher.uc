class X2Item_OrdnanceLauncher extends X2Item config(GameData_WeaponData);

var config WeaponDamageValue DAMAGE;
var config array <WeaponDamageValue> EXTRA_DAMAGE;


static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	/*
	Templates.AddItem(Create_OrdnanceLauncher_CV());
	Templates.AddItem(Create_OrdnanceLauncher_MG());
	Templates.AddItem(Create_OrdnanceLauncher_BM());
	*/
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
	Template.GameArchetype = "IRIOrdnanceLauncher.Archetypes.WP_OrdnanceLauncher_CV";
	Template.WeaponCat = 'iri_ordnance_launcher';
	
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
	Template.GameArchetype = "IRIOrdnanceLauncher.Archetypes.WP_OrdnanceLauncher_MG";
	Template.WeaponCat = 'iri_ordnance_launcher';
	
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.GrenadeRangeBonusLabel, , class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RANGEBONUS);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.GrenadeRadiusBonusLabel, , class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RADIUSBONUS);

	return Template;
}

static function X2GrenadeLauncherTemplate Create_OrdnanceLauncher_BM()
{
	local X2GrenadeLauncherTemplate Template;

	`CREATE_X2TEMPLATE(class'X2GrenadeLauncherTemplate', Template, 'IRI_OrdnanceLauncher_BM');

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

	Template.WeaponTech = 'beam';
	Template.GameArchetype = "IRIOrdnanceLauncher.Archetypes.WP_OrdnanceLauncher_BM";
	Template.WeaponCat = 'iri_ordnance_launcher';
	
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.GrenadeRangeBonusLabel, , class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RANGEBONUS);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.GrenadeRadiusBonusLabel, , class'X2Item_DefaultGrenades'.default.GRENADELAUNCHER_RADIUSBONUS);

	return Template;
}
