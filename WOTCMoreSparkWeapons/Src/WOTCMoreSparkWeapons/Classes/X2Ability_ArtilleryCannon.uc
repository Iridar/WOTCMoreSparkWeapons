class X2Ability_ArtilleryCannon extends X2Ability;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	//	Heavy Weapon: Autogun
	Templates.AddItem(Create_FireArtilleryCannon_HEAT());

	return Templates;
}

static function X2AbilityTemplate Create_FireArtilleryCannon_HEAT()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_Radius           MultiTargetRadius;

	Template = class'X2Ability_WeaponCommon'.static.Add_StandardShot('IRI_FireArtilleryCannon_HEAT', true, true);

	//	Icon Setup
	Template.IconImage = "img:///IRISparkHeavyWeapons.UI.Inv_HeavyAutgoun";

	//	Multi Target Effects
	Template.AddMultiTargetEffect(new class'X2Effect_ApplyWeaponDamage');
	
	//	Targeting and triggering
	Template.TargetingMethod = class'X2TargetingMethod_HeatShot';

	MultiTargetRadius = new class'X2AbilityMultiTarget_Radius';
	MultiTargetRadius.fTargetRadius = 2;
	Template.AbilityMultiTargetStyle = MultiTargetRadius;

	Template.ModifyNewContextFn = HeatShot_ModifyActivatedAbilityContext;

	return Template;
}

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

	if (AbilityContext.IsResultContextMiss())
	{
		//World = `XWORLD;
		//UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));

		NewLocation = class'X2Ability'.static.FindOptimalMissLocation(AbilityContext, false);

		AbilityState.GatherAdditionalAbilityTargetsForLocation(NewLocation, Target);
		AbilityContext.InputContext.MultiTargets = Target.AdditionalTargets;

		AbilityContext.InputContext.TargetLocations.Length = 0;
		AbilityContext.InputContext.TargetLocations.AddItem(NewLocation);

		AbilityContext.ResultContext.ProjectileHitLocations.Length = 0;
		AbilityContext.ResultContext.ProjectileHitLocations.AddItem(NewLocation);
	}
}
