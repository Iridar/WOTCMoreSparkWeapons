class X2EventListener_HasHeavyWeapon extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_ListenerTemplate());

	return Templates;
}

static function CHEventListenerTemplate Create_ListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'X2EventListener_HasHeavyWeapon');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('OverrideHasHeavyWeapon', ListenerEventFunction, ELD_Immediate);

	return Template;
}

static function EventListenerReturn ListenerEventFunction(Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComLWTuple			Tuple;
	local XComGameState_Unit	UnitState;
	local XComGameState			CheckGameState;
	local XComGameState_Item	ItemState;

	/*
	Tuple = new class'XComLWTuple';
	Tuple.Id = 'OverrideHasHeavyWeapon';
	Tuple.Data.Add(3);
	Tuple.Data[0].kind = XComLWTVBool;
	Tuple.Data[0].b = false; //bOverrideHasHeavyWeapon;
	Tuple.Data[1].kind = XComLWTVBool;
	Tuple.Data[1].b = false; //bHasHeavyWeapon;
	Tuple.Data[2].kind = XComLWTVObject;
	Tuple.Data[2].o = CheckGameState;
	*/
	
	Tuple = XComLWTuple(EventData);
	UnitState = XComGameState_Unit(EventSource);

	`LOG("Override: for unit:" @ UnitState.GetFullName(),, 'WOTCMoreSparkWeapons');

	if (Tuple != none && UnitState != none && !Tuple.Data[0].b)
	{
		//	Proceed only if this unit is a SPARK and the decision of whether it has HW Slot has not been overridden already.
		if (class'X2DownloadableContentInfo_WOTCMoreSparkWeapons'.default.SparkCharacterTemplates.Find(UnitState.GetMyTemplateName()) != INDEX_NONE)
		{
			CheckGameState = XComGameState(Tuple.Data[2].o);

			//	We will determine right now if this unit has a Heavy Weapon slot or not.
			Tuple.Data[0].b = true;
			
			//	TODO: Maybe cycle through all inventory items here.
			ItemState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);
			if (ItemState != none)
			{
				//	Grant HW slot if the secondary weapon's category is listed.
				Tuple.Data[1].b = class'X2DownloadableContentInfo_WOTCMoreSparkWeapons'.default.WeaponCategoriesAddHeavyWeaponSlot.Find(ItemState.GetWeaponCategory()) != INDEX_NONE;

				`LOG("Override: unit has heavy weapon:" @ Tuple.Data[0].b,, 'WOTCMoreSparkWeapons');

				return ELR_NoInterrupt;
			}
			//	Forbid the unit to have a HW slot if the listed weapon category is not present.
			Tuple.Data[1].b = false;

			`LOG("Override: unit has heavy weapon Stage2:" @ Tuple.Data[0].b,, 'WOTCMoreSparkWeapons');
		}
	}
	return ELR_NoInterrupt;
}



			