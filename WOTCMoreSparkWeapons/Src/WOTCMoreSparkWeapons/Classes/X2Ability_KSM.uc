class X2Ability_KSM extends X2Ability;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_KineticStrike('IRI_KineticStrike'));
	Templates.AddItem(Create_KineticStrike('IRI_KineticStrike_Soldier', false));
	Templates.AddItem(Create_KineticStrike_Passive());

	return Templates;
}

//	==============================================================
//			KINETIC STRIKE MODULE
//	==============================================================

static function X2AbilityTemplate Create_KineticStrike(name TemplateName, optional bool bForSpark = true)
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Cylinder		MultiTarget;
	local X2Effect_ApplyKSMWorldDamage		KSMWorldDamage;
	local X2Effect_OverrideDeathAction		OverrideDeathAction;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	//	Icon setup
	if (bForSpark)
	{
		Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;	//	Same as Strike

		Template.ActionFireClass = class'X2Action_KSM_Kill';

		OverrideDeathAction = new class'X2Effect_OverrideDeathAction';
		OverrideDeathAction.DeathActionClass = class'X2Action_KSM_Death';
		OverrideDeathAction.EffectName = 'IRI_KineticStrike_DeathActionEffect';
		Template.AddMultiTargetEffect(OverrideDeathAction);

		Template.CinescriptCameraType = "Spark_Strike";

		ActionPointCost = new class'X2AbilityCost_ActionPoints';
		ActionPointCost.iNumPoints = 1;
		ActionPointCost.bConsumeAllPoints = true;
		Template.AbilityCosts.AddItem(ActionPointCost);
	}
	else
	{
		Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.ARMOR_ACTIVE_PRIORITY; //	Same as Heavy Weapons

		Template.CinescriptCameraType = "Soldier_HeavyWeapons";		

		Template.AbilityCosts.AddItem(new class'X2AbilityCost_HeavyWeaponActionPoints');
		//Template.CinescriptCameraType = "Iridar_HeavyStrikeModule";		
	}
	
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///IRI_SparkArsenal_UI.UI_KineticStrike";

	//	Targeting and Triggering
	Template.AbilityToHitCalc = new class'X2AbilityToHitCalc_StandardMelee';
	Template.DisplayTargetHitChance = true;
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = 2;	//	Able to target diagonally
	Template.AbilityTargetStyle = CursorTarget;
	
	MultiTarget = new class'X2AbilityMultiTarget_Cylinder';
	MultiTarget.bIgnoreBlockingCover = true;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTarget.fTargetHeight = 1.5f;
	MultiTarget.fTargetRadius = 0.75f;
	Template.AbilityMultiTargetStyle = MultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_KSM';
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	//	Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
	
	//	Multi Target Conditions
	Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetOnlyProperty);
	
	//	Multi Target effects
	WeaponDamageEffect = new class'X2Effect_DLC_3StrikeDamage';
	Template.AddMultiTargetEffect(WeaponDamageEffect);

	KSMWorldDamage = new class'X2Effect_ApplyKSMWorldDamage';
	KSMWorldDamage.DamageAmount = class'X2Item_KSM'.default.KINETIC_STRIKE_ENVIRONMENTAL_DAMAGE;
	KSMWorldDamage.bApplyOnHit = true;
	KSMWorldDamage.bApplyOnMiss = true;
	Template.AddMultiTargetEffect(KSMWorldDamage);

	Template.bOverrideMeleeDeath = true;
	Template.SourceMissSpeech = 'SwordMiss';

	//	Apparently necessary to force the animation to play correctly against friendly units/exploding purifiers?..
	SetFireAnim(Template, 'FF_KineticStrike');

	//	This makes the attack animation glitch out at all times.
	//Template.bSkipExitCoverWhenFiring = true;
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";
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
	//local int i;

	class'X2Ability'.static.TypicalAbility_BuildVisualization(VisualizeGameState);
	
	History = `XCOMHISTORY;
	VisMgr = `XCOMVISUALIZATIONMGR;
	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	//for (i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++)
	//{
	//	`LOG("Target unit:" @ XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[i].ObjectID)).GetFullName(),, 'WOTCMoreSparkWeapons');
	//}

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
		
		MoveTurnAction = X2Action_MoveTurn(class'X2Action_MoveTurn'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, FireAction.ParentActions[0]));
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
			////`LOG("Damage radius:" @ DamageTerrainAction.DamageEvent.DamageRadius,, 'WOTCMoreSparkWeapons');
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

	Template.IconImage = "img:///IRI_SparkArsenal_UI.UI_KSM_MeleeBoost";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	DamageEffect = new class'X2Effect_MeleeDamageBonus';
	DamageEffect.BonusDamageFlat = class'X2Item_KSM'.default.MELEE_DAMAGE_BONUS_FLAT;
	DamageEffect.BonusDamageMultiplier = class'X2Item_KSM'.default.MELEE_DAMAGE_BONUS_MULTIPLIER;
	DamageEffect.ValidAbilities = class'X2DownloadableContentInfo_WOTCMoreSparkWeapons'.default.MeleeAbilitiesUseKSM;
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(DamageEffect);

	//	This will add configured Anim Sets with special Kill animations.
	//	Only necessary for third party animations.
	class'KSMHelper'.static.AddDeathAnimSetsToAbilityTemplate(Template);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
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

	//`LOG("Action layer: " @ iLayer @ ": " @ Action.Class.Name @ Action.StateChangeContext.AssociatedState.HistoryIndex,, 'IRIPISTOLVIZ'); 
	foreach Action.ChildActions(ChildAction)
	{
		PrintActionRecursive(ChildAction, iLayer + 1);
	}
}