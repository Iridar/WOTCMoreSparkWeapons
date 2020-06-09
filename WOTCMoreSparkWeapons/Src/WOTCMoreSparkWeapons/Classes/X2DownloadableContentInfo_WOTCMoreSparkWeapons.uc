class X2DownloadableContentInfo_WOTCMoreSparkWeapons extends X2DownloadableContentInfo;

var config(SparkWeapons) array<name> SparkCharacterTemplates;
var config(SparkWeapons) bool bRocketLaunchersModPresent;
var config(SparkWeapons) bool bAlwaysUseArmCannonAnimationsForHeavyWeapons;
var config(SparkWeapons) bool bRemoveHeavyWeaponSlotWithoutBIT;
var config(SparkWeapons) array<name> WeaponCategoriesAddHeavyWeaponSlot;
var config(SparkWeapons) array<name> StartingItemsToAddOnSaveLoad;
var config(OrdnanceLaunchers) bool bOrdnanceAmplifierUsesBlasterLauncherTargeting;

var config(KineticStrikeModule) array<name> MeleeAbilitiesUseKSM;

var config(ClassData) array<name> ClassesToRemoveAbilitiesFrom;
var config(ClassData) array<name> AbilitiesToRemove;

//	Immedaite goals:

//	Check Mechatronic Warfare and MEC Troopers ability trees for incompatibilities, ABB, Metal Over Flesh
//	Balance Heavy Weapons in Aux Slot, and the Aux Slot itself

//	Compatibility config for grenade scatter mod and grenade rebalance mod
//	release video
//	Icon for EM pulse without a BIT, icon for KSM melee damage bonus

//	Codex -> grab skull as they attempt to flicker all over the place and crush it
//	## ADVENT grunts -> stratosphere
//	## Shieldbearers -> double down
//	## Berserker - Rip the heart out
//	Andromedon - break the glass, kill the pilot
//	Sectoid - knock over, stomp on the head
//	Faceless - flaming elbow drop
//	High stance Sectopod -> jump on the jump jet and strike right into the Wrath cannon as it opens up
//	Archon - bitchslap?
//	Muton - break their weapon with a punch, then kill them with a second one.
//	Riftkeeper -> punch away their plating? or stick it right into their eye? Smash them into the ground?
//	Purifier -> use them as an explosive grenade?
//	KSM kill animation: https://youtu.be/m8H-FDOLxz0

//	Ammo Canister -> +1 Heavy Weapon shot, +1 Ordnance Launcher slot?
//	BIT - Repair Servos (restore 2HP a turn to a maximum of 6 per mission)?
//	BIT - AOE holotarget?
//	BIT - make Active Camo scale with BIT tier?

//	Artillery Cannons
//	support for Demolition

//	LOW PRIORITY
//	Textures are too dark in Photobooth.
//	Sparkfall within the context of this mod?
//	Better heart material for bers heart
//	KSM Tintable
//	During KSM kills, delay damage flyover.
//	Change KSM Exhaust flames so they turn off gradually instead of instantly.
//	Add more effects to EM Pulse against fully-augmented soldiers, make a "Augment disabled!" flyover. Blind for head (eyes)
//	Fix BIT EM Pulse visualization - at least make the Spark play finger-pointing animation and make multi target effects visualize at the same time. Ideally, make SPARK play EM Charge animation, and then have the energy zap to the BIT. Perhaps, Perk Content tether (or Volt projectile)
//	Resto Mist - improve textures and tintable
//	BIT for Specialists? If so, include Active Camo animation for them.

/*	Investigate logs:
[0155.04] Log: No animation compression exists for sequence NO_SensorSweepA (AnimSet Bit.Anims.AS_BeamBit)
[0155.04] Log: FAnimationUtils::CompressAnimSequence NO_SensorSweepA (AnimSet Bit.Anims.AS_BeamBit) SkelMesh not valid, won't be able to use RemoveLinearKeys.
[0155.04] Log: Compression Requested for Empty Animation NO_SensorSweepA
*/

//	LONG TERM:
//	1) Make equipping a BIT autoequip a Heavy Weapon once this is merged: https://github.com/X2CommunityCore/X2WOTCCommunityHighlander/issues/741
//	2) Get rid of OverrideHasHeavyWeapon Event Listener when this is merged: https://github.com/X2CommunityCore/X2WOTCCommunityHighlander/issues/881
//	3) Make it possible to carry EM Pulse and Resto Heal by regular soldiers in the Heavy Weapon slot when this is merged: https://github.com/X2CommunityCore/X2WOTCCommunityHighlander/issues/844

