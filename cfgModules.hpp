#include "\AC\defines\commonDefines.inc"

class AC_ModuleBase: Module_F
{
	scope = 1;
	displayName = "ModuleBase";
	icon = "\a3\Missions_F_Curator\data\img\iconMPTypeSectorControl_ca.paa";
	category = "AC_ArmaCommander";
	isGlobal = 2;
	isTriggerActivated = 0;
	isDisposable = 0;
	is3DEN = 1;

	class Attributes: AttributesBase
	{
		class ModuleDescription: ModuleDescription {};
	};

	class ModuleDescription: ModuleDescription
	{
		description = "Empty description.";
 	};
};

class AC_ModuleBattalion: AC_ModuleBase
{
	displayName = "Battalion";
	icon = "\a3\Modules_f\data\iconHQ_ca.paa";
	scope = 2;
	//function = "AC_fnc_moduleBattalion";

	class Attributes: AttributesBase
	{
		class Side: Combo
		{
			property = "AC_ModuleBattalion_Side";
			displayName = "Side";
			tooltip = "Which side the battalion belongs.";
			typeName = "NUMBER";
			defaultValue = "1";
			class Values
			{
				class WEST			{name = "WEST"; value = 1;};
				class EAST			{name = "EAST"; value = 0;};
				class RESISTANCE	{name = "INDEPENDENT"; value = 2;};
			};
		};
		class Role: Combo
		{
			property = "AC_ModuleBattalion_Role";
			displayName = "Role";
			tooltip = "What is the combat role of the battalion?";
			typeName = "NUMBER";
			defaultValue = "1";
			class Values
			{
				class Attacker {name = "Attacker"; value = 1;};
				class Defender {name = "Defender"; value = 0;};
			};
		};

		class Points: Edit
		{
			property = "AC_ModuleBattalion_Points";
			displayName = "Requisition Points";
			tooltip = "How much resources battalion has from the start.";
			typeName = "NUMBER";
			defaultValue = "50";
		};
		class BasicIncome: Edit
		{
			property = "AC_ModuleBattalion_Income";
			displayName = "Basic Income";
			tooltip = "Basic income of the battalion added every tick.";
			typeName = "NUMBER";
			defaultValue = "5";
		};
		class Reserves: Edit
		{
			property = "AC_ModuleBattalion_Reserves";
			displayName = "Reserves";
			tooltip = "How much to multiply reserve counts by, 0 for default based on unit cap.";
			typeName = "NUMBER";
			defaultValue = "0";
		};

		class Type: Combo
		{
			property = "AC_ModuleBattalion_Type";
			displayName = "Type";
			tooltip = "What type of troops battalion consists.";
			typeName = "NUMBER";
			defaultValue = "0";
			class Values
			{
				class Militia_FIA		{name = "FIA Militia Battalion"; value = MILITIA_FIA;};
				class Recon_B			{name = "NATO Ranger Battalion"; value = RECON_B;};
				class Tank_B			{name = "NATO Mechanized Battlion"; value = TANK_B;};
				class Tank_B_W			{name = "NATO Mechanized Battlion (Woodland)"; value = TANK_B_W;};
				class Recon_O 			{name = "CSAT Recon Battalion"; value = RECON_O};
				class Infantry_O 		{name = "CSAT Guard Infantry Battalion"; value = INFANTRY_O};
				class Tank_O 			{name = "CSAT Tank Battalion"; value = TANK_O};
				class Spetsnaz_O 		{name = "Spetsnaz Battalion"; value = SPETSNAZ_O};
				class Mechanized_I		{name = "AAF Mechanized Battalion"; value = MECHANIZED_I};
				class Militia_Syndikat	{name = "Syndikat Militia Battalion"; value = MILITIA_SYNDIKAT;};
				class LDF	{name = "Livonian Defense Battalion"; value = LDF};
				class Custom			{name = "Custom Battalion"; value = CUSTOM;};
			};
		};

		class ModuleDescription: ModuleDescription{};
	};
	class ModuleDescription: ModuleDescription
	{
		description = "Battalion module. You can place two battalions into game as maximum.";
	};
};

class AC_ModuleACBase: AC_ModuleBase
{
	displayName = "Base";
	icon = "\a3\Modules_f\data\iconSector_ca.paa";
	scope = 2;

