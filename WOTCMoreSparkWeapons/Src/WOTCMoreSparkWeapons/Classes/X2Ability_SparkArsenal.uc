class X2Ability_SparkArsenal extends X2Ability;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_Ammo_Sabot_Ability());

	Templates.AddItem(Create_RestorativeMist_Heal());
	Templates.AddItem(Create_RestorativeMist_HealBit());

	Templates.AddItem(Create_ElectroPulse());
	Templates.AddItem(Create_ElectroPulse_Bit());

	return Templates;
}

//	==============================================================
//			SABOT AMMO
//	==============================================================

static function X2AbilityTemplate Create_Ammo_Sabot_Ability()
{
	local X2AbilityTemplate		Template;
	local X2Effect_SabotAmmo	SabotAmmo;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_Ammo_Sabot_Ability');

	SetPassive(Template);
	SetHidden(Template);
	Template.IconImage = "img:///IRIRestorativeMist.UI.UIPerk_Ammo_Sabot";
	Template.AbilitySourceName = 'eAbilitySource_Item';

	SabotAmmo = new class'X2Effect_SabotAmmo';
	SabotAmmo.BuildPersistentEffect(1, true);
	SabotAmmo.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(SabotAmmo);

	return Template;
}


//	==============================================================
//			RESTORATIVE MIST
//	==============================================================

static function SetUpRestorativeMist(X2AbilityTemplate Template)
{
	local X2Condition_UnitProperty				UnitPropertyCondition;
	local X2AbilityMultiTarget_Radius			MultiTargetStyle;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2Effect_ApplyMedikitHeal				MedikitHeal;
	local X2Effect_RemoveEffectsByDamageType	RemoveEffects;	
	local name									HealType;

	//	Icon
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.MEDIKIT_HEAL_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	//	Targeting and Triggering
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	MultiTargetStyle = new class'X2AbilityMultiTarget_Radius';
	MultiTargetStyle.bUseWeaponRadius = false;
	MultiTargetStyle.bIgnoreBlockingCover = false;
	MultiTargetStyle.fTargetRadius = class'X2Item_RestorativeMist_CV'.default.HEAL_RADIUS;
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

	//	Costs
	AddCharges(Template, class'X2Item_RestorativeMist_CV'.default.CHARGES);
	AddCooldown(Template, class'X2Item_RestorativeMist_CV'.default.COOLDOWN);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	//	Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	//	Multi Target Conditions
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeHostileToSource = !class'X2Item_RestorativeMist_CV'.default.HEALS_ENEMIES;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeFullHealth = true;
	UnitPropertyCondition.ExcludeRobotic = true;
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	MedikitHeal = new class'X2Effect_ApplyMedikitHeal';
	MedikitHeal.PerUseHP = class'X2Item_RestorativeMist_CV'.default.HEAL_HP;
	MedikitHeal.IncreasedHealProject = 'BattlefieldMedicine';
	MedikitHeal.IncreasedPerUseHP = class'X2Item_RestorativeMist_CV'.default.BATTLEFIELD_MEDICINE_HEAL_HP;
	Template.AddMultiTargetEffect(MedikitHeal);

	RemoveEffects = new class'X2Effect_RemoveEffectsByDamageType';
	foreach class'X2Ability_DefaultAbilitySet'.default.MedikitHealEffectTypes(HealType)
	{
		RemoveEffects.DamageTypesToRemove.AddItem(HealType);
	}
	Template.AddMultiTargetEffect(RemoveEffects);

	//	State and Viz
	Template.ActivationSpeech = 'HealingAlly';
	Template.Hostility = eHostility_Defensive;

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
}

