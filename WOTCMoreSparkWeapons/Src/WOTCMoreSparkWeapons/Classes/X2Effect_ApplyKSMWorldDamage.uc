class X2Effect_ApplyKSMWorldDamage extends X2Effect;

var int DamageAmount;
var bool bSkipGroundTiles;

//	Similar to X2Effect_ApplyDirectionalWorldDamage, but works even without target/multi target units.

simulated function ApplyEffectToWorld(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local XComGameStateContext_Ability		AbilityContext;
	local XComGameState_Unit				SourceUnit;
	local vector							TargetLocation;
	local XComGameState_EnvironmentDamage	DamageEvent;
	//local XComGameState_Item				ItemState;
	//local X2WeaponTemplate					WeaponTemplate;
	local XComWorldData						WorldData;
	local Vector							DamageDirection;
	local Vector							SourceLocation;
	local TTile								SourceTile, TargetTile;
	//local DestructibleTileData				DestructData;
	//local XComDestructibleActor				DestructActor;

	//`LOG("Applying world damage: start.",, 'WOTCMoreSparkWeapons');

	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
	if( AbilityContext != none && AbilityContext.InputContext.TargetLocations.Length > 0)
	{
		SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
		if (SourceUnit == none) return;

		WorldData = `XWORLD;

		SourceUnit.GetKeystoneVisibilityLocation(SourceTile);
		
		//	Convert Target Location to a tile and then backwards to "snap" it to the middle of the tile. Might be unnecesary, but better be safe.
		TargetLocation = AbilityContext.InputContext.TargetLocations[0];
		TargetTile = WorldData.GetTileCoordinatesFromPosition(TargetLocation);

		//	Raise height of the attack by 1 tile so we don't strike ground tiles.
		if (bSkipGroundTiles)
		{
			SourceTile.Z++;
			TargetTile.Z = SourceTile.Z;
		}
		SourceLocation = WorldData.GetPositionFromTileCoordinates(SourceTile);
		TargetLocation = WorldData.GetPositionFromTileCoordinates(TargetTile);

		//`LOG("Got context. Source location:" @ SourceLocation @ "Target location:" @ AbilityContext.InputContext.TargetLocations[0],, 'WOTCMoreSparkWeapons');

		DamageDirection = SourceLocation - TargetLocation;

		//`LOG("Damage direction:" @ DamageDirection,, 'WOTCMoreSparkWeapons');
		DamageDirection.Z = 0.0f;
		DamageDirection = Normal(DamageDirection);

		//`LOG("Normalized damage direction:" @ DamageDirection @ "Damage amount:" @ DamageAmount,, 'WOTCMoreSparkWeapons');
		
		DamageEvent = XComGameState_EnvironmentDamage(NewGameState.CreateNewStateObject(class'XComGameState_EnvironmentDamage'));
		DamageEvent.DEBUG_SourceCodeLocation = "UC: X2Effect_ApplyDirectionalWorldDamage:ApplyEffectToWorld";
		DamageEvent.DamageAmount = DamageAmount;
		DamageEvent.DamageTypeTemplateName = 'melee';
		DamageEvent.HitLocation = TargetLocation;
		DamageEvent.Momentum = DamageDirection;
		DamageEvent.DamageDirection = DamageDirection; //Limit environmental damage to the attack direction( ie. spare floors )
		DamageEvent.PhysImpulse = 100;
		DamageEvent.DamageRadius = 64;			
		DamageEvent.DamageCause = SourceUnit.GetReference();
		DamageEvent.DamageSource = DamageEvent.DamageCause;
		DamageEvent.bRadialDamage = true;
		DamageEvent.bAllowDestructionOfDamageCauseCover = true;

		DamageEvent.DamageTiles.AddItem(TargetTile);
		TargetTile.Z++;
		DamageEvent.DamageTiles.AddItem(TargetTile);
		TargetTile.Z++;
		DamageEvent.DamageTiles.AddItem(TargetTile);
	}
}