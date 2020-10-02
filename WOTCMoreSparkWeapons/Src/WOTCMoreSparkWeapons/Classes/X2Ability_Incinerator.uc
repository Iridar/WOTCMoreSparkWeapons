class X2Ability_Incinerator extends X2Ability config(Incinerators);

var config int CONE_TILE_WIDTH;
var config int  CONE_TILE_LENGTH;
var config float FIRECHANCE_LVL1;
var config float FIRECHANCE_LVL2;
var config float FIRECHANCE_LVL3;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_FireSparkFlamethrower());
	Templates.AddItem(Create_FireSparkFlamethrowerOverwatch());

	return Templates;
}

//	Copied from Mitzruti's Immolators + Chemthrowers mod.

static function X2AbilityTemplate Create_FireSparkFlamethrower()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2Effect_ApplyWeaponDamage		WeaponDamageEffect;
	local X2AbilityTarget_Cursor			CursorTarget;
	local X2AbilityMultiTarget_Cone			ConeMultiTarget;
	local X2AbilityToHitCalc_StandardAim	StandardAim;
	local X2AbilityCost_Ammo				AmmoCost;
	local X2Effect_PersistentStatChange     DisorientedEffect;
	local X2Effect_ApplyMedikitHeal			MedikitHeal;
	local X2Condition_AbilityProperty		AbilityCondition;
	local X2Effect_ApplyFireToWorld			FireToWorldEffect;
	local array<name>                       SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_FireSparkFlamethrower');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_WrongSoldierClass');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_flamethrower";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllEffects.AddItem('MZBurningRush');
	Template.AbilityCosts.AddItem(ActionPointCost);

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bMultiTargetOnly = true;
	Template.AbilityToHitCalc = StandardAim;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Shooter conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetOnlyProperty);
	Template.AbilityMultiTargetConditions.AddItem(new class'X2Condition_FineControl');

	Template.bAllowBonusWeaponEffects = true;

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bExplosiveDamage = false;
	Template.AddMultiTargetEffect(WeaponDamageEffect);

	FireToWorldEffect = new class'X2Effect_ApplyFireToWorld';
	FireToWorldEffect.bUseFireChanceLevel = true;
	FireToWorldEffect.bDamageFragileOnly = true;
	FireToWorldEffect.FireChance_Level1 = default.FIRECHANCE_LVL1;
	FireToWorldEffect.FireChance_Level2 = default.FIRECHANCE_LVL2;
	FireToWorldEffect.FireChance_Level3 = default.FIRECHANCE_LVL3;
	FireToWorldEffect.bCheckForLOSFromTargetLocation = false; //The flamethrower does its own LOS filtering
	Template.AddMultiTargetEffect(FireToWorldEffect);

	MedikitHeal = new class'X2Effect_ApplyMedikitHeal';
	MedikitHeal.PerUseHP = 1;
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('Phoenix');
	MedikitHeal.TargetConditions.AddItem(AbilityCondition);
	Template.AddShooterEffect(MedikitHeal);

	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
	DisorientedEffect.iNumTurns = 2;
	DisorientedEffect.DamageTypes.AddItem('Mental');
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('FlamePanic');
	DisorientedEffect.TargetConditions.AddItem(AbilityCondition);
	Template.AddMultiTargetEffect(DisorientedEffect);

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = default.CONE_TILE_WIDTH * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = default.CONE_TILE_LENGTH * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.AddBonusConeSize('MZWidthNozzleBsc', 2, 0);
	ConeMultiTarget.AddBonusConeSize('MZWidthNozzleAdv', 3, 0);
	ConeMultiTarget.AddBonusConeSize('MZWidthNozzleSup', 4, 0);
	ConeMultiTarget.AddBonusConeSize('MZLengthNozzleBsc', 0, 1);
	ConeMultiTarget.AddBonusConeSize('MZLengthNozzleAdv', 0, 2);
	ConeMultiTarget.AddBonusConeSize('MZLengthNozzleSup', 0, 3);
	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.bCheckCollision = true;
	Template.bAffectNeighboringTiles = true;
	Template.bFragileDamageOnly = false;

	Template.ActionFireClass =  class'X2Action_Fire_Flamethrower';

	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	Template.ActivationSpeech = 'Flamethrower';
	Template.CinescriptCameraType = "Iridar_SPARK_Flamethrower";

	Template.PostActivationEvents.AddItem('ChemthrowerActivated');

	Template.SuperConcealmentLoss = 100;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bFrameEvenWhenUnitIsHidden = true;

	Template.Hostility = eHostility_Offensive;

	return Template;
}

