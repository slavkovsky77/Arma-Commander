#include "\AC\defines\commonDefines.inc"

AC_dropzone = "";
AC_deployMarkers = [];
AC_deployMode = false;
AC_markerPlaced = false;
AC_supportMode = false;
AC_supportsPlaced = [0,0,0];

ACF_drawSpawnZones = {
	private _basesToSpawn = [AC_playerSide] call ACF_findSpawnBases;
	if (count AC_deployMarkers > 0) exitWith {};
	setMousePosition [0.5,0.5];
	private _deployRange = DEPLOY_RADIUS;

	// Draw local markers around the areas
	{
		// Draw areas around the bases, so you are able to spawn
		private _mrk = createMarkerLocal [format ["sz%1",_forEachIndex],getPosWorld _x];
		_mrk setmarkershapelocal "ELLIPSE";
		_mrk setmarkertypelocal "Solid";
		_mrk setmarkersizelocal [_deployRange,_deployRange];
		_mrk setmarkercolorlocal "colorCivilian";
		_mrk setmarkeralphalocal 0.3;

		AC_deployMarkers pushback _mrk;
	} forEach _basesToSpawn;

	// Move cursor to middle of screen

	if (AC_dropzone == "") then {
		AC_dropzone = createMarkerLocal ["dropZone", UGVAR("#map") posScreenToWorld getMousePosition];
		AC_dropzone setmarkershapelocal "ICON";
		AC_dropzone setMarkerTypeLocal "mil_end";
		AC_dropzone setmarkercolorlocal "ColorGreen";
		AC_dropzone setmarkeralphalocal 1;
		AC_dropzone setmarkerTextlocal "Landing Zone";
	};
};

ACF_findSpawnBases = {
	params ["_side"];
	private _enemyRange = ShutdownSpawnRadius;
	private _enemySide = [_side] call ACF_enemySide;
	private _enemyBases = AC_bases select {GVAR(_x,"side") == _enemySide};
	//determine defender detection type
	private _color = switch (_side) do {
	    case west: { "Wdetected" };
	    case east: { "Edetected" };
	    case resistance: { "Idetected" };
	    default { "Wdetected"};
	};
	private _enemyGroups = AC_operationGroups select {side _x == _enemySide && {GVARS(_x,_color,false)} };
	private _basesToSpawn = AC_bases select {private _base = _x;
		GVAR(_x,"side") == _side
		&& {GVARS(_x,"deployed",DEPLOYED_FALSE) == DEPLOYED_FALSE}
		&& {GVARS(_x,"nospawn",0) == 0}
		&& {_enemyGroups findIf {_base distance (leader _x) < [_enemyRange,GVARS(_base,"Shutdown",0)] select (GVARS(_base,"Shutdown",0) > 0) } == -1}
		&& {_enemyBases findIf {_base distance _x < [_enemyRange,GVARS(_base,"Shutdown",0)] select (GVARS(_base,"Shutdown",0) > 0) } == -1}
	};
	_basesToSpawn
};

ACF_eraseSpawnZones = {
	deleteMarkerLocal AC_dropzone;
	AC_dropzone = "";
	{
		deleteMarkerLocal _x;
	} forEach AC_deployMarkers;
	AC_deployMarkers = [];
};

[] spawn {
	waitUntil {time > 5 && !isNull (findDisplay 12)};

	// Place dropzone marker
	(findDisplay 12 displayctrl 51) ctrlAddEventHandler ["MouseButtonClick",{
		params ["_map","_button"];
		if (!AC_markerPlaced && AC_deployMode) then {
			private _mousePosWorld = _map posScreenToWorld getMousePosition;
			if (AC_deployMarkers findIf {getMarkerPos _x distance2D _mousePosWorld <= DEPLOY_RADIUS} > -1) then {
				AC_markerPlaced = true;
				playSound "addItemOk";
			} else {
				playSound "addItemFailed";
			};
		};
		if (AC_supportMode && AC_supportsPlaced#0 == 0) then {
			AC_supportsPlaced = _map posScreenToWorld getMousePosition;
		};
	}];

	(findDisplay 12 displayctrl 51) ctrlAddEventHandler ["Draw",{
		params ["_map"];
		if (AC_deployMode && !AC_markerPlaced) then {
			AC_dropzone setmarkerposlocal (_map posScreenToWorld getMousePosition);
		};
		if (AC_supportMode) then {
			private _radius = [] call ACF_getSupportRadius;
			_map drawEllipse [_map posScreenToWorld getMousePosition, _radius, _radius, 0, [0,0,0,1], "#(rgb,8,8,3)color(0,0,0,0.3)"];
		};
	}];
	addMissionEventHandler ["Map", {
		params ["_opened"];
		if (!_opened) then {
			[] call ACF_eraseSpawnZones;
			AC_deployMode = false;
			AC_markerPlaced = false;
			AC_supportsPlaced = [0,0,0];
			AC_supportMode = false;
		};
	}];
};