static function X2AbilityTemplate Create_RestorativeMist_Heal()
{
	local X2AbilityTemplate						Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_RestorativeMist_Heal');

	SetUpRestorativeMist(Template);

	//	Icon Setup
	Template.IconImage = "img:///IRIRestorativeMist.UI.UI_RestorativeMist";

	//	Targeting and Triggering
	Template.AbilityTargetStyle = default.SelfTarget;
	
	//	State and Viz
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2DataTemplate Create_RestorativeMist_HealBit()
{
	local X2AbilityTemplate             Template;
	local X2AbilityTarget_Cursor        CursorTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_RestorativeMist_HealBit');

	SetUpRestorativeMist(Template);

	//	Icon Setup
	Template.IconImage = "img:///IRIRestorativeMist.UI.UI_RestorativeMist_BIT";

	//	Triggering and Targeting
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = class'X2Item_RestorativeMist_CV'.default.HEAL_RANGE;
	CursorTarget.bRestrictToWeaponRange = false;
	Template.AbilityTargetStyle = CursorTarget;

	Template.TargetingMethod = class'X2TargetingMethod_GremlinAOE';

	//	 Game State and Viz
	Template.CustomFireAnim = 'HL_SendGremlin';
	Template.CustomSelfFireAnim = 'FF_RestorativeMistA';

	Template.ActivationSpeech = 'HealingAlly';
	Template.PostActivationEvents.AddItem('ItemRecalled');
	Template.bStationaryWeapon = true;
	Template.BuildNewGameStateFn = SendBITToLocation_BuildGameState;
	Template.BuildVisualizationFn = RestorativeMist_BIT_BuildVisualization;

	return Template;
}

//	Unmodofied. Can't reference the original class'X2Ability_SpecialistAbilitySet'.static.SendGremlinToLocation_BuildGameState cuz it's not static?
simulated function XComGameState SendBITToLocation_BuildGameState( XComGameStateContext Context )
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState NewGameState;
	local XComGameState_Item GremlinItemState;
	local XComGameState_Unit GremlinUnitState;
	local vector TargetPos;

	AbilityContext = XComGameStateContext_Ability(Context);
	NewGameState = TypicalAbility_BuildGameState(Context);

	//`LOG("SendBITToLocation_BuildGameState: begin. Source Item:" @ AbilityContext.InputContext.ItemObject.ObjectID,, 'WOTCMoreSparkWeapons');

	GremlinItemState = XComGameState_Item(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.ItemObject.ObjectID));
	if (GremlinItemState == none)
	{
		GremlinItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', AbilityContext.InputContext.ItemObject.ObjectID));
	}
	//`LOG("SendBITToLocation_BuildGameState: begin. GremlinItemState:" @ GremlinItemState.GetMyTemplateName() @ GremlinItemState.CosmeticUnitRef.ObjectID,, 'WOTCMoreSparkWeapons');

	GremlinUnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(GremlinItemState.CosmeticUnitRef.ObjectID));
	if (GremlinUnitState == none)
	{
		GremlinUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', GremlinItemState.CosmeticUnitRef.ObjectID));
	}

	GremlinItemState.AttachedUnitRef.ObjectID = 0;
	TargetPos = AbilityContext.InputContext.TargetLocations[0];
	GremlinUnitState.SetVisibilityLocationFromVector(TargetPos);

	//`LOG("SendBITToLocation_BuildGameState: end",, 'WOTCMoreSparkWeapons');

	return NewGameState;
}

