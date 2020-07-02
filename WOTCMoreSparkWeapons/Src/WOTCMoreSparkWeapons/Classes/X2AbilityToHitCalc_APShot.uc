class X2AbilityToHitCalc_APShot extends X2AbilityToHitCalc_StandardAim;

var float CounterSquadsightPenalty;

function int GetWeaponRangeModifier(XComGameState_Unit Shooter, XComGameState_Unit Target, XComGameState_Item Weapon)
{
	local int Tiles;

	Tiles = Shooter.TileDistanceBetween(Target);

	//  Calculate how far into Squadsight range are we.
	Tiles -= Shooter.GetVisibilityRadius() * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;

	//	Remove half of the squadsight penalty here.
	if (Tiles > 0)
	{
		return -class'X2AbilityToHitCalc_StandardAim'.default.SQUADSIGHT_DISTANCE_MOD * Tiles * CounterSquadsightPenalty;
	}
	else if (Tiles == 0)	//	right at the boundary, but squadsight IS being used so treat it like one tile
	{
		return -class'X2AbilityToHitCalc_StandardAim'.default.SQUADSIGHT_DISTANCE_MOD * CounterSquadsightPenalty;
	}
	return 0;
}

defaultproperties
{
	CounterSquadsightPenalty = 0.5f
}