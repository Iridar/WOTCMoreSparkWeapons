class X2StrategyElement_SparkArsenalTech extends X2StrategyElement config(AuxiliaryWeapons);

var config int ARM_CANNON_TECH_DAYS;
var config array<name> ARM_CANNON_TECH_RESOURCE_TYPE;
var config array<int> ARM_CANNON_TECH_RESOURCE_QUANTITY;

var config(ArtilleryCannon) int EXPERIMENTAL_SHELLS_TECH_DAYS;
var config(ArtilleryCannon) array<name> EXPERIMENTAL_SHELLS_TECH_RESOURCE_TYPE;
var config(ArtilleryCannon) array<int> EXPERIMENTAL_SHELLS_TECH_RESOURCE_QUANTITY;

var config(ArtilleryCannon) int IMPROVED_SHELLS_TECH_DAYS;
var config(ArtilleryCannon) array<name> IMPROVED_SHELLS_TECH_RESOURCE_TYPE;
var config(ArtilleryCannon) array<int> IMPROVED_SHELLS_TECH_RESOURCE_QUANTITY;

var config(ArtilleryCannon) StrategyRequirement IMPROVED_SHELLS_TECH_REQUIREMENTS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;

	Techs.AddItem(Create_ArmCannonTech());
	Techs.AddItem(Create_ExperimentalShells_Tech());
	Techs.AddItem(Create_ImprovedShells_Tech());

	return Techs;
}

static function X2DataTemplate Create_ArmCannonTech()
{
	local X2TechTemplate		Template;
	local ArtifactCost			Resources;
	local StrategyRequirement	AltReq;
	local int i;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'IRI_ArmCannon_Tech');

	Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, default.ARM_CANNON_TECH_DAYS);
	Template.strImage = "img:///IRISparkHeavyWeapons.UI.UI_ArmCannon_ProvingGrounds";
	Template.SortingTier = 3;
	
	// Created Item
	//Template.ResearchCompletedFn = class'X2StrategyElement_DefaultTechs'.static.UpgradeItems;

	//	Requirements
	Template.Requirements.RequiredTechs.AddItem('MechanizedWarfare');

	AltReq.SpecialRequirementsFn = IsLostTowersNarrativeContentComplete;
	Template.AlternateRequirements.AddItem(AltReq);

	Template.Requirements.bVisibleIfPersonnelGatesNotMet = true;

	// Cost
	for (i = 0; i < default.ARM_CANNON_TECH_RESOURCE_TYPE.Length; i++)
	{
		if (default.ARM_CANNON_TECH_RESOURCE_QUANTITY[i] > 0)
		{
			Resources.ItemTemplateName = default.ARM_CANNON_TECH_RESOURCE_TYPE[i];
			Resources.Quantity = default.ARM_CANNON_TECH_RESOURCE_QUANTITY[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}

	Template.bProvingGround = true;
	Template.bRepeatable = false;

	return Template;
}

static function X2DataTemplate Create_ExperimentalShells_Tech()
{
	local X2TechTemplate		Template;
	local ArtifactCost			Resources;
	local StrategyRequirement	AltReq;
	local int i;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'IRI_ExperimentalShells_Tech');

	Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, default.ARM_CANNON_TECH_DAYS);
	Template.strImage = "img:///IRISparkHeavyWeapons.UI.UI_ArmCannon_ProvingGrounds";
	Template.SortingTier = 3;
	
	Template.ResearchCompletedFn = GiveShells;

	//	Requirements
	Template.Requirements.RequiredTechs.AddItem('MechanizedWarfare');

	AltReq.SpecialRequirementsFn = IsLostTowersNarrativeContentComplete;
	Template.AlternateRequirements.AddItem(AltReq);

	Template.Requirements.RequiredEngineeringScore = 10;
	Template.Requirements.bVisibleIfPersonnelGatesNotMet = true;

	// Cost
	for (i = 0; i < default.EXPERIMENTAL_SHELLS_TECH_RESOURCE_TYPE.Length; i++)
	{
		if (default.EXPERIMENTAL_SHELLS_TECH_RESOURCE_QUANTITY[i] > 0)
		{
			Resources.ItemTemplateName = default.EXPERIMENTAL_SHELLS_TECH_RESOURCE_TYPE[i];
			Resources.Quantity = default.EXPERIMENTAL_SHELLS_TECH_RESOURCE_QUANTITY[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}

	Template.bProvingGround = true;
	Template.bRepeatable = false;

	return Template;
}

static function GiveShells(XComGameState NewGameState, XComGameState_Tech TechState)
{
	local XComGameStateHistory History;
	local X2ItemTemplateManager ItemMgr;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local XComGameState_HeadquartersXCom XComHQ;

	History = `XCOMHISTORY;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if (XComHQ == none)
	{
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	}

	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	
	// Iterate through the Spark Equipment, find their templates, and build and activate the Item State Object for each

	ItemTemplate = ItemMgr.FindItemTemplate('IRI_Shell_HE');
	if (ItemTemplate != none)
	{
		TechState.ItemRewards.AddItem(ItemTemplate);
		ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
		XComHQ.AddItemToHQInventory(ItemState);
	}
	ItemTemplate = ItemMgr.FindItemTemplate('IRI_Shell_HEAT');
	if (ItemTemplate != none)
	{
		TechState.ItemRewards.AddItem(ItemTemplate);
		ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
		XComHQ.AddItemToHQInventory(ItemState);
	}
	ItemTemplate = ItemMgr.FindItemTemplate('IRI_Shell_Shrapnel');
	if (ItemTemplate != none)
	{
		TechState.ItemRewards.AddItem(ItemTemplate);
		ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
		XComHQ.AddItemToHQInventory(ItemState);
	}	
}


static function X2DataTemplate Create_ImprovedShells_Tech()
{
	local X2TechTemplate		Template;
	local ArtifactCost			Resources;
	local int i;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'IRI_ImprovedShells_Tech');

	Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, default.ARM_CANNON_TECH_DAYS);
	Template.strImage = "img:///IRISparkHeavyWeapons.UI.UI_ArmCannon_ProvingGrounds";
	Template.SortingTier = 3;
	
	Template.ResearchCompletedFn = class'X2StrategyElement_DefaultTechs'.static.UpgradeItems;

	//	Requirements
	Template.Requirements = default.IMPROVED_SHELLS_TECH_REQUIREMENTS;

	// Cost
	for (i = 0; i < default.IMPROVED_SHELLS_TECH_RESOURCE_TYPE.Length; i++)
	{
		if (default.IMPROVED_SHELLS_TECH_RESOURCE_QUANTITY[i] > 0)
		{
			Resources.ItemTemplateName = default.IMPROVED_SHELLS_TECH_RESOURCE_TYPE[i];
			Resources.Quantity = default.IMPROVED_SHELLS_TECH_RESOURCE_QUANTITY[i];
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}

	Template.bProvingGround = true;
	Template.bRepeatable = false;

	return Template;
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