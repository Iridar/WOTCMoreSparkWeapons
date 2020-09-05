class X2Effect_SpeedLoader_Trigger extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'IRI_SpeedLoader_Trigger_Event', TriggerSpeedLoad_Listener, ELD_OnStateSubmitted,, UnitState);
	EventMgr.RegisterForEvent(EffectObj, 'IRI_SpeedLoader_Trigger_Event', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted,, UnitState);
	
	//	local X2EventManager EventMgr;
	//	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(SourceUnit.FindAbility('ABILITY_NAME').ObjectID));
	//	EventMgr = `XEVENTMGR;
	//	EventMgr.TriggerEvent('X2Effect_SpeedLoader_Trigger_Event', AbilityState, SourceUnit, NewGameState);
	
	//EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', AbilityActivated_Listener, ELD_OnStateSubmitted,, UnitState);	
	/*
	native function RegisterForEvent( ref Object SourceObj, 
									Name EventID, 
									delegate<OnEventDelegate> NewDelegate, 
									optional EventListenerDeferral Deferral=ELD_Immediate, 
									optional int Priority=50, 
									optional Object PreFilterObject, 
									optional bool bPersistent, 
									optional Object CallbackData );*/
	
	super.RegisterForEvents(EffectGameState);
}

static function EventListenerReturn TriggerSpeedLoad_Listener(Object EventData, Object EventSource, XComGameState GameState, name InEventID, Object CallbackData)
{
    local XComGameState_Unit            UnitState;
	local XComGameState_Item			ItemState;
	local array<XComGameState_Item>		ItemStates;
    local XComGameState_Ability         AbilityState;
	local StateObjectReference			AbilityRef;
		
	UnitState = XComGameState_Unit(EventSource);
	if (UnitState != none)
	{
		ItemStates = UnitState.GetAllInventoryItems(GameState, true);
		foreach ItemStates(ItemState)
		{
			if (ItemState.Ammo < ItemState.GetClipSize() && WeaponHasSpeedLoader(ItemState))
			{
				AbilityRef = UnitState.FindAbility('IRI_SpeedLoader_Reload', ItemState.GetReference());
				if (AbilityRef.ObjectID != 0)
				{
					AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityRef.ObjectID));
					if (AbilityState != none)
					{
						AbilityState.AbilityTriggerAgainstSingleTarget(UnitState.GetReference(), false);
					}
				}
			}
		}
	}	
    return ELR_NoInterrupt;
}
/*
private static function bool GiveUnitActionPointsForAbility(XComGameState_Unit UnitState, XComGameState_Ability AbilityState)
{
	local X2AbilityTemplate				AbilityTemplate;
	local X2AbilityCost					AbilityCost;
	local X2AbilityCost_ActionPoints	ActionCost;
	local int							GivePoints;
	local int i;

	AbilityTemplate = AbilityState.GetMyTemplate();
	if (AbilityTemplate != none)
	{
		foreach AbilityTemplate.AbilityCosts(AbilityCost)
		{
			ActionCost = X2AbilityCost_ActionPoints(AbilityCost);
			if (ActionCost != none)
			{
				GivePoints = ActionCost.GetPointCost(AbilityState, UnitState);
				for (i = 0; i < GivePoints; i++)
				{
					UnitState.ActionPoints.AddItem('');
				}
			}
		}
		return true;
	}

	return false;
}
*/
private static function bool WeaponHasSpeedLoader(const XComGameState_Item ItemState)
{
	local array<name> UpgradeNames;

	UpgradeNames = ItemState.GetMyWeaponUpgradeTemplateNames();

	return UpgradeNames.Find('IRI_SpeedLoader_Upgrade') != INDEX_NONE;
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints) 
{ 
	//	This is a movement ability and the unit is dashing.
	if (AbilityContext.InputContext.MovementPaths.Length > 0)
	{	
		if (AbilityContext.InputContext.MovementPaths[0].CostIncreases.Length > 0)
		{
			`XEVENTMGR.TriggerEvent('IRI_SpeedLoader_Trigger_Event', SourceUnit, SourceUnit, NewGameState);
		}
	}
	return false; 
}

defaultproperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "X2Effect_SpeedLoader_Trigger_Effect"
}