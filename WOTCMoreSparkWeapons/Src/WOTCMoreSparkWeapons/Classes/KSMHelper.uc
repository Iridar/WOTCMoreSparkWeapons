class KSMHelper extends Object config(KineticStrikeModule);

struct KSMSpecialDeathAnimationStruct
{
	var name CharacterTemplateName;
	var string KillAnimSet;
	var name KillSequence;
	var string DeathAnimSet;
	var name DeathSequence;
	var bool bStrictMatch;
};
var config array<KSMSpecialDeathAnimationStruct> KSMSpecialDeathAnimation;

//class''.static.GetKillAnimationNameForCharacterTemplate();
static public function bool GetKillDeathAnimationNamesForCharacterTemplate(const name CharacterTemplateName, out name AnimName, out name DeathSequence)
{
	local array<int>	ValidIndexArray;
	local bool			bStrictMatch;
	local int			i;

	//	Do a first pass through the config array to determine whether we need to use strict Character Template Name screening for this search.
	//	Strict matching is necessary in case there's some enemy like "Muton" and then there's some enemy like "MutonElite", and we don't want "Muton" animations
	//	To get selected for "MutonElite" kills.
	bStrictMatch = ShouldUseStrictMatchingForCharacterTemplate(CharacterTemplateName);

	//	Build an array of indices of the Config Array members that match the character template name
	for (i = 0; i < default.KSMSpecialDeathAnimation.Length; i++)
	{
		//	Look for a strict character template name match, if required so. Partial match is good enough, otherwise.
		if (bStrictMatch && CharacterTemplateName == default.KSMSpecialDeathAnimation[i].CharacterTemplateName ||
			InStr(CharacterTemplateName, default.KSMSpecialDeathAnimation[i].CharacterTemplateName,, true) != INDEX_NONE)	// Ignore letter case
		{
			ValidIndexArray.AddItem(i);
		}
	}

	//	Select one at random.
	if (ValidIndexArray.Length > 0)
	{
		i = ValidIndexArray[`SYNC_RAND_STATIC(ValidIndexArray.Length)];
		AnimName = default.KSMSpecialDeathAnimation[i].KillSequence;
		DeathSequence = default.KSMSpecialDeathAnimation[i].DeathSequence;

		return true;
	}
	return false;
}

static public function bool GetDeathAnimationNameForCharacterTemplateAndKillName(const name CharacterTemplateName, const name KillSequence, out name AnimName)
{
	local array<int>	ValidIndexArray;
	local bool			bStrictMatch;
	local int			i;

	bStrictMatch = ShouldUseStrictMatchingForCharacterTemplate(CharacterTemplateName);
 
	for (i = 0; i < default.KSMSpecialDeathAnimation.Length; i++)
	{
		if (default.KSMSpecialDeathAnimation[i].KillSequence == KillSequence &&
			(bStrictMatch && CharacterTemplateName == default.KSMSpecialDeathAnimation[i].CharacterTemplateName ||
			InStr(CharacterTemplateName, default.KSMSpecialDeathAnimation[i].CharacterTemplateName,, true) != INDEX_NONE))
		{
			ValidIndexArray.AddItem(i);
		}
	}

	//	Select one at random.
	//	This two step process is necessary in case there are several different death animations for one kill animation.
	if (ValidIndexArray.Length > 0)
	{
		AnimName = default.KSMSpecialDeathAnimation[ValidIndexArray[`SYNC_RAND_STATIC(ValidIndexArray.Length)]].DeathSequence;

		return true;
	}
	return  false;
}

static private function array<string> FindDeathAnimSetsForCharacterTemplate(const name CharacterTemplateName)
{
	local array<string> ReturnArray;
	local bool			bStrictMatch;
	local int i;

	bStrictMatch = ShouldUseStrictMatchingForCharacterTemplate(CharacterTemplateName);

	for (i = 0; i < default.KSMSpecialDeathAnimation.Length; i++)
	{
		if (default.KSMSpecialDeathAnimation[i].DeathAnimSet != "" && (bStrictMatch && CharacterTemplateName == default.KSMSpecialDeathAnimation[i].CharacterTemplateName ||
			InStr(CharacterTemplateName, default.KSMSpecialDeathAnimation[i].CharacterTemplateName,, true) != INDEX_NONE))
		{
			ReturnArray.AddItem(default.KSMSpecialDeathAnimation[i].DeathAnimSet);
		}
	}
	return ReturnArray;
}

static public function AddDeathAnimSetsToCharacterTemplates()
{
    local X2CharacterTemplateManager    CharMgr;
    local X2CharacterTemplate           CharTemplate;
	local array<X2DataTemplate>			DifficultyVariants;
	local X2DataTemplate				DifficultyVariant;
	local X2DataTemplate				DataTemplate;
	local XComContentManager			Content;
	local string						AnimSetPath;
	local array<string>					AnimSetPaths;
	
    //  Get the Character Template Modify
    CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	Content = `CONTENT;

	foreach CharMgr.IterateTemplates(DataTemplate, none)
	{
		AnimSetPaths = FindDeathAnimSetsForCharacterTemplate(DataTemplate.DataName);
		if (AnimSetPaths.Length > 0)
		{
			`LOG("Adding KSM Death Anim Sets to:" @ DataTemplate.DataName,,'WOTCMoreSparkWeapons');
			CharMgr.FindDataTemplateAllDifficulties(DataTemplate.DataName, DifficultyVariants);

			foreach DifficultyVariants(DifficultyVariant)
			{
				CharTemplate = X2CharacterTemplate(DifficultyVariant);
				if (CharTemplate != none)
				{
					foreach AnimSetPaths(AnimSetPath)
					{
						CharTemplate.AdditionalAnimSets.AddItem(AnimSet(Content.RequestGameArchetype(AnimSetPath)));
					}
				}
			}
		}
	}
}

static private function bool ShouldUseStrictMatchingForCharacterTemplate(name CharacterTemplateName)
{
	local int i;

	for (i = 0; i < default.KSMSpecialDeathAnimation.Length; i++)
	{
		if (default.KSMSpecialDeathAnimation[i].bStrictMatch && CharacterTemplateName == default.KSMSpecialDeathAnimation[i].CharacterTemplateName)
		{
			return true;
		}
	}
	return false;
}

static private function array<string> FindKillAnimSets()
{
	local array<string> ReturnArray;
	local int i;

	for (i = 0; i < default.KSMSpecialDeathAnimation.Length; i++)
	{
		if (default.KSMSpecialDeathAnimation[i].KillAnimSet != "")
		{
			ReturnArray.AddItem(default.KSMSpecialDeathAnimation[i].DeathAnimSet);
		}
	}
	return ReturnArray;
}

static public function AddDeathAnimSetsToAbilityTemplate(X2AbilityTemplate Template)
{
	local X2Effect_AdditionalAnimSets	AnimSetEffect;
	local array<string>					AnimSetPaths;
	local string						AnimSetPath;

	AnimSetPaths = FindKillAnimSets();

	if (AnimSetPaths.Length > 0)
	{
		AnimSetEffect = new class'X2Effect_AdditionalAnimSets';
		foreach AnimSetPaths(AnimSetPath)
		{
			AnimSetEffect.AddAnimSetWithPath(AnimSetPath);
		}

		AnimSetEffect.BuildPersistentEffect(1, true, false, false);
		Template.AddTargetEffect(AnimSetEffect);
	}
}