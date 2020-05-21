class X2StrategyElement_InventorySlots extends CHItemSlotSet config(GameData_WeaponData);

var localized string strSlotFirstLetter;

var config int CONV_LAUNCHER_GRANT_GRENADE_SLOTS;
var config int MAG_LAUNCHER_GRANT_GRENADE_SLOTS;
var config int BEAM_LAUNCHER_GRANT_GRENADE_SLOTS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateSlotTemplate('IRI_SparkSlot_1', eInvSlot_SparkRocket1, 1));
	Templates.AddItem(CreateSlotTemplate('IRI_SparkSlot_2', eInvSlot_SparkRocket2, 2));
	Templates.AddItem(CreateSlotTemplate('IRI_SparkSlot_3', eInvSlot_SparkRocket3, 3));

	return Templates;
}

/*
eInvSlot_SparkRocket1
eInvSlot_SparkRocket2
eInvSlot_SparkRocket3
eInvSlot_SparkRocket4
*/

static function X2DataTemplate CreateSlotTemplate(name TemplateName, EInventorySlot Slot, int iNum)
{
	local CHItemSlot Template;

	`CREATE_X2TEMPLATE(class'CHItemSlot', Template, TemplateName);

	Template.InvSlot = Slot;
	Template.SlotCatMask = Template.SLOT_ITEM;

	Template.IsUserEquipSlot = true;
	Template.IsEquippedSlot = false;

	Template.BypassesUniqueRule = true;
	Template.IsMultiItemSlot = false;
	Template.IsSmallSlot = true;
	Template.NeedsPresEquip = false;
	Template.ShowOnCinematicPawns = true;

	Template.CanAddItemToSlotFn = CanAddItemToSlot;

	switch (iNum)
	{
		case 1:	
			Template.UnitHasSlotFn = HasSlot_1;
			Template.GetPriorityFn = SlotGetPriority_1;
			break;
		case 2:	
			Template.UnitHasSlotFn = HasSlot_2;
			Template.GetPriorityFn = SlotGetPriority_2;
			break;
		case 3:	
			Template.UnitHasSlotFn = HasSlot_3;
			Template.GetPriorityFn = SlotGetPriority_3;
			break;
		default:
			break;
	}
	
	
	Template.ShowItemInLockerListFn = ShowItemInLockerList;
	Template.ValidateLoadoutFn = SlotValidateLoadout;
	Template.GetSlotUnequipBehaviorFn = SlotGetUnequipBehavior;
	Template.GetDisplayLetterFn = GetSlotDisplayLetter;
	Template.GetDisplayNameFn = GetDisplayName;

	return Template;
}

static function bool HasSlot_1(CHItemSlot Slot, XComGameState_Unit UnitState, out string LockedReason, optional XComGameState CheckGameState)
{    
	return HasSlot(UnitState, 1, CheckGameState);
}

static function bool HasSlot_2(CHItemSlot Slot, XComGameState_Unit UnitState, out string LockedReason, optional XComGameState CheckGameState)
{    
	return HasSlot(UnitState, 2, CheckGameState);
}

static function bool HasSlot_3(CHItemSlot Slot, XComGameState_Unit UnitState, out string LockedReason, optional XComGameState CheckGameState)
{    
	return HasSlot(UnitState, 3, CheckGameState);
}

static function bool HasSlot(XComGameState_Unit UnitState, int iNum, optional XComGameState CheckGameState)
{
	local XComGameState_Item		ItemState;
	local X2GrenadeLauncherTemplate	WeaponTemplate;

	ItemState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);
	if (ItemState != none)
	{
		WeaponTemplate = X2GrenadeLauncherTemplate(ItemState.GetMyTemplate());

		if (WeaponTemplate != none && WeaponTemplate.WeaponCat == 'iri_ordnance_launcher')
		{
			return iNum <= GetTier(WeaponTemplate);
		}
	}

    return false;
}

static function int GetTier(X2GrenadeLauncherTemplate WeaponTemplate)
{
	switch (WeaponTemplate.WeaponTech)
	{
		case 'conventional':
			return 1;
		case 'magnetic':
			return 2;
		case 'beam':
			return 3;
		default:
			return 0;
	}
	return 0;
}

static function bool ShowItemInLockerList(CHItemSlot Slot, XComGameState_Unit Unit, XComGameState_Item ItemState, X2ItemTemplate ItemTemplate, XComGameState CheckGameState)
{
	return X2GrenadeTemplate(ItemTemplate) != none;
}

static function bool CanAddItemToSlot(CHItemSlot Slot, XComGameState_Unit UnitState, X2ItemTemplate ItemTemplate, optional XComGameState CheckGameState, optional int Quantity = 1, optional XComGameState_Item ItemState)
{    
	//	If there is no item in the slot
	if(UnitState.GetItemInSlot(Slot.InvSlot, CheckGameState) == none)
	{
		return X2GrenadeTemplate(ItemTemplate) != none;
	}

	//	Slot is already occupied, cannot add any more items to it.
	return false;
}

static function SlotValidateLoadout(CHItemSlot Slot, XComGameState_Unit Unit, XComGameState_HeadquartersXCom XComHQ, XComGameState NewGameState)
{
	local XComGameState_Item ItemState;
	local string strDummy;
	local bool HasSlot;

	ItemState = Unit.GetItemInSlot(Slot.InvSlot, NewGameState);
	HasSlot = Slot.UnitHasSlot(Unit, strDummy, NewGameState);
	
	if(ItemState == none && HasSlot )
	{
		ItemState = FindBestWeapon(Unit, Slot.InvSlot, XComHQ, NewGameState);
		if (ItemState != none)
		{
			`LOG("Empty slot is not allowed, equipping:" @ ItemState.GetMyTemplateName(),, 'WOTCMoreSparkWeapons');
			if (Unit.AddItemToInventory(ItemState, Slot.InvSlot, NewGameState))
			{
				`LOG("Equipped successfully!",, 'WOTCMoreSparkWeapons');
			}
			else `LOG("WARNING, could not equip it!",, 'WOTCMoreSparkWeapons');

			return;
		}
		else `LOG("Empty slot is not allowed, but the mod was unable to find an infinite item to fill the slot.",, 'WOTCMoreSparkWeapons');
	}	

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


private static function XComGameState_Item FindBestWeapon(const XComGameState_Unit UnitState, EInventorySlot Slot, XComGameState_HeadquartersXCom XComHQ, XComGameState NewGameState)
{
	local X2GrenadeTemplate					GrenadeTemplate;
	local XComGameStateHistory				History;
	local int								HighestTier;
	local XComGameState_Item				ItemState;
	local XComGameState_Item				BestItemState;
	local StateObjectReference				ItemRef;

	HighestTier = -999;
	History = `XCOMHISTORY;

	//	Cycle through all items in HQ Inventory
	foreach XComHQ.Inventory(ItemRef)
	{
		ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));
		if (ItemState != none)
		{
			GrenadeTemplate = X2GrenadeTemplate(ItemState.GetMyTemplate());

			//	If this is an infinite item, it's tier is higher than the current recorded highest tier,
			//	it is allowed on the soldier by config entries that are relevant to this soldier
			//	and it can be equipped on the soldier
			if (GrenadeTemplate != none && GrenadeTemplate.bInfiniteItem && GrenadeTemplate.Tier > HighestTier && 
				UnitState.CanAddItemToInventory(GrenadeTemplate, Slot, NewGameState, ItemState.Quantity, ItemState))
			{	
				//	then remember this item as the currently best replacement option.
				HighestTier = GrenadeTemplate.Tier;
				BestItemState = ItemState;
			}
		}
	}

	if (BestItemState != none)
	{
		//	This will set up the Item State for modification automatically, or create a new Item State in the NewGameState if the template is infinite.
		XComHQ.GetItemFromInventory(NewGameState, BestItemState.GetReference(), BestItemState);
	}

	//	If we didn't find any fitting items, then BestItemState will be "none", and we're okay with that.
	return BestItemState;
}

function ECHSlotUnequipBehavior SlotGetUnequipBehavior(CHItemSlot Slot, ECHSlotUnequipBehavior DefaultBehavior, XComGameState_Unit UnitState, XComGameState_Item ItemState, optional XComGameState CheckGameState)
{	
	return eCHSUB_AttemptReEquip;
}

static function int SlotGetPriority_1(CHItemSlot Slot, XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	return 131;
}

static function int SlotGetPriority_2(CHItemSlot Slot, XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	return 132;
}

static function int SlotGetPriority_3(CHItemSlot Slot, XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	return 133;
}

static function string GetSlotDisplayLetter(CHItemSlot Slot)
{
	return default.strSlotFirstLetter;
}

static function string GetDisplayName(CHItemSlot Slot)
{
	return class'UIArmory_Loadout'.default.m_strInventoryLabels[eInvSlot_GrenadePocket];
}
