#include "\AC\defines\commonDefines.inc"

// TODO: Notifications for limited time

// Server side, right?
ACF_frontlinesModeAgent = {
	// 1. Give tasks for player
	sleep 5;

    [true,["task1"],["","Capture Enemy Bases",""],objNull,1,3,true] call BIS_fnc_taskCreate;

	// 2. Check victory conditions: Time, survival
	private _winner = sideUnknown;
	private _victoryType = "Minor";
	private _n5 = true;
	private _n1 = true;
	while {_winner == sideUnknown} do {
		sleep 1;

		// Side lost all bases
		{
			private _side = GVAR(_x,"side");
			if (AC_bases findIf {GVAR(_x,"side") == _side} == -1) exitWith {
				_winner = [_side] call ACF_enemySide;
				_victoryType = "Total";
			};
		} forEach AC_battalions;

		// Notifications:
		if (_n5 && {AC_endTimeServer <= 300}) then {
			SEND_NOTIFICATION(NN_TIME_REMAINING,5,0);
			_n5 = false;
		};
		if (_n1 && {AC_endTimeServer <= 60}) then {
			SEND_NOTIFICATION(NN_TIME_REMAINING,1,0);
			_n1 = false;
		};

		if (AC_endTimeServer <= 0) then {
			// Find out who won
			private _victoryPointsArray = [];
			{
				private _points = [GVAR(_x,"side")] call ACF_victoryPoints;
				_victoryPointsArray pushBack _points;
			} forEach AC_battalions;

			if (_victoryPointsArray#0 != _victoryPointsArray#1) then {
				if (_victoryPointsArray#0 > _victoryPointsArray#1) then {
					_winner = GVAR(AC_battalions#0,"side");
				} else {
					_winner = GVAR(AC_battalions#1,"side");
				};

				// Find out type of victory
				_victoryPointsArray sort false;
				private _rate = _victoryPointsArray#0 / _victoryPointsArray#1;
				if (_rate > 1.5) then {
					_victoryType = "Major";
				};
			} else {
				_winner = sideEmpty; // Tie
			};
		};
	};

	// Select proper victory: Minor, major, total
	private _t = "";
	switch (_winner) do {
		case sideEmpty: {_t = "Tie"};
		case west: {
			if (_victoryType == "Minor") exitWith {_t = "WestMin"};
			if (_victoryType == "Major") exitWith {_t = "WestMaj"};
			if (_victoryType == "Total") exitWith {_t = "WestTot"};
		};
		case east: {
			if (_victoryType == "Minor") exitWith {_t = "EastMin"};
			if (_victoryType == "Major") exitWith {_t = "EastMaj"};
			if (_victoryType == "Total") exitWith {_t = "EastTot"};
		};
		case independent: {
			if (_victoryType == "Minor") exitWith {_t = "IndMin"};
			if (_victoryType == "Major") exitWith {_t = "IndMaj"};
			if (_victoryType == "Total") exitWith {_t = "IndTot"};
		};
	};
	[_t] call BIS_fnc_endMissionServer;
};

// Server side, right?
ACF_LastStandModeAgent = {
	// 1. Give tasks for player
	sleep 5;

	private _attackerBattalion = (AC_battalions select {GVAR(_x,"Role" == 1)}) param [0,objNull];
	private _defenderBattalion = (AC_battalions select {GVAR(_x,"Role" == 0)}) param [0,objNull];

	if(isNull _attackerBattalion || isNull _defenderBattalion) exitWith {
		["Attacker or defender not found! Ending conditions will not work"] call BIS_fnc_error;
	};
	private _attackerSide = GVAR(_attackerBattalion,"side");
	private _defenderSide = GVAR(_defenderBattalion,"side");

    [_defenderSide,["task1_def"],["","Survive until the time limit",""],objNull,1,3,true] call BIS_fnc_taskCreate;
    [_attackerSide,["task_att"],["","Capture Enemy Bases",""],objNull,1,3,true] call BIS_fnc_taskCreate;

	// 2. Check victory conditions: Time, survival
	private _winner = sideUnknown;
	private _n5 = true;
	private _n1 = true;
	while {_winner == sideUnknown} do {
		sleep 5;

		// Side lost all bases: Attacker or defender won
		{
			private _side = GVAR(_x,"side");
			if (AC_bases findIf {GVAR(_x,"side") == _side} == -1) exitWith {
				_winner = [_side] call ACF_enemySide;
			};
		} forEach AC_battalions;

		// Notifications:
		if (_n5 && {AC_endTimeServer <= 300}) then {
			SEND_NOTIFICATION(NN_TIME_REMAINING,5,0);
			_n5 = false;
		};
		if (_n1 && {AC_endTimeServer <= 60}) then {
			SEND_NOTIFICATION(NN_TIME_REMAINING,1,0);
			_n1 = false;
		};

		if (AC_endTimeServer <= 0) then {
			_winner = _defenderSide;
		};
	};

	private _t = "DefenderVictory";
	if(_winner == _attackerSide) then {
		_t = "AttackerVictory";
	};

	[_t] call BIS_fnc_endMissionServer;
};
