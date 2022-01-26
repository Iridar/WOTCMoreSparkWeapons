class XComGameState_Effect_TransferWeapon extends XComGameState_Effect config(SparkArsenal);

//eInvSlot_ExtraRocket1
//eInvSlot_ExtraBackpack

var array<EInventorySlot> UseInventorySlots;

var EInventorySlot OriginalSlot;
var EInventorySlot TargetSlot;

var StateObjectReference TransferWeaponRef;
var StateObjectReference SourceUnitRef;	//	Reference to the unit that used Aid Protocol, aka the current owner of the BIT Item State
var StateObjectReference TargetUnitRef;	//	Reference to the target of the Aid Protocol aka the soldier that gets control of the BIT's heavy weapon.
var StateObjectReference BitWeaponRef;	//	Reference to the BIT Item State that is transferring the weapon

var private bool bValidTarget;
var config bool ONLY_SOLDIERS_CONTROL_BIT_HEAVY_WEAPON;

struct AbilityChargeCooldownDataStruct
{
	var name TemplateName;
	var int iCooldown;
	var int iCharges;
};
var private array<AbilityChargeCooldownDataStruct> AbilityChargeCooldownDataArray;

private function RecordAbilityChargeCooldownData(const XComGameState_Ability AbilityState)
{
	local AbilityChargeCooldownDataStruct AbilityChargeCooldownData;

	AbilityChargeCooldownData.TemplateName = AbilityState.GetMyTemplateName();
	AbilityChargeCooldownData.iCooldown = AbilityState.iCooldown;
	AbilityChargeCooldownData.iCharges = AbilityState.iCharges;

	AbilityChargeCooldownDataArray.AddItem(AbilityChargeCooldownData);
}

private function RestoreAbilityChargeCooldownData(XComGameState_Ability AbilityState)
{
	local int i;

	for (i = AbilityChargeCooldownDataArray.Length - 1; i >= 0; i--)
	{
		if (AbilityChargeCooldownDataArray[i].TemplateName == AbilityState.GetMyTemplateName())
		{
			AbilityState.iCooldown = AbilityChargeCooldownDataArray[i].iCooldown;

			//	If ability was not transferred to another soldier, then we reduce the cooldown by the number of turns this effect was present on the soldier to account for the passed time.
			if (!bValidTarget)
			{
				AbilityState.iCooldown -= FullTurnsTicked;
			}

			AbilityState.iCharges = AbilityChargeCooldownDataArray[i].iCharges;
			AbilityChargeCooldownDataArray.Remove(i, 1);
			return;
		}
	}
}

private function ResetAbilityChargeCooldownData()
{
	AbilityChargeCooldownDataArray.Length = 0;
}

//	##############			INTERFACE FUNCTIONS			##############

