//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_WOTCMoreSparkWeapons.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_WOTCMoreSparkWeapons extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

static function GetNumUtilitySlotsOverride(out int NumUtilitySlots, XComGameState_Item EquippedArmor, XComGameState_Unit UnitState, XComGameState CheckGameState)
{
	local XComGameState_Item ItemState;

	if (UnitState.GetMyTemplateName() == 'SparkSoldier' || UnitState.GetMyTemplateName() == 'XComMecSoldier')
	{
		ItemState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);
		if (ItemState != none && ItemState.GetWeaponCategory() == 'iri_ordnance_launcher')
		{
			NumUtilitySlots++;
		}
	}
}

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local XComGameState_Item		ItemState;
	local array<XComGameState_Item>	InventoryItems;
	local AbilitySetupData			Data, EmptyData;
	local X2AbilityTemplate			AbilityTemplate;
	local StateObjectReference		GrenadeLauncherRef;
	local X2GrenadeTemplate			GrenadeTemplate;
	local int i;

	//`LOG("Finalize abilities for unit:",, 'IRILOG');

	if (UnitState.GetMyTemplateName() == 'SparkSoldier' || UnitState.GetMyTemplateName() == 'XComMecSoldier')
	{
		ItemState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);
		if (ItemState != none && ItemState.GetWeaponCategory() == 'iri_ordnance_launcher')
		{
			//	If the unit is a SPARK / MEC with an Ordnance Launcher
			`LOG("Found SPARK with a grenade launcher",, 'IRILOG');
			GrenadeLauncherRef = ItemState.GetReference();
			AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('IRI_LaunchOrdnance');

			//	Cycle through all Item States in the Unit's inventory
			InventoryItems = UnitState.GetAllInventoryItems(StartState);
			foreach InventoryItems(ItemState)
			{
				if (ItemState.bMergedOut) continue;

				//	If we find a grenade item
				GrenadeTemplate = X2GrenadeTemplate(ItemState.GetMyTemplate());
				if (GrenadeTemplate != none)
				{ 
					//	If the grenade item is a rocket add Launch Ordnance to it
					if (GrenadeTemplate.WeaponCat != 'rocket')
					{
						Data = EmptyData;
						Data.TemplateName = 'IRI_LaunchOrdnance';
						Data.Template = AbilityTemplate;
						Data.SourceWeaponRef = GrenadeLauncherRef;
						Data.SourceAmmoRef = ItemState.GetReference();
						SetupData.AddItem(Data);
					}
				}
			}
		}
	}
}