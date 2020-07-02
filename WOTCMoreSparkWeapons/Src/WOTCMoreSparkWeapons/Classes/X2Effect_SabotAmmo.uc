class X2Effect_SabotAmmo extends X2Effect_Persistent config(SparkWeapons);

var config float CounterSquadsightPenalty;
var config float CounterDodge;
var config float CounterDefense;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo		ModInfo;
	local X2CharacterTemplate	CharTemplate;
	local XComGameState_Item	SourceWeapon;
	local int					Tiles;
	 
	 SourceWeapon = AbilityState.GetSourceWeapon();

	//  make sure the ammo that created this effect is loaded into the weapon
	if (SourceWeapon != none && SourceWeapon.LoadedAmmo.ObjectID == EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID)
	{
		Tiles = Attacker.TileDistanceBetween(Target);

		//  Calculate how far into Squadsight range are we.
		Tiles -= Attacker.GetVisibilityRadius() * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;

		//	right at the boundary, but squadsight IS being used so treat it like one tile
		if (Tiles == 0) Tiles = 1;

		CharTemplate = Target.GetMyTemplate();
		if (Tiles > 0 && CharTemplate != none)
		{	
			ModInfo.ModType = eHit_Success;
			ModInfo.Reason = FriendlyName;
			ModInfo.Value = -class'X2AbilityToHitCalc_StandardAim'.default.SQUADSIGHT_DISTANCE_MOD * Tiles * CounterSquadsightPenalty + CharTemplate.CharacterBaseStats[eStat_Defense] * default.CounterDefense;
			ShotModifiers.AddItem(ModInfo);

			ModInfo.ModType = eHit_Crit;
			ModInfo.Reason = FriendlyName;
			ModInfo.Value = -class'X2AbilityToHitCalc_StandardAim'.default.SQUADSIGHT_CRIT_MOD;
			ShotModifiers.AddItem(ModInfo);

			ModInfo.ModType = eHit_Graze;
			ModInfo.Reason = FriendlyName;
			ModInfo.Value = -CharTemplate.CharacterBaseStats[eStat_Dodge] * default.CounterDodge;
			ShotModifiers.AddItem(ModInfo);
		}	
	}
}

defaultproperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "X2Effect_SabotAmmo_Effect"
	bDisplayInSpecialDamageMessageUI = true
}