class X2TargetingMethod_HeatShot extends X2TargetingMethod_Grenade;

//	======================================================================
//	X2TargetingMethod_TopDown.uc
//	======================================================================
var private X2Camera_LookAtActor LookatCamera;
var protected int LastTarget;

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
		DrawAOETiles(Tiles);
		DrawSplashRadius();

		GetCurrentTargetFocus(TargetedLocation);
		AdjustGrenadePath(TargetedLocation);
	}
}

private function AdjustGrenadePath(vector TargetLocation)
{
	local vector vDif;
	local int iKeyframes;
	local int i;
	local float Alpha;
	local float PathLength;
	//local InterpCurvePointVector	CurvePoint;

	iKeyframes = GrenadePath.iNumKeyframes;
	vDif = TargetLocation - GrenadePath.akKeyframes[iKeyframes - 1].vLoc;

	GrenadePath.bUseOverrideTargetLocation = true;
	GrenadePath.OverrideTargetLocation = TargetLocation;

	GrenadePath.bUseOverrideSourceLocation = true;
	GrenadePath.OverrideSourceLocation = GrenadePath.akKeyframes[0].vLoc;

	`LOG("============== BEGIN SPLINE PRINT ===================",, 'SmartRounds');
	for (i = 0; i < GrenadePath.kSplineInfo.Points.Length; i++)
	{
		`LOG("Spline:" @ i @":" @ GrenadePath.kSplineInfo.Points[i].InVal @ GrenadePath.kSplineInfo.Points[i].OutVal,, 'SmartRounds');
	}
	`LOG("============== END SPLINE PRINT ===================",, 'SmartRounds');

	for (i = 0; i < iKeyframes; i++)
	{	
		Alpha = float(i) / float(iKeyframes);
		`LOG("Old frame:" @ i @ "out of:" @ iKeyframes @ "Alpha:" @ Alpha @ "____" @ GrenadePath.akKeyframes[i].vLoc @ GrenadePath.akKeyframes[i].fTime,, 'SmartRounds');			
		GrenadePath.akKeyframes[i].vLoc += vDif * Alpha;
		`LOG("New frame:" @ i @ "out of:" @ iKeyframes @ "Alpha:" @ Alpha @ "____" @ GrenadePath.akKeyframes[i].vLoc @ GrenadePath.akKeyframes[i].fTime,, 'SmartRounds');		

		GrenadePath.kSplineInfo.Points[i].OutVal = GrenadePath.akKeyframes[i].vLoc;
	}	
	PathLength = GrenadePath.akKeyframes[GrenadePath.iNumKeyframes - 1].fTime - GrenadePath.akKeyframes[0].fTime;
	GrenadePath.kRenderablePath.UpdatePathRenderData(GrenadePath.kSplineInfo, PathLength, none, `CAMERASTACK.GetCameraLocationAndOrientation().Location);
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


function Init(AvailableAction InAction, int NewTargetIndex)
{
	local XComWeapon			WeaponEntity;
	local PrecomputedPathData	WeaponPrecomputedPathData;
	local X2AbilityTemplate		AbilityTemplate;

	super(X2TargetingMethod).Init(InAction, NewTargetIndex);

	AssociatedPlayerState = XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(UnitState.ControllingPlayer.ObjectID));
	AbilityTemplate = Ability.GetMyTemplate();

	GetGrenadeWeaponInfo(WeaponEntity, WeaponPrecomputedPathData);
	// Tutorial Band-aid #2 - Should look at a proper fix for this
	if (WeaponEntity.m_kPawn == none)
	{
		WeaponEntity.m_kPawn = FiringUnit.GetPawn();
	}

	GrenadePath = `PRECOMPUTEDPATH;
	GrenadePath.ClearOverrideTargetLocation(); // Clear this flag in case the grenade target location was locked.
	GrenadePath.ActivatePath(WeaponEntity, FiringUnit.GetTeam(), WeaponPrecomputedPathData);
	GrenadePath.SetFiringFromSocketPosition('gun_fire');

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

function Update(float DeltaTime)
{
	local vector TargetedLocation;

	super(X2TargetingMethod).Update(DeltaTime);
	
	GetCurrentTargetFocus(TargetedLocation);
	AdjustGrenadePath(TargetedLocation);	
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

//	================================================

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
/*
private function AdjustGrenadePath(vector TargetLocation)
{
	local vector vDif;
	local int iKeyframes;
	local int i;
	local float Alpha;
	local XComWeapon				WeaponEntity;
	local PrecomputedPathData		WeaponPrecomputedPathData;

	iKeyframes = GrenadePath.iNumKeyframes;
	vDif = TargetLocation - GrenadePath.akKeyframes[iKeyframes - 1].vLoc;

	GetGrenadeWeaponInfo(WeaponEntity, WeaponPrecomputedPathData);
	GrenadePath.SetWeaponAndTargetLocation(WeaponEntity, FiringUnit.GetTeam(), TargetLocation, WeaponPrecomputedPathData);

	GrenadePath.bUseOverrideSourceLocation = true;
	GrenadePath.OverrideSourceLocation = GrenadePath.akKeyframes[0].vLoc;
	GrenadePath.SetFiringFromSocketPosition('gun_fire');

	//GrenadePath.LastTargetLocation = TargetLocation;

	for (i = 0; i < iKeyframes; i++)
	{	
		Alpha = float(i) / float(iKeyframes);
		`LOG("Old frame:" @ i @ "out of:" @ iKeyframes @ "Alpha:" @ Alpha @ "____" @ GrenadePath.akKeyframes[i].vLoc @ GrenadePath.akKeyframes[i].fTime,, 'SmartRounds');			
		GrenadePath.akKeyframes[i].vLoc += vDif * Alpha;
		`LOG("New frame:" @ i @ "out of:" @ iKeyframes @ "Alpha:" @ Alpha @ "____" @ GrenadePath.akKeyframes[i].vLoc @ GrenadePath.akKeyframes[i].fTime,, 'SmartRounds');		
	}	

	//GrenadePath.ForceRebuildGrenadePath();
	
	//GrenadePath.UpdateTrajectory();
	GrenadePath.bSplineDirty = true;
	
}*/