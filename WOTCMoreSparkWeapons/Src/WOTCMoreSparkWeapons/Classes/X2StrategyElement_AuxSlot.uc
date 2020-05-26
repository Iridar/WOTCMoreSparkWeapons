class X2StrategyElement_AuxSlot extends CHItemSlotSet config(SparkWeapons);

var localized string strSlotFirstLetter;
var localized string strSlotLocName;

var config array<name> AuxSlotAllowedWeaponCategories;

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

	Template.InvSlot = eInvSlot_AuxiliaryWeapon;
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
	return IsTemplateValidForSlot(ItemTemplate);
}

static function bool CanAddItemToSlot(CHItemSlot Slot, XComGameState_Unit UnitState, X2ItemTemplate ItemTemplate, optional XComGameState CheckGameState, optional int Quantity = 1, optional XComGameState_Item ItemState)
{    
	//	If there is no item in the slot
	if(UnitState.GetItemInSlot(Slot.InvSlot, CheckGameState) == none)
	{
		return IsTemplateValidForSlot(ItemTemplate);
	}

	//	Slot is already occupied, cannot add any more items to it.
	return false;
}

private static function bool IsTemplateValidForSlot(X2ItemTemplate ItemTemplate)
{
	local X2WeaponTemplate	WeaponTemplate;

	WeaponTemplate = X2WeaponTemplate(ItemTemplate);
	if (WeaponTemplate != none)
	{
		return default.AuxSlotAllowedWeaponCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE;
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

	if(ItemState != none && !HasSlot)
	{
		`LOG("WARNING Unit:" @ Unit.GetFullName() @ "soldier class:" @ Unit.GetSoldierClassTemplateName() @ "has an item equipped in the Slot:" @ ItemState.GetMyTemplateName() @ ", but they are not supposed to have the Pistol Slot. Attempting to unequip the item.",, 'WOTCMoreSparkWeapons');

		ItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', ItemState.ObjectID));
		if (Unit.RemoveItemFromInventory(ItemState, NewGameState))
		{
			`LOG("Successfully unequipped the item. Putting it into HQ Inventory.",, 'WOTCMoreSparkWeapons');
			XComHQ.PutItemInInventory(NewGameState, ItemState);
		}
		else `LOG("WARNING, failed to unequip the item!",, 'WOTCMoreSparkWeapons');
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