class X2Effect_Entrench extends X2Effect_Persistent;

// Tracking effect for Entrench Protocol. Applied by Aid Protocol, removed if the unit moves.

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	
	EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', AbilityActivated_Listener, ELD_Immediate,, UnitState,, UnitState);	
	
	super.RegisterForEvents(EffectGameState);
}

static function EventListenerReturn AbilityActivated_Listener(Object EventData, Object EventSource, XComGameState NewGameState, name InEventID, Object CallbackData)
{
    local XComGameState_Unit            UnitState;
    local XComGameState_Effect			EffectState;
	local XComGameStateContext_Ability	AbilityContext;
		
	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
	if (AbilityContext == none || AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt)
	    return ELR_NoInterrupt;

	if (AbilityContext.InputContext.MovementPaths.Length > 0)
	{
		UnitState = XComGameState_Unit(EventSource);
		if (UnitState == none)
			return ELR_NoInterrupt;

		EffectState = UnitState.GetUnitAffectedByEffectState(default.EffectName);
		if (EffectState != none)
		{
			EffectState.RemoveEffect(NewGameState, NewGameState, true);
		}
	}
	return ELR_NoInterrupt;
}

defaultproperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "IRI_SparkArsenal_Entrench_Effect"
}