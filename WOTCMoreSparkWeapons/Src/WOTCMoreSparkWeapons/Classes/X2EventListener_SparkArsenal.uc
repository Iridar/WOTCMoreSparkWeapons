class X2EventListener_SparkArsenal extends X2EventListener config(ArtilleryCannon);

var config bool BLOCK_CLIP_SIZE_INCREASES;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(StrategyAndTacticalListener());
	Templates.AddItem(TacticalListener());
	Templates.AddItem(StrategyListener());

	return Templates;
}

static function CHEventListenerTemplate StrategyAndTacticalListener()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'IRI_SparkArsenal_StrategyAndTacticalListener');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('OverrideHasAmmoPocket', OnOverrideHasAmmoPocket, ELD_Immediate);

	return Template;
}
static function CHEventListenerTemplate StrategyListener()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'IRI_SparkArsenal_StrategyListener');

	Template.RegisterInTactical = false;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('WeaponUpgraded', OnWeaponUpgraded, ELD_Immediate);
	Template.AddCHEvent('ItemRemovedFromSlot', OnItemRemovedFromSlot, ELD_Immediate);

	return Template;
}
static function CHEventListenerTemplate TacticalListener()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'IRI_SparkArsenal_TacticalListener');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = false;

	//	Setting high priority to make sure we get the last word.
	if (default.BLOCK_CLIP_SIZE_INCREASES)
	{
		Template.AddCHEvent('OverrideClipSize', OverrideClipSize_ListenerEventFunction, ELD_Immediate, 101);
	}
	Template.AddCHEvent('IRI_RecallCosmeticUnit_Event', RecallCosmeticUnit_ListenerEventFunction, ELD_OnStateSubmitted);
	Template.AddCHEvent('CleanupTacticalMission', OnCleanupTacticalMission, ELD_Immediate);	

	return Template;
}

static private function EventListenerReturn RecallCosmeticUnit_ListenerEventFunction(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameStateContext_Ability	AbilityContext;
	local XComGameState_Unit			UnitState;
	local XComGameState_Item			RecalledItem;
	local XComGameStateHistory			History;
	local XComGameState					NewGameState;
	local XComGameState_Item			NewRecalledItem;
	local XGUnit						Visualizer;
	local vector						MoveToLoc;
	local XComGameState_Unit			CosmeticUnitState;
	local bool							MoveFromTarget;
	local TTile							UnitStateDesiredAttachTile;

	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));

	//`LOG("RecallCosmeticUnit_ListenerEventFunction:: running",, 'WOTCMoreSparkWeapons');
	
	if (AbilityContext == none || UnitState == none)
		return ELR_NoInterrupt;

	RecalledItem = class'XComGameState_Effect_TransferWeapon'.static.GetGremlinItemState(UnitState, AbilityContext.InputContext.ItemObject, GameState);
	if (RecalledItem == none)
		return ELR_NoInterrupt;

	//`LOG("RecallCosmeticUnit_ListenerEventFunction:: unit:" @ UnitState.GetFullName() @ "item:" @ RecalledItem.GetMyTemplateName(),, 'WOTCMoreSparkWeapons');

	UnitStateDesiredAttachTile = UnitState.GetDesiredTileForAttachedCosmeticUnit();
	if (UnitStateDesiredAttachTile != RecalledItem.GetTileLocation())
	{
		if (RecalledItem.AttachedUnitRef != UnitState.GetReference())
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Equipment recalled");					
			//Update the attached unit for this item
			NewRecalledItem = XComGameState_Item(NewGameState.ModifyStateObject(RecalledItem.Class, RecalledItem.ObjectID));
			NewRecalledItem.AttachedUnitRef = UnitState.GetReference();

			//`LOG("RecallCosmeticUnit_ListenerEventFunction:: submitting new game state",, 'WOTCMoreSparkWeapons');

			`GAMERULES.SubmitGameState(NewGameState);
		}

		CosmeticUnitState = XComGameState_Unit(History.GetGameStateForObjectID(RecalledItem.CosmeticUnitRef.ObjectID));

		MoveFromTarget = UnitStateDesiredAttachTile == RecalledItem.GetTileLocation();

		if (MoveFromTarget && AbilityContext.InputContext.TargetLocations.Length > 0)
		{
			MoveToLoc = AbilityContext.InputContext.TargetLocations[0];
			CosmeticUnitState.SetVisibilityLocationFromVector( MoveToLoc );

			//`LOG("RecallCosmeticUnit_ListenerEventFunction::MoveFromTarget MoveToLoc" @ MoveToLoc,, 'WOTCMoreSparkWeapons');
		}

		//  Now move it move it
		Visualizer = XGUnit(History.GetVisualizer(RecalledItem.CosmeticUnitRef.ObjectID));
		MoveToLoc = `XWORLD.GetPositionFromTileCoordinates(UnitStateDesiredAttachTile);
		Visualizer.MoveToLocation(MoveToLoc, CosmeticUnitState);

		//`LOG("RecallCosmeticUnit_ListenerEventFunction:: move it move it",, 'WOTCMoreSparkWeapons');
	}

	//`LOG("RecallCosmeticUnit_ListenerEventFunction:: exiting",, 'WOTCMoreSparkWeapons');

	return ELR_NoInterrupt;
}

