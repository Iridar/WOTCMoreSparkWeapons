class X2TargetingMethod_HeavyAutogun extends X2TargetingMethod_TopDown;

//	This targeting method uses Top Down targeting if the ability has a Multi Target Radius to speak of, and Over The Shoulder targeting otherwise.

var private float AbilityRadius;

//	From Area Suppression
function Update(float DeltaTime)
{
    local array<Actor> CurrentlyMarkedTargets;
    local array<TTile> Tiles;
    local Actor TargetedActor, CurrentTarget;
    local XGUnit TargetedUnit;

	//	Do Area Suppression treatment only if there's actual AOE to display.
	if (AbilityRadius >=1.0f)
	{
		TargetedActor = GetTargetedActor();
		GetTargetedActors(TargetedActor.Location, CurrentlyMarkedTargets, Tiles);
		foreach CurrentlyMarkedTargets (CurrentTarget)
		{
			TargetedUnit = XGUnit (CurrentTarget);
			if (TargetedUnit == none)
			{
				CurrentlyMarkedTargets.RemoveItem(CurrentTarget);
			}
			else
			{
				if (FiringUnit.GetTeam() == TargetedUnit.GetTeam())
					CurrentlyMarkedTargets.RemoveItem(CurrentTarget);
			}
		}
		MarkTargetedActors(CurrentlyMarkedTargets, ((!AbilityIsOffensive) ? FiringUnit.GetTeam() : 0));
	}
}

function Init(AvailableAction InAction, int NewTargetIndex)
{
	//	Get AbilityRadius to determined what kind of targeting we want to do.
	Ability = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(InAction.AbilityObjectRef.ObjectID));
	AbilityRadius = Ability.GetAbilityRadius();

	if (AbilityRadius >=1.0f)
	{
		//	Do Top Down init if the ability hits AOE tiles
		super.Init(InAction, NewTargetIndex);
	}
	else
	{
		//	Otherwise do OTS Init
		super(X2TargetingMethod).Init(InAction, NewTargetIndex);
		DirectSetTarget(NewTargetIndex);
		UpdatePostProcessEffects(true);
	}	
}

function Canceled()
{
	//	From Area Suppression
	ClearTargetedActors();

	if (AbilityRadius >=1.0f)
	{
		//	Top Down treatment
		super.Canceled();
	}
	else
	{
		//	OTS treatment
		super(X2TargetingMethod).Canceled();
		RemoveTargetingCamera();

		FiringUnit.IdleStateMachine.bTargeting = false;
		NotifyTargetTargeted(false);

		UpdatePostProcessEffects(false);
	}
}

function Committed()
{
	if (AbilityRadius >=1.0f)
	{
		//	Top Down
		Canceled();
	}
	else
	{	
		//	OTS
		AOEMeshActor.Destroy();
		ClearTargetedActors();

		if(!Ability.GetMyTemplate().bUsesFiringCamera)
		{
			RemoveTargetingCamera();
		}

		UpdatePostProcessEffects(false);
	}
}

