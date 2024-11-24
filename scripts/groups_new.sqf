#include "\AC\defines\commonDefines.inc"

ACF_grp_createGroup = {
	params ["_type","_side","_pos"];
	// UnitList, vehicleList, skill
	private _battalion = [_side] call ACF_battalion;
	private _skill = [_type,_side] call ACF_getSkill;
	_skill = _skill * GVARS(_battalion,"skillMultiplier",1);
	private _soldiers = [_type,"units"] call ACF_getGroupArray;
	private _vehicles = [_type,"vehicles"] call ACF_getGroupArray;
	private _groupType = [_type,"type"] call ACF_getGroupNumber;
	private _aircraft = _groupType == TYPE_AIR;
	private _dir = _battalion getDir _pos;

	// Should unit spawn in air?
	private _airSpawn = true;
	private _module = MGVARS(_type,objNull);
	if (!isNull _module && {typeOf _module == "AC_ModuleRegisterGroup"}) then {
		_airSpawn = GVARS(_module,"airSpawn",true);
	};

	// Loadouts
	private _customLoadouts = GVARS(_module,"Loadouts",false);
	private _loadouts = [];
	if (_customLoadouts) then {
		_loadouts = GVARS(_module,"unitLoadouts",[]);
		if (count _loadouts == 0) then {_customLoadouts = false};
	};

	// Create all units
	private _vehicleObjects = [];
	private ["_windComp", "_vehicle", "_unit", "_finalPos","_para","_inVehicle","_airPos","_vel","_speed"];

	private _ngroup = createGroup [_side, false];

	if (_airSpawn) then {
		_ngroup setCombatMode "BLUE";
	};
	_finalPos = _pos;
	_finalPos set [2,120];
	_pos set [2,0];

	private _unitData = GVARS(_battalion,"ec_unitList",[]);
	private _i = _unitData findIf {_type == _x#0};
	private _defaultCost = _unitData#_i#1;
	private _vehicleCost = 0;

	if (count _vehicles > 0) then {_vehicleCost = _defaultCost / (count _vehicles);};

	{
		sleep 1;
		if (!_aircraft) then {
			// Create vehicle and his parachute, give him proper position
			_vehicle = _x createVehicle _pos;
			_vehicle setDir _dir;
			if (_airSpawn) then {
				// Parachute spawn
				_windComp = [0,0,-4] vectorDiff (wind vectorMultiply 5);
				_para = createVehicle ["B_Parachute_02_F",_finalPos, [], 35, "FLY"];
				_vehicle attachTo [_para,[0,0,0]];
				_para setDir _dir;
				//adjust for Wind with incoming drop velocity
				_vehicle setVelocity _windComp;
				_para setVelocity _windComp;
				[_vehicle,_para,true] spawn ACF_handleParadrop;
			};
			_vehicle limitSpeed VEHICLE_SPEED_LIMIT;
		} else {
			// Create Aircraft and give him proper position
			_airPos = [_finalPos,-DEPLOY_RADIUS,_dir] call bis_fnc_relpos;
			_airPos set [2,150];
			_vehicle = createVehicle [_x, _airPos, [], 10, "FLY"];
			_vehicle setVectorDir [
				sin _dir,
				cos _dir,
				1
			];
			if (_vehicle isKindOf "Plane") then {
				_speed = 50;
			} else {
				_vehicle flyInHeight HELI_ALT;
				_vehicle flyInHeightASL [HELI_ALT*2, HELI_ALT, HELI_ALT*3];
				_speed = 25;
				_vehicle limitSpeed SPEED_LIMIT_AIR;
			};
			_vehicle setVelocity [
				(sin _dir * _speed),
				(cos _dir * _speed),
				0
			];
			_ngroup move _finalPos;
		};
		_vehicleObjects pushBack _vehicle;
		_ngroup addVehicle _vehicle;
		_vehicle allowCrewInImmobile true;
		SVARG(_vehicle, "VehValue", _vehicleCost);
		true
	} count _vehicles;

	{
		_unit = _ngroup createUnit [_x,_pos,[],10,"NONE"];
		_inVehicle = [_unit,_vehicleObjects] call ACF_grp_moveInFreeVehicle;
		if (_customLoadouts) then {
			_unit setUnitLoadout (_loadouts#_forEachIndex);
		};
		[_unit] joinSilent _ngroup; //side fix
		_unit triggerDynamicSimulation true; //test
		_unit setSkill _skill;
		if (isNull _inVehicle && _airSpawn) then {
			_windComp = [0,0,-4] vectorDiff (wind vectorMultiply 6);
			_finalPos set [2,_finalPos#2 + 1];
			_para = createVehicle  ["Steerable_Parachute_F",_finalPos, [], 38, "FLY"];
			_unit moveInDriver _para;
			//adjust for Wind with incoming drop velocity
			_para setVelocity _windComp;
			_unit setVelocity _windComp;
			//lockIdentity _unit;
			[_unit,_para,false] spawn ACF_handleParadrop;
		};
		sleep 1;
	} forEach _soldiers;

	if (_customLoadouts) then { [_ngroup] call ACF_saveLoadouts };
	SVARG(_battalion,"requestQueue", GVAR(_battalion,"requestQueue") - 1);

	if (count _vehicleObjects > 0) then {
		reverse _vehicleObjects; //get leader of First vehicle
		_ngroup selectLeader (effectiveCommander (_vehicleObjects#0));
	};

	_ngroup setCombatMode "YELLOW";

	private _callsign = [_ngroup] call ACF_grp_setCallsign;
	private _data = [_type,_callsign,_skill];
	SVARG(_ngroup, "resetStr", true);
	SEND_GROUP_DATA(_ngroup,_data);
};

// Group-based version of saving loadouts
ACF_saveLoadouts = {
	params ["_group"];
	private _loadouts = [];
	{
		SVARG(_x,"#i",_forEachIndex);
		_loadouts pushBack (getUnitLoadout _x);
	} forEach units _group;
	SVARG(_group,"#loadouts",_loadouts);
};

// Give soldiers with proper indexes their loadouts
ACF_applyLoadouts = {
	params ["_group"];
	private _loadouts = GVARS(_group,"#loadouts",[]);
	private _maxI = (count _loadouts) - 1;
	{
		private _i = GVARS(_x,"#i",-1);
		if (_i > -1 && _i <= _maxI) then {
			_x setUnitLoadout [_loadouts#_i,true];
		};
		sleep 1;
	} forEach (units _group select {alive _x});
};

// Give soldiers with proper indexes their loadouts
ACF_applyResupply = {
	params ["_group","_men"];
	private _loadouts = GVARS(_group,"#loadouts",[]);
	private _maxI = (count _loadouts) - 1;
	{
		_x setDamage 0;
		private _i = GVARS(_x,"#i",-1);
		if (_i > -1 && _i <= _maxI) then {
			_x setUnitLoadout [_loadouts#_i,true];
		} else {
			_X setUnitLoadout typeof _x; //no custom? restore default
		};
		sleep 1;
	} forEach (_men);
};

/*
ACF_grp_saveGroupLoadouts = {
	params ["_group"];
	private _side = side _group;
	private _battalion = [_side] call ACF_battalion;
	private _loadouts = GVARS(_battalion,"loadouts",[]);
	private _nLoadouts = count _loadouts;
	{
		private _type = typeOf _x;
		if (_loadouts findIf {_x#0 == _type} == -1) then {
			_loadouts pushBack [_type, getUnitLoadout _x];
		};
	} forEach units _group;
	if (count _loadouts != _nLoadouts) then {
		SVARG(_battalion,"loadouts",_loadouts);
	};
};
*/

ACF_handleParadrop = {
	params ["_unit","_para","_isCar"];
	waitUntil { (getPosATL _unit)#2 < 2 || { (velocity _unit select 2) == 0 } };
	//_unit allowDamage false;

	if (_isCar) then {
		waitUntil { (getPosATL _unit)#2 < 1 || { (velocity _unit select 2) == 0 } };
		detach _unit;
		_unit SetVelocity [0,0,-3];
		sleep 0.05;
		_unit SetVelocity [0,0,0];
	};

	waitUntil { isTouchingGround _unit };
	//_unit allowDamage true;
	sleep 3;
	deleteVehicle _para;
};

ACF_getSkill = {
	params ["_type","_side"];
	private _module = MGVARS(_type,objNull);
	private _skill = 0.4;
	if (isNull _module) then {
		private _battalion = [_side] call ACF_battalion;
		private _batConfig = configfile >> "AC" >> "Battalions" >> GVAR(_battalion,"type");
		_skill = getNumber (_batConfig >> "combatElement" >> _type >> "skill");
	} else {
		_skill = GVAR(_module,"skill");
	};
	_skill
};

ACF_getGroupVehicles = {
	params ["_group"];
	private _vehicles = (units _group) select {private _veh = objectParent _x;
		!isNull _veh && {_x == effectiveCommander _veh}
		&& {typeOf _veh != "Steerable_Parachute_F" && typeOf _veh != "B_Parachute_02_F"}
	};
	_vehicles = _vehicles apply {objectParent _x};
	_vehicles
};