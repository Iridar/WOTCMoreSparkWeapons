class X2Ability_ArtilleryCannon extends X2Ability;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_FireArtilleryCannon_HEAT());
	Templates.AddItem(Create_FireArtilleryCannon_HE());
	Templates.AddItem(Create_FireArtilleryCannon_Shrapnel());

	Templates.AddItem(Create_FireArtilleryCannon_HEDP());
	Templates.AddItem(Create_FireArtilleryCannon_HESH());
	Templates.AddItem(Create_FireArtilleryCannon_Flechette());

	Templates.AddItem(Create_FireArtilleryCannon_HEAT_Passive());
	Templates.AddItem(Create_FireArtilleryCannon_AP_Passive());
	Templates.AddItem(Create_FireArtilleryCannon_Shrapnel_Passive());

	return Templates;
}

//	=============================================================
//			COMMON CODE
//	=============================================================

static function X2AbilityTemplate SetUpCannonShot(name TemplateName, bool bAllowDisoriented, optional name DamageTag, optional bool bExplosiveDamage = true, optional name RequiredItemName, optional bool bSkipLoSCondition)
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local array<name>                       SkipExclusions;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_Visibility            VisibilityCondition;
	local X2Effect_Shredder					DamageEffect;
	local X2Condition_RequiredItem			RequiredItem;
	//local X2Condition_UnitValue				UnitValueCondition;
	//local X2Effect_SetUnitValue				UnitValueEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_standard";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY;

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_WeaponIncompatible');
	Template.HideErrors.AddItem('AA_CannotAfford_AmmoCost');
	Template.HideErrors.AddItem('AA_CannotAfford_ActionPoints');
	Template.HideErrors.AddItem('AA_AbilityUnavailable');

	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.bDontDisplayInAbilitySummary = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	//	Targeting and Triggering
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';

	Template.AbilityToHitCalc = default.SimpleStandardAim;
	Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;

	//	Shooter Conditions

	//	If this shot requires a special shell to be loaded
	if (RequiredItemName != '')
	{
		RequiredItem = new class'X2Condition_RequiredItem';
		RequiredItem.ItemName = RequiredItemName;
		Template.AbilityShooterConditions.AddItem(RequiredItem);

		//UnitValueCondition = new class'X2Condition_UnitValue';
		//UnitValueCondition.AddCheckValue(RequiredItemName, 1,,,, 'AA_WeaponIncompatible');
		//Template.AbilityShooterConditions.AddItem(UnitValueCondition);

		//UnitValueEffect = new class'X2Effect_SetUnitValue';
		//UnitValueEffect.UnitName = RequiredItemName;
		//UnitValueEffect.CleanupType = eCleanup_BeginTurn;
		//UnitValueEffect.NewValueToSet = 0;
		//Template.AddShooterEffect(UnitValueEffect);
	}
	//else //	If not, then add a condition that this shot can't be used unless the special shell is loaded.
	//{
	//	UnitValueCondition = new class'X2Condition_UnitValue';
	//	UnitValueCondition.AddCheckValue('IRI_Shell_HE', 1,,,, 'AA_WeaponIncompatible');
	//	UnitValueCondition.AddCheckValue('IRI_Shell_AP', 1,,,, 'AA_WeaponIncompatible');
	//	UnitValueCondition.AddCheckValue('IRI_Shell_Shrapnel', 1,,,, 'AA_WeaponIncompatible');
	//	Template.AbilityShooterConditions.AddItem(UnitValueCondition);
	//}

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	if (bAllowDisoriented)
	{
		SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	}
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Ability Costs
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.bAddWeaponTypicalCost = true;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);	

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	//	Special cannon shots do not benefit from ammo bonuses
	Template.bAllowAmmoEffects = false;

	Template.bAllowBonusWeaponEffects = true;
	Template.bAllowFreeFireWeaponUpgrade = true; // Hair Trigger

	// Target Conditions
	if (DamageTag != 'NoPrimary')
	{
		// Can only shoot visible enemies
		if (!bSkipLoSCondition)
		{
			VisibilityCondition = new class'X2Condition_Visibility';
			VisibilityCondition.bRequireGameplayVisible = true;
			VisibilityCondition.bAllowSquadsight = true;
			Template.AbilityTargetConditions.AddItem(VisibilityCondition);
		}
		Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);		

		Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	
		DamageEffect = new class'X2Effect_Shredder';
		if (DamageTag != '') 
		{
			DamageEffect.DamageTag = DamageTag;
			DamageEffect.bIgnoreBaseDamage = true;
		}
		DamageEffect.bExplosiveDamage = bExplosiveDamage;
		Template.AddTargetEffect(DamageEffect);

		Template.AddTargetEffect(default.WeaponUpgradeMissDamage);	//	Stock compatibility	

		KnockbackEffect = new class'X2Effect_Knockback';
		KnockbackEffect.KnockbackDistance = 2;
		Template.AddTargetEffect(KnockbackEffect);
	}
	
	// Game State and Viz
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	Template.AlternateFriendlyNameFn = class'X2Ability_WeaponCommon'.static.StandardShot_AlternateFriendlyName;
	Template.bFrameEvenWhenUnitIsHidden = true;

	Template.AssociatedPassives.AddItem('HoloTargeting');
	Template.PostActivationEvents.AddItem('StandardShotActivated');

	return Template;	
}


