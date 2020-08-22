class X2Effect_SabotShell extends X2Effect_Persistent config(ArtilleryCannon);

var config array<name> BlacklistedAbilities;

//	Compensates for defense bonus when shooting through cover
//	Reduces damage at long range and when shooting through cover.
var config float CounterCoverDefenseBonus;

var config float ReduceDamageLowCover;
var config float ReduceDamageHighCover;
var config float ReduceDamagePerTile;

//var config int PierceConventional;
//var config int PierceMagnetic;
//var config int PierceBeam;
/*
I decided to drop dynamic Armor Pierce from the Sabot Shells for the sake of transparency. I just realized current Armor Pierce is not displayed in the UI anywhere, at all, even with mods.
So it would be pretty hard to tell how much Pierce you're getting currently.
So I'll keep it static, cuz it wouldn't make sense for Sabot to not get any Pierce at all.


;	These values must match the actual Pierce of the Cannon.
PierceConventional = 3
PierceMagnetic = 4
PierceBeam = 5
*/

//	This will modify environmental damage dealt by special shell shots.
//	It is not necessary for the regular firemode.
function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager		EventMgr;
	local Object				EffectObj;
	//local XComGameState_Unit	UnitState;

	EventMgr = `XEVENTMGR;
	EffectObj = EffectGameState;
	//UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	
	//	Stting high priority so this listener gets executed first
	EventMgr.RegisterForEvent(EffectObj, 'ModifyEnvironmentDamage', class'X2Ability_ArtilleryCannon'.static.ModifyEnvironmenDamage_Listener, ELD_Immediate, 75, /*UnitState*/,, /*EffectObj*/);	

	super.RegisterForEvents(EffectGameState);
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{	
	local ShotModifierInfo				ModInfo;
	local GameRulesCache_VisibilityInfo VisInfo;
	//local int							TileDistance;

	if (default.BlacklistedAbilities.Find(AbilityState.GetMyTemplateName()) != INDEX_NONE) return;
	if (EffectState.ApplyEffectParameters.ItemStateObjectRef != AbilityState.SourceWeapon) return;

	//	Compensate aim penalty for shooting through cover
	//	This method of getting target cover seems to be most reliable
	if (Target.CanTakeCover() && `TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, Target.ObjectID, VisInfo))
	{	
		//`LOG("Attacker:" @ Attacker.GetFullName() @ "Target:" @ Target.GetFullName() @ "Cover:" @ VisInfo.TargetCover,, 'WOTCMoreSparkWeapons');
		switch (VisInfo.TargetCover)
		{
			case CT_MidLevel:
				ModInfo.ModType = eHit_Success;
				ModInfo.Reason = FriendlyName;
				ModInfo.Value = class'X2AbilityToHitCalc_StandardAim'.default.LOW_COVER_BONUS * default.CounterCoverDefenseBonus;
				ShotModifiers.AddItem(ModInfo);
				break;
			case CT_Standing:
				ModInfo.ModType = eHit_Success;
				ModInfo.Reason = FriendlyName;
				ModInfo.Value = class'X2AbilityToHitCalc_StandardAim'.default.HIGH_COVER_BONUS * default.CounterCoverDefenseBonus;
				ShotModifiers.AddItem(ModInfo);
				break;
			default:
				break;
		}
	}
}
/*
static private function int GetPierceAmount(const XComGameState_Ability AbilityState)
{
	local XComGameState_Item	SourceWeapon;
	local X2WeaponTemplate		WeaponTemplate;

	SourceWeapon = AbilityState.GetSourceWeapon();
	if (SourceWeapon != none)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		if (WeaponTemplate != none)
		{
			switch (WeaponTemplate.WeaponTech)
			{
				case 'conventional':
					return default.PierceConventional;
				case 'magnetic':
					return default.PierceMagnetic;
				case 'beam':
					return default.PierceBeam;
				default:
					return 0;
			}
		}
	}
	return 0;
}*/

