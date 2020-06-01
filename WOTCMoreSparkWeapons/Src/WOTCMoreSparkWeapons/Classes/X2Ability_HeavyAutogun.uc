class X2Ability_HeavyAutogun extends X2Ability config(AutogunHeavyWeapon);

var config bool GUARANTEED_HIT;
var config bool ALLOW_CRIT;
var config bool ENDS_TURN;
var config array<name> DO_NOT_END_TURN_ABILITY;
var config bool ALLOW_BURNING;
var config bool ALLOW_DISORIENTED;
var config bool ALLOW_SPECIAL_AMMO_EFFECTS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	//	Heavy Weapon: Autogun
	Templates.AddItem(Create_FireLAC());
	Templates.AddItem(Create_FireLAC_Spark());
	Templates.AddItem(Create_FireLAC_Spark_with_BIT());

	return Templates;
}


//	Helper function for adding stuff that's the same for all Fire LAC abilities.
static function SetupFire_LAC_Ability(X2AbilityTemplate Template)
{
	local X2Condition_Visibility                VisCondition;
	local X2AbilityCost_ActionPoints			ActionCost;
	local X2AbilityCost_Ammo					AmmoCost;
	local X2AbilityToHitCalc_StandardAim		ToHitCalc;
	local array<name>							SkipExclusions;
	local X2Effect_Knockback					KnockbackEffect;

	//	Icon Setup
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_combatprotocol";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.bDisplayInUITacticalText = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	//	Targeting and triggering
	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.bGuaranteedHit = default.GUARANTEED_HIT;
	ToHitCalc.bAllowCrit = default.ALLOW_CRIT;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;
	Template.DisplayTargetHitChance = !default.GUARANTEED_HIT;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	//	Costs
	ActionCost = new class'X2AbilityCost_ActionPoints';
	ActionCost.bAddWeaponTypicalCost = true;
	ActionCost.bConsumeAllPoints = default.ENDS_TURN;
	ActionCost.DoNotConsumeAllSoldierAbilities = default.DO_NOT_END_TURN_ABILITY;
	Template.AbilityCosts.AddItem(ActionCost);

	Template.bUseAmmoAsChargesForHUD = true;
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	//	Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	if (default.ALLOW_DISORIENTED) SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	if (default.ALLOW_BURNING) SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	//	Target Conditions
	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitOnlyProperty);

	VisCondition = new class'X2Condition_Visibility';
	VisCondition.bRequireGameplayVisible = true;
	Template.AbilityTargetConditions.AddItem(VisCondition);

	//	Ability Effects
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	Template.bAllowAmmoEffects = default.ALLOW_SPECIAL_AMMO_EFFECTS;
	Template.bAllowBonusWeaponEffects = false;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddTargetEffect(KnockbackEffect);

	//	Game State and Viz
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Offensive;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";	

	Template.AlternateFriendlyNameFn = AutogunShot_AlternateFriendlyName;
}

static function bool AutogunShot_AlternateFriendlyName(out string AlternateDescription, XComGameState_Ability AbilityState, StateObjectReference TargetRef)
{
	local XComGameState_Unit TargetUnit;

	// when targeting the lost, call the ability "Headshot" instead of "Fire Weapon"
	if( TargetRef.ObjectID > 0 )
	{
		TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetRef.ObjectID));
		if( TargetUnit != None && TargetUnit.GetTeam() == eTeam_TheLost )
		{
			AlternateDescription = class'XLocalizedData'.default.HeadshotDescriptionText;
			return true;
		}
	}

	return false;
}

static function X2DataTemplate Create_FireLAC()
{
	local X2AbilityTemplate Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_Fire_HeavyAutogun');

	SetupFire_LAC_Ability(Template);

	return Template;
}

static function X2DataTemplate Create_FireLAC_Spark()
{
	local X2AbilityTemplate Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_Fire_HeavyAutogun_Spark');

	SetupFire_LAC_Ability(Template);

	Template.TargetingMethod = none;
	Template.CinescriptCameraType = "Iridar_Heavy_Weapon_Spark";

	return Template;
}

