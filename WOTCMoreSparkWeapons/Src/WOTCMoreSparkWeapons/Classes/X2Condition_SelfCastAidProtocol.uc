class X2Condition_SelfCastAidProtocol extends X2Condition;

//	Maybe this can be done with one of the milion undocumented UnitEffects conditions, but I tried most (all?) of them, and they don't seem to be doing what I need,
//	which is having a condition that passes only if the unit is affected by their own AidProtocol.

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit	UnitState;
	local XComGameState_Effect	AidProtocol;
	
	UnitState = XComGameState_Unit(kTarget);
	
	if (UnitState != none)
	{
		AidProtocol = UnitState.GetUnitAffectedByEffectState('AidProtocol');
		if (AidProtocol != none && AidProtocol.ApplyEffectParameters.SourceStateObjectRef.ObjectID == UnitState.ObjectID)
		{
			return 'AA_Success';
		}
	}
	else return 'AA_NotAUnit';
	
	return 'AA_MissingRequiredEffect';
}