class X2TargetingMethod_OrdnanceLauncher extends X2TargetingMethod_MECMicroMissile;

/*
function Init(AvailableAction InAction, int NewTargetIndex)
{
	local XComGameStateHistory History;
	local XComWeapon WeaponEntity;
	local PrecomputedPathData WeaponPrecomputedPathData;
	local float TargetingRange;
	local X2AbilityTarget_Cursor CursorTarget;
	local X2AbilityTemplate AbilityTemplate;

	super.Init(InAction, NewTargetIndex);

	GrenadePath = `PRECOMPUTEDPATH;
	GrenadePath.ClearOverrideTargetLocation(); // Clear this flag in case the grenade target location was locked.
	GrenadePath.ActivatePath(WeaponEntity, FiringUnit.GetTeam(), WeaponPrecomputedPathData);
	if( X2TargetingMethod_MECMicroMissile(self) != none )
	{
		//Explicit firing socket name for the Micro Missile, which is defaulted to gun_fire
		GrenadePath.SetFiringFromSocketPosition(name("gun_fire"));
	}
}
*/
/*
function GetGrenadeWeaponInfo(out XComWeapon WeaponEntity, out PrecomputedPathData WeaponPrecomputedPathData)
{
	local XComGameState_Item WeaponItem;
	local X2WeaponTemplate WeaponTemplate;
	local XGWeapon WeaponVisualizer;

	WeaponItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);
	WeaponTemplate = X2WeaponTemplate(WeaponItem.GetMyTemplate());
	WeaponVisualizer = XGWeapon(WeaponItem.GetVisualizer());

	// Tutorial Band-aid fix for missing visualizer due to cheat GiveItem
	if (WeaponVisualizer == none)
	{
		class'XGItem'.static.CreateVisualizer(WeaponItem);
		WeaponVisualizer = XGWeapon(WeaponItem.GetVisualizer());
		WeaponEntity = XComWeapon(WeaponVisualizer.CreateEntity(WeaponItem));

		if (WeaponEntity != none)
		{
			WeaponEntity.m_kPawn = FiringUnit.GetPawn();
		}
	}
	else
	{
		WeaponEntity = WeaponVisualizer.GetEntity();
	}

	WeaponPrecomputedPathData = WeaponTemplate.WeaponPrecomputedPathData;
}*/

defaultproperties
{
	OrdnanceTypeName="Ordnance_Grenade"
}