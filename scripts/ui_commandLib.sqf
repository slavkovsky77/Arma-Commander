#include "\AC\defines\commonDefines.inc"

// Add functionality to each action button
ACF_ui_addMissionButtonHandlers = {
	//disableserialization;
	private _table = UGVAR("ac_actionsList");
	((_table ctRowControls 0) select 2) ctrlAddEventHandler ["MouseButtonClick",{[B_TRANSPORT] call ACF_ai_moveAction; [] call ACF_ui_updateCommandUI;}];
	((_table ctRowControls 1) select 2) ctrlAddEventHandler ["MouseButtonClick",{[B_COMBAT] call ACF_ai_moveAction; [] call ACF_ui_updateCommandUI}];
	((_table ctRowControls 2) select 2) ctrlAddEventHandler ["MouseButtonClick",{[B_SILENT] call ACF_ai_moveAction; [] call ACF_ui_updateCommandUI}];
	((_table ctRowControls 3) select 2) ctrlAddEventHandler ["MouseButtonClick",{[] call ACF_ai_vehicleAction; [] call ACF_ui_updateCommandUI}];
	((_table ctRowControls 4) select 2) ctrlAddEventHandler ["MouseButtonClick",{[] call ACF_landAction; [] call ACF_ui_updateCommandUI}];
	((_table ctRowControls 5) select 2) ctrlAddEventHandler ["MouseButtonClick",{[] call ACF_ai_fireMissionAction}];

};

// This controls button on battalion info - show or hide buying menu
ACF_ui_RequisitionButton = {
	//disableSerialization;

	private _ctrls = [UGVAR("ac_buyList"),UGVAR("ac_supportslist")];
	if (ctrlShown (_ctrls#0)) then {
		{_x ctrlShow false} forEach _ctrls;
		AC_deployMode = false;
		AC_markerPlaced = false;
		AC_supportMode = false;
		AC_supportsPlaced = [0,0,0];
	} else {
		{_x ctrlShow true} forEach _ctrls;
	};
};

ACF_ai_moveAction = {
	params ["_type"];
	{
		[_x,_type] call ACF_ai_changeBehavior;
	} forEach AC_selectedGroups;
};

// Get in / unload / get out button
ACF_ai_vehicleAction = {
	private _group = AC_mouseOver;
	if (count AC_selectedGroups > 0) then {
		_group = AC_selectedGroups select 0;
	};

	// Determine type of action: Get in, get out, unload
	switch ([_group] call ACF_ui_vehicleActionType) do {
		case ACTION_GET_OUT: {
			// Create getOut WP on the spot
			[_group] call ACF_wp_getOut;
		};
		case ACTION_UNLOAD: {
			[_group] call ACF_wp_unload;
		};
		case ACTION_GET_IN: {
			[_group, leader _group, true] call ACF_wp_getIn;
		};
	};
};

ACF_ui_vehicleActionType = {
	params ["_group"];

	// Determine if action should be get in, get out, or unload
	private _vehicles = [];
	{
		if (vehicle _x != _x) then {
			_vehicles pushBackUnique vehicle _x;
		};
	} forEach units _group;
	private _transporting = false;

	//make sure we own the vehicle
	{
		private _veh = _x;
		{
			if (alive _x && {_X == effectiveCommander _veh}) exitWith {_transporting = true};
		} forEach units _group;
	} forEach _vehicles;

	//if so do we have passangers?
	if (_transporting) then {
		_transporting = false;
		{
			{
				if (alive _x && {group _x != _group}) exitWith {_transporting = true};
			} forEach crew _x;
		} forEach _vehicles;

	};

	if (_transporting) exitWith {ACTION_UNLOAD};
	if (count _vehicles > 0 && {!isNull (_vehicles select 0)}) exitWith {ACTION_GET_OUT};
	ACTION_GET_IN
};

ACF_ui_getTransportedGroups = {
	params ["_group"];

	private _groups = [_group];
	private _vehicles = [];
	{
		if (vehicle _x != _x) then {
			_vehicles pushBackUnique vehicle _x;
		};
	} forEach units _group;

	{
		{
			_groups pushBackUnique (group _x);
		} forEach crew _x;
	} forEach _vehicles;
	_groups
};

ACF_landAction = {
	if (count AC_selectedGroups == 0) exitWith {};
	private _group = AC_selectedGroups#0;
	private _vehicles = [_group] call ACF_getGroupVehicles;

	// Delete all waypoints
	while {count waypoints _group > 0} do {
		deleteWaypoint ((waypoints _group)#0);
	};
	//[_group, getPos leader _group, objNull] spawn BIS_fnc_wpLand;
	[_group, getPosWorld leader _group, objNull] remoteExec ["BIS_fnc_wpLand",2];

};

// Next valid click into space will be fire mission, if it's correct
ACF_ai_fireMissionAction = {
	params ["_group"];
	USVAR("fireMission",true);
};

