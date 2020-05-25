class X2Action_KSM_Death extends X2Action_Death;

//	Copied from Musashi's Jedi Class Revised mod, then adjusted.

var name AnimationToPlay;
var AnimNodeSequence AttackSequence;

function Init()
{
	super.Init();

	AttackSequence = XGUnit(DamageDealer).GetPawn().GetAnimTreeController().FullBodyDynamicNode.GetTerminalSequence();
	
	if (AttackSequence.AnimSeqName == 'FF_KSMKill_ShieldbearerA')
	{
		UnitPawn.bUseDesiredEndingAtomOnDeath = false;
		bWaitUntilNotified = true;
	
		AnimationToPlay = 'FF_KSMDeath_ShieldbearerA';
	}
}

event OnAnimNotify(AnimNotify ReceiveNotify)
{
    super.OnAnimNotify(ReceiveNotify);

    if((XComAnimNotify_NotifyTarget(ReceiveNotify) != none) && (AbilityContext != none))
    {
        bWaitUntilNotified = false;
    }
}

static function bool AllowOverrideActionDeath(VisualizationActionMetadata ActionMetadata, XComGameStateContext Context)
{
	local XComGameState_Ability AbilityState;

	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(XComGameStateContext_Ability(Context).InputContext.AbilityRef.ObjectID, eReturnType_Reference));
	if (AbilityState != none && AbilityState.GetMyTemplate().ActionFireClass == class'X2Action_KSM_Kill')
	{
		return true;
	}
	return false;
}

function bool ShouldRunDeathHandler()
{
	if (AnimationToPlay != '')
	{
		return false;
	}
	return super.ShouldRunDeathHandler();
}

function bool ShouldPlayDamageContainerDeathEffect()
{
	if (AnimationToPlay != '')
	{
		return false;
	}
	return super.ShouldPlayDamageContainerDeathEffect();
}

function bool DamageContainerDeathSound()
{
	if (AnimationToPlay != '')
	{
		return false;
	}
	return super.DamageContainerDeathSound();
}

simulated function Name ComputeAnimationToPlay()
{
	if (AnimationToPlay != '')
	{
		// Always allow new animations to play.
		UnitPawn.GetAnimTreeController().SetAllowNewAnimations(true);

		return AnimationToPlay;
	}

	return super.ComputeAnimationToPlay();
}