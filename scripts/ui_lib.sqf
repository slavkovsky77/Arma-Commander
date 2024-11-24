#include "\AC\defines\commonDefines.inc"
#include "\a3\Ui_f\hpp\defineCommonColors.inc"

/*
	Library for general UI functionality:
	Generic functions, variables,...
*/

// Default UI variables
AC_selectedGroups = [];
AC_playerSide = sideUnknown;
AC_playerSideColor = [civilian] call BIS_fnc_sideColor;
AC_playerBattalion = objNull;

AC_mouseOver = grpNull;
USVAR("fireMission",false); // Fire mission mode

// Initialization of player's UI. Local function on mission start
ACF_ui_initUI = {
	//disableSerialization;
	waitUntil {!isNull (findDisplay 12 displayCtrl 51)};

	// Declare UI variables
	USVAR("#map",findDisplay 12 displayCtrl 51);
	private _map = UGVAR("#map");

	// These variables are doubled!
	_map ctrlAddEventHandler ["MouseButtonClick",{
		params ["_map","_button"];
		if (_button == 1 && {IS_COMMANDER}) then {
			_this call ACF_ui_eventRightClick;
			if (UGVAR("fireMission")) then {USVAR("fireMission",false)};
		};
	}];

	AC_mouseDownPos = [];
	_map ctrlAddEventHandler ["MouseButtonDown",{
		if (_this select 1 == 0) then {
			AC_mouseDownPos = getMousePosition;
			_this spawn ACF_ui_selectionSquare;
		};
	}];
	_map ctrlAddEventHandler ["MouseButtonUp",{
		AC_mouseDownPos = [];

		if (count AC_selectedGroups == 0) exitWith {};
		if (isNull GVARS(AC_selectedGroups#0,"base",objNull)) then {
			UGVAR("ac_groupInfo") ctrlShow true;

			if (side (AC_selectedGroups#0) == AC_playerSide && {IS_COMMANDER}) then {
				UGVAR("ac_actionsList") ctrlShow true;
			};
			[] call ACF_ui_updateCommandUI;
		};
	}];

	//_map ctrlAddEventHandler ["Unload",{AC_mouseDownPos = []}];

	[] call ACF_initMapIcons;
	[] call ACF_initCommandUI;
};

ACF_ui_getRankIcon = {
	params [["_skill",1]];
	private _rank = 7;
	if (true)  then {
		if (_skill < 0.25) exitWith {_rank = 0};
		if (_skill >= 0.25 && _skill < 0.45) exitWith {_rank = 1};
		if (_skill >= 0.45 && _skill < 0.65) exitWith {_rank = 2};
		if (_skill >= 0.65 && _skill < 0.85) exitWith {_rank = 3};
		if (_skill >= 0.85 && _skill < 0.95) exitWith {_rank = 4};
		if (_skill >= 0.95) exitWith {_rank = 5};
	};

	// Load correct cfg
	private _icon = getText (configfile >> "CfgRanks" >> str _rank >> "texture");
	_icon
};

ACF_ui_depletionColor = {
	params [["_count",0],["_originalCount",0]];
	private _rgba = [1,1,1,1];

	if (_originalCount <= 0) exitWith {_rgba};
	if (_count > _originalCount) then {_count = _originalCount};
	private _rate = _count / _originalCount;
	private _r = 1;
	private _g = 1;
	private _b = 1;

	if (_rate >= 0.5) then {
		_b = (_rate - 0.5) * 2;
	} else {
		_b = 0;
		_g = _rate * 2;
	};

	_rgba = [_r,_g,_b,1];
	_rgba
};