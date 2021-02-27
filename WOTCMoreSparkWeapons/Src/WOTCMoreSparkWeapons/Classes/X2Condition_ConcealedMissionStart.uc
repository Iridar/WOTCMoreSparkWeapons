class X2Condition_ConcealedMissionStart extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{	
	local MissionSchedule ActiveMissionSchedule;

	`TACTICALMISSIONMGR.GetActiveMissionSchedule(ActiveMissionSchedule);

	if (ActiveMissionSchedule.XComSquadStartsConcealed)
	{
		return 'AA_Success'; 
	}

	return 'AA_AbilityUnavailable';
}
