class X2UnifiedProjectile_HEAT extends X2UnifiedProjectile;

var array<int> ProjectileIndexPatched;

function FireProjectileInstance(int Index)
{
	local XGUnit TargetVisualizer;
	

	super.FireProjectileInstance(Index);

	if (ProjectileIndexPatched.Find(Index) != INDEX_NONE)
	{
		return;
	}

	TargetVisualizer = XGUnit(`XCOMHISTORY.GetVisualizer(AbilityContextPrimaryTargetID));

	if (Projectiles[Index].GrenadePath != none && Projectiles[Index].GrenadePath.iNumKeyframes > 0 && TargetVisualizer != none)
	{
		`LOG("==================== BEGIN ==============================",, 'SmartRounds');

		//Projectiles[Index].GrenadePath.SetWeaponAndTargetLocation(SourceWeapon, Projectiles[Index].GrenadePath.eComputePathForTeam, TargetVisualizer.GetTargetingFocusLocation(), WeaponTemplate.WeaponPrecomputedPathData);
		//Projectiles[Index].GrenadePath.bUseOverrideTargetLocation = true;
		//Projectiles[Index].GrenadePath.OverrideTargetLocation = TargetVisualizer.GetTargetingFocusLocation();
		//Projectiles[Index].GrenadePath.UpdateTrajectory();

		AdjustGrenadePath(Projectiles[Index].GrenadePath, TargetVisualizer.GetTargetingFocusLocation());

		//`LOG(default.class @ GetFuncName() @ Projectiles[Index].GrenadePath.ToString(),, 'SmartRounds');
	}

	`LOG("==================== END ==============================",, 'SmartRounds');

	ProjectileIndexPatched.AddItem(Index);
}

private function AdjustGrenadePath(XComPrecomputedPath GrenadePath, vector TargetLocation)
{
	local vector vDif;
	local int iKeyframes;
	local int i;
	local float Alpha;

	iKeyframes = GrenadePath.iNumKeyframes;
	vDif = TargetLocation - GrenadePath.akKeyframes[iKeyframes - 1].vLoc;
		
	for (i = 0; i < iKeyframes; i++)
	{	
		Alpha = float(i) / float(iKeyframes);
		//`LOG("Old frame:" @ i @ "out of:" @ iKeyframes @ "Alpha:" @ Alpha @ "____" @ GrenadePath.akKeyframes[i].vLoc @ GrenadePath.akKeyframes[i].fTime,, 'SmartRounds');			
		GrenadePath.akKeyframes[i].vLoc += vDif * Alpha;
		//`LOG("New frame:" @ i @ "out of:" @ iKeyframes @ "Alpha:" @ Alpha @ "____" @ GrenadePath.akKeyframes[i].vLoc @ GrenadePath.akKeyframes[i].fTime,, 'SmartRounds');		
	}
}


/*
struct native XKeyframe
{
	var float   fTime;
	var Vector  vLoc;
	var Rotator rRot;
	var bool bValid;
};
*/

function FireProjectileInstance12331231(int Index)
{
	local int KeyFrameIndex, /*NewIndex,*/ TempKeyFrameIndex;
	//local vector NextFrameLoc;
	local XComPrecomputedPath GrenadePath;
	local XGUnit TargetVisualizer;
	local float TimeStart, TimeEnd, Alpha;
	local array<XKeyframe> NewKeyFrames;
	local XKeyframe Keyframe;

	super.FireProjectileInstance(Index);

	if (ProjectileIndexPatched.Find(Index) != INDEX_NONE)
	{
		return;
	}

	TargetVisualizer = XGUnit(`XCOMHISTORY.GetVisualizer(AbilityContextPrimaryTargetID));

	`LOG(default.class @ GetFuncName() @ Index @ Projectiles[Index].GrenadePath,, 'SmartRounds');

	if (Projectiles[Index].GrenadePath != none)
	{
		`LOG(default.class @ GetFuncName() @ Projectiles[Index].GrenadePath.ToString(),, 'SmartRounds');

		for (KeyFrameIndex = 0; KeyFrameIndex < Projectiles[Index].GrenadePath.iNumKeyframes * 0.65; KeyFrameIndex++)
		{
			NewKeyFrames.AddItem(Projectiles[Index].GrenadePath.akKeyframes[KeyFrameIndex]);
		}

		GrenadePath = `PRECOMPUTEDPATH_SINGLEPROJECTILE;
		GrenadePath.ForceRebuildGrenadePath();
		GrenadePath.bUseOverrideSourceLocation = true;
		GrenadePath.OverrideSourceLocation = Projectiles[Index].GrenadePath.akKeyframes[KeyFrameIndex].vLoc;

		GrenadePath.bUseOverrideTargetLocation = true;
		GrenadePath.OverrideTargetLocation = Projectiles[Index].GrenadePath.akKeyframes[Projectiles[Index].GrenadePath.iNumKeyframes - 1].vLoc;
		GrenadePath.SetupPath(SourceWeapon, TargetVisualizer.GetTeam(), WeaponTemplate.WeaponPrecomputedPathData);
		GrenadePath.UpdateTrajectory();

		if (GrenadePath.iNumKeyframes > 0)
		{
			`LOG(default.class @ GetFuncName() @ "Removed" @ Projectiles[Index].GrenadePath.iNumKeyframes * 0.35 @ "keyframes from BlasterLauncher path",, 'SmartRounds');
			`LOG(default.class @ GetFuncName() @ "Adding" @ GrenadePath.iNumKeyframes @ "keyframes from grenade path",, 'SmartRounds');

			TimeStart = Projectiles[Index].GrenadePath.akKeyframes[KeyFrameIndex].fTime;
			TimeEnd = Projectiles[Index].GrenadePath.akKeyframes[Projectiles[Index].GrenadePath.iNumKeyframes - 1].fTime;

			for (TempKeyFrameIndex = 0; TempKeyFrameIndex < GrenadePath.iNumKeyframes; TempKeyFrameIndex++)
			{
				Alpha = float(TempKeyFrameIndex + 1) / float(GrenadePath.iNumKeyframes);
				GrenadePath.akKeyframes[TempKeyFrameIndex].fTime = Lerp(TimeStart, TimeEnd, Alpha);
				//`LOG(default.class @ GetFuncName() @ Alpha @ GrenadePath.akKeyframes[TempKeyFrameIndex].fTime,, 'SmartRounds');
				NewKeyFrames.AddItem(GrenadePath.akKeyframes[TempKeyFrameIndex]);
			}

			foreach NewKeyFrames(Keyframe, KeyFrameIndex)
			{
				Projectiles[Index].GrenadePath.akKeyframes[KeyFrameIndex] = Keyframe;
			}
			Projectiles[Index].GrenadePath.iNumKeyframes = NewKeyFrames.Length;
		}

		//NewKeyFrames.AddItem(Projectiles[Index].GrenadePath.akKeyframes[Projectiles[Index].GrenadePath.iNumKeyframes - 1]);

		`LOG(default.class @ GetFuncName() @ Projectiles[Index].GrenadePath.ToString(),, 'SmartRounds');
	}

	`LOG(default.class @ GetFuncName() @ Index @ "--------------------------------------",, 'SmartRounds');

	ProjectileIndexPatched.AddItem(Index);
}