simulated function RestorativeMist_BIT_BuildVisualization( XComGameState VisualizeGameState )
{
	local XComGameStateHistory			History;
	local XComWorldData					WorldData;
	local XComGameStateContext_Ability  Context;
	local X2AbilityTemplate             AbilityTemplate;

	local XComGameState_Item			GremlinItem;
	local XComGameState_Unit			AttachedUnitState;
	local XComGameState_Unit			GremlinUnitState;

	local StateObjectReference          InteractingUnitRef;

	local VisualizationActionMetadata			EmptyTrack;
	local VisualizationActionMetadata			ActionMetadata;
	local X2Action_WaitForAbilityEffect DelayAction;
	local X2Action_AbilityPerkStart		PerkStartAction;

	local Vector						TargetPosition;
	local TTile							TargetTile;
	local PathingInputData              PathData;
	local array<PathPoint> Path;
	local PathingResultData	ResultData;

	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local X2Action_PlayAnimation		PlayAnimation;

	local int i, j, EffectIndex;
	local X2VisualizerInterface TargetVisualizerInterface;

	local XComGameState_Unit SparkUnitState;
	local int BITObjectID;

	//`LOG("RestorativeMist_BIT_BuildVisualization: begin",, 'WOTCMoreSparkWeapons');

	History = `XCOMHISTORY;
	WorldData = `XWORLD;

	Context = XComGameStateContext_Ability( VisualizeGameState.GetContext( ) );
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager( ).FindAbilityTemplate( Context.InputContext.AbilityTemplateName );

	//****************************************************************************************
	//Configure the visualization track for the owner of the Gremlin
	//`LOG("RestorativeMist_BIT_BuildVisualization: begin shooter",, 'WOTCMoreSparkWeapons');
	SparkUnitState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID));

	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(SparkUnitState.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = SparkUnitState;
	ActionMetadata.VisualizeActor = History.GetVisualizer(SparkUnitState.ObjectID);

	//`LOG("RestorativeMist_BIT_BuildVisualization: play animation",, 'WOTCMoreSparkWeapons');

	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree( ActionMetadata, Context ));
	PlayAnimation.Params.AnimName = 'HL_SendGremlinA';

	if (AbilityTemplate.ActivationSpeech != '')
	{
		//`LOG("RestorativeMist_BIT_BuildVisualization: speech and flyover",, 'WOTCMoreSparkWeapons');

		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.ActivationSpeech, eColor_Good);
	}

	//****************************************************************************************
	//Configure the visualization track for the Gremlin
	BITObjectID = Context.InputContext.ItemObject.ObjectID;

	//`LOG("RestorativeMist_BIT_BuildVisualization: Gremling:" @ BITObjectID,, 'WOTCMoreSparkWeapons');

	GremlinItem = XComGameState_Item( History.GetGameStateForObjectID( BITObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1 ) );
	GremlinUnitState = XComGameState_Unit( History.GetGameStateForObjectID( GremlinItem.CosmeticUnitRef.ObjectID ) );
	AttachedUnitState = XComGameState_Unit( History.GetGameStateForObjectID( GremlinItem.AttachedUnitRef.ObjectID ) );

	InteractingUnitRef = GremlinItem.CosmeticUnitRef;

	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID( InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1 );
	ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
	ActionMetadata.VisualizeActor = History.GetVisualizer( InteractingUnitRef.ObjectID );

	//`LOG("RestorativeMist_BIT_BuildVisualization: shooter effects",, 'WOTCMoreSparkWeapons');

	//If there are effects added to the shooter, add the visualizer actions for them
	for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
	{
		AbilityTemplate.AbilityShooterEffects[ EffectIndex ].AddX2ActionsForVisualization( VisualizeGameState, ActionMetadata, Context.FindShooterEffectApplyResult( AbilityTemplate.AbilityShooterEffects[ EffectIndex ] ) );
	}

	if (Context.InputContext.TargetLocations.Length > 0)
	{
		//`LOG("RestorativeMist_BIT_BuildVisualization: target position",, 'WOTCMoreSparkWeapons');

		TargetPosition = Context.InputContext.TargetLocations[0];
		TargetTile = `XWORLD.GetTileCoordinatesFromPosition( TargetPosition );

		if (WorldData.IsTileFullyOccupied( TargetTile ))
		{
			TargetTile.Z++;
		}

		if (!WorldData.IsTileFullyOccupied( TargetTile ))
		{
			//`LOG("RestorativeMist_BIT_BuildVisualization: pathing",, 'WOTCMoreSparkWeapons');

			class'X2PathSolver'.static.BuildPath( GremlinUnitState, AttachedUnitState.TileLocation, TargetTile, PathData.MovementTiles );
			class'X2PathSolver'.static.GetPathPointsFromPath( GremlinUnitState, PathData.MovementTiles, Path );
			class'XComPath'.static.PerformStringPulling(XGUnitNativeBase(ActionMetadata.VisualizeActor), Path);
			PathData.MovementData = Path;
			PathData.MovingUnitRef = GremlinUnitState.GetReference();
			Context.InputContext.MovementPaths.AddItem(PathData);

			class'X2TacticalVisibilityHelpers'.static.FillPathTileData(PathData.MovingUnitRef.ObjectID,	PathData.MovementTiles,	ResultData.PathTileData);
			Context.ResultContext.PathResults.AddItem(ResultData);

			class'X2VisualizerHelpers'.static.ParsePath( Context, ActionMetadata);
		}
		else
		{
			//`LOG("Gremlin was unable to find a location to move to for ability "@Context.InputContext.AbilityTemplateName,, 'WOTCMoreSparkWeapons');
			`redscreen("Gremlin was unable to find a location to move to for ability "@Context.InputContext.AbilityTemplateName);
		}
	}
	else
	{
		//`LOG("Gremlin was not provided a location to move to for ability " @Context.InputContext.AbilityTemplateName,, 'WOTCMoreSparkWeapons');
		`redscreen("Gremlin was not provided a location to move to for ability "@Context.InputContext.AbilityTemplateName);
	}

	//`LOG("Perk start action",, 'WOTCMoreSparkWeapons');
	PerkStartAction = X2Action_AbilityPerkStart(class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	PerkStartAction.NotifyTargetTracks = true;

	//`LOG("play animation",, 'WOTCMoreSparkWeapons');
	PlayAnimation = none;
	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree( ActionMetadata, Context ));
	PlayAnimation.Params.AnimName = AbilityTemplate.CustomSelfFireAnim;

	// build in a delay before we hit the end (which stops activation effects)
	//`LOG("Delay action",, 'WOTCMoreSparkWeapons');
	DelayAction = X2Action_WaitForAbilityEffect( class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree( ActionMetadata, Context ) );
	DelayAction.ChangeTimeoutLength( class'X2Ability_SpecialistAbilitySet'.default.GREMLIN_PERK_EFFECT_WINDOW );

	//`LOG("Perk end",, 'WOTCMoreSparkWeapons');

	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree( ActionMetadata, Context );

	//****************************************************************************************
	//Configure the visualization track for the targets
	//****************************************************************************************
	//`LOG("Targets",, 'WOTCMoreSparkWeapons');
	for (i = 0; i < Context.InputContext.MultiTargets.Length; ++i)
	{
		//`LOG("Target:" @ i,, 'WOTCMoreSparkWeapons');

		InteractingUnitRef = Context.InputContext.MultiTargets[i];
		ActionMetadata = EmptyTrack;
		ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
		ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

		class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree( ActionMetadata, Context, false, PlayAnimation);

		for( j = 0; j < Context.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
		{
			Context.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, Context.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
		}

		TargetVisualizerInterface = X2VisualizerInterface(ActionMetadata.VisualizeActor);
		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
		}
	}
	//****************************************************************************************

	//`LOG("RestorativeMist_BIT_BuildVisualization: end",, 'WOTCMoreSparkWeapons');
}