//	=============================================================
//			NORMAL FIREMODE - AP SLUG
//	=============================================================

static function X2AbilityTemplate Create_FireArtilleryCannon_AP_Passive()
{
	local X2AbilityTemplate		Template;
	local X2Effect_SabotShell	SabotAmmo;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_FireArtilleryCannon_AP_Passive');

	SetPassive(Template);
	SetHidden(Template);
	Template.IconImage = "img:///IRIRestorativeMist.UI.UIPerk_Ammo_Sabot";
	Template.AbilitySourceName = 'eAbilitySource_Item';

	SabotAmmo = new class'X2Effect_SabotShell';
	SabotAmmo.BuildPersistentEffect(1, true);
	SabotAmmo.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(SabotAmmo);

	return Template;
}

//	=============================================================
//			HEAT AND HEDP
//	=============================================================

static function X2AbilityTemplate Create_FireArtilleryCannon_HEAT()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_Radius           MultiTargetRadius;
	local X2Effect_ApplyWeaponDamage			AreaDamage;
	local X2Effect_Knockback					KnockbackEffect;
		
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_HEAT', true, 'HEATDamage', true, 'IRI_Shell_HEAT');

	//	Icon Setup
	Template.IconImage = "img:///IRISparkHeavyWeapons.UI.Inv_HeavyAutgoun";

	//	Multi Target Effects
	AreaDamage = new class'X2Effect_Shredder';
	AreaDamage.DamageTag = 'HEATAreaDamage';
	AreaDamage.bIgnoreBaseDamage = true;
	AreaDamage.bApplyOnHit = true;
	AreaDamage.bApplyOnMiss = true;
	AreaDamage.EnvironmentalDamageAmount = 15;
	Template.AddMultiTargetEffect(AreaDamage);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddMultiTargetEffect(KnockbackEffect);

	//	Targeting and triggering
	Template.TargetingMethod = class'X2TargetingMethod_TopDown';

	MultiTargetRadius = new class'X2AbilityMultiTarget_Radius';
	MultiTargetRadius.fTargetRadius = 2.5f;
	Template.AbilityMultiTargetStyle = MultiTargetRadius;

	SetFireAnim(Template, 'FF_FireHEAT_Shell');

	Template.ModifyNewContextFn = HeatShot_ModifyActivatedAbilityContext;

	return Template;
}

