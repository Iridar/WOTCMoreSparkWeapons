class X2TargetingMethod_HeatShot extends X2TargetingMethod_Grenade;

//	======================================================================
//	X2TargetingMethod_TopDown.uc
//	======================================================================
var private X2Camera_LookAtActor LookatCamera;
var protected int LastTarget;

function Canceled()
{
	super.Canceled();
	`CAMERASTACK.RemoveCamera(LookatCamera);
	ClearTargetedActors();
}

function Committed()
{
	Canceled();
}

/*
function Update(float DeltaTime)
{
	//local array<Actor> CurrentlyMarkedTargets;
	//local vector NewTargetLocation;
	//local array<TTile> Tiles;

	//NewTargetLocation = GetSplashRadiusCenter();

	//super.Update(DeltaTime);

	GrenadePath.LastTargetLocation = TargetLocation;
}
*/
function Update(float DeltaTime)
{
}

function NextTarget()
{
	DirectSetTarget(LastTarget + 1);
}

function PrevTarget()
{
	DirectSetTarget(LastTarget - 1);
}

function int GetTargetIndex()
{
	return LastTarget;
}

function DirectSetTarget(int TargetIndex)
{
	local XComPresentationLayer Pres;
	local UITacticalHUD TacticalHud;
	local Actor TargetedActor;
	local array<TTile> Tiles;
	local TTile TargetedActorTile;
	local XGUnit TargetedPawn;
	local vector TargetedLocation;
	local XComWorldData World;
	local int NewTarget;
	local array<Actor> CurrentlyMarkedTargets;
	local X2AbilityTemplate AbilityTemplate;

	World = `XWORLD;

	// put the targeting reticle on the new target
	Pres = `PRES;
	TacticalHud = Pres.GetTacticalHUD();

	// advance the target counter
	NewTarget = TargetIndex % Action.AvailableTargets.Length;
	if(NewTarget < 0) NewTarget = Action.AvailableTargets.Length + NewTarget;

	LastTarget = NewTarget;
	TacticalHud.TargetEnemy(Action.AvailableTargets[NewTarget].PrimaryTarget.ObjectID);

	// have the idle state machine look at the new target
	if(FiringUnit != none)
	{
		FiringUnit.IdleStateMachine.CheckForStanceUpdate();
	}

	// have the camera look at the new target (or the source unit if no target is available)
	TargetedActor = GetTargetedActor();
	if(TargetedActor != none)
	{
		LookatCamera.ActorToFollow = TargetedActor;
	}
	else if(FiringUnit != none)
	{
		LookatCamera.ActorToFollow = FiringUnit;
	}

	TargetedPawn = XGUnit(TargetedActor);
	if( TargetedPawn != none )
	{
		TargetedLocation = TargetedPawn.GetFootLocation();
		TargetedActorTile = World.GetTileCoordinatesFromPosition(TargetedLocation);
		TargetedLocation = World.GetPositionFromTileCoordinates(TargetedActorTile);
	}
	else
	{
		TargetedLocation = TargetedActor.Location;
	}

	AbilityTemplate = Ability.GetMyTemplate();

	if ( AbilityTemplate.AbilityMultiTargetStyle != none)
	{
		AbilityTemplate.AbilityMultiTargetStyle.GetValidTilesForLocation(Ability, TargetedLocation, Tiles);
	}

	if( AbilityTemplate.AbilityTargetStyle != none )
	{
		AbilityTemplate.AbilityTargetStyle.GetValidTilesForLocation(Ability, TargetedLocation, Tiles);
	}

	if( Tiles.Length > 1 )
	{
		GetTargetedActors(TargetedLocation, CurrentlyMarkedTargets, Tiles);
		CheckForFriendlyUnit(CurrentlyMarkedTargets);
		MarkTargetedActors(CurrentlyMarkedTargets, (!AbilityIsOffensive) ? FiringUnit.GetTeam() : eTeam_None);
		AdjustGrenadePath(TargetedPawn);
		DrawAOETiles(Tiles);
		DrawSplashRadius();
	}
}

private function AdjustGrenadePath(XGUnit TargetedPawn)
{
	//local XComGameState_Unit		TargetUnit;
	local XComWeapon				WeaponEntity;
	local PrecomputedPathData		WeaponPrecomputedPathData;
	local vector					TargetedLocation;
	//local float						FinalHeightIncrement;
	//local int i;

	//	Make the arched shot hit in the random point of the upper half of the target's profile
	//TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetedPawn.ObjectID));
	//if (TargetUnit != none)
	//{
		//`LOG("Got unit successfully:" @ TargetedLocation.Z,,'WOTCMoreSparkWeapons');
		//TargetedLocation.Z += TargetUnit.UnitHeight * class'XComWorldData'.const.WORLD_HalfFloorHeight + `SYNC_FRAND() * (TargetUnit.UnitHeight - 1) * class'XComWorldData'.const.WORLD_FloorHeight;
		//`LOG("Adjusted Z:" @ TargetedLocation.Z,,'WOTCMoreSparkWeapons');

		TargetedLocation = GetSplashRadiusCenter();
		//`LOG("Got unit successfully:" @ TargetedLocation.Z,,'WOTCMoreSparkWeapons');
		//FinalHeightIncrement = TargetUnit.UnitHeight * class'XComWorldData'.const.WORLD_HalfFloorHeight + `SYNC_FRAND() * (TargetUnit.UnitHeight - 1) * class'XComWorldData'.const.WORLD_FloorHeight;
		//TargetedLocation.Z += FinalHeightIncrement;
		//`LOG("Adjusted Z:" @ TargetedLocation.Z,,'WOTCMoreSparkWeapons');
	//}
	
	GetGrenadeWeaponInfo(WeaponEntity, WeaponPrecomputedPathData);
	GrenadePath.SetWeaponAndTargetLocation(WeaponEntity, FiringUnit.GetTeam(), TargetedLocation, WeaponPrecomputedPathData);
	
	//for (i = GrenadePath.iNumKeyframes - 1; i >= 0; i--)
	//{
	//	GrenadePath.akKeyframes[i].vLoc.Z += FinalHeightIncrement;
	//	FinalHeightIncrement -= FinalHeightIncrement / GrenadePath.iNumKeyframes;

	//	`LOG("Keyframe:" @ GrenadePath.akKeyframes[i].fTime @ GrenadePath.akKeyframes[i].vLoc @ GrenadePath.akKeyframes[i].rRot @ GrenadePath.akKeyframes[i].bValid,,'WOTCMoreSparkWeapons');

		//if (i > GrenadePath.iNumKeyframes / 2) 
		//{
		//	GrenadePath.akKeyframes[i].vLoc.Z += 100;
		//}
	//}

	//GrenadePath.bSplineDirty = true;
	//GrenadePath.UpdateTrajectory();
	//GrenadePath.DrawPath();
	//GrenadePath.Tick(0);
}

