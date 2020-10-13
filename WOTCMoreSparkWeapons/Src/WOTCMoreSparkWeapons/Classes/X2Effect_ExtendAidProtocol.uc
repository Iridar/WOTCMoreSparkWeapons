class X2Effect_ExtendAidProtocol extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit	UnitState;
	local XComGameState_Effect	AidProtocolEffectState;
	local XComGameState_Ability	AidProtocolAbilityState;

	UnitState = XComGameState_Unit(kNewTargetState);
	
	if (UnitState != none)
	{
		AidProtocolEffectState = UnitState.GetUnitAffectedByEffectState('AidProtocol');

		//	Double check for source unit state just in case, though it worked fine without it.
		if (AidProtocolEffectState != none && AidProtocolEffectState.ApplyEffectParameters.SourceStateObjectRef == ApplyEffectParameters.SourceStateObjectRef)
		{
			AidProtocolEffectState.iTurnsRemaining++;

			AidProtocolAbilityState = XComGameState_Ability(NewGameState.ModifyStateObject(class'XComGameState_Ability', AidProtocolEffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			if (AidProtocolAbilityState != none && 	AidProtocolAbilityState.GetMyTemplate().AbilityCooldown != none)
			{
				AidProtocolAbilityState.iCooldown = AidProtocolAbilityState.GetMyTemplate().AbilityCooldown.iNumTurns;
			}
			
		}
	}
}