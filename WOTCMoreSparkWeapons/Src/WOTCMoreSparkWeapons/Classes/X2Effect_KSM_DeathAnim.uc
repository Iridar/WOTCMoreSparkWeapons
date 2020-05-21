class X2Effect_KSM_DeathAnim extends X2Effect_AdditionalAnimSets;

simulated function X2Action AddX2ActionsForVisualization_Death(out VisualizationActionMetadata ActionMetadata, XComGameStateContext Context)
{
	local X2Action_PlayAnimation		PlayAnimation;

	//if( DeathActionClass != none && DeathActionClass.static.AllowOverrideActionDeath(ActionMetadata, Context))
	//{
		PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		PlayAnimation.Params.AnimName = 'HL_MeleeDeathA';
		PlayAnimation.Params.BlendTime = 0.3f;

		//AddAction = class'X2Action'.static.CreateVisualizationActionClass( DeathActionClass, Context, ActionMetadata.VisualizeActor );

		//class'X2Action'.static.AddActionToVisualizationTree(AddAction, ActionMetadata, Context, false, ActionMetadata.LastActionAdded);
	//}

	return PlayAnimation;
}

defaultproperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "X2Effect_KSM_DeathAnim_Effect"
}