//	==============================================================
//			ELECTRO PULSE
//	==============================================================

static function SetUpElectroPulse(X2AbilityTemplate Template)
{
	local X2Effect_StunCyberus					StunnedEffect;
	local X2Effect_RemoveEffects				RemoveEffects;
	local X2Condition_UnitProperty				UnitCondition;
	local X2Condition_Augmented					AugmentedCondition;
	local X2AbilityCost_ActionPoints			ActionPointCost;

	//	Icon Setup
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.MEDIKIT_HEAL_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	//	Triggering and Targeting
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	//	Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	//	Costs
	AddCharges(Template, class'X2Item_ElectroPulse'.default.CHARGES);
	AddCooldown(Template, class'X2Item_ElectroPulse'.default.COOLDOWN);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	//	Deal damage
	if (class'X2Item_ElectroPulse'.default.DEAL_DAMAGE)
	{
		Template.AddMultiTargetEffect(new class'X2Effect_ApplyWeaponDamage');
	}
	//	Remove Energy Shields from all units in AOE
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove = class'X2Item_ElectroPulse'.default.REMOVE_EFFECTS;
	Template.AddMultiTargetEffect(RemoveEffects);

	//	Disable Weapons on all units in AOE
	if (class'X2Item_ElectroPulse'.default.DISABLE_WEAPONS)
	{
		Template.AddMultiTargetEffect(new class'X2Effect_DisableWeapon');
	}

	//	Stun Robots and similar units
	UnitCondition = new class'X2Condition_UnitProperty';
	UnitCondition.ExcludeOrganic = true;
	UnitCondition.IncludeWeakAgainstTechLikeRobot = true;
	UnitCondition.ExcludeFriendlyToSource = false;

	StunnedEffect = CreateCyberusStunnedStatusEffect(class'X2Item_ElectroPulse'.default.STUN_DURATION_ACTIONS, class'X2Item_ElectroPulse'.default.STUN_CHANCE, false);
	StunnedEffect.SetDisplayInfo(ePerkBuff_Penalty, class'X2StatusEffects'.default.RoboticStunnedFriendlyName, class'X2StatusEffects'.default.RoboticStunnedFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_stun");
	StunnedEffect.TargetConditions.AddItem(UnitCondition);
	Template.AddMultiTargetEffect(StunnedEffect);

	//	Stun fully-augmented soldiers.
	AugmentedCondition = new class'X2Condition_Augmented';
	AugmentedCondition.Head = true;
	AugmentedCondition.Torso = true;
	AugmentedCondition.Arms = true;
	AugmentedCondition.Legs = true;

	StunnedEffect = CreateCyberusStunnedStatusEffect(class'X2Item_ElectroPulse'.default.STUN_DURATION_ACTIONS, class'X2Item_ElectroPulse'.default.STUN_CHANCE, false);
	StunnedEffect.SetDisplayInfo(ePerkBuff_Penalty, class'X2StatusEffects'.default.RoboticStunnedFriendlyName, class'X2StatusEffects'.default.RoboticStunnedFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_stun");
	StunnedEffect.TargetConditions.AddItem(AugmentedCondition);
	Template.AddMultiTargetEffect(StunnedEffect);

	//	Make Robots easier to hack
	UnitCondition = new class'X2Condition_UnitProperty';
	UnitCondition.ExcludeOrganic = true;
	Template.AddMultiTargetEffect(class'X2StatusEffects'.static.CreateHackDefenseChangeStatusEffect(class'X2Item_ElectroPulse'.default.HACK_DEFENSE_REDUCTION, UnitCondition));

	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Offensive;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	//	Same as for Throw Grenade
	Template.SuperConcealmentLoss = 100;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.GrenadeLostSpawnIncreasePerUse;
}

static function X2Effect_StunCyberus CreateCyberusStunnedStatusEffect(int StunLevel, int Chance, optional bool bIsMentalDamage = true)
{
	local X2Effect_StunCyberus StunnedEffect;
	local X2Condition_UnitProperty UnitPropCondition;

	StunnedEffect = new class'X2Effect_StunCyberus';
	StunnedEffect.BuildPersistentEffect(1, true, true, false, eGameRule_UnitGroupTurnBegin);
	StunnedEffect.ApplyChance = Chance;
	StunnedEffect.StunLevel = StunLevel;
	StunnedEffect.bIsImpairing = true;
	StunnedEffect.EffectHierarchyValue = class'X2StatusEffects'.default.STUNNED_HIERARCHY_VALUE;
	StunnedEffect.EffectName = class'X2AbilityTemplateManager'.default.StunnedName;
	StunnedEffect.VisualizationFn = class'X2StatusEffects'.static.StunnedVisualization;
	StunnedEffect.EffectTickedVisualizationFn = class'X2StatusEffects'.static.StunnedVisualizationTicked;
	StunnedEffect.EffectRemovedVisualizationFn = class'X2StatusEffects'.static.StunnedVisualizationRemoved;
	StunnedEffect.EffectRemovedFn = class'X2StatusEffects'.static.StunnedEffectRemoved;
	StunnedEffect.bRemoveWhenTargetDies = true;
	StunnedEffect.bCanTickEveryAction = true;

	if( bIsMentalDamage )
	{
		StunnedEffect.DamageTypes.AddItem('Mental');
	}

	if (class'X2StatusEffects'.default.StunnedParticle_Name != "")
	{
		StunnedEffect.VFXTemplateName = class'X2StatusEffects'.default.StunnedParticle_Name;
		StunnedEffect.VFXSocket = class'X2StatusEffects'.default.StunnedSocket_Name;
		StunnedEffect.VFXSocketsArrayName = class'X2StatusEffects'.default.StunnedSocketsArray_Name;
	}

	UnitPropCondition = new class'X2Condition_UnitProperty';
	UnitPropCondition.ExcludeFriendlyToSource = false;
	UnitPropCondition.FailOnNonUnits = true;
	StunnedEffect.TargetConditions.AddItem(UnitPropCondition);

	return StunnedEffect;
}

static function X2AbilityTemplate Create_ElectroPulse()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_Radius			MultiTargetStyle;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_ElectroPulse');

	SetUpElectroPulse(Template);

	Template.IconImage = "img:///IRIElectroPulse.UI.UI_EMPulse";

	//	Targeting and Triggering
	Template.AbilityTargetStyle = default.SelfTarget;

	MultiTargetStyle = new class'X2AbilityMultiTarget_Radius';
	MultiTargetStyle.bUseWeaponRadius = false;
	MultiTargetStyle.bIgnoreBlockingCover = true;
	MultiTargetStyle.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTargetStyle.fTargetRadius = class'X2Item_ElectroPulse'.default.PULSE_RADIUS;
	Template.AbilityMultiTargetStyle = MultiTargetStyle;
	
	//	State and Viz	
	Template.CinescriptCameraType = "Iridar_EMPulse_Spark";
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2DataTemplate Create_ElectroPulse_Bit()
{
	local X2AbilityTemplate             Template;
	local X2AbilityTarget_Cursor        CursorTarget;
	local X2AbilityMultiTarget_Radius   RadiusMultiTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_ElectroPulse_Bit');

	SetUpElectroPulse(Template);

	Template.IconImage = "img:///IRIElectroPulse.UI.UI_EMPulse_BIT";

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = class'X2Item_ElectroPulse'.default.PULSE_RANGE;
	CursorTarget.bRestrictToWeaponRange = false;
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	RadiusMultiTarget.bUseWeaponRadius = false;
	RadiusMultiTarget.fTargetRadius = class'X2Item_ElectroPulse'.default.PULSE_RADIUS;
	RadiusMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_GremlinAOE';

	//	 Game State and Viz
	//Template.CustomFireAnim = 'HL_SendGremlin';
	Template.CustomFireAnim = 'FF_ElectroPulse';
	Template.CustomSelfFireAnim = 'FF_ElectroPulse';
	//Template.ActivationSpeech = 'HealingAlly';
	Template.PostActivationEvents.AddItem('ItemRecalled');
	Template.bStationaryWeapon = true;

	Template.BuildNewGameStateFn = SendBITToLocation_BuildGameState;
	Template.BuildVisualizationFn = CapacitorDischarge_BuildVisualization;

	return Template;
}

simulated function CapacitorDischarge_BuildVisualization( XComGameState VisualizeGameState )
{
	local XComGameStateHistory			History;
	local XComWorldData					WorldData;
	local XComGameStateContext_Ability  Context;
	local X2AbilityTemplate             AbilityTemplate;

	local XComGameState_Item			GremlinItem;
	local XComGameState_Unit			AttachedUnitState;
	local XComGameState_Unit			GremlinUnitState;

	local StateObjectReference          InteractingUnitRef;
	local StateObjectReference          GremlinOwnerUnitRef;

	local VisualizationActionMetadata			EmptyTrack;
	local VisualizationActionMetadata			ActionMetadata;
	local X2Action_WaitForAbilityEffect DelayAction;
	local X2Action_AbilityPerkStart		PerkStartAction;

	local Vector						TargetPosition;
	local TTile							TargetTile;
	local PathingInputData              PathData;
	local array<PathPoint> Path;
	local PathingResultData	ResultData;

	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local X2Action_PlayAnimation		PlayAnimation;


	local int i, j, EffectIndex;
	local X2VisualizerInterface TargetVisualizerInterface;

	History = `XCOMHISTORY;
	WorldData = `XWORLD;

	Context = XComGameStateContext_Ability( VisualizeGameState.GetContext( ) );
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager( ).FindAbilityTemplate( Context.InputContext.AbilityTemplateName );

	GremlinItem = XComGameState_Item( History.GetGameStateForObjectID( Context.InputContext.ItemObject.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1 ) );
	GremlinUnitState = XComGameState_Unit( History.GetGameStateForObjectID( GremlinItem.CosmeticUnitRef.ObjectID ) );
	AttachedUnitState = XComGameState_Unit( History.GetGameStateForObjectID( GremlinItem.AttachedUnitRef.ObjectID ) );

	InteractingUnitRef = GremlinItem.CosmeticUnitRef;

	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID( InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1 );
	ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
	ActionMetadata.VisualizeActor = History.GetVisualizer( InteractingUnitRef.ObjectID );

	//If there are effects added to the shooter, add the visualizer actions for them
	for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
	{
		AbilityTemplate.AbilityShooterEffects[ EffectIndex ].AddX2ActionsForVisualization( VisualizeGameState, ActionMetadata, Context.FindShooterEffectApplyResult( AbilityTemplate.AbilityShooterEffects[ EffectIndex ] ) );
	}

	if (Context.InputContext.TargetLocations.Length > 0)
	{
		TargetPosition = Context.InputContext.TargetLocations[0];
		TargetTile = `XWORLD.GetTileCoordinatesFromPosition( TargetPosition );

		if (WorldData.IsTileFullyOccupied( TargetTile ))
		{
			TargetTile.Z++;
		}

		if (!WorldData.IsTileFullyOccupied( TargetTile ))
		{
			class'X2PathSolver'.static.BuildPath( GremlinUnitState, AttachedUnitState.TileLocation, TargetTile, PathData.MovementTiles );
			class'X2PathSolver'.static.GetPathPointsFromPath( GremlinUnitState, PathData.MovementTiles, Path );
			class'XComPath'.static.PerformStringPulling(XGUnitNativeBase(ActionMetadata.VisualizeActor), Path);
			PathData.MovementData = Path;
			PathData.MovingUnitRef = GremlinUnitState.GetReference();
			Context.InputContext.MovementPaths.AddItem(PathData);

			class'X2TacticalVisibilityHelpers'.static.FillPathTileData(PathData.MovingUnitRef.ObjectID,	PathData.MovementTiles,	ResultData.PathTileData);
			Context.ResultContext.PathResults.AddItem(ResultData);

			class'X2VisualizerHelpers'.static.ParsePath( Context, ActionMetadata);
		}
		else
		{
			`redscreen("Gremlin was unable to find a location to move to for ability "@Context.InputContext.AbilityTemplateName);
		}
	}
	else
	{
		`redscreen("Gremlin was not provided a location to move to for ability "@Context.InputContext.AbilityTemplateName);
	}

	PerkStartAction = X2Action_AbilityPerkStart(class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	PerkStartAction.NotifyTargetTracks = true;

	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree( ActionMetadata, Context ));
	PlayAnimation.Params.AnimName = AbilityTemplate.CustomSelfFireAnim;

	

	// build in a delay before we hit the end (which stops activation effects)
	DelayAction = X2Action_WaitForAbilityEffect( class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree( ActionMetadata, Context ) );
	DelayAction.ChangeTimeoutLength( 1.75f );

	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree( ActionMetadata, Context );

	//****************************************************************************************
	//Configure the visualization track for the targets
	//****************************************************************************************
	for (i = 0; i < Context.InputContext.MultiTargets.Length; ++i)
	{
		InteractingUnitRef = Context.InputContext.MultiTargets[i];
		ActionMetadata = EmptyTrack;
		ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
		ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

		class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree( ActionMetadata, Context );

		for( j = 0; j < Context.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
		{
			Context.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, Context.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
		}

		TargetVisualizerInterface = X2VisualizerInterface(ActionMetadata.VisualizeActor);
		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
		}
	}
	//****************************************************************************************


	//Configure the visualization track for the owner of the Gremlin
	//****************************************************************************************
	GremlinOwnerUnitRef = GremlinItem.OwnerStateObject;

	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(GremlinOwnerUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(GremlinOwnerUnitRef.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(GremlinOwnerUnitRef.ObjectID);

	if (AbilityTemplate.ActivationSpeech != '')
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.ActivationSpeech, eColor_Good);
	}
	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree( ActionMetadata, Context ));
	PlayAnimation.Params.AnimName = AbilityTemplate.CustomFireAnim;

	
	//****************************************************************************************
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