	canSetArea = 1;
	class AttributeValues
	{
		size3[] = {50, 50, -1};
	};

	class Attributes: AttributesBase
	{
		class Callsign: Edit
		{
			property = "AC_ModuleBattalion_Callsign";
			displayName = "Name";
			tooltip = "Name of the base (optional).";
			typeName = "STRING";
			defaultValue = """""";
		};

		class side: Combo
			{
			property = "AC_ModuleACBase_Side";
			displayName = "Side";
			tooltip = "Owner of the base";
			typeName = "NUMBER"; // Value type, can be "NUMBER", "STRING" or "BOOL"
			defaultValue = "1";
			class Values
			{
				class WEST			{name = "WEST"; value = 1;};
				class EAST			{name = "EAST"; value = 0;};
				class RESISTANCE	{name = "INDEPENDENT"; value = 2;};
				class EMPTY			{name = "EMPTY"; value = 8;};
			};
		};

		class nSoldiers: Edit
			{
			property = "AC_ModuleACBase_Garrison";
			displayName = "Garrison";
			tooltip = "Number of soldiers guarding the base.";
			typeName = "NUMBER"; // Value type, can be "NUMBER", "STRING" or "BOOL"
			defaultValue = "10"; // Default attribute value.
		};

		class BaseValue: Edit
		{
			property = "AC_ModuleBase_BaseValue";
			displayName = "Value";
			tooltip = "How much Requisition Points this base give.";
			typeName = "NUMBER";
			defaultValue = "1";
		};

		class Shutdown: Edit
		{
			property = "AC_ModuleBase_BaseSpawnShutdown";
			displayName = "Shutdown";
			tooltip = "How close enemies can be before base cannot spawn. (Uses scenario default if 0)";
			typeName = "NUMBER";
			defaultValue = "0";
		};

		class hidden: Combo
		{
			property = "AC_ModuleBase_Hidden";
			displayName = "Show to enemy";
			tooltip = "Show the base to all sides. Otherwise he has to find it first to see it.";
			typeName = "NUMBER";
			defaultValue = "0";
			class Values
			{
				class hide	{name = "Hide"; value = 1;};
				class show	{name = "Show"; value = 0;};
			};
		};

		class noIncome: Combo
		{
			property = "AC_ModuleBase_Income";
			displayName = "Produce Income";
			tooltip = "The base produces income points.";
			typeName = "NUMBER";
			defaultValue = "0";
			class Values
			{
				class hide	{name = "No"; value = 1;};
				class show	{name = "Yes"; value = 0;};
			};
		};

		class noVictory: Combo
		{
			property = "AC_ModuleBase_Victory";
			displayName = "Produce Victory";
			tooltip = "The base produces victory points.";
			typeName = "NUMBER";
			defaultValue = "0";
			class Values
			{
				class hide	{name = "No"; value = 1;};
				class show	{name = "Yes"; value = 0;};
			};
		};

		class noSpawn: Combo
		{
			property = "AC_ModuleBase_Spawn";
			displayName = "Allow Spawn";
			tooltip = "The base can spawn and resupply units.";
			typeName = "NUMBER";
			defaultValue = "0";
			class Values
			{
				class hide	{name = "No"; value = 1;};
				class show	{name = "Yes"; value = 0;};
			};
		};

		class ModuleDescription: ModuleDescription{}; // Module description should be shown last
	};
	class ModuleDescription: ModuleDescription
	{
		description = "Base module. It can be any place ready to be defended."; // Short description, will be formatted as structured text
		sync[] = {"All"};
	};
};

class AC_ModuleAcGame: AC_ModuleBase
{
	displayName = "Arma Commander Game Mode";
	icon = "\A3\modules_f\data\iconStrategicMapMission_ca.paa";
	function = "AC_fnc_moduleAcGame";
	scope = 2;
	class Attributes: AttributesBase
	{
		class GameMode: Combo
		{
			property = "AC_ModuleAcGame_Mode";
			displayName = "Game Mode";
			tooltip = "Select rulesets for the game mode.";
			typeName = "NUMBER";
			defaultValue = "0";
			class Values
			{
				class Classic	{name = "Classic: Timed battle"; value = GAME_MODE_CLASSIC};
				class LastStand	{name = "Last Stand: Capture all enemy bases or survive the time"; value = GAME_MODE_LAST_STAND};
				class Custom {name = "Custom: Write your own rules"; value = GAME_MODE_CUSTOM};
			};
		};
		class UnitCap: Edit
		{
			property = "AC_ModuleAcGame_UnitCap";
			displayName = "Maximum deployed groups";
			tooltip = "Set how many group from one battalion can be on the battlefield at one moment.";
			typeName = "NUMBER";
			defaultValue = "10";
		};