function DirectSetTarget(int TargetIndex)
{
	local XComPresentationLayer Pres;
	local UITacticalHUD TacticalHud;
	local Actor NewTargetActor;
	local bool ShouldUseMidpointCamera;
	local array<TTile> Tiles;
	local XComDestructibleActor Destructible;
	local Vector TilePosition;
	local TTile CurrentTile;
	local XComWorldData World;
	local array<Actor> CurrentlyMarkedTargets;

	if (AbilityRadius >=1.0f)
	{
		//	Top Down
		super.DirectSetTarget(TargetIndex);
	}
	else
	{

		Pres = `PRES;
		World = `XWORLD;
	
		NotifyTargetTargeted(false);

		// make sure our target is in bounds (wrap around out of bounds values)
		LastTarget = TargetIndex;
		LastTarget = LastTarget % Action.AvailableTargets.Length;
		if (LastTarget < 0) LastTarget = Action.AvailableTargets.Length + LastTarget;

		ShouldUseMidpointCamera = ShouldUseMidpointCameraForTarget(Action.AvailableTargets[LastTarget].PrimaryTarget.ObjectID) || !`Battle.ProfileSettingsGlamCam();

		NewTargetActor = GetTargetedActor();

		AddTargetingCamera(NewTargetActor, ShouldUseMidpointCamera);

		// put the targeting reticle on the new target
		TacticalHud = Pres.GetTacticalHUD();
		TacticalHud.TargetEnemy(GetTargetedObjectID());


		FiringUnit.IdleStateMachine.bTargeting = true;
		FiringUnit.IdleStateMachine.CheckForStanceUpdate();

		class'WorldInfo'.static.GetWorldInfo().PlayAKEvent(AkEvent'SoundTacticalUI.TacticalUI_TargetSelect');

		NotifyTargetTargeted(true);

		Destructible = XComDestructibleActor(NewTargetActor);
		if( Destructible != None )
		{
			Destructible.GetRadialDamageTiles(Tiles);
		}
		else
		{
			GetEffectAOETiles(Tiles);
		}

		//	reset these values when changing targets
		bFriendlyFireAgainstObjects = false;
		bFriendlyFireAgainstUnits = false;

		if( Tiles.Length > 1 )
		{
			if( ShouldUseMidpointCamera )
			{
				foreach Tiles(CurrentTile)
				{
					TilePosition = World.GetPositionFromTileCoordinates(CurrentTile);
					if( World.Volume.EncompassesPoint(TilePosition) )
					{
						X2Camera_Midpoint(FiringUnit.TargetingCamera).AddFocusPoint(TilePosition, true);
					}
				}
			
			}
			GetTargetedActorsInTiles(Tiles, CurrentlyMarkedTargets, false);
			CheckForFriendlyUnit(CurrentlyMarkedTargets);
			MarkTargetedActors(CurrentlyMarkedTargets, (!AbilityIsOffensive) ? FiringUnit.GetTeam() : eTeam_None);
			DrawAOETiles(Tiles);
			AOEMeshActor.SetHidden(false);
		}
		else
		{
			ClearTargetedActors();
			AOEMeshActor.SetHidden(true);
		}
	}
}

function bool GetCurrentTargetFocus(out Vector Focus)
{
	if (AbilityRadius >=1.0f)
	{
		//	Top Down
		super.GetCurrentTargetFocus(Focus);
	}
	else
	{
		//	OTS
		if( FiringUnit.TargetingCamera != None )
		{
			Focus = FiringUnit.TargetingCamera.GetTargetLocation();
		}
		else
		{
			Focus = GetTargetedActor().Location;
		}
		return true;
	}
}

//	============================================ 
//			OVER THE SHOULDER	-	 REQUIRED
//	============================================ 

private function AddTargetingCamera(Actor NewTargetActor, bool ShouldUseMidpointCamera)
{
	local X2Camera_Midpoint MidpointCamera;
	local X2Camera_OTSTargeting OTSCamera;
	local X2Camera_MidpointTimed LookAtMidpointCamera;
	local bool bCurrentTargetingCameraIsMidpoint;
	local bool bShouldAddNewTargetingCameraToStack;

	if (AbilityRadius < 1.0f)
	{
		if( FiringUnit.TargetingCamera != None )
		{
			bCurrentTargetingCameraIsMidpoint = (X2Camera_Midpoint(FiringUnit.TargetingCamera) != None);

			if( bCurrentTargetingCameraIsMidpoint != ShouldUseMidpointCamera )
			{
				RemoveTargetingCamera();
			}
		}

		if( ShouldUseMidpointCamera )
		{
			if( FiringUnit.TargetingCamera == None )
			{
				FiringUnit.TargetingCamera = new class'X2Camera_Midpoint';
				bShouldAddNewTargetingCameraToStack = true;
			}

			MidpointCamera = X2Camera_Midpoint(FiringUnit.TargetingCamera);
			MidpointCamera.TargetActor = NewTargetActor;
			MidpointCamera.ClearFocusActors();
			MidpointCamera.AddFocusActor(FiringUnit);
			MidpointCamera.AddFocusActor(NewTargetActor);

			// the following only needed if bQuickTargetSelectEnabled were desired
			//if( TacticalHud.m_kAbilityHUD.LastTargetActor != None )
			//{
			//	MidpointCamera.AddFocusActor(TacticalHud.m_kAbilityHUD.LastTargetActor);
			//}

			if( bShouldAddNewTargetingCameraToStack )
			{
				`CAMERASTACK.AddCamera(FiringUnit.TargetingCamera);
			}

			MidpointCamera.RecomputeLookatPointAndZoom(false);
		}
		else
		{
			if( FiringUnit.TargetingCamera == None )
			{
				FiringUnit.TargetingCamera = new class'X2Camera_OTSTargeting';
				bShouldAddNewTargetingCameraToStack = true;
			}

			OTSCamera = X2Camera_OTSTargeting(FiringUnit.TargetingCamera);
			OTSCamera.FiringUnit = FiringUnit;
			OTSCamera.CandidateMatineeCommentPrefix = UnitState.GetMyTemplate().strTargetingMatineePrefix;
			OTSCamera.ShouldBlend = class'X2Camera_LookAt'.default.UseSwoopyCam;
			OTSCamera.ShouldHideUI = false;

			if( bShouldAddNewTargetingCameraToStack )
			{
				`CAMERASTACK.AddCamera(FiringUnit.TargetingCamera);
			}

			// add swoopy midpoint
			if( !OTSCamera.ShouldBlend )
			{
				LookAtMidpointCamera = new class'X2Camera_MidpointTimed';
				LookAtMidpointCamera.AddFocusActor(FiringUnit);
				LookAtMidpointCamera.LookAtDuration = 0.0f;
				LookAtMidpointCamera.AddFocusPoint(OTSCamera.GetTargetLocation());
				OTSCamera.PushCamera(LookAtMidpointCamera);
			}

			// have the camera look at the new target
			OTSCamera.SetTarget(NewTargetActor);
		}
	}
}


private function RemoveTargetingCamera()
{
	if( FiringUnit.TargetingCamera != none )
	{
		`CAMERASTACK.RemoveCamera(FiringUnit.TargetingCamera);
		FiringUnit.TargetingCamera = none;
	}
}

