class X2Ability_OrdnanceLauncher extends X2Ability;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_LaunchOrdnance());
	Templates.AddItem(Create_LaunchOrdnance('IRI_BlastOrdnance', true));

	Templates.AddItem(IRI_ActiveCamo());

	Templates.AddItem(Create_IRI_Bombard());

	// Separate versions of abilities to fire from the arm cannon with a different cinecam.
	Templates.AddItem(SparkRocketLauncher());
	Templates.AddItem(SparkShredderGun());
	Templates.AddItem(SparkShredstormCannon());
	Templates.AddItem(SparkFlamethrower());
	Templates.AddItem(SparkFlamethrowerMk2());
	Templates.AddItem(SparkBlasterLauncher());
	Templates.AddItem(SparkPlasmaBlaster());

	return Templates;
}

static function X2DataTemplate Create_LaunchOrdnance(optional name TemplateName = 'IRI_LaunchOrdnance', optional bool bBlasterLauncherTargeting = false)
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2Condition_AbilitySourceWeapon   GrenadeCondition, ProximityMineCondition;
	local X2Effect_ProximityMine            ProximityMineEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	//Template.SoldierAbilityPurchasedFn = class'X2Ability_GrenadierAbilitySet'.static.GrenadePocketPurchased;

	//	Icon Setup
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_CannotAfford_AmmoCost');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_grenade_launcher";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_GRENADE_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.bUseAmmoAsChargesForHUD = true;

	//	Targeting and Triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bIndirectFire = true;
	StandardAim.bAllowCrit = false;
	Template.AbilityToHitCalc = StandardAim;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	//Template.TargetingMethod = class'X2TargetingMethod_Grenade';
	if (bBlasterLauncherTargeting)
	{
		Template.TargetingMethod = class'X2TargetingMethod_BlasterLauncher';
	}
	else
	{
		Template.TargetingMethod = class'X2TargetingMethod_OrdnanceLauncher';
	}
	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.bUseWeaponRadius = true;
	RadiusMultiTarget.bUseWeaponBlockingCoverFlag = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;
	
	//	Ability Costs
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	AmmoCost.UseLoadedAmmo = true;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Salvo');
	Template.AbilityCosts.AddItem(ActionPointCost);

	//	Shooter Conditions
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	Template.AddShooterEffectExclusions();

	//	Multi Target Conditions
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	GrenadeCondition = new class'X2Condition_AbilitySourceWeapon';
	GrenadeCondition.CheckGrenadeFriendlyFire = true;
	Template.AbilityMultiTargetConditions.AddItem(GrenadeCondition);
	
	//	Ability Effects
	Template.bUseLaunchedGrenadeEffects = true;
	Template.bRecordValidTiles = true;

	ProximityMineEffect = new class'X2Effect_ProximityMine';
	ProximityMineEffect.BuildPersistentEffect(1, true, false, false);
	ProximityMineCondition = new class'X2Condition_AbilitySourceWeapon';
	ProximityMineCondition.MatchGrenadeType = 'ProximityMine';
	ProximityMineEffect.TargetConditions.AddItem(ProximityMineCondition);
	Template.AddShooterEffect(ProximityMineEffect);

	
	//	State and Viz
	Template.bHideAmmoWeaponDuringFire = true;
	
	Template.ActivationSpeech = 'ThrowGrenade';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.DamagePreviewFn = class'X2Ability_Grenades'.static.GrenadeDamagePreview;

	//Template.CinescriptCameraType = "Grenadier_GrenadeLauncher";
	//Template.CinescriptCameraType = "MEC_MicroMissiles";
	Template.CinescriptCameraType = "Iridar_Grenade_Launch_Spark";

	// This action is considered 'hostile' and can be interrupted!
	Template.Hostility = eHostility_Offensive;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.GrenadeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}

