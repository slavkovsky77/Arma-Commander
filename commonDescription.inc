#include "\AC\defines\commonDefines.inc"

//disabledAI = 1;
//enableDebugConsole = 2;

// Respawn settings
respawn = "INSTANT";
respawnTemplates[] = {};
respawnOnStart = 0;
respawnDialog = 0;
respawnDelay = 10e10;

// Revive settings
ReviveMode = 1;                         //0: disabled, 1: enabled, 2: controlled by player attributes
ReviveUnconsciousStateMode = 0;         //0: basic, 1: advanced, 2: realistic
ReviveRequiredTrait = 0;                //0: none, 1: medic trait is required
ReviveRequiredItems = 0;                //0: none, 1: medkit, 2: medkit or first aid kit
ReviveRequiredItemsFakConsumed = 0;     //0: first aid kit is not consumed upon revive, 1: first aid kit is consumed
ReviveDelay = 10;                       //time needed to revive someone (in secs)
ReviveMedicSpeedMultiplier = 2;         //speed multiplier for revive performed by medic
ReviveForceRespawnDelay = 3;            //time needed to perform force respawn (in secs)
ReviveBleedOutDelay = 120;              //unconscious state duration (in secs)

// Garbage collection
corpseManagerMode = 1;
corpseLimit = 30;
corpseRemovalMinTime = 30;
corpseRemovalMaxTime = 600;
wreckManagerMode = 1;
wreckLimit = 6;
wreckRemovalMinTime = 60;
wreckRemovalMaxTime = 6000;
minPlayerDistance = 50;

// Params
class Params
{
	class Daytime
	{
		title = "Time";
		texts[] = {"00:00","01:00","02:00","03:00","04:00","05:00","06:00","07:00","08:00","09:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00","Random","Random Day","Default"};
		values[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,24,26};
		default = 26;
		//function = "BIS_fnc_paramDaytime";
	};

	//#include "\a3\functions_f\Params\paramWeather.hpp"

	class Percepitation
	{
		title = "Percepitation";
		values[] = {-1,1,2,3,4,5,6,7,8};
		texts[] = {"Default","Cloudless","Clear","Partial Clouds","Showers","Cloudy","Rainy","Downpour","Stormy"};
		default = -1;
 	};

	class Fog
	{
		title = "Fog and Wind";
		values[] = {-1,1,2,3,4,5,6,7,8,9};
		texts[] = {"Default","Still","Hazy","Thin Fog","Thick Fog","Drifting Fog","Valley Fog","High Fog","Windy","High Winds"};
		default = -1;
 	};

	class Wind
	{
		title = "Wind";
		values[] = {-1,0};
		texts[] = {"Enabled","Disabled"};
		default = -1;
 	};

