class X2TargetingMethod_KSM extends X2TargetingMethod_VoidRift;

var protected X2Actor_ConeTarget ConeActor;
var protected vector FiringLocation;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	super.Init(InAction, NewTargetIndex);

	FiringLocation = `XWORLD.GetPositionFromTileCoordinates(UnitState.TileLocation);

	// setup the targeting mesh
	ConeActor = `BATTLE.Spawn(class'X2Actor_ConeTarget');
	ConeActor.MeshLocation = "UI_Range.Meshes.KinetiStrikeDir_Plane";
	ConeActor.InitConeMesh(1, 1);
	ConeActor.SetLocation(FiringLocation);
}

function Update(float DeltaTime)
{
	local array<Actor> CurrentlyMarkedTargets;
	local vector NewTargetLocation;
	local array<TTile> Tiles;
	local Vector ShooterToTarget;
	local Rotator ConeRotator;

	//local XComWorldData WorldData;
	//local array<StateObjectReference> UnitsOnTile;
	//local XComPresentationLayer Pres;
	//local UITacticalHUD TacticalHud;

	//NewTargetLocation = GetSplashRadiusCenter();
	NewTargetLocation = Cursor.GetCursorFeetLocation();

	if (NewTargetLocation != CachedTargetLocation)
	{		
		GetTargetedActors(NewTargetLocation, CurrentlyMarkedTargets, Tiles);
		CheckForFriendlyUnit(CurrentlyMarkedTargets);	
		MarkTargetedActors(CurrentlyMarkedTargets, FiringUnit.GetTeam());
		//DrawAOETiles(Tiles);
	}
	
	super(X2TargetingMethod).Update(DeltaTime);

	if (ConeActor != none)
	{
		ShooterToTarget = NewTargetLocation - FiringLocation;
		ConeRotator = rotator(ShooterToTarget);

		//	Make the targeting mesh parallel to the ground
		ConeRotator.Pitch = 0;
		ConeActor.SetRotation(ConeRotator);
	}
	/*
	WorldData = `XWORLD;
	UnitsOnTile = WorldData.GetUnitsOnTile(Tiles[0]);
	if (UnitsOnTile.Length > 0)
	{
		Pres = `PRES;
		TacticalHud = Pres.GetTacticalHUD();
		TacticalHud.TargetEnemy(UnitsOnTile[0].ObjectID);
		TacticalHud.ToggleEnemyInfo();
	}*/
}
/*
function int GetTargetedObjectID()
{
	local XComWorldData WorldData;
	local array<StateObjectReference> UnitsOnTile;
	local TTile Tile;
	local vector NewTargetLocation;

	WorldData = `XWORLD;
	NewTargetLocation = Cursor.GetCursorFeetLocation();
	Tile = WorldData.GetTileCoordinatesFromPosition(NewTargetLocation);
	UnitsOnTile = WorldData.GetUnitsOnTile(Tile);

	if (UnitsOnTile.Length > 0)
	{
		return UnitsOnTile[0].ObjectID;
	}
	return 0;
}

function int GetTargetIndex()
{
	return 0;
}
*/
function Canceled()
{
	super.Canceled();
	// clean up the ui
	ConeActor.Destroy();
}

function bool GetAbilityIsOffensive()
{
	return true;
}

defaultproperties
{
	ProjectileTimingStyle=""
	OrdnanceTypeName=""
}