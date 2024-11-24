//disableSerialization;
#include "\AC\defines\commonDefines.inc"

/*
	Events on mouseClick and cursor icon handling
*/

addMissionEventHandler ["GroupIconClick",{
	if (_this select 3 == 0) then {
		[_this select 1] call ACF_ui_groupIconLeftClick;
	};
}];

addMissionEventHandler ["MapSingleClick",{
	if !(isNull AC_mouseOver) exitWith {};
	[] spawn {
		sleep 0.05;
		AC_selectedGroups = [];
		UGVAR("ac_groupInfo") ctrlShow false;
		UGVAR("ac_baseInfo") ctrlShow false;
		UGVAR("ac_actionsList") ctrlShow false;
	};
}];


addMissionEventHandler ["GroupIconOverEnter", {
	AC_mouseOver = _this select 1;
	private _base = leader AC_mouseOver;
	private _pSide = AC_playerSide;
	private _color = switch (_pSide) do {
	    case west: { "Wdetected" };
	    case east: { "Edetected" };
	    case resistance: { "Idetected" };
    	default { "Wdetected"};
	};

	// Return if group is not visible
	if (count AC_selectedGroups > 0 || {side AC_mouseOver != _pSide && !GVARS(AC_mouseOver,_color,false)} ) exitWith {};

	private _baseObj = GVARS(AC_mouseOver,"base",objNull);
	if (!isNull _baseObj) then {
		if (GVARS(_baseObj,"side",sideEmpty) == _pSide || {GVARS(_baseObj,_color,false)}) then {
			UGVAR("ac_baseInfo") ctrlShow true;
		};
	} else {
		UGVAR("ac_groupInfo") ctrlShow true;
		if (side AC_mouseOver == _pSide && IS_COMMANDER) then {
			UGVAR("ac_actionsList") ctrlShow true;
		};
	};

	[] call ACF_ui_updateCommandUI;
}];

addMissionEventHandler ["GroupIconOverLeave", {
	AC_mouseOver = grpNull;
	if (count AC_selectedGroups == 0) then {
		UGVAR("ac_groupInfo") ctrlShow false;
		UGVAR("ac_baseInfo") ctrlShow false;
		UGVAR("ac_actionsList") ctrlShow false;
	};
}];

addMissionEventHandler ["Map", {
	params ["_opened"];
	if (_opened) then {
		UGVAR("ac_battalionInfo") ctrlShow true;
	} else {
		{
			UGVAR(_x) ctrlShow false;
		} forEach ["ac_groupInfo","ac_baseInfo","ac_actionsList","ac_buyList","ac_battalionInfo","ac_supportsList"];
		AC_selectedGroups = [];
	};
}];

// Functions
ACF_ui_groupIconLeftClick = {
	//disableSerialization;
	params ["_group"];
	private _color = switch (AC_playerSide) do {
	    case west: { "Wdetected" };
	    case east: { "Edetected" };
	    case resistance: { "Idetected" };
	    default { "Wdetected"};
	};
	// Disable clicking on hidden enemy groups
	if (side _group != AC_playerSide && (!GVARS(_group,_color,false) )) exitWith {};
	AC_selectedGroups = [_group];

	private _groupInfo = UGVAR("ac_groupInfo");
	private _baseInfo = UGVAR("ac_baseInfo");
	private _missionList = UGVAR("ac_actionsList");

	// Left click on anything should bring up current info
	if (!isNull GVARS(_group,"base",objNull)) then {
		// show base info
		_groupInfo ctrlShow false;
		_baseInfo ctrlShow true;
		_missionList ctrlShow false;
	} else {
		_baseInfo ctrlShow false;
		_groupInfo ctrlShow true;
		if (side _group == AC_playerSide && IS_COMMANDER) then {
			_missionList ctrlShow true;
		} else {
			_missionList ctrlShow false;
		};
	};
	playSound "Click";
	[] call ACF_ui_updateCommandUI;
};

