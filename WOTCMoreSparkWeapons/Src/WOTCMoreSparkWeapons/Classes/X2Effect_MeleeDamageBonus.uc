class X2Effect_MeleeDamageBonus extends X2Effect_Persistent;

var int BonusDamageFlat;
var float BonusDamageMultiplier;
var array<name> ValidAbilities;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) 
{ 
	if (ValidAbilities.Find(AppliedData.AbilityInputContext.AbilityTemplateName) != INDEX_NONE)
	{
		return CurrentDamage * BonusDamageMultiplier + BonusDamageFlat;
	}
	return 0; 
}