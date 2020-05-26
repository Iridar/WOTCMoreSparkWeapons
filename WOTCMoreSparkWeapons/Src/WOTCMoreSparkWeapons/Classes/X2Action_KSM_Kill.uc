class X2Action_KSM_Kill extends X2Action_Fire;

function Init()
{
	super.Init();

	AnimParams.AnimName = Get_KSMKill_AnimName();
}

function name Get_KSMKill_AnimName()
{
	local XComGameState_Unit	TargetUnitState;

	if (AbilityContext.InputContext.MultiTargets.Length > 0 && AbilityContext.IsResultContextMultiHit(0))
	{
		TargetUnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[0].ObjectID));

		if (class'X2Condition_UnblockedTile'.static.IsUnitOnAnUnblockedTile(SourceUnitState, TargetUnitState, "FireAction"))
		{
			if (InStr(TargetUnitState.GetMyTemplateName(), "ShieldBearer") >= 0)
			{
				if	(UnitPawn.GetAnimTreeController().CanPlayAnimation('FF_KSMKill_ShieldbearerA') && 
					 TargetUnit.GetPawn().GetAnimTreeController().CanPlayAnimation('FF_KSMDeath_ShieldbearerA'))
				{
					return 'FF_KSMKill_ShieldbearerA';
				}
			}
		}
	}
	return AnimParams.AnimName;
}
