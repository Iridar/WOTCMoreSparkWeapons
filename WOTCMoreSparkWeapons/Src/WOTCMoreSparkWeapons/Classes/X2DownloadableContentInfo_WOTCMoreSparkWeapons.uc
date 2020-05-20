class X2DownloadableContentInfo_WOTCMoreSparkWeapons extends X2DownloadableContentInfo;

var config(SparkWeapons) array<name> SparkCharacterTemplates;
var config(SparkWeapons) bool bRocketLaunchersModPresent;
var config(SparkWeapons) bool bAlwaysUseArmCannonAnimationsForHeavyWeapons;
var config(GameData_WeaponData) bool bOrdnanceAmplifierUsesBlasterLauncherTargeting;

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

//	Template Highlander Slots for the Ordnance Launcher
//	Check armory weapon tinting - make sure it persists!

//	Uncouple BIT from the SPARK - investigate log warning
//	Move hacking to BIT
//	BIT for Specialists? Include Active Camo animation for specialists.
//	Weak railgun heavy weapon
//	Make rocket movement penalty not applied to SPARKs

//	Icon for Active Camo
//	KSM Icon: Texture2D'UILibrary_PerkIcons.UIPerk_mecclosecombat'

//	Sparkfall within the context of this mod?

//	Cannon loading sound
//AkEvent'XPACK_SoundEnvironment.Crate_Extract_Advent_Crate_Grab'

//	Music for release vid?
// https://youtu.be/YLp62WwnGSU

//	KSM as a heavy weapon. Competes with the flamethrower, keeping it similar to EW. Also mounts on the same left arm. Makes sense.
//	Restorative Mist and Electo Pulse go into utility slot, competing with SPARK Launcher Redux. If BIT is equipped, BIT is used to deploy them. If not, they deploy around the SPARK.
//	Pulse is more of an AoE bot stun with small damage. Nova's just straight damage, and it damages the SPARK. it's also limited to them.

/*
Simple tech on custom death animations: 
Apply an AnimSet to the target with a custom death animation (same name as original death animation, check if you need to replace several animations with different names at once.
Might be necessary to apply the AnimSet before the ability goes through. In that case, apply it with a separate ability with an AbilityActivated event listener trigger that works during interrupt stage. 
Make sure to un-apply the AnimSet effect afterwards in case the target doesn't die.
*/

/*
Ordnance Projector
Ordnance Amplifier -> Lago 508
Kinetic Collision Module
 inetic Drive Module / Kinetic Driver*/

