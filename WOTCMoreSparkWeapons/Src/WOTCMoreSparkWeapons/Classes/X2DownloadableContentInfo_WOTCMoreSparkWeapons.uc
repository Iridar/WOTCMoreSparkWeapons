class X2DownloadableContentInfo_WOTCMoreSparkWeapons extends X2DownloadableContentInfo;

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
//	Cinecam for Launch Grenade (based on Micro Missiles which uses CIN_Quick_Wide in CIN_Soldier
//	Same for Fire Rocket
//	Same for Fire Sabot
//	Arm Rocket animation
//	Animation and cine cam for Plasma Ejector
//	Check all other rockets

//	Mag tier model
//	Beam tier model
//	Set to use Grenade Launcher schematics
//	Localization
//	In-game weapon icons

static event OnPostTemplatesCreated()
{
    local X2CharacterTemplateManager    CharMgr;
    local X2CharacterTemplate           CharTemplate;

    //  Get the Character Template Modify
    CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

    //  Access a specific Character Template.
    CharTemplate = CharMgr.FindCharacterTemplate('SparkSoldier');

    //  If template was found
    if (CharTemplate != none)
    {
        CharTemplate.strMatineePackages.AddItem("CIN_IRI_Lockon");
		`LOG("Patched matinee",, 'IRITEST');
    }
}


static function string DLCAppendSockets(XComUnitPawn Pawn)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Pawn.ObjectID));

	if (UnitState != none && (UnitState.GetMyTemplateName() == 'SparkSoldier' || UnitState.GetMyTemplateName() == 'XComMecSoldier'))
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
	if (UnitState.GetMyTemplateName() == 'SparkSoldier' || UnitState.GetMyTemplateName() == 'XComMecSoldier')
	{
		ItemState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);
		if (ItemState != none && ItemState.GetWeaponCategory() == 'iri_ordnance_launcher')
		{
			NumUtilitySlots++;
		}
	}
}

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local XComGameState_Item		ItemState;
	local array<XComGameState_Item>	InventoryItems;
	local AbilitySetupData			Data, EmptyData;
	local X2AbilityTemplate			AbilityTemplate;
	local StateObjectReference		GrenadeLauncherRef;
	local X2GrenadeTemplate			GrenadeTemplate;

	//`LOG("Finalize abilities for unit:",, 'IRILOG');

	if (UnitState.GetMyTemplateName() == 'SparkSoldier' || UnitState.GetMyTemplateName() == 'XComMecSoldier')
	{
		ItemState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);
		if (ItemState != none && ItemState.GetWeaponCategory() == 'iri_ordnance_launcher')
		{
			//	If the unit is a SPARK / MEC with an Ordnance Launcher
			`LOG("Found SPARK with a grenade launcher",, 'IRILOG');
			GrenadeLauncherRef = ItemState.GetReference();
			AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('IRI_LaunchOrdnance');

			//	Cycle through all Item States in the Unit's inventory
			InventoryItems = UnitState.GetAllInventoryItems(StartState);
			foreach InventoryItems(ItemState)
			{
				if (ItemState.bMergedOut) continue;

				//	If we find a grenade item
				GrenadeTemplate = X2GrenadeTemplate(ItemState.GetMyTemplate());
				if (GrenadeTemplate != none)
				{ 
					//	If the grenade item is NOT a rocket add Launch Ordnance to it
					if (GrenadeTemplate.WeaponCat != 'rocket')
					{
						Data = EmptyData;
						Data.TemplateName = 'IRI_LaunchOrdnance';
						Data.Template = AbilityTemplate;
						Data.SourceWeaponRef = GrenadeLauncherRef;
						Data.SourceAmmoRef = ItemState.GetReference();
						SetupData.AddItem(Data);
					}
				}
			}
		}
	}
}

static function WeaponInitialized(XGWeapon WeaponArchetype, XComWeapon Weapon, optional XComGameState_Item ItemState=none)
{
    Local XComGameState_Item	InternalWeaponState;
	local XComGameState_Unit	UnitState;
	local X2GrenadeTemplate		GrenadeTemplate;

    if (ItemState == none) 
	{	
		InternalWeaponState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(WeaponArchetype.ObjectID));
		`redscreen("SPARK Weapons: Weapon Initialized -> Had to reach into history to get Internal Weapon State.-Iridar");
	}
	else InternalWeaponState = ItemState;

	if (InternalWeaponState != none)
	{
		if (InternalWeaponState.GetWeaponCategory() == 'iri_ordnance_launcher')
		{
			SkeletalMeshComponent(Weapon.Mesh).AnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("IRI_MECRockets.Anims.AS_OrdnanceLauncher_Lockon")));
			return;
		}
		
		GrenadeTemplate = X2GrenadeTemplate(InternalWeaponState.GetMyTemplate());

		if (GrenadeTemplate != none && GrenadeTemplate.WeaponCat == 'rocket')
		{
			UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(InternalWeaponState.OwnerStateObject.ObjectID));
			if (UnitState != none && (UnitState.GetMyTemplateName() == 'SparkSoldier' || UnitState.GetMyTemplateName() == 'XComMecSoldier'))
			{
				//Weapon.DefaultSocket = '';

				Weapon.CustomUnitPawnAnimsets.Length = 0;
				//	Firing animations
				Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("IRIOrdnanceLauncher.Anims.AS_OrdnanceLauncher")));

				//	Give Rocket and stuff
				Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("IRI_MECRockets.Anims.AS_SPARK_Rocket")));
			}
		}
	}		
}