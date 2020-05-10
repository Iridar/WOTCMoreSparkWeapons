class X2Action_FireJavelin extends X2Action_BlazingPinionsStage2;

//	Copied from the Rocket Launchers mod, but works differently, because we're firing at a location, not at a unit.

//	This function fires a projectile between two points
function AddProjectile()
{
	local XComWorldData					World;
	local vector						SourceLocation, ImpactLocation;
	local X2UnifiedProjectile			NewProjectile;
	local AnimNotify_FireWeaponVolley	FireVolleyNotify;

	World = `XWORLD;

	ImpactLocation = AbilityContext.InputContext.TargetLocations[0];
	SourceLocation = ImpactLocation;

	// Calculate the upper z position for the projectile
	// Move it above the top level of the world
	SourceLocation.Z = World.WORLD_FloorHeight * World.WORLD_FloorHeightsPerLevel * World.WORLD_TotalLevels;
		
	FireVolleyNotify = new class'AnimNotify_FireWeaponVolley';
	FireVolleyNotify.NumShots = 1;
	FireVolleyNotify.ShotInterval = 0.0f;

	NewProjectile = class'WorldInfo'.static.GetWorldInfo().Spawn(class'X2UnifiedProjectile', , , , , GetProjectile());
		
	NewProjectile.ConfigureNewProjectileCosmetic(FireVolleyNotify, AbilityContext, , , Unit.CurrentFireAction, SourceLocation, ImpactLocation, true);
	NewProjectile.GotoState('Executing');
}

//	Depending on the weapon tech of the Ordnance Launcher, fire different BIT projectiles.
function X2UnifiedProjectile GetProjectile()
{
	//	Appears other Bombard projectiles are fake.
	/*local X2WeaponTemplate	WeaponTemplate;

	WeaponTemplate = X2WeaponTemplate(SourceItemGameState.GetMyTemplate());

	if (WeaponTemplate != none)
	{
		switch (WeaponTemplate.WeaponTech)
		{
			case 'magnetic':
				return X2UnifiedProjectile(`CONTENT.RequestGameArchetype("DLC_3_WP_Bombard.PJ_Bombard_Bit_MG"));
			case 'beam':
				return X2UnifiedProjectile(`CONTENT.RequestGameArchetype("DLC_3_WP_Bombard.PJ_Bombard_Bit_BM"));
			case 'conventional':
			default:
				return X2UnifiedProjectile(`CONTENT.RequestGameArchetype("DLC_3_WP_Bombard.PJ_Bombard_Bit_CV"));
		}
	}*/
	return X2UnifiedProjectile(`CONTENT.RequestGameArchetype("DLC_3_WP_Bombard.PJ_Bombard_Bit_CV"));
}

simulated state Executing
{
Begin:
	Unit.CurrentFireAction = self;

	Sleep(GetDelayModifier());
	AddProjectile();

	while (!ProjectileHit)
	{
		Sleep(0.01f);
	}

	Sleep(0.5f * GetDelayModifier()); // Sleep to allow destruction to be seen

	CompleteAction();
}