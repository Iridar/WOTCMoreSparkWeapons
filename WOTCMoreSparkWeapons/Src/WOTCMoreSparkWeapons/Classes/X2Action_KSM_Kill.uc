class X2Action_KSM_Kill extends X2Action_Fire;

function Init()
{
	local XComGameState_Unit PrimaryTargetState;

	super.Init();

	PrimaryTargetState = XComGameState_Unit(History.GetGameStateForObjectID(PrimaryTargetID));

	if (PrimaryTargetState.IsDead())
	{
		Get_KSMKill_AnimName(AnimParams.AnimName);
	}
}

private function Get_KSMKill_AnimName(out name AnimName)
{
	local XComGameState_Unit	TargetUnitState;
	local name					KillSequence, DeathSequence;

	if (AbilityContext.InputContext.MultiTargets.Length > 0 && AbilityContext.IsResultContextMultiHit(0))
	{
		TargetUnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[0].ObjectID));

		//	Removed because it's apparently unnecessary?
		//if (class'X2Condition_UnblockedTile'.static.IsUnitOnAnUnblockedTile(SourceUnitState, TargetUnitState, "FireAction"))
		//{
			if (class'KSMHelper'.static.GetKillDeathAnimationNamesForCharacterTemplate(TargetUnitState.GetMyTemplateName(), KillSequence, DeathSequence))
			{
				if	(UnitPawn.GetAnimTreeController().CanPlayAnimation(KillSequence) && 
					TargetUnit.GetPawn().GetAnimTreeController().CanPlayAnimation(DeathSequence))
				{
					AnimName = KillSequence;
					return;
				}
			}
		//}
	}
	AnimName = 'FF_KineticStrikeA';
}
