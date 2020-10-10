class X2Effect_TransferWeapon extends X2Effect_Persistent;

//	TODO: Sync duration with existing Aid Protocol
//	TODO: Make this effect applicable only with BIT as source weapon
/*
function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'X2Effect_TransferWeapon_Event', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
	
	//	local X2EventManager EventMgr;
	//	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(SourceUnit.FindAbility('ABILITY_NAME').ObjectID));
	//	EventMgr = `XEVENTMGR;
	//	EventMgr.TriggerEvent('X2Effect_TransferWeapon_Event', AbilityState, SourceUnit, NewGameState);
	
	EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', AbilityActivated_Listener, ELD_OnStateSubmitted,, UnitState);	
	
	//native function RegisterForEvent( ref Object SourceObj, 
	//								Name EventID, 
	//								delegate<OnEventDelegate> NewDelegate, 
	//								optional EventListenerDeferral Deferral=ELD_Immediate, 
	//								optional int Priority=50, 
	//								optional Object PreFilterObject, 
	//								optional bool bPersistent, 
	//								optional Object CallbackData );
	
	super.RegisterForEvents(EffectGameState);
}

static function EventListenerReturn AbilityActivated_Listener(Object EventData, Object EventSource, XComGameState NewGameState, name InEventID, Object CallbackData)
{
    local XComGameState_Unit            UnitState;
    local XComGameState_Ability         AbilityState;
	local X2AbilityTemplate				AbilityTemplate;
		
	AbilityState = XComGameState_Ability(EventData);
	UnitState = XComGameState_Unit(EventSource);
	AbilityTemplate = AbilityState.GetMyTemplate();
	
    return ELR_NoInterrupt;
}
*/
simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit					SourceUnit;
	local XComGameState_Unit					TargetUnit;
	local XComGameState_Item					SourceWeapon;
	local XComGameState_Item					BIT_ItemState;
	local XComGameState_Effect_TransferWeapon	TransferWeaponEffect;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	SourceUnit = XComGameState_Unit(GetGameStateForObjectID(NewGameState, class'XComGameState_Unit', ApplyEffectParameters.SourceStateObjectRef));

	SourceWeapon = SourceUnit.GetItemInSlot(class'X2StrategyElement_BITHeavyWeaponSlot'.default.BITHeavyWeaponSlot, NewGameState);
	SourceWeapon = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', SourceWeapon.ObjectID));
	TransferWeaponEffect = XComGameState_Effect_TransferWeapon(NewEffectState);

	BIT_ItemState = XComGameState_Item(GetGameStateForObjectID(NewGameState, class'XComGameState_Item', ApplyEffectParameters.ItemStateObjectRef));
	
	if (TargetUnit != none && SourceUnit != none && SourceWeapon != none && TransferWeaponEffect != none && BIT_ItemState != none)
	{	
		TransferWeaponEffect.ForwardTransfer(SourceUnit, SourceWeapon, TargetUnit, BIT_ItemState.GetReference(), NewGameState);
		BIT_ItemState.AttachedUnitRef = TargetUnit.GetReference();
	}

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Effect_TransferWeapon	TransferWeaponEffect;

	TransferWeaponEffect = XComGameState_Effect_TransferWeapon(RemovedEffectState);
	if (TransferWeaponEffect != none)
	{
		TransferWeaponEffect.BackwardTransfer(NewGameState);
	}

	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);
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

defaultproperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "X2Effect_TransferWeapon_Effect"
	GameStateEffectClass = class'XComGameState_Effect_TransferWeapon'
}