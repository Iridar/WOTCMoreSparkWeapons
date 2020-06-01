class X2Effect_IRI_Rainmaker extends X2Effect_Persistent;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	switch (AbilityState.GetMyTemplateName())
	{
	case 'IRI_SparkRocketLauncher':
		return class'X2Ability_SparkAbilitySet'.default.RAINMAKER_DMG_ROCKETLAUNCHER;
	case 'IRI_SparkShredderGun':
		return class'X2Ability_SparkAbilitySet'.default.RAINMAKER_DMG_SHREDDERGUN;
	case 'IRI_SparkShredstormCannon':
		return class'X2Ability_SparkAbilitySet'.default.RAINMAKER_DMG_SHREDSTORM;
	case 'IRI_SparkFlamethrower':
		return class'X2Ability_SparkAbilitySet'.default.RAINMAKER_DMG_FLAMETHROWER;
	case 'IRI_SparkFlamethrowerMk2':
		return class'X2Ability_SparkAbilitySet'.default.RAINMAKER_DMG_FLAMETHROWER2;
	case 'IRI_SparkBlasterLauncher':
		return class'X2Ability_SparkAbilitySet'.default.RAINMAKER_DMG_BLASTERLAUNCHER;
	case 'IRI_SparkPlasmaBlaster':
		return class'X2Ability_SparkAbilitySet'.default.RAINMAKER_DMG_PLASMABLASTER;
	case 'IRI_Fire_HeavyAutogun':
	case 'IRI_Fire_HeavyAutogun_Spark':
	case 'IRI_Fire_HeavyAutogun_BIT':
		return class'X2Ability_HeavyAutogun'.default.RAINMAKER_BONUS_DAMAGE;
	default:
		break;
	}
	return 0;
}

defaultproperties
{
	bDisplayInSpecialDamageMessageUI = true
}