static simulated function HeatShot_ModifyActivatedAbilityContext(XComGameStateContext Context)
{
	local XComGameStateHistory			History;
	local vector						NewLocation;
	local XComGameState_Ability			AbilityState;
	local AvailableTarget				Target;
	local XComGameStateContext_Ability	AbilityContext;

	History = `XCOMHISTORY;
	
	AbilityContext = XComGameStateContext_Ability(Context);

	//`LOG("Running Modify Context FN: " @ AbilityContext.IsResultContextMiss() @ AbilityContext.ResultContext.HitResult,, 'WOTCMoreSparkWeapons');

	if (AbilityContext.IsResultContextMiss())
	{
		//World = `XWORLD;
		//UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));

		NewLocation = class'X2Ability'.static.FindOptimalMissLocation(AbilityContext, false);

		//`LOG("This is a miss. Original location:" @ AbilityContext.InputContext.TargetLocations[0] @ AbilityContext.ResultContext.ProjectileHitLocations[0] @ ", new location:" @ NewLocation,, 'WOTCMoreSparkWeapons');

		AbilityState.GatherAdditionalAbilityTargetsForLocation(NewLocation, Target);
		AbilityContext.InputContext.MultiTargets = Target.AdditionalTargets;

		AbilityContext.InputContext.TargetLocations.Length = 0;
		AbilityContext.InputContext.TargetLocations.AddItem(NewLocation);

		AbilityContext.ResultContext.ProjectileHitLocations.Length = 0;
		AbilityContext.ResultContext.ProjectileHitLocations.AddItem(NewLocation);
	}
}

static function X2AbilityTemplate Create_FireArtilleryCannon_HEDP()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_Radius           MultiTargetRadius;
	local X2Effect_ApplyWeaponDamage			AreaDamage;
	local X2Effect_Knockback					KnockbackEffect;
		
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_HEDP', true, 'HEDPDamage', true, 'IRI_Shell_HEDP');

	//	Icon Setup
	Template.IconImage = "img:///IRISparkHeavyWeapons.UI.Inv_HeavyAutgoun";

	//	Multi Target Effects
	AreaDamage = new class'X2Effect_Shredder';
	AreaDamage.DamageTag = 'HEDPAreaDamage';
	AreaDamage.bIgnoreBaseDamage = true;
	AreaDamage.bApplyOnHit = true;
	AreaDamage.bApplyOnMiss = true;
	AreaDamage.EnvironmentalDamageAmount = 15;
	Template.AddMultiTargetEffect(AreaDamage);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddMultiTargetEffect(KnockbackEffect);

	//	Targeting and triggering
	Template.TargetingMethod = class'X2TargetingMethod_TopDown';

	MultiTargetRadius = new class'X2AbilityMultiTarget_Radius';
	MultiTargetRadius.fTargetRadius = 2.5f;
	Template.AbilityMultiTargetStyle = MultiTargetRadius;

	SetFireAnim(Template, 'FF_FireHEAT_Shell');

	Template.ModifyNewContextFn = HeatShot_ModifyActivatedAbilityContext;

	return Template;
}

static function X2AbilityTemplate Create_FireArtilleryCannon_HEAT_Passive()
{
	local X2AbilityTemplate		Template;
	local X2Effect_HeatShell	HeatShell;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_FireArtilleryCannon_HEAT_Passive');

	SetPassive(Template);
	SetHidden(Template);
	Template.IconImage = "img:///IRIRestorativeMist.UI.UIPerk_Ammo_Sabot";
	Template.AbilitySourceName = 'eAbilitySource_Item';

	HeatShell = new class'X2Effect_HeatShell';
	HeatShell.BuildPersistentEffect(1, true);
	HeatShell.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(HeatShell);

	return Template;
}

//	=============================================================
//			HE AND HESH
//	=============================================================