// If unit is selected, create waypoint
ACF_ui_eventRightClick = {
	params ["","","_posX","_posY"];
	private _pos = UGVAR("#map") posScreenToWorld [_posX, _posY];

	if (count AC_selectedGroups > 0 && {side (AC_selectedGroups#0) != AC_playerSide}) exitWith {
		AC_selectedGroups = [];
	};

	switch (AC_cursorIcon) do {
		case (CURSOR_NORMAL): {};
		case (CURSOR_FIRE_MISSION): {
			playSound "FD_CP_Clear_F";

			if (UGVAR("fireMission")) then {
				// Launch mortar fire mission
				{
					[_x, _pos] remoteExec ["AC_ai_fireMission",2];
				} forEach AC_selectedGroups;
				USVAR("fireMission",false);
			} else {
				// Attack unit
				if (!isNull AC_mouseOver) then {
					{[_x, leader AC_mouseOver,B_COMBAT] call ACF_ai_move;} forEach AC_selectedGroups;
				} else {
					{[_x, _pos] call ACF_ai_move;} forEach AC_selectedGroups;
				};
			};
		};
		case (CURSOR_GET_IN): {
			playSound "FD_CP_Clear_F";
			private _target = _pos;
			if (!isNull AC_mouseOver) then {
				_target = AC_mouseOver;
			} else {
				if (!isNull AC_emptyVehicleTarget) then {
					_target = AC_emptyVehicleTarget;
				};
			};

			{[_x, _target] call ACF_wp_getIn;} forEach AC_selectedGroups;
		};
		default {
			playSound "FD_CP_Clear_F";
			{[_x, _pos] call ACF_ai_move} forEach AC_selectedGroups;
		};
	};
};

// TODO: Optimize. Reading from config multiple times a frame is not good idea
// Find out if there are vehicles with carry capacity
ACF_getTransportCapacity = {
	params ["_group"];
	private _vehicles = [_group] call ACF_getGroupVehicles;
	private _totalCapacity = 0;
	{
		private _capacityCfg = (_x emptyPositions "cargo")+(_x emptyPositions "gunner");
		//if (!isNull _capacityCfg) then {
		_totalCapacity = _totalCapacity + _capacityCfg;
		//};
	} forEach _vehicles;
	_totalCapacity
};

// Events that will change how cursor is drawn:
// CurrentActions: ACTION_GET_IN
// 1. Enemy unit is onHovered
// 2. Friendly unit is onHovered
// 3. Getting into car
// 4. Fire mission is selected

// TODO: If fire mission is selected, change behaviour of left mouse click!
// TODO: Make this function compatible with empty cars

// Checking on draw what cursor should be shown.
AC_cursorIcon = CURSOR_MOVE;
ACF_ui_drawCursorIcon = {
	//disableSerialization;
	//private _currentIcon = CURSOR_MOVE;
	private _newIcon = CURSOR_MOVE;//determine defender detection type
	private _color = switch (AC_playerSide) do {
	    case west: { "Wdetected" };
	    case east: { "Edetected" };
	    case resistance: { "Idetected" };
	    default { "Wdetected"};
	};
	switch (true) do {
		case (count AC_selectedGroups == 0): {_newIcon = CURSOR_NORMAL};
		case (side AC_mouseOver == AC_playerSide &&
			{[AC_selectedGroups select 0] call ACF_getTransportCapacity == 0} &&
			{[AC_mouseOver] call ACF_getTransportCapacity > 0} &&
			{AC_selectedGroups select 0 != AC_mouseOver}): {
			_newIcon = CURSOR_GET_IN;
		};
		case ((!(side AC_mouseOver in [AC_playerSide,sideUnknown,civilian]) ||
			{GVARS(leader AC_mouseOver,"side",AC_playerSide) != AC_playerSide})
			&& {GVARS(AC_mouseOver,_color,false)}
			&& {count AC_selectedGroups > 0}
			&& {side (AC_selectedGroups select 0) == AC_playerSide}):
			{_newIcon = CURSOR_ATTACK};
		case (UGVAR("fireMission")): {
			_newIcon = CURSOR_FIRE_MISSION;
		};
	};

	// Empty vehicle pass
	if (_newIcon == CURSOR_MOVE) then {
		private _targetVehicle = [] call ACF_emptyVehicleTarget;
		if (!isNull _targetVehicle) then {
			_newIcon = CURSOR_GET_IN;
		};
	};

	if (_newIcon != AC_cursorIcon) then {
		UGVAR("#map") ctrlMapCursor [CURSOR_NORMAL, _newIcon];
		AC_cursorIcon = _newIcon;
	};
};

ACF_emptyVehicleTarget = {
	private _target = objNull;
	private _cursorPos = UGVAR("#map") ctrlMapScreenToWorld getMousePosition;
	private _emptyVehicles = _cursorPos nearEntities [["AllVehicles"], 200];

	private _i = _emptyVehicles findIf {
		getMousePosition distance2D (UGVAR("#map") ctrlMapWorldToScreen (getPosWorld _x)) < 0.03 &&
		{_x in AC_visibleVehicles} &&
		{crew _x findIf {alive _x} == -1}
	};

	if (_i > -1) then {
		_target = _emptyVehicles#_i;
	};
	AC_emptyVehicleTarget = _target;
	_target
};
