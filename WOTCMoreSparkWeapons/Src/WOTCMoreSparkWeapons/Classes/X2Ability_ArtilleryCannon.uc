class X2Ability_ArtilleryCannon extends X2Ability;
/*
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	//	Heavy Weapon: Autogun
	Templates.AddItem(Create_FireArtilleryCannon_HEAT());
	Templates.AddItem(Create_FireArtilleryCannon_HE());
	Templates.AddItem(Create_FireArtilleryCannon_AP());
	Templates.AddItem(Create_FireArtilleryCannon_Shrapnel());

	return Templates;
}
*/
static function X2AbilityTemplate SetUpCannonShot(name TemplateName, bool bAllowDisoriented, optional name DamageTag, optional bool bExplosiveDamage = true)
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local array<name>                       SkipExclusions;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_Visibility            VisibilityCondition;
	local X2Effect_Shredder					DamageEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_standard";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
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
	
	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;
	Template.bAllowFreeFireWeaponUpgrade = true; // Hair Trigger

	// Target Conditions
	if (DamageTag != 'NoPrimary')
	{
		// Can only shoot visible enemies
		VisibilityCondition = new class'X2Condition_Visibility';
		VisibilityCondition.bRequireGameplayVisible = true;
		VisibilityCondition.bAllowSquadsight = true;
		Template.AbilityTargetConditions.AddItem(VisibilityCondition);
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

static function X2AbilityTemplate Create_FireArtilleryCannon_HEAT()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_Radius           MultiTargetRadius;
	local X2Effect_ApplyWeaponDamage			AreaDamage;

	Template = SetUpCannonShot('IRI_FireArtilleryCannon_HEAT', true);

	//	Icon Setup
	Template.IconImage = "img:///IRISparkHeavyWeapons.UI.Inv_HeavyAutgoun";

	//	Multi Target Effects
	AreaDamage = new class'X2Effect_Shredder';
	AreaDamage.DamageTag = 'HEATAreaDamage';
	AreaDamage.bIgnoreBaseDamage = true;
	AreaDamage.bApplyOnHit = true;
	AreaDamage.bApplyOnMiss = true;
	Template.AddMultiTargetEffect(AreaDamage);
	
	//	Targeting and triggering
	//Template.TargetingMethod = class'X2TargetingMethod_HeatShot';
	Template.TargetingMethod = class'X2TargetingMethod_TopDown';

	MultiTargetRadius = new class'X2AbilityMultiTarget_Radius';
	MultiTargetRadius.fTargetRadius = 2.5f;
	Template.AbilityMultiTargetStyle = MultiTargetRadius;

	//Template.ModifyNewContextFn = HeatShot_ModifyActivatedAbilityContext;

	return Template;
}

static function X2AbilityTemplate Create_FireArtilleryCannon_HE()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_Radius           MultiTargetRadius;
	local X2Effect_ApplyWeaponDamage			AreaDamage;
	local X2AbilityTarget_Cursor				CursorTarget;
	local X2Effect_Knockback					KnockbackEffect;

	Template = SetUpCannonShot('IRI_FireArtilleryCannon_HE', false, 'HESHDamage');

	Template.AbilityToHitCalc = default.DeadEye;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	//CursorTarget.bRestrictToWeaponRange = true;
	CursorTarget.FixedAbilityRange = `UNITSTOMETERS(`TILESTOUNITS(25));	// Feed range in tiles to this
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

	Template.ModifyNewContextFn = HE_Shot_ModifyActivatedAbilityContext;

	return Template;
}

static simulated function HE_Shot_ModifyActivatedAbilityContext(XComGameStateContext Context)
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

static function X2AbilityTemplate Create_FireArtilleryCannon_AP()
{
	local X2AbilityTemplate						Template;

	Template = SetUpCannonShot('IRI_FireArtilleryCannon_AP', true, 'APDamage', false);

	//	Icon Setup
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snipershot";

	return Template;
}

static function X2AbilityTemplate Create_FireArtilleryCannon_Shrapnel()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Cone         ConeMultiTarget;
	local X2Effect_ApplyWeaponDamage		AreaDamage;
	local X2Effect_Knockback				KnockbackEffect;

	Template = SetUpCannonShot('IRI_FireArtilleryCannon_Shrapnel', true, 'NoPrimary', false);
	
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_shreddergun";
	
	Template.AbilityToHitCalc = default.DeadEye;
	
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

	return Template;	
}

/*
static simulated function HeatShot_ModifyActivatedAbilityContext(XComGameStateContext Context)
{
	//local XComGameState_Unit			UnitState;
	//local XComWorldData					World;
	//local int							bHit;
	local XComGameStateHistory			History;
	local vector						NewLocation;
	local XComGameState_Ability			AbilityState;
	local AvailableTarget				Target;
	local XComGameStateContext_Ability	AbilityContext;

	History = `XCOMHISTORY;
	
	AbilityContext = XComGameStateContext_Ability(Context);

	`LOG("Running Modify Context FN: " @ AbilityContext.IsResultContextMiss() @ AbilityContext.ResultContext.HitResult,, 'WOTCMoreSparkWeapons');

	if (AbilityContext.IsResultContextMiss())
	{
		//World = `XWORLD;
		//UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));

		NewLocation = class'X2Ability'.static.FindOptimalMissLocation(AbilityContext, false);

		`LOG("This is a miss. Original location:" @ AbilityContext.InputContext.TargetLocations[0] @ AbilityContext.ResultContext.ProjectileHitLocations[0] @ ", new location:" @ NewLocation,, 'WOTCMoreSparkWeapons');

		AbilityState.GatherAdditionalAbilityTargetsForLocation(NewLocation, Target);
		AbilityContext.InputContext.MultiTargets = Target.AdditionalTargets;

		AbilityContext.InputContext.TargetLocations.Length = 0;
		AbilityContext.InputContext.TargetLocations.AddItem(NewLocation);

		AbilityContext.ResultContext.ProjectileHitLocations.Length = 0;
		AbilityContext.ResultContext.ProjectileHitLocations.AddItem(NewLocation);
	}
}
*/