static private function GetDamageReduction(const XComGameState_Unit Attacker, const XComGameState_Unit TargetUnit, out float DamageMod)
{
	local GameRulesCache_VisibilityInfo VisInfo;
	local int TileDistance;

	//	Modify damage by cover
	if (TargetUnit.CanTakeCover() && `TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, TargetUnit.ObjectID, VisInfo))
	{	
		switch (VisInfo.TargetCover)
		{
			case CT_Standing:
				DamageMod -= default.ReduceDamageHighCover;
				break;
			case CT_MidLevel:
				DamageMod -= default.ReduceDamageLowCover;
				break;
			default:
				break;
		}
	}

	//	Modify damage by distance at squadsight range
	TileDistance = Attacker.TileDistanceBetween(TargetUnit);

	//TileDistance -= 18;
	//if (TileDistance < 0) return;

	DamageMod -= TileDistance * default.ReduceDamagePerTile;
}

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) 
{
	local float							DamageMod;
	local XComGameState_Unit			TargetUnit;

	if (default.BlacklistedAbilities.Find(AbilityState.GetMyTemplateName()) != INDEX_NONE) return 0;
	if (EffectState.ApplyEffectParameters.ItemStateObjectRef != AbilityState.SourceWeapon) return 0;

	TargetUnit = XComGameState_Unit(TargetDamageable);
	if (TargetUnit != none)
	{
		GetDamageReduction(Attacker, TargetUnit, DamageMod);

		//`LOG("GetAttackingDamageModifier:" @ DamageMod @ "Current Damage:" @ CurrentDamage,, 'WOTCMoreSparkWeapons');

		//	Compensate for exhausting Pierce first
		//DamageMod += GetPierceAmount(AbilityState);

		//	There was not enough Armor Pierce reduction to start exhausting the damage as well.
		//if (DamageMod >= 0) 
		//{
		//	`LOG("GetAttackingDamageModifier: Pierce not fully exhausted, exiting.",, 'WOTCMoreSparkWeapons');
		//	return 0;
		//}

		//`LOG("GetAttackingDamageModifier after exhausting Pierce:" @ DamageMod,, 'WOTCMoreSparkWeapons');

		//	Damage was fully comepnsated, the attack will deal no damage.
		if (DamageMod < -1)
		{
			return -CurrentDamage;
		}
	}
	return CurrentDamage * DamageMod; 
}
/*
function int GetExtraArmorPiercing(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData) 
{ 
	local float							DamageMod;
	local XComGameState_Unit			TargetUnit;
	local int							NormalPierce;

	if (AbilityState.GetMyTemplateName() != 'IRI_FireArtilleryCannon_AP') return 0;

	TargetUnit = XComGameState_Unit(TargetDamageable);
	if (TargetUnit != none)
	{
		GetDamageReduction(Attacker, TargetUnit, DamageMod);

		NormalPierce = GetPierceAmount(AbilityState);
		`LOG("GetExtraArmorPiercing:" @ DamageMod @ "Base Pierce:" @ NormalPierce,, 'WOTCMoreSparkWeapons');

		if (NormalPierce + DamageMod < 0)
		{
			`LOG("GetExtraArmorPiercing: Pierce fully exhausted.",, 'WOTCMoreSparkWeapons');
			return -NormalPierce;
		}
	}
	return DamageMod; 
}*/
/*
struct ApplyDamageInfo
{
	var WeaponDamageValue BaseDamageValue;
	var WeaponDamageValue ExtraDamageValue;
	var WeaponDamageValue BonusEffectDamageValue;
	var WeaponDamageValue AmmoDamageValue;
	var WeaponDamageValue UpgradeDamageValue;
	var bool bDoesDamageIgnoreShields;
};
*/