static function X2AbilityTemplate Create_FireSparkFlamethrowerOverwatch()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;
	local X2Effect_ApplyWeaponDamage		WeaponDamageEffect;
	local X2AbilityMultiTarget_Cone			ConeMultiTarget;
	local X2AbilityToHitCalc_StandardAim	StandardAim;
	local X2AbilityCost_Ammo				AmmoCost;
	local X2Condition_Visibility			TargetVisibilityCondition;
	local X2AbilityTrigger_EventListener	Trigger;
	local X2Condition_UnitProperty          ShooterCondition;
	local X2Effect_PersistentStatChange     DisorientedEffect;
	local X2Effect_ApplyMedikitHeal			MedikitHeal;
	local X2Condition_AbilityProperty		AbilityCondition;
	local X2Effect_ApplyFireToWorld			FireToWorldEffect;
	local X2Condition_UnitImmunities		UnitImmunityCondition;
	local array<name>                       SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'IRI_FireSparkFlamethrowerOverwatch');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_flamethrower";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY + 1;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint);
	Template.AbilityCosts.AddItem(ReserveActionPointCost);

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bReactionFire = true;
	StandardAim.bOnlyMultiHitWithSuccess = false;
	Template.AbilityToHitCalc = StandardAim;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	//Trigger on movement - interrupt the move
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'ObjectMoved';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalOverwatchListener;
	Template.AbilityTriggers.AddItem(Trigger);

	// Shooter conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	ShooterCondition = new class'X2Condition_UnitProperty';
	ShooterCondition.ExcludeConcealed = true;
	Template.AbilityShooterConditions.AddItem(ShooterCondition);

	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bRequireBasicVisibility = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true; //Don't use peek tiles for over watch shots	
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	UnitImmunityCondition = new class'X2Condition_UnitImmunities';
	UnitImmunityCondition.AddExcludeDamageType('Fire');
	UnitImmunityCondition.bOnlyOnCharacterTemplate = false;
	Template.AbilityTargetConditions.AddItem(UnitImmunityCondition);

	Template.AbilityTargetConditions.AddItem(new class'X2Condition_WithinChemthrowerRange');
	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetOnlyProperty);
	Template.AbilityMultiTargetConditions.AddItem(new class'X2Condition_FineControl');

	Template.bAllowBonusWeaponEffects = true;

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bExplosiveDamage = false;
	Template.AddMultiTargetEffect(WeaponDamageEffect);
	Template.AddTargetEffect(WeaponDamageEffect);

	FireToWorldEffect = new class'X2Effect_ApplyFireToWorld';
	FireToWorldEffect.bUseFireChanceLevel = true;
	FireToWorldEffect.bDamageFragileOnly = true;
	FireToWorldEffect.FireChance_Level1 = default.FIRECHANCE_LVL1;
	FireToWorldEffect.FireChance_Level2 = default.FIRECHANCE_LVL2;
	FireToWorldEffect.FireChance_Level3 = default.FIRECHANCE_LVL3;
	FireToWorldEffect.bCheckForLOSFromTargetLocation = false; //The flamethrower does its own LOS filtering
	Template.AddMultiTargetEffect(FireToWorldEffect);

	MedikitHeal = new class'X2Effect_ApplyMedikitHeal';
	MedikitHeal.PerUseHP = 1;
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('Phoenix');
	MedikitHeal.TargetConditions.AddItem(AbilityCondition);
	Template.AddShooterEffect(MedikitHeal);

	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
	DisorientedEffect.iNumTurns = 2;
	DisorientedEffect.DamageTypes.AddItem('Mental');
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('FlamePanic');
	DisorientedEffect.TargetConditions.AddItem(AbilityCondition);
	Template.AddMultiTargetEffect(DisorientedEffect);
	Template.AddTargetEffect(DisorientedEffect);

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = default.CONE_TILE_WIDTH * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = default.CONE_TILE_LENGTH * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.AddBonusConeSize('MZWidthNozzleBsc', 2, 0);
	ConeMultiTarget.AddBonusConeSize('MZWidthNozzleAdv', 3, 0);
	ConeMultiTarget.AddBonusConeSize('MZWidthNozzleSup', 4, 0);
	ConeMultiTarget.AddBonusConeSize('MZLengthNozzleBsc', 0, 1);
	ConeMultiTarget.AddBonusConeSize('MZLengthNozzleAdv', 0, 2);
	ConeMultiTarget.AddBonusConeSize('MZLengthNozzleSup', 0, 3);
	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.bCheckCollision = true;
	Template.bAffectNeighboringTiles = true;
	Template.bFragileDamageOnly = false;
	Template.bAllowFreeFireWeaponUpgrade = false;

	Template.ActionFireClass =  class'X2Action_Fire_Flamethrower';

	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	Template.ActivationSpeech = 'Flamethrower';
	//Template.CinescriptCameraType = "Soldier_HeavyWeapons";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildVisualizationFn = OverwatchShot_BuildVisualization;
	Template.bFrameEvenWhenUnitIsHidden = true;

	Template.Hostility = eHostility_Offensive;

	return Template;
}