static function X2AbilityTemplate IRI_ActiveCamo()
{
	local X2AbilityTemplate			Template;
	local X2Effect_StayConcealed	Effect;
	local X2Effect_Persistent		PersistentEffect;
	//local X2Effect_RangerStealth    StealthEffect;
	//local X2AbilityTrigger_EventListener    Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_ActiveCamo');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_refractionfield";
	SetHidden(Template);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	/*
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'StartOfMatchConcealment';
	Trigger.ListenerData.Filter = eFilter_Player;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self; //_VisualizeInGameState;
	Template.AbilityTriggers.AddItem(Trigger);*/
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	//	Adding a hard effect to enter concealment so that SPARK enters concealment on missions where squad is not concealed in time
	//	for active ability to see the SPARK concealed and play its VFX correctly.

	//	Hard effect to gain concealment.
	//StealthEffect = new class'X2Effect_RangerStealth';
	//StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	//Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false, ,Template.AbilitySourceName);
	//StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
	//Template.AddTargetEffect(StealthEffect);

	PersistentEffect = new class'X2Effect_Persistent';
	PersistentEffect.EffectName = 'IRI_ActiveCamo_Effect';
	PersistentEffect.BuildPersistentEffect(1, true, false);
	PersistentEffect.bRemoveWhenTargetConcealmentBroken = true;
	Template.AddTargetEffect(PersistentEffect);

	//	Phantom-like - stay concealed if squad breaks concealment.
	Effect = new class'X2Effect_StayConcealed';
	Effect.BuildPersistentEffect(1, true, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false, ,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.Hostility = eHostility_Neutral;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CustomFireAnim = 'NO_Camouflage';
	//Template.AssociatedPlayTiming = SPT_AfterParallel;
	//Template.AssociatedPlayTiming = SPT_BeforeParallel;

	return Template;
}

static function X2AbilityTemplate Create_IRI_Bombard()
{
	local X2AbilityTemplate             Template;
	local X2AbilityTarget_Cursor        CursorTarget;
	local X2AbilityMultiTarget_Radius   RadiusMultiTarget;
	local X2AbilityCost_Charges         ChargeCost;
	local X2AbilityCharges              Charges;
	local X2AbilityCooldown             Cooldown;
	local X2Effect_ApplyWeaponDamage    DamageEffect;
	local X2AbilityCost_ActionPoints    ActionPointCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_Bombard');

	//	Icon
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_DLC3Images.UIPerk_spark_bombard";

	//	Targeting and Triggering
	Template.TargetingMethod = class'X2TargetingMethod_VoidRift';
	Template.AbilityToHitCalc = default.DeadEye;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToSquadsightRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = class'X2Ability_SparkAbilitySet'.default.BOMBARD_DAMAGE_RADIUS_METERS;
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	//	Ability Costs
	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Charges = new class'X2AbilityCharges';
	Charges.InitialCharges = class'X2Ability_SparkAbilitySet'.default.BOMBARD_CHARGES;
	Template.AbilityCharges = Charges;
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = class'X2Ability_SparkAbilitySet'.default.BOMBARD_NUM_COOLDOWN_TURNS;
	Template.AbilityCooldown = Cooldown;

	// Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	//	Multi Target Conditions
	Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetOnlyProperty);

	//	Ability effects
	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.bIgnoreBaseDamage = true;
	DamageEffect.DamageTag = 'Bombard';
	DamageEffect.EnvironmentalDamageAmount = class'X2Ability_SparkAbilitySet'.default.BOMBARD_ENV_DMG;
	Template.AddMultiTargetEffect(DamageEffect);

	Template.CinescriptCameraType = "Iridar_Rocket_Lockon_Spark";
	Template.CustomFireAnim = 'FF_Bombard';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = IRI_Bombard_BuildVisualization;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.GrenadeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}

