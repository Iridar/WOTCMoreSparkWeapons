class X2StrategyElement_SparkArsenalTech extends X2StrategyElement config(AuxiliaryWeapons);

var config int ARM_CANNON_TECH_DAYS;
var config array<name> ARM_CANNON_TECH_RESOURCE_TYPE;
var config array<int> ARM_CANNON_TECH_RESOURCE_QUANTITY;

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
	local int i;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'IRI_ExperimentalShells_Tech');

	Template.PointsToComplete = class'X2StrategyElement_DefaultTechs'.static.StafferXDays(1, default.ARM_CANNON_TECH_DAYS);
	Template.strImage = "img:///IRISparkHeavyWeapons.UI.UI_ArmCannon_ProvingGrounds";
	Template.SortingTier = 3;
	
	Template.ResearchCompletedFn = class'X2StrategyElement_DefaultTechs'.static.GiveItems;

	//Template.ItemRewards.AddItem('IRI_Shell_HE');
	//Template.ItemRewards.AddItem('IRI_Shell_HEAT');
	//Template.ItemRewards.AddItem('IRI_Shell_Shrapnel');

	//	Requirements
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
	Template.Requirements.RequiredTechs.AddItem('IRI_ExperimentalShells_Tech');
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