simulated function ForwardTransfer(XComGameState_Unit SourceUnit, XComGameState_Item SourceWeapon, XComGameState_Unit TargetUnit, StateObjectReference BitObjRef, XComGameState NewGameState)
{
	local XComGameState_Player		PlayerState;
	local XComGameState_Ability		AbilityState;	
	local StateObjectReference		AbilityRef;
	local array<AbilitySetupData>	AbilityData;
	local X2TacticalGameRuleset		TacticalRules;
	local XComGameStateHistory		History;
	local int						iAmmo;
	local int i;

	TargetSlot = FindFreeInventorySlot(TargetUnit, NewGameState);
	if (TargetSlot != eInvSlot_Unknown)
	{
		History = `XCOMHISTORY;
		OriginalSlot = SourceWeapon.InventorySlot;	//	Should always be eInvSlot_ExtraBackpack
		TransferWeaponRef = SourceWeapon.GetReference();
		SourceUnitRef = SourceUnit.GetReference();
		TargetUnitRef = TargetUnit.GetReference();
		BitWeaponRef = BitObjRef;

		//	Transferring the weapon appears to reset its ammo count, so we store it locally.
		`LOG("XComGameState_Effect_TransferWeapon::ForwardTransfer:: begin transfer of weapon:" @ SourceWeapon.GetMyTemplateName() @ "with ammo:" @ SourceWeapon.Ammo @ "from slot:" @ OriginalSlot @ "to slot:" @ TargetSlot,, 'WOTCMoreSparkWeapons');
		iAmmo = SourceWeapon.Ammo;

		//	Remove all abilities associated with the weapon being transferred from the unit that is giving it away.
		for (i = SourceUnit.Abilities.Length - 1; i >= 0; i--)
		{
			AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(SourceUnit.Abilities[i].ObjectID));
			if (AbilityState.SourceWeapon == TransferWeaponRef)
			{
				RecordAbilityChargeCooldownData(AbilityState);
				`LOG("XComGameState_Effect_TransferWeapon::ForwardTransfer:: removing ability:" @ AbilityState.GetMyTemplateName() @ "from source unit:" @ SourceUnit.GetFullName(),, 'WOTCMoreSparkWeapons');
				SourceUnit.Abilities.Remove(i, 1);
			}
		}

		SourceUnit.RemoveItemFromInventory(SourceWeapon, NewGameState);

		//	Only soldiers receive control over BIT Heavy Weapons.
		//	The user of the Aid Protocol still must lose control of the weapon or the viz will bug out hard if they try to use it.
		if (default.ONLY_SOLDIERS_CONTROL_BIT_HEAVY_WEAPON)
		{
			bValidTarget = TargetUnit.IsSoldier();
		}
		else
		{
			bValidTarget = true;
		}

		//	---------------------------------------------------------------------------
		if (bValidTarget)
		{
			TargetUnit.bIgnoreItemEquipRestrictions = true;
			TargetUnit.AddItemToInventory(SourceWeapon, TargetSlot, NewGameState);	
			TargetUnit.bIgnoreItemEquipRestrictions = false;

			//	Initiate abilities associated with the newly added weapon.
			PlayerState = XComGameState_Player(History.GetGameStateForObjectID(TargetUnit.ControllingPlayer.ObjectID));			
			AbilityData = TargetUnit.GatherUnitAbilitiesForInit(/*NewGameState*/, PlayerState); // Passing StartState to it causes a bug in LWOTC where it restores ammo for some weapons.
			TacticalRules = `TACTICALRULES;

			for (i = 0; i < AbilityData.Length; i++)
			{
				if (AbilityData[i].SourceWeaponRef == TransferWeaponRef)
				{	
					`LOG("XComGameState_Effect_TransferWeapon::ForwardTransfer:: initializing ability:" @ AbilityData[i].Template.DataName @ "for target unit:" @ TargetUnit.GetFullName(),, 'WOTCMoreSparkWeapons');
					
					AbilityRef = TacticalRules.InitAbilityForUnit(AbilityData[i].Template, TargetUnit, NewGameState, TransferWeaponRef);
					AbilityState = XComGameState_Ability(NewGameState.GetGameStateForObjectID(AbilityRef.ObjectID));
					RestoreAbilityChargeCooldownData(AbilityState);
				}
			}

			`LOG("XComGameState_Effect_TransferWeapon::ForwardTransfer:: finish transfer of weapon:" @ SourceWeapon.GetMyTemplateName() @ ", it now has ammo:" @ SourceWeapon.Ammo,, 'WOTCMoreSparkWeapons');
			SourceWeapon.Ammo = iAmmo;
		}
	}
	else `LOG("XComGameState_Effect_TransferWeapon::ForwardTransfer:: ERROR, could not find any free slots on the Target Unit:" @ TargetUnit.GetFullName(),, 'WOTCMoreSparkWeapons');
}

simulated function BackwardTransfer(XComGameState NewGameState)
{
	local XComGameState_Unit		TargetUnit;
	local XComGameState_Unit		SourceUnit;
	local XComGameState_Item		SourceWeapon;
	local int						iAmmo;
	local XComGameState_Player		PlayerState;
	local XComGameState_Ability		AbilityState;	
	local array<AbilitySetupData>	AbilityData;
	local X2TacticalGameRuleset		TacticalRules;
	local XComGameStateHistory		History;
	local StateObjectReference		AbilityRef;
	
	local int i;

	TargetUnit = XComGameState_Unit(GetGameStateForObjectID(NewGameState, class'XComGameState_Unit', TargetUnitRef));
	SourceUnit = XComGameState_Unit(GetGameStateForObjectID(NewGameState, class'XComGameState_Unit', SourceUnitRef));
	SourceWeapon = XComGameState_Item(GetGameStateForObjectID(NewGameState, class'XComGameState_Item', TransferWeaponRef));
	if (TargetUnit != none && SourceUnit != none && SourceWeapon != none)
	{
		//`LOG("XComGameState_Effect_TransferWeapon::BackwardTransfer:: begin transfer of weapon:" @ SourceWeapon.GetMyTemplateName() @ "with ammo:" @ SourceWeapon.Ammo @ "from slot:" @ SourceWeapon.InventorySlot @ "to slot:" @ OriginalSlot,, 'WOTCMoreSparkWeapons');

		History = `XCOMHISTORY;
		iAmmo = SourceWeapon.Ammo;

		if (bValidTarget)
		{
			ResetAbilityChargeCooldownData();
			//	Remove all abilities associated with the weapon being transferred from the unit that is giving it away.
			for (i = TargetUnit.Abilities.Length - 1; i >= 0; i--)
			{
				AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(TargetUnit.Abilities[i].ObjectID));
				if (AbilityState.SourceWeapon == TransferWeaponRef)
				{
					RecordAbilityChargeCooldownData(AbilityState);
					//`LOG("XComGameState_Effect_TransferWeapon::BackwardTransfer:: removing ability:" @ AbilityState.GetMyTemplateName() @ "from target unit:" @ TargetUnit.GetFullName(),, 'WOTCMoreSparkWeapons');
					TargetUnit.Abilities.Remove(i, 1);
				}
			}

			TargetUnit.RemoveItemFromInventory(SourceWeapon, NewGameState);
		}
		//	---------------------------------------------------------------------------

		SourceUnit.bIgnoreItemEquipRestrictions = true;
		SourceUnit.AddItemToInventory(SourceWeapon, OriginalSlot, NewGameState);	
		SourceUnit.bIgnoreItemEquipRestrictions = false;

		//	Initiate abilities associated with the newly added weapon.
		PlayerState = XComGameState_Player(History.GetGameStateForObjectID(SourceUnit.ControllingPlayer.ObjectID));			
		AbilityData = SourceUnit.GatherUnitAbilitiesForInit(/*NewGameState*/, PlayerState);
		TacticalRules = `TACTICALRULES;
		for (i = 0; i < AbilityData.Length; i++)
		{
			if (AbilityData[i].SourceWeaponRef == TransferWeaponRef)
			{	
				//`LOG("XComGameState_Effect_TransferWeapon::BackwardTransfer:: initializing ability:" @ AbilityData[i].Template.DataName @ "for source unit:" @ SourceUnit.GetFullName(),, 'WOTCMoreSparkWeapons');
				AbilityRef = TacticalRules.InitAbilityForUnit(AbilityData[i].Template, SourceUnit, NewGameState, TransferWeaponRef);
				AbilityState = XComGameState_Ability(NewGameState.GetGameStateForObjectID(AbilityRef.ObjectID));
				RestoreAbilityChargeCooldownData(AbilityState);
			}
		}

		SourceWeapon.Ammo = iAmmo;
	}
}

