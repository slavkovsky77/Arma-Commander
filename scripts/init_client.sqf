#include "\AC\defines\commonDefines.inc"

// ---------------------------
// INITIALIZE PLAYER & UI
// ---------------------------
addMissionEventHandler ["PreloadFinished",{AC_postInit = true}];

"text" cutText ["", "BLACK FADED", 1, true, true];

waituntil {time > 1 && {!isNull player} && {alive player}};

// Play music at the start
if (["Music",0] call BIS_fnc_getParamValue == 1) then {
	[] spawn {
		sleep 1;
		private _tracks = ["EventTrack01a_F_Tacops","EventTrack01b_F_Tacops","EventTrack02a_F_Tacops","EventTrack02b_F_Tacops","EventTrack03a_F_Tacops","EventTrack03b_F_Tacops"];
		0 fadeMusic 0;
		playMusic selectRandom _tracks;
		10 fadeMusic 1;
	};
};

if (didJIP) then {
	[clientOwner] remoteExecCall ["ACF_sendJipData",2];
};
waitUntil {(!isNil "AC_postInit" || !isMultiplayer) && {!isNil "AC_endTime"}};

AC_playerSide = side group player;
AC_playerSideColor = [AC_playerSide] call BIS_fnc_sideColor;
AC_playerBattalion = [AC_playerSide] call ACF_battalion;

// Make sure that HQ element is initialized
[group player,AC_playerBattalion,AC_playerSide] remoteExec ["ACF_initHqElement",2];

// Select commander locally
if (leader group player == player && GVARS(AC_playerBattalion,"#commander","") == "") then {
	private _name = name player;
	if (!isMultiplayer) then {_name = profileName};
	SVARG(AC_playerBattalion,"#commander", _name);
};

if (isMultiplayer) then {
	titlecut ["","BLACK IN",5];
};

if (!DEBUG_MODE) then {sleep 3};

disableMapIndicators [true,true,false,false];
[] call ACF_ui_initUI;


sleep 0.5;
"text" cutText ["", "BLACK IN", 1, true, true];

// Add action
[] call ACF_addSwitchAction;

[] spawn {
	while {true} do {
		sleep 5;
		[] call ACF_visibleVehiclesAgent;
	};
};