//	This will make sure Heavy Cannons cannot benefit from any kind of clipsize boost.
static private function EventListenerReturn OverrideClipSize_ListenerEventFunction(Object EventData, Object EventSource, XComGameState NullGameState, Name Event, Object CallbackData)
{
	local XComLWTuple				Tuple;
	local XComGameState_Item		ItemState;

	/*
	Tuple = new class'XComLWTuple';
	Tuple.Id = 'OverrideClipSize';
	Tuple.Data.Add(1);
	Tuple.Data[0].kind = XComLWTVInt;
	Tuple.Data[0].i = ClipSize;

	`XEVENTMGR.TriggerEvent('OverrideClipSize', Tuple, self);

	*/

	Tuple = XComLWTuple(EventData);
	ItemState = XComGameState_Item(EventSource);

	if (Tuple != none && ItemState != none)
	{
		switch (ItemState.GetMyTemplateName())
		{
			case 'IRI_ArtilleryCannon_CV':
			case 'IRI_ArtilleryCannon_MG':
			case 'IRI_ArtilleryCannon_BM':
			case 'IRI_ArtilleryCannon_LS':
			case 'IRI_ArtilleryCannon_CG':
				Tuple.Data[0].i = X2WeaponTemplate(ItemState.GetMyTemplate()).iClipSize;
				return ELR_NoInterrupt;
			default:
				return ELR_NoInterrupt;
		}		
	}
	return ELR_NoInterrupt;
}


static private function EventListenerReturn OnOverrideHasAmmoPocket(Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComLWTuple				Tuple;
	local XComGameState_Unit		UnitState;
	local array<XComGameState_Item>	ItemStates;
	local XComGameState_Item		ItemState;
	local array<name>				WeaponUpgradeTemplateNames;

	/*
	Tuple = new class'XComLWTuple';
	Tuple.Id = EventID;
	Tuple.Data.Add(1);
	Tuple.Data[0].kind = XComLWTVBool;
	Tuple.Data[0].b = bOverridePocketResult;

	`XEVENTMGR.TriggerEvent(EventID, Tuple, self, none);
	*/

	Tuple = XComLWTuple(EventData);
	UnitState = XComGameState_Unit(EventSource);

	if (Tuple != none && UnitState != none && !Tuple.Data[0].b)
	{
		ItemStates = UnitState.GetAllInventoryItems(, true);
		foreach ItemStates(ItemState)
		{
			switch (ItemState.GetMyTemplateName())
			{
				case 'IRI_Shells_T1':
				case 'IRI_Shells_T2':
					Tuple.Data[0].b = true;
					return ELR_NoInterrupt;
				default:
					break;
			}

			WeaponUpgradeTemplateNames = ItemState.GetMyWeaponUpgradeTemplateNames();
			if (WeaponUpgradeTemplateNames.Find('IRI_ExperimentalMagazine_Upgrade') != INDEX_NONE)
			{
				Tuple.Data[0].b = true;
				return ELR_NoInterrupt;
			}
		}
	}
	return ELR_NoInterrupt;
}


