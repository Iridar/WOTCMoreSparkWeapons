class X2StrategyElement_AuxSlot extends CHItemSlotSet config(AuxiliaryWeapons);

var localized string strSlotFirstLetter;
var localized string strSlotLocName;

var config EInventorySlot AuxiliaryWeaponSlot;

var config array<name> AuxSlotAllowedWeaponCategories;
var config array<name> AuxSlotAllowedItemsWithTech;
var config array<name> AuxSlotAlwaysAllowedItems;
var config name		   TechRequiredForItems;
var config bool		   bAllowCanisters;
var config bool		   bAllowCanistersForNonSPARKs;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateSlotTemplate());

	return Templates;
}

static function X2DataTemplate CreateSlotTemplate()
{
	local CHItemSlot Template;

	`CREATE_X2TEMPLATE(class'CHItemSlot', Template, 'IRI_SparkSlot_Aux');

	Template.InvSlot = default.AuxiliaryWeaponSlot;
	Template.SlotCatMask = Template.SLOT_WEAPON | Template.SLOT_ITEM;

	Template.IsUserEquipSlot = true;

	Template.IsEquippedSlot = true;

	Template.BypassesUniqueRule = false;
	Template.IsMultiItemSlot = false;
	Template.IsSmallSlot = false;
	Template.NeedsPresEquip = true;
	Template.ShowOnCinematicPawns = true;

	Template.CanAddItemToSlotFn = CanAddItemToSlot;

	Template.UnitHasSlotFn = HasSlot;
	Template.GetPriorityFn = SlotGetPriority;
	
	Template.ShowItemInLockerListFn = ShowItemInLockerList;
	Template.ValidateLoadoutFn = SlotValidateLoadout;
	Template.GetSlotUnequipBehaviorFn = SlotGetUnequipBehavior;
	Template.GetDisplayLetterFn = GetSlotDisplayLetter;
	Template.GetDisplayNameFn = GetDisplayName;

	return Template;
}

static function bool HasSlot(CHItemSlot Slot, XComGameState_Unit UnitState, out string LockedReason, optional XComGameState CheckGameState)
{    
	//	Aux Slot is granted to all SPARK / MEC characters
	return class'X2DownloadableContentInfo_WOTCMoreSparkWeapons'.static.IsUnitSparkLike(UnitState) || default.bAllowCanistersForNonSPARKs && IsUnitsPrimaryWeaponValidForCanister(UnitState) && !DoesUnitHaveCanisterEquippedInOtherSlot(UnitState);
}

static private function bool IsUnitsPrimaryWeaponValidForCanister(const XComGameState_Unit UnitState)
{
   local XComGameState_Item PrimaryWeapon;
 
    PrimaryWeapon = UnitState.GetPrimaryWeapon();

    if (PrimaryWeapon != none)
	{
		if (PrimaryWeapon.GetWeaponCategory() == 'chemthrower')
			return true;

		switch (PrimaryWeapon.GetMyTemplateName())
		{
		case 'IRI_Incinerator_CV':
		case 'IRI_Incinerator_MG':
		case 'IRI_Incinerator_BM':
			return true;
		default:
			return false;
		}
	}
	return false;
}

static function bool ShowItemInLockerList(CHItemSlot Slot, XComGameState_Unit Unit, XComGameState_Item ItemState, X2ItemTemplate ItemTemplate, XComGameState CheckGameState)
{
	return IsTemplateValidForSlot(Slot.InvSlot, ItemTemplate, Unit, CheckGameState);
}

static function bool CanAddItemToSlot(CHItemSlot Slot, XComGameState_Unit UnitState, X2ItemTemplate ItemTemplate, optional XComGameState CheckGameState, optional int Quantity = 1, optional XComGameState_Item ItemState)
{    
	//	If there is no item in the slot
	if(UnitState.GetItemInSlot(Slot.InvSlot, CheckGameState) == none)
	{
		return IsTemplateValidForSlot(Slot.InvSlot, ItemTemplate, UnitState, CheckGameState);
	}

	//	Slot is already occupied, cannot add any more items to it.
	return false;
}

private static function bool IsTemplateValidForSlot(EInventorySlot InvSlot, X2ItemTemplate ItemTemplate, XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local XComGameState_Item				OrdLauncherState;
	local X2WeaponTemplate					WeaponTemplate;
	local X2EquipmentTemplate				EqTemplate;
	local XComGameState_HeadquartersXCom	XComHQ;

	//`LOG("IsTemplateValidForSlot:" @ ItemTemplate.DataName,, 'IRITEST');

	// Handle SPARK-like units.
	if (class'X2DownloadableContentInfo_WOTCMoreSparkWeapons'.static.IsUnitSparkLike(UnitState))
	{
		if (default.AuxSlotAlwaysAllowedItems.Find(ItemTemplate.DataName) != INDEX_NONE)
		{
			return true;
		}
	
		//	Whitelist items by template name
		if (default.AuxSlotAllowedItemsWithTech.Find(ItemTemplate.DataName) != INDEX_NONE)
		{
			if (default.TechRequiredForItems != '')
			{
				XComHQ = `XCOMHQ;
				if (XComHQ.IsTechResearched(default.TechRequiredForItems))
				{
					return true;
				}
			}
			else return true;	//	Allow equipping specified items if no required Tech is specified.
		}	

		//	Whitelist items by inventory slot - in case an item was made or patched to be here.
		EqTemplate = X2EquipmentTemplate(ItemTemplate);
		if (EqTemplate != none && EqTemplate.InventorySlot == InvSlot)
		{
			return true;
		}

		//	If the ordnance launcher is equipped, allow equipping grenades in the slot.
		OrdLauncherState = UnitState.GetItemInSlot(class'X2Item_OrdnanceLauncher_CV'.default.INVENTORY_SLOT, CheckGameState);
		if (OrdLauncherState != none && OrdLauncherState.GetWeaponCategory() == class'X2Item_OrdnanceLauncher_CV'.default.WEAPON_CATEGORY)
		{
			if (IsItemValidGrenade(ItemTemplate)) return true;
		}

		//	Allow canisters in Aux Slot, as long as they don't already have a canister equipped.
		if (IsItemCanister(ItemTemplate) && default.bAllowCanisters && !DoesUnitHaveCanisterEquippedInOtherSlot(UnitState))
		{
			return true;
		}

		//	Whitelist items by weaponcat
		WeaponTemplate = X2WeaponTemplate(ItemTemplate);
		if (WeaponTemplate != none)
		{
			return default.AuxSlotAllowedWeaponCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE;
		}
	
	}
	else // Handle non-SPARK units
	{
		//	Allow canisters in Aux Slot, as long as they don't already have a canister equipped.
		if (IsItemCanister(ItemTemplate) && default.bAllowCanistersForNonSPARKs && !DoesUnitHaveCanisterEquippedInOtherSlot(UnitState))
		{
			return true;
		}
	}

	return false;
}

static private function bool DoesUnitHaveCanisterEquippedInOtherSlot(const XComGameState_Unit UnitState)
{
    local array<XComGameState_Item> InventoryItems;
    local XComGameState_Item        InventoryItem;
 
    InventoryItems = UnitState.GetAllInventoryItems();
 
    foreach InventoryItems(InventoryItem)
    {
		//	Filtering for the Unknown slot is necessary so that items don't get unequipped before they get properly equipped first.
        if (InventoryItem.GetWeaponCategory() == 'canister' && InventoryItem.InventorySlot != default.AuxiliaryWeaponSlot && InventoryItem.InventorySlot != eInvSlot_Unknown)
        {
			//`LOG("Unit has canister equipped in slot:" @ InventoryItem.InventorySlot,, 'WOTCSparkArsenal');
            return true;
        }
    }
	//`LOG("Unit DOES NOT has canister equipped in other slot",, 'WOTCSparkArsenal');
    return false;
}

private static function bool IsItemCanister(const X2ItemTemplate ItemTemplate)
{
	local X2WeaponTemplate	WeaponTemplate;

	WeaponTemplate = X2WeaponTemplate(ItemTemplate);

	return WeaponTemplate != none && WeaponTemplate.WeaponCat =='canister';
}

private static function bool IsItemValidGrenade(const X2ItemTemplate ItemTemplate)
{
	local X2GrenadeTemplate GrenadeTemplate;

	GrenadeTemplate = X2GrenadeTemplate(ItemTemplate);

	if (GrenadeTemplate != none)
	{
		return GrenadeTemplate.LaunchedGrenadeEffects.Length > 0;
	}
	return false;
}

static function SlotValidateLoadout(CHItemSlot Slot, XComGameState_Unit Unit, XComGameState_HeadquartersXCom XComHQ, XComGameState NewGameState)
{
	local XComGameState_Item	ItemState;
	local string				strDummy;
	local bool					HasSlot;
	local bool					bShouldUnequip;

	ItemState = Unit.GetItemInSlot(Slot.InvSlot, NewGameState);
	HasSlot = Slot.UnitHasSlot(Unit, strDummy, NewGameState);

	`LOG("Aux slot. Has slot:" @ HasSlot @ "has item:" @ ItemState != none @ ItemState.GetMyTemplateName(),, 'IRITEST');


	if (!HasSlot)
	{
		bShouldUnequip = true;
	}
	else if (ItemState != none)
	{
		if (!IsTemplateValidForSlot(Slot.InvSlot, ItemState.GetMyTemplate(), Unit, NewGameState))
		{
			bShouldUnequip = true;
		}
		if (class'X2DownloadableContentInfo_WOTCMoreSparkWeapons'.static.IsItemSpecialShell(ItemState.GetMyTemplateName()) &&
			!class'X2DownloadableContentInfo_WOTCMoreSparkWeapons'.static.DoesUnitHaveHeavyCannonEquipped(Unit, NewGameState))
		{
			bShouldUnequip = true;
		}
	}

	`LOG(`ShowVar(bShouldUnequip),, 'IRITEST');

	//	If there's an item equipped in the slot, but the unit is not supposed to have the slot, or the item is not supposed to be in the slot, then unequip it and put it into HQ Inventory.
	if (bShouldUnequip && ItemState != none)
	{
		ItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', ItemState.ObjectID));
		Unit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', Unit.ObjectID));
		if (Unit.RemoveItemFromInventory(ItemState, NewGameState))
		{	
			`LOG("Remove item",, 'IRITEST');
			XComHQ.PutItemInInventory(NewGameState, ItemState);
		}	
	}

	`LOG("Slot validated.",, 'IRITEST');
}

function ECHSlotUnequipBehavior SlotGetUnequipBehavior(CHItemSlot Slot, ECHSlotUnequipBehavior DefaultBehavior, XComGameState_Unit UnitState, XComGameState_Item ItemState, optional XComGameState CheckGameState)
{	
	return eCHSUB_AllowEmpty;
}

static function int SlotGetPriority(CHItemSlot Slot, XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	return 55;
}

static function string GetSlotDisplayLetter(CHItemSlot Slot)
{
	return default.strSlotFirstLetter;
}

static function string GetDisplayName(CHItemSlot Slot)
{
	return default.strSlotLocName;
}