static function X2AbilityTemplate Create_FireArtilleryCannon_HE()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_Radius           MultiTargetRadius;
	local X2Effect_ApplyWeaponDamage			AreaDamage;
	local X2AbilityTarget_Cursor				CursorTarget;
	local X2Effect_Knockback					KnockbackEffect;

	//	Disallow disoriented, HESHDamage tag for the primary target damage, its explosive damage, requires shell item.
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_HE', false, 'NoPrimary', true, 'IRI_Shell_HE');

	Template.AbilityToHitCalc = default.DeadEye;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	//CursorTarget.bRestrictToWeaponRange = true;
	CursorTarget.FixedAbilityRange = `UNITSTOMETERS(`TILESTOUNITS(14));	// Feed range in tiles to this
	Template.AbilityTargetStyle = CursorTarget;

	//	Icon Setup
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_fanfire";

	//	Multi Target Effects
	AreaDamage = new class'X2Effect_Shredder';
	AreaDamage.DamageTag = 'HEAreaDamage';
	AreaDamage.bIgnoreBaseDamage = true;
	Template.AddMultiTargetEffect(AreaDamage);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddMultiTargetEffect(KnockbackEffect);
	
	//	Targeting and triggering
	Template.TargetingMethod = class'X2TargetingMethod_Grenade';

	MultiTargetRadius = new class'X2AbilityMultiTarget_Radius';
	MultiTargetRadius.fTargetRadius = 2.5f;
	Template.AbilityMultiTargetStyle = MultiTargetRadius;

	SetFireAnim(Template, 'FF_FireHE_Shell');

	return Template;
}

static function X2AbilityTemplate Create_FireArtilleryCannon_HESH()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_Radius           MultiTargetRadius;
	local X2Effect_ApplyWeaponDamage			AreaDamage;
	local X2AbilityTarget_Cursor				CursorTarget;
	local X2Effect_Knockback					KnockbackEffect;

	//	Disallow disoriented, HESHDamage tag for the primary target damage, its explosive damage, requires shell item.
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_HESH', false, 'HESHDamage', true, 'IRI_Shell_HESH');

	Template.AbilityToHitCalc = default.DeadEye;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	//CursorTarget.bRestrictToWeaponRange = true;
	CursorTarget.FixedAbilityRange = `UNITSTOMETERS(`TILESTOUNITS(18));	// Feed range in tiles to this
	Template.AbilityTargetStyle = CursorTarget;

	//	Icon Setup
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_fanfire";

	//	Multi Target Effects
	AreaDamage = new class'X2Effect_Shredder';
	AreaDamage.DamageTag = 'HESHAreaDamage';
	AreaDamage.bIgnoreBaseDamage = true;
	Template.AddMultiTargetEffect(AreaDamage);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddMultiTargetEffect(KnockbackEffect);
	
	//	Targeting and triggering
	Template.TargetingMethod = class'X2TargetingMethod_Grenade';

	MultiTargetRadius = new class'X2AbilityMultiTarget_Radius';
	MultiTargetRadius.fTargetRadius = 2.5f;
	Template.AbilityMultiTargetStyle = MultiTargetRadius;

	Template.ModifyNewContextFn = HESH_Shot_ModifyActivatedAbilityContext;

	SetFireAnim(Template, 'FF_FireHE_Shell');

	return Template;
}

