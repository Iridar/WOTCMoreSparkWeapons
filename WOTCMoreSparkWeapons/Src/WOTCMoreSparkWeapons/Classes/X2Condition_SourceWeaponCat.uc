class X2Condition_SourceWeaponCat extends X2Condition;

var array<name> MatchWeaponCats;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget) 
{
	local XComGameState_Item SourceWeapon;
	
	SourceWeapon = kAbility.GetSourceWeapon();

	if (SourceWeapon != none && MatchWeaponCats.Find(SourceWeapon.GetWeaponCategory()) != INDEX_NONE)
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
		if ( MatchWeaponCats.Find(InventoryItem.GetWeaponCategory()) != INDEX_NONE)
		{
			return true;
		}
	}

	return false;
}