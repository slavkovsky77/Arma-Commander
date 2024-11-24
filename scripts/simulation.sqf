#include "\AC\defines\commonDefines.inc"

// Only base simulation is calculated now
ACF_checkSimulation = {
	//predefine loop variables and get defines to improve effeciency
	private ["_pos", "_enemySide", "_deployed","_base","_flag","_baseSide","_nearUnits","_peri"];
	private	_spawnR = SPAWN_RANGE;
	private	_despawnR = DESPAWN_RANGE;
	private	_dFalse = DEPLOYED_FALSE;
	private	_dTrue = DEPLOYED_TRUE;
	{
		_pos = getPosATL _x;
		_baseSide = GVARS(_x,"side",sideUnknown);
		_enemySide = _baseSide call ACF_enemySide;
		_deployed = GVAR(_x,"deployed");

		if (_deployed == _dFalse) then {
			if ( (_pos nearEntities [["Man", "AllVehicles"], _spawnR]) findIf {side _x == _enemySide} > -1 )
			 exitWith {	[_x] spawn AC_gar_deployGarrison; };
		};

		//folded detection and battle start into base sim to save processing, no need to check undeploy while contested and that is when sim gets intense
		if ( !GVARS(_x,"contested",false) ) then {
			_nearUnits = _pos nearEntities [["Man", "AllVehicles"], _despawnR];
			if (_deployed == _dTrue) then {
				if ( _nearUnits findIf {side _x == _enemySide} == -1 )
				 exitWith {	[_x] spawn AC_gar_undeployGarrison;	};
			};
			//recycle the array to save processing
			_peri = GVAR(_x,"out_perimeter");
			_nearUnits = _nearUnits select { _x distance _pos < _peri };
			private _sides = ([west, east, independent] - [_baseSide]);
			if ( _nearUnits findIf {side _x in _sides} > -1 ) then {
				_x spawn ACF_battleAgent;
				private _color = "Wdetected";
				private _baseEnc = _x;
				{
					private _detectingSide = _x;
					if ( _nearUnits findIf {side _x == _detectingSide} > -1 ) then {

						_color = switch (_x) do {
						    case west: { "Wdetected" };
						    case east: { "Edetected" };
						    case resistance: { "Idetected" };
						};
						if (!GVARS(_baseEnc,_color,true)) then {
							SVARG(_baseEnc,_color,true);
							[_baseEnc] remoteExec ["ACF_ui_revealGroup",_x];
						};

					};
					true
				} count _sides;
			};
		};
		true
	} count AC_bases;
};


// New new group detection check, may be less sensitive but should mimic other stealth systems and be less intensive.
ACF_groupdetectionCheck = {

	private ["_side", "_enemy", "_ownGroups", "_group","_leader","_color"];
	{
		_side = GVAR(_x,"side");
		_enemy = [_side] call ACF_enemySide;
		_color = switch (_enemy) do {
		    case west: { "Wdetected" };
		    case east: { "Edetected" };
		    case resistance: { "Idetected" };
	    	default { "Wdetected"};
		};
		_ownGroups = AC_operationGroups select {side _x == _side};

		{
			_group = _x;
			_leader = vehicle leader _x;
			if (!GVARS(_group,_color,false)) then {
				if (_enemy knowsAbout _leader > DETECTION_THRESHOLD) exitWith {
					SVARG(_group,_color,true);
					[_group] remoteExec ["ACF_ui_revealGroup",_enemy];
					//systemChat format ["%1 Revealed!", GVAR(_group,"callsign")];
				};
			} else {
				if (_enemy knowsAbout _leader <= DETECTION_THRESHOLD) then {
						SVARG(_group,_color,false);
						//systemChat format ["%1 Forgotten", GVAR(_group,"callsign")];
				};
			};
			true
		} count _ownGroups;
		true
	} count AC_battalions;
};
