class X2Condition_UnblockedTile extends X2Condition;

var bool bReverseCondition;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Unit SourceUnit, TargetUnit;
	
	SourceUnit = XComGameState_Unit(kSource);
	TargetUnit = XComGameState_Unit(kTarget);
	
	if (SourceUnit != none && TargetUnit != none)
	{
		if (IsUnitOnAnUnblockedTile(SourceUnit, TargetUnit, "Condition", bReverseCondition)) 
		{
			return 'AA_Success'; 
		}
	}
	else return 'AA_NotAUnit';
	
	return 'AA_TileIsBlocked';
}

static function bool IsUnitOnAnUnblockedTile(const XComGameState_Unit SourceUnit, const XComGameState_Unit TargetUnit, string LogPart, optional bool bReverseConditionReturn = false)
{
	local XComWorldData			WorldData;
	local array<TilePosPair>	Tiles;
	local vector				TargetLocation;
	local int i;

	WorldData = `XWORLD;
	TargetLocation = WorldData.GetPositionFromTileCoordinates(TargetUnit.TileLocation);
	WorldData.CollectTilesInCylinder(Tiles, TargetLocation, 96.0f, 0); // grabs only directly adjacent tiles (non-diagonal)

	//`LOG(LogPart @ "## Checking if unit:" @ TargetUnit.GetFullName() @ "is on an unblocked tile. Gathered:" @ Tiles.Length @ "tiles.",, 'WOTCMoreSparkWeapons');

	for (i = 0; i < Tiles.Length; i++)
	{
		if (WorldData.IsFloorTile(Tiles[i].Tile) && Tiles[i].Tile != TargetUnit.TileLocation && Tiles[i].Tile != SourceUnit.TileLocation && !WorldData.IsTileOutOfRange(Tiles[i].Tile))
		{	
			//`LOG(LogPart @ "## Checking floor tile:" @ i @ ":" @ Tiles[i].Tile.X @ Tiles[i].Tile.Y @ Tiles[i].Tile.Z @ ". Tile is blocked:" @ !WorldData.CanUnitsEnterTile(Tiles[i].Tile),, 'WOTCMoreSparkWeapons');
			if (!WorldData.CanUnitsEnterTile(Tiles[i].Tile)) return bReverseConditionReturn;
		}			
	}
	return !bReverseConditionReturn;
}