		class Length: Combo
		{
			property = "AC_ModuleAcGame_Length";
			displayName = "Scenario time";
			tooltip = "How long before before scenario ends.";
			typeName = "NUMBER";
			defaultValue = "3600";
			class Values
			{
				class L0	{name = "Unlimited"; value = -100;};
				class L15	{name = "15 Minutes"; value = 900;};
				class L20	{name = "20 Minutes"; value = 1200;};
				class L30	{name = "30 Minutes"; value = 1800;};
				class L45	{name = "45 Minutes"; value = 2700;};
				class L60	{name = "1 Hour"; value = 3600;};
				class L90	{name = "1.5 Hours"; value = 5400;};
				class L120	{name = "2 Hours"; value = 7200;};
				class L180	{name = "3 Hours"; value = 10800;};
				class L240	{name = "4 Hours"; value = 14400;};
				class L360	{name = "10 Hours"; value = 36000;};
			};
		};

		class IncomeRate: Combo
		{
			property = "AC_ModuleAcGame_Income";
			displayName = "Income";
			tooltip = "How often will battalion recieve resources.";
			typeName = "NUMBER";
			defaultValue = "120";
			class Values
			{
				class VeryHigh	{name = "Every 30 seconds"; value = 30;};
				class High		{name = "Every minute"; value = 60;};
				class Medium	{name = "Every 2 minutes"; value = 120;};
				class MedLow	{name = "Every 3 minutes"; value = 180;};
				class Low		{name = "Every 4 minutes"; value = 240;};
				class VeryLow	{name = "Every 5 minutes"; value = 300;};
				class Min1		{name = "Every 8 minutes"; value = 480;};
				class Min2		{name = "Every 10 minutes"; value = 600;};
				class Min3		{name = "Every 15 minutes"; value = 900;};
				class Min4		{name = "Every 20 minutes"; value = 1200;};
				class Min5		{name = "Every 30 minutes"; value = 1800;};
			};
		};

		class IncomeMultiplier: Edit
		{
			property = "AC_ModuleAcGame_Multiply";
			displayName = "Income Multiplier";
			tooltip = "How much should every base give player by default.";
			typeName = "NUMBER";
			defaultValue = "1";
		};

		class Debug: Checkbox
		{
			displayName = "Debug Mode";
			property = "AC_ModuleAcGame_Debug";
			tooltip = "Enable debug mode for development and testing";
			typeName = "BOOL";
			defaultValue = "false";
		};

		class ModuleDescription: ModuleDescription{};
	};

	class ModuleDescription: ModuleDescription
	{
		description = "Game mode module - serves for setting scenario parameters.";
	};
};

class AC_ModuleRegisterGroup: AC_ModuleBase
{
	displayName = "Register Battalion Group";
	icon = "\A3\modules_f\data\iconStrategicMapMission_ca.paa";
	scope = 2;
	class Attributes: AttributesBase
	{
		class Name: Edit
		{
			displayName = "Name";
			property = "AC_ModuleRegisterGroup_Name";
			tooltip = "Name of the group shown in reuisition panel. Must be unique!";
			typeName = "STRING";
			defaultValue = """""";
		};
		class Tooltip: Edit
		{
			displayName = "Tooltip";
			property = "AC_ModuleRegisterGroup_Tooltip";
			tooltip = "Tooltip describing abilities of the group for the requisition panel.";
			typeName = "STRING";
			defaultValue = """""";
		};

		class Side: Combo
		{
			displayName = "Side";
			property = "AC_ModuleRegisterGroup_Side";
			tooltip = "What side to register to.";
			typeName = "NUMBER";
			defaultValue = "1";
			class Values
			{
				class West	{name = "BLUFOR"; 		value = 1;};
				class East	{name = "OPFOR"; 		value = 0;};
				class Indep	{name = "INDEPENDENT"; 	value = 2;};
			};
		};

