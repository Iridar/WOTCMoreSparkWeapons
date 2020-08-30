class X2EventListener_SparkArsenal extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_ListenerTemplate());

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



			