private function GetEffectAOETiles(out array<TTile> TilesToBeDamaged)
{
	local XComGameState_Unit TargetUnit;
	local XComGameStateHistory History;
	local XComGameState_Effect EffectState;
	local StateObjectReference EffectRef;
	local XComGameState_Unit SourceUnit;

	if (AbilityRadius < 1.0f)
	{
		History = `XCOMHISTORY;

		TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(GetTargetedObjectID()));
		if( TargetUnit != None )
		{
			foreach TargetUnit.AffectedByEffects(EffectRef)
			{
				EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
				if( EffectState != None )
				{
					SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
					if( SourceUnit != None )
					{
						EffectState.GetX2Effect().GetAOETiles(SourceUnit, TargetUnit, TilesToBeDamaged);
					}
				}
			}
		}
	}
}

private function NotifyTargetTargeted(bool Targeted)
{
	local XComGameStateHistory History;
	local XGUnit TargetUnit;

	if (AbilityRadius < 1.0f)
	{

		History = `XCOMHISTORY;

		if( LastTarget != -1 )
		{
			TargetUnit = XGUnit(History.GetVisualizer(GetTargetedObjectID()));
		}

		if( TargetUnit != None )
		{
			// only have the target peek if he isn't peeking into the shooters tile. Otherwise they get really kissy.
			// setting the "bTargeting" flag will make the unit do the hold peek.
			TargetUnit.IdleStateMachine.bTargeting = Targeted && !FiringUnit.HasSameStepoutTile(TargetUnit);
			TargetUnit.IdleStateMachine.CheckForStanceUpdate();
		}
	}
}

static function bool ShouldWaitForFramingCamera()
{
	// we only need to disable the framing camera if we are pushing an OTS targeting camera, which we don't do when user
	// has disabled glam cams
	return !`BATTLE.ProfileSettingsGlamCam();
}