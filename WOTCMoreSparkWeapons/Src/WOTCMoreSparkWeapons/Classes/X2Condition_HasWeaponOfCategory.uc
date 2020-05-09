class X2Condition_HasWeaponOfCategory extends X2Condition;

//	This condition succeeds if at least one of the equipped items on the unit has the specified weapon cat.
//	If bReverseCondition = true, the condition succeeds if none of the equipped items have the specified weapon cat.

var name RequireWeaponCategory;
var bool bReverseCondition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit		UnitState;
	
	
	UnitState = XComGameState_Unit(kTarget);
	
	if (UnitState != none)
	{
		if (CanEverBeValid(UnitState, false))
		{
			return 'AA_Success';
		}
	}
	else return 'AA_NotAUnit';
	
	return 'AA_AbilityUnavailable'; 
}

function bool CanEverBeValid(XComGameState_Unit SourceUnit, bool bStrategyCheck)
{
	local array<XComGameState_Item> InventoryItems;
	local XComGameState_Item		InventoryItem;

	InventoryItems = SourceUnit.GetAllInventoryItems();

	foreach InventoryItems(InventoryItem)
	{
		if (InventoryItem.GetWeaponCategory() == RequireWeaponCategory)
		{
			return !bReverseCondition;
		}
	}

	return bReverseCondition;
}

static function bool DoesUnitHaveBITEquipped(XComGameState_Unit SourceUnit)
{
	local array<XComGameState_Item> InventoryItems;
	local XComGameState_Item		InventoryItem;

	InventoryItems = SourceUnit.GetAllInventoryItems();

	foreach InventoryItems(InventoryItem)
	{
		if (InventoryItem.GetWeaponCategory() == 'sparkbit')
		{
			return true;
		}
	}
	return false;
}