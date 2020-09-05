Created by Iridar, as voted by patrons.

More info at: https://www.patreon.com/Iridar

[WOTC] Iridar's SPARK Arsenal
Adds new weapons and tools for SPARKs and [b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=1452700934]MEC Troopers[/url][/b], a new Inventory Slot, and makes some changes to BITs.

[b][url=https://steamcommunity.com/workshop/filedetails/discussion/2127166233/2568690416483865842/]>>> CLICK HERE FOR THE FULL LIST OF NEW WEAPONS, ITEMS AND OTHER FEATURES <<<[/url][/b]+

[b]New Primary Weapons:[/b][list]
[*] Heavy Cannons (3 tiers)[/list]

[b]New Secondary Weapons:[/b][list]
[*] Ordnance Launchers (3 tiers)
[*] Kinetic Strike Module
[*] Munitions Mount (2 tiers)[/list]

[b]New Heavy Weapons:[/b][list]
[*] Kiruka Autogun
[*] Kiruka Autopulser[/list]

[b]Arm Cannon animations for SPARK / MEC Heavy Weapons[/b]

[b]New Inventory Slot: Auxiliary Weapon[/b]

[b]New items that go into that slot:[/b][list]
[*] Restorative Mist
[*] E.M. Pulse
[*] Special Shells for Heavy Cannons (3 variants, each has 2 tiers)[/list]

[b]New Weapon Upgrade: Experimental Magazine - grants an Ammo Slot.[/b]

[b]New Experimental Ammo: Sabot Rounds[/b]

[b]BIT Changes:[/b][list]
[*] Active Camo passive ability
[*] Grants more Hacking
[*] Fixed bug that prevented BIT's bonus to Hacking from showing up in the Armory[/list]

[b]Shredder Gun, Shredstorm Cannon and Plasma Blaster heavy weapons now properly knockback enemies on kills.[/b]

[b]SPARKs and MEC Troopers can now Hack objectives without having a BIT equipped.[/b]

[h1]BALANCING[/h1]

This mod is a significant buff to SPARKs' and MECs' power. However, it is created around the expectation that SPARKs and MEC Troopers do not have Utility Slots. So if another mod adds some Utility Slots, abd lets you carry more than 2-3 grenades/rockets, please do not complain that it's overpowered, that is not the intended behavior for this mod. The mod does support grenades/rockets in Utility Slots, if that's what you want to do.

[h1]REQUIREMENTS[/h1]
[list]
[*] [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1796402257][b][BETA] X2WOTCCommunityHighlander[/b][/url] v1.21 or higher is required ([b][url=https://steamcommunity.com/workshop/filedetails/discussion/2127166233/2442587820564618365/]here are instructions[/url][/b] on how to configure the mod to work with older Highlander versions)
[*] [b]Shen's Last Gift DLC[/b] is required. 
[*] [b]Alien Hunters DLC[/b] - I used a few assets from it, so it's probably required, though the mod might still function without it.[/list]

[h1]COMPANION MODS[/h1]
[list]
[*] [b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=1775963384][WOTC] Rocket Launchers 2.0[/url][/b] - fully supported. This mod enables SPARKs to carry, Take, Arm and Give rockets, as well as Fire them with the Ordnance Launcher. SPARKs do not suffer movement penalties for carrying rockets. All rockets are supported, including the Tactical Elerium Nuke. Judgement Day is upon ADVENT.
[*] [b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=1161324428]SPARK Launchers Redux[/url][/b] - can be carried in the Auxiliary Weapon Slot. 
[*] [b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=2025780967][WOTC] Iridar's Scatter Mod[/url][/b] - adds scatter to grenades and rockets and HE/HESH Heavy Cannon shots.[/list]

[h1]COMPATIBILITY[/h1]

I tried to keep the mod as compatible as possible, including all the major overhauls. For compatibility notes with specific mods please [b][url=https://steamcommunity.com/workshop/filedetails/discussion/2127166233/2442587820564618365/]go here[/url][/b].

[h1]CONFIGURATION[/h1]

The mod is [b][i]highly[/i][/b] configurable through various files in:
[code]..\steamapps\workshop\content\268500\2127166233\Config\[/code]

[h1]MOD STATUS[/h1]

Currently hard at work making this mod more awesome. Stay tuned for updates.

[h1]CREDITS[/h1]

First of all, huge thanks to my [b][url=https://www.patreon.com/Iridar]patrons on patreon[/url][/b] for producing this mod. It's a [b][i]blast[/i][/b] to work with so many wonderful people. Particularly:
[b]Arkhangel[/b], [b]lago508[/b], [b]Chris the Thin Mint[/b] and [b]Wolfcub05[/b] - feedback and ideas.
[b]Kiruka[/b] - a long time patron, requested the Autogun to make SPARKs better equipped to deal with the Lost. I named the weapon after her as a sign of appreciation for her support.

And thanks to comrades in arms:
[b]Musashi[/b] - for graciously providing the custom death animation code. 
[b]NeIVIeSiS[/b] - for making many of the icons for this mod.
[b]bstar[/b] - brainstorm assistance.






[h1]KSM Custom Death Animations[/h1]

When [b]Kinetic Strike[/b] ability kills an enemy, custom kill/death animations will play, if possible. These custom animations may inexplicably fail to play in some circumstances, in which case the game should default to regular kill/death animations.

Custom animations are configured via [b]XComKineticStrikeModule.ini[/b] by adding [b]KSMSpecialDeathAnimation[/b] entries, for example:

[WOTCMoreSparkWeapons.KSMHelper]
+KSMSpecialDeathAnimation = (CharacterTemplateName = "AdvTrooper", KillSequence = "FF_KSMKill_TrooperA", DeathSequence = "FF_KSMDeath_TrooperA", DeathAnimSet = "IRIKineticStrikeModule.Anims.AS_Trooper_Death")

Currently available parameters are:[list]
[*] [b]CharacterTemplateName[/b] - character template name of the unit that should play the custom death animation when killed by Kinetic Strike. By default, partially matching template names are accepted. E.g. "AdvTrooper" will work for AdvTrooperM1, AdvTrooperM2 and AdvTrooperM3.
[*] [b]bStrictMatch[/b] - if this is "true", only character templates with exactly matching template names will be accepted. This can be used, for example, if you want a "Muton" to be affected, but a "MutonCenturion" - not.
[*] [b]KillAnimSet[/b] - path to an AnimSet that will contain a custom kill animation that will be used by the SPARK / MEC Trooper. It's not necessary to specify the AnimSet if it is already applied to the unit via any means. Refer to "IRIKineticStrikeModule.Anims.AS_KSM_Pawn" for examples on how custom kill animations should look like. Note that in this case the NotifyTarget (UnitHit) AnimNotify will signal the game when to start playing the custom death animation.
[*] [b]KillSequence[/b] - name of the animsequence that will be played by the unit to kill the target. 
[*] [b]DeathAnimSet[/b] - path to an AnimSet that will contain a custom death animation. Similarly, there is no need to specify the path if the target already has that AnimSet applied.
[*] [b]DeathSequence[/b] - name of the custom death animsequence.
[/list]

If a character template has several KSMSpecialDeathAnimation entries, one will be selected at random each time the unit of that template is killed.

[h1]Mod Compatibility[/h1]

[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1499767042][b][WOTC] Mechatronic Warfare: Total SPARK Overhaul[/b][/url]

Fully supported. [b]Bombardment[/b] ability can be used with Ordnance Launchers instead of the BIT, but then it will behave exactly the same as vanilla SPARK Bombard ability.

[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1537675645][b]A Better Barracks: TLE[/b][/url]

Nothing incompatible on the first glance, but no playtesting has been done.

[b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=1452700934]MEC Troopers[/url][/b]

Fully supported, except for soldiers' facial expressions during custom animations added by the Arsenal mod.

[b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=1125117203]Metal Over Flesh Redux[/url][/b]

Compatible. [b]Heavy Weapon Storage[/b] perk does not affect Heavy Weapons in the auxilary slot, and I'm fine with that.

[url=https://steamcommunity.com/sharedfiles/filedetails/?id=1383408046][b]Honey's Heavy Support Items [WOTC][/b][/url]

Compatible, but not supported in the Auxiliary Weapon slot. Same goes for [b][i]ALL[/i][/b] mod-added Heavy Weapons.

[url=https://steamcommunity.com/sharedfiles/filedetails/?id=2025780967][b][WOTC] Iridar's Scatter Mod[/b][/url]

I included some copy-pasted config that will add scatter to grenades launched via Ordnance Launcher.