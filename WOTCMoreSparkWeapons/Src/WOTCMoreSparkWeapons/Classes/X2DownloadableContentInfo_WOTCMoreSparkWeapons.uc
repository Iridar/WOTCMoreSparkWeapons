class X2DownloadableContentInfo_WOTCMoreSparkWeapons extends X2DownloadableContentInfo;

var config(SparkWeapons) array<name> SparkCharacterTemplates;
var config(SparkWeapons) bool bRocketLaunchersModPresent;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}


//	Immedaite goals:

//	Ordnance Lauincher - Mag tier model
//	Ordnance Lauincher - Beam tier model
//	Ordnance Lauincher - Set to use Grenade Launcher schematics
//	Ordnance Lauincher - Localization
//	Ordnance Lauincher - inventory icons for weapons

//	Uncouple BIT from the SPARK - investigate log warnings.

//	BIT for Specialists? Include Active Camo animation for specialists.
//	Template Highlander Slots for the Ordnance Launcher

//	Icon for Active Camo
//	KSM Icon: Texture2D'UILibrary_PerkIcons.UIPerk_mecclosecombat'

static event OnPostTemplatesCreated()
{
	PatchCharacterTemplates();
	CopyLocalizationForAbilities();
	PatchRainmaker();
	PatchRepair();
	AddActveCamoToBITs();
}

