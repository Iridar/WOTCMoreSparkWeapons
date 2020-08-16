class X2Effect_ShrapnelShell extends X2Effect_Persistent config(ArtilleryCannon);

var config float HighCoverDamageModifier;
var config float LowCoverDamageModifier;

var config int FlechetteArmorPierceVersusOrganic;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) 
{ 
	local GameRulesCache_VisibilityInfo VisInfo;
	local XComGameState_Unit			TargetUnit;

	switch (AbilityState.GetMyTemplateName())
	{
		case 'IRI_FireArtilleryCannon_Flechette':
		case 'IRI_FireArtilleryCannon_Shrapnel':
			break;
		default:
			return 0;
	}

	TargetUnit = XComGameState_Unit(TargetDamageable);

	if (TargetUnit != none && TargetUnit.CanTakeCover() && `TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, TargetUnit.ObjectID, VisInfo))
	{	
		//`LOG("Attacker:" @ Attacker.GetFullName() @ "Target:" @ Target.GetFullName() @ "Cover:" @ VisInfo.TargetCover,, 'WOTCMoreSparkWeapons');
		switch (VisInfo.TargetCover)
		{
			case CT_Standing:
				return CurrentDamage * HighCoverDamageModifier;
			case CT_MidLevel:
				return CurrentDamage * LowCoverDamageModifier;
			default:
				break;
		}
	}
	return 0; 
}

function int GetExtraArmorPiercing(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData)
{ 
	local XComGameState_Unit TargetUnit;

	if (AbilityState.GetMyTemplateName() != 'IRI_FireArtilleryCannon_Flechette')
		return 0;

	TargetUnit = XComGameState_Unit(TargetDamageable);

	if (TargetUnit != none && !TargetUnit.IsRobotic())
	{	
		return default.FlechetteArmorPierceVersusOrganic;
	}
	return 0; 
}


defaultproperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "X2Effect_ShrapnelShell_Effect"
}