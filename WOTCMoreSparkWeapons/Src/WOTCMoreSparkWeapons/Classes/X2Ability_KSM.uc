class X2Ability_KSM extends X2Ability;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_KineticStrike());
	Templates.AddItem(Create_KineticStrike_Passive());

	Templates.AddItem(Create_RestorativeMist_Heal());
	Templates.AddItem(Create_RestorativeMist_HealBit());

	return Templates;
}

//	==============================================================
//			KINETIC STRIKE MODULE
//	==============================================================

static function X2AbilityTemplate Create_KineticStrike()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Cylinder		MultiTarget;
	//local X2Effect_AdditionalAnimSets		AnimSetEffect;
	local X2Effect_OverrideDeathAction		OverrideDeathAction;
	//local X2Effect_Knockback				KnockbackEffect;
	//local X2Condition_UnblockedTile			UnblockedTileCondition;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_KineticStrike');

	//	Icon setup
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_mecclosecombat";

	//	Targeting and Triggering
	Template.AbilityToHitCalc = new class'X2AbilityToHitCalc_StandardMelee';
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	//CursorTarget.bRestrictToWeaponRange = true;
	CursorTarget.FixedAbilityRange = 2;	//	Able to target diagonally
	Template.AbilityTargetStyle = CursorTarget;
	
	MultiTarget = new class'X2AbilityMultiTarget_Cylinder';
	MultiTarget.bIgnoreBlockingCover = true;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTarget.fTargetHeight = 1.5f;
	MultiTarget.fTargetRadius = 0.75f;
	Template.AbilityMultiTargetStyle = MultiTarget;

	//Template.SkipRenderOfAOETargetingTiles = true;
	Template.TargetingMethod = class'X2TargetingMethod_KSM';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	//	Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
	
	//	Multi Target Conditions
	Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetOnlyProperty);
	
	//	Ability Costs
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	//	Multi Target effects
	/*
	AnimSetEffect = new class'X2Effect_AdditionalAnimSets';
	AnimSetEffect.AddAnimSetWithPath("IRIKineticStrikeModule.Anims.AS_Trooper_Kill");
	AnimSetEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddShooterEffect(AnimSetEffect);*/
	/*
	AnimSetEffect = new class'X2Effect_AdditionalAnimSets';
	AnimSetEffect.AddAnimSetWithPath("IRIKineticStrikeModule.Anims.AS_Trooper_Death");
	AnimSetEffect.BuildPersistentEffect(1, true, false, false);
	AnimSetEffect.TargetConditions.AddItem(new class'X2Condition_UnblockedTile');
	Template.AddMultiTargetEffect(AnimSetEffect);*/

	Template.ActionFireClass = class'X2Action_KSM_Kill';
	OverrideDeathAction = new class'X2Effect_OverrideDeathAction';
	OverrideDeathAction.DeathActionClass = class'X2Action_KSM_Death';
	OverrideDeathAction.EffectName = 'IRI_KineticStrike_DeathActionEffect';
	//OverrideDeathAction.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnBegin);
	//OverrideDeathAction.TargetConditions.AddItem(new class'X2Condition_UnblockedTile');
	Template.AddMultiTargetEffect(OverrideDeathAction);

	//Template.AddMultiTargetEffect(new class'X2Effect_DLC_3StrikeDamage');
	WeaponDamageEffect = new class'X2Effect_DLC_3StrikeDamage';
	Template.AddMultiTargetEffect(WeaponDamageEffect);

	//	Add knockback only to enemies that *are* on blocked tiles.
	/*
	UnblockedTileCondition = new class'X2Condition_UnblockedTile';
	UnblockedTileCondition.bReverseCondition = true;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 8;
	KnockbackEffect.bKnockbackDestroysNonFragile = true;
	KnockbackEffect.TargetConditions.AddItem(UnblockedTileCondition);
	Template.AddMultiTargetEffect(KnockbackEffect);
	Template.bOverrideMeleeDeath = true;*/

	Template.CustomFireAnim = 'FF_Melee';
	Template.SourceMissSpeech = 'SwordMiss';
	//Template.ActivationSpeech = 'RocketLauncher';
	Template.CinescriptCameraType = "Spark_Strike";

	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";
	//Template.MeleePuckMeshPath = "Materials_DLC3.MovePuck_Strike";
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = KineticStrike_BuildVisualization;
	Template.ModifyNewContextFn = KineticStrike_ModifyActivatedAbilityContext;

	//	This ability is offensive and can be interrupted!
	Template.Hostility = eHostility_Offensive;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MeleeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;	
}

