#include "\AC\defines\commonDefines.inc"

ACF_grp_moveInFreeVehicle = {
	params ["_unit","_vehicles"];
	if (count _vehicles == 0) exitWith {objNull};

	// Sort vehicles by amount of crew, descendant
	_vehicles = [_vehicles,[],{count crew _x},"ASCEND"] call BIS_fnc_sortBy;

	// Try to move vehicles inside
	private ["_veh", "_paths"];
	private _in = objNull;
	private _moved = false;
	{
    	if ( !(_x isKindOf "Air") && !(_x isKindOf "Truck_F") ) then {
			if (_unit moveInCommander _x) exitWith {_unit assignAsCommander _x; _in = _x;};
			if (_unit moveInDriver _x) exitWith {_unit assignAsDriver _x; _in = _x;};

			//fix for tankers riding outside.
			_veh = _x;
			_paths = allTurrets _veh;
			{
				_moved = [_veh, _unit, ["turret", _x]] call BIS_fnc_moveIn;
				if (_moved) exitWith {_in = _veh};
			} forEach _paths;
			if (_moved) exitWith {_in = _x};

			if (_unit moveInGunner _x) exitWith {_unit assignAsGunner _x; _in = _x;};
			if (_unit moveInAny _x) exitWith {_in = _x};
		} else {
			if (_unit moveInAny _x) exitWith {_in = _x};
		};
	} forEach _vehicles;
	_in
};

