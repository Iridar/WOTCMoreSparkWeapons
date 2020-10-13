class X2StrategyElement_BITHeavyWeaponSlot extends CHItemSlotSet config(SparkArsenal);

var config bool BIT_Grants_HeavyWeaponSlot;

var localized string strSlotFirstLetter;
var localized string strSlotLocName;

var config EInventorySlot BITHeavyWeaponSlot;
var config array<name> HeavyWeaponsValidForBITWithSoldiers;

var config array<name> DisallowWeapon;

// Let's go without restriction for now and hope that mods that add new heavy weapons rely on vanilla animations.
/*
;	This config specifically determines which Heavy Weapons can be equipped 
;	into the Heavy Weapon slot granted by a BIT equipped on a regular soldier.
;	It has to be whitelist-only, because each heavy weapon requires a specific animation added by this mod.
;	SPARKs and MEC Troopers can equip any heavy weapon into that slot regardless of this config.
+HeavyWeaponsValidForBITWithSoldiers = "RocketLauncher"
+HeavyWeaponsValidForBITWithSoldiers = "ShredderGun"
+HeavyWeaponsValidForBITWithSoldiers = "Flamethrower"
+HeavyWeaponsValidForBITWithSoldiers = "FlamethrowerMk2"
+HeavyWeaponsValidForBITWithSoldiers = "BlasterLauncher"
+HeavyWeaponsValidForBITWithSoldiers = "PlasmaBlaster"
+HeavyWeaponsValidForBITWithSoldiers = "ShredstormCannon"
+HeavyWeaponsValidForBITWithSoldiers = "IRI_Heavy_Autogun"
+HeavyWeaponsValidForBITWithSoldiers = "IRI_Heavy_Autogun_MK2"
+HeavyWeaponsValidForBITWithSoldiers = "IRI_ElectroPulse_CV"
+HeavyWeaponsValidForBITWithSoldiers = "IRI_RestorativeMist_CV":
*/

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	if (default.BIT_Grants_HeavyWeaponSlot)
	{
		Templates.AddItem(CreateSlotTemplate());
	}

	return Templates;
}

static function X2DataTemplate CreateSlotTemplate()
{
	local CHItemSlot Template;

	`CREATE_X2TEMPLATE(class'CHItemSlot', Template, 'IRI_BITHeavyWeaponSlot');

	Template.InvSlot = default.BITHeavyWeaponSlot;
	Template.SlotCatMask = Template.SLOT_WEAPON;

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
	Template.GetBestGearForSlotFn = GetBestGearForSlot;

	return Template;
}

static function array<X2EquipmentTemplate> GetBestGearForSlot(CHItemSlot Slot, XComGameState_Unit Unit)
{
	local X2EquipmentTemplate			EqTemplate;
	local array<X2EquipmentTemplate>	ReturnArray;

	EqTemplate = X2EquipmentTemplate(class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate(class'X2Item_HeavyWeapons'.default.FreeHeavyWeaponToEquip));

	if (EqTemplate != none)
	{
		ReturnArray.AddItem(EqTemplate);
	}
	return ReturnArray;
}

static function bool HasSlot(CHItemSlot Slot, XComGameState_Unit UnitState, out string LockedReason, optional XComGameState CheckGameState)
{    
	//	Granted to all units with a BIT.
	return class'X2Condition_HasWeaponOfCategory'.static.DoesUnitHaveBITEquipped(UnitState);
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
	local X2WeaponTemplate WeaponTemplate;

	if (default.DisallowWeapon.Find(ItemTemplate.DataName) != INDEX_NONE)
		return false;
	
	//	Soldier-sized units can equip only whitelisted items.
	//if (UnitState.GetMyTemplate().UnitHeight == 2)
	//{
	//	return default.HeavyWeaponsValidForBITWithSoldiers.Find(ItemTemplate.DataName) != INDEX_NONE;
	//}
	//	Sparks / MECs can equip all heavy weapons.
	WeaponTemplate = X2WeaponTemplate(ItemTemplate);

	return WeaponTemplate != none && WeaponTemplate.WeaponCat == 'heavy';
}

static function SlotValidateLoadout(CHItemSlot Slot, XComGameState_Unit Unit, XComGameState_HeadquartersXCom XComHQ, XComGameState NewGameState)
{
	local XComGameState_Item	ItemState;
	local X2EquipmentTemplate	EqTemplate;
	local XComGameState_Unit	NewUnit;
	local string strDummy;
	local bool HasSlot;

	ItemState = Unit.GetItemInSlot(Slot.InvSlot, NewGameState);
	HasSlot = Slot.UnitHasSlot(Unit, strDummy, NewGameState);

	//	If there's an item equipped in the slot, but the unit is not supposed to have the slot, or the item is not supposed to be in the slot, then unequip it and put it into HQ Inventory.
	if (ItemState != none && (!HasSlot || !IsTemplateValidForSlot(Slot.InvSlot, ItemState.GetMyTemplate(), Unit, NewGameState)))
	{
		ItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', ItemState.ObjectID));
		NewUnit = XComGameState_Unit(GetGameStateForObjectID(NewGameState, class'XComGameState_Unit', Unit.GetReference()));
		if (NewUnit.RemoveItemFromInventory(ItemState, NewGameState))
		{
			XComHQ.PutItemInInventory(NewGameState, ItemState);
			ItemState = none;
		}	
	}

	//	If there's no item in the slot, put a generic heavy weapon into it.
	if (ItemState == none && HasSlot)
	{
		EqTemplate = X2EquipmentTemplate(class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate(class'X2Item_HeavyWeapons'.default.FreeHeavyWeaponToEquip));
		if (EqTemplate != none)
		{
			ItemState = EqTemplate.CreateInstanceFromTemplate(NewGameState);

			if (NewUnit == none)
			{
				NewUnit = XComGameState_Unit(GetGameStateForObjectID(NewGameState, class'XComGameState_Unit', Unit.GetReference()));
			}
			if (!NewUnit.AddItemToInventory(ItemState, Slot.InvSlot, NewGameState))
			{
				//	Nuke the item if it was not equipped for some reason.
				NewGameState.PurgeGameStateForObjectID(ItemState.ObjectID);
			}
		}
	}
}

static private function XComGameState_BaseObject GetGameStateForObjectID(XComGameState NewGameState, class ObjClass, const StateObjectReference ObjRef)
{
	local XComGameState_BaseObject BaseObject;

	BaseObject = NewGameState.GetGameStateForObjectID(ObjRef.ObjectID);
	if (BaseObject == none)
	{
		BaseObject = NewGameState.ModifyStateObject(ObjClass, ObjRef.ObjectID);
	}	
	if (BaseObject == none)
	{
		`LOG("X2Effect_TransferWeapon:: ERROR, could not get Game State for Object ID!",, 'WOTCMoreSparkWeapons');
	}
	return BaseObject;
}

function ECHSlotUnequipBehavior SlotGetUnequipBehavior(CHItemSlot Slot, ECHSlotUnequipBehavior DefaultBehavior, XComGameState_Unit UnitState, XComGameState_Item ItemState, optional XComGameState CheckGameState)
{	
	return eCHSUB_AttemptReEquip;
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