		class Type: Combo
		{
			displayName = "Group Type";
			property = "AC_ModuleRegisterGroup_Type";
			tooltip = "Type of the group.";
			typeName = "NUMBER";
			defaultValue = "0";
			class Values
			{
				class Inf	{name = "Infantry";		value = TYPE_INFANTRY;};
				class Motor	{name = "Motorized"; 	value = TYPE_MOTORIZED;};
				class Air	{name = "Air"; 	value = TYPE_AIR;};
				class Art	{name = "Artillery"; value = TYPE_ARTILLERY;};
			};
		};

		class Marker: Edit
		{
			displayName = "NATO Marker";
			property = "AC_ModuleRegisterGroup_Marker";
			tooltip = "Icon of the group. Any icon can be used, NATO markers are recommended.";
			typeName = "STRING";
			defaultValue = """\A3\ui_f\data\map\markers\nato\n_inf.paa""";
		};

		class Cost: Edit
		{
			displayName = "Cost";
			property = "AC_ModuleRegisterGroup_Cost";
			tooltip = "Cost of buying the group.";
			typeName = "NUMBER";
			defaultValue = "20";
		};
		class Count: Edit
		{
			displayName = "Count";
			property = "AC_ModuleRegisterGroup_Count";
			tooltip = "How many times the group can be requested.";
			typeName = "NUMBER";
			defaultValue = "4";
		};
		class Skill: Edit
		{
			displayName = "Skill";
			property = "AC_ModuleRegisterGroup_Skill";
			tooltip = "Overall skill of the group.";
			typeName = "NUMBER";
			defaultValue = "0.4";
		};
		class Condition: Edit
		{
			displayName = "Spawn Condition";
			property = "AC_ModuleRegisterGroup_Condition";
			tooltip = "What condition has to be fulfilled to be able to spawn group.";
			typeName = "STRING";
			defaultValue = """true""";
		};
		class AirSpawn: Checkbox
		{
			displayName = "Spawn on Parachutes";
			property = "AC_ModuleRegisterGroup_Air";
			tooltip = "Spawn on parachutes mid air";
			typeName = "BOOL";
			defaultValue = "true";
		};
		class Loadouts: Checkbox
		{
			displayName = "Save Modified Loadouts";
			property = "AC_ModuleRegisterGroup_Loadouts";
			tooltip = "Save any modifications of unit loadouts. Warning: This feature can have big impact on MP stability.";
			typeName = "BOOL";
			defaultValue = "false";
		};
		class Transport: Checkbox
		{
			displayName = "Unarmed Utility";
			property = "AC_ModuleRegisterGroup_Transport";
			tooltip = "This is an unarmed utility or transport group. Mostly for AI strategy info";
			typeName = "BOOL";
			defaultValue = "false";
		};

		class ModuleDescription: ModuleDescription{};
	};
	class ModuleDescription: ModuleDescription
	{
		description = "Adds group to Custom Battalion of specified side. Use it by synchronizing group leader to the module, group will then be available in requisition tab in the mission.";
	};
};

class AC_ModuleCustomBattalion: AC_ModuleBase
{
	displayName = "Create Custom Battalion";
	icon = "\A3\modules_f\data\iconStrategicMapMission_ca.paa";
	scope = 2;
	class Attributes: AttributesBase
	{
		class Side: Combo
		{
			displayName = "Side";
			property = "AC_ModuleCustomBat_Side";
			tooltip = "How long before before scenario ends.";
			typeName = "NUMBER";
			defaultValue = "1";
			class Values
			{
				class West	{name = "BLUFOR"; 		value = 1;};
				class East	{name = "OPFOR"; 		value = 0;};
				class Indep	{name = "INDEPENDENT"; 	value = 2;};
			};
		};

