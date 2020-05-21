class X2Ability_KSM extends X2Ability;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_KineticStrike());
	Templates.AddItem(Create_KineticStrike_Animation());

	return Templates;
}

static function X2AbilityTemplate Create_KineticStrike()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Cylinder		MultiTarget;
	local X2Effect_AdditionalAnimSets		AnimSetEffect;
	local X2Effect_KSM_DeathAnim			DeathAnimSetEffect;
	//local X2Effect_Knockback				KnockbackEffect;
	
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
	//Template.AbilityMultiTargetConditions.AddItem(default.LivingHostileTargetProperty);

	//	Ability Costs
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	//	Multi Target effects

	AnimSetEffect = new class'X2Effect_AdditionalAnimSets';
	AnimSetEffect.AddAnimSetWithPath("IRIKineticStrikeModule.Anims.AS_Trooper_Kill");
	AnimSetEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddShooterEffect(AnimSetEffect);

	DeathAnimSetEffect = new class'X2Effect_KSM_DeathAnim';
	DeathAnimSetEffect.AddAnimSetWithPath("IRIKineticStrikeModule.Anims.AS_Trooper_Death");
	DeathAnimSetEffect.BuildPersistentEffect(1, true, false, false);
	DeathAnimSetEffect.bRemoveWhenTargetDies = false;
	Template.AddMultiTargetEffect(DeathAnimSetEffect);

	// new class'X2Effect_DLC_3StrikeDamage';
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddMultiTargetEffect(WeaponDamageEffect);
	
	//KnockbackEffect = new class'X2Effect_Knockback';
	//KnockbackEffect.KnockbackDistance = 2;
	//Template.AddMultiTargetEffect(KnockbackEffect);
	//Template.bOverrideMeleeDeath = true;

	Template.CustomFireAnim = 'FF_Melee';
	Template.SourceMissSpeech = 'SwordMiss';
	//Template.ActivationSpeech = 'RocketLauncher';
	Template.CinescriptCameraType = "Spark_Strike";

	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";
	Template.MeleePuckMeshPath = "Materials_DLC3.MovePuck_Strike";
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	//	This ability is offensive and can be interrupted!
	Template.Hostility = eHostility_Offensive;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MeleeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	//Template.AdditionalAbilities.AddItem('IRI_KineticStrike_Animation');

	return Template;	
}

static function KineticStrike_BuildVisualization(XComGameState VisualizeGameState)
{	
	local VisualizationActionMetadata	ActionMetadata, EmptyMetadata;
	local XComGameStateContext_Ability	AbilityContext;
	local XComGameStateHistory			History;
	local int i;

	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	
	for (i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++)
	{
		if (AbilityContext.IsResultContextMultiHit(i))
		{
			ActionMetadata = EmptyMetadata;
			ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[i].ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
			ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[i].ObjectID, eReturnType_Reference);
			ActionMetadata.VisualizeActor = History.GetVisualizer(AbilityContext.InputContext.MultiTargets[i].ObjectID);

			class'X2Action_UpdateAnimations'.static.AddToVisualizationTree(ActionMetadata, AbilityContext);
		}
	}

	class'X2Ability'.static.TypicalAbility_BuildVisualization(VisualizeGameState);
}

static function X2AbilityTemplate Create_KineticStrike_Animation()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger_EventListener    Trigger;
	local X2Effect_AdditionalAnimSets		AnimSetEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_KineticStrike_Animation');

	//	Icon setup
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_mecclosecombat";

	//	Targeting and Triggering
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Trigger = new class'X2AbilityTrigger_EventListener';
    Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
    Trigger.ListenerData.EventID = 'AbilityActivated';
    Trigger.ListenerData.Filter = eFilter_Unit;
    Trigger.ListenerData.EventFn = KineticStrikeActivatedListener;
    Template.AbilityTriggers.AddItem(Trigger);

	//	Effects
	AnimSetEffect = new class'X2Effect_AdditionalAnimSets';
	AnimSetEffect.AddAnimSetWithPath("IRIKineticStrikeModule.Anims.AS_Trooper_Death");
	AnimSetEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(AnimSetEffect);

	AnimSetEffect = new class'X2Effect_AdditionalAnimSets';
	AnimSetEffect.AddAnimSetWithPath("IRIKineticStrikeModule.Anims.AS_Trooper_Kill");
	AnimSetEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddShooterEffect(AnimSetEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	//	No visualization on purpose
	Template.BuildVisualizationFn = none;
	//	Cannot be interrupted
	Template.Hostility = eHostility_Neutral;
	Template.BuildInterruptGameStateFn = none;

	return Template;	
}

static function EventListenerReturn KineticStrikeActivatedListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
    local XComGameStateContext_Ability	AbilityContext;
    local XComGameState_Ability			AbilityState, KSMA_AbilityState;
    local XComGameState_Unit			SourceUnit, TargetUnit;
	local XComGameStateHistory			History;
	local int i;

    AbilityState = XComGameState_Ability(EventData);
    SourceUnit = XComGameState_Unit(EventSource);
	KSMA_AbilityState = XComGameState_Ability(CallbackData);
    AbilityContext = XComGameStateContext_Ability(GameState.GetContext());

	`LOG("KineticStrikeActivatedListener running",, 'WOTCMoreSparkWeapons');

    if (AbilityState == none || SourceUnit == none || AbilityContext == none)
    {
        //    Something went terribly wrong, exit listener.
        return ELR_NoInterrupt;
    }
	//    Do stuff during interrupt phase
	if (AbilityContext.InputContext.AbilityTemplateName == 'IRI_KineticStrike' && AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt)
    {
		`LOG("KineticStrikeActivatedListener kinetic strike detected",, 'WOTCMoreSparkWeapons');
		History = `XCOMHISTORY;
		for (i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++)
		{
			if (AbilityContext.IsResultContextMultiHit(i))
			{
				TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[i].ObjectID));
				if (TargetUnit != none && TargetUnit.IsEnemyUnit(SourceUnit))
				{
					`LOG("KineticStrikeActivatedListener triggering for target:" @ TargetUnit.GetFullName(),, 'WOTCMoreSparkWeapons');
					 KSMA_AbilityState.AbilityTriggerAgainstSingleTarget(AbilityContext.InputContext.MultiTargets[i], false);
					 return ELR_NoInterrupt;
				}
			}
		}
    }
    return ELR_NoInterrupt;
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