// This agent is not handling AI ATM.
/*
	Empty base: Speciální případ

	začáteční score = 0
	defender = ten co prijde driv
	attacker = ten druhej
	kdyz vyhraje defender, tak se to stejne flipne
*/

ACF_battleAgent = {
	params ["_base"];
	private _basePos = getPosATL _base;
	private _newSoldiers = GVAR(_base,"nSoldiersOriginal");
	private _defenders = GVAR(_base,"staticGroup");
	private _perimeter = GVAR(_base,"out_perimeter");
	// Find out if there is any enemy inside borders
	private _nearSold = _basePos nearEntities [["Man","LandVehicle"],_perimeter];
	_nearSold = _nearSold select {side _x != civilian}; //no Civlian attacks
	if (count _nearSold < 1) exitWith {};

	//systemChat format ["Battle of %1 begun!",GVAR(_base,"callsign")];

	private ["_nDefenders", "_nAttackers", "_change","_leader"];
	private _baseSide = GVARS(_base,"side",sideEmpty);
	private _battleEnded = false;
	private _score = 100;
	private _emptyBase = false;
	private _flagPole = GVAR(_base,"flag");

	if (_baseSide == sideUnknown || _baseSide == sideEmpty) then {
		//systemChat "Battle for empty base";
		_emptyBase = true;
		private _nearest = _nearSold#0;
		_baseSide = side _nearest;
		_score = 0;
	    [_flagPole, 0, true] call BIS_fnc_animateFlag;
	};
	private _enemySide = [_baseSide] call ACF_enemySide;
	private _flagDefender = GVAR([_baseSide] call ACF_battalion,"flag");
	private _flagAttacker = GVAR([_enemySide] call ACF_battalion,"flag");

	SVARG(_base,"contested",true);
	SEND_NOTIFICATION(NN_BASE_ATTACKED,GVAR(_base,"callsign"),GVAR(_base,"side"));

	if (!isNil "_defenders" && {speedMode _defenders == "LIMITED"}) then {
		private _wp = _defenders addWaypoint [_base, 5, 1];
		_wp setWaypointType "SAD";
		_defenders setSpeedMode "FULL";
	};

	while {!_battleEnded} do {
		sleep 1;
		_nearSold = _basePos nearEntities [["Man","LandVehicle"],_perimeter];
		{{_nearSold pushBackUnique _x} forEach crew _x} forEach _nearSold;
		_nDefenders = {side _x == _baseSide} count _nearSold;
		_nAttackers = {side _x == _enemySide} count _nearSold;

		_change = (_nDefenders - _nAttackers) * BA_CHANGE_RATE;
		CLAMP(_change,-2,2);
		_score = _score + _change;
		CLAMP(_score,-100,100);
		SVARG(_base,"score",round _score);

		// Handle flag position and texture
	    [_flagPole, abs (_score / 100), false] call BIS_fnc_animateFlag;

		if (_score < 0 && {getForcedFlagTexture _flagPole  != _flagAttacker}) then {
			_flagPole forceFlagTexture _flagAttacker;
		};
		if (_score > 0 && {getForcedFlagTexture _flagPole  != _flagDefender}) then {
			_flagPole forceFlagTexture _flagDefender;
		};

		if (_score == -100 || {_nAttackers == 0 && _score == 100}|| {_emptyBase && _score == 100} || {_emptyBase && count _nearSold == 0 && _score == 0}) then {
			_battleEnded = true;
		};
	};

	if (_score == -100) then {
		// Flip the base
		[_base, _enemySide, _newSoldiers] spawn AC_gar_changeOwner;
		[_base, _enemySide] call ACF_ai_battleEnded;
	};
	if (_score == 100) then {
		if (_emptyBase) then {
			[_base, _baseSide, _newSoldiers] spawn AC_gar_changeOwner;
			[_base, _baseSide] call ACF_ai_battleEnded;
		} else {
			// Base defended!
		};
	};
	//systemChat format ["Battle of %1 ended!",GVAR(_base,"callsign")];

	// Reset battle variables
	SVARG(_base,"state",BATTLE_STATE_ENDED);

	sleep 5;
	SVARG(_base,"contested",false);
};