AC_grp_handleKilledUnit = {
	params ["_killed"];
	private _group = group _killed;
	private _base = GVARS(_group,"base",objNull);
	private _side = side _group;

	debugLog "Handling killed unit";
	private _men = units _group select {alive _x};

	if (!isNULL _base) then {
		// Precise recounting of actual units alive
		private _group = GVARS(_base,"staticGroup",grpNull);
		private _nSoldiers = ({alive _x} count units _group);
		SVARG(_base,"nSoldiers",_nSoldiers);
		if ( speedMode _group == "LIMITED") then {
			private _wp = _group addWaypoint [_base, 5, 0];
			_wp setWaypointType "SAD";
			_group setSpeedMode "FULL";
		};
	};
	if (GVARS(_group, "resetStr", false) == false) then {SVARG(_group, "resetStr", true);};

	//replace leader manually if nessicary
	private _groupLead = leader _group;
	if (_groupLead == objNull || _groupLead == _killed) then {
  		private _vehicles = [_group] call ACF_getGroupVehicles;
		_groupLead = _men#0;
		if (count _vehicles > 0) then {
			private _vehicle = _vehicles#0;
			_groupLead = effectiveCommander _vehicle;
			if (_groupLead == objNull || {!(alive _groupLead)}) then {
				_groupLead = driver _vehicle;
				if (_groupLead == objNull || {!(alive _groupLead)}) then { _groupLead = _men#0; };
			};
		};
		[group _groupLead, _groupLead] remoteExec ["selectLeader", groupOwner group _groupLead];
	};

	// Delete group if it's empty
	_men = units _group select {alive _x};
	if (count _men == 0) then  {
	    //[_group, _side] remoteExec ["ACF_grp_handleEmptyGroup", 0];
		[_group,_side] spawn ACF_grp_handleEmptyGroup;
	} else {
		[_killed,_side] spawn AC_grp_handleDeadUnit;
	};
};

AC_grp_handleDeadUnit = {
	params ["_killed","_side"];
	sleep 1;
	private _ngroup = createGroup [_side, true];
	_ngroup enableDynamicSimulation true;
	[_killed] joinSilent _ngroup;
};


ACF_grp_handleEmptyGroup = {
	params ["_group","_side"];
	private _callsign = GVAR(_group,"callsign");
	private _operationIndex = AC_operationGroups findIf {_group == _x};
	//private _localityChanged = _group setGroupOwner 2;
	if (_operationIndex > - 1) then {
		// Delete group from operation group and battalion
		//[AC_operationGroups,_group] remoteExec ["REMOVE_DATA_MISSION",2];
		//REMOVE_DATA_MISSION("AC_operationGroups",_group); // Remove group globally
  	 	REMOVE_GROUP(_group);

		// Send notifications
		private _otherSides = [WEST, EAST, RESISTANCE] - [_side];
		SEND_NOTIFICATION(NN_GROUP_LOST,_callsign,_side);
		SEND_NOTIFICATION(NN_GROUP_KILLED,"",_otherSides);
	};
	//Remove last man
	private _ngroup = createGroup [_side, true];
	_ngroup enableDynamicSimulation true;
	{
		[_x] joinSilent _ngroup;
	} forEach units _group;
	_group enableDynamicSimulation true;
    if (local _group) then
	{
		clearGroupIcons _group;
		_group deleteGroupWhenEmpty true;
	}
	else // group is local to a client
	{
    	[_group] remoteExec ["clearGroupIcons", groupOwner _group];
		[_group, true] remoteExec ["deleteGroupWhenEmpty", groupOwner _group];
	};

};

ACF_grp_setCallsign = {
	params ["_group", ["_callsign",""]];
	private _battalion = [side _group] call ACF_battalion;

	if (_callsign == "") then {
		_callsign = [_battalion] call ACF_assignCallsign;
	};
	_callsign
};

// Very simple function for now.
ACF_grp_addGroupXp = {
	params ["_killer", "_killed"];
	private _group = group _killer;
	private _nSoldiers = {alive _x} count units _group;
	private _skill = skill leader _group;

	//if (DEBUG_MODE) then {systemChat format ["%1 skill,", _skill]};
	// Friendly fire does not add any skill
	if (side group _killed == side group _killer || _nSoldiers == 0) exitWith {};
	//if (DEBUG_MODE) then {systemChat format ["%1 skills,", _skill]};

	private _newSkill = _skill + (XP_KILL_RATIO / _nSoldiers);
	if (_newSkill > 1) then {_newSkill = 1}; // Clamp

	// Change everyone's skill, and update group's skill
	{
		_x setSkill _newSkill;
	} forEach units _group;
};

ACF_ui_baseReinforce = {
	params ["_base","_battalion"];
	//if (count AC_selectedGroups == 0 || {isNull (AC_selectedGroups#0)}) exitWith {};

	private _newSoldiers = GVAR(_base,"nSoldiersOriginal");

	//can units be reinforced?
	private _resupplyCost = _newSoldiers - GVAR(_base,"nSoldiers");
	private _modifier = 1;
	private _points = GVAR(_battalion,"points");
	private _module = GVARS(_battalion,"module",objNull);
	if (isNull _module) then {
		private _conf = configfile >> "AC" >> "Battalions" >> _battalion getVariable "type" >> "Reserves";
		_modifier = getNumber (_conf >> "modifier");
		_resupplyCost = ceil (_resupplyCost * _modifier);
	} else {
		_modifier = GVARS(_module,"modifier",1);
		_resupplyCost = ceil (_resupplyCost * _modifier);
	};

	if (_points < _resupplyCost) exitWith {};
	SVARG(_base,"nSoldiers", _newSoldiers);
	SVARG(_battalion,"points",GVAR(_battalion,"points") - _resupplyCost);
};

// Server function
ACF_resupplyGroup = {
	params ["_group","_battalion","_cost"];
	// DEBUG
	//systemChat str _this;
	if (isNull _group || GVAR(_battalion,"points") - _cost < 0) exitWith {};
	/*
		1. Find classes to create and spawn them above
		2. Change internal data, after everything is spawned
		3. Resupply all vehicles
	*/
	SVARG(_group,"noResupply", 1);
	SVARG(_battalion,"points",GVAR(_battalion,"points") - _cost);

	private _type = GVAR(_group,"typeStr");
	private _newSoldiers = +([_type,"units"] call ACF_getGroupArray);

	// Should unit spawn in air?
	private _airSpawn = true;
	private _module = MGVARS(_type,objNull);
	if (!isNull _module && {typeOf _module == "AC_ModuleRegisterGroup"}) then {
		_airSpawn = GVARS(_module,"airSpawn",true);
	};

	private _skill = skill leader _group;
	private _soldiers = units _group select {alive _x};
	private _vehicles = [_group] call ACF_getGroupVehicles;
	private _currentSoldiers = _soldiers apply {typeOf _x};
	private _currentVehicles = _vehicles apply {typeOf _x};

	// Use indexes of soldiers to find out which needs to be replaced
	private _soldierIndexes = [];
	private ["_windComp", "_str", "_i", "_unit", "_finalPos","_para","_inVehicle"];
	{_soldierIndexes pushBack _forEachIndex} forEach _newSoldiers;
	{
		_soldierIndexes = _soldierIndexes - [GVARS(_x,"#i",-1)];
	} forEach _soldiers;

	// Remove those objects that already exist
	{
		_str = _x;
		_i = _newSoldiers findIf {_x == _str};
		_newSoldiers deleteAt _i;
	} forEach _currentSoldiers;

	// Spawn the rest
	private _pos = getPosWorld leader _group;
	_pos set [2,0];
	//resupply only nearby units
	private _men = _soldiers select { _x distance _pos < DEPLOY_RADIUS};
	private _cars = _vehicles select { _x distance _pos < DEPLOY_RADIUS};

	//remove bodies from vehicles
	{
		private _car = _x;
		{
			if !(alive _x) then {
				//moveOut _x;
				[_car, _x] remoteExec ["deleteVehicleCrew", 0];
				sleep 1;
			};
		} forEach crew _car;
	} forEach _cars;

	// Loadouts
	private _customLoadouts = GVARS(_module,"Loadouts",false);
	private _loadouts = [];
	if (_customLoadouts) then {
		//_loadouts = GVARS(_module,"unitLoadouts",[]);
		_loadouts = GVARS(_group,"#loadouts",[]);
		if (count _loadouts == 0) then {_customLoadouts = false};
	};

	{
		_i = _soldierIndexes#_forEachIndex;
		sleep 1;
		_unit = _group createUnit [_x,_pos,[],10,"NONE"];
		//causes broken unit AI to use this on already active vehicle due to dead body issues
		//private _inVehicle = [_unit,_cars] call ACF_grp_moveInFreeVehicle;
		_unit triggerDynamicSimulation true; //test
		_unit setSkill _skill;
		//[_unit] joinSilent _group; //side fix
		[[_unit], _group] remoteExec ["joinSilent", 0]; //side fix?
		if (_i == 0 and count _cars < 1) then { //restore commander
			_group selectLeader _unit;
		};
		SVARG(_unit,"#i",_i);
		sleep 0.4;

		if (_customLoadouts) then {
			//_unit setUnitLoadout (_loadouts#_i);
			_unit setUnitLoadout [_loadouts#_i,true];
		};
		sleep 0.4;

		if (_airSpawn) then { //isNull _inVehicle &&
			_finalPos = getPosWorld _unit;
			_finalPos set [2,120];
			_windComp = [0,0,-4] vectorDiff (wind vectorMultiply 6);
			_para = createVehicle  ["Steerable_Parachute_F",_finalPos, [], 38, "FLY"];
			_unit moveInDriver _para;
			[_unit,_para,false] spawn ACF_handleParadrop;
			_para setVelocity _windComp;
		};
		sleep 0.4;
	} forEach _newSoldiers;

	{
		sleep 1;
		_x setDamage 0;
		[_x, 1] remoteExec ["setvehicleammo", 0];
		[_x, 1] remoteExec ["setFuel", 0];
	} forEach _cars;

	if (count _cars > 0) then {
		reverse _cars; //get leader of First vehicle
		_group selectLeader (effectiveCommander (_cars#0));
	};

	[_group,_men] call ACF_applyResupply;
	if ( (count _newSoldiers > 0) && (count _cars > 0) ) then {
		// Add or edit waypoint
		deleteWaypoint [_group, 0];
		private _wp = _group addWaypoint [_pos, 0,0];
		_wp setWaypointType "GETIN NEAREST";
	};

	sleep 2;
	SVARG(_group,"noResupply", 0);
	SVARG(_group, "resetStr", true);
};

ACF_canResupply = {
	params ["_group","_battalion"];
	if (GVARS(_group,"noResupply", 0) == 1) exitWith {-7000};

	// Find out if group is near spawnable base
	private _lead = leader _group;
	private _pos = getPosATL _lead;
	private _side = side _group;
	private _basesToSpawn = [_side] call ACF_findSpawnBases;
	private _n = _basesToSpawn findIf { _x distance _pos < DEPLOY_RADIUS };

	if (_n == -1) exitWith {-1000};
	if !(isTouchingGround (vehicle _lead)) exitWith {-4000};

	_n = ({alive _x} count units _group);
	if (_n < 1) exitWith {-1100};

	// Find out resupply cost, and save it to the group
	private _type = GVARS(_group,"typeStr","");
	private _unitData = GVARS(_battalion,"ec_unitList",[]);
	private _i = _unitData findIf {_type == _x#0};
	if (_i == -1) exitWith {-2000};

	private _defaultCost = _unitData#_i#1;
	private _max = count ([_type,"units"] call ACF_getGroupArray);
	private _cost = _defaultCost * (1 - (_n / _max));

	private ["_checkUnit", "_pAmmoCnt", "_hAmmoCnt", "_ammo","_vehCost"];
	//examine units and add to cost
	{
		_checkUnit = _x;
		if ( alive _x && {_x distance _pos < DEPLOY_RADIUS} ) then {
			_pAmmoCnt = [count (primaryWeaponMagazine _checkUnit), 1] select (primaryWeapon _checkUnit == "");
			//_sAmmoCnt = [count (secondaryWeaponMagazine _checkUnit), 1] select (secondaryWeapon _checkUnit == "");
			//_sAmmoCnt = 1;
			_hAmmoCnt = [count (handgunMagazine _checkUnit), 1] select (handgunWeapon _checkUnit == "");
			_ammo = [1, 0] select (_pAmmoCnt == 0 || {_hAmmoCnt == 0});
			_cost = _cost + ( ((_defaultCost * 0.5 * (1 - (_ammo) )) + (_defaultCost * 0.5 * (damage _x))) / _max);
		};
	} forEach units _group;

	private _vehicles = [_group] call ACF_getGroupVehicles;
	{
		_ammo = [_x] call getVehicleAmmoDef;
		_vehCost = GVARS(_x, "VehValue", _defaultCost);
		if (_vehCost > _defaultCost) then {_defaultCost = _vehCost;};
		_cost = _cost + ( (_vehCost * 0.5 * (1 - (_ammo) )) + (_vehCost * 0.5 * (damage _x)) );
		//_cost = _cost + ( ((_defaultCost * 0.5 * (1 - (_ammo) )) + (_defaultCost * 0.5 * (damage _x))) / _max);
	} forEach _vehicles;
	//enabled if any units dead or out of ammo
	if (_cost == 0) exitWith {-3000};

	// Clamp between 25% and 100%
	_cost = round ((_cost min _defaultCost) max (_defaultCost * 0.25));

	if (GVARS(_group,"resupplyCost",-1) != _cost) then {
		SVARG(_group,"resupplyCost",_cost);
	};

	_cost
};

// Is group pure infantry?
ACF_grp_isInfantry = {
	params ["_group"];
	private _result = true;

	// Config search version
	if(_group isEqualType "") then {
		private _groupType = [_group,"type"] call ACF_getGroupNumber;
		_result = _groupType == TYPE_INFANTRY;
	} else {
		{
			private _vehicle = objectParent _x;
			if (!isNull _vehicle &&
				{_x == effectiveCommander _vehicle || _x == driver _vehicle}
			) exitWith {
				_result = false;
			};
		} forEach units _group;
	};

	_result
};


// Is group commanding artillery?
ACF_grp_isArtillery = {
	params ["_group"];
	private _result = false;

	// Config search version
	if(_group isEqualType "") then {
		private _groupType = [_group,"type"] call ACF_getGroupNumber;
		_result = _groupType == TYPE_ARTILLERY;
	} else {
		{
			private _vehicle = objectParent _x;
			if (!isNull _vehicle &&
				{_x == effectiveCommander _vehicle} &&
				{_vehicle isKindOf "Air"} && //!!!
				{!(_vehicle isKindOf "ParachuteBase")}
			) exitWith {
				_result = true;
			};
		} forEach units _group;
	};

	_result
};
// Is group commanding aircraft?
ACF_grp_isAircraft = {
	params ["_group"];
	private _result = false;

	// Config search version
	if(_group isEqualType "") then {
		private _groupType = [_group,"type"] call ACF_getGroupNumber;
		_result = _groupType == TYPE_AIR;
	} else {
		{
			private _vehicle = objectParent _x;
			if (!isNull _vehicle &&
				{_x == effectiveCommander _vehicle} &&
				{_vehicle isKindOf "Air"} &&
				{!(_vehicle isKindOf "ParachuteBase")}
			) exitWith {
				_result = true;
			};
		} forEach units _group;
	};

	_result
};

// Is group commanding transport?
ACF_grp_isTransport= {
	params ["_group"];
	private _result = false;

	// Config search version
	if(_group isEqualType "") then {
		private _groupType = [_group,"transport"] call ACF_getGroupBool;
		_result = _groupType;
	} else {
		{
			private _vehicle = objectParent _x;
			if (!isNull _vehicle &&
				{_x == effectiveCommander _vehicle} &&
				//needs tweak later
				{(_vehicle emptyPositions "cargo") > 0}
			) exitWith {
				_result = true;
			};
		} forEach units _group;
	};

	_result
};

// Is group commanding utility?
ACF_grp_isUtility = {
	params ["_group"];
	private _result = false;

	// Config search version
	if(_group isEqualType "") then {
		private _groupType = [_group,"transport"] call ACF_getGroupBool;
		_result = _groupType;
	} else {
		private _groupType = GVARS(_group,"typeStr",""); //group entry
		_result = [_groupType,"transport"] call ACF_getGroupBool; // unit type
	};

	_result
};

// Custom groups handling
ACF_registerCustomGroup = {
	params ["_module"];
	if (count synchronizedObjects _module == 0) exitWith {};
	private _object = (synchronizedObjects _module)#0;
	private _group = group _object;
	if !(_object isKindOf "Man") then {
		_group = group ((crew _object)#0);
	};

	// Group string - composed from the name - will be the var

	// Soldiers array
	private _soldierArray = [];
	private _vehicleList = [];
	private _vehicleArray = [];

	private ["_vehicle"];
	{
		_soldierArray pushBack (typeOf _x);
		_vehicle = objectParent _x;
		if (!isNull _vehicle) then {
			_vehicleList pushBackUnique _vehicle;
		};
	} forEach units _group;

	{
		_vehicleArray pushBack (typeOf _x);
	} forEach _vehicleList;

	// Resolve according to
	private _icon = GVAR(_module,"Marker");

	// Create typeString from the name
	private _arr = toArray GVAR(_module,"name");
	private _indexes = [];
	{
		if (_x == 32) then {
			_indexes pushBack _forEachIndex;
		};
	} forEach _arr;
	reverse _indexes;
	{_arr deleteAt _x} forEach _indexes;
	private _type = "AC_" + (toString _arr);

	MSVARG(_type,_module);
	SVARG(_module,"icon",_icon);
	SVARG(_module,"typeStr",_type);
	SVARG(_module,"units",_soldierArray);
	SVARG(_module,"vehicles",_vehicleArray);

	// Save loadouts if needed
	if (GVAR(_module,"Loadouts")) then {
		private _loadouts = (units _group) apply {getUnitLoadout _x};
		SVARG(_module,"unitLoadouts",_loadouts);
	};

	// Delete template group
	{
		deleteVehicle (objectParent _x);
		deleteVehicle _x;
	} forEach (units _group);
	//deleteVehicle _module;
};
