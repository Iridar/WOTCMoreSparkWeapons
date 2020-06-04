class X2Condition_Augmented extends X2Condition;

var bool Head;
var bool Torso;
var bool Arms;
var bool Legs;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit	UnitState;
	local XComGameState_Item    ItemState;
	
	UnitState = XComGameState_Unit(kTarget);
	
	if (UnitState != none)
	{
		if (Head)
		{
			ItemState = UnitState.GetItemInSlot(eInvSlot_AugmentationHead);
			if (ItemState == none)
			{
				return 'AA_UnitIsWrongType';
			}
		}
		if (Torso)
		{
			ItemState = UnitState.GetItemInSlot(eInvSlot_AugmentationTorso);
			if (ItemState == none)
			{
				return 'AA_UnitIsWrongType';
			}
		}
		if (Arms)
		{
			ItemState = UnitState.GetItemInSlot(eInvSlot_AugmentationArms);
			if (ItemState == none)
			{
				return 'AA_UnitIsWrongType';
			}
		}
		if (Legs)
		{
			ItemState = UnitState.GetItemInSlot(eInvSlot_AugmentationLegs);
			if (ItemState == none)
			{
				return 'AA_UnitIsWrongType';
			}
		}
	}
	else return 'AA_NotAUnit';
	
	return 'AA_Success'; 
}