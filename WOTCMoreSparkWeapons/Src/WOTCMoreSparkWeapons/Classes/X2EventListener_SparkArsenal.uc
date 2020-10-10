class X2EventListener_SparkArsenal extends X2EventListener config(ArtilleryCannon);

var config bool BLOCK_CLIP_SIZE_INCREASES;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_ListenerTemplate());
	Templates.AddItem(Create_TacticalListenerTemplate());
	
	return Templates;
}

static function CHEventListenerTemplate Create_ListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'IRI_X2EventListener_HasAmmoPocket');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('OverrideHasAmmoPocket', ListenerEventFunction, ELD_Immediate);

	return Template;
}
static function CHEventListenerTemplate Create_TacticalListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'IRI_SPARK_Arsenal_Tactical_Listener');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = false;

	//	Setting high priority to make sure we get the last word.
	if (default.BLOCK_CLIP_SIZE_INCREASES)
	{
		Template.AddCHEvent('OverrideClipSize', OverrideClipSize_ListenerEventFunction, ELD_Immediate, 101);
	}
	Template.AddCHEvent('IRI_RecallCosmeticUnit_Event', RecallCosmeticUnit_ListenerEventFunction, ELD_OnStateSubmitted);

	return Template;
}

static function EventListenerReturn RecallCosmeticUnit_ListenerEventFunction(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
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

	`LOG("RecallCosmeticUnit_ListenerEventFunction:: running",, 'WOTCMoreSparkWeapons');
	
	if (AbilityContext == none || UnitState == none)
		return ELR_NoInterrupt;

	RecalledItem = class'XComGameState_Effect_TransferWeapon'.static.GetGremlinItemState(UnitState, AbilityContext.InputContext.ItemObject, GameState);
	if (RecalledItem == none)
		return ELR_NoInterrupt;

	`LOG("RecallCosmeticUnit_ListenerEventFunction:: unit:" @ UnitState.GetFullName() @ "item:" @ RecalledItem.GetMyTemplateName(),, 'WOTCMoreSparkWeapons');

	UnitStateDesiredAttachTile = UnitState.GetDesiredTileForAttachedCosmeticUnit();
	if (UnitStateDesiredAttachTile != RecalledItem.GetTileLocation())
	{
		if (RecalledItem.AttachedUnitRef != UnitState.GetReference())
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Equipment recalled");					
			//Update the attached unit for this item
			NewRecalledItem = XComGameState_Item(NewGameState.ModifyStateObject(RecalledItem.Class, RecalledItem.ObjectID));
			NewRecalledItem.AttachedUnitRef = UnitState.GetReference();

			`LOG("RecallCosmeticUnit_ListenerEventFunction:: submitting new game state",, 'WOTCMoreSparkWeapons');

			`GAMERULES.SubmitGameState(NewGameState);
		}

		CosmeticUnitState = XComGameState_Unit(History.GetGameStateForObjectID(RecalledItem.CosmeticUnitRef.ObjectID));

		MoveFromTarget = UnitStateDesiredAttachTile == RecalledItem.GetTileLocation();

		if (MoveFromTarget && AbilityContext.InputContext.TargetLocations.Length > 0)
		{
			MoveToLoc = AbilityContext.InputContext.TargetLocations[0];
			CosmeticUnitState.SetVisibilityLocationFromVector( MoveToLoc );

			`LOG("RecallCosmeticUnit_ListenerEventFunction::MoveFromTarget MoveToLoc" @ MoveToLoc,, 'WOTCMoreSparkWeapons');
		}

		//  Now move it move it
		Visualizer = XGUnit(History.GetVisualizer(RecalledItem.CosmeticUnitRef.ObjectID));
		MoveToLoc = `XWORLD.GetPositionFromTileCoordinates(UnitStateDesiredAttachTile);
		Visualizer.MoveToLocation(MoveToLoc, CosmeticUnitState);

		`LOG("RecallCosmeticUnit_ListenerEventFunction:: move it move it",, 'WOTCMoreSparkWeapons');
	}

	`LOG("RecallCosmeticUnit_ListenerEventFunction:: exiting",, 'WOTCMoreSparkWeapons');

	return ELR_NoInterrupt;
}

//	This will make sure Heavy Cannons cannot benefit from any kind of clipsize boost.
static function EventListenerReturn OverrideClipSize_ListenerEventFunction(Object EventData, Object EventSource, XComGameState NullGameState, Name Event, Object CallbackData)
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
				Tuple.Data[0].i = X2WeaponTemplate(ItemState.GetMyTemplate()).iClipSize;
				return ELR_NoInterrupt;
			default:
				return ELR_NoInterrupt;
		}		
	}
	return ELR_NoInterrupt;
}


static function EventListenerReturn ListenerEventFunction(Object EventData, Object EventSource, XComGameState NullGameState, Name Event, Object CallbackData)
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






			