class X2Effect_SabotAmmo extends X2Effect_Persistent config(SparkArsenal);

var config float CounterSquadsightPenalty;
var config float CounterDodge;
var config float CounterDefense;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo		ModInfo;
	local X2CharacterTemplate	CharTemplate;
	local XComGameState_Item	SourceWeapon;
	local int					Tiles;
	local int					SquadsightTiles;
	local float					Modifier;
	 
	 SourceWeapon = AbilityState.GetSourceWeapon();

	//  make sure the ammo that created this effect is loaded into the weapon
	if (SourceWeapon == none || SourceWeapon.LoadedAmmo.ObjectID != EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID || !AbilityState.GetMyTemplate().bAllowAmmoEffects)
		return;

	CharTemplate = Target.GetMyTemplate();
	if (CharTemplate == none)
		return;
	
	//  Calculate how far into Squadsight range are we.
	Tiles = Attacker.TileDistanceBetween(Target);
	SquadsightTiles = Tiles - Attacker.GetVisibilityRadius() * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;

	//	right at the boundary, but squadsight IS being used so treat it like one tile
	if (SquadsightTiles == 0) SquadsightTiles = 1;

	// Aim - counter squadsight penalty
	if (SquadsightTiles > 0)
	{	
		Modifier = -class'X2AbilityToHitCalc_StandardAim'.default.SQUADSIGHT_DISTANCE_MOD * SquadsightTiles * CounterSquadsightPenalty;
	}	

	// Aim - counter target's innate defense
	Modifier += CharTemplate.CharacterBaseStats[eStat_Defense] * default.CounterDefense;
	if (Modifier != 0)
	{	
		ModInfo.ModType = eHit_Success;
		ModInfo.Reason = FriendlyName;
		ModInfo.Value = Modifier;
		ShotModifiers.AddItem(ModInfo);
	}	

	// Crit - counter squadsight's crit penalty
	Modifier = -class'X2AbilityToHitCalc_StandardAim'.default.SQUADSIGHT_CRIT_MOD * CounterSquadsightPenalty;
	if (Modifier != 0)
	{	
		ModInfo.ModType = eHit_Crit;
		ModInfo.Reason = FriendlyName;
		ModInfo.Value = Modifier;
		ShotModifiers.AddItem(ModInfo);
	}	

	// Graze - counter target's innate dodge stat
	Modifier = -CharTemplate.CharacterBaseStats[eStat_Dodge] * default.CounterDodge;
	if (Modifier != 0)
	{	
		ModInfo.ModType = eHit_Graze;
		ModInfo.Reason = FriendlyName;
		ModInfo.Value = Modifier;
		ShotModifiers.AddItem(ModInfo);
	}
}

defaultproperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "X2Effect_SabotAmmo_Effect"
	bDisplayInSpecialDamageMessageUI = true
}