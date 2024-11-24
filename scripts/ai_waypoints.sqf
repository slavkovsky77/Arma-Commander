#include "\AC\defines\commonDefines.inc"

AC_battlesInProgress = [];

ACF_ai_move = {
	params ["_group","_pos",["_mode",B_DEFAULT],"_canGetOrders",["_radius",0]];

	// Delete all waypoints
	while {count waypoints _group > 0} do {
		deleteWaypoint ((waypoints _group)#0);
	};
	SVARG(_group,"canGetOrders",_canGetOrders);

	private _leader_pos = getPosATL leader _group;
	private _wpPos = [_pos select 0, _pos select 1, _leader_pos select 2];
	private _wp = _group addWaypoint [_wpPos, _radius];

	_wp setWaypointType "MOVE";

	if (_mode != B_DEFAULT && {!isPlayer leader _group}) then {
		[_group,_mode] call ACF_ai_changeBehavior;
	};
	_wp
};

ACF_rtbPos = {
	params ["_group"];
	private _side = side _group;
	private _pos = getPosATL leader _group;
	//
	private _friendlyBases = AC_bases select {GVAR(_x,"side") == _side};
	_friendlyBases = [_friendlyBases,[],{_x distance2D _pos},"ASCEND"] call BIS_fnc_sortBy;
	private _spawns = GVARS(_friendlyBases#0,"stagePoints",[]) + GVARS(_friendlyBases#0,"spawnPoints",[]);
	if (count _spawns > 0) then {
		_spawns = [_spawns,[],{_x distance _pos},"ASCEND"] call BIS_fnc_sortBy;
		_pos = _spawns#0;
	} else {
		_pos = getPosATL (_friendlyBases#0);
	};
	_pos
};

ACF_ai_changeBehavior = {
	params ["_group","_behavior"];
	private _units = units _group;

	if(DEBUG_MODE) then {
		private _behaviorName = switch (_behavior) do {
			case B_COMBAT: { "COMBAT" };
			case B_TRANSPORT: { "TRANSPORT" };
			case B_SILENT: { "STEALTH" };
			default { "DEFAULT" };
		};
		systemChat format ["[%1] Switching to %2 behavior", 
			GVAR(_group,"callsign"),
			_behaviorName
		];
	};

	// Set specific behaviour parts
	switch (_behavior) do {
		case B_COMBAT: {
			_group setCombatMode "RED";
			_group setCombatBehaviour "COMBAT";
			_group setSpeedMode "NORMAL";
			{
				_x enableAI "autocombat";
			} forEach _units;
		};
		case B_TRANSPORT: {
			_group setCombatMode "YELLOW";
			_group setCombatBehaviour "SAFE"; //encourages road use, will switch to AWARE automatically if engaged
			_group setSpeedMode "NORMAL";
			{
				_x disableAI "autocombat";
			} forEach _units;
		};
		case B_SILENT: {
			_group setCombatMode "GREEN";
			_group setCombatBehaviour "STEALTH";
			_group setSpeedMode "LIMITED";
			{
				_x disableAI "autocombat";
			} forEach _units;
		};
	};

	// Apply special rules for aircraft
	if ([_group] call ACF_grp_isAircraft) then {
		private _multiplier = 1;
		if (_behavior == B_SILENT) then {_multiplier = 0.6};
		if (_behavior == B_TRANSPORT) then {_multiplier = 1.3};
		private _pos = getWPPos [_group, 1];
		private _wpArray = waypoints _group;
		{
			if (_x isKindOf "Plane") then {
				if (_mode == B_COMBAT) then {
					_wpArray#1 setWaypointType "DESTROY";
				};
				_x move _pos;
			} else {
				[_x,SPEED_LIMIT_AIR * _multiplier] remoteExecCall ["limitSpeed",2];
				[_x,HELI_ALT * _multiplier] remoteExecCall ["flyInHeight",2];
			};
		} forEach ([_group] call ACF_getGroupVehicles);
	} else {
		{
			_x engineOn true;
		} forEach ([_group] call ACF_getGroupVehicles);
	};

	// Log aircraft-specific behavior
	if ([_group] call ACF_grp_isAircraft && DEBUG_MODE) then {
		private _multiplier = switch (_behavior) do {
			case B_SILENT: { 0.6 };
			case B_TRANSPORT: { 1.3 };
			default { 1 };
		};
		systemChat format ["[Air] %1 - Speed: %2%, Height: %3m", 
			GVAR(_group,"callsign"),
			(_multiplier * 100) toFixed 0,
			HELI_ALT * _multiplier
		];
	};

	SVARG(_group,"#b",_behavior);
};

// TODO: Make the function more universal
AC_ai_fireMission = {
	params ["_group","_pos",["_spread",50],["_nRounds",4],["_sender",objNull]];
	private _artillery = vehicle leader _group;
	private _types = (getArtilleryAmmo [_artillery]);
	if (count _types == 0) exitWith {playSound "3DEN_notificationWarning"};
	private _roundType = _types#0;

	if (_pos isEqualType objNull) then {
		_pos = getPosWorld _pos;
	};
	private _roundPos = [_pos, _spread] call ACF_randomPos;

	// Check if target can be hit
	private _eta = _artillery getArtilleryETA [_roundPos, (getArtilleryAmmo [_artillery])#0];
	if (_eta == -1) exitWith {playSound "3DEN_notificationWarning"};

	// Create simulation zone, a small one
	doStop _artillery;
	private _simulationZone = (group ((entities "logic") select 0)) createUnit ["LOGIC",_pos , [], 0, ""];
	_simulationZone setVariable ["simulationRange", 300];
	AC_battlesInProgress pushBack _simulationZone;

	if (!isNull _sender) then {
		if (_eta > -1) then {
			[_eta,_pos,_spread + 15] remoteExec ["ACF_showFireZone", _sender];
		} else {
			"3DEN_notificationWarning" remoteExec ["playSound",_sender];
		};
	};
	_artillery commandArtilleryFire [_roundPos, _roundType, 4];
	sleep (_eta + 10);
	AC_battlesInProgress = AC_battlesInProgress - [_simulationZone];
	deleteVehicle _simulationZone;
};

ACF_showFireZone = {
	params ["_eta","_pos","_spread"];

	// Prepare marker
	playSound "FD_Finish_F";
	private _mrk = createMarkerLocal [str _pos,_pos];
	_mrk setMarkerShapeLocal "ELLIPSE";
	_mrk setMarkerSizeLocal [_spread,_spread];
	_mrk setMarkerColorLocal "colorBlack";
	_mrk setMarkerColorLocal "colorBlack";
	_mrk setMarkerAlphaLocal 0.5;
	sleep (_eta + 10);
	deleteMarkerLocal _mrk;
};

ACF_wp_getIn = {
	params ["_group","_target",["_auto",false]];
	// Target must be position or object
	if (_target isEqualType grpNull) then {
		_target = vehicle leader _target;
	};

	if(DEBUG_MODE) then {
		systemChat format ["[Transport] %1 boarding %2 (%3)", 
			_group,
			_target,
			if(_auto) then {"auto"} else {"ordered"}
		];
	};
	_group setCombatMode "YELLOW";
	_group setCombatBehaviour "SAFE"; //encourages road use, will switch to AWARE automatically if engaged

	// Add or edit waypoint
	deleteWaypoint [_group, 0];
	private _wp = _group addWaypoint [getPosATL _target, 0,0];

	if (_auto) then {
		_wp setWaypointType "GETIN NEAREST";
	} else {
		units _group allowGetIn true;
		_wp waypointAttachVehicle _target;
		_wp setWaypointType "GETIN";
		{
			[_x] orderGetIn true;
		} forEach units _group;
		_target setUnloadInCombat [FALSE,FALSE];       // passengers and person turrets stay mounted
		private _targetGroup = group effectiveCommander _target;
		if ([_targetGroup] call ACF_grp_isAircraft) then {
			// Order aircraft to get to the group and land nearby
			deleteWaypoint [_targetGroup, 0];
			[_targetGroup, getPosWorld leader _group, leader _group] remoteExec ["BIS_fnc_wpLand",2];
		};

	};
};

//TO do: add tranport unload/dismount for motorized infantry type units

ACF_wp_unload = {
	params ["_group"];
	private _transportedGroups = [_group] call ACF_ui_getTransportedGroups;
	// Remove all waypoints
	{
		while {count waypoints _x > 0} do {
			deleteWaypoint ((waypoints _x)#0);
		};
	} forEach (_transportedGroups + [_group]);
	//private _wp = _group addWaypoint [getPosWorld leader _group,0];
	//_wp setWaypointType "TR UNLOAD";
	_transportedGroups = _transportedGroups - [_group];
	_target = vehicle leader _group;
	_target setUnloadInCombat [TRUE,FALSE];       // passengers dismount

	{
		// Create get out waypoint for all groups
		private _wp = _x addWaypoint [getPosATL leader _x, 0];
		_wp setWaypointType "GETOUT";
		{
			// TODO: Test it in MP, I might need to remoteExec it!
		    unassignVehicle _x;
			[_x] orderGetIn false;
		} forEach units _x;
	    _x leaveVehicle _target;
	} forEach _transportedGroups;

	if(DEBUG_MODE) then {
		systemChat format ["[Transport] %1 unloading %2 groups", 
			GVAR(_group,"callsign"),
			count _transportedGroups
		];
	};
};

ACF_wp_getOut = {
	params ["_group"];
	deleteWaypoint [_group, 0];
	private _unlVeh = [_group] call ACF_getGroupVehicles;
	if (!isNil "_unlVeh") then {
		{
			_x setUnloadInCombat [TRUE,TRUE];       // passengers and person turrets will dismount
		} forEach _unlVeh;
		private _wp = _group addWaypoint [_unlVeh#0, 0,0];
		_wp setWaypointType "GETOUT";
	};
};