//	Commented out unless there's a way to check if a tile contains a terrain blocking element (e.g. cliff)
/*
static function GetDamageReduction(const XComGameState_Unit Attacker, const XComGameState_Unit TargetUnit, out float DamageMod)
{
	local XComWorldData					World;
	local array<TilePosPair>			TilesBetweenUnits;
	local TTile							ShooterTileLocation, TargetTileLocation;
	local vector						ShooterLocation, TargetLocation;
	local int i;

	World = `XWORLD;

	//	Increase tile height so that the ray is trace from somewhere in the middle/upper body of the unit, and not feet-to-feet
	ShooterTileLocation = Attacker.TileLocation;
	ShooterTileLocation.Z += Attacker.UnitHeight - 1;
	ShooterLocation = World.GetPositionFromTileCoordinates(ShooterTileLocation);

	TargetTileLocation = TargetUnit.TileLocation;
	TargetTileLocation.Z += TargetUnit.UnitHeight - 1;
	TargetLocation = World.GetPositionFromTileCoordinates(TargetTileLocation);

	//	Similar method to collecting tiles via raytrace, but also collects blocked tiles.
	World.CollectTilesInCapsule(TilesBetweenUnits, ShooterLocation, TargetLocation, World.WORLD_HalfFloorHeight);
	
	`LOG("Gathered tiles:" @ TilesBetweenUnits.Length,, 'WOTCMoreSparkWeapons');

	for (i = 0; i < TilesBetweenUnits.Length; i++)
	{
		`LOG("## Tile: " @ i @ ":" @ TilesBetweenUnits[i].Tile.X @ TilesBetweenUnits[i].Tile.Y @ TilesBetweenUnits[i].Tile.Z,, 'WOTCMoreSparkWeapons');

		if (TilesBetweenUnits[i].Tile == ShooterTileLocation || TilesBetweenUnits[i].Tile == TargetTileLocation)
		{
			`LOG("Skipping tile cuz it's occupied by shooter or target",, 'WOTCMoreSparkWeapons');
			continue;
		}

		if (World.IsTileFullyOccupied(TilesBetweenUnits[i].Tile))
		{
			`LOG("This tile is fully occupied.",, 'WOTCMoreSparkWeapons');
			DamageMod -= 2;
		}
	}
}
function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) 
{
	local XComWorldData					World;
	local array<TilePosPair>			TilesBetweenUnits;
	local array<TilePosPair>			TilePosPairs;
	local array<int>					ProcessedDestructibleActors;
	local XComGameState_Unit			TargetUnit;
	local TTile							ShooterTileLocation, TargetTileLocation;
	local vector						ShooterLocation, TargetLocation;
	local array<XComDestructibleActor>	DestructibleActors;
	local XComDestructibleActor			DestructibleActor;
	local float DamageMod;
	local int i;

	if (AppliedData.AbilityInputContext.AbilityTemplateName != 'IRI_FireArtilleryCannon_AP')
		return 0;

	World = `XWORLD;

	//	Increase tile height so that the ray is trace from somewhere in the middle/upper body of the unit, and not feet-to-feet
	ShooterTileLocation = Attacker.TileLocation;
	ShooterTileLocation.Z += Attacker.UnitHeight - 1;
	ShooterLocation = World.GetPositionFromTileCoordinates(ShooterTileLocation);

	TargetUnit = XComGameState_Unit(TargetDamageable);
	if (TargetUnit != none)
	{
		TargetTileLocation = TargetUnit.TileLocation;
		TargetTileLocation.Z += TargetUnit.UnitHeight - 1;
		TargetLocation = World.GetPositionFromTileCoordinates(TargetTileLocation);
	}
	else return 0;

	//	Similar method to collecting tiles via raytrace, but also collects blocked tiles.
	World.CollectTilesInCapsule(TilesBetweenUnits, ShooterLocation, TargetLocation, World.WORLD_HalfFloorHeight);
	
	`LOG("Gathered tiles:" @ TilesBetweenUnits.Length,, 'WOTCMoreSparkWeapons');

	for (i = 0; i < TilesBetweenUnits.Length; i++)
	{
		`LOG("## Tile: " @ i @ ":" @ TilesBetweenUnits[i].Tile.X @ TilesBetweenUnits[i].Tile.Y @ TilesBetweenUnits[i].Tile.Z,, 'WOTCMoreSparkWeapons');

		if (TilesBetweenUnits[i].Tile == ShooterTileLocation || TilesBetweenUnits[i].Tile == TargetTileLocation)
		{
			`LOG("Skipping tile cuz it's occupied by shooter or target",, 'WOTCMoreSparkWeapons');
			continue;
		}

		if (World.IsTileFullyOccupied(TilesBetweenUnits[i].Tile))
		{
			TilePosPairs[0] = TilesBetweenUnits[i];	

			DestructibleActors.Length = 0;
			World.CollectDestructiblesInTiles(TilePosPairs, DestructibleActors);

			`LOG("This tile is fully occupied. Actors:" @ DestructibleActors.Length,, 'WOTCMoreSparkWeapons');

			DamageMod -= 2;
			
			foreach DestructibleActors(DestructibleActor)
			{
				//	If the destructible actor is actually destructible, reduce shot's damage based on its health
				if (ProcessedDestructibleActors.Find(DestructibleActor.ObjectID) == INDEX_NONE)
				{
					`LOG("New destructible actor:" @ PathName(DestructibleActor.ObjectArchetype) @ "Health:" @ DestructibleActor.Health,, 'WOTCMoreSparkWeapons');
					DamageMod -= DestructibleActor.Health / 10.0f;
					ProcessedDestructibleActors.AddItem(DestructibleActor.ObjectID);
				}
				else `LOG("Destructible actor already processed.",, 'WOTCMoreSparkWeapons');
			}
		}
	}

	//	Don't allow dealing negative damage
	if (CurrentDamage - DamageMod < 0)
	{
		return -CurrentDamage;
	}
	return DamageMod; 
}*/
/*
[0077.11] WOTCMoreSparkWeapons: VoxelRaytrace_Locations returns true: 3
[0077.11] WOTCMoreSparkWeapons: ## Tile:  0 : 12 5 1
[0077.11] WOTCMoreSparkWeapons: This tile is blocked. Actors: 0
[0077.11] WOTCMoreSparkWeapons: ## Tile:  1 : 12 11 2
[0077.11] WOTCMoreSparkWeapons: This tile is blocked. Actors: 0
[0077.11] WOTCMoreSparkWeapons: ## Tile:  2 : 12 10 2
*/
/*
struct native VoxelRaytraceCheckResult
{	
	var int     BlockedFlag;    //Indicates which blocking flag was responsible for blocking the trace. 0x0 if the trace was not blocked
	var byte    TraceFlags;     //Contains info about what the trace passed through ( smoke, windows, etc. )
	var TTile   BlockedTile;    //If bBlocked is true, contains the tile that blocked the trace	
	var TTile   BlockedVoxel;   //If bBlocked is true, contains the voxel that blocked the trace
	var bool    bDebug;         //Instructs the voxel raytrace to draw debug data
	var bool	bRecordAllTiles;	//Instructs the voxel raytrace to record all the tiles traced through.  Tiles can be found in TraceTiles member
	var bool	bTraceToMapEdge;	//Instructs the voxel raytrace to trace all the way to the map edge (having travelled through the end tile).
		
	var vector  TraceStart;
	var vector  TraceEnd;       
	var vector  TraceBlocked;	//Contains the location of the voxel where the trace was blocked
	var Actor	TraceBlockedActor;//The actor that created the blocking voxel that blocked this trace
	var float   Distance;       //Linear distance of this trace

	var array<TTile>	TraceTiles; // All the Tile that were traced through


*/
/*
World.CollectTilesInBox( out array<TilePosPair> Collection, const out Vector Minimum, const out Vector Maximum );

native function bool VoxelRaytrace_Locations( const out Vector FromLocation, const out Vector ToLocation, out VoxelRaytraceCheckResult OutResult );
native function bool VoxelRaytrace_Tiles( const out TTile FromLocation, const out TTile ToLocation, out VoxelRaytraceCheckResult OutResult );

static function bool 
ECoverType  = 
*/
/*
function WeaponDamageValue GetBonusEffectDamageValue(XComGameState_Ability AbilityState, XComGameState_Unit SourceUnit, XComGameState_Item SourceWeapon, StateObjectReference TargetRef)
{
	local WeaponDamageValue		ReturnDamageValue;
	local XComGameState_Unit	TargetUnit;
	local XComGameState_Unit	AdditionalTarget;
	local array<XComGameState_Unit>	AdditionalTargets;
	local XComWorldData			WorldData;
	local XComGameStateHistory	History;
	local vector				ShooterLocation, TargetLocation;
	local array<StateObjectReference>	UnitsOnTile;
	local StateObjectReference			UnitRef;
	local TTile					TargetTile;
	local array<TilePosPair>			Tiles;
	local int i;
	local array<XComDestructibleActor>	DestructibleActors;

	History = `XCOMHISTORY;
	WorldData = `XWORLD;

	ReturnDamageValue = EffectDamageValue;

	////`LOG("Targeting: " @ TargetRef.ObjectID, bLog, 'IRIROCK');

	TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(TargetRef.ObjectID));
	if (TargetUnit != none) 
	{

		////`LOG("Target is a unit: " @ TargetUnit.GetFullName(), bLog, 'IRIROCK');
		////`LOG("Calculating unit damage: " @ ReturnDamageValue.Damage, bLog, 'IRIROCK');
		TargetTile = TargetUnit.TileLocation;

		//	first, reduce damage based on tile distance to the target.
		ReturnDamageValue.Damage -= default.DAMAGE_LOSS_PER_TILE * TileDistanceBetweenTiles(SourceUnit.TileLocation, TargetTile);
		////`LOG("Distance adjust: " @ ReturnDamageValue.Damage, bLog, 'IRIROCK');
		//	If that would reduce damage to zero or lower, exit the function then and there.
		if (ReturnDamageValue.Damage <= 0) 
		{
			ReturnDamageValue.Shred = 0;
			ReturnDamageValue.Damage = 0;
		}
		else
		{
			//	otherwise, get positions for both shooter and this current target
			ShooterLocation = WorldData.GetPositionFromTileCoordinates(SourceUnit.TileLocation);
			TargetLocation = WorldData.GetPositionFromTileCoordinates(TargetTile);

			//	grab all the tiles between the shooter and the target
			WorldData.CollectTilesInCapsule(Tiles, ShooterLocation, TargetLocation, 1.0f); //WORLD_StepSize

			//	cycle through grabbed tiles
			for (i = 0; i < Tiles.Length; i++)
			{
				//	and try to find any units on it
				UnitsOnTile = WorldData.GetUnitsOnTile(Tiles[i].Tile);
				foreach UnitsOnTile(UnitRef)
				{
					AdditionalTarget = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));

					//	Add the Unit to the list of additional targets only if it's not the shooter, and not the primary target of this effect, and it's not in the list already
					//	and it's actually alive and not in Stasis
					if (AdditionalTarget != none && 
						UnitRef.ObjectID != TargetUnit.ObjectID &&
						UnitRef.ObjectID != SourceUnit.ObjectID && 
						AdditionalTargets.Find(AdditionalTarget) == INDEX_NONE &&
						AdditionalTarget.IsAlive() &&
						!AdditionalTarget.IsInStasis()) 
					{
						AdditionalTargets.AddItem(AdditionalTarget);
					}
				}
			}

			//	Cycle through filtered out targets and reduce damage dealt to this current target by the cumulitive amount of HP and Armor of all the units between the shooter and this current target
			for (i = 0; i < AdditionalTargets.Length; i++)
			{
				ReturnDamageValue.Damage -= AdditionalTargets[i].GetCurrentStat(eStat_HP);
				ReturnDamageValue.Damage -= AdditionalTargets[i].GetCurrentStat(eStat_ArmorMitigation); //	armor mitigates damage before being shredded
				////`LOG("Target adjust: " @ AdditionalTargets[i].GetFullName() @ ": " @ ReturnDamageValue.Damage, bLog, 'IRIROCK');
			}

			//	Then grab all the destructible objects between shooter and target. this includes ONLY things like cars and gas tanks, but not cover objects. (?)
			WorldData.CollectDestructiblesInTiles(Tiles, DestructibleActors);
			for (i = 0; i < DestructibleActors.Length; i++)
			{
				ReturnDamageValue.Damage -= int(DestructibleActors[i].Health / default.ENVIRONMENTAL_DAMAGE_MULTIPLIER);
				////`LOG("Destructible adjust: " @ ReturnDamageValue.Damage, bLog, 'IRIROCK');
				////`LOG("Destructible on the path, actor health: " @ DestructibleActors[i].Health, bLog, 'IRIROCK');
			}

			if (ReturnDamageValue.Damage <= 0) 
			{
				ReturnDamageValue.Damage = 0;
			}		
			//	clamp shred by damage
			if (ReturnDamageValue.Shred < ReturnDamageValue.Damage) 
			{
				ReturnDamageValue.Shred = ReturnDamageValue.Damage;
			}	
		}
	}
	////`LOG("Calculated target damage: " @ ReturnDamageValue.Damage, bLog, 'IRIROCK');
	return ReturnDamageValue;
}
*/
defaultproperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "X2Effect_SabotShell_Effect"
}