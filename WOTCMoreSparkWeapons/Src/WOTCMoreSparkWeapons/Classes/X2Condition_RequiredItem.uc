class X2Condition_RequiredItem extends X2Condition;

var array<name> ItemNames;
//var name WeaponUpgradeName;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit	UnitState;
	local name					ItemName;
	
	UnitState = XComGameState_Unit(kTarget);
	
	if (UnitState != none)
	{
		foreach ItemNames(ItemName)
		{
			if (UnitState.HasItemOfTemplateType(ItemName))
			{
				return 'AA_Success'; 
			}
		}
	}
	else return 'AA_NotAUnit';

	//	DEBUG ONLY
	//return 'AA_Success';
	
	return 'AA_WeaponIncompatible';
}

function bool CanEverBeValid(XComGameState_Unit SourceUnit, bool bStrategyCheck)
{
	local name ItemName;

	foreach ItemNames(ItemName)
	{
		if (SourceUnit.HasItemOfTemplateType(ItemName))
		{
			return true;
		}
	}
	return false;
}
