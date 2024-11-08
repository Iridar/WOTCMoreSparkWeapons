class X2Item_RestorativeMist_CV extends X2Item config(RestorativeMist);

var config bool REQUIRE_SPARK;

var config float HEAL_RANGE_BIT;
var config float HEAL_RADIUS_BIT;
var config float HEAL_RADIUS;

var config int	HEAL_HP;
var config int	BATTLEFIELD_MEDICINE_HEAL_HP;
var config bool HEALS_ENEMIES;
var config int	COOLDOWN;

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

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_Item());

	return Templates;
}

static function X2DataTemplate Create_Item()
{
	local X2WeaponTemplate		Template;
	local ArtifactCost			Resources;
	local StrategyRequirement	AltReq;
	local AltGameArchetypeUse	GameArch;
	local int i;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'IRI_RestorativeMist_CV');

	Template.StowedLocation = eSlot_LeftBack;
	Template.EquipSound = "StrategyUI_Medkit_Equip";

	if (default.COOLDOWN > 0)
	{
		Template.SetUIStatMarkup(class'XLocalizedData'.default.CooldownLabel, , default.COOLDOWN);
	}
	//Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , default.HEAL_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , default.HEAL_RADIUS - 1);
	
	//Template.iRange = default.HEAL_RANGE;
	Template.iRadius = default.HEAL_RADIUS;

	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';

	Template.ItemCat = default.ITEM_CATEGORY;
	Template.WeaponCat = default.WEAPON_CATEGORY;
	Template.InventorySlot = default.INVENTORY_SLOT;
	Template.NumUpgradeSlots = default.NUM_UPGRADE_SLOTS;
	Template.Abilities = default.ABILITIES;
	
	Template.WeaponTech = default.WEAPON_TECH;
	Template.RewardDecks = default.REWARD_DECKS;
	
	Template.iTypicalActionCost = default.TYPICAL_ACTION_COST;
	
	Template.Tier = default.SORTING_TIER;

	Template.RangeAccuracy = default.RANGE;
	Template.BaseDamage = default.DAMAGE;
	Template.ExtraDamage = default.EXTRA_DAMAGE;
	Template.Aim = default.AIM;
	Template.CritChance = default.CRITCHANCE;
	Template.iClipSize = default.ICLIPSIZE;
	Template.bHideClipSizeStat = true;
	if (default.ICLIPSIZE == -1)
	{
		Template.InfiniteAmmo = true;
		Template.iClipSize = 99;
	}
	if (default.ICLIPSIZE > 0)
	{
		Template.SetUIStatMarkup(class'XLocalizedData'.default.ChargesLabel, , default.ICLIPSIZE);
	}

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

	if (default.REQUIRE_SPARK)
	{
		Template.Requirements.RequiredTechs.AddItem('MechanizedWarfare');
		AltReq.RequiredTechs = default.REQUIRED_TECHS;
		AltReq.SpecialRequirementsFn = IsLostTowersNarrativeContentComplete;
		Template.AlternateRequirements.AddItem(AltReq);
	}

	GameArch.UseGameArchetypeFn = AltGameArchetypeForSoldier;
	GameArch.ArchetypeString = "IRIRestorativeMist.Archetypes.WP_RestorativeMist_Soldier";
	Template.AltGameArchetypeArray.AddItem(GameArch);

	return Template;
}

static private function bool AltGameArchetypeForSoldier(XComGameState_Item ItemState, XComGameState_Unit UnitState, string ConsiderArchetype)
{
	//	Use alternative archetype for all non-SPARK characters
	return class'X2DownloadableContentInfo_WOTCMoreSparkWeapons'.default.SparkCharacterTemplates.Find(UnitState.GetMyTemplateName()) == INDEX_NONE;
}

//	Copied from RM's MEC Troopers. Ey, no reason to reinvent the wheel, okay?
//---------------------------------------------------------------------------------------
// Only returns true if narrative content is enabled AND completed, OR if XPack DLC Integration is turned on. Also accounts for Unintegrated DLC
private static function bool IsLostTowersNarrativeContentComplete()
{
	local XComGameState_CampaignSettings CampaignSettings;
	
	CampaignSettings = XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));

	if (CampaignSettings.HasIntegratedDLCEnabled())
	{
		if (CampaignSettings.HasOptionalNarrativeDLCEnabled(name(class'X2DownloadableContentInfo_DLC_Day90'.default.DLCIdentifier))) //unintegrated DLC may turn this back on
		{
			if (class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('DLC_LostTowersMissionComplete'))
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return true; // When DLC is integrated, count this as narrative content being completed
		}
	}
	else if (CampaignSettings.HasOptionalNarrativeDLCEnabled(name(class'X2DownloadableContentInfo_DLC_Day90'.default.DLCIdentifier)))
	{
		if (class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('DLC_LostTowersMissionComplete'))
		{
			return true;
		}
	}

	return false;
}