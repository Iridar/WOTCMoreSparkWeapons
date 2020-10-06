class X2Effect_ExtendAidProtocol extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit	UnitState;
	local XComGameState_Effect	AidProtocolEffectState;
	local XComGameState_Ability	AidProtocolAbilityState;

	UnitState = XComGameState_Unit(kNewTargetState);
	
	if (UnitState != none)
	{
		`LOG("X2Effect_ExtendAidProtocol applied to unit:" @ UnitState.GetFullName(),, 'IRITEST');
		AidProtocolEffectState = UnitState.GetUnitAffectedByEffectState('AidProtocol');
		if (AidProtocolEffectState != none)
		{
			`LOG("Increasing Aid Protocol duration from turns:" @ AidProtocolEffectState.iTurnsRemaining,, 'IRITEST');
			AidProtocolEffectState.iTurnsRemaining++;

			AidProtocolAbilityState = XComGameState_Ability(NewGameState.ModifyStateObject(class'XComGameState_Ability', AidProtocolEffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			if (AidProtocolAbilityState != none)
			{
				AidProtocolAbilityState.iCooldown++;
			}
			
		}
		else `LOG("No Aid Protocol effect state!",, 'IRITEST');
	}
}