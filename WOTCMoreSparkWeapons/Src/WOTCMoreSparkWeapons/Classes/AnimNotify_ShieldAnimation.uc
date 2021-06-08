class AnimNotify_ShieldAnimation extends AnimNotify_Scripted;

// Hunker Down / Shield Wall animations are handled by Idle State Machine.
// When the effect is applied, it plays the Hunker Start animation, and then loops the Hunker Loop animation.
// When the effect is removed, it plays the Hunker Start animation backwards. 
// Pretty cool, saves like 2KB of memory on a custom Hunker Stop animation 
// that would take 2 minutes to make by reversing the Hunker Stop animation in Maya.

// However, SPARK Shields need to play different Socket Animations for their Unfold / Fold animations 
// depending on whether the effect was just applied or just removed.
// So this custom Notify will inject the appropriate Play Socket animnotify depending on whether the unit
// is getting into hunker, or getting out of it.

// Number of the notify in the Hunker Down Start AnimSequence. 
const iNumNotify = 7;

// This notify is present both at the start and end of the animation. 
// The one at the end plays first when the animation is played in reverse.

event Notify(Actor Owner, AnimNodeSequence AnimSeqInstigator)
{
	local XComUnitPawn				Pawn;
	local XGUnitNativeBase			OwnerUnit;
	local XComGameState_Unit		UnitState;
	local XComGameState_Item		SecondaryWeapon;

	Pawn = XComUnitPawn(Owner);
    if (Pawn == none)
		return;

	OwnerUnit = Pawn.GetGameUnit();
	if (OwnerUnit == none)
		return;
		
	UnitState = OwnerUnit.GetVisualizedGameState();
	if (UnitState == none)
		return;

	SecondaryWeapon = UnitState.GetSecondaryWeapon();
	if (SecondaryWeapon == none)
		return;


	if (UnitState.IsUnitAffectedByEffectName('ShieldWall'))
	{	
		if (SecondaryWeapon.GetMyTemplateName() == 'SparkBallisticShield_BM')
		{
			XComAnimNotify_PlaySocketAnim(AnimSeqInstigator.AnimSeq.Notifies[iNumNotify].Notify).AnimName = 'FF_Shield_Extend_Powered';
		}
		else
		{
			XComAnimNotify_PlaySocketAnim(AnimSeqInstigator.AnimSeq.Notifies[iNumNotify].Notify).AnimName = 'FF_Shield_Extend';
		}
	}
	else
	{
		XComAnimNotify_PlaySocketAnim(AnimSeqInstigator.AnimSeq.Notifies[iNumNotify].Notify).AnimName = 'FF_Shield_Close';
	}
}