		class Faction: Edit
		{
			displayName = "Faction Name";
			property = "AC_ModuleCustomBat_Faction";
			tooltip = "Name of the group shown in reuisition panel. Must be unique!";
			typeName = "STRING";
			defaultValue = """""";
		};
		class Flag: Edit
		{
			displayName = "Battalion Flag";
			property = "AC_ModuleCustomBat_Flag";
			tooltip = "Flag texture that will fly on masts at your bases.";
			typeName = "STRING";
			defaultValue = """\a3\Data_F_Exp\Flags\flag_VIPER_CO.paa""";
		};
		class BatIcon: Edit
		{
			displayName = "Battalion Icon";
			property = "AC_ModuleCustomBat_BatIcon";
			tooltip = "Smaller square icon of the faction. You can find examples of these in CfgFactionClasses.";
			typeName = "STRING";
			defaultValue = """\a3\Data_F_Exp\FactionIcons\icon_VIPER_CA.paa""";
		};
		class Skill: Edit
		{
			displayName = "Base Defenders Skill";
			property = "AC_ModuleCustomBat_Skill";
			tooltip = "Skill of base defenders.";
			typeName = "NUMBER";
			defaultValue = "0.4";
		};
		class Modifier: Edit
		{
			displayName = "Base Defenders Price";
			property = "AC_ModuleCustomBat_Price";
			tooltip = "Price per unit to reinforce base defenders.";
			typeName = "NUMBER";
			defaultValue = "1.0";
		};
		class Loadouts: Checkbox
		{
			displayName = "Save Modified Loadouts";
			property = "AC_ModuleBattalion_Loadouts";
			tooltip = "Save any modifications of unit loadouts. Warning: This feature can have big impact on MP stability.";
			typeName = "BOOL";
			defaultValue = "false";
		};

		class ModuleDescription: ModuleDescription{};
	};
	class ModuleDescription: ModuleDescription
	{
		description = "Adds custom battalion, which can have any properties and units you want. To create groups for the battalion, register custom groups of the same side. n\To register base defenders, synchdonize place units you want into editor and sync them with this module.";
	};
};

class AC_ModuleArtillerySupport: AC_ModuleBase
{
	displayName = "Artillery Support";
	icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\destroy_ca.paa";
	scope = 2;
	class Attributes: Attributes
	{
		class Side: Combo
		{
			displayName = "Side";
			property = "AC_ModuleArtillerySupport_Side";
			tooltip = "How long before before scenario ends.";
			typeName = "NUMBER";
			defaultValue = "1";
			class Values
			{
				class West	{name = "BLUFOR"; 		value = 1;};
				class East	{name = "OPFOR"; 		value = 0;};
				class Indep	{name = "INDEPENDENT"; 	value = 2;};
			};
		};
		class Name: Edit
		{
			displayName = "Name";
			property = "AC_ModuleArtillerySupport_Name";
			tooltip = "Supports name.";
			typeName = "STRING";
			defaultValue = """""";
		};
		class Tooltip: Edit
		{
			displayName = "Tooltip";
			property = "AC_ModuleArtillerySupport_Tooltip";
			tooltip = "Tooltip shown on the supports.";
			typeName = "STRING";
			defaultValue = """""";
		};
		class Ammo: Edit
		{
			displayName = "Ammunition fired";
			property = "AC_ModuleArtillerySupport_Ammo";
			tooltip = "Ammo that is being shot. Find proper ammo type in CfgAmmo, for example 'Sh_155mm_AMOS'.";
			typeName = "STRING";
			defaultValue = """""";
		};
		class nRounds: Edit
		{
			displayName = "Rouds per salvo";
			property = "AC_ModuleArtillerySupport_nRounds";
			tooltip = "How many rounds per one artillery support is fired.";
			typeName = "NUMBER";
			defaultValue = """""";
		};
		class Radius: Edit
		{
			displayName = "Radius";
			property = "AC_ModuleArtillerySupport_Radius";
			tooltip = "Impact radius, in which shells will land.";
			typeName = "NUMBER";
			defaultValue = """""";
		};
		class Cost: Edit
		{
			displayName = "Cost";
			property = "AC_ModuleArtillerySupport_Cost";
			tooltip = "Cost that commander has to pay for every call of the support.";
			typeName = "NUMBER";
			defaultValue = """""";
		};
		class Timeout: Edit
		{
			displayName = "Timeout (seconds)";
			property = "AC_ModuleArtillerySupport_Timeout";
			tooltip = "How long has to commander wait after using the support.";
			typeName = "NUMBER";
			defaultValue = """""";
		};
		class Condition: Edit
		{
			displayName = "Spawn Condition";
			property = "AC_ModuleArtillerySupport_Condition";
			tooltip = "What condition has to be fulfilled to be able to spawn artillery support.";
			typeName = "STRING";
			defaultValue = """true""";
		};
		class ModuleDescription: ModuleDescription{};
	};
	class ModuleDescription: ModuleDescription
	{
		description = "This module creates combat support for battalion of the given side.";
	};
};