//	EXPLOITABLE STUFF
//	Music for release vid?
// https://youtu.be/YLp62WwnGSU

//	Cannon loading sound
//	AkEvent'XPACK_SoundEnvironment.Crate_Extract_Advent_Crate_Grab'
//	Click sounds
//	AkEvent'SoundUnreal3DSounds.Unreal3DSounds_GrabSyringe'

/*	LOCALIZATION
//	Kinetic Strike Module
//	Kinetic Assault Module
//	Kinetic Barrage Module
//	Kinetic Collision Module
	Kinetic Drive Module 
	Kinetic Driver
	Ordnance Projector
*/

/// <summary>
/// This method is run when the player loads a saved game directly into Strategy while this DLC is installed
/// </summary>
static event OnLoadedSavedGameToStrategy()
{
	local XComGameStateHistory				History;
	local XComGameState						NewGameState;
	local XComGameState_HeadquartersXCom	XComHQ;
	local XComGameState_Item				ItemState;
	local X2ItemTemplate					ItemTemplate;
	local name								TemplateName;
	local X2ItemTemplateManager				ItemMgr;
	local bool								bChange;
	local X2StrategyElementTemplateManager	StratMgr;

	History = `XCOMHISTORY;	
	XComHQ = `XCOMHQ;
	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("WOTCMoreSparkWeapons: Add Starting Items");
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	//	Add an instance of the specified item template into HQ inventory
	foreach default.StartingItemsToAddOnSaveLoad(TemplateName)
	{
		ItemTemplate = ItemMgr.FindItemTemplate(TemplateName);

		if (ItemTemplate != none && ItemTemplate.StartingItem && !XComHQ.HasItem(ItemTemplate))
		{	
			ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
			NewGameState.AddStateObject(ItemState);
			XComHQ.AddItemToHQInventory(ItemState);	

			bChange = true;
		}
	}

	if (bChange)
	{
		History.AddGameStateToHistory(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	AddProvingGroundsProjectIfItsNotPresent(StratMgr, 'IRI_ArmCannon_Tech');
}


static function AddProvingGroundsProjectIfItsNotPresent(X2StrategyElementTemplateManager StratMgr, name ProjectName)
{
	local XComGameState		NewGameState;
	local X2TechTemplate	TechTemplate;

	if (!IsResearchInHistory(ProjectName))
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Research Templates");

		TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate(ProjectName));
		NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);

		`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	}
}

static function bool IsResearchInHistory(name ResearchName)
{
	// Check if we've already injected the tech templates
	local XComGameState_Tech	TechState;
	local XComGameStateHistory	History;
	
	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_Tech', TechState)
	{
		if ( TechState.GetMyTemplateName() == ResearchName )
		{
			return true;
		}
	}
	return false;
}

static event OnPostTemplatesCreated()
{
	PatchSoldierClassTemplates();
	PatchCharacterTemplates();
	CopyLocalizationForAbilities();
	PatchAbilityTemplates();
	PatchWeaponTemplates();
	class'KSMHelper'.static.AddDeathAnimSetsToCharacterTemplates();
}

static function PatchSoldierClassTemplates()
{		
	local X2SoldierClassTemplateManager Manager;
	local X2SoldierClassTemplate		SoldierClassTemplate;
	local name							TemplateName;
	local int i;

	Manager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();

	foreach default.ClassesToRemoveAbilitiesFrom(TemplateName)
	{
		SoldierClassTemplate = Manager.FindSoldierClassTemplate(TemplateName);

		//	Requires unprotecting X2SoldierClassTemplate::SoldierRanks
		if (SoldierClassTemplate != none && SoldierClassTemplate.SoldierRanks.Length > 0)
		{
			for (i = SoldierClassTemplate.SoldierRanks[0].AbilitySlots.Length - 1; i >= 0; i--)
			{
				if (default.AbilitiesToRemove.Find(SoldierClassTemplate.SoldierRanks[0].AbilitySlots[i].AbilityType.AbilityName) != INDEX_NONE)
				{
					SoldierClassTemplate.SoldierRanks[0].AbilitySlots.Remove(i, 1);
				}
			}
		}		
	}	 
}

static function GetNumHeavyWeaponSlotsOverride(out int NumHeavySlots, XComGameState_Unit UnitState, XComGameState CheckGameState)
{
	if (default.bRemoveHeavyWeaponSlotWithoutBIT && 
		default.SparkCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE && 
		!class'X2Condition_HasWeaponOfCategory'.static.DoesUnitHaveBITEquipped(UnitState))
	{
		//	Remove one Heavy Weapon slot if the SPARK doesn't have a BIT equipped.
		NumHeavySlots--;
	}
}

static function PatchCharacterTemplates()
{
    local X2CharacterTemplateManager    CharMgr;
    local X2CharacterTemplate           CharTemplate;
	local name							CharTemplateName;
	local array<X2DataTemplate>			DifficultyVariants;
	local X2DataTemplate				DifficultyVariant;
	local XComContentManager			Content;
	
    CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	Content = `CONTENT;

	foreach default.SparkCharacterTemplates(CharTemplateName)
	{
		CharMgr.FindDataTemplateAllDifficulties(CharTemplateName, DifficultyVariants);
		foreach DifficultyVariants(DifficultyVariant)
		{
			CharTemplate = X2CharacterTemplate(DifficultyVariant);

			if (CharTemplate != none)
			{
				//	Remove Active Camo from char templates. We'll add it to BIT instead.
				CharTemplate.Abilities.RemoveItem('ActiveCamo');
				//	Add an ability that debuffs detection radius when concealed
				CharTemplate.Abilities.AddItem('IRI_SparkDebuffConcealment');

				//	Always attach Lockon Matinee cuz it's also used by Bombard
				CharTemplate.strMatineePackages.AddItem("CIN_IRI_Lockon");
			
				CharTemplate.strMatineePackages.AddItem("CIN_IRI_QuickWideSpark");
				CharTemplate.strMatineePackages.AddItem("CIN_IRI_QuickWideHighSpark");

				CharTemplate.AdditionalAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("IRISparkHeavyWeapons.Anims.AS_LAC_Spark")));
			}
		}
	}
}


