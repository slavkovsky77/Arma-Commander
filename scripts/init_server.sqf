#include "\AC\defines\commonDefines.inc"

// Make sure sides are enemies
west setFriend [east,0];
west setFriend [resistance,0];
east setFriend [west,0];
east setFriend [resistance,0];
resistance setFriend [east,0];
resistance setFriend [west,0];

// Enable dynamic simulation
enableDynamicSimulationSystem true;

[] spawn {
	private _props = ["ReammoBox","HouseBase","ReammoBox_F"];
	{
		{
			_x enableDynamicSimulation true;
			uiSleep 0.01;
		} forEach allMissionObjects _x;
	} forEach _props;
};


addMissionEventHandler ["HandleDisconnect",{
	debugLog "HandleDisconnect";
	_this call ACF_com_handleDisconnect;
}];

MSVARG("AC_serverInitDone",true);

sleep 2;

// Wind
private _param = ["Wind",-1] call BIS_fnc_getParamValue;
if (_param > -1) then {
	setWind [0, 0, true];
};

// Daytime
_param = ["Daytime",-1] call BIS_fnc_getParamValue;

if (_param < 24) then {
	_param call BIS_fnc_paramDaytime;
};
if (_param == 24) then {
	((random 8) + 8) call BIS_fnc_paramDaytime;
};
if (_param == 25) then {
	random 23 call BIS_fnc_paramDaytime;
};

_param = ["Percepitation",-1] call BIS_fnc_getParamValue;

switch (_param) do {
	case -1: {};
	case 1: {
		0 setOvercast 0;
		0 setRain 0;
		0 setRainbow 0.3;
		0 setLightnings 0;
		forceWeatherChange;
	};
	case 2: {
		0 setOvercast 0.2;
		0 setRain 0;
		0 setRainbow 0.3;
		0 setLightnings 0;
		forceWeatherChange;
	};
	case 3: {
		0 setOvercast 0.5;
		0 setRain 0;
		0 setRainbow 1;
		0 setLightnings 0;
		forceWeatherChange;
	};
	case 4:  {
		0 setOvercast 0.55;
		0 setRain 0.2;
		0 setRainbow 1;
		0 setLightnings 0;
		forceWeatherChange;
	};
	case 5: {
		0 setOvercast 0.6;
		0 setRain 0;
		0 setRainbow 0.6;
		0 setLightnings 0;
		forceWeatherChange;
	};
	case 6: {
		0 setOvercast 0.65;
		0 setRain 0.6;
		0 setRainbow 0.5;
		0 setLightnings 0.1;
		forceWeatherChange;
	};
	case 7: {
		0 setOvercast 0.7;
		0 setRain 0.9;
		0 setRainbow 0.4;
		0 setLightnings 0.5;
		forceWeatherChange;
	};
	case 8: {
		0 setOvercast 0.75;
		0 setRain 1;
		0 setRainbow 0;
		0 setLightnings 1;
		forceWeatherChange;
	};
};

_param = ["Fog",-1] call BIS_fnc_getParamValue;

switch (_param) do {
	case -1: {};
	case 1: {
		0 setGusts 0;
		0 setWaves 0.1;
		0 setFog [0, 0, 0];
		forceWeatherChange;
	};
	case 2: {
		0 setGusts 0.2;
		0 setWaves 0.25;
		0 setFog [0.02, -0.0005, 150];
		forceWeatherChange;
	};
	case 3: {
		0 setGusts 0.1;
		0 setWaves 0.1;
		0 setFog [0.05, 0.05, 70];
		forceWeatherChange;
	};
	case 4:  {
		0 setGusts 0.1;
		0 setWaves 0.1;
		0 setFog [0.1, 0.07, 70];
		forceWeatherChange;
	};
	case 5: {
		0 setGusts 0.15;
		0 setWaves 0.15;
		0 setFog [0.075, 0.06, 75];
		forceWeatherChange;
	};
	case 6: {
		0 setGusts 0.1;
		0 setWaves 0.1;
		0 setFog [0.05, 0.08, 60];
		forceWeatherChange;
	};
	case 7: {
		0 setGusts 0.2;
		0 setWaves 0.25;
		0 setFog [0.04, -0.08, 150];
		forceWeatherChange;
	};
	case 8: {
		0 setGusts 0.4;
		0 setWaves 0.35;
		0 setFog [0, 0, 0];
		forceWeatherChange;
	};
	case 9: {
		0 setGusts 0.5;
		0 setWaves 0.4;
		0 setFog [0, 0, 0];
		forceWeatherChange;
	};
};

[] call ACF_ec_setIncomeParams;

// Server time to end
AC_missionLength = GVAR(AC_gameModule,"Length");
_param = ["Length",-1] call BIS_fnc_getParamValue;
if (_param > -1) then {
	AC_missionLength = _param;
};

// Check ending conditions
if (AC_missionLength != -100) then {
	[] spawn {
		AC_endTimeServer = AC_missionLength - time;
		[AC_endTimeServer] remoteExec ["ACF_runEndTimer",0];
		while {true} do {
			sleep 0.5;
			AC_endTimeServer = (AC_missionLength - time) max 0;
		};
	};

	[] spawn {
		sleep 1;
		private _mode = GVARS(AC_gameModule,"GameMode",GAME_MODE_CLASSIC);
		if (_mode == GAME_MODE_CLASSIC) then {
			[] spawn ACF_frontlinesModeAgent;
		};
		if (_mode == GAME_MODE_LAST_STAND) then {
			[] spawn ACF_lastStandModeAgent;
		};
	};
} else {
	AC_endTimeServer = 0;
	[0] remoteExec ["ACF_runEndTimer",0];
};

// Set up all game loop checks
[] spawn {
	sleep 1;
	private _t = time + 10;
	// All players are alive, or timeout ran out
	waitUntil {sleep 1;
		!isMultiplayer || {time > _t}
		|| {playersNumber west + playersNumber east + playersNumber resistance == {alive _x} count allPlayers}
	};

	[] spawn ACF_ai_strategyAgent;
	sleep 0.1;
	[] spawn ACF_ec_economyAgent;
};

while {true} do {
	[] call ACF_checkSimulation;
	sleep 0.5;
	[] call ACF_groupdetectionCheck;
	sleep 0.5;
};