class XComPrecomputedPathWithBlackJackAndHookers extends XComPrecomputedPath;

//	Made with help from Musashi

simulated event Tick(float DeltaTime)
{	
	local float PathLength;

	if(kRenderablePath.HiddenGame)
	{
		return;
	}
	if (m_bBlasterBomb)
	{
		CalculateBlasterBombTrajectoryToTarget();
	}
	else
	{
		UpdateTrajectory();
	}

	UpdateSplineInfo();

	DrawPath();

	

	if( bSplineDirty || true)
	{
		PathLength = akKeyframes[iNumKeyframes - 1].fTime - akKeyframes[0].fTime;
		kRenderablePath.UpdatePathRenderData(kSplineInfo,PathLength,none,`CAMERASTACK.GetCameraLocationAndOrientation().Location);
		bSplineDirty = FALSE;
	}
}

private function UpdateSplineInfo()
{
	local InterpCurvePointVector CurvePoint;
	local float Alpha;
	local int i;

	kSplineInfo.Points.Length = 0;
	CurvePoint.InterpMode = CIM_CurveAuto;

	for (i = 0; i < iNumKeyframes; i++)
	{	
		Alpha = float(i) / float(iNumKeyframes);		

		CurvePoint.InVal = Alpha;
		CurvePoint.OutVal = akKeyframes[i].vLoc;
		kSplineInfo.Points.AddItem(CurvePoint);
	}	
}