static function PatchAbilityTemplates()
{
	local X2AbilityTemplateManager		AbilityTemplateManager;
	local X2DataTemplate				DataTemplate;
	local X2AbilityTemplate				Template;
	local X2Effect_IRI_Rainmaker		Rainmaker;
	local X2Effect						Effect;
	local X2Condition_SourceWeaponCat	WeaponCondition;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	//	Rainmaker
	//	Get the Rainmaker ability template so we can use it for the purposes of our effect's localization.
	Template = AbilityTemplateManager.FindAbilityTemplate('Rainmaker');
	if (Template != none)
	{
		Rainmaker = new class'X2Effect_IRI_Rainmaker';
		Rainmaker.BuildPersistentEffect(1, true);
		Rainmaker.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false, ,Template.AbilitySourceName);

		//	Cycle through all abilities, if any of them add the Rainmaker effect, add our effect in parallel.
		//	Resource intensive, but comprehensive.
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

	//	Repair
	Template = AbilityTemplateManager.FindAbilityTemplate('Repair');
	if (Template != none)
	{
		WeaponCondition = new class'X2Condition_SourceWeaponCat';
		WeaponCondition.MatchWeaponCat = 'sparkbit';
		Template.AbilityShooterConditions.AddItem(WeaponCondition);
	}
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
		//	Add some abilities to BITs.
        if (WeaponTemplate.WeaponCat == 'sparkbit')
        {
			//	Makes BIT grant concealment
			WeaponTemplate.Abilities.AddItem('IRI_ActiveCamo');

			//	Pure passives with localization, just to let the player know.
			WeaponTemplate.Abilities.AddItem('IntrusionProtocol');
			WeaponTemplate.Abilities.AddItem('Arsenal');

			AddBITAnimSetsToCharacterTemplate(WeaponTemplate.CosmeticUnitTemplate);
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

	//	Add missing stat markup for the bonus hacking from BIT
	WeaponTemplate = X2WeaponTemplate(ItemMgr.FindItemTemplate('SparkBit_CV'));
	if (WeaponTemplate != none)
	{
		WeaponTemplate.SetUIStatMarkup(class'XLocalizedData'.default.TechBonusLabel, eStat_Hacking, class'X2Item_DLC_Day90Weapons'.default.SPARKBIT_CONVENTIONAL_HACKBONUS, true);
	}
	WeaponTemplate = X2WeaponTemplate(ItemMgr.FindItemTemplate('SparkBit_MG'));
	if (WeaponTemplate != none)
	{
		WeaponTemplate.SetUIStatMarkup(class'XLocalizedData'.default.TechBonusLabel, eStat_Hacking, class'X2Item_DLC_Day90Weapons'.default.SPARKBIT_MAGNETIC_HACKBONUS, true);
	}
	WeaponTemplate = X2WeaponTemplate(ItemMgr.FindItemTemplate('SparkBit_BM'));
	if (WeaponTemplate != none)
	{
		WeaponTemplate.SetUIStatMarkup(class'XLocalizedData'.default.TechBonusLabel, eStat_Hacking, class'X2Item_DLC_Day90Weapons'.default.SPARKBIT_BEAM_HACKBONUS, true);
	}
}

static function AddBITAnimSetsToCharacterTemplate(string TemplateName)
{
    local X2CharacterTemplateManager    CharMgr;
    local X2CharacterTemplate           CharTemplate;
	local array<X2DataTemplate>			DifficultyVariants;
	local X2DataTemplate				DifficultyVariant;
	local XComContentManager			Content;
	
    CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	
	CharMgr.FindDataTemplateAllDifficulties(name(TemplateName), DifficultyVariants);
	foreach DifficultyVariants(DifficultyVariant)
	{
		CharTemplate = X2CharacterTemplate(DifficultyVariant);

		if (CharTemplate != none)
		{
			Content = `CONTENT;
			CharTemplate.AdditionalAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("IRIRestorativeMist.Anims.AS_RestoMist_BIT")));
			CharTemplate.AdditionalAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("IRIElectroPulse.Anims.AS_ElectroPulse_BIT")));
			CharTemplate.AdditionalAnimSets.AddItem(AnimSet(Content.RequestGameArchetype("AnimSet'IRISparkHeavyWeapons.Anims.AS_LAC_Bit")));
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
}

static function string DLCAppendSockets(XComUnitPawn Pawn)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Pawn.ObjectID));

	if (UnitState != none && (default.SparkCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE))
	{
		return "IRIOrdnanceLauncher.Meshes.Spark_Sockets";
	}
	return "";
}
/*
static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{

}*/

static function OverrideItemImage(out array<string> imagePath, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, XComGameState_Unit UnitState)
{
	local XComGameState_HeadquartersXCom XComHQ;

	if (ItemTemplate.DataName == 'IRI_RestorativeMist_CV')
	{
		XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));

		if (XComHQ != None && XComHQ.IsTechResearched('BattlefieldMedicine'))
		{
			imagePath.Length = 0;
			imagePath.AddItem("img:///IRIRestorativeMist.UI.Inv_RestorativeMist_Nano");
			//`LOG("Adding resto mist icon.",, 'IRITEST');
		}
	}
}

/*
static function GetNumUtilitySlotsOverride(out int NumUtilitySlots, XComGameState_Item EquippedArmor, XComGameState_Unit UnitState, XComGameState CheckGameState)
{
	//	If this is a SPARK or a MEC and doesn't have utility slots at all, add one.
	if (default.SparkCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE && NumUtilitySlots == 0)
	{
		NumUtilitySlots++;
	}
}
*/
static function bool CanAddItemToInventory_CH_Improved(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit UnitState, optional XComGameState CheckGameState, optional out string DisabledReason, optional XComGameState_Item ItemState) 
{
    local XGParamTag                    LocTag;
    local bool							OverrideNormalBehavior;
    local bool							DoNotOverrideNormalBehavior;
	local XComGameState_Item			OtherItemState;
	local name							TemplateName;

    OverrideNormalBehavior = CheckGameState != none;
    DoNotOverrideNormalBehavior = CheckGameState == none;

    if(DisabledReason != "")
        return DoNotOverrideNormalBehavior;
		
	//	If we're trying to equip an Autogun
	if (ItemTemplate.DataName == 'IRI_Heavy_Autogun' || ItemTemplate.DataName == 'IRI_Heavy_Autogun_MK2') 
	{
		//	Into Heavy Weapon slot
		if (Slot == eInvSlot_HeavyWeapon)
		{
			//	Grab Item State in the Aux Slot
			OtherItemState = UnitState.GetItemInSlot(eInvSlot_AuxiliaryWeapon, CheckGameState);
		}	//	Into Aux SLot
		else if (Slot == eInvSlot_AuxiliaryWeapon)
		{
			//	Grab Item State from the Heavy Weapon slot
			OtherItemState = UnitState.GetItemInSlot(eInvSlot_HeavyWeapon, CheckGameState);
		}
			
		//	If there's an item in that slot
		if (OtherItemState != none)
		{
			TemplateName = OtherItemState.GetMyTemplateName();
			//	If it's an Autogun
			if (TemplateName == 'IRI_Heavy_Autogun' || TemplateName == 'IRI_Heavy_Autogun_MK2')
			{
				//	Autogun already equipped, forbid equipping another one.
				LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
				LocTag.StrValue0 = class'UIArmory_Loadout'.default.m_strInventoryLabels[eInvSlot_HeavyWeapon];				
				DisabledReason = class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(`XEXPAND.ExpandString(class'UIArmory_Loadout'.default.m_strCategoryRestricted));
				bCanAddItem = 0;
				return OverrideNormalBehavior;
			}
		}
	}
    return DoNotOverrideNormalBehavior;
}

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local XComGameState_Item		ItemState;
	local X2AbilityTemplate			AbilityTemplate;
	local StateObjectReference		OrdLauncherRef, KSMRef, BITRef;
	local X2AbilityTemplateManager  AbilityTemplateManager;
	local bool						bChangeHeavyWeapons;
	local bool						bChangeMelee;
	local bool						bChangeGrenadesAndRockets;
	local int Index;
	
	if (default.SparkCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE)
	{
		//`LOG("Finalize abilities for unit:" @ UnitState.GetFullName(),, 'IRILOG');

		AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();		

		//	Ordnance Launcher Equipped?
		ItemState = UnitState.GetItemInSlot(class'X2Item_OrdnanceLauncher_CV'.default.INVENTORY_SLOT, StartState);
		if (ItemState != none && ItemState.GetWeaponCategory() == class'X2Item_OrdnanceLauncher_CV'.default.WEAPON_CATEGORY)
		{
			bChangeGrenadesAndRockets = true;
			OrdLauncherRef = ItemState.GetReference();

			//`LOG("Found SPARK with a grenade launcher",, 'IRILOG');
			//	Prep the ability we're gonna be attaching to grenades.
		
			if (default.bOrdnanceAmplifierUsesBlasterLauncherTargeting && ItemState.GetMyTemplateName() == 'IRI_OrdnanceLauncher_BM')
			{
				AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('IRI_BlastOrdnance');
			}
			else
			{
				AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('IRI_LaunchOrdnance');
			}
		}

		//	KSM Equipped?
		ItemState = UnitState.GetItemInSlot(class'X2Item_KSM'.default.INVENTORY_SLOT, StartState);
		if (ItemState != none && ItemState.GetWeaponCategory() == class'X2Item_KSM'.default.WEAPON_CATEGORY)
		{
			bChangeMelee = true;
			KSMRef = ItemState.GetReference();
		}
		
		//	BIT Equipped? Not checking secondary weapon directly in case somebody adds Utility Slot BITs or something
		BITRef.ObjectID = class'X2Condition_HasWeaponOfCategory'.static.GetBITObjectID(UnitState, StartState);
		if (default.bAlwaysUseArmCannonAnimationsForHeavyWeapons || BITRef.ObjectID <= 0)
		{
			bChangeHeavyWeapons = true;
		}
					
		//	Cycle through all abilities that are about to be Initialized
		for (Index = SetupData.Length - 1; Index >= 0; Index--)
		{
			//	Lookup its template name and replace or remove the ability.
			switch (SetupData[Index].TemplateName)
			{
				//	=======	Grenades =======
				case 'ThrowGrenade':	//	Replace instances of Throw Grenade with Launch Ordnance. Pet two foxes with one arm.
					if (!bChangeGrenadesAndRockets) break;
					SetupData[Index].TemplateName = AbilityTemplate.DataName;
					SetupData[Index].Template = AbilityTemplate;
					SetupData[Index].SourceAmmoRef = SetupData[Index].SourceWeaponRef;
					SetupData[Index].SourceWeaponRef = OrdLauncherRef;
					break;
				case 'LaunchGrenade':	//	Remove instances of Launch Grenade. There shouldn't be a way for them to be here, but just in case.
					if (!bChangeGrenadesAndRockets) break;
					SetupData.Remove(Index, 1);
					break;
				//	=======	Heavy Weapons =======
				case 'SparkRocketLauncher':
					if (!bChangeHeavyWeapons && !DoesThisRefAuxSlotItem(SetupData[Index].SourceWeaponRef)) break;
					//`LOG("Replacing:" @ SetupData[Index].TemplateName @ "for unit:" @ UnitState.GetFullName() @ "on item:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID)).GetMyTemplateName() @ "on ammo:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceAmmoRef.ObjectID)).GetMyTemplateName(),, 'WOTCMoreSparkWeapons');
					SetupData[Index].TemplateName = 'IRI_SparkRocketLauncher';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkRocketLauncher');
					break;
				case 'SparkShredderGun':
					if (!bChangeHeavyWeapons && !DoesThisRefAuxSlotItem(SetupData[Index].SourceWeaponRef)) break;
					//`LOG("Replacing:" @ SetupData[Index].TemplateName @ "for unit:" @ UnitState.GetFullName() @ "on item:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID)).GetMyTemplateName() @ "on ammo:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceAmmoRef.ObjectID)).GetMyTemplateName(),, 'WOTCMoreSparkWeapons');
					SetupData[Index].TemplateName = 'IRI_SparkShredderGun';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkShredderGun');
					break;
				case 'SparkShredstormCannon':
					if (!bChangeHeavyWeapons && !DoesThisRefAuxSlotItem(SetupData[Index].SourceWeaponRef)) break;
					//`LOG("Replacing:" @ SetupData[Index].TemplateName @ "for unit:" @ UnitState.GetFullName() @ "on item:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID)).GetMyTemplateName() @ "on ammo:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceAmmoRef.ObjectID)).GetMyTemplateName(),, 'WOTCMoreSparkWeapons');
					SetupData[Index].TemplateName = 'IRI_SparkShredstormCannon';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkShredstormCannon');
					break;
				case 'SparkFlamethrower':
					if (!bChangeHeavyWeapons && !DoesThisRefAuxSlotItem(SetupData[Index].SourceWeaponRef)) break;
					//`LOG("Replacing:" @ SetupData[Index].TemplateName @ "for unit:" @ UnitState.GetFullName() @ "on item:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID)).GetMyTemplateName() @ "on ammo:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceAmmoRef.ObjectID)).GetMyTemplateName(),, 'WOTCMoreSparkWeapons');
					SetupData[Index].TemplateName = 'IRI_SparkFlamethrower';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkFlamethrower');
					break;
				case 'SparkFlamethrowerMk2':
					if (!bChangeHeavyWeapons && !DoesThisRefAuxSlotItem(SetupData[Index].SourceWeaponRef)) break;
					//`LOG("Replacing:" @ SetupData[Index].TemplateName @ "for unit:" @ UnitState.GetFullName() @ "on item:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID)).GetMyTemplateName() @ "on ammo:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceAmmoRef.ObjectID)).GetMyTemplateName(),, 'WOTCMoreSparkWeapons');
					SetupData[Index].TemplateName = 'IRI_SparkFlamethrowerMk2';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkFlamethrowerMk2');
					break;
				case 'SparkBlasterLauncher':
					if (!bChangeHeavyWeapons && !DoesThisRefAuxSlotItem(SetupData[Index].SourceWeaponRef)) break;
					//`LOG("Replacing:" @ SetupData[Index].TemplateName @ "for unit:" @ UnitState.GetFullName() @ "on item:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID)).GetMyTemplateName() @ "on ammo:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceAmmoRef.ObjectID)).GetMyTemplateName(),, 'WOTCMoreSparkWeapons');
					SetupData[Index].TemplateName = 'IRI_SparkBlasterLauncher';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkBlasterLauncher');
					break;
				case 'SparkPlasmaBlaster':
					if (!bChangeHeavyWeapons && !DoesThisRefAuxSlotItem(SetupData[Index].SourceWeaponRef)) break;
					//`LOG("Replacing:" @ SetupData[Index].TemplateName @ "for unit:" @ UnitState.GetFullName() @ "on item:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID)).GetMyTemplateName() @ "on ammo:" @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceAmmoRef.ObjectID)).GetMyTemplateName(),, 'WOTCMoreSparkWeapons');
					SetupData[Index].TemplateName = 'IRI_SparkPlasmaBlaster';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_SparkPlasmaBlaster');
					break;
				//	=======	Bombard =======
				case 'Bombard':
					if (!bChangeGrenadesAndRockets) break;
					SetupData[Index].TemplateName = 'IRI_Bombard';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_Bombard');
					SetupData[Index].SourceWeaponRef = OrdLauncherRef;
					break;
				//	=======	Rocket Launchers =======	
				case 'IRI_FireRocket':	
					if (!bChangeGrenadesAndRockets) break;
					SetupData[Index].TemplateName = 'IRI_FireRocket_Spark';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_FireRocket_Spark');
					break;
				case 'IRI_FireSabot':
					if (!bChangeGrenadesAndRockets) break;
					SetupData[Index].TemplateName = 'IRI_FireSabot_Spark';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_FireSabot_Spark');
					break;
				case 'IRI_FireLockon':
					if (!bChangeGrenadesAndRockets) break;
					SetupData[Index].TemplateName = 'IRI_FireLockon_Spark';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_FireLockon_Spark');
					break;
				case 'IRI_LockAndFireLockon':
					if (!bChangeGrenadesAndRockets) break;
					SetupData[Index].TemplateName = 'IRI_LockAndFireLockon_Spark';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_LockAndFireLockon_Spark');
					break;
				case 'IRI_LockAndFireLockon_Holo':
					if (!bChangeGrenadesAndRockets) break;
					SetupData[Index].TemplateName = 'IRI_LockAndFireLockon_Holo_Spark';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_LockAndFireLockon_Holo_Spark');
					break;
				case 'IRI_FireTacticalNuke':
					if (!bChangeGrenadesAndRockets) break;
					SetupData[Index].TemplateName = 'IRI_FireTacticalNuke_Spark';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_FireTacticalNuke_Spark');
					break;
				case 'IRI_Fire_PlasmaEjector':
					if (!bChangeGrenadesAndRockets) break;
					SetupData[Index].TemplateName = 'IRI_Fire_PlasmaEjector_Spark';
					SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_Fire_PlasmaEjector_Spark');
					break;
				//	=======	Restorative Mist =======
				case 'IRI_RestorativeMist_Heal':
					if (BITRef.ObjectID > 0)
					{
						SetupData.Remove(Index, 1);
						//`LOG("Removed restorative mist:" @ SetupData[Index].SourceAmmoRef.ObjectID @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceAmmoRef.ObjectID)).GetMyTemplateName() @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID)).GetMyTemplateName() @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(BITRef.ObjectID)).GetMyTemplateName(),, 'WOTCMoreSparkWeapons');
					}
					break;		
				case 'IRI_RestorativeMist_HealBit':
					if (BITRef.ObjectID > 0)
					{
						//`LOG("Patched restorative mist bit:" @ SetupData[Index].SourceAmmoRef.ObjectID @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceAmmoRef.ObjectID)).GetMyTemplateName() @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID)).GetMyTemplateName() @ XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(BITRef.ObjectID)).GetMyTemplateName(),, 'WOTCMoreSparkWeapons');
						SetupData[Index].SourceWeaponRef = BITRef;
					}
					else
					{
						SetupData.Remove(Index, 1);
					}
					break;	
				//	=======	Electro Pulse =======
				case 'IRI_ElectroPulse':
					if (BITRef.ObjectID > 0)
					{
						SetupData.Remove(Index, 1);
					}
					break;		
				case 'IRI_ElectroPulse_Bit':
					if (BITRef.ObjectID > 0)
					{
						SetupData[Index].SourceWeaponRef = BITRef;
					}
					else
					{
						SetupData.Remove(Index, 1);
					}
					break;	
				//	=======	Light Auto Cannon =======
				case 'IRI_Fire_HeavyAutogun':	//	If this is a Heavy Autogun ability, and the BIT is present, and this heavy weapon is not in the Aux Slot
					if (BITRef.ObjectID > 0 && !DoesThisRefAuxSlotItem(SetupData[Index].SourceWeaponRef))
					{
						//	Attach it to BIT
						SetupData[Index].TemplateName = 'IRI_Fire_HeavyAutogun_BIT';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_Fire_HeavyAutogun_BIT');
					}
					else
					{
						//	Otherwise, replace it with the "arm cannon" version.
						SetupData[Index].TemplateName = 'IRI_Fire_HeavyAutogun_Spark';
						SetupData[Index].Template = AbilityTemplateManager.FindAbilityTemplate('IRI_Fire_HeavyAutogun_Spark');
					}					
					break;		
				default:
					//	=======	Melee =======
					if (!bChangeMelee) break;	//	Move melee abilities to KSM so they can use KSM melee animations
					if (default.MeleeAbilitiesUseKSM.Find(SetupData[Index].TemplateName) != INDEX_NONE)
					{
						SetupData[Index].SourceWeaponRef = KSMRef;
					}
					break;
			}
		}
	}
}

static function bool DoesThisRefAuxSlotItem(const StateObjectReference Ref)
{
    local XComGameState_Item ItemState;

    ItemState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));

    //`LOG("Checking item:" @ ItemState.GetMyTemplateName() @ "in slot:" @ ItemState.InventorySlot,, 'WOTCMoreSparkWeapons');
    if (ItemState != none && ItemState.InventorySlot == eInvSlot_AuxiliaryWeapon) return true;

    return false;
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
			
			//	If this is a Heavy Weapon
			if (WeaponTemplate.WeaponCat == 'heavy')
			{
				//	If it is in the Aux Slot, or if the the SPARK doesn't have a BIT equipped, or if the mod is configured to always use the Arm Cannon animations for heavy weapons
				if (InternalWeaponState.InventorySlot == eInvSlot_AuxiliaryWeapon || default.bAlwaysUseArmCannonAnimationsForHeavyWeapons || !class'X2Condition_HasWeaponOfCategory'.static.DoesUnitHaveBITEquipped(UnitState))
				{
					//	Replace the mesh for this heavy weapon with the arm cannon and replace the weapon and pawn animations.
					Weapon.CustomUnitPawnAnimsets.Length = 0;
					Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(Content.RequestGameArchetype("IRISparkHeavyWeapons.Anims.AS_Heavy_Spark")));
					SkeletalMeshComponent(Weapon.Mesh).SkeletalMesh = SkeletalMesh(Content.RequestGameArchetype("IRISparkHeavyWeapons.Meshes.SM_SparkHeavyWeapon"));
					SkeletalMeshComponent(Weapon.Mesh).AnimSets.AddItem(AnimSet(Content.RequestGameArchetype("IRISparkHeavyWeapons.Anims.AS_Heavy_Weapon")));

					//	Bandaid patch to play a different animation with a different weapon charging sound.
					if (WeaponTemplate.DataName == 'IRI_Heavy_Autogun_MK2')
					{
						Weapon.WeaponFireAnimSequenceName = 'FF_FireLAC_MK2';
					}

					//`LOG("Weapon Initialized -> Patched heavy weapon for a SPARK.",, 'IRITEST');
				}
				else	//	Blank out the default socket on this heavy weapon so it's not visible on the spark.
				{
					Weapon.DefaultSocket = '';
				}
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

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local name TagText;
	
	TagText = name(InString);
	switch (TagText)
	{
	case 'IRI_CONV_LAUNCHER_GRANT_GRENADE_SLOTS':
		OutString = SetColor(class'X2StrategyElement_InventorySlots'.default.CONV_LAUNCHER_GRANT_GRENADE_SLOTS);
		return true;
	case 'IRI_MAG_LAUNCHER_GRANT_GRENADE_SLOTS':
		OutString = SetColor(class'X2StrategyElement_InventorySlots'.default.MAG_LAUNCHER_GRANT_GRENADE_SLOTS);
		return true;
	case 'IRI_BEAM_LAUNCHER_GRANT_GRENADE_SLOTS':
		OutString = SetColor(class'X2StrategyElement_InventorySlots'.default.BEAM_LAUNCHER_GRANT_GRENADE_SLOTS);
		return true;
	//	===================================================
	default:
            return false;
    }  
}


static function string SetColor(coerce string Value)
{	
	return "<font color='#1ad1cf'>" $ Value $ "</font>";
}

static function string AddSign(int Value)
{
	if (Value > 0) return "+" $ Value;

	return string(Value);
}

static function string AddSignFloat(float Value)
{
	if (Value > 0) return "+" $ TruncateFloat(Value);

	return string(Value);
}

static function string TruncateFloat(float value)
{
	local string FloatString, TempString;
	local int i;
	local float TempFloat, TestFloat;

	TempFloat = value;
	for (i=0; i < 2; i++)
	{
		TempFloat *= 10.0;
	}
	TempFloat = Round(TempFloat);
	for (i=0; i < 2; i++)
	{
		TempFloat /= 10.0;
	}

	TempString = string(TempFloat);
	for (i = InStr(TempString, ".") + 1; i < Len(TempString) ; i++)
	{
		FloatString = Left(TempString, i);
		TestFloat = float(FloatString);
		if (TempFloat ~= TestFloat)
		{
			break;
		}
	}

	if (Right(FloatString, 1) == ".")
	{
		FloatString $= "0";
	}

	return FloatString;
}