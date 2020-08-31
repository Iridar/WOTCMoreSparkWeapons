class X2Ability_ArtilleryCannon extends X2Ability config (ArtilleryCannon);

`define SWITCHACTIONS(NEWACTION, OLDACTION) VisualizationMgr.ConnectAction(`NEWACTION, VisualizationMgr.BuildVisTree, true, `OLDACTION); VisualizationMgr.DisconnectAction(`NEWACTION); VisualizationMgr.ConnectAction(`NEWACTION, VisualizationMgr.BuildVisTree,,, `OLDACTION.ParentActions); VisualizationMgr.DisconnectAction(`OLDACTION)

var config float HEAT_Area_Radius_Meters;
var config float HEDP_Area_Radius_Meters;

var config float HE_Area_Radius_Meters;
var config int HE_Range_Tiles;

var config float HESH_Area_Radius_Meters;
var config int HESH_Range_Tiles;

var config int Shrapnel_Cone_Length_Tiles;
var config int Shrapnel_Cone_Width_Tiles;

var config int Flechette_Cone_Length_Tiles;
var config int Flechette_Cone_Width_Tiles;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local X2AbilityTemplate		Template;

	Templates.AddItem(Create_FireArtilleryCannon_HEAT());
	Templates.AddItem(Create_FireArtilleryCannon_HE());
	Templates.AddItem(Create_FireArtilleryCannon_Shrapnel());

	Templates.AddItem(Create_FireArtilleryCannon_HEDP());
	Templates.AddItem(Create_FireArtilleryCannon_HESH());
	Templates.AddItem(Create_FireArtilleryCannon_Flechette());

	Templates.AddItem(Create_FireArtilleryCannon_HEAT_Passive());
	Templates.AddItem(Create_FireArtilleryCannon_AP_Passive());
	Templates.AddItem(Create_FireArtilleryCannon_Shrapnel_Passive());

	//	Set of dummy abilities used for icon in tactical to remind the player about shells equipped.
	//	Oh the fire and brimstone that will rain on anyone creating an ablity template outside a separate function!..
	Template = PurePassive('IRI_Shell_HEAT_Passive', "img:///IRIArtilleryCannon.UI.UIPerk_FireHEAT", false, 'eAbilitySource_Item', true);
	SetHidden(Template);
	Templates.AddItem(Template);

	Template = PurePassive('IRI_Shell_HEDP_Passive', "img:///IRIArtilleryCannon.UI.UIPerk_FireHEAT", false, 'eAbilitySource_Item', true);
	SetHidden(Template);
	Templates.AddItem(Template);

	Template = PurePassive('IRI_Shell_HE_Passive', "img:///IRIArtilleryCannon.UI.UIPerk_FireHE", false, 'eAbilitySource_Item', true);
	SetHidden(Template);
	Templates.AddItem(Template);

	Template = PurePassive('IRI_Shell_HESH_Passive', "img:///IRIArtilleryCannon.UI.UIPerk_FireHE", false, 'eAbilitySource_Item', true);
	SetHidden(Template);
	Templates.AddItem(Template);

	Template = PurePassive('IRI_Shell_Shrapnel_Passive', "img:///IRIArtilleryCannon.UI.UIPerk_FireShrapnel", false, 'eAbilitySource_Item', true);
	SetHidden(Template);
	Templates.AddItem(Template);

	Template = PurePassive('IRI_Shell_Flechette_Passive', "img:///IRIArtilleryCannon.UI.UIPerk_FireShrapnel", false, 'eAbilitySource_Item', true);
	SetHidden(Template);
	Templates.AddItem(Template);

	return Templates;
}

//	=============================================================
//			COMMON CODE
//	=============================================================

static function X2AbilityTemplate SetUpCannonShot(name TemplateName, bool bAllowDisoriented, optional name DamageTag, optional bool bExplosiveDamage = true, optional bool bSkipLoSCondition)
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local array<name>                       SkipExclusions;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_Visibility            VisibilityCondition;
	local X2Effect_Shredder					DamageEffect;
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
	
	//	Special cannon shots still benefit from ammo bonuses
	//	Requires Mr.Nice's Weapon Fixes mod and config for it.
	Template.bAllowAmmoEffects = true;

	//	Do not apply bonus weapon effects; the bonus effect for artillery cannons is destroying target's cover, it's only valid for the default firemode,
	//	and with Weapon Fixes mod could lead to stupid interactions, like shrapnel shells destroying targets' cover.
	Template.bAllowBonusWeaponEffects = false;
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
	Template.BuildNewGameStateFn = MrNice_WeaponFixes_BuildNewGameState;
	Template.BuildVisualizationFn = MrNice_WeaponFixes_BuildVisualization;	
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealShotMax;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.HeavyWeaponLostSpawnIncreasePerUse;

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
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///IRIArtilleryCannon.UI.UIPerk_FireCannon";
	Template.AbilitySourceName = 'eAbilitySource_Item';

	SabotAmmo = new class'X2Effect_SabotShell';
	SabotAmmo.BuildPersistentEffect(1, true);
	SabotAmmo.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(SabotAmmo);

	return Template;
}

/*
// Issue #200 Start, allow listeners to modify environment damage
ModifyEnvironmentDamageTuple = new class'XComLWTuple';
ModifyEnvironmentDamageTuple.Id = 'ModifyEnvironmentDamage';
ModifyEnvironmentDamageTuple.Data.Add(3);
ModifyEnvironmentDamageTuple.Data[0].kind = XComLWTVBool;
ModifyEnvironmentDamageTuple.Data[0].b = false;  // override? (true) or add? (false)
ModifyEnvironmentDamageTuple.Data[1].kind = XComLWTVInt;
ModifyEnvironmentDamageTuple.Data[1].i = 0;  // override/bonus environment damage
ModifyEnvironmentDamageTuple.Data[2].kind = XComLWTVObject;
ModifyEnvironmentDamageTuple.Data[2].o = AbilityStateObject;  // ability being used

`XEVENTMGR.TriggerEvent('ModifyEnvironmentDamage', ModifyEnvironmentDamageTuple, self, NewGameState);
*/

static function EventListenerReturn ModifyEnvironmenDamage_Listener(Object EventData, Object EventSource, XComGameState GameState, name InEventID, Object CallbackData)
{
	local XComLWTuple				ModifyEnvironmentDamageTuple;
	local XComGameState_Ability		AbilityState;
	local XComGameState_Item		SourceWeapon;
	local X2WeaponTemplate			WeaponTemplate;

	ModifyEnvironmentDamageTuple = XComLWTuple(EventData);
	if (ModifyEnvironmentDamageTuple == none)
		return ELR_NoInterrupt;

	AbilityState = XComGameState_Ability(ModifyEnvironmentDamageTuple.Data[2].o);
	if (AbilityState == none)
		return ELR_NoInterrupt;

	switch (AbilityState.GetMyTemplateName())
	{
		case 'IRI_FireArtilleryCannon_HEAT':
		case 'IRI_FireArtilleryCannon_HE':
		//case 'IRI_FireArtilleryCannon_Shrapnel':
		case 'IRI_FireArtilleryCannon_HEDP':
		case 'IRI_FireArtilleryCannon_HESH':
		//case 'IRI_FireArtilleryCannon_Flechette':
			break;
		default:
			return ELR_NoInterrupt;
	}

	SourceWeapon = AbilityState.GetSourceWeapon();
	if (SourceWeapon == none)
		return ELR_NoInterrupt;

	WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());

	if (WeaponTemplate == none)
		return ELR_NoInterrupt;

	//	by default, the abilities from the list above deal 0 environmental damage, because their apply weapon damage effect is set to ignore base damage.
	//	So we simply add weapon's normal environmental damage.
	//`LOG("Adding base environment damage to ability:" @ AbilityState.GetMyTemplateName() @ WeaponTemplate.iEnvironmentDamage,, 'IRITEST');
	ModifyEnvironmentDamageTuple.Data[1].i += WeaponTemplate.iEnvironmentDamage;
	
    return ELR_NoInterrupt;
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
	local X2Condition_RequiredItem				RequiredItem;
		
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_HEAT', true, 'HEATDamage', true);

	//	Icon Setup
	Template.IconImage = "img:///IRIArtilleryCannon.UI.UIPerk_FireHEAT";

	//	Shooter Conditions
	RequiredItem = new class'X2Condition_RequiredItem';
	RequiredItem.ItemNames.AddItem('IRI_Shell_HEAT');
	RequiredItem.ItemNames.AddItem('IRI_Shells_T1');
	Template.AbilityShooterConditions.AddItem(RequiredItem);
	

	//	Multi Target Effects
	AreaDamage = new class'X2Effect_Shredder';
	AreaDamage.DamageTag = 'HEATAreaDamage';
	AreaDamage.bIgnoreBaseDamage = true;
	AreaDamage.bApplyOnHit = true;
	AreaDamage.bApplyOnMiss = true;
	Template.AddMultiTargetEffect(AreaDamage);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddMultiTargetEffect(KnockbackEffect);

	//	Targeting and triggering
	Template.TargetingMethod = class'X2TargetingMethod_TopDown';

	MultiTargetRadius = new class'X2AbilityMultiTarget_Radius';
	MultiTargetRadius.fTargetRadius = default.HEAT_Area_Radius_Meters;
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
	local X2Condition_RequiredItem				RequiredItem;
		
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_HEDP', true, 'HEDPDamage', true);

	//	Icon Setup
	Template.IconImage = "img:///IRIArtilleryCannon.UI.UIPerk_FireHEAT";

	//	Shooter Conditions
	RequiredItem = new class'X2Condition_RequiredItem';
	RequiredItem.ItemNames.AddItem('IRI_Shell_HEDP');
	RequiredItem.ItemNames.AddItem('IRI_Shells_T2');
	Template.AbilityShooterConditions.AddItem(RequiredItem);

	//	Multi Target Effects
	AreaDamage = new class'X2Effect_Shredder';
	AreaDamage.DamageTag = 'HEDPAreaDamage';
	AreaDamage.bIgnoreBaseDamage = true;
	AreaDamage.bApplyOnHit = true;
	AreaDamage.bApplyOnMiss = true;
	Template.AddMultiTargetEffect(AreaDamage);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddMultiTargetEffect(KnockbackEffect);

	//	Targeting and triggering
	Template.TargetingMethod = class'X2TargetingMethod_TopDown';

	MultiTargetRadius = new class'X2AbilityMultiTarget_Radius';
	MultiTargetRadius.fTargetRadius = default.HEDP_Area_Radius_Meters;
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
	Template.IconImage = "img:///IRIArtilleryCannon.UI.UIPerk_FireHEAT";
	Template.AbilitySourceName = 'eAbilitySource_Item';

	HeatShell = new class'X2Effect_HeatShell';
	HeatShell.BuildPersistentEffect(1, true);
	HeatShell.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);
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
	local X2Condition_RequiredItem				RequiredItem;

	//	Disallow disoriented, HESHDamage tag for the primary target damage, its explosive damage, requires shell item.
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_HE', false, 'NoPrimary', true);

	Template.AbilityToHitCalc = default.DeadEye;

	//	Shooter Conditions
	RequiredItem = new class'X2Condition_RequiredItem';
	RequiredItem.ItemNames.AddItem('IRI_Shell_HE');
	RequiredItem.ItemNames.AddItem('IRI_Shells_T1');
	Template.AbilityShooterConditions.AddItem(RequiredItem);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	//CursorTarget.bRestrictToWeaponRange = true;
	CursorTarget.FixedAbilityRange = `UNITSTOMETERS(`TILESTOUNITS(default.HE_Range_Tiles));	// Feed range in tiles to this
	Template.AbilityTargetStyle = CursorTarget;

	//	Icon Setup
	Template.IconImage = "img:///IRIArtilleryCannon.UI.UIPerk_FireHE";

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
	MultiTargetRadius.fTargetRadius = default.HE_Area_Radius_Meters;
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
	local X2Condition_RequiredItem				RequiredItem;

	//	Disallow disoriented, HESHDamage tag for the primary target damage, its explosive damage, requires shell item.
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_HESH', false, 'HESHDamage', true);

	Template.AbilityToHitCalc = default.DeadEye;

	//	Shooter Conditions
	RequiredItem = new class'X2Condition_RequiredItem';
	RequiredItem.ItemNames.AddItem('IRI_Shell_HESH');
	RequiredItem.ItemNames.AddItem('IRI_Shells_T2');
	Template.AbilityShooterConditions.AddItem(RequiredItem);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	//CursorTarget.bRestrictToWeaponRange = true;
	CursorTarget.FixedAbilityRange = `UNITSTOMETERS(`TILESTOUNITS(default.HESH_Range_Tiles));	// Feed range in tiles to this
	Template.AbilityTargetStyle = CursorTarget;

	//	Icon Setup
	Template.IconImage = "img:///IRIArtilleryCannon.UI.UIPerk_FireHE";

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
	MultiTargetRadius.fTargetRadius = default.HESH_Area_Radius_Meters;
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
	local X2Condition_RequiredItem			RequiredItem;

	//	Allow disoriented, skip primary target damage, reqires Shrapnel Shells
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_Shrapnel', true, 'NoPrimary');

	//	Shooter Conditions
	RequiredItem = new class'X2Condition_RequiredItem';
	RequiredItem.ItemNames.AddItem('IRI_Shell_Shrapnel');
	RequiredItem.ItemNames.AddItem('IRI_Shells_T1');
	Template.AbilityShooterConditions.AddItem(RequiredItem);
	
	Template.IconImage = "img:///IRIArtilleryCannon.UI.UIPerk_FireShrapnel";
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bGuaranteedHit = true;
	Template.AbilityToHitCalc = StandardAim;
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = default.Shrapnel_Cone_Width_Tiles * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = default.Shrapnel_Cone_Length_Tiles * class'XComWorldData'.const.WORLD_StepSize;
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
	Template.IconImage = "img:///IRIArtilleryCannon.UI.UIPerk_FireShrapnel";
	Template.AbilitySourceName = 'eAbilitySource_Item';

	HeatShell = new class'X2Effect_ShrapnelShell';
	HeatShell.BuildPersistentEffect(1, true);
	HeatShell.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,, Template.AbilitySourceName);
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
	local X2Condition_RequiredItem			RequiredItem;

	//	Allow disoriented, skip primary target damage, reqires Shrapnel Shells
	Template = SetUpCannonShot('IRI_FireArtilleryCannon_Flechette', true, 'NoPrimary');

	//	Shooter Conditions
	RequiredItem = new class'X2Condition_RequiredItem';
	RequiredItem.ItemNames.AddItem('IRI_Shell_Flechette');
	RequiredItem.ItemNames.AddItem('IRI_Shells_T2');
	Template.AbilityShooterConditions.AddItem(RequiredItem);
	
	Template.IconImage = "img:///IRIArtilleryCannon.UI.UIPerk_FireShrapnel";
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bIgnoreBlockingCover = false;
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = default.Flechette_Cone_Width_Tiles * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = default.Flechette_Cone_Length_Tiles * class'XComWorldData'.const.WORLD_StepSize;
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