static simulated function KineticStrike_ModifyActivatedAbilityContext(XComGameStateContext Context)
{
	local XComGameStateContext_Ability	AbilityContext;

	//	Make primary target of the ability to be the same as the 0th multi target. 
	//	Used only for the camera work. KS doesn't apply target effects.
	AbilityContext = XComGameStateContext_Ability(Context);
	if (AbilityContext.InputContext.MultiTargets.Length > 0)
	{
		AbilityContext.InputContext.PrimaryTarget = AbilityContext.InputContext.MultiTargets[0];	
		AbilityContext.ResultContext.HitResult = AbilityContext.ResultContext.MultiTargetHitResults[0];
	}
}

static function KineticStrike_BuildVisualization(XComGameState VisualizeGameState)
{	
	local XComGameStateVisualizationMgr VisMgr;
	local array<X2Action>				FindActions;
	local X2Action						FindAction, CycleAction;
	local X2Action						FireAction;
	local XComGameStateContext_Ability	AbilityContext;
	local X2Action_MoveTurn				MoveTurnAction;
	local VisualizationActionMetadata   ActionMetadata, EmptyTrack;
	local XComGameStateHistory			History;
	local XComGameState_Unit			SourceUnit, TargetUnit;
	local X2Action_PlayAnimation		PlayAnimation;
	//local X2Action						DamageUnitAction;
	//local X2Action_MarkerNamed	DamageTerrainAction;
	local int i;

	class'X2Ability'.static.TypicalAbility_BuildVisualization(VisualizeGameState);
	
	History = `XCOMHISTORY;
	VisMgr = `XCOMVISUALIZATIONMGR;
	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	for (i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++)
	{
		`LOG("Target unit:" @ XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[i].ObjectID)).GetFullName(),, 'WOTCMoreSparkWeapons');
	}

	//	Make the "primary target" of the ability rotate towards the spark
	if (AbilityContext.InputContext.MultiTargets.Length > 0)
	{
		FireAction = VisMgr.GetNodeOfType(VisMgr.BuildVisTree, class'X2Action_Fire',, AbilityContext.InputContext.SourceObject.ObjectID);

		//	Make the SPARK rotate towards the target. This doesn't always happen automatically in time.
		TargetUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[0].ObjectID));
		ActionMetadata = FireAction.Metadata;
		MoveTurnAction = X2Action_MoveTurn(class'X2Action_MoveTurn'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, true, FireAction.ParentActions[0]));
		MoveTurnAction.m_vFacePoint =  `XWORLD.GetPositionFromTileCoordinates(TargetUnit.TileLocation);
		MoveTurnAction.UpdateAimTarget = true;

		//	Move the Update Animations actions to the start of the Viz Tree so they take effect in time for the custom death animation to get assigned to the target.
		VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_UpdateAnimations', FindActions);
		foreach FindActions(FindAction)
		{
			VisMgr.DisconnectAction(FindAction);
			VisMgr.ConnectAction(FindAction, VisMgr.BuildVisTree, false, VisMgr.BuildVisTree);

			foreach FindAction.ChildActions(CycleAction)
			{
				VisMgr.DisconnectAction(CycleAction);
				VisMgr.ConnectAction(CycleAction, VisMgr.BuildVisTree, false, FireAction);
			}
		}	
		
		SourceUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));

		ActionMetadata = EmptyTrack;
		ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[0].ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[0].ObjectID);
		ActionMetadata.VisualizeActor = History.GetVisualizer(AbilityContext.InputContext.MultiTargets[0].ObjectID);
		
		MoveTurnAction = X2Action_MoveTurn(class'X2Action_MoveTurn'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, true, FireAction.ParentActions[0]));
		MoveTurnAction.m_vFacePoint =  `XWORLD.GetPositionFromTileCoordinates(SourceUnit.TileLocation);
		MoveTurnAction.UpdateAimTarget = true;

		//	Make the target play its idle animation to prevent it from turning back to their original facing direction right away.
		PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, MoveTurnAction));
		PlayAnimation.Params.AnimName = 'HL_Idle';
		PlayAnimation.Params.BlendTime = 0.3f;			

		//	Make all Damage Terrain actions a child of the Unit Take Damage action, so that they don't begin until after the damage unit action is done.
		//	Prevents the viz bug associated with Damage Terrain actions making nearby units flinch, breaking the custom death animation.
		//DamageUnitAction = VisMgr.GetNodeOfType(VisMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToUnit',, AbilityContext.InputContext.MultiTargets[0].ObjectID);
		//VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_ApplyWeaponDamageToTerrain', FindActions);
		//foreach FindActions(FindAction)
		//{
			//DamageTerrainAction = X2Action_MarkerNamed(class'X2Action'.static.CreateVisualizationActionClass(class'X2Action_MarkerNamed', FindAction.StateChangeContext));
			//DamageTerrainAction.SetName("ReplaceStub");
			//VisMgr.ReplaceNode(DamageTerrainAction, FindAction);

			//DamageTerrainAction = X2Action_ApplyWeaponDamageToTerrain(FindAction);
			//`LOG("Damage radius:" @ DamageTerrainAction.DamageEvent.DamageRadius,, 'WOTCMoreSparkWeapons');
			//DamageTerrainAction.DamageEvent.DamageRadius = 17.0f;
			//DamageTerrainAction.DamageInfluenceRadiusMultiplier = -1;
			//VisMgr.DisconnectAction(FindAction);
			//VisMgr.ConnectAction(FindAction, VisMgr.BuildVisTree, false, DamageUnitAction);
		//}	
	}
}

