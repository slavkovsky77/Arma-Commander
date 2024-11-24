#include "\AC\defines\commonDefines.inc"

// Handling fire support

/*
	Struktura supportu:
	Support má vlastní modul, který zaregistruješ k battalionu
	Support má vlastní strukturu v rámci battalionu

	Struktura:
		Side - ke kterýmu je to battalionu
		Type
		Ammo type
		nRounds
		Cost
		Timeout
*/

// Register supports in modules.
ACF_registerSupports = {
	params ["_battalion","_type"];
	private _side = GVAR(_battalion,"side");

	private _data = [];
	private _supports = [];
	if (_type != "Custom") then {
		_supports = getArray (configfile >> "AC" >> "Battalions" >> _type >> "Supports");

		// Data structure
		{
			private _cfg = configfile >> "AC" >> "Supports" >> _x;
			_data pushBack [
				getText 	(_cfg >> "name"), 			// 0
				getText 	(_cfg >> "tooltip"),		// 1
				getNumber 	(_cfg >> "cost"),			// 2
				getNumber 	(_cfg >> "timeout") + time,	// 3
				getNumber 	(_cfg >> "timeout"),		// 4
				getNumber 	(_cfg >> "type"),			// 5
				getText 	(_cfg >> "ammo"),			// 6
				getNumber 	(_cfg >> "nRounds"),		// 7
				getNumber 	(_cfg >> "radius"),			// 8
				{true}									// 9
			];
		} forEach _supports;
	};

	{
		if ([GVAR(_x,"side")] call AC_fnc_numberToSide == _side) then {
			private _condition = GVAR(_x,"condition");
			if(_condition == "") then {_condition = "true"};
			_data pushBack [
				GVAR(_x,"name"), 			// 0
				GVAR(_x,"tooltip"), 		// 1
				GVAR(_x,"cost"),			// 2
				GVAR(_x,"timeout") + time,	// 3
				GVAR(_x,"timeout"),			// 4
				SUPPORT_ARTY,				// 5
				GVAR(_x,"ammo"),			// 6
				GVAR(_x,"nRounds"),			// 7
				GVAR(_x,"radius"),			// 8
				compileFinal _condition		// 9
			];
		};
	} forEach (entities "AC_ModuleArtillerySupport");

	{
		if ([GVAR(_x,"side")] call AC_fnc_numberToSide == _side) then {
			private _condition = GVAR(_x,"condition");
			if(_condition == "") then {_condition = "true"};
			_data pushBack [
				GVAR(_x,"name"), 			// 0
				GVAR(_x,"tooltip"), 		// 1
				GVAR(_x,"cost"),			// 2
				GVAR(_x,"timeout") + time,	// 3
				GVAR(_x,"timeout"),			// 4
				SUPPORT_CAS,				// 5
				GVAR(_x,"Aircraft"),		// 6
				GVAR(_x,"SupportMode"),		// 7
				GVAR(_x,"Height"),			// 8
				compileFinal _condition	// 9
			];
		};
	} forEach (entities "AC_ModuleCAS");

	SVARG(_battalion,"ec_supportsList",_data);
};

