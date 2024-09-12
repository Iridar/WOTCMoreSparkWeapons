class X2Action_UpdateUnitLoadout extends X2Action;

var private XComGameState_Unit UnitState;

function Init()
{
	super.Init();

	UnitState = XComGameState_Unit(StateChangeContext.AssociatedState.GetGameStateForObjectID(Unit.ObjectID));
}


simulated state Executing
{
Begin:
	
	Unit.ApplyLoadoutFromGameState(UnitState, StateChangeContext.AssociatedState);
	CompleteAction();
}
