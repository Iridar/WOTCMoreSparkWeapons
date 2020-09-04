class X2StrategyElement_AuxSlot extends CHItemSlotSet config(AuxiliaryWeapons);

var localized string strSlotFirstLetter;
var localized string strSlotLocName;

var config EInventorySlot AuxiliaryWeaponSlot;

var config array<name> AuxSlotAllowedWeaponCategories;
var config array<name> AuxSlotAllowedItems;
var config name		   TechRequiredForItems;

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
	return class'X2DownloadableContentInfo_WOTCMoreSparkWeapons'.default.SparkCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE;
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
	
	//	Whitelist items by template name
	if (default.AuxSlotAllowedItems.Find(ItemTemplate.DataName) != INDEX_NONE)
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

	//	Whitelist items by weaponcat
	WeaponTemplate = X2WeaponTemplate(ItemTemplate);
	if (WeaponTemplate != none)
	{
		return default.AuxSlotAllowedWeaponCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE;
	}
	return false;
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
	local XComGameState_Item ItemState;
	local string strDummy;
	local bool HasSlot;

	ItemState = Unit.GetItemInSlot(Slot.InvSlot, NewGameState);
	HasSlot = Slot.UnitHasSlot(Unit, strDummy, NewGameState);

	//	If there's an item equipped in the slot, but the unit is not supposed to have the slot, or the item is not supposed to be in the slot, then unequip it and put it into HQ Inventory.
	if (ItemState != none && (!HasSlot || !IsTemplateValidForSlot(Slot.InvSlot, ItemState.GetMyTemplate(), Unit, NewGameState)))
	{
		//`LOG("WARNING Unit:" @ Unit.GetFullName() @ "soldier class:" @ Unit.GetSoldierClassTemplateName() @ "has an item equipped in the Slot:" @ Slot.InvSlot @ ", but they are not supposed to have the Slot. Attempting to unequip the item.",, 'WOTCMoreSparkWeapons');

		ItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', ItemState.ObjectID));
		Unit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', Unit.ObjectID));
		if (Unit.RemoveItemFromInventory(ItemState, NewGameState))
		{
			//`LOG("Successfully unequipped the item. Putting it into HQ Inventory.",, 'WOTCMoreSparkWeapons');
			XComHQ.PutItemInInventory(NewGameState, ItemState);
		}	
		//else //`LOG("WARNING, failed to unequip the item!",, 'WOTCMoreSparkWeapons');
	}
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
