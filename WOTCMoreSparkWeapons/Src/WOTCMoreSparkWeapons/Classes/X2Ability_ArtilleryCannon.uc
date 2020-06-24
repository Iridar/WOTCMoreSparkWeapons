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

	return Template;
}