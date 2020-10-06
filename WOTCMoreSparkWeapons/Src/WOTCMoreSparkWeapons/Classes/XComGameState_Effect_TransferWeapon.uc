class XComGameState_Effect_TransferWeapon extends XComGameState_Effect;

var array<EInventorySlot> UseInventorySlots;

var EInventorySlot OriginalSlot;
var EInventorySlot TargetSlot;

//	What will happen if the Unit already has a BIT associated with it? how will Build Vis function behave? Maybe need to insert new Bit to the top of the list? Hopefully won't need a custom BuildViz function...

simulated function ForwardTransfer(XComGameState_Unit SourceUnit, XComGameState_Item SourceWeapon, XComGameState_Unit TargetUnit, XComGameState NewGameState)
{
	local XComGameState_Player		PlayerState;
	local XComGameState_Ability		AbilityState;	
	local array<AbilitySetupData>	AbilityData;
	local X2TacticalGameRuleset		TacticalRules;
	local XComGameStateHistory		History;
	local int i;

	TargetSlot = FindFreeInventorySlot(TargetUnit, NewGameState);
	if (TargetSlot != eInvSlot_Unknown)
	{
		History = `XCOMHISTORY;
		OriginalSlot = SourceWeapon.InventorySlot;

		//	Remove all abilities associated with the weapon being transferred from the unit that is giving it away.
		for (i = SourceUnit.Abilities.Length - 1; i >= 0; i--)
		{
			AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(SourceUnit.Abilities[i].ObjectID));
			if (AbilityState.SourceWeapon.ObjectID == SourceWeapon.ObjectID)
			{
				`LOG("XComGameState_Effect_TransferWeapon::ForwardTransfer:: removing ability:" @ AbilityState.GetMyTemplateName() @ "from source unit:" @ SourceUnit.GetFullName(),, 'WOTCMoreSparkWeapons');
				SourceUnit.Abilities.Remove(i, 1);
			}
		}

		SourceUnit.RemoveItemFromInventory(SourceWeapon, NewGameState);


		TargetUnit.bIgnoreItemEquipRestrictions = true;
		TargetUnit.AddItemToInventory(SourceWeapon, TargetSlot, NewGameState);	
		TargetUnit.bIgnoreItemEquipRestrictions = false;

		//	Initiate abilities associated with the newly added weapon.
		PlayerState = XComGameState_Player(History.GetGameStateForObjectID(TargetUnit.ControllingPlayer.ObjectID));			
		AbilityData = TargetUnit.GatherUnitAbilitiesForInit(NewGameState, PlayerState);
		TacticalRules = `TACTICALRULES;
		for (i = 0; i < AbilityData.Length; i++)
		{
			if (AbilityData[i].SourceWeaponRef.ObjectID == SourceWeapon.ObjectID)
			{	
				`LOG("XComGameState_Effect_TransferWeapon::ForwardTransfer:: initializing ability:" @ AbilityData[i].Template.DataName @ "for target unit:" @ TargetUnit.GetFullName(),, 'WOTCMoreSparkWeapons');
				TacticalRules.InitAbilityForUnit(AbilityData[i].Template, TargetUnit, NewGameState, AbilityData[i].SourceWeaponRef);
			}
		}
	}
	else `LOG("XComGameState_Effect_TransferWeapon::ForwardTransfer:: ERROR, could not find any free slots on the Target Unit:" @ TargetUnit.GetFullName(),, 'WOTCMoreSparkWeapons');
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

defaultproperties
{
	UseInventorySlots(0) = eInvSlot_QuaternaryWeapon
	UseInventorySlots(1) = eInvSlot_QuinaryWeapon
	UseInventorySlots(2) = eInvSlot_SenaryWeapon
	UseInventorySlots(3) = eInvSlot_SeptenaryWeapon
	UseInventorySlots(4) = eInvSlot_AuxiliaryWeapon
	UseInventorySlots(5) = eInvSlot_ExtraSecondary
	UseInventorySlots(6) = eInvSlot_PrimaryPayload
	UseInventorySlots(7) = eInvSlot_SecondaryPayload
	UseInventorySlots(8) = eInvSlot_ExtraBackpack
}