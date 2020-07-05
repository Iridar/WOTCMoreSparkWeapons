class X2Effect_IRI_TriggerEvent extends X2Effect_TriggerEvent;

var array<name> AllowedAbilities;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	if (AllowedAbilities.Find(ApplyEffectParameters.AbilityInputContext.AbilityTemplateName) != INDEX_NONE)
	{
		super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	}
}