class AC_ModuleCAS: AC_ModuleBase
{
	displayName = "Close Air Support";
	icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\plane_ca.paa";
	scope = 2;
	class Attributes: AttributesBase
	{
		class Side: Combo
		{
			displayName = "Side";
			property = "AC_ModuleCAS_Side";
			tooltip = "Side.";
			typeName = "NUMBER";
			defaultValue = "1";
			class Values
			{
				class West	{name = "BLUFOR"; 		value = 1;};
				class East	{name = "OPFOR"; 		value = 0;};
				class Indep	{name = "INDEPENDENT"; 	value = 2;};
			};
		};
		class Name: Edit
		{
			displayName = "Name";
			property = "AC_ModuleCAS_Name";
			tooltip = "Supports name.";
			typeName = "STRING";
			defaultValue = """""";
		};
		class Tooltip: Edit
		{
			displayName = "Tooltip";
			property = "AC_ModuleCAS_Tooltip";
			tooltip = "Tooltip shown on the supports.";
			typeName = "STRING";
			defaultValue = """""";
		};
		class Aircraft: Edit
		{
			displayName = "Supporting Aircraft";
			property = "AC_ModuleCAS_aircraft";
			tooltip = "Name of the plane for close air support, for example 'B_Plane_CAS_01_F'";
			typeName = "STRING";
			defaultValue = """""";
		};
		class SupportMode: Combo
		{
			displayName = "Side";
			property = "AC_ModuleCAS_SupportMode";
			tooltip = "What type of ammunition should air support use.";
			typeName = "NUMBER";
			defaultValue = "2";
			class Values
			{
				class Can	{name = "Cannon"; 				value = 0;};
				class Miss	{name = "Missiles"; 			value = 1;};
				class Both	{name = "Cannon and missiles"; 	value = 2;};
				class Bomb	{name = "Bombs";			 	value = 3;};
			};
		};

		class Cost: Edit
		{
			displayName = "Cost";
			property = "AC_ModuleCAS_Cost";
			tooltip = "Cost that commander has to pay for every call of the support.";
			typeName = "NUMBER";
			defaultValue = """""";
		};
		class Timeout: Edit
		{
			displayName = "Timeout (seconds)";
			property = "AC_ModuleCAS_Timeout";
			tooltip = "How long has to commander wait after using the support.";
			typeName = "NUMBER";
			defaultValue = """""";
		};
		class Condition: Edit
		{
			displayName = "Spawn Condition";
			property = "AC_ModuleCAS_Condition";
			tooltip = "What condition has to be fulfilled to be able to spawn CAS.";
			typeName = "STRING";
			defaultValue = """true""";
		};
		class Height: Edit
		{
			displayName = "Fly height";
			property = "AC_ModuleCAS_Height";
			tooltip = "How high should the airplane fly to the CAS mission.";
			typeName = "NUMBER";
			defaultValue = "600";
		};

		class ModuleDescription: ModuleDescription{};
	};
	class ModuleDescription: ModuleDescription
	{
		description = "This module creates combat support for battalion of the given side.";
	};
};

class AC_ModuleRandomLocation: AC_ModuleBase
{
	displayName = "Base Location";
	icon = "\A3\ui_f\data\map\markers\military\start_ca.paa";
	scope = 2;
	class Attributes: AttributesBase
	{
		class Weight: Edit
		{
			displayName = "Randomization Weight";
			property = "AC_ModuleRandomLocation_Weight";
			tooltip = "Assign weight to this location, so it's more likely to be spawned in the area.";
			typeName = "STRING";
			defaultValue = "1";
		};
		class ModuleDescription: ModuleDescription{};
	};
	class ModuleDescription: ModuleDescription
	{
		description = "This module creates combat support for battalion of the given side.";
	};
};