simulated function IRI_Bombard_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateVisualizationMgr		VisMgr;
	local X2Action							FoundAction;
	local VisualizationActionMetadata		ActionMetadata;
	local XComGameStateHistory				History;
	local XComGameStateContext_Ability		Context;
	local int								SourceUnitID;
	local X2Action_CameraLookAt				LookAtTargetAction;

	//	Call the typical ability visuailzation. With just that, the ability would look like the soldier firing the rocket upwards, and then enemy getting damage for seemingly no reason.
	class'X2Ability'.static.TypicalAbility_BuildVisualization(VisualizeGameState);

	VisMgr = `XCOMVISUALIZATIONMGR;
	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	SourceUnitID = Context.InputContext.SourceObject.ObjectID;

	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(SourceUnitID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(SourceUnitID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(SourceUnitID);

	//	Find the Fire Action in vis tree configured by Typical Ability Build Viz
	FoundAction = VisMgr.GetNodeOfType(VisMgr.BuildVisTree, class'X2Action_Fire');

	if (FoundAction != none)
	{
		//	Add a camera action as a child to the Fire Action's parent, that lets both Fire Action and Camera Action run in parallel
		//	pan camera towards the shooter for the firing animation
		LookAtTargetAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, Context, false, FoundAction.ParentActions[0]));
		LookAtTargetAction.LookAtActor = ActionMetadata.VisualizeActor;
		LookAtTargetAction.LookAtDuration = 6.25f;
		LookAtTargetAction.BlockUntilActorOnScreen = true;
		LookAtTargetAction.BlockUntilFinished = true;
		//LookAtAction.TargetZoomAfterArrival = -0.5f; zooms in slowly and doesn't stop
		
		//	This action will pause the Vis Tree until the Unit Hit (Notify Target) Anim Notify is reached in the Fire Action's AnimSequence (in the Fire Lockon firing animation)
		class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, Context, true, FoundAction);

		//	Start setting up the action that will pan the camera towards the location of the primary target
		LookAtTargetAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, Context, true, ActionMetadata.LastActionAdded));
		LookAtTargetAction.LookAtLocation = Context.InputContext.TargetLocations[0];
		LookAtTargetAction.LookAtDuration = 3.0f;

		//	make the projectile fall down.
		class'X2Action_FireJavelin'.static.AddToVisualizationTree(ActionMetadata, Context, true, LookAtTargetAction);
	}
}


//	========================================
//				HEAVY WEAPON ABILITIES
//	========================================


static function X2AbilityTemplate SparkRocketLauncher()
{
	local X2AbilityTemplate AbilityTemplate;

	AbilityTemplate = class'X2Ability_HeavyWeapons'.static.RocketLauncherAbility('IRI_SparkRocketLauncher');

	X2AbilityMultiTarget_Radius(AbilityTemplate.AbilityMultiTargetStyle).AddAbilityBonusRadius('Rainmaker', class'X2Ability_SparkAbilitySet'.default.RAINMAKER_RADIUS_ROCKETLAUNCHER);

	AbilityTemplate.bDisplayInUITacticalText = false;
	AbilityTemplate.bFrameEvenWhenUnitIsHidden = true;

	AbilityTemplate.CinescriptCameraType = "Iridar_Heavy_Weapon_Spark";

	return AbilityTemplate;
}

static function X2AbilityTemplate SparkShredderGun()
{
	local X2AbilityTemplate AbilityTemplate;

	AbilityTemplate = class'X2Ability_HeavyWeapons'.static.ShredderGunAbility('IRI_SparkShredderGun');

	X2AbilityMultiTarget_Cone(AbilityTemplate.AbilityMultiTargetStyle).AddBonusConeSize('Rainmaker', class'X2Ability_SparkAbilitySet'.default.RAINMAKER_CONEDIAMETER_SHREDDERGUN, class'X2Ability_SparkAbilitySet'.default.RAINMAKER_CONELENGTH_SHREDDERGUN);

	AbilityTemplate.bDisplayInUITacticalText = false;
	AbilityTemplate.bFrameEvenWhenUnitIsHidden = true;

	AbilityTemplate.CinescriptCameraType = "Iridar_Heavy_Weapon_Spark";

	return AbilityTemplate;
}

static function X2AbilityTemplate SparkShredstormCannon()
{
	local X2AbilityTemplate AbilityTemplate;

	AbilityTemplate = class'X2Ability_HeavyWeapons'.static.ShredstormCannonAbility('IRI_SparkShredstormCannon');

	X2AbilityMultiTarget_Cone(AbilityTemplate.AbilityMultiTargetStyle).AddBonusConeSize('Rainmaker', class'X2Ability_SparkAbilitySet'.default.RAINMAKER_CONEDIAMETER_SHREDSTORM, class'X2Ability_SparkAbilitySet'.default.RAINMAKER_CONELENGTH_SHREDSTORM);

	AbilityTemplate.bDisplayInUITacticalText = false;
	AbilityTemplate.bFrameEvenWhenUnitIsHidden = true;

	AbilityTemplate.CinescriptCameraType = "Iridar_Heavy_Weapon_Spark";

	return AbilityTemplate;
}

static function X2AbilityTemplate SparkFlamethrower()
{
	local X2AbilityTemplate AbilityTemplate;

	AbilityTemplate = class'X2Ability_HeavyWeapons'.static.Flamethrower('IRI_SparkFlamethrower');

	X2AbilityMultiTarget_Cone(AbilityTemplate.AbilityMultiTargetStyle).AddBonusConeSize('Rainmaker', class'X2Ability_SparkAbilitySet'.default.RAINMAKER_CONEDIAMETER_FLAMETHROWER, class'X2Ability_SparkAbilitySet'.default.RAINMAKER_CONELENGTH_FLAMETHROWER);

	AbilityTemplate.bDisplayInUITacticalText = false;
	AbilityTemplate.bFrameEvenWhenUnitIsHidden = true;

	AbilityTemplate.CinescriptCameraType = "Iridar_Heavy_Weapon_Spark";

	return AbilityTemplate;
}

static function X2AbilityTemplate SparkFlamethrowerMk2()
{
	local X2AbilityTemplate AbilityTemplate;

	AbilityTemplate = class'X2Ability_HeavyWeapons'.static.Flamethrower('IRI_SparkFlamethrowerMk2');

	X2AbilityMultiTarget_Cone(AbilityTemplate.AbilityMultiTargetStyle).AddBonusConeSize('Rainmaker', class'X2Ability_SparkAbilitySet'.default.RAINMAKER_CONEDIAMETER_FLAMETHROWER2, class'X2Ability_SparkAbilitySet'.default.RAINMAKER_CONELENGTH_FLAMETHROWER2);

	AbilityTemplate.bDisplayInUITacticalText = false;
	AbilityTemplate.bFrameEvenWhenUnitIsHidden = true;

	AbilityTemplate.CinescriptCameraType = "Iridar_Heavy_Weapon_Spark";

	return AbilityTemplate;
}

static function X2AbilityTemplate SparkBlasterLauncher()
{
	local X2AbilityTemplate AbilityTemplate;

	AbilityTemplate = class'X2Ability_HeavyWeapons'.static.BlasterLauncherAbility('IRI_SparkBlasterLauncher');

	X2AbilityMultiTarget_Radius(AbilityTemplate.AbilityMultiTargetStyle).AddAbilityBonusRadius('Rainmaker', class'X2Ability_SparkAbilitySet'.default.RAINMAKER_RADIUS_BLASTERLAUNCHER);

	AbilityTemplate.bDisplayInUITacticalText = false;
	AbilityTemplate.bFrameEvenWhenUnitIsHidden = true;

	AbilityTemplate.CinescriptCameraType = "Iridar_Heavy_Weapon_Spark";

	return AbilityTemplate;
}

static function X2AbilityTemplate SparkPlasmaBlaster()
{
	local X2AbilityTemplate AbilityTemplate;

	AbilityTemplate = class'X2Ability_HeavyWeapons'.static.PlasmaBlaster('IRI_SparkPlasmaBlaster');

	X2AbilityMultiTarget_Line(AbilityTemplate.AbilityMultiTargetStyle).AddAbilityBonusWidth('Rainmaker', class'X2Ability_SparkAbilitySet'.default.RAINMAKER_WIDTH_PLASMABLASTER);

	AbilityTemplate.bDisplayInUITacticalText = false;
	AbilityTemplate.bFrameEvenWhenUnitIsHidden = true;

	AbilityTemplate.CinescriptCameraType = "Iridar_Heavy_Weapon_Spark";

	return AbilityTemplate;
}


//	========================================
//				COMMON CODE
//	========================================

static function AddCooldown(out X2AbilityTemplate Template, int Cooldown)
{
	local X2AbilityCooldown AbilityCooldown;

	if (Cooldown > 0)
	{
		AbilityCooldown = new class'X2AbilityCooldown';
		AbilityCooldown.iNumTurns = Cooldown;
		Template.AbilityCooldown = AbilityCooldown;
	}
}

static function AddCharges(out X2AbilityTemplate Template, int InitialCharges)
{
	local X2AbilityCharges		Charges;
	local X2AbilityCost_Charges	ChargeCost;

	if (InitialCharges > 0)
	{
		Charges = new class'X2AbilityCharges';
		Charges.InitialCharges = InitialCharges;
		Template.AbilityCharges = Charges;

		ChargeCost = new class'X2AbilityCost_Charges';
		ChargeCost.NumCharges = 1;
		Template.AbilityCosts.AddItem(ChargeCost);
	}
}

static function AddFreeCost(out X2AbilityTemplate Template)
{
	local X2AbilityCost_ActionPoints ActionPointCost;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
}

static function RemoveVoiceLines(out X2AbilityTemplate Template)
{
	Template.ActivationSpeech = '';
	Template.SourceHitSpeech = '';
	Template.TargetHitSpeech = '';
	Template.SourceMissSpeech = '';
	Template.TargetMissSpeech = '';
	Template.TargetKilledByAlienSpeech = '';
	Template.TargetKilledByXComSpeech = '';
	Template.MultiTargetsKilledByAlienSpeech = '';
	Template.MultiTargetsKilledByXComSpeech = '';
	Template.TargetWingedSpeech = '';
	Template.TargetArmorHitSpeech = '';
	Template.TargetMissedSpeech = '';
}

static function SetFireAnim(out X2AbilityTemplate Template, name Anim)
{
	Template.CustomFireAnim = Anim;
	Template.CustomFireKillAnim = Anim;
	Template.CustomMovingFireAnim = Anim;
	Template.CustomMovingFireKillAnim = Anim;
	Template.CustomMovingTurnLeftFireAnim = Anim;
	Template.CustomMovingTurnLeftFireKillAnim = Anim;
	Template.CustomMovingTurnRightFireAnim = Anim;
	Template.CustomMovingTurnRightFireKillAnim = Anim;
}

static function SetHidden(out X2AbilityTemplate Template)
{
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	
	//TacticalText is for mainly for item-granted abilities (e.g. to hide the ability that gives the armour stats)
	Template.bDisplayInUITacticalText = false;
	
	//	bDisplayInUITooltip isn't actually used in the base game, it should be for whether to show it in the enemy tooltip, 
	//	but showing enemy abilities didn't make it into the final game. Extended Information resurrected the feature  in its enhanced enemy tooltip, 
	//	and uses that flag as part of it's heuristic for what abilities to show, but doesn't rely solely on it since it's not set consistently even on base game abilities. 
	//	Anyway, the most sane setting for it is to match 'bDisplayInUITacticalText'. (c) MrNice
	Template.bDisplayInUITooltip = false;
	
	//Ability Summary is the list in the armoury when you're looking at a soldier.
	Template.bDontDisplayInAbilitySummary = true;
	Template.bHideOnClassUnlock = true;
}

static function X2AbilityTemplate Create_AnimSet_Passive(name TemplateName, string AnimSetPath)
{
	local X2AbilityTemplate                 Template;
	local X2Effect_AdditionalAnimSets		AnimSetEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.bDontDisplayInAbilitySummary = true;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	AnimSetEffect = new class'X2Effect_AdditionalAnimSets';
	AnimSetEffect.AddAnimSetWithPath(AnimSetPath);
	AnimSetEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(AnimSetEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function SetPassive(out X2AbilityTemplate Template)
{
	Template.bIsPassive = true;

	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.bDisplayInUITacticalText = true;
	Template.bDisplayInUITooltip = true;
	Template.bDontDisplayInAbilitySummary = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.Hostility = eHostility_Neutral;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
}

static function X2AbilityTemplate HiddenPurePassive(name TemplateName, optional string TemplateIconImage="img:///UILibrary_PerkIcons.UIPerk_standard", optional bool bCrossClassEligible=false, optional Name AbilitySourceName='eAbilitySource_Perk', optional bool bDisplayInUI=true)
{
	local X2AbilityTemplate	Template;
	
	Template = PurePassive(TemplateName, TemplateIconImage, bCrossClassEligible, AbilitySourceName, bDisplayInUI);
	SetHidden(Template);
	
	return Template;
}

//	Use: SetSelfTarget_WithEventTrigger(Template, 'PlayerTurnBegun',, eFilter_Player);
static function	SetSelfTarget_WithEventTrigger(out X2AbilityTemplate Template, name EventID, optional EventListenerDeferral Deferral = ELD_OnStateSubmitted, optional AbilityEventFilter Filter = eFilter_None, optional int Priority = 50)
{
	local X2AbilityTrigger_EventListener Trigger;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	
	Trigger = new class'X2AbilityTrigger_EventListener';	
	Trigger.ListenerData.EventID = EventID;
	Trigger.ListenerData.Deferral = Deferral;
	Trigger.ListenerData.Filter = Filter;
	Trigger.ListenerData.Priority = Priority;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);
}

static function PrintActionRecursive(X2Action Action, int iLayer)
{
	local X2Action ChildAction;

	`LOG("Action layer: " @ iLayer @ ": " @ Action.Class.Name @ Action.StateChangeContext.AssociatedState.HistoryIndex,, 'IRIPISTOLVIZ'); 
	foreach Action.ChildActions(ChildAction)
	{
		PrintActionRecursive(ChildAction, iLayer + 1);
	}
}