static private function EventListenerReturn OnWeaponUpgraded(Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComGameState_Item ItemState;
	local XComGameState_Item NewItemState;
	local XComGameState_Unit NewUnitState;
	local array<name> EquippedUpgrades;
	local array<name> NewEquippedUpgrades;

	// `XEVENTMGR.TriggerEvent('WeaponUpgraded', Weapon, UpgradeItem, ChangeState);
	ItemState = XComGameState_Item(EventData);
	if (ItemState == none)
		return ELR_NoInterrupt;

	NewItemState = XComGameState_Item(NewGameState.GetGameStateForObjectID(ItemState.ObjectID));
	if (NewItemState == none)
		return ELR_NoInterrupt;

	EquippedUpgrades = ItemState.GetMyWeaponUpgradeTemplateNames();
	NewEquippedUpgrades = NewItemState.GetMyWeaponUpgradeTemplateNames();

	// Validate loadout if the weapon was equipped with an Experimental Magazine, or if it was removed.
	// Prevents the following bug:
	//Make soldier eligible for the Ammo Pocket (e.g. by equipping a weapon upgrade that grants the Ammo Slot, like Experimental Magazine from SPARK Arsenal)
	//Equip experimental ammo
	//Make soldier ineligible (e.g. by removing mentioned weapon upgrade).
	//Ammo slot is no longer visible in the UI, but the soldier still has the Ammo equipped under the hood, and will benefit from it in Tactical.
	if (EquippedUpgrades.Find('IRI_ExperimentalMagazine_Upgrade') != NewEquippedUpgrades.Find('IRI_ExperimentalMagazine_Upgrade'))
	{
		NewUnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ItemState.OwnerStateObject.ObjectID));
		if (NewUnitState == none)
			NewUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ItemState.OwnerStateObject.ObjectID));

		NewUnitState.ValidateLoadout(NewGameState);
	}
	return ELR_NoInterrupt;
}

static private function EventListenerReturn OnItemRemovedFromSlot(Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit	UnitState;
	local XComGameState_Unit	NewUnitState;
	local XComGameState_Item	RemovedItem;
	local X2WeaponTemplate		WeaponTemplate;

	RemovedItem = XComGameState_Item(EventData);
	if (RemovedItem == none)
		return ELR_NoInterrupt;

	// Check if the removed item was a Heavy Cannon
	WeaponTemplate = X2WeaponTemplate(RemovedItem.GetMyTemplate());
	if (WeaponTemplate == none || WeaponTemplate.Abilities.Find('IRI_FireArtilleryCannon_AP_Passive') == INDEX_NONE)
		return ELR_NoInterrupt;

	UnitState = XComGameState_Unit(EventSource);
	if (UnitState == none)
		return ELR_NoInterrupt;

	NewUnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(UnitState.ObjectID));
	if (NewUnitState == none)
	{
		NewUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));
	}

	if (class'X2DownloadableContentInfo_WOTCMoreSparkWeapons'.static.DoesUnitHaveMunitionsMount(NewUnitState,NewGameState))
	{
		UnequipMunitionsMount(NewUnitState, NewGameState);
	}	

	return ELR_NoInterrupt;
}

static private function UnequipMunitionsMount(XComGameState_Unit UnitState, XComGameState NewGameState)
{
	local XComGameState_Item ItemState;
	local XComGameState_HeadquartersXCom XComHQ;

	ItemState = UnitState.GetItemInSlot(class'X2Item_Shells_T1'.default.INVENTORY_SLOT, NewGameState);
	if (ItemState == none || ItemState.GetMyTemplateName() != 'IRI_Shells_T1')
	{
		ItemState = UnitState.GetItemInSlot(class'X2Item_Shells_T2'.default.INVENTORY_SLOT, NewGameState);
		if (ItemState == none || ItemState.GetMyTemplateName() != 'IRI_Shells_T2')
			return;
	}

	if (UnitState.RemoveItemFromInventory(ItemState, NewGameState))
	{
		foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
		{
			break;
		}
		if (XComHQ == none)
		{
			XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
			XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		}

		XComHQ.PutItemInInventory(NewGameState, ItemState);
	}
}

// Remove all Transfer Weapon effects at the end of tactical. This does not happen automatically, because `UnitRemovedFromPlay` is not called for XCOM units.
static private function EventListenerReturn OnCleanupTacticalMission(Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComGameStateHistory					History;
	local XComGameState_Effect_TransferWeapon	EffectState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_Effect_TransferWeapon', EffectState)
	{
		EffectState.RemoveEffect(NewGameState, NewGameState, true);
	}

	return ELR_NoInterrupt;
}