	class BattalionWest
	{
		title = "Battalion West";
		values[] = {-1,MILITIA_FIA, RECON_B, TANK_B, TANK_B_W};
		texts[] = {"Default","FIA Battalion","NATO Ranger Battalion","NATO Mechanized Battalion", "NATO Mechanized Battalion (Woodland)"};
		default = -1;
 	};
	class BattalionEast
	{
		title = "Battalion East";
		values[] = {-1,INFANTRY_O,RECON_O,TANK_O,SPETSNAZ_O};
		texts[] = {"Default","CSAT Guard Infantry Battalion","CSAT Recon Battalion","CSAT Tank Battalion","Spetsnaz Battalion"};
		default = -1;
 	};
	class BattalionInd
	{
		title = "Battalion Independent";
		values[] = {-1, MECHANIZED_I, MILITIA_SYNDIKAT,LDF};
		texts[] = {"Default","AAF Mechanized Battalion","Syndikat Militia Battalion","Livonian Defense Battalion"};
		default = -1;
 	};
	class Length
	{
		title = "Scenario Length";
		values[] = {-1,900,1200,1800,2700,3600,5400,7200,10800,14400,36000};
		texts[] = {"Default","15 Minutes","20 Minutes","30 Minutes","45 Minutes","1 Hour","1.5 Hours","2 Hours","3 Hours","4 Hours","10 Hours"};
		default = -1;
	};
	class UnitCap
	{
		title = "Maximum Groups per Side";
		values[] = {-1,5,10,12,15,20};
		texts[] = {"Default","5","10","12","15","20"};
		default = -1;
	};
	class StartingResources
	{
		title = "Starting resources";
		values[] = {-1,0,10,25,52,75,100,500};
		texts[] = {"Default","0","10","25","50","75","100","500"};
		default = -1;
	};
	class IncomeRate
	{
		title = "Income Rate (Requisition points every x minutes)";
		values[] = {-1,60,120,180,240,300,480,600,900,1200,1800};
		texts[] = {"Default","1 minute","2 minutes","3 minutes","4 minutes","5 minutes","8 minutes","10 minutes","15 minutes","20 minutes","30 minutes"};
		default = -1;
	};
	class Skill_West
	{
		title = "BLUFOR Skill Multiplier";
		values[] = {0.25,0.05,0.75,1,1.25,1.5,2,3.5,5};
		texts[] = {"25%","50%","75%","100%","125%","150%","200%","350%","500%"};
		default = 1;
	};
	class Income_West
	{
		title = "BLUFOR Income Multiplier";
		values[] = {0.25,0.05,0.75,1,1.25,1.5,2,3.5,5};
		texts[] = {"25%","50%","75%","100%","125%","150%","200%","350%","500%"};
		default = 1;
	};
	class Reserves_West
	{
		title = "BLUFOR Reserves Multiplier";
		values[] = {-1,0.25,0.05,0.75,1,1.25,1.5,2,3.5,5};
		texts[] = {"Default","25%","50%","75%","100%","125%","150%","200%","350%","500%"};
		default = -1;
	};
	class Strategic_Skill_West
	{
		title = "BLUFOR Strategic Skill";
		values[] = {1,2,3,4};
		texts[] = {"Very Easy","Easy","Moderate","Hard"};
		default = 4;
	};
	class Skill_East
	{
		title = "OPFOR Skill Multiplier";
		values[] = {0.25,0.05,0.75,1,1.25,1.5,2,3.5,5};
		texts[] = {"25%","50%","75%","100%","125%","150%","200%","350%","500%"};
		default = 1;
	};
	class Income_East
	{
		title = "OPFOR Income Multiplier";
		values[] = {0.25,0.05,0.75,1,1.25,1.5,2,3.5,5};
		texts[] = {"25%","50%","75%","100%","125%","150%","200%","350%","500%"};
		default = 1;
	};
	class Reserves_East
	{
		title = "OPFOR Reserves Multiplier";
		values[] = {-1,0.25,0.05,0.75,1,1.25,1.5,2,3.5,5};
		texts[] = {"Default","25%","50%","75%","100%","125%","150%","200%","350%","500%"};
		default = -1;
	};
	class Strategic_Skill_East
	{
		title = "OPFOR Strategic Skill";
		values[] = {1,2,3,4};
		texts[] = {"Very Easy","Easy","Moderate","Hard"};
		default = 4;
	};
	class Skill_Indep
	{
		title = "INDEPENDENT Skill Multiplier";
		values[] = {0.25,0.05,0.75,1,1.25,1.5,2,3.5,5};
		texts[] = {"25%","50%","75%","100%","125%","150%","200%","350%","500%"};
		default = 1;
	};
	class Income_Indep
	{
		title = "INDEPENDENT Income Multiplier";
		values[] = {0.25,0.05,0.75,1,1.25,1.5,2,3.5,5};
		texts[] = {"25%","50%","75%","100%","125%","150%","200%","350%","500%"};
		default = 1;
	};
	class Reserves_Indep
	{
		title = "INDEPENDENT Reserves Multiplier";
		values[] = {-1,0.25,0.05,0.75,1,1.25,1.5,2,3.5,5};
		texts[] = {"Default","25%","50%","75%","100%","125%","150%","200%","350%","500%"};
		default = -1;
	};
	class Strategic_Skill_Indep
	{
		title = "INDEPENDENT Strategic Skill";
		values[] = {1,2,3,4};
		texts[] = {"Very Easy","Easy","Moderate","Hard"};
		default = 4;
	};

	class ShutdownSpawn
	{
		title = "Shutdown standard base spawn when enemy is within";
		values[] = {400,500,600,700,800,900,1000};
		texts[] = {"400m","500m","600m","700m","800m","900m","1000m"};
		default = 600;
	};
	class Music
	{
		title = "Music";
		values[] = {0,1};
		texts[] = {"Disable","Enable"};
		default = 1;
	};
	class SharedCommanding
	{
		title = "Shared Commanding (all units can request and control groups)";
		values[] = {0,1};
		texts[] = {"Disable","Enable"};
		default = 0;
	};
	class Debug
	{
		title = "Debug Mode";
		values[] = {0,1};
		texts[] = {"Disable","Enable"};
		default = 0;
	};
};


class CfgDebriefing
{
	class WestMin
	{
		title = "BLUFOR MINOR VICTORY";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};
	class WestMaj
	{
		title = "BLUFOR MAJOR VICTORY";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};
	class WestTot
	{
		title = "BLUFOR TOTAL VICTORY";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};

	class EastMin
	{
		title = "OPFOR MINOR VICTORY";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};
	class EastMaj
	{
		title = "OPFOR MAJOR VICTORY";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};
	class EastTot
	{
		title = "OPFOR TOTAL VICTORY";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};

	class IndMin
	{
		title = "INDEPENDENT MINOR VICTORY";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};
	class IndMaj
	{
		title = "INDEPENDENT MAJOR VICTORY";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};
	class IndTot
	{
		title = "INDEPENDENT TOTAL VICTORY";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};
	class Tie
	{
		title = "TIE";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};
	class DefenderVictory
	{
		title = "DEFENDER WON";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};
	class AttackerVictory
	{
		title = "ATTACKER WON";
		subtitle = "";
		description = "";
		pictureColor[] = {};
	};

};


saving = 1;