class X2Effect_StunCyberus extends X2Effect_Stunned;

//	Copy paste of the original stun effect, I just removed the nonsense that makes it handle Codex (Cyberus) differently

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;
	local XComGameState_Unit StunningUnitState;
	local X2EventManager EventManager;
	local bool IsOurTurn;

	EventManager = `XEVENTMGR;

	UnitState = XComGameState_Unit(kNewTargetState);
	if (UnitState != none)
	{
		
		UnitState.ReserveActionPoints.Length = 0;
		UnitState.StunnedActionPoints += StunLevel;

		if(IsTickEveryAction(UnitState) && UnitState.StunnedActionPoints > 1)
		{
			// when ticking per action, randomly subtract an action point, effectively giving rulers a 1-2 stun
			UnitState.StunnedActionPoints -= `SYNC_RAND(1);
		}
		
		if( UnitState.IsTurret() ) // Stunned Turret.   Update turret state.
		{
			UnitState.UpdateTurretState(false);
		}

		//  If it's the unit's turn, consume action points immediately
		IsOurTurn = UnitState.ControllingPlayer == `TACTICALRULES.GetCachedUnitActionPlayerRef();
		if (IsOurTurn)
		{
			// keep track of how many action points we lost, so we can regain them if the
			// stun is cleared this turn, and also reduce the stun next turn by the
			// number of points lost
			while (UnitState.StunnedActionPoints > 0 && UnitState.ActionPoints.Length > 0)
			{
				UnitState.ActionPoints.Remove(0, 1);
				UnitState.StunnedActionPoints--;
				UnitState.StunnedThisTurn++;
			}
			
			// if we still have action points left, just immediately remove the stun
			if(UnitState.ActionPoints.Length > 0)
			{
				// remove the action points and add them to the "stunned this turn" value so that
				// the remove stun effect will restore the action points correctly
				UnitState.StunnedActionPoints = 0;
				UnitState.StunnedThisTurn = 0;
				NewEffectState.RemoveEffect(NewGameState, NewGameState, true, true);
			}
		}

		// Immobilize to prevent scamper or panic from enabling this unit to move again.
		if(!IsOurTurn || UnitState.ActionPoints.Length == 0) // only if they are not immediately getting back up
		{
			UnitState.SetUnitFloatValue(class'X2Ability_DefaultAbilitySet'.default.ImmobilizedValueName, 1);
		}

		StunningUnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
		EventManager.TriggerEvent(StunnedTriggerName, StunningUnitState, UnitState, NewGameState);
	}
}