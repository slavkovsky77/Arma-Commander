#include "\AC\defines\commonDefines.inc"

// Handle Shared commanding feature
if (["SharedCommanding", 0] call BIS_fnc_getParamValue == 0) then {
	AC_sharedCommanding = false;
} else {
	AC_sharedCommanding = true;
};

if (hasInterface) then {
	#include "\AC\scripts\init_briefing.sqf"
	["ACLoadingScreen", "Loading… wait for my splendid™ mission!"] call BIS_fnc_startLoadingScreen;
};

// Define basic variables
if (isNil "AC_operationGroups") then {AC_operationGroups = []};
if (isNil "AC_serverInitDone") then {AC_serverInitDone = false};

AC_battalions = entities "AC_moduleBattalion";
AC_bases = entities "AC_ModuleACBase";
AC_ended = false;
AC_gameModule = (entities "AC_moduleAcGame")#0;
DEBUG_MODE = GVAR(AC_gameModule,"Debug");
AC_unitCap = ["UnitCap", -1] call BIS_fnc_getParamValue;
ShutdownSpawnRadius = ["ShutdownSpawn",-1] call BIS_fnc_getParamValue;
if (AC_unitCap == -1) then {AC_unitCap = GVAR(AC_gameModule,"UnitCap")};
AC_unitCapRatio = AC_unitCap / 10;

enableEnvironment [false, true];

// Check for correct setup
if (count entities "AC_moduleAcGame" != 1) exitWith {
	["Incorrect game setup - game module setup failed"] call BIS_fnc_error
};
if (count AC_battalions != 2 ||
	{GVAR(AC_battalions#0,"side") == GVAR(AC_battalions#1, "side")}
) exitWith {
	["Incorrect game setup: Incorrect setup of battalions"] call BIS_fnc_error;
};

private _scriptsToLoad = [
	"ai_strategic",
	"ai_waypoints",
	"ai_utils",
	"ai_attack",
	"battalion",
	"economy",
	"experiments",
	"ui_commandEvents",
	"ui_commandUpdate",
	"ui_commandLib",
	"ui_commandInit",
	"ui_events",
	"ui_lib",
	"supports",
	"garrison",
	"groups",
	"groups_new",
	"handlePlayers",
	"handleCommand",
	"bases",
	"simulation",
	"ui_mapIcons",
	"utility",
	"gameModes",
	"network"
];

{
	[] call (compileFinal (preprocessFile format ["\AC\scripts\%1.sqf", _x]));
} forEach _scriptsToLoad;


// This is pre-init for mission maker, if he wants to do anything before AC is fully initialized
if (!isNil "AC_preInitFinished") then {waituntil {AC_preInitFinished}};

//define function
getVehicleAmmoDef = compileFinal preprocessFileLineNumbers "\AC\scripts\getVehicleAmmoDef.sqf";

// Mostly local initializations of bases, battalions and groups
if (isServer) then {
	{[_x] call ACF_createCustomBattalion} forEach (entities "AC_ModuleCustomBattalion");
	{[_x] call ACF_registerCustomGroup} forEach (entities "AC_ModuleRegisterGroup");
};

{[_x] call ACF_initBattalion} forEach AC_battalions;
[] call ACF_nav_initBases;

if (isServer) then {[] execVM "\AC\scripts\init_server.sqf"};
if (hasinterface) then {[] execVM "\AC\scripts\init_client.sqf"};
"ACLoadingScreen" call BIS_fnc_endLoadingScreen;
