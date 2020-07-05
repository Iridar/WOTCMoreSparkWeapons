class X2Effect_HeatShell extends X2Effect_Persistent config(ArtilleryCannon);

//	Reduce ability's crit chance at squadsight ranges
var config float SquadsightCritChancePenaltyModifier;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{	
	local ShotModifierInfo				ModInfo;
	local int							TileDistance;

	switch (AbilityState.GetMyTemplateName())
	{
		case 'IRI_FireArtilleryCannon_HEAT':
		case 'IRI_FireArtilleryCannon_HEDP':
			break;
		default:
			return;
	}

	//	Compensate Squadsight Aim and Crit penalties
	TileDistance = Attacker.TileDistanceBetween(Target);

	//  Calculate how far into Squadsight range are we.
	TileDistance -= Attacker.GetVisibilityRadius() * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;

	//	right at the boundary, but squadsight IS being used so treat it like one tile
	if (TileDistance == 0) TileDistance = 1;

	if (TileDistance > 0)
	{
		`LOG("X2Effect_HeatShell: Reducing crit by:" @ class'X2AbilityToHitCalc_StandardAim'.default.SQUADSIGHT_DISTANCE_MOD * TileDistance,, 'WOTCMoreSparkWeapons');
		ModInfo.ModType = eHit_Crit;
		ModInfo.Reason = FriendlyName;
		ModInfo.Value = class'X2AbilityToHitCalc_StandardAim'.default.SQUADSIGHT_DISTANCE_MOD * TileDistance * SquadsightCritChancePenaltyModifier;
		ShotModifiers.AddItem(ModInfo);
	}	
}


defaultproperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "X2Effect_HeatShell_Effect"
}