static function X2AbilityTemplate Create_FireLAC_Spark_with_BIT()
{
	local X2AbilityTemplate Template;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_Fire_HeavyAutogun_BIT');

	SetupFire_LAC_Ability(Template);
	
	Template.bStationaryWeapon = true;	
	Template.BuildVisualizationFn = SparkHeavyWeaponVisualization;

	return Template;
}

static function XComGameState AttachGremlinToTarget_BuildGameState( XComGameStateContext Context )
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState NewGameState;
	local XComGameState_Item GremlinItemState;
	local XComGameState_Unit GremlinUnitState, TargetUnitState;
	local TTile TargetTile;

	`LOG("AttachGremlinToTarget_BuildGameState: enter",, 'WOTCMoreSparkWeapons');

	AbilityContext = XComGameStateContext_Ability(Context);
	NewGameState = TypicalAbility_BuildGameState(Context);

	`LOG("AttachGremlinToTarget_BuildGameState: step 1",, 'WOTCMoreSparkWeapons');

	TargetUnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	if (TargetUnitState == none)
	{
		TargetUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', AbilityContext.InputContext.PrimaryTarget.ObjectID));
	}
	`LOG("AttachGremlinToTarget_BuildGameState: step 2",, 'WOTCMoreSparkWeapons');


	//	This is Heavy Weapon
	GremlinItemState = XComGameState_Item(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.ItemObject.ObjectID));
	if (GremlinItemState == none)
	{
		GremlinItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', AbilityContext.InputContext.ItemObject.ObjectID));
	}
	`LOG("AttachGremlinToTarget_BuildGameState: step 3",, 'WOTCMoreSparkWeapons');

	//	This is none
	GremlinUnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(GremlinItemState.CosmeticUnitRef.ObjectID));
	if (GremlinUnitState == none)
	{
		GremlinUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', GremlinItemState.CosmeticUnitRef.ObjectID));
	}
	`LOG("AttachGremlinToTarget_BuildGameState: step 4",, 'WOTCMoreSparkWeapons');

	GremlinItemState.AttachedUnitRef = TargetUnitState.GetReference();

	//Handle height offset for tall units
	TargetTile = TargetUnitState.GetDesiredTileForAttachedCosmeticUnit();

	`LOG("AttachGremlinToTarget_BuildGameState: step 5",, 'WOTCMoreSparkWeapons');

	GremlinUnitState.SetVisibilityLocation(TargetTile);

	`LOG("AttachGremlinToTarget_BuildGameState: exit",, 'WOTCMoreSparkWeapons');

	return NewGameState;
}

static simulated function LAC_BIT_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory				History;
	local XComGameStateContext_Ability		Context;
	local XComGameState_Unit				SourceUnitState, TargetUnitState;
	local array<XComGameState_Unit>			AttachedUnitStates;
	local XComGameState_Unit				CosmeticUnit;
	local VisualizationActionMetadata		EmptyMetadata;
	local VisualizationActionMetadata		ActionMetadata;
	local X2AbilityTemplate					AbilityTemplate;
	local XComGameState_Item				CosmeticHeavyWeapon;
	local X2Action_ExitCover				ExitCoverAction;
	local X2Action_ExitCover				SourceExitCoverAction;
	local X2Action_EnterCover				EnterCoverAction;
	local X2Action_Fire						FireAction;
	local X2Action_Fire						NewFireAction;
	local XComGameStateVisualizationMgr		VisMgr;
	local Actor								SourceVisualizer;
	local Array<X2Action>					ParentArray;
	local Array<X2Action>					TempDamageNodes;
	local Array<X2Action>					DamageNodes;
	local int								ScanNodes;
	local TTile								TargetTile;
	local TTile								StartTile;
	local PathingInputData					PathData;
	local PathingResultData					ResultData;
	local Actor								TargetVisualizer;
	local array<PathPoint>					Path;
	local X2Action_CameraLookAt				TargetCameraAction;

	VisMgr = `XCOMVISUALIZATIONMGR;
	// Jwats: Build the standard visualization
	TypicalAbility_BuildVisualization(VisualizeGameState);

	// Jwats: Now handle the cosmetic unit
	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(Context.InputContext.AbilityTemplateName);

	SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID));
	TargetUnitState = XComGameState_Unit(History.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));
	TargetVisualizer = History.GetVisualizer(Context.InputContext.PrimaryTarget.ObjectID);
	SourceVisualizer = History.GetVisualizer(SourceUnitState.ObjectID);
	SourceUnitState.GetAttachedUnits(AttachedUnitStates, VisualizeGameState);
	`assert(AttachedUnitStates.Length > 0);
	CosmeticUnit = AttachedUnitStates[0];

	CosmeticHeavyWeapon = CosmeticUnit.GetItemInSlot(eInvSlot_HeavyWeapon);

	// Jwats: Because the shooter might be using a unique fire action we'll replace it with the standard fire action to just
	//			command the cosmetic unit
	SourceExitCoverAction = X2Action_ExitCover(VisMgr.GetNodeOfType(VisMgr.BuildVisTree, class'X2Action_ExitCover', SourceVisualizer));
	FireAction = X2Action_Fire(VisMgr.GetNodeOfType(VisMgr.BuildVisTree, AbilityTemplate.ActionFireClass, SourceVisualizer));

	// Jwats: Replace the current fire action with this fire action
	NewFireAction = X2Action_Fire(class'X2Action_Fire'.static.CreateVisualizationAction(Context, SourceVisualizer));
	NewFireAction.SetFireParameters(Context.IsResultContextHit());
	VisMgr.ReplaceNode(NewFireAction, FireAction);

	//	BIT
	ActionMetadata = EmptyMetadata;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(CosmeticUnit.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(CosmeticUnit.ObjectID);
	if( ActionMetadata.StateObject_NewState == none )
		ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
	ActionMetadata.VisualizeActor = History.GetVisualizer(CosmeticUnit.ObjectID);


	TargetTile = TargetUnitState.GetDesiredTileForAttachedCosmeticUnit();
	StartTile = SourceUnitState.GetDesiredTileForAttachedCosmeticUnit();

	class'X2PathSolver'.static.BuildPath(CosmeticUnit, StartTile, TargetTile, PathData.MovementTiles);
	class'X2PathSolver'.static.GetPathPointsFromPath( CosmeticUnit, PathData.MovementTiles, Path );
	class'XComPath'.static.PerformStringPulling(XGUnitNativeBase(ActionMetadata.VisualizeActor), Path);

	PathData.MovingUnitRef = CosmeticUnit.GetReference();
	PathData.MovementData = Path;
	Context.InputContext.MovementPaths.AddItem(PathData);

	class'X2TacticalVisibilityHelpers'.static.FillPathTileData(PathData.MovingUnitRef.ObjectID,	PathData.MovementTiles,	ResultData.PathTileData);
	Context.ResultContext.PathResults.AddItem(ResultData);

	class'X2VisualizerHelpers'.static.ParsePath( Context, ActionMetadata);

	if( TargetVisualizer != none )
	{
		TargetCameraAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		TargetCameraAction.LookAtActor = TargetVisualizer;
		TargetCameraAction.BlockUntilActorOnScreen = true;
		TargetCameraAction.LookAtDuration = 10.0f;		// longer than we need - camera will be removed by tag below
		TargetCameraAction.CameraTag = 'TargetFocusCamera';
		TargetCameraAction.bRemoveTaggedCamera = false;
	}

	// Jwats: Have the bit do an exit cover/fire/enter cover
	// Jwats: Wait to exit cover until the main guy is ready
	ExitCoverAction = X2Action_ExitCover(class'X2Action_ExitCover'.static.AddToVisualizationTree(ActionMetadata, Context, false, , SourceExitCoverAction.ParentActions));
	FireAction = X2Action_Fire(AbilityTemplate.ActionFireClass.static.AddToVisualizationTree(ActionMetadata, Context, false));
	EnterCoverAction = X2Action_EnterCover(class'X2Action_EnterCover'.static.AddToVisualizationTree(ActionMetadata, Context, false, FireAction));
	ExitCoverAction.UseWeapon = XGWeapon(History.GetVisualizer(CosmeticHeavyWeapon.ObjectID));
	FireAction.SetFireParameters(Context.IsResultContextHit());
	
	// Jwats: Make sure that the fire actions are in sync! Wait until both have completed their exit cover
	ParentArray.Length = 0;
	ParentArray.AddItem(ExitCoverAction);
	ParentArray.AddItem(SourceExitCoverAction);
	VisMgr.ConnectAction(FireAction, VisMgr.BuildVisTree, false, , ParentArray);
	VisMgr.ConnectAction(NewFireAction, VisMgr.BuildVisTree, false, , ParentArray);

	// Jwats: Update the apply weapon damage nodes to have the bit's fire flamethrower as their parent instead of the spark's fire node
	VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToUnit', TempDamageNodes);
	DamageNodes = TempDamageNodes;
	VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToTerrain', TempDamageNodes);

	for( ScanNodes = 0; ScanNodes < TempDamageNodes.Length; ++ScanNodes )
	{
		DamageNodes.AddItem(TempDamageNodes[ScanNodes]);
	}
	
	for( ScanNodes = 0; ScanNodes < DamageNodes.Length; ++ScanNodes )
	{
		if( DamageNodes[ScanNodes].ParentActions[0] == NewFireAction )
		{
			VisMgr.DisconnectAction(DamageNodes[ScanNodes]);
			VisMgr.ConnectAction(DamageNodes[ScanNodes], VisMgr.BuildVisTree, false, FireAction);
		}
	}

	// Jwats: Now make sure the enter cover of the bit is a child of all the apply weapon damage nodes
	VisMgr.ConnectAction(EnterCoverAction, VisMgr.BuildVisTree, false, , DamageNodes);
}

static simulated function GremlinSingleTarget_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  Context;
	local X2AbilityTemplate             AbilityTemplate, ThreatTemplate;
	local StateObjectReference          InteractingUnitRef;
	local XComGameState_Item			GremlinItem;
	local XComGameState_Unit			TargetUnitState;
	local XComGameState_Unit			AttachedUnitState;
	local XComGameState_Unit			GremlinUnitState, ActivatingUnitState;
	local array<PathPoint> Path;
	local TTile                         TargetTile;
	local TTile							StartTile;

	local VisualizationActionMetadata        EmptyTrack;
	local VisualizationActionMetadata        ActionMetadata;
	local X2Action_WaitForAbilityEffect DelayAction;
	local X2Action_AbilityPerkStart		PerkStartAction;
	local X2Action_CameraLookAt			CameraAction;

	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local int EffectIndex;
	local PathingInputData              PathData;
	local PathingResultData				ResultData;
	local X2Action_PlayAnimation		PlayAnimation;

	local X2VisualizerInterface TargetVisualizerInterface;
	local string FlyOverText, FlyOverIcon;
	local X2AbilityTag AbilityTag;

	local X2Action_CameraLookAt			TargetCameraAction;
	local Actor TargetVisualizer;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(Context.InputContext.AbilityTemplateName);

	TargetUnitState = XComGameState_Unit( VisualizeGameState.GetGameStateForObjectID( Context.InputContext.PrimaryTarget.ObjectID ) );

	GremlinItem = XComGameState_Item( History.GetGameStateForObjectID( Context.InputContext.ItemObject.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1 ) );
	GremlinUnitState = XComGameState_Unit( History.GetGameStateForObjectID( GremlinItem.CosmeticUnitRef.ObjectID ) );
	AttachedUnitState = XComGameState_Unit( History.GetGameStateForObjectID( GremlinItem.AttachedUnitRef.ObjectID ) );
	ActivatingUnitState = XComGameState_Unit( History.GetGameStateForObjectID( Context.InputContext.SourceObject.ObjectID) );

	if( GremlinUnitState == none )
	{
		`RedScreen("Attempting GremlinSingleTarget_BuildVisualization with a GremlinUnitState of none");
		return;
	}
	
	//Configure the visualization track for the shooter
	//****************************************************************************************

	//****************************************************************************************
	InteractingUnitRef = Context.InputContext.SourceObject;
	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID( InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1 );
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID( InteractingUnitRef.ObjectID );
	ActionMetadata.VisualizeActor = History.GetVisualizer( InteractingUnitRef.ObjectID );

	CameraAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	CameraAction.LookAtActor = ActionMetadata.VisualizeActor;
	CameraAction.BlockUntilActorOnScreen = true;

	class'X2Action_IntrusionProtocolSoldier'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);

	if (AbilityTemplate.ActivationSpeech != '')
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.ActivationSpeech, eColor_Good);
	}

	// make sure he waits for the gremlin to come back, so that the cinescript camera doesn't pop until then
	X2Action_WaitForAbilityEffect(class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded)).SetCustomTimeOutSeconds(30);

	//Configure the visualization track for the gremlin
	//****************************************************************************************

	InteractingUnitRef = GremlinUnitState.GetReference( );

	ActionMetadata = EmptyTrack;
	History.GetCurrentAndPreviousGameStatesForObjectID(GremlinUnitState.ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, , VisualizeGameState.HistoryIndex);
	ActionMetadata.VisualizeActor = GremlinUnitState.GetVisualizer();
	TargetVisualizer = History.GetVisualizer(Context.InputContext.PrimaryTarget.ObjectID);

	class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);

	if (AttachedUnitState.TileLocation != TargetUnitState.TileLocation)
	{
		// Given the target location, we want to generate the movement data.  

		//Handle tall units.
		TargetTile = TargetUnitState.GetDesiredTileForAttachedCosmeticUnit();
		StartTile = AttachedUnitState.GetDesiredTileForAttachedCosmeticUnit();

		class'X2PathSolver'.static.BuildPath(GremlinUnitState, StartTile, TargetTile, PathData.MovementTiles);
		class'X2PathSolver'.static.GetPathPointsFromPath( GremlinUnitState, PathData.MovementTiles, Path );
		class'XComPath'.static.PerformStringPulling(XGUnitNativeBase(ActionMetadata.VisualizeActor), Path);

		PathData.MovingUnitRef = GremlinUnitState.GetReference();
		PathData.MovementData = Path;
		Context.InputContext.MovementPaths.AddItem(PathData);

		class'X2TacticalVisibilityHelpers'.static.FillPathTileData(PathData.MovingUnitRef.ObjectID,	PathData.MovementTiles,	ResultData.PathTileData);
		Context.ResultContext.PathResults.AddItem(ResultData);

		class'X2VisualizerHelpers'.static.ParsePath( Context, ActionMetadata);

		if( TargetVisualizer != none )
		{
			TargetCameraAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
			TargetCameraAction.LookAtActor = TargetVisualizer;
			TargetCameraAction.BlockUntilActorOnScreen = true;
			TargetCameraAction.LookAtDuration = 10.0f;		// longer than we need - camera will be removed by tag below
			TargetCameraAction.CameraTag = 'TargetFocusCamera';
			TargetCameraAction.bRemoveTaggedCamera = false;
		}
	}

	PerkStartAction = X2Action_AbilityPerkStart(class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	PerkStartAction.NotifyTargetTracks = true;

	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree( ActionMetadata, Context ));
	if( AbilityTemplate.CustomSelfFireAnim != '' )
	{
		PlayAnimation.Params.AnimName = AbilityTemplate.CustomSelfFireAnim;
	}
	else
	{
		PlayAnimation.Params.AnimName = 'NO_CombatProtocol';
	}

	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree( ActionMetadata, Context );

	//****************************************************************************************

	//Configure the visualization track for the target
	//****************************************************************************************
	InteractingUnitRef = Context.InputContext.PrimaryTarget;
	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	ActionMetadata.VisualizeActor = TargetVisualizer;

	DelayAction = X2Action_WaitForAbilityEffect( class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree( ActionMetadata, Context ) );
	DelayAction.ChangeTimeoutLength( 20 );       //  give the gremlin plenty of time to show up
	
	for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
	{
		AbilityTemplate.AbilityTargetEffects[ EffectIndex ].AddX2ActionsForVisualization( VisualizeGameState, ActionMetadata, Context.FindTargetEffectApplyResult( AbilityTemplate.AbilityTargetEffects[ EffectIndex ] ) );
	}
					
	if (AbilityTemplate.bShowActivation)
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		if (AbilityTemplate.DataName == 'AidProtocol' && ActivatingUnitState.HasSoldierAbility('ThreatAssessment'))
		{
			ThreatTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('ThreatAssessment');
			FlyOverText = ThreatTemplate.LocFlyOverText;			
			FlyOverIcon = ThreatTemplate.IconImage;
		}
		else
		{		
			FlyOverText = AbilityTemplate.LocFlyOverText;
			FlyOverIcon = AbilityTemplate.IconImage;
		}
		AbilityTag = X2AbilityTag(`XEXPANDCONTEXT.FindTag("Ability"));
		AbilityTag.ParseObj = History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID);
		FlyOverText = `XEXPAND.ExpandString(FlyOverText);
		AbilityTag.ParseObj = none;

		SoundAndFlyOver.SetSoundAndFlyOverParameters(none, FlyOverText, '', eColor_Good, FlyOverIcon, 1.5f, true);
	}

	TargetVisualizerInterface = X2VisualizerInterface(ActionMetadata.VisualizeActor);
	if (TargetVisualizerInterface != none)
	{
		//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
		TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
	}

	if( TargetCameraAction != none )
	{
		TargetCameraAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		TargetCameraAction.CameraTag = 'TargetFocusCamera';
		TargetCameraAction.bRemoveTaggedCamera = true;
	}

	//****************************************************************************************
}

function SparkHeavyWeaponVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory				History;
	local XComGameStateContext_Ability		Context;
	local XComGameState_Unit				SourceUnitState;
	local array<XComGameState_Unit>			AttachedUnitStates;
	local XComGameState_Unit				CosmeticUnit;
	local VisualizationActionMetadata		EmptyMetadata;
	local VisualizationActionMetadata		ActionMetadata;
	local X2AbilityTemplate					AbilityTemplate;
	local XComGameState_Item				CosmeticHeavyWeapon;
	local X2Action_ExitCover				ExitCoverAction;
	local X2Action_ExitCover				SourceExitCoverAction;
	local X2Action_EnterCover				EnterCoverAction;
	local X2Action_Fire						FireAction;
	local X2Action_Fire						NewFireAction;
	local XComGameStateVisualizationMgr		VisMgr;
	local Actor								SourceVisualizer;
	local Array<X2Action>					ParentArray;
	local Array<X2Action>					TempDamageNodes;
	local Array<X2Action>					DamageNodes;
	local int								ScanNodes;

	VisMgr = `XCOMVISUALIZATIONMGR;
	// Jwats: Build the standard visualization
	TypicalAbility_BuildVisualization(VisualizeGameState);

	// Jwats: Now handle the cosmetic unit
	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(Context.InputContext.AbilityTemplateName);

	SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID));
	SourceVisualizer = History.GetVisualizer(SourceUnitState.ObjectID);
	SourceUnitState.GetAttachedUnits(AttachedUnitStates, VisualizeGameState);
	`assert(AttachedUnitStates.Length > 0);
	CosmeticUnit = AttachedUnitStates[0];

	CosmeticHeavyWeapon = CosmeticUnit.GetItemInSlot(eInvSlot_HeavyWeapon);
	`LOG("Cosmetic heavy weapon:" @ CosmeticHeavyWeapon.GetMyTemplateName(),, 'WOTCMoreSparkWeapons');

	// Jwats: Because the shooter might be using a unique fire action we'll replace it with the standard fire action to just
	//			command the cosmetic unit
	SourceExitCoverAction = X2Action_ExitCover(VisMgr.GetNodeOfType(VisMgr.BuildVisTree, class'X2Action_ExitCover', SourceVisualizer));
	FireAction = X2Action_Fire(VisMgr.GetNodeOfType(VisMgr.BuildVisTree, AbilityTemplate.ActionFireClass, SourceVisualizer));

	// Jwats: Replace the current fire action with this fire action
	NewFireAction = X2Action_Fire(class'X2Action_Fire'.static.CreateVisualizationAction(Context, SourceVisualizer));
	NewFireAction.SetFireParameters(Context.IsResultContextHit());
	VisMgr.ReplaceNode(NewFireAction, FireAction);

	// Jwats: Have the bit do an exit cover/fire/enter cover
	ActionMetadata = EmptyMetadata;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(CosmeticUnit.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(CosmeticUnit.ObjectID);
	if( ActionMetadata.StateObject_NewState == none )
		ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
	ActionMetadata.VisualizeActor = History.GetVisualizer(CosmeticUnit.ObjectID);

	// Jwats: Wait to exit cover until the main guy is ready
	ExitCoverAction = X2Action_ExitCover(class'X2Action_ExitCover'.static.AddToVisualizationTree(ActionMetadata, Context, false, , SourceExitCoverAction.ParentActions));
	FireAction = X2Action_Fire(AbilityTemplate.ActionFireClass.static.AddToVisualizationTree(ActionMetadata, Context, false));
	EnterCoverAction = X2Action_EnterCover(class'X2Action_EnterCover'.static.AddToVisualizationTree(ActionMetadata, Context, false, FireAction));
	ExitCoverAction.UseWeapon = XGWeapon(History.GetVisualizer(CosmeticHeavyWeapon.ObjectID));
	FireAction.SetFireParameters(Context.IsResultContextHit());
	
	// Jwats: Make sure that the fire actions are in sync! Wait until both have completed their exit cover
	ParentArray.Length = 0;
	ParentArray.AddItem(ExitCoverAction);
	ParentArray.AddItem(SourceExitCoverAction);
	VisMgr.ConnectAction(FireAction, VisMgr.BuildVisTree, false, , ParentArray);
	VisMgr.ConnectAction(NewFireAction, VisMgr.BuildVisTree, false, , ParentArray);

	// Jwats: Update the apply weapon damage nodes to have the bit's fire flamethrower as their parent instead of the spark's fire node
	VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToUnit', TempDamageNodes);
	DamageNodes = TempDamageNodes;
	VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToTerrain', TempDamageNodes);

	for( ScanNodes = 0; ScanNodes < TempDamageNodes.Length; ++ScanNodes )
	{
		DamageNodes.AddItem(TempDamageNodes[ScanNodes]);
	}
	
	for( ScanNodes = 0; ScanNodes < DamageNodes.Length; ++ScanNodes )
	{
		if( DamageNodes[ScanNodes].ParentActions[0] == NewFireAction )
		{
			VisMgr.DisconnectAction(DamageNodes[ScanNodes]);
			VisMgr.ConnectAction(DamageNodes[ScanNodes], VisMgr.BuildVisTree, false, FireAction);
		}
	}

	// Jwats: Now make sure the enter cover of the bit is a child of all the apply weapon damage nodes
	VisMgr.ConnectAction(EnterCoverAction, VisMgr.BuildVisTree, false, , DamageNodes);
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