static event OnPostTemplatesCreated()
{
	PatchCharacterTemplates();
	CopyLocalizationForAbilities();
	PatchRainmaker();
	PatchRepair();
	PatchWeaponTemplates();
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
			CharTemplate.strMatineePackages.AddItem("CIN_IRI_QuickWideHighSpark");
			
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

static function PatchWeaponTemplates()
{
	local X2WeaponTemplate              WeaponTemplate;
    local array<X2WeaponTemplate>       arrWeaponTemplates;
    local X2ItemTemplateManager         ItemMgr;
	local X2GrenadeTemplate				GrenadeTemplate;
	local AbilityIconOverride			IconOverride;

    ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
    arrWeaponTemplates = ItemMgr.GetAllWeaponTemplates();

    foreach arrWeaponTemplates(WeaponTemplate)
    {
		//	Add my Active Camo to all Spark BITs
        if (WeaponTemplate.WeaponCat == 'sparkbit')
        {
			WeaponTemplate.Abilities.AddItem('IRI_ActiveCamo');
        }

		//	Duplicate Launch Grenade icons for my Launch Ordnance abilities.
		GrenadeTemplate = X2GrenadeTemplate(WeaponTemplate);
		if (GrenadeTemplate != none)
		{
			foreach GrenadeTemplate.AbilityIconOverrides(IconOverride)
			{
				if (IconOverride.AbilityName == 'LaunchGrenade')
				{
					if (default.bOrdnanceAmplifierUsesBlasterLauncherTargeting)
					{
						GrenadeTemplate.AddAbilityIconOverride('IRI_BlastOrdnance', IconOverride.OverrideIcon);
					}
					GrenadeTemplate.AddAbilityIconOverride('IRI_LaunchOrdnance', IconOverride.OverrideIcon);
				}
			}
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

			//	Prep the ability we're gonna be attaching to grenades.
			AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();		
			if (default.bOrdnanceAmplifierUsesBlasterLauncherTargeting && ItemState.GetMyTemplateName() == 'IRI_OrdnanceLauncher_BM')
			{
				AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('IRI_BlastOrdnance');
			}
			else
			{
				AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('IRI_LaunchOrdnance');
			}
			
			//	Cycle through all abilities that are about to be Initialized
			for (Index = SetupData.Length - 1; Index >= 0; Index--)
			{
				//	Lookup its template name and replace or remove the ability.
				switch (SetupData[Index].TemplateName)
				{
					case 'ThrowGrenade':	//	Replace instances of Throw Grenade with Launch Ordnance. Pet two foxes with one arm.
						SetupData[Index].TemplateName = AbilityTemplate.DataName;
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
		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(InternalWeaponState.OwnerStateObject.ObjectID));
		WeaponTemplate = X2WeaponTemplate(InternalWeaponState.GetMyTemplate());

		if (UnitState != none && (default.SparkCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE) && WeaponTemplate != none)
		{
			//	Initial checks complete, this is a weapon equipped on a SPARK.

			Content = `CONTENT;
			
			//	If this is an Ordnance Launcher and the Rocket Launchers mod is present, add Weapon Animations for firing rockets.
			if (WeaponTemplate.WeaponCat == 'iri_ordnance_launcher' && default.bRocketLaunchersModPresent)
			{
				switch (WeaponTemplate.WeaponTech)
				{
					case 'magnetic':
						SkeletalMeshComponent(Weapon.Mesh).AnimSets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_OrdnanceLauncher_MG_Rockets")));
						break;
					case 'beam':
						SkeletalMeshComponent(Weapon.Mesh).AnimSets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_OrdnanceLauncher_BM_Rockets")));
						break;
					case 'conventional':
					default:
						SkeletalMeshComponent(Weapon.Mesh).AnimSets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_OrdnanceLauncher_CV_Rockets")));
						break;
				}	
				return;
			}
			
			//	If this is a Heavy Weapon, and the SPARK doesn't have a BIT equipped, or if the mod is configured to always use the Arm Cannon animations for heavy weapons
			if (WeaponTemplate.WeaponCat == 'heavy' && (default.bAlwaysUseArmCannonAnimationsForHeavyWeapons || !class'X2Condition_HasWeaponOfCategory'.static.DoesUnitHaveBITEquipped(UnitState)))
			{
				//	Replace the mesh for this heavy weapon with the arm cannon and replace the weapon and pawn animations.
				Weapon.CustomUnitPawnAnimsets.Length = 0;
				SkeletalMeshComponent(Weapon.Mesh).SkeletalMesh = SkeletalMesh(Content.RequestGameArchetype("IRISparkHeavyWeapons.Meshes.SM_SparkHeavyWeapon"));
				SkeletalMeshComponent(Weapon.Mesh).AnimSets.AddItem(AnimSet(Content.RequestGameArchetype("IRISparkHeavyWeapons.Anims.AS_Heavy_Weapon")));
				Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRISparkHeavyWeapons.Anims.AS_Heavy_Spark")));

				//`LOG("Patched heavy weapon for a SPARK.",, 'IRITEST');
				return;
			}

			//	If the rocket launchers mod is installed
			if (default.bRocketLaunchersModPresent)
			{
				//	And this weapon is a rocket
				GrenadeTemplate = X2GrenadeTemplate(InternalWeaponState.GetMyTemplate());
				if (GrenadeTemplate != none && GrenadeTemplate.WeaponCat == 'rocket')
				{
					//	Check if the Secondary Weapon is an Ordnance Launcher
					SecondaryWeaponState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);
					if (SecondaryWeaponState != none)
					{
						WeaponTemplate = X2WeaponTemplate(SecondaryWeaponState.GetMyTemplate());
					}
					if (WeaponTemplate != none && WeaponTemplate.WeaponCat == 'iri_ordnance_launcher')
					{
						//	Replace the rocket's Pawn Animations with the ones made for the Ordnance Launcher.
						Weapon.CustomUnitPawnAnimsets.Length = 0;
						//	Firing animations
						//	Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRIOrdnanceLauncher.Anims.AS_OrdnanceLauncher")));

						//	Give Rocket and stuff. Take Rocket is added to character templates in Rocket Launchers mod, because eveery spark must be able to Take Rockets before their Weapon is initialized.
						Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_SPARK_Rocket")));

						//	Attach additional Anim Sets based on the tier of the launcher.
						switch (WeaponTemplate.WeaponTech)
						{
							case 'magnetic':
								Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_SPARK_Rocket_MG")));
								break;
							case 'beam':
								Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_SPARK_Rocket_BM")));
								break;
							case 'conventional':
							//	Basic anims are enough for conventional.
							default:
								break;
						}	
						//	T3 Lockon rocket gets its own firing animation with a different Play Socket Animation notify to play a different "rocket flying in the sky" cosmetic PFX.
						if (GrenadeTemplate.DataName == 'IRI_X2Rocket_Lockon_T3')
						{	
							switch (WeaponTemplate.WeaponTech)
							{
								case 'magnetic':
									Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_SPARK_LockonT3_MG")));
									break;
								case 'beam':
									Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_SPARK_LockonT3_BM")));
									break;
								case 'conventional':
									Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRI_MECRockets.Anims.AS_SPARK_LockonT3")));
								default:
									break;
							}
						}
					}
				}
			}
		}
	}		
}