static function PatchCharacterTemplates()
{
    local X2CharacterTemplateManager    CharMgr;
    local X2CharacterTemplate           CharTemplate;
	local name							CharTemplateName;

    //  Get the Character Template Modify
    CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	foreach default.SparkCharacterTemplates(CharTemplateName)
	{
		CharTemplate = CharMgr.FindCharacterTemplate(CharTemplateName);

		if (CharTemplate != none)
		{
			//	Remove Active Camo from char templates. We'll add it to BIT instead.
			CharTemplate.Abilities.RemoveItem('ActiveCamo');

			//	Always attach Lockon Matinee cuz it's also used by Bombard
			CharTemplate.strMatineePackages.AddItem("CIN_IRI_Lockon");
			
			CharTemplate.strMatineePackages.AddItem("CIN_IRI_QuickWideSpark");
			`LOG("Added matinee for Character Template:" @ CharTemplate.DataName,, 'IRITEST');
		}
	}
}

static function PatchRainmaker()
{
	local X2AbilityTemplateManager	AbilityTemplateManager;
	local X2DataTemplate			DataTemplate;
	local X2AbilityTemplate			Template;
	local X2Effect_IRI_Rainmaker	Rainmaker;
	local X2Effect					Effect;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	//	Get the Rainmaker ability template so we can use it for the purposes of our effect's localization.
	Template = AbilityTemplateManager.FindAbilityTemplate('Rainmaker');
	if (Template != none)
	{
		Rainmaker = new class'X2Effect_IRI_Rainmaker';
		Rainmaker.BuildPersistentEffect(1, true);
		Rainmaker.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false, ,Template.AbilitySourceName);

		//	Cycle through all abilities, if any of them add the Rainmaker effect, add our effect in parallel.
		foreach AbilityTemplateManager.IterateTemplates(DataTemplate, none)
		{
			Template = X2AbilityTemplate(DataTemplate);
			if (Template != none)
			{
				foreach Template.AbilityShooterEffects(Effect)
				{
					if (X2Effect_DLC_3Rainmaker(Effect) != none)
					{
						Template.AddShooterEffect(Rainmaker);
						break;
					}
				}
			
				foreach Template.AbilityTargetEffects(Effect)
				{
					if (X2Effect_DLC_3Rainmaker(Effect) != none)
					{
						Template.AddShooterEffect(Rainmaker);
						break;
					}
				}

				foreach Template.AbilityMultiTargetEffects(Effect)
				{
					if (X2Effect_DLC_3Rainmaker(Effect) != none)
					{
						Template.AddMultiTargetEffect(Rainmaker);
						break;
					}
				}
			}
		}
	}
	else `LOG("ERROR, Could not find Rainmaker ability template.",, 'WOTCMoreSparkWeapons');
}	

static function PatchRepair()
{
	local X2AbilityTemplateManager		AbilityTemplateManager;
	local X2AbilityTemplate				Template;
	local X2Condition_SourceWeaponCat	WeaponCondition;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Template = AbilityTemplateManager.FindAbilityTemplate('Repair');
	if (Template != none)
	{
		WeaponCondition = new class'X2Condition_SourceWeaponCat';
		WeaponCondition.MatchWeaponCat = 'sparkbit';
		Template.AbilityShooterConditions.AddItem(WeaponCondition);
	}
	else `LOG("ERROR, Could not find Repair ability template.",, 'WOTCMoreSparkWeapons');
}	

static function AddActveCamoToBITs()
{
	local X2WeaponTemplate              WeaponTemplate;
    local array<X2WeaponTemplate>       arrWeaponTemplates;
    local X2ItemTemplateManager         ItemMgr;

	//	Add my Active Camo to all Spark BITs
    ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

    arrWeaponTemplates = ItemMgr.GetAllWeaponTemplates();

    foreach arrWeaponTemplates(WeaponTemplate)
    {
        if (WeaponTemplate.WeaponCat == 'sparkbit')
        {
			WeaponTemplate.Abilities.AddItem('IRI_ActiveCamo');
        }
    }
}

static function CopyLocalizationForAbilities()
{
    local X2AbilityTemplateManager  AbilityTemplateManager;

    //  Get the Ability Template Manager.
    AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	CopyLocalization(AbilityTemplateManager, 'IRI_SparkRocketLauncher', 'SparkRocketLauncher');
	CopyLocalization(AbilityTemplateManager, 'IRI_SparkShredderGun', 'SparkShredderGun');
	CopyLocalization(AbilityTemplateManager, 'IRI_SparkShredstormCannon', 'SparkShredstormCannon');
	CopyLocalization(AbilityTemplateManager, 'IRI_SparkFlamethrower', 'SparkFlamethrower');
	CopyLocalization(AbilityTemplateManager, 'IRI_SparkFlamethrowerMk2', 'SparkFlamethrowerMk2');
	CopyLocalization(AbilityTemplateManager, 'IRI_SparkBlasterLauncher', 'SparkBlasterLauncher');
	CopyLocalization(AbilityTemplateManager, 'IRI_SparkPlasmaBlaster', 'SparkPlasmaBlaster');

	CopyLocalization(AbilityTemplateManager, 'IRI_Bombard', 'Bombard');
}

static function CopyLocalization(X2AbilityTemplateManager AbilityTemplateManager, name TemplateName, name DonorTemplateName)
{
	local X2AbilityTemplate Template;
	local X2AbilityTemplate DonorTemplate;

	Template = AbilityTemplateManager.FindAbilityTemplate(TemplateName);
	DonorTemplate = AbilityTemplateManager.FindAbilityTemplate(DonorTemplateName);

	if (Template != none && DonorTemplate != none)
	{
		Template.LocFriendlyName = DonorTemplate.LocFriendlyName;
		Template.LocHelpText = DonorTemplate.LocHelpText;                   
		Template.LocLongDescription = DonorTemplate.LocLongDescription;
		Template.LocPromotionPopupText = DonorTemplate.LocPromotionPopupText;
		Template.LocFlyOverText = DonorTemplate.LocFlyOverText;
		Template.LocMissMessage = DonorTemplate.LocMissMessage;
		Template.LocHitMessage = DonorTemplate.LocHitMessage;
		Template.LocFriendlyNameWhenConcealed = DonorTemplate.LocFriendlyNameWhenConcealed;      
		Template.LocLongDescriptionWhenConcealed = DonorTemplate.LocLongDescriptionWhenConcealed;   
		Template.LocDefaultSoldierClass = DonorTemplate.LocDefaultSoldierClass;
		Template.LocDefaultPrimaryWeapon = DonorTemplate.LocDefaultPrimaryWeapon;
		Template.LocDefaultSecondaryWeapon = DonorTemplate.LocDefaultSecondaryWeapon;
	}
	else `LOG("ERROR, could not access ability template:" @ TemplateName @ Template == none @ DonorTemplateName @ DonorTemplate == none,, 'WOTCMoreSparkWeapons');
}

static function string DLCAppendSockets(XComUnitPawn Pawn)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Pawn.ObjectID));

	if (UnitState != none && (default.SparkCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE))
	{
		//`LOG("Adding spark sockets to" @ UnitState.GetFullName(),, 'IRITEST');
		return "IRIOrdnanceLauncher.Meshes.Spark_Sockets";
	}
	return "";
}