//	================================
//	Copied from [WotC] Weapon Fixes https://steamcommunity.com/sharedfiles/filedetails/?id=1737532501 by Mr.Nice
//	Could not obtain permission since he's no longer active, but he made code for my mods before, I don't think he would mind.

function XComGameState MrNice_WeaponFixes_BuildNewGameState(XComGameStateContext Context)
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_Ability ShootAbilityState;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameStateContext_Ability AbilityContext;
	local int TargetIndex;	

	local XComGameState_BaseObject AffectedTargetObject_OriginalState;	
	local XComGameState_BaseObject AffectedTargetObject_NewState;
	local XComGameState_BaseObject SourceObject_OriginalState;
	local XComGameState_Item       SourceWeapon, SourceWeapon_NewState;
	local X2AmmoTemplate           AmmoTemplate;
	local X2WeaponTemplate         WeaponTemplate;
	local EffectResults            MultiTargetEffectResults;
	local bool ApplyAmmo, ApplyWeapon;

	NewGameState = TypicalAbility_BuildGameState(Context);
	//Build the new game state frame, and unit state object for the acting unit
	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
	if (AbilityContext.InputContext.MultiTargets.Length == 0) return NewGameState;

	History = `XCOMHISTORY;	
	ShootAbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));	
	AbilityTemplate = ShootAbilityState.GetMyTemplate();
	//`log("Weapon fixes started to build gamestate for " $ AbilityTemplate.LocFriendlyName $ "(" $ string(AbilityTemplate.DataName) $ ")");
	//`log(`showvar(BaseGameStateFn));
	SourceWeapon = ShootAbilityState.GetSourceWeapon();
	
	if (SourceWeapon != none)
	{
		SourceWeapon_NewState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', SourceWeapon.ObjectID));
	}
	if (SourceWeapon_NewState == none)
		return NewGameState;

	ShootAbilityState = XComGameState_Ability(NewGameState.ModifyStateObject(ShootAbilityState.Class, ShootAbilityState.ObjectID));

	if (AbilityTemplate.bAllowAmmoEffects && SourceWeapon_NewState.HasLoadedAmmo())
	{
		AmmoTemplate = X2AmmoTemplate(SourceWeapon_NewState.GetLoadedAmmoTemplate(ShootAbilityState));
		ApplyAmmo = AmmoTemplate != none && AmmoTemplate.TargetEffects.Length != 0;
	}

	if (AbilityTemplate.bAllowBonusWeaponEffects)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon_NewState.GetMyTemplate());
		ApplyWeapon = WeaponTemplate != none && WeaponTemplate.BonusWeaponEffects.Length != 0;
	}

	if (ApplyAmmo || ApplyWeapon)
	{
		SourceObject_OriginalState = History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID);	

		for( TargetIndex = 0; TargetIndex < AbilityContext.InputContext.MultiTargets.Length; ++TargetIndex )
		{
			AffectedTargetObject_OriginalState = History.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[TargetIndex].ObjectID, eReturnType_Reference);
			AffectedTargetObject_NewState = NewGameState.ModifyStateObject(AffectedTargetObject_OriginalState.Class, AbilityContext.InputContext.MultiTargets[TargetIndex].ObjectID);

			MultiTargetEffectResults = AbilityContext.ResultContext.MultiTargetEffectResults[TargetIndex];        //  clear struct for use - cannot pass dynamic array element as out parameter
			if (ApplyAmmo)
			{
				class'X2Ability'.static.ApplyEffectsToTarget(
					AbilityContext, 
					AffectedTargetObject_OriginalState, 
					SourceObject_OriginalState, 
					ShootAbilityState, 
					AffectedTargetObject_NewState, 
					NewGameState, 
					AbilityContext.ResultContext.MultiTargetHitResults[TargetIndex],
					AbilityContext.ResultContext.MultiTargetArmorMitigation[TargetIndex],
					AbilityContext.ResultContext.MultiTargetStatContestResult[TargetIndex],
					AmmoTemplate.TargetEffects, 
					MultiTargetEffectResults, 
					AmmoTemplate.DataName,  //Use the ammo template for TELT_AmmoTargetEffects
					TELT_AmmoTargetEffects);
			}
			if (ApplyWeapon)
			{
				class'X2Ability'.static.ApplyEffectsToTarget(
					AbilityContext, 
					AffectedTargetObject_OriginalState, 
					SourceObject_OriginalState, 
					ShootAbilityState, 
					AffectedTargetObject_NewState, 
					NewGameState, 
					AbilityContext.ResultContext.MultiTargetHitResults[TargetIndex],
					AbilityContext.ResultContext.MultiTargetArmorMitigation[TargetIndex],
					AbilityContext.ResultContext.MultiTargetStatContestResult[TargetIndex],
					WeaponTemplate.BonusWeaponEffects, 
					MultiTargetEffectResults, 
					WeaponTemplate.DataName,  //Use the ammo template for TELT_AmmoTargetEffects
					TELT_WeaponEffects);
			}
			AbilityContext.ResultContext.MultiTargetEffectResults[TargetIndex] = MultiTargetEffectResults;  //  copy results into dynamic array
		}
	}

	return NewGameState;
}

