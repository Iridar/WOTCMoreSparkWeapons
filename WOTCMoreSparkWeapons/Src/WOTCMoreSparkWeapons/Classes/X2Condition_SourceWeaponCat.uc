class X2Condition_SourceWeaponCat extends X2Condition;

var name MatchWeaponCat;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget) 
{
	local XComGameState_Item SourceWeapon;
	
	SourceWeapon = kAbility.GetSourceWeapon();

	if (SourceWeapon != none && SourceWeapon.GetWeaponCategory() == MatchWeaponCat)
	{
		return 'AA_Success'; 
	}
	
	return 'AA_WeaponIncompatible';
}

function bool CanEverBeValid(XComGameState_Unit SourceUnit, bool bStrategyCheck)
{
	local array<XComGameState_Item> InventoryItems;
	local XComGameState_Item		InventoryItem;

	InventoryItems = SourceUnit.GetAllInventoryItems();

	foreach InventoryItems(InventoryItem)
	{
		if (InventoryItem.GetWeaponCategory() == MatchWeaponCat)
		{
			return true;
		}
	}

	return false;
}