static simulated function HESH_Shot_ModifyActivatedAbilityContext(XComGameStateContext Context)
{
	local XComWorldData					World;
	local array<StateObjectReference>	UnitsOnTile;
	local XComGameStateContext_Ability	AbilityContext;
	local TTile							TargetTile;
	local vector						TargetLocation;

	AbilityContext = XComGameStateContext_Ability(Context);

	World = `XWORLD;
	TargetLocation = AbilityContext.InputContext.TargetLocations[0];
	TargetTile = World.GetTileCoordinatesFromPosition(TargetLocation);
	UnitsOnTile = World.GetUnitsOnTile(TargetTile);

	if (UnitsOnTile.Length > 0)
	{
		AbilityContext.InputContext.PrimaryTarget = UnitsOnTile[0];
	}	
}

//	=============================================================
//			SHRAPNEL AND FLECHETTE
//	=============================================================

static function X2AbilityTemplate Create_FireArtilleryCannon_Shrapnel()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Cone         ConeMultiTarget;
	local X2Effect_ApplyWeaponDamage		AreaDamage;
	local X2Effect_Knockback				KnockbackEffect;
	local X2AbilityToHitCalc_StandardAim    StandardAim;

	//	Allow disoriented, skip primary target damage, reqires Shrapnel Shells
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_Shrapnel', true, 'NoPrimary',, 'IRI_Shell_Shrapnel');
	
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_shreddergun";
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bGuaranteedHit = true;
	Template.AbilityToHitCalc = StandardAim;
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = 5 * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = 15 * class'XComWorldData'.const.WORLD_StepSize;
	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	AreaDamage = new class'X2Effect_Shredder';
	AreaDamage.DamageTag = 'ShrapnelAreaDamage';
	AreaDamage.bIgnoreBaseDamage = true;
	Template.AddMultiTargetEffect(AreaDamage);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddMultiTargetEffect(KnockbackEffect);

	SetFireAnim(Template, 'FF_FireShrapnel_Shell');

	Template.ModifyNewContextFn = Shrapnel_Shot_ModifyActivatedAbilityContext;

	return Template;	
}

static function X2AbilityTemplate Create_FireArtilleryCannon_Shrapnel_Passive()
{
	local X2AbilityTemplate			Template;
	local X2Effect_ShrapnelShell	HeatShell;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_FireArtilleryCannon_Shrapnel_Passive');

	SetPassive(Template);
	SetHidden(Template);
	Template.IconImage = "img:///IRIRestorativeMist.UI.UIPerk_Ammo_Sabot";
	Template.AbilitySourceName = 'eAbilitySource_Item';

	HeatShell = new class'X2Effect_ShrapnelShell';
	HeatShell.BuildPersistentEffect(1, true);
	HeatShell.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(HeatShell);

	return Template;
}

static simulated function Shrapnel_Shot_ModifyActivatedAbilityContext(XComGameStateContext Context)
{
	local XComWorldData					World;
	local XComGameStateContext_Ability	AbilityContext;
	local XComGameState_Unit			UnitState;
	local TTile							ShooterTileLocation, TargetTileLocation;
	local vector						ShooterLocation;
	local XComGameStateHistory			History;
	local vector						ClosestLocation, TestLocation;
	local float							ClosestDistance, TestDistance;
	local int i;

	History = `XCOMHISTORY;
	World = `XWORLD;
	AbilityContext = XComGameStateContext_Ability(Context);

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	ShooterTileLocation = UnitState.TileLocation;
	ShooterTileLocation.Z += UnitState.UnitHeight - 1;
	ShooterLocation = World.GetPositionFromTileCoordinates(ShooterTileLocation);
	
	ClosestLocation = AbilityContext.InputContext.TargetLocations[0];
	ClosestDistance = VSize(ClosestLocation - ShooterLocation);

	for (i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++)
	{
		if (AbilityContext.IsResultContextMultiHit(i))
		{
			UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[i].ObjectID));

			TargetTileLocation = UnitState.TileLocation;
			TargetTileLocation.Z += UnitState.UnitHeight - 1;
			TestLocation = World.GetPositionFromTileCoordinates(TargetTileLocation);

			TestDistance = VSize(TestLocation - ShooterLocation);
			if (TestDistance < ClosestDistance)
			{
				ClosestDistance = TestDistance;
				ClosestLocation = TestLocation;
			}
		}
	}

	AbilityContext.InputContext.TargetLocations[0] = ClosestLocation;
}

static function X2AbilityTemplate Create_FireArtilleryCannon_Flechette()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Cone         ConeMultiTarget;
	local X2Effect_ApplyWeaponDamage		AreaDamage;
	local X2Effect_Knockback				KnockbackEffect;

	//	Allow disoriented, skip primary target damage, reqires Shrapnel Shells
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_Flechette', true, 'NoPrimary',, 'IRI_Shell_Flechette');
	
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_shreddergun";
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bIgnoreBlockingCover = false;
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = 5 * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = 15 * class'XComWorldData'.const.WORLD_StepSize;
	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	AreaDamage = new class'X2Effect_Shredder';
	AreaDamage.DamageTag = 'FlechetteAreaDamage';
	AreaDamage.bIgnoreBaseDamage = true;
	Template.AddMultiTargetEffect(AreaDamage);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddMultiTargetEffect(KnockbackEffect);

	SetFireAnim(Template, 'FF_FireShrapnel_Shell');

	return Template;	
}

//	=============================================================
//			UNUSED
//	=============================================================
//	Unused
/*
static function X2AbilityTemplate Create_FireArtilleryCannon_AP()
{
	local X2AbilityTemplate						Template;
	local X2Effect_ApplyDirectionalWorldDamage  WorldDamage;

	//local X2AbilityMultiTarget_Line				LineMultiTarget;
	//local X2Condition_UnitProperty				UnitPropertyCondition;
	//local X2Effect_ApplyWeaponDamage			AreaDamage;
	//local X2Condition_Visibility				VisibilityCondition;

	//	Allow disoriented, deal APDamage to primary target, not explosive damage, requires AP Shells
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_AP', true, 'APDamage', false, 'IRI_Shell_AP');

	//	Icon Setup
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snipershot";

	//VisibilityCondition = new class'X2Condition_Visibility';
	//VisibilityCondition.bVisibleToAnyAlly = true;
	//Template.AbilityTargetConditions.AddItem(VisibilityCondition);

		//	TODO: Reimplement this once custom multi target styles are a thing
		//LineMultiTarget = new class'X2AbilityMultiTarget_Line';
		//Template.AbilityMultiTargetStyle = LineMultiTarget;

		//	Make it damage only cover objects
		//UnitPropertyCondition = new class'X2Condition_UnitProperty';
		//UnitPropertyCondition.ExcludeDead = true;
		//UnitPropertyCondition.ExcludeAlive = true;
		//Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

		//AreaDamage = new class'X2Effect_ApplyWeaponDamage';
		//AreaDamage.bIgnoreBaseDamage = true;
		//AreaDamage.EnvironmentalDamageAmount = 10;
		//Template.AddMultiTargetEffect(AreaDamage);

	WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';
	WorldDamage.bUseWeaponDamageType = true;
	WorldDamage.bUseWeaponEnvironmentalDamage = false;
	WorldDamage.EnvironmentalDamageAmount = 30;
	WorldDamage.bApplyOnHit = true;
	WorldDamage.bApplyOnMiss = true;
	WorldDamage.bApplyToWorldOnHit = true;
	WorldDamage.bApplyToWorldOnMiss = true;
	WorldDamage.bHitAdjacentDestructibles = true;
	WorldDamage.PlusNumZTiles = 1;
	WorldDamage.bHitTargetTile = true;
	Template.AddTargetEffect(WorldDamage);

	return Template;
}*/
/*
static function X2AbilityTemplate Create_LoadSpecialShell(name TemplateName, name ShellType)
{
	local X2AbilityTemplate		Template;
	local X2Effect_SetUnitValue	UnitValueEffect;

	Template = class'X2Ability_DefaultAbilitySet'.static.AddReloadAbility(TemplateName);

	UnitValueEffect = new class'X2Effect_SetUnitValue';
	UnitValueEffect.UnitName = ShellType;
	UnitValueEffect.CleanupType = eCleanup_BeginTactical;
	UnitValueEffect.NewValueToSet = 1;
	Template.AddShooterEffect(UnitValueEffect);

	Template.DefaultKeyBinding = -1;

	return Template;
}*/

static function SetPassive(out X2AbilityTemplate Template)
{
	Template.bIsPassive = true;

	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;

	//	These are actually default for X2AbilityTemplate
	Template.bDisplayInUITacticalText = true;
	Template.bDisplayInUITooltip = true;
	Template.bDontDisplayInAbilitySummary = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.Hostility = eHostility_Neutral;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
}

static function SetHidden(out X2AbilityTemplate Template)
{
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.bDisplayInUITacticalText = false;
	Template.bDisplayInUITooltip = false;
	Template.bDontDisplayInAbilitySummary = true;
	Template.bHideOnClassUnlock = true;
}

static function SetFireAnim(out X2AbilityTemplate Template, name Anim)
{
	Template.CustomFireAnim = Anim;
	Template.CustomFireKillAnim = Anim;
	Template.CustomMovingFireAnim = Anim;
	Template.CustomMovingFireKillAnim = Anim;
	Template.CustomMovingTurnLeftFireAnim = Anim;
	Template.CustomMovingTurnLeftFireKillAnim = Anim;
	Template.CustomMovingTurnRightFireAnim = Anim;
	Template.CustomMovingTurnRightFireKillAnim = Anim;
}