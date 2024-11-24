#include "\AC\defines\commonDefines.inc"
#include "\AC\defines\markerDefines.inc"
// ---------------------------
// INIT MAP ICONS
// ---------------------------

// Determine player's color

ACF_initMapIcons = {
	// Show all group icons
	setGroupIconsVisible [true,false];
	setGroupIconsSelectable true;

	{[_x] call ACF_ui_createGroupIcon} forEach AC_operationGroups;
	{[group _x] call ACF_ui_createGroupIcon} forEach AC_bases;

	UGVAR("#map") ctrlAddEventHandler ["Draw", {
		params ["_map"];

		[_map] call ACF_ui_drawMapIcons;
		[_map] call ACF_ui_drawSelectionBox;
		if (IS_COMMANDER) then {
			[] call ACF_ui_drawCursorIcon;
		};
	}];
};

ACF_ui_drawMapIcons = {
	params ["_map"];

	// Prevent existence of null groups
	AC_operationGroups = AC_operationGroups - [grpNull];
	private _textSize = 0.06;
	private _sizeCircle = SIZE_GROUP_CIRCLE;
	private _sizeIcon = SIZE_ICON;
	private _iconCFill = ICON_CIRCLE_FILL;
	private _iconCBorder = ICON_CIRCLE_BORDER;
	private _iconBFill = ICON_BASE_FILL;
	private _iconB = ICON_BASE;
	private _iconBBorder = ICON_BASE_OUTLINE;
	private _colorVeh = COLOR_VEHICLE;
	private _colorVehCon = COLOR_CONTRAST_VEHICLE;
	private _colorSel = COLOR_SELECTED_GROUP;


	private ["_iconType", "_pos","_waypoint", "_rgba","_colorIcon", "_callsign", "_colorSide", "_groupLead","_groups", "_color","_damage","_health"];

	private _drawVehicles = {
		{
			_iconType = _x getVariable ["marker",""];
			if (_iconType == "") then {
				_iconType = getText (configfile >> "CfgVehicles" >> typeOf _x >> "Icon");
				_x setVariable ["marker", _iconType];
			};
			_pos = getPosWorld _x;
			_map drawIcon [_iconCFill, _colorVeh, _pos, _sizeCircle, _sizeCircle, 0];
			_map drawIcon [_iconType, _colorVehCon, _pos, _sizeIcon, _sizeIcon, getDir _x];
		} forEach (_this select 0);
	};

	private _drawBases = {
		params ["_units",["_selected",false]];
		private _borderColor = _colorVehCon;
		if (_selected) then {_borderColor = _colorSel};
		{
			_colorIcon = COLOR_BASE_CONTRAST;
			if (GVAR(_x,"contested")) then {_colorIcon = [1,0,0,1]};
			_colorSide = [_x getVariable "side"] call BIS_fnc_sideColor;
			_colorSide set [3, 0.8];
			_callsign = GVAR(_x,"callsign");
			_pos = getPosWorld _x;

			_map drawIcon [_iconBFill,_colorSide,_pos,80,40,0,_callsign,2,_textSize,'TahomaB','right'];
			_map drawIcon [_iconBBorder,_borderColor,_pos,80,40,0,"",0,0.03,'TahomaB','right'];
			_map drawIcon [_iconB,_colorIcon,_pos,_sizeIcon,_sizeIcon,0,"",0,0.03,'TahomaB','right'];
		} forEach (_this#0);
	};

	private _drawWaypoints = {

		{
			_waypoint = getWPPos [_x, currentWaypoint _x];
			//private _waypoint = _x getVariable ["#wp",[0,0,0]];
			//private _rgba = [side _x] call BIS_fnc_sideColor;
			_rgba =  [0.8,0.8,0,1]; // Yellow
			if (DEBUG_MODE && {GVARS(_x,"canGetOrders",true)}) then {_rgba = [1,1,1,1]};

			if (_waypoint isEqualType [] && {_waypoint#0 != 0} || (_waypoint isEqualType objNull && {!isNull _waypoint})) then {
				_map drawLine [getPosWorld leader _x, _waypoint, _rgba];
				_map drawIcon [ICON_WAYPOINT, _rgba, _waypoint, 20, 20, 0, "", 0, 0.03, 'TahomaB', 'right'];
			};
		} forEach ((_this#0) select {{alive _x} count units _x > 0});
	};

	private _drawGroups = {
		params ["_units",["_selected",false]];
		private _borderColor = _colorVehCon;
		private _friendlyPlayerGroups = [];
		{_friendlyPlayerGroups pushBackUnique (group _x)} forEach (allPlayers select {side group _x == AC_playerSide});
		if (_selected) then {_borderColor = _colorSel};


		{
			_colorIcon = COLOR_BASE_CONTRAST;
			if (_x == group player) then {
				_colorIcon = [0,1,0,1];
			} else {
				if (side _x == AC_playerSide && {_x in _friendlyPlayerGroups}) then {
					_colorIcon = [1,1,0,1];
				};
			};

			 _colorSide = [side _x] call BIS_fnc_sideColor;
			_colorSide set [3,0.8];
			_callsign = GVARS(_x,"callsign","");
			_groupLead = leader _x;
			_pos = getPosWorld _groupLead;

			//private _pos = getPosVisual leader _x;

			_groups = [_x] call ACF_ui_getTransportedGroups;
			if (count _groups > 1) then {
				{
					if (_forEachIndex != 0) then {
						_callsign = _callsign + ", ";
						_callsign = _callsign + GVAR(_x,"callsign");
					};
				} forEach _groups;
			};

			_map drawIcon [_iconCFill, _colorSide, _pos, _sizeCircle, _sizeCircle, 0, _callsign,2,_textSize, 'TahomaB', 'right'];
			_map drawIcon [_iconCBorder, _borderColor, _pos, _sizeCircle, _sizeCircle, 0];

			// Draw icon of the vehicle
			([_x] call ACF_getGroupVehicles) params [["_vehicle",objNull]];
			if (!isNull _vehicle) then {
				_iconType = _vehicle getVariable ["marker",""];
				if (_iconType == "") then {
					_iconType = getText (configfile >> "CfgVehicles" >> typeOf _vehicle >> "Icon");
					_vehicle setVariable ["marker", _iconType];
				};

				_color = _colorVehCon; // TODO - depletedColor
				_damage = damage _vehicle;
				if (!canMove _vehicle) then {_damage = 1};

				if (_damage > 0.1) then {
					_health = (1 - _damage);
					_color = [_health,1] call ACF_ui_depletionColor;
				};

				//private _posOffset = _map posWorldToScreen _pos;
				//_posOffset set [0,_posOffset#0 - 0.03];
				//_posOffset set [1,_posOffset#1 - 0.03];
				//_posOffset = _map posScreenToWorld _posOffset;
				(findDisplay 12 displayCtrl 51) drawIcon [_iconType,_color,_pos,_sizeIcon,_sizeIcon,0];
			};

			_iconType = GVARS(_x,"ico",GVAR(_x,"marker"));
			_map drawIcon [_iconType, _colorIcon, _pos, _sizeIcon, _sizeIcon, 0];
		} forEach (_this#0);
	};

	/*
		Order of draw:
		- empty vehicles
		- bases
		- waypoints
		- groups
		- selected entities and their properties
	*/

	[AC_visibleVehicles] call _drawVehicles;

	//hide hidden icons so they don't block transports they are on
	private _groupsToDraw = AC_operationGroups select {!([_x] call ACF_isTransported)};
	private _transported = AC_operationGroups - _groupsToDraw;
	private _selectedGroups = AC_selectedGroups select {!([_x] call ACF_isTransported)};
	{
		clearGroupIcons _x;
	} forEach _transported;
	_groupsToDraw = _groupsToDraw - _selectedGroups;
	{[_x] call ACF_ui_createGroupIcon} forEach _groupsToDraw;

	private _basesToDraw = AC_bases - _selectedGroups;
	private _pSide = AC_playerSide;
	private _color = switch (_pSide) do {
	    case west: { "Wdetected" };
	    case east: { "Edetected" };
	    case resistance: { "Idetected" };
	};
	if (!DEBUG_MODE) then {
		_basesToDraw = _basesToDraw select {GVAR(_x,_color) || {GVAR(_x,"side") == _pSide}};
	};
	[_basesToDraw] call _drawBases;

	private _waypoints = _groupsToDraw select {side _x == _pSide};
	if (!isNull AC_mouseOver && {side _x == _pSide} && {_selectedGroups find AC_mouseOver == -1}) then {
		_waypoints pushBack AC_mouseOver;
	};
	//if (DEBUG_MODE) then {_waypoints = AC_operationGroups};
	[_waypoints] call _drawWaypoints;

	_groupsToDraw = _groupsToDraw select {(side _x == _pSide || {_x getVariable [_color,false]}) }; //&& {!([_x] call ACF_isTransported)}

	//if (DEBUG_MODE) then {_groups = AC_operationGroups};
	[_groupsToDraw] call _drawGroups;

	// Selected groups + WP will be drawn last, so it is not covered by anyone
	if (count _selectedGroups == 0) exitWith {};

	private _firstSelected = _selectedGroups select 0;

	if (!isNull GVARS(_firstSelected,"base",objNull)) then {
		[[leader _firstSelected],true] call _drawBases;
	} else {
		[_selectedGroups select {side _x == _pSide},true] call _drawWaypoints;
		[_selectedGroups,true] call _drawGroups;
	};
};

// ----------------------
// GROUP ICONS MANAGEMENT
// ----------------------

// Group icon contains only text, no longer dynamic icon
ACF_ui_createGroupIcon = {
	params ["_group"];
	if (isNull _group) exitWith {};
	//exit if group icon exists
	if !(((getGroupIcons _group) select 0) isEqualTo [1,1,1,1]) exitWith {
		debugLog "Group icon already exists!";
	};

	private _side = side _group;
	if (!isNull GVARS(_group,"base",objNull)) then {
		_side = (leader _group) getVariable "side";
	};

	private _color = switch (AC_playerSide) do {
	    case west: { "Wdetected" };
	    case east: { "Edetected" };
	    case resistance: { "Idetected" };
	};
	private _visible = true;
	if (_side != AC_playerSide) then {
		_visible = _group getVariable [_color, true];
	};

	// Group icon contains only dummy icon, real icon is not group icon
	_group addGroupIcon ["Dummy",[0,0]];
	_group setGroupIconParams [AC_playerSideColor,"",1,_visible];
};

// Local reveal function
ACF_ui_revealGroup = {
	params ["_entity"];
	if (_entity isEqualType objNull) then {
		//_group = group _entity;

		// Show notification about the group or a base
		[NN_BASE_DETECTED,""] call NN;
	} else {
		[NN_GROUP_DETECTED,""] call NN;
		private _group = _entity;
		private _params = getGroupIconParams _group;
		_params set [3,true];
		_group setGroupIconParams _params;
	};

};

ACF_ui_forgetGroup = {
	params ["_entity"];
	private _group = grpNull;
	if (_entity isEqualType objNull) then {
		_group = group _entity;
	} else {
		_group = _entity;
	};

	private _params = getGroupIconParams _group;
	_params set [3,false];
	_group setGroupIconParams _params;
};

ACF_ui_drawSelectionBox = {
	params ["_map"];

	if (count AC_mouseDownPos == 0 || !visibleMap) exitWith {AC_mouseDownPos = []};
	if (getMousePosition distance2D AC_mouseDownPos < 0.05) exitWith {};

	private _cursorCurPos = _map ctrlMapScreenToWorld getMousePosition;
	private _originalCurPos = _map ctrlMapScreenToWorld AC_mouseDownPos;
	_originalCurPos params ["_origX","_origY"];
	_cursorCurPos params ["_curX","_curY"];

	// Draw rectangle
	private _middlePos = [_originalCurPos, _cursorCurPos] call ACF_middlePos;
	private _lenX = (abs _origX - _curX) / 2;
	private _lenY = (abs _origY - _curY) / 2;

	_map drawRectangle [_middlePos, _lenX, _lenY, 0,COLOR_SELECTION_BOX,""];

	// Put correct groups into selection
	AC_selectedGroups = [];
	{
		(getPosWorld leader _x) params ["_leaderX","_leaderY"];
		private _limitsX = [_origX, _curX];
		private _limitsY = [_origY, _curY];
		{_x sort true} forEach [_limitsX, _limitsY];

		if (side _x == AC_playerSide &&
			{_leaderX >= _limitsX#0} &&
			{_leaderX <= _limitsX#1} &&
			{_leaderY >= _limitsY#0} &&
			{_leaderY <= _limitsY#1}
		) then {
			if !([_x] call ACF_isTransported) then {
				AC_selectedGroups pushBack _x;
			};
		};
	} forEach AC_operationGroups;
};

AC_visibleVehicles = [];
AC_emptyVehicleTarget = objNull;
ACF_visibleVehiclesAgent = {
	//AC_visibleVehicles = (entities [["AllVehicles"],["Man","ParachuteBase"],false,true]) select {
	AC_visibleVehicles = (entities [["AllVehicles"],["ParachuteBase"],false,true]) select {
		(getPosATL _x)#2 < 1 &&
		{{alive _x} count crew _x== 0} &&
		{AC_playerSide knowsAbout _x > DETECTION_THRESHOLD}
	};
};

//not used?
ACF_groupIconsAgent = {
	private _color = switch (AC_playerSide) do {
	    case west: { "Wdetected" };
	    case east: { "Edetected" };
	    case resistance: { "Idetected" };
	};
	while {true} do {
		{
			sleep 1;
			[_x] call ACF_setGroupIcon;
		} forEach (AC_operationGroups select {side _x == AC_playerSide || GVARS(_x,_color,false)});
	};
};

ACF_setGroupIcon = {
	params ["_group"];
	private _side = side _group;
	private _str = "";

	private _prefix = "n_";
	if (_side == west) then {_prefix = "b_"};
	if (_side == east) then {_prefix = "o_"};

	// Detect the first real vehicle
	private _vehicle = ([_group] call ACF_getGroupVehicles) param [0, objNull];

	if (!isNull _vehicle) then {
		if (_vehicle isKindOf "Car") then {
			_str = _prefix + "motor_inf";
		};

		if (_vehicle isKindOf "Air") then {
			_str = _prefix + "air";
		};

		if (_vehicle isKindOf "Tank") then {
			if ((typeOf _vehicle) find "APC" > -1) then {
				_str = _prefix + "mech_inf";
			} else {
				_str = _prefix + "armor";
			};
		};
	} else {
		_str = GVAR(_group,"marker");
	};

	if (_str != GVAR(_group,"ico")) then {
		SVARG(_group,"ico",_str);
	};
};