static function X2AbilityTemplate Create_KineticStrike_Passive()
{
	local X2AbilityTemplate			Template;
	local X2Effect_MeleeDamageBonus	DamageEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_KineticStrike_Passive');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_momentum";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	DamageEffect = new class'X2Effect_MeleeDamageBonus';
	DamageEffect.BonusDamage = class'X2Item_KSM'.default.MELEE_DAMAGE_BONUS;
	DamageEffect.ValidAbilities = class'X2DownloadableContentInfo_WOTCMoreSparkWeapons'.default.MeleeAbilitiesUseKSM;
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(DamageEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//	==============================================================
//			RESTORATIVE MIST
//	==============================================================

static function X2AbilityTemplate Create_RestorativeMist_Heal()
{
	local X2AbilityTemplate						Template;
	local X2AbilityCost_Ammo					AmmoCost;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2Effect_ApplyMedikitHeal				MedikitHeal;
	local X2Effect_RemoveEffectsByDamageType	RemoveEffects;
	local X2Condition_UnitProperty				UnitPropertyCondition;
	//local array<name>							SkipExclusions;
	local X2AbilityMultiTarget_Radius			MultiTargetStyle;
	local name									HealType;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_RestorativeMist_Heal');

	//	Icon Setup
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_medkit";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.MEDIKIT_HEAL_PRIORITY;
	Template.bDisplayInUITooltip = true;
	Template.bLimitTargetIcons = true;

	//	Targeting and Triggering
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	MultiTargetStyle = new class'X2AbilityMultiTarget_Radius';
	MultiTargetStyle.bUseWeaponRadius = true;
	MultiTargetStyle.bIgnoreBlockingCover = false;
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

	//	Ability Costs
	Template.bUseAmmoAsChargesForHUD = true;
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	AmmoCost.bReturnChargesError = true;
	Template.AbilityCosts.AddItem(AmmoCost);

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
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeFullHealth = true;
	UnitPropertyCondition.ExcludeRobotic = true;
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	MedikitHeal = new class'X2Effect_ApplyMedikitHeal';
	MedikitHeal.PerUseHP = 4;
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
	//Template.CustomSelfFireAnim = 'NO_RestorativeMist';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

	return Template;
}

static function X2DataTemplate Create_RestorativeMist_HealBit()
{
	local X2AbilityTemplate             Template;
	local X2AbilityCost_ActionPoints    ActionPointCost;
	local X2Condition_UnitProperty      UnitPropertyCondition;
	local X2AbilityTarget_Cursor        CursorTarget;
	local X2Effect_ApplyMedikitHeal		MedikitHeal;
	local X2Effect_RemoveEffectsByDamageType	RemoveEffects;
	local X2AbilityMultiTarget_Radius   RadiusMultiTarget;
	local name							HealType;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_RestorativeMist_HealBit');

	//	Icon Setup
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.MEDIKIT_HEAL_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_capacitordischarge";
	Template.bDisplayInUITooltip = false;

	//	Triggering and Targeting
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = class'X2Item_RestorativeMist'.default.HEAL_RANGE;
	CursorTarget.bRestrictToWeaponRange = false;
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.bUseWeaponRadius = false;
	RadiusMultiTarget.fTargetRadius = class'X2Item_RestorativeMist'.default.HEAL_RADIUS;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_GremlinAOE';

	//	Costs
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	AddCharges(Template, class'X2Item_RestorativeMist'.default.ICLIPSIZE);

	//	Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	//	Multi Target Conditions
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeFullHealth = true;
	UnitPropertyCondition.ExcludeRobotic = true;
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	//	Ability Effects
	MedikitHeal = new class'X2Effect_ApplyMedikitHeal';
	MedikitHeal.PerUseHP = 4;
	Template.AddMultiTargetEffect(MedikitHeal);

	RemoveEffects = new class'X2Effect_RemoveEffectsByDamageType';
	foreach class'X2Ability_DefaultAbilitySet'.default.MedikitHealEffectTypes(HealType)
	{
		RemoveEffects.DamageTypesToRemove.AddItem(HealType);
	}
	Template.AddMultiTargetEffect(RemoveEffects);

	//	 Game State and Viz
	//Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;
	Template.CustomFireAnim = 'HL_SendGremlin';
	Template.CustomSelfFireAnim = 'FF_FireShredStormCannon';
	Template.Hostility = eHostility_Defensive;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.ActivationSpeech = 'HealingAlly';
	Template.PostActivationEvents.AddItem('ItemRecalled');
	Template.bStationaryWeapon = true;
	//Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.SendGremlinToLocation_BuildGameState;
	Template.BuildNewGameStateFn = SendBITToLocation_BuildGameState;
	//Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.CapacitorDischarge_BuildVisualization;
	Template.BuildVisualizationFn = RestorativeMist_BIT_BuildVisualization;

	//Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;	

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

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

	`LOG("SendBITToLocation_BuildGameState: begin. Source Item:" @ AbilityContext.InputContext.ItemObject.ObjectID,, 'WOTCMoreSparkWeapons');

	GremlinItemState = XComGameState_Item(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.ItemObject.ObjectID));
	if (GremlinItemState == none)
	{
		GremlinItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', AbilityContext.InputContext.ItemObject.ObjectID));
	}
	`LOG("SendBITToLocation_BuildGameState: begin. GremlinItemState:" @ GremlinItemState.GetMyTemplateName() @ GremlinItemState.CosmeticUnitRef.ObjectID,, 'WOTCMoreSparkWeapons');

	GremlinUnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(GremlinItemState.CosmeticUnitRef.ObjectID));
	if (GremlinUnitState == none)
	{
		GremlinUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', GremlinItemState.CosmeticUnitRef.ObjectID));
	}

	GremlinItemState.AttachedUnitRef.ObjectID = 0;
	TargetPos = AbilityContext.InputContext.TargetLocations[0];
	GremlinUnitState.SetVisibilityLocationFromVector(TargetPos);

	`LOG("SendBITToLocation_BuildGameState: end",, 'WOTCMoreSparkWeapons');

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

	`LOG("RestorativeMist_BIT_BuildVisualization: begin",, 'WOTCMoreSparkWeapons');

	History = `XCOMHISTORY;
	WorldData = `XWORLD;

	Context = XComGameStateContext_Ability( VisualizeGameState.GetContext( ) );
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager( ).FindAbilityTemplate( Context.InputContext.AbilityTemplateName );

	//****************************************************************************************
	//Configure the visualization track for the owner of the Gremlin
	`LOG("RestorativeMist_BIT_BuildVisualization: begin shooter",, 'WOTCMoreSparkWeapons');
	SparkUnitState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID));

	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(SparkUnitState.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = SparkUnitState;
	ActionMetadata.VisualizeActor = History.GetVisualizer(SparkUnitState.ObjectID);

	`LOG("RestorativeMist_BIT_BuildVisualization: play animation",, 'WOTCMoreSparkWeapons');

	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree( ActionMetadata, Context ));
	PlayAnimation.Params.AnimName = 'HL_SendGremlinA';

	if (AbilityTemplate.ActivationSpeech != '')
	{
		`LOG("RestorativeMist_BIT_BuildVisualization: speech and flyover",, 'WOTCMoreSparkWeapons');

		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.ActivationSpeech, eColor_Good);
	}

	//****************************************************************************************
	//Configure the visualization track for the Gremlin
	BITObjectID = Context.InputContext.ItemObject.ObjectID;

	`LOG("RestorativeMist_BIT_BuildVisualization: Gremling:" @ BITObjectID,, 'WOTCMoreSparkWeapons');

	GremlinItem = XComGameState_Item( History.GetGameStateForObjectID( BITObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1 ) );
	GremlinUnitState = XComGameState_Unit( History.GetGameStateForObjectID( GremlinItem.CosmeticUnitRef.ObjectID ) );
	AttachedUnitState = XComGameState_Unit( History.GetGameStateForObjectID( GremlinItem.AttachedUnitRef.ObjectID ) );

	InteractingUnitRef = GremlinItem.CosmeticUnitRef;

	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID( InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1 );
	ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
	ActionMetadata.VisualizeActor = History.GetVisualizer( InteractingUnitRef.ObjectID );

	`LOG("RestorativeMist_BIT_BuildVisualization: shooter effects",, 'WOTCMoreSparkWeapons');

	//If there are effects added to the shooter, add the visualizer actions for them
	for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
	{
		AbilityTemplate.AbilityShooterEffects[ EffectIndex ].AddX2ActionsForVisualization( VisualizeGameState, ActionMetadata, Context.FindShooterEffectApplyResult( AbilityTemplate.AbilityShooterEffects[ EffectIndex ] ) );
	}

	if (Context.InputContext.TargetLocations.Length > 0)
	{
		`LOG("RestorativeMist_BIT_BuildVisualization: target position",, 'WOTCMoreSparkWeapons');

		TargetPosition = Context.InputContext.TargetLocations[0];
		TargetTile = `XWORLD.GetTileCoordinatesFromPosition( TargetPosition );

		if (WorldData.IsTileFullyOccupied( TargetTile ))
		{
			TargetTile.Z++;
		}

		if (!WorldData.IsTileFullyOccupied( TargetTile ))
		{
			`LOG("RestorativeMist_BIT_BuildVisualization: pathing",, 'WOTCMoreSparkWeapons');

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
			`LOG("Gremlin was unable to find a location to move to for ability "@Context.InputContext.AbilityTemplateName,, 'WOTCMoreSparkWeapons');
			`redscreen("Gremlin was unable to find a location to move to for ability "@Context.InputContext.AbilityTemplateName);
		}
	}
	else
	{
		`LOG("Gremlin was not provided a location to move to for ability " @Context.InputContext.AbilityTemplateName,, 'WOTCMoreSparkWeapons');
		`redscreen("Gremlin was not provided a location to move to for ability "@Context.InputContext.AbilityTemplateName);
	}

	`LOG("Perk start action",, 'WOTCMoreSparkWeapons');
	PerkStartAction = X2Action_AbilityPerkStart(class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	PerkStartAction.NotifyTargetTracks = true;

	`LOG("play animation",, 'WOTCMoreSparkWeapons');
	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree( ActionMetadata, Context ));
	PlayAnimation.Params.AnimName = AbilityTemplate.CustomSelfFireAnim;

	// build in a delay before we hit the end (which stops activation effects)
	`LOG("Delay action",, 'WOTCMoreSparkWeapons');
	DelayAction = X2Action_WaitForAbilityEffect( class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree( ActionMetadata, Context ) );
	DelayAction.ChangeTimeoutLength( class'X2Ability_SpecialistAbilitySet'.default.GREMLIN_PERK_EFFECT_WINDOW );

	`LOG("Perk end",, 'WOTCMoreSparkWeapons');

	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree( ActionMetadata, Context );

	//****************************************************************************************
	//Configure the visualization track for the targets
	//****************************************************************************************
	`LOG("Targets",, 'WOTCMoreSparkWeapons');
	for (i = 0; i < Context.InputContext.MultiTargets.Length; ++i)
	{
		`LOG("Target:" @ i,, 'WOTCMoreSparkWeapons');

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

	`LOG("RestorativeMist_BIT_BuildVisualization: end",, 'WOTCMoreSparkWeapons');
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