function bool GetCurrentTargetFocus(out Vector Focus)
{
	local Actor TargetedActor;
	local X2VisualizerInterface TargetVisualizer;

	TargetedActor = GetTargetedActor();

	if(TargetedActor != none)
	{
		TargetVisualizer = X2VisualizerInterface(TargetedActor);
		if( TargetVisualizer != None )
		{
			Focus = TargetVisualizer.GetTargetingFocusLocation();
		}
		else
		{
			Focus = TargetedActor.Location;
		}
		
		return true;
	}
	
	return false;
}


//	======================================================================
//	X2TargetingMethod_Grenade.uc
//	======================================================================
function Init(AvailableAction InAction, int NewTargetIndex)
{
	local XComGameStateHistory History;
	local XComWeapon WeaponEntity;
	local PrecomputedPathData WeaponPrecomputedPathData;
	//local float TargetingRange;
	//local X2AbilityTarget_Cursor CursorTarget;
	local X2AbilityTemplate AbilityTemplate;

	super(X2TargetingMethod).Init(InAction, NewTargetIndex);

	History = `XCOMHISTORY;

	AssociatedPlayerState = XComGameState_Player(History.GetGameStateForObjectID(UnitState.ControllingPlayer.ObjectID));

	// determine our targeting range
	AbilityTemplate = Ability.GetMyTemplate();
	//TargetingRange = Ability.GetAbilityCursorRangeMeters();

	// lock the cursor to that range
	//Cursor = `Cursor;
	//Cursor.m_fMaxChainedDistance = `METERSTOUNITS(TargetingRange);

	// set the cursor location to itself to make sure the chain distance updates
	//Cursor.CursorSetLocation(Cursor.GetCursorFeetLocation(), false, true); 

	//CursorTarget = X2AbilityTarget_Cursor(Ability.GetMyTemplate().AbilityTargetStyle);
	//if (CursorTarget != none)
	//	bRestrictToSquadsightRange = CursorTarget.bRestrictToSquadsightRange;

	GetGrenadeWeaponInfo(WeaponEntity, WeaponPrecomputedPathData);
	// Tutorial Band-aid #2 - Should look at a proper fix for this
	if (WeaponEntity.m_kPawn == none)
	{
		WeaponEntity.m_kPawn = FiringUnit.GetPawn();
	}

	GrenadePath = `PRECOMPUTEDPATH;
	GrenadePath.ClearOverrideTargetLocation(); // Clear this flag in case the grenade target location was locked.
	GrenadePath.ActivatePath(WeaponEntity, FiringUnit.GetTeam(), WeaponPrecomputedPathData);

	if (!AbilityTemplate.SkipRenderOfTargetingTemplate)
	{
		// setup the blast emitter
		ExplosionEmitter = `BATTLE.spawn(class'XComEmitter');
		if(AbilityIsOffensive)
		{
			ExplosionEmitter.SetTemplate(ParticleSystem(DynamicLoadObject("UI_Range.Particles.BlastRadius_Shpere", class'ParticleSystem')));
		}
		else
		{
			ExplosionEmitter.SetTemplate(ParticleSystem(DynamicLoadObject("UI_Range.Particles.BlastRadius_Shpere_Neutral", class'ParticleSystem')));
		}
		
		ExplosionEmitter.LifeSpan = 60 * 60 * 24 * 7; // never die (or at least take a week to do so)
	}

	//	Top Down
	LookatCamera = new class'X2Camera_LookAtActor';
	LookatCamera.UseTether = false;
	`CAMERASTACK.AddCamera(LookatCamera);

	DirectSetTarget(0);
}

simulated protected function Vector GetSplashRadiusCenter( bool SkipTileSnap = false )
{
	local Actor TargetedActor;
	local vector Center;

	TargetedActor = GetTargetedActor();
	if (TargetedActor != none)
	{
		Center = TargetedActor.Location;
	}
	
	return Center;
}