function MrNice_WeaponFixes_BuildVisualization(XComGameState VisualizeGameState)
{
	//general
	local XComGameStateHistory	History;
	local XComGameStateVisualizationMgr VisualizationMgr;

	//actions
	local X2Action JoinAction;
	local array<X2Action> Actions, DummyActions;

	//state objects
	local XComGameState_BaseObject			TargetStateObject;
	local XComGameState_Item				SourceWeapon;
	local StateObjectReference				ShootingUnitRef;

	//contexts
	local XComGameStateContext_Ability	Context;
	local AbilityInputContext			AbilityContext;
	
	//templates
	local X2AbilityTemplate	AbilityTemplate;
	local X2AmmoTemplate	AmmoTemplate;
	local X2WeaponTemplate	WeaponTemplate;

	//Tree metadata
	local VisualizationActionMetadata   InitData;
	local VisualizationActionMetadata   BuildData;
	local VisualizationActionMetadata   SourceData;

	local name         ApplyResult;

	//indices
	local int	idx, TargetIndex, FireIndex;

	//Flags
	local bool bMultiSourceIsAlsoTarget, ApplyAmmo, ApplyWeapon, MultiFireAction;

	TypicalAbility_BuildVisualization(VisualizeGameState);

	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;

	SourceWeapon = XComGameState_Item(History.GetGameStateForObjectID(AbilityContext.ItemObject.ObjectID));
	if (SourceWeapon == None) return;

	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);

	//`log("Weapon fixes started to build visualization for " $ AbilityTemplate.LocFriendlyName $ "(" $ string(AbilityTemplate.DataName) $ ")");
	//`log(`showvar(BaseVisualizationFn));

	if (AbilityTemplate.bAllowAmmoEffects && SourceWeapon.HasLoadedAmmo())
	{
		AmmoTemplate = X2AmmoTemplate(SourceWeapon.GetLoadedAmmoTemplate(XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.AbilityRef.ObjectID))));
		ApplyAmmo = AmmoTemplate != none && AmmoTemplate.TargetEffects.Length != 0;
	}

	if (AbilityTemplate.bAllowBonusWeaponEffects)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		ApplyWeapon = WeaponTemplate != none && WeaponTemplate.BonusWeaponEffects.Length != 0;
	}

	if (ApplyAmmo || ApplyWeapon)
	{
		VisualizationMgr = `XCOMVISUALIZATIONMGR;
		VisualizationMgr.GetNodesOfType(VisualizationMgr.BuildVisTree, class'X2Action_MarkerNamed', Actions);
		for(idx=0; idx<Actions.Length; idx++)
			if (X2Action_MarkerNamed(Actions[idx]).MarkerName=='Join')
		{
			JoinAction = Actions[idx];
			break;
		}
		SourceData.StateObject_OldState = History.GetGameStateForObjectID(ShootingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		SourceData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ShootingUnitRef.ObjectID);
		if (SourceData.StateObject_NewState == none)
			SourceData.StateObject_NewState = SourceData.StateObject_OldState;
		SourceData.VisualizeActor = History.GetVisualizer(Context.InputContext.SourceObject.ObjectID);;	
		VisualizationMgr.GetNodesOfType(VisualizationMgr.BuildVisTree, class'X2Action_Fire', Actions, SourceData.VisualizeActor);
		if (Actions.Length!=0)
		{
			SourceData.LastActionAdded = Actions[0];
			for (idx=0; idx<SourceData.LastActionAdded.ChildActions.Length; idx++)
			{	
				if (X2Action_EnterCover(SourceData.LastActionAdded.ChildActions[idx]) == none
					&& SourceData.VisualizeActor == SourceData.LastActionAdded.ChildActions[idx].MetaData.VisualizeActor)
				{
					SourceData.LastActionAdded = SourceData.LastActionAdded.ChildActions[idx];
					idx=-1;
				}
			}
			if(Actions.Length!=1)
			{
				for (idx=0; idx<Actions.Length; idx++)
				{	
					DummyActions.AddItem(class'X2Action'.static.CreateVisualizationActionClass(class'X2Action_MarkerNamed', Context));
					`SWITCHACTIONS(DummyActions[idx], Actions[idx]);
				}
				MultiFireAction = true;				
			}

		}
		/*
		if(HandlePrimary)
		{
			if( AbilityContext.PrimaryTarget.ObjectID == AbilityContext.SourceObject.ObjectID )
			{
				bMultiSourceIsAlsoTarget = true;
				BuildData=SourceData;
				if(MultiFireAction)
				{
					FireIndex=0;
					`SWITCHACTIONS(Actions[0], DummyActions[0]);
				}
			}
			else
			{
				BuildData = InitData;
				BuildData.VisualizeActor = History.GetVisualizer(AbilityContext.PrimaryTarget.ObjectID);

				TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
				if( TargetStateObject != none )
				{
					History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.PrimaryTarget.ObjectID, 
																		BuildData.StateObject_OldState, BuildData.StateObject_NewState,
																		eReturnType_Reference,
																		VisualizeGameState.HistoryIndex);
				}			
				else
				{
					//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
					//and show no change.
					BuildData.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
					BuildData.StateObject_NewState = BuildData.StateObject_OldState;
				}

				if(Actions.Length!=0)
				{
					if(MultiFireAction)
					{
						for (FireIndex=0; FireIndex<Actions.Length; FireIndex++)
						{	
							if ( AbilityContext.PrimaryTarget.ObjectID == X2Action_Fire(Actions[FireIndex]).PrimaryTargetID
								|| X2Action_Fire(Actions[FireIndex]).PrimaryTargetID == 0)
								break;
						}
						if(FireIndex == Actions.Length) FireIndex = 0;
						BuildData.LastActionAdded = Actions[FireIndex];
						`SWITCHACTIONS(Actions[FireIndex], DummyActions[FireIndex]);
					}
					else  BuildData.LastActionAdded = Actions[0];
					for (idx=0; idx<BuildData.LastActionAdded.ChildActions.Length; idx++)
					{	
						if ( BuildData.VisualizeActor == BuildData.LastActionAdded.ChildActions[idx].MetaData.VisualizeActor)
						{
							BuildData.LastActionAdded = BuildData.LastActionAdded.ChildActions[idx];
							idx=-1;
						}
					}
				}
			}
		
			if (ApplyAmmo) for (idx = 0; idx < AmmoTemplate.TargetEffects.Length; ++idx)
			{
				ApplyResult = Context.FindTargetEffectApplyResult(AmmoTemplate.TargetEffects[idx]);

				// Target effect visualization
				AmmoTemplate.TargetEffects[idx].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);
				AmmoTemplate.TargetEffects[idx].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
			}
				
			if (ApplyWeapon) for (idx = 0; idx < WeaponTemplate.BonusWeaponEffects.Length; ++idx)
			{
				ApplyResult = Context.FindTargetEffectApplyResult(WeaponTemplate.BonusWeaponEffects[idx]);

				// Target effect visualization
				WeaponTemplate.BonusWeaponEffects[idx].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);
				WeaponTemplate.BonusWeaponEffects[idx].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
			}
			if( bMultiSourceIsAlsoTarget )
			{
				SourceData = BuildData;
				bMultiSourceIsAlsoTarget = false;
			}
			if(MultiFireAction)
			{
				`SWITCHACTIONS(DummyActions[FireIndex], Actions[FireIndex]);
			}
		}
		*/

		for( TargetIndex = 0; TargetIndex < AbilityContext.MultiTargets.Length; ++TargetIndex )
		{	
			if( AbilityContext.MultiTargets[TargetIndex].ObjectID == AbilityContext.SourceObject.ObjectID )
			{
				bMultiSourceIsAlsoTarget = true;
				BuildData=SourceData;
				if(MultiFireAction)
				{
					FireIndex=0;
					`SWITCHACTIONS(Actions[0], DummyActions[0]);
				}
			}
			else
			{
				BuildData = InitData;
				BuildData.VisualizeActor = History.GetVisualizer(AbilityContext.MultiTargets[TargetIndex].ObjectID);

				TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
				if( TargetStateObject != none )
				{
					History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID, 
																		BuildData.StateObject_OldState, BuildData.StateObject_NewState,
																		eReturnType_Reference,
																		VisualizeGameState.HistoryIndex);
				}			
				else
				{
					//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
					//and show no change.
					BuildData.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
					BuildData.StateObject_NewState = BuildData.StateObject_OldState;
				}

				if(Actions.Length!=0)
				{
					if(MultiFireAction)
					{
						for (FireIndex=0; FireIndex<Actions.Length; FireIndex++)
						{	
							if ( AbilityContext.MultiTargets[TargetIndex].ObjectID == X2Action_Fire(Actions[FireIndex]).PrimaryTargetID)
								break;
						}
						if(FireIndex == Actions.Length) FireIndex = 0;
						BuildData.LastActionAdded = Actions[FireIndex];
						`SWITCHACTIONS(Actions[FireIndex], DummyActions[FireIndex]);
					}
					else  BuildData.LastActionAdded = Actions[0];
					for (idx=0; idx<BuildData.LastActionAdded.ChildActions.Length; idx++)
					{	
						if ( BuildData.VisualizeActor == BuildData.LastActionAdded.ChildActions[idx].MetaData.VisualizeActor)
						{
							BuildData.LastActionAdded = BuildData.LastActionAdded.ChildActions[idx];
							idx=-1;
						}
					}
				}
			}
		
			if (ApplyAmmo) for (idx = 0; idx < AmmoTemplate.TargetEffects.Length; ++idx)
			{
				ApplyResult = Context.FindMultiTargetEffectApplyResult(AmmoTemplate.TargetEffects[idx], TargetIndex);

				// Target effect visualization
				AmmoTemplate.TargetEffects[idx].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);
				AmmoTemplate.TargetEffects[idx].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
			}
				
			if (ApplyWeapon) for (idx = 0; idx < WeaponTemplate.BonusWeaponEffects.Length; ++idx)
			{
				ApplyResult = Context.FindMultiTargetEffectApplyResult(WeaponTemplate.BonusWeaponEffects[idx], TargetIndex);

				// Target effect visualization
				WeaponTemplate.BonusWeaponEffects[idx].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);
				WeaponTemplate.BonusWeaponEffects[idx].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
			}
			if( bMultiSourceIsAlsoTarget )
			{
				SourceData = BuildData;
				bMultiSourceIsAlsoTarget = false;
			}
			if(MultiFireAction)
			{
				`SWITCHACTIONS(DummyActions[FireIndex], Actions[FireIndex]);
			}
		}

		if(MultiFireAction) for(idx=0; idx<DummyActions.Length; idx++)
		{
			VisualizationMgr.ReplaceNode(Actions[idx], DummyActions[idx]);
		}

		if (JoinAction!=none)
		{
			VisualizationMgr.GetAllLeafNodes(VisualizationMgr.BuildVisTree, Actions);
			Actions.RemoveItem(JoinAction);
			if (Actions.Length != 0)
				VisualizationMgr.ConnectAction(JoinAction, VisualizationMgr.BuildVisTree,,, Actions);
		}
	}
}