//	##############			PRIVATE HELPER FUNCTIONS			##############

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

static private function EInventorySlot FindFreeInventorySlot(const XComGameState_Unit UnitState, XComGameState CheckGameState)
{
	local EInventorySlot TestSlot;
	
	foreach default.UseInventorySlots(TestSlot)
	{
		if (UnitState.GetItemInSlot(TestSlot, CheckGameState) == none)
		{
			return TestSlot;
		}
	}
	return eInvSlot_Unknown;
}

static private function XComGameState_BaseObject GetObjectStateFromGameStateOrHistory(int ObjectObjectID, optional XComGameState CheckGameState)
{
	local XComGameState_BaseObject BaseObj;

	if (CheckGameState != none)
	{
		BaseObj = CheckGameState.GetGameStateForObjectID(ObjectObjectID);
	}
	if (BaseObj == none)
	{
		BaseObj = `XCOMHISTORY.GetGameStateForObjectID(ObjectObjectID);
	}
	return BaseObj;
}

//	##############			PUBLIC HELPER FUNCTIONS			##############
/*
class'XComGameState_Effect_TransferWeapon'.static.GetGremlinItemState(const XComGameState_Unit UnitState, const StateObjectReference VisualizeWeaponRef, optional XComGameState CheckGameState)

class'XComGameState_Effect_TransferWeapon'.static.GetCosmeticUnitState(const XComGameState_Unit UnitState, const StateObjectReference VisualizeWeaponRef, optional XComGameState CheckGameState)
*/
static function XComGameState_Unit GetCosmeticUnitState(const XComGameState_Unit UnitState, const StateObjectReference VisualizeWeaponRef, optional XComGameState CheckGameState)
{
	local XComGameState_Unit					CosmeticUnitState;
	local XComGameState_Item					BitItemState;
	local array<XComGameState_Unit>				AttachedUnitStates;

	BitItemState = GetGremlinItemState(UnitState, VisualizeWeaponRef, CheckGameState);

	if (BitItemState != none)
	{
		CosmeticUnitState = XComGameState_Unit(GetObjectStateFromGameStateOrHistory(BitItemState.CosmeticUnitRef.ObjectID, CheckGameState));

		return CosmeticUnitState;
	}

	//	FALLBACK - return unit state of any cosmetic unit attached to this unit.

	UnitState.GetAttachedUnits(AttachedUnitStates, CheckGameState);

	if (AttachedUnitStates.Length > 0)
	{
		return AttachedUnitStates[0];
	}

	return none;
}

static function XComGameState_Item GetGremlinItemState(const XComGameState_Unit UnitState, const StateObjectReference VisualizeWeaponRef, optional XComGameState CheckGameState)
{
	local XComGameState_Effect_TransferWeapon	TransferWeaponEffectState;
	local XComGameState_Item					ItemState;
	local int									BitObjectID;

	//	First let's see if this unit owns a BIT at all.
	BitObjectID = class'X2Condition_HasWeaponOfCategory'.static.GetBITObjectID(UnitState, CheckGameState);
	if (BitObjectID != 0)
	{
		//	This soldier has a BIT in their inventory.
		//	Let's check if the visualized weapon is that BIT.
		if (BitObjectID == VisualizeWeaponRef.ObjectID)
		{
			//	Yep, this must be a bog standard attack like Combat Protocol, where the BIT itself is the weapon.
			ItemState = XComGameState_Item(GetObjectStateFromGameStateOrHistory(BitObjectID, CheckGameState));

			return ItemState;
		}

		//	Still here? Maybe the visualized weapon is the Heavy Weapon in the Slot granted by this BIT.
		ItemState = UnitState.GetItemInSlot(class'X2StrategyElement_BITHeavyWeaponSlot'.default.BITHeavyWeaponSlot);
		if (ItemState != none && ItemState.ObjectID == VisualizeWeaponRef.ObjectID)
		{
			//	Yep. Then same deal, return the cosmetic unit state of the BIT owned by this soldier.
			ItemState = XComGameState_Item(GetObjectStateFromGameStateOrHistory(BitObjectID, CheckGameState));
			return ItemState;
		}
	}

	//	If we're still here, it means the visualized weapon is NOT the BIT owned by this soldier nor the heavy weapon in the slot granted by that BIT. 
	//	Or maybe the soldier doesn't have their own BIT at all.
	//	Then the visualized weapon must be granted to this slot by another BIT attached to this unit via Aid Protocol. Or the attached BIT itself. At this point we don't care, since for now we just want the ItemState of the relevant BIT.
	TransferWeaponEffectState = XComGameState_Effect_TransferWeapon(UnitState.GetUnitAffectedByEffectState(class'X2Effect_TransferWeapon'.default.EffectName));
	if (TransferWeaponEffectState != none)
	{
		ItemState = XComGameState_Item(GetObjectStateFromGameStateOrHistory(TransferWeaponEffectState.BitWeaponRef.ObjectID, CheckGameState));
		return ItemState;
	}

	return none;
}




/*
if( OldItem.ObjectID > 0 )
			{
				//Destroy the visuals for the old item if we had one
				OldItemVisualizer = XGItem(History.GetVisualizer(OldItem.ObjectID));
				OldItemVisualizer.Destroy();
				History.SetVisualizer(OldItem.ObjectID, none);
			}
			*/



defaultproperties
{
	UseInventorySlots(0) = eInvSlot_ExtraRocket1
	UseInventorySlots(1) = eInvSlot_QuaternaryWeapon
	UseInventorySlots(2) = eInvSlot_QuinaryWeapon
	UseInventorySlots(3) = eInvSlot_SenaryWeapon
	UseInventorySlots(4) = eInvSlot_SeptenaryWeapon
	UseInventorySlots(6) = eInvSlot_ExtraSecondary
	UseInventorySlots(7) = eInvSlot_PrimaryPayload
	UseInventorySlots(8) = eInvSlot_SecondaryPayload
}