static function GetNumUtilitySlotsOverride(out int NumUtilitySlots, XComGameState_Item EquippedArmor, XComGameState_Unit UnitState, XComGameState CheckGameState)
{
	local XComGameState_Item ItemState;

	//	TODO:  Replace this with Grenade Pocket once CHL is out
	ItemState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);
	if (ItemState != none && ItemState.GetWeaponCategory() == 'iri_ordnance_launcher')
	{
		NumUtilitySlots++;
	}
}

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local XComGameState_Item		ItemState;
	//local array<XComGameState_Item>	InventoryItems;
	//local AbilitySetupData			Data, EmptyData;
	local X2AbilityTemplate			AbilityTemplate;
	local StateObjectReference		GrenadeLauncherRef;
	//local X2GrenadeTemplate			GrenadeTemplate;
	local X2AbilityTemplateManager  AbilityTemplateManager;
	local int Index;

	//`LOG("Finalize abilities for unit:",, 'IRILOG');
	if (default.SparkCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE)
	{
		ItemState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);
		if (ItemState != none && ItemState.GetWeaponCategory() == 'iri_ordnance_launcher')
		{
			//	If the unit is a SPARK / MEC with an Ordnance Launcher
			`LOG("Found SPARK with a grenade launcher",, 'IRILOG');
			GrenadeLauncherRef = ItemState.GetReference();
			AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();			
			AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('IRI_LaunchOrdnance');

			//	Cycle through all abilities that are about to be Initialized
			for (Index = SetupData.Length - 1; Index >= 0; Index--)
			{
				//	Lookup its template name and replace or remove the ability.
				switch (SetupData[Index].TemplateName)
				{
					case 'ThrowGrenade':	//	Replace instances of Throw Grenade with Launch Ordnance. Pet two foxes with one arm.
						SetupData[Index].TemplateName = 'IRI_LaunchOrdnance';
						SetupData[Index].Template = AbilityTemplate;
						SetupData[Index].SourceAmmoRef = SetupData[Index].SourceWeaponRef;
						SetupData[Index].SourceWeaponRef = GrenadeLauncherRef;
						break;
					case 'LaunchGrenade':	//	Remove instances of Launch Grenade. There shouldn't be a way for them to be here, but just in case.
						SetupData.Remove(Index, 1);
						break;
					case 'SparkRocketLauncher':
						SetupData[Index].TemplateName = 'IRI_SparkRocketLauncher';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkRocketLauncher');
						break;
					case 'SparkShredderGun':
						SetupData[Index].TemplateName = 'IRI_SparkShredderGun';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkShredderGun');
						break;
					case 'SparkShredstormCannon':
						SetupData[Index].TemplateName = 'IRI_SparkShredstormCannon';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkShredstormCannon');
						break;
					case 'SparkFlamethrower':
						SetupData[Index].TemplateName = 'IRI_SparkFlamethrower';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkFlamethrower');
						break;
					case 'SparkFlamethrowerMk2':
						SetupData[Index].TemplateName = 'IRI_SparkFlamethrowerMk2';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkFlamethrowerMk2');
						break;
					case 'SparkBlasterLauncher':
						SetupData[Index].TemplateName = 'IRI_SparkBlasterLauncher';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkBlasterLauncher');
						break;
					case 'SparkPlasmaBlaster':
						SetupData[Index].TemplateName = 'IRI_SparkPlasmaBlaster';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkPlasmaBlaster');
						break;
					case 'Bombard':
						SetupData[Index].TemplateName = 'IRI_Bombard';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_Bombard');
						SetupData[Index].SourceWeaponRef = GrenadeLauncherRef;
						break;
					case 'IRI_FireRocket':
						SetupData[Index].TemplateName = 'IRI_FireRocket_Spark';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_FireRocket_Spark');
						break;
					case 'IRI_FireSabot':
						SetupData[Index].TemplateName = 'IRI_FireSabot_Spark';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_FireSabot_Spark');
						break;
					case 'IRI_FireLockon':
						SetupData[Index].TemplateName = 'IRI_FireLockon_Spark';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_FireLockon_Spark');
						break;
					case 'IRI_LockAndFireLockon':
						SetupData[Index].TemplateName = 'IRI_LockAndFireLockon_Spark';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_LockAndFireLockon_Spark');
						break;
					case 'IRI_LockAndFireLockon_Holo':
						SetupData[Index].TemplateName = 'IRI_LockAndFireLockon_Holo_Spark';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_LockAndFireLockon_Holo_Spark');
						break;
					case 'IRI_FireTacticalNuke':
						SetupData[Index].TemplateName = 'IRI_FireTacticalNuke_Spark';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_FireTacticalNuke_Spark');
						break;
					case 'IRI_Fire_PlasmaEjector':
						SetupData[Index].TemplateName = 'IRI_Fire_PlasmaEjector_Spark';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_Fire_PlasmaEjector_Spark');
						break;
					default:
						break;
				}
			}
		}
	}
}

static function WeaponInitialized(XGWeapon WeaponArchetype, XComWeapon Weapon, optional XComGameState_Item ItemState=none)
{
    Local XComGameState_Item	InternalWeaponState, SecondaryWeaponState;
	local XComGameState_Unit	UnitState;
	local X2GrenadeTemplate		GrenadeTemplate;
	local X2WeaponTemplate		WeaponTemplate;
	local XComContentManager	Content;

    if (ItemState == none) 
	{	
		InternalWeaponState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(WeaponArchetype.ObjectID));
		`redscreen("SPARK Weapons: Weapon Initialized -> Had to reach into history to get Internal Weapon State.-Iridar");
	}
	else InternalWeaponState = ItemState;

	if (InternalWeaponState != none)
	{
		Content = `CONTENT;
		WeaponTemplate = X2WeaponTemplate(InternalWeaponState.GetMyTemplate());

		if (WeaponTemplate != none && WeaponTemplate.WeaponCat == 'iri_ordnance_launcher')
		{
			if (default.bRocketLaunchersModPresent)
			{
				switch (WeaponTemplate.WeaponTech)
				{
					case 'magnetic':
						SkeletalMeshComponent(Weapon.Mesh).AnimSets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_OrdnanceLauncher_MG_Rockets")));
					case 'beam':
					case 'conventional':
					default:
						SkeletalMeshComponent(Weapon.Mesh).AnimSets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_OrdnanceLauncher_CV_Rockets")));
						break;
				}	
			}
			return;
		}
		else if(InternalWeaponState.GetWeaponCategory() == 'heavy')
		{
			UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(InternalWeaponState.OwnerStateObject.ObjectID));
			if (UnitState == none) 
			{
				//`redscreen("SPARK Weapons: Weapon Initialized -> no Unit State!-Iridar");
				return;
			}

			SecondaryWeaponState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);
			if (SecondaryWeaponState != none && SecondaryWeaponState.GetWeaponCategory() != 'sparkbit' && 
				(default.SparkCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE))
			{
				//	This is a Heavy Weapon and this is SPARK / MEC that doesn't have a BIT equipped.
				Weapon.CustomUnitPawnAnimsets.Length = 0;
				SkeletalMeshComponent(Weapon.Mesh).SkeletalMesh = SkeletalMesh(Content.RequestGameArchetype("IRISparkHeavyWeapons.Meshes.SM_SparkHeavyWeapon"));
				SkeletalMeshComponent(Weapon.Mesh).AnimSets.AddItem(AnimSet(Content.RequestGameArchetype("IRISparkHeavyWeapons.Anims.AS_Heavy_Weapon")));
				Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRISparkHeavyWeapons.Anims.AS_Heavy_Spark")));

				`LOG("Patched heavy weapon for a SPARK.",, 'IRITEST');
				return;
			}
		}
		
		if (default.bRocketLaunchersModPresent)
		{
			GrenadeTemplate = X2GrenadeTemplate(InternalWeaponState.GetMyTemplate());

			if (GrenadeTemplate != none && GrenadeTemplate.WeaponCat == 'rocket')
			{
				UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(InternalWeaponState.OwnerStateObject.ObjectID));
				if (UnitState != none && (UnitState.GetMyTemplateName() == 'SparkSoldier' || UnitState.GetMyTemplateName() == 'XComMecSoldier'))
				{
					//Weapon.DefaultSocket = '';

					Weapon.CustomUnitPawnAnimsets.Length = 0;
					//	Firing animations
					Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRIOrdnanceLauncher.Anims.AS_OrdnanceLauncher")));

					//	Give Rocket and stuff. Take Rocket is added to character templates in Rocket Launchers mod, because eveery spark must be able to Take Rockets before their Weapon is initialized.
					Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_SPARK_Rocket")));
					if (GrenadeTemplate.DataName == 'IRI_X2Rocket_Lockon_T3')
					{	
						Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_SPARK_LockonT3")));
					}
				}
			}
		}
	}		
}
/*
static function UpdateWeaponMaterial(XGWeapon WeaponArchetype, MeshComponent MeshComp)
{
	local int i;
	local MaterialInterface Mat;
	local MaterialInstanceConstant MIC;

	if (MeshComp != none && XComWeapon(WeaponArchetype.m_kEntity).DefaultSocket == 'HeavyWeapon')
	{
		`LOG(GetFuncName() @ XComWeapon(WeaponArchetype.m_kEntity).DefaultSocket @ MeshComp.GetNumElements(),, 'IRISPARK');

		for (i = 0; i < MeshComp.GetNumElements(); ++i)
		{
			Mat = MeshComp.GetMaterial(i);
			MIC = MaterialInstanceConstant(Mat);
			if (MIC != none)
			{
				MIC.
				`LOG(MIC.Name,, 'X2JediClassWotc');
			}	
		}
	}	
}*/