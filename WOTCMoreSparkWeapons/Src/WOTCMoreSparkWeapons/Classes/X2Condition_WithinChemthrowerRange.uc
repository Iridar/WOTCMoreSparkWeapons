class X2Condition_WithinChemthrowerRange extends X2Condition;

//	Copied from Mitzruti's Immolators + Chemthrowers mod.

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) 
{
	local XComGameState_Unit	Target, Source;
	local int					Range;

	Target = XComGameState_Unit(kTarget);
	Source = XComGameState_Unit(kSource);

	if ( Target != none && Source != none )
	{

		Range = class'X2Ability_Incinerator'.default.CONE_TILE_LENGTH;
		if ( Source.HasSoldierAbility('MZLengthNozzleBsc') ) { Range += 1; }
		if ( Source.HasSoldierAbility('MZLengthNozzleAdv') ) { Range += 2; }
		if ( Source.HasSoldierAbility('MZLengthNozzleSup') ) { Range += 3; }
		
		if ( Source.TileDistanceBetween(Target) <= Range )
		{
			return 'AA_Success';
		}

		return 'AA_NotInRange';
	}

	return 'AA_NotAUnit';
}