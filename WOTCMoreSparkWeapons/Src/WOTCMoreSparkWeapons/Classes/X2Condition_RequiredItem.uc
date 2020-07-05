class X2Condition_RequiredItem extends X2Condition;

var name ItemName;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit	UnitState;
	
	UnitState = XComGameState_Unit(kTarget);
	
	if (UnitState != none)
	{
		if (UnitState.HasItemOfTemplateType(ItemName))
		{
			return 'AA_Success'; 
		}
	}
	else return 'AA_NotAUnit';
	
	return 'AA_WeaponIncompatible';
}

function bool CanEverBeValid(XComGameState_Unit SourceUnit, bool bStrategyCheck)
{
	return SourceUnit.HasItemOfTemplateType(ItemName);
}