#define SUPPORTS_ETA 20
// Server function
ACF_callSupport = {
	params ["_pos","_battalion","_index"];
	private _data = (GVAR(_battalion,"ec_supportsList")#_index);
	_data params ["_name","_tooltip","_cost","_timeout","_defaultTimeout","_type","_support","_nRounds","_radius","_condition"];

	// Remove commander's money, reset timeout
	private _side = GVAR(_battalion,"side");
	private _points = GVAR(_battalion,"points");
	if (_points < _cost) exitWith {};
	SVARG(_battalion,"points", _points - _cost);

	// Create fire support marker:
	if (_type == SUPPORT_ARTY) then {
		[_pos,_radius, _nRounds * 5 + SUPPORTS_ETA,_index] remoteExec ["ACF_drawSupportArea",_side];
		sleep SUPPORTS_ETA;
		[_pos, _support, _radius, _nRounds, 4, {}, 0, 250, 150, ["shell1","shell2"]] spawn BIS_fnc_fireSupportVirtual;
	} else {
		[_pos, 115, 3 * SUPPORTS_ETA,_index] remoteExec ["ACF_drawSupportArea",_side];
		sleep SUPPORTS_ETA;
		if (isNil "_radius") then {_radius=600;};
		[[_pos, 25] call ACF_randomPos, _support, _side, _battalion, _nRounds, _radius] spawn ACF_CAS;
	};
};

// Show or hide buy button
ACF_ui_buttonSupportsPressed = {
	// Find out position of the button in the table
	private _battalion = AC_playerBattalion;
	private _index = (ctCurSel UGVAR("ac_supportsList"));

	setMousePosition [0.5,0.5];
	AC_supportMode = true;

	// Wait for clicking or closing map
	waitUntil {AC_supportsPlaced#0 != 0 || {!visibleMap}};
	if (!visibleMap) exitWith{}; // do not fire if map closed!
	((UGVAR("ac_supportsList") ctRowControls _index)#5) ctrlEnable false;
	[AC_supportsPlaced, _battalion, _index] remoteExec ["ACF_callSupport",2];

	AC_supportMode = false;
	AC_supportsPlaced = [0,0,0];

	// Wait for UI update
	[] spawn {
		private _points = GVAR(AC_playerBattalion,"points");
		waitUntil {GVAR(AC_playerBattalion,"points") != _points};
		[] call ACF_ui_updateCommandUI;
	};
};

ACF_getSupportRadius = {
	private _index = ctCurSel UGVAR("ac_supportsList");
	private _data = GVAR(AC_playerBattalion,"ec_supportsList");
	private _radius = _data#_index#8;
	if (_data#_index#5 == SUPPORT_CAS) then {_radius = 115};
	_radius
};

ACF_drawSupportArea = {
	params ["_pos","_radius","_timeout","_index"];

	private _data = GVAR(AC_playerBattalion,"ec_supportsList");
	private _typeData = _data#_index;
	private _name = _typeData#0;

	// Restart timeout
	_typeData set [3,time + (_typeData#4)];
	SVARG(AC_playerBattalion,"ec_supportsList",_data);
	// Switch timeout to default timeout

	private _mrk = createMarkerLocal [str _pos,_pos];
	_mrk setMarkerShapeLocal "ELLIPSE";
	_mrk setMarkerSizeLocal [_radius,_radius];
	_mrk setMarkerAlphaLocal 0.5;

	private _mrk2 = createMarkerLocal [str (_pos + [0]),_pos];
	_mrk2 setMarkerShapeLocal "ICON";
	_mrk2 setMarkerTypeLocal "hd_destroy";
	_mrk2 setMarkerTextLocal _name;

	sleep (_timeout + 5);
	deleteMarkerLocal _mrk;
	deleteMarkerLocal _mrk2;
};

// HEAVILY modified BIS_fnc_moduleCAS from Karel Moricky
ACF_cas = {
	params ["_pos","_aircraft","_side","_caller","_weaponTypesID",["_height",600]];
	private _dir = _caller getDir _pos;
	//fly from nearby base or battalion location
	private _basesToSpawn = [_side] call ACF_findSpawnBases;
	_basesToSpawn = [_basesToSpawn,[],{_x distance _pos},"ASCEND"] call BIS_fnc_sortBy;
	if (count _basesToSpawn > 0) then {
		{
			if ( _x distance _pos > 850 && _x distance _caller < _pos distance _caller) exitwith { _caller = _x};
		} foreach _basesToSpawn;
	};

	//--- Detect guns
	_weaponTypes = switch _weaponTypesID do {
		case 0: {["machinegun","cannon","vehicleweapon","vn_mgun_base","vn_autocannon_base","lib_planemgun_base","lib_planecannon_base","mgun","autocannon_base_f"]};
		case 1: {["missilelauncher","rocketpods","vn_rocketpod_base"]};
		case 2: {["machinegun","missilelauncher","rocketpods","vn_rocketpod_base","cannon","vehicleweapon","vn_mgun_base","vn_autocannon_base","lib_planemgun_base","lib_planecannon_base","mgun","autocannon_base_f"]};
		case 3: {["bomblauncher","vn_bomblauncher","weapon_lgblauncherbase","lib_bomb_mount_base"]};
		default {[]};
	};
	_weapons = [];
	{
		_weaponType = tolower ((_x call bis_fnc_itemType) select 1);
		if (_weaponType in _weaponTypes) then {
			_modes = getarray (configfile >> "cfgweapons" >> _x >> "modes");
			_mode = _modes select 0;
			if (_mode == "this") then {_mode = _x;};
			if (count _modes > 0) then {
				_ff = !(_weaponType in ["bomblauncher","vn_bomblauncher","weapon_lgblauncherbase","lib_bomb_mount_base","missilelauncher","rocketpods","vn_rocketpod_base"]);
				_weapons set [count _weapons,[_x,_mode,_ff]];
			};
		};
	} foreach (_aircraft call bis_fnc_weaponsEntityType);

	//--- Create plane
	private _planePos = [getPosASL _caller,-850,_dir] call bis_fnc_relpos;
	_adjust = _height + (getTerrainHeightASL getPosWorld _caller max getTerrainHeightASL _pos);
	private _speed = 80;
	_planePos set [2,_adjust];
	_dir = _planePos getDir _pos;
	private _planeArray = [_planePos,_dir,_aircraft,_side] call bis_fnc_spawnVehicle;
	_plane = _planeArray#0;
	_pos set [2,0]; //This makes the bombs hit... for RHS anyway
	_plane move _pos;
	_plane limitSpeed 120;
	_plane flyInHeightASL [_height, 20, (_height * 2)];
	_plane flyInHeight _height;
	_plane disableai "target";
	_plane disableai "autotarget";
	_plane setcombatmode "blue";
	private _planegroup = group _plane;
	private _distance = 700;
	switch (_weaponTypesID) do {
		case 0: {_adjust = 0;};
		case 1: {_adjust = 0.25;};
		case 2: {_adjust = 0.2;};
		case 3: {
			_adjust = 0.225;
			_distance = 550;
		};
		default {_adjust = 0.2;};
	};
	_distance = _distance + ((_height-100)*0.3);
	_plane setVelocity [
		(sin _dir * _speed),
		(cos _dir * _speed),
		0
	];

	//--- Approach
	_fire = [] spawn {waituntil {false}};
	_fireNull = true;
	private _time = 3 + ((_height-100)*0.0025);
	_pilot = driver _plane;
	waituntil {
		//--- Fire!
		if ( (getposasl _plane) distance2d _pos < _distance && _fireNull) then {
			_plane flyInHeight 40;
			_plane enableai "target";
			_plane enableai "autotarget";
			_plane setBehaviour "COMBAT";
			//--- Create laser target if no targeting laser with 50m
			private _targetType = if (_side getfriend west > 0.6) then {"LaserTargetW"} else {"LaserTargetE"};
			private _target = ((_pos nearEntities [_targetType,50])) param [0,objnull];
			if (isnull _target) then {
				_target = createvehicle [_targetType,_pos,[],1,"none"];
			};
			_pilot dowatch _target;
			_plane move getPosASL _target;
			_time = time + _time;
			waituntil {
				_pilot lookAt _target;
				sleep 0.1;
				time > (_time - 2)  || {_weaponTypesID == 3} || {0 < _plane aimedAtTarget [_target]} || {!(alive _plane)} // align to target
			};
			if (isnull _target) then {
				_target = createvehicle [_targetType,_pos,[],1,"none"];
			};
			_fireNull = false;
			terminate _fire;
			_fire = [_plane,_weapons,_target,_weaponTypesID,_pilot,_time,_adjust] spawn {
				_plane = _this select 0;
				_weapons = _this select 1;
				_target = _this select 2;
				_weaponTypesID = _this select 3;
				_pilot = _this select 4;
				_time = _this select 5;
				_adjust = _this select 6;
				_fired = false;
				waituntil {
        			_pilot dotarget _target;
					sleep 0.1;
					{
						if ( (_x select 2) || {_adjust < _plane aimedAtTarget [_target,(_x select 0)]} || {time > _time } ) then {
							_fired = _plane fireattarget [_target,(_x select 0)];
							if (!_fired) then {
								_plane selectweapon (_x select 0);
								_weapon = [_x select 0,_x select 1];
								_pilot forceweaponfire _weapon;
								_fired = true;
							};
						};
					} foreach _weapons;
					time > _time || (_weaponTypesID == 3 && _fired) || {!(alive _plane)} //--- Shoot only for specific period or only one bomb
				};
				sleep 0.1;
			};
		};
		scriptdone _fire || isnull _plane
	};
	_plane limitSpeed 1000;
	_plane move ([_pos,-2000,_dir] call bis_fnc_relpos);
	_pilot setBehaviour "STEALTH";

	sleep 35;
	// Delete plane
	if (alive _plane) then {
		{deletevehicle _x} foreach (crew _plane);
	    _planegroup deleteGroupWhenEmpty true;
		if !(local _planegroup) then {
		    [_planegroup, true] remoteExec ["deleteGroupWhenEmpty", groupOwner _planegroup];
		};
		deletevehicle _plane;
	};
};