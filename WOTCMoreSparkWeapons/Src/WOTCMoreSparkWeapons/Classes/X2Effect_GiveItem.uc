class X2Effect_GiveItem extends X2Effect;

var name			ItemToGive;
var EInventorySlot	InventorySlot;		
var bool			bUseInventorySlot;	//	If this is false, the effect will use the inventory slot specified in the template
var bool			bOverrideInventoryRestrictions;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit	UnitState;
	local X2EquipmentTemplate	EqTemplate;
	local XComGameState_Item	ItemState;
	local bool					bEquppedSuccessfully;

	local array<AbilitySetupData>	AbilityData;
	local X2TacticalGameRuleset		TacticalRules;
	local XComGameState_Player		PlayerState;
	local int i;

	

	UnitState = XComGameState_Unit(kNewTargetState);
	//`LOG("X2Effect_GiveItem: for unit:" @ UnitState.GetFullName(),, 'IRITEST');
	
	if (UnitState != none)
	{
		if (!bOverrideInventoryRestrictions && bUseInventorySlot)
		{
			ItemState = UnitState.GetItemInSlot(InventorySlot, NewGameState);
			if (ItemState != none)
			{
				//`LOG("X2Effect_GiveItem: unit already has item in slot, exiting:" @ InventorySlot,, 'IRITEST');
				return;
			}
		}

		EqTemplate = X2EquipmentTemplate(class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate(ItemToGive));
		if (EqTemplate == none)
			return;

		`LOG("X2Effect_GiveItem: found template:" @ EqTemplate.DataName,, 'IRITEST');

		if (!bOverrideInventoryRestrictions && !bUseInventorySlot)
		{
			ItemState = UnitState.GetItemInSlot(EqTemplate.InventorySlot, NewGameState);
			if (ItemState != none)
			{
				//`LOG("X2Effect_GiveItem: unit already has item in slot, exiting:" @ EqTemplate.InventorySlot,, 'IRITEST');
				return;
			}
		}		

		ItemState = none;
		ItemState = EqTemplate.CreateInstanceFromTemplate(NewGameState);

		if (bOverrideInventoryRestrictions)
			UnitState.bIgnoreItemEquipRestrictions = true;

		if (bUseInventorySlot)
		{
			bEquppedSuccessfully = UnitState.AddItemToInventory(ItemState, InventorySlot, NewGameState);
		}
		else
		{
			bEquppedSuccessfully = UnitState.AddItemToInventory(ItemState, EqTemplate.InventorySlot, NewGameState);
		}

		if (bOverrideInventoryRestrictions)
			UnitState.bIgnoreItemEquipRestrictions = false;

		//`LOG("X2Effect_GiveItem: equipped item:" @ bEquppedSuccessfully,, 'IRITEST');
		if (!bEquppedSuccessfully)
		{
			NewGameState.PurgeGameStateForObjectID(ItemState.ObjectID);
			return;
		}

		PlayerState = XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(UnitState.ControllingPlayer.ObjectID));			
		AbilityData = UnitState.GatherUnitAbilitiesForInit(NewGameState, PlayerState);
		TacticalRules = `TACTICALRULES;
		for (i = 0; i < AbilityData.Length; i++)
		{
			if (AbilityData[i].SourceWeaponRef.ObjectID == ItemState.ObjectID)
			{	
				//`LOG("X2Effect_GiveItem: initing ability:" @ AbilityData[i].Template.DataName,, 'IRITEST');
				TacticalRules.InitAbilityForUnit(AbilityData[i].Template, UnitState, NewGameState, ItemState.GetReference());
			}
		}
	}
}

// TODO: Test if this breaks anything
/*
simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	if (EffectApplyResult == 'AA_Success')
	{
		class'X2Action_UpdateUnitLoadout'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded);
	}
	super.AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, EffectApplyResult);
}
*/

defaultproperties
{
	
}