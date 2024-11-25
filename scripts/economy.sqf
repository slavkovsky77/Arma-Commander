#include "\AC\defines\commonDefines.inc"

#define POINTS_CAP 1000

/*
	Economy functions:
	- Adding resources to battalions
	- AI: Buying new units
*/

// Find out rate of recieving RP:
AC_economyTick = GVARS(AC_gameModule,"IncomeRate",60);

// Set income params should be set up very early, before player gets into game
ACF_ec_setIncomeParams = {
	// Check starting resources
	private _resources = ["StartingResources",-1] call BIS_fnc_getParamValue;
	if (_resources > -1) then {
		{
			SVARG(_x,"points",_resources);
		} forEach AC_battalions;
	};

	// Check economy tick rate
	private _rate = ["IncomeRate",-1] call BIS_fnc_getParamValue;
	if (_rate > -1) then {
		AC_economyTick = _rate;
	};
};

ACF_ec_economyAgent = {
	{
		[_x] spawn ACF_buyStartingComposition;
	} forEach (AC_battalions select {IS_AI_ENABLED(_x)});


	private ["_side", "_basesIncome", "_nDeployedGroups","_added"];

	MSVARG("AC_nextIncomeTime",time + AC_economyTick);
	while {sleep 1; !AC_ended} do {
		if (time > MGVAR("AC_nextIncomeTime",9999999999999999999) ) then {
			{
				MSVARG("AC_nextIncomeTime",time + AC_economyTick);
				// Calculate how many points are added
				_side = GVAR(_x,"side");
				_basesIncome = 0;
				{
					_basesIncome = _basesIncome + GVARS(_x,"BaseValue",1);
				} forEach (AC_bases select {GVAR(_x,"side") == _side && {GVARS(_x,"noincome",0) == 0} });

				// Execute for all clients
				_added = (_basesIncome + GVARS(_x,"basicIncome",5)) * GVARS(_x,"incomeMultiplier",1);
				_points = GVAR(_x,"points") + _added;
				_points = _points min POINTS_CAP;
				SVARG(_x,"points",_points);
				[_x,_added] remoteExecCall ["ACF_ec_addRp",0,false];


				if (IS_AI_ENABLED(_x)) then {
					_x spawn {
						_nDeployedGroups = count ([_this] call ACF_combatGroups);
						if (random AC_unitCap >= _nDeployedGroups) then { [_this] call ACF_ec_requestUnitAI };
						sleep 5;
						[_this] spawn ACF_ec_checkForReinforcements;
					};
				};
			} forEach AC_battalions;
		};

	};
};

// Locally adding requisition points - easier to update UI alongside
ACF_ec_addRp = {
	params ["_battalion", "_added"];
	//private _points = GVAR(_battalion,"points") + _added;
	//_points = _points min POINTS_CAP;
	//if (isServer) then {SVARG(_battalion,"points",_points);};
	AC_nextIncomeTime = MGVAR("AC_nextIncomeTime",9999999999999999999);

	if (hasInterface && {visibleMap} && {GVAR(_battalion,"side") == side group player}) then {
		[] call ACF_ui_updateBattalionInfo;
		[] call ACF_ui_updateBuyList;
		playSound "Beep_Target";
	};
};


ACF_ec_unitTable = {
	params ["_battalion"];
	private _table = GVARS(_battalion,"unitTable",[]);

	//New adjustable reserve count
   	private _side = GVAR(_battalion,"side");
	private _cap = -1;
	switch (_side) do {
		case WEST: {
			_cap = (["Reserves_West",1] call BIS_fnc_getParamValue);
			if (_cap == -1) then {
				_cap = GVARS(_battalion,"reserves",0);
				if (_cap == 0) then {_cap = AC_unitCapRatio;};
			};
		};
		case EAST: {
			_cap = (["Reserves_East",1] call BIS_fnc_getParamValue);
			if (_cap == -1) then {
				_cap = GVARS(_battalion,"reserves",0);
				if (_cap == 0) then {_cap = AC_unitCapRatio;};
			};
		};
		case INDEPENDENT: {
			_cap = (["Reserves_Indep",1] call BIS_fnc_getParamValue);
			if (_cap == -1) then {
				_cap = GVARS(_battalion,"reserves",0);
				if (_cap == 0) then {_cap = AC_unitCapRatio;};
			};
		};
	};


	if (count _table == 0) then {
		{
			private _count = ceil ((getNumber (_x >> "count")) * _cap);
			_table pushBack [configName _x, _count,getNumber (_x >> "cost"),_count,{true}];
		} forEach ("true" configClasses (configfile >> "AC" >> "Battalions" >> GVAR(_battalion,"type") >> "combatElement"));

		// Write unit table entries into the table itself
		private _side = GVAR(_battalion,"side");
		{
			if (_side == [GVAR(_x,"side")] call AC_fnc_numberToSide) then {
				private _count = ceil (GVAR(_x,"count") * _cap);
				private _condition = GVAR(_x,"Condition");
				if (_condition == "") then {_condition = "true"};
				//systemChat _condition;
				_table pushBack [GVAR(_x,"typeStr"), _count, GVAR(_x,"cost"),_count, compileFinal _condition];
			};
		} forEach (entities "AC_ModuleRegisterGroup");

		SVARG(_battalion,"unitTable",_table);
	};
	_table // format [classname,count,cost];
};

ACF_ec_requestUnitAI = {
	params ["_battalion"];
	private _rp = GVAR(_battalion,"points");
	private _unitTable = [_battalion] call ACF_ec_unitTable;
	private _hqGroup = GVARS(_battalion,"hqElement",grpNull);

	private _side = GVAR(_battalion,"side");
	private _nDeployedGroups = {side _x == _side && {{alive _x} count units _x > 0} && {_x != _hqGroup}} count AC_operationGroups;
	if (_nDeployedGroups >= AC_unitCap) exitWith {};

	private _side = GVAR(_battalion,"side");
	private _basesToSpawn = [_side] call ACF_findSpawnBases;
	if ( count _basesToSpawn < 1 ) exitWith {};

	private _selectedUnitIndex = -1;

	// Select random unit as reinforcement
	if (_selectedUnitIndex == -1) then {

		private _availableGroups = _unitTable select {
			_x params [["_unit",""],["_count",0],["_cost",100],["_oCount",0],["_condition","true"]];
			_rp >= _cost && {_count > 0} && (call _condition) && {!([_unit] call ACF_grp_isAircraft)} && {!([_unit] call ACF_grp_isArtillery)} && {!([_unit] call ACF_grp_isUtility)}
		};

		if (count _availableGroups > 0) then {
			private _selected = selectRandom _availableGroups;
			_selectedUnitIndex = _unitTable findIf {_x#0 == _selected#0};
		};
	};

	// Order
	if (_selectedUnitIndex > -1) then {
		private _selectedUnit = _unitTable#_selectedUnitIndex;
		if(DEBUG_MODE) then {
			systemChat format ["[%1] PURCHASE | Unit:%2 | Cost:%3 | Stock:%4 | Groups:%5/%6", 
				_side,
				_selectedUnit#0,
				_selectedUnit#2,
				_selectedUnit#1,
				_nDeployedGroups,
				AC_unitCap
			];
		};
		[_battalion,_selectedUnitIndex] call ACF_ec_orderGroup;
	} else {
		if(DEBUG_MODE) then {
			systemChat format ["[%1] PURCHASE failed: No suitable units", _side];
		};
	};
};

ACF_ec_requestCounterUnitAI = {
	params ["_battalion","_groups"];
	private _rp = GVAR(_battalion,"points");
	private _unitTable = [_battalion] call ACF_ec_unitTable;
	private _hqGroup = GVARS(_battalion,"hqElement",grpNull);

	private _side = GVAR(_battalion,"side");
	private _nDeployedGroups = {side _x == _side && {{alive _x} count units _x > 0} && {_x != _hqGroup}} count AC_operationGroups;
	if (_nDeployedGroups >= AC_unitCap) exitWith {};

	private _side = GVAR(_battalion,"side");
	private _basesToSpawn = [_side] call ACF_findSpawnBases;
	if ( count _basesToSpawn < 1 ) exitWith {};

	private _selectedUnitIndex = -1;

	//known counters
	if (count _groups > 0) then {
		private _availableGroups = _unitTable select {
			_x params [["_unit",""],["_count",0],["_cost",100],["_oCount",0],["_condition","true"]];
			_rp >= _cost && {_count > 0} && (call _condition) && {_groups findIf { _x == _unit } > -1} && {!([_unit] call ACF_grp_isUtility)}
		};

		if (count _availableGroups > 0) then {
			private _selected = selectRandom _availableGroups;
			_selectedUnitIndex = _unitTable findIf {_x#0 == _selected#0};
		};
	};

	// Select random unit as counter
	if (_selectedUnitIndex == -1) then {

		private _availableGroups = _unitTable select {
			_x params [["_unit",""],["_count",0],["_cost",100],["_oCount",0],["_condition","true"]];
			_rp >= _cost && {_count > 0} && (call _condition) && {!([_unit] call ACF_grp_isUtility)}
		};

		if (count _availableGroups > 0) then {
			private _selected = selectRandom _availableGroups;
			_selectedUnitIndex = _unitTable findIf {_x#0 == _selected#0};
		};
	};

	// Order
	if (_selectedUnitIndex > -1) then {
		private _selectedUnit = _unitTable#_selectedUnitIndex;
		if(DEBUG_MODE) then {
			systemChat format ["[%1] COUNTER PURCHASE | Unit:%2 | Cost:%3 | Stock:%4 | Counter groups %5", 
				_side,
				_selectedUnit#0,
				_selectedUnit#2,
				_selectedUnit#1,
				_groups
			];
		};
		[_battalion,_selectedUnitIndex] call ACF_ec_orderGroup;
	} else {
		if(DEBUG_MODE) then {
			systemChat format ["[%1]  COUNTER PURCHASE failed: No suitable units", _side];
		};
	};
};

ACF_ec_requestMobilityUnitAI = {
	params ["_battalion","_groups"];
	private _rp = GVAR(_battalion,"points");
	private _unitTable = [_battalion] call ACF_ec_unitTable;
	private _hqGroup = GVARS(_battalion,"hqElement",grpNull);

	private _side = GVAR(_battalion,"side");
	private _nDeployedGroups = {side _x == _side && {{alive _x} count units _x > 0} && {_x != _hqGroup}} count AC_operationGroups;
	if (_nDeployedGroups >= AC_unitCap) exitWith {};

	private _side = GVAR(_battalion,"side");
	private _basesToSpawn = [_side] call ACF_findSpawnBases;
	if ( count _basesToSpawn < 1 ) exitWith {};

	private _selectedUnitIndex = -1;

	//known vehicles
	if (count _groups > 0) then {
		private _availableGroups = _unitTable select {
			_x params [["_unit",""],["_count",0],["_cost",100],["_oCount",0],["_condition","true"]];
			_rp >= _cost && {_count > 0} && (call _condition) && {_groups findIf { _x == _unit } > -1}
		};

		if (count _availableGroups > 0) then {
			private _selected = selectRandom _availableGroups;
			_selectedUnitIndex = _unitTable findIf {_x#0 == _selected#0};
		};
	};

	// Select random unit as counter
	if (_selectedUnitIndex == -1) then {

		private _availableGroups = _unitTable select {
			_x params [["_unit",""],["_count",0],["_cost",100],["_oCount",0],["_condition","true"]];
			_rp >= _cost && {_count > 0} && (call _condition) && {!([_unit] call ACF_grp_isInfantry)} && {!([_unit] call ACF_grp_isArtillery)}
		};

		if (count _availableGroups > 0) then {
			private _selected = selectRandom _availableGroups;
			_selectedUnitIndex = _unitTable findIf {_x#0 == _selected#0};
		};
	};

	// Order
	if (_selectedUnitIndex > -1) then {
		[_battalion,_selectedUnitIndex] call ACF_ec_orderGroup;
		// DEBUG
		//systemChat str [_selectedUnitIndex,_unitTable#_selectedUnitIndex];
		if(DEBUG_MODE) then {
			private _selectedUnit = _unitTable#_selectedUnitIndex; 
			systemChat format ["[%1] TRANSPORT | Unit:%2 | Cost:%3 | Stock:%4 | For:%5 groups", 
				_side,
				_selectedUnit#0,  // transport type
				_selectedUnit#2,  // cost
				_selectedUnit#1,  // remaining in stock
				count _groups    // number of groups needing transport
			];
		};
	};
};

ACF_ec_checkForReinforcements = {
	params ["_battalion"];
	// Reinforce units with some randomization
	private _side = GVAR(_battalion,"side");
    private _startingPoints = GVAR(_battalion,"points");

    // Track what gets reinforced
    private _reinforcedBases = [];
    private _resuppliedGroups = [];
    private _totalCost = 0;
    private _soldiersAdded = 0;

	//reinforce bases with randomization
	private _module = GVARS(_battalion,"module",objNull);
	private _modifier = 1;
	{
		if !(GVARS(_X,"deployed", DEPLOYED_FALSE) == DEPLOYED_FALSE) exitWith {};
		private _base = _x;
		private _currentSoldiers = GVAR(_x,"nSoldiers");
		private _newSoldiers = GVAR(_x,"nSoldiersOriginal");
		private _resupplyCost = _newSoldiers - _currentSoldiers;
		private _points = GVAR(_battalion,"points");

		if (isNull _module) then {
			private _conf = configfile >> "AC" >> "Battalions" >> _battalion getVariable "type" >> "Reserves";
			_modifier = getNumber (_conf >> "modifier");
			_resupplyCost = ceil (_resupplyCost * _modifier);
		} else {
			_modifier = GVARS(_module,"modifier",1);
			_resupplyCost = ceil (_resupplyCost * _modifier);
		};

		if (_resupplyCost == 0 || {_points < _resupplyCost} || {random 2 > 1}) exitWith {};
		
		_reinforcedBases pushBack _base;
		_totalCost = _totalCost + _resupplyCost;
        _soldiersAdded = _soldiersAdded + (_newSoldiers - _currentSoldiers);

		
		SVARG(_x,"nSoldiers", _newSoldiers);
		SVARG(_battalion,"points", _points - _resupplyCost);
	} forEach (AC_bases select {GVAR(_x,"side") == _side});

	{
		private _cost = [_x, _battalion] call ACF_canResupply;
		if (_cost >= 0 && random 2 <= 1) then {
			_resuppliedGroups pushBack _x;
            _totalCost = _totalCost + _cost;
			[_x, _battalion, _cost] call ACF_resupplyGroup;
			sleep 1;
		};
	} forEach ([_battalion] call ACF_combatGroups);

    // Single debug message showing what actually happened
    if(DEBUG_MODE) then {
        systemChat format ["[%1] REINFORCE CHECK | Points:%2->%3 | Cost:%4 | Soldiers:+%5 | Bases:%6 | Groups:%7", 
            _side,
            _startingPoints,
            GVAR(_battalion,"points"),
            _totalCost,
            _soldiersAdded,
            _reinforcedBases,
            _resuppliedGroups
        ];
    };
};

ACF_ec_orderGroup = {
	params ["_battalion","_tableIndex",["_pos",[]]];
	private _table = [_battalion] call ACF_ec_unitTable;
	private _points = GVAR(_battalion,"points");

	//compare at order time to prevent errors
	private _rGroups = GVAR(_battalion,"requestQueue");
	private _hqGroup = GVARS(_battalion,"hqElement",grpNull);
	private _side = GVAR(_battalion,"side");
	private _aliveGroups = {side _x == _side && {{alive _x} count units _x > 0} && {_x != _hqGroup}} count AC_operationGroups;
	private _remainingSlots = AC_unitCap - (_aliveGroups + _rGroups);

	(_table#_tableIndex) params ["_unit","_count","_cost","_oCount","_condition"];
	if (_points < _cost || {_remainingSlots < 1} || _count <= 0 || ! (call _condition)) exitWith {};

	if (count _pos == 0) then {
		if !([_unit] call ACF_grp_isArtillery) then {
			_pos = [_battalion] call ACF_ec_findBestSpawnPos;
		} else {
			_pos = [_battalion] call ACF_ec_findBestSpawnPosArt;
		};
	};

	// Remove 1 count of unit from the list
	(_table#_tableIndex) set [1, _count - 1];
	SVARG(_battalion,"unitTable",+_table);
	SVARG(_battalion,"points", _points - _cost);
	SVARG(_battalion,"requestQueue", GVAR(_battalion,"requestQueue") + 1);
	[_battalion, _unit,_pos] call ACF_ec_buyGroup;
};

ACF_ec_findBestSpawnPos = {
	params ["_battalion"];
	private _side = GVAR(_battalion,"side");
	private _attackedBase = objNull;
	private _spawnBase = objNull;
	private _pos = [];
	private _roads = [];
	private _road = objNull;
	private _spawns = [];

	private _basesToSpawn = [_side] call ACF_findSpawnBases;

	private _attacks = GVARS(_battalion,"attacks",[]);
	private _enemyAttacks = _attacks;
	_enemyAttacks = _enemyAttacks select {GVAR(_x,"side") != sideEmpty};
	//if we are attacking the enemy, deploy nearest there
	if (count _enemyAttacks > 0) then {
		_enemyAttacks = [_enemyAttacks,[],{GVARS(_x,"adRatio",100)},"ASCEND"] call BIS_fnc_sortBy;
		_attackedBase = _enemyAttacks#0;
		if (!isNull _attackedBase) then {
			_basesToSpawn = [_basesToSpawn,[],{_x distance _attackedBase},"ASCEND"] call BIS_fnc_sortBy;
			if (count _basesToSpawn > 0) then {
				_spawnBase = _basesToSpawn#0;
				_spawns = GVARS(_spawnBase,"spawnPoints",[]);
				if (!isNil "_spawns" && {count _spawns > 0}) then {
					_spawns = [_spawns,[],{_x distance _attackedBase},"ASCEND"] call BIS_fnc_sortBy;
					_pos = _spawns#0;
				} else {
					_roads = _spawnBase nearRoads 250;
					if (count _roads > 0) then {
						_roads = [_roads,[],{_x distance _attackedBase},"ASCEND"] call BIS_fnc_sortBy;
						_road = _roads#0;
						_pos = ASLToAGL getPosASL _road;
					} else {
						_pos = getPosATL _spawnBase;
					};
				};
			};
		};
	};

	// If there is no attack, select near the frontier
	if (count _pos == 0 && {count _basesToSpawn > 0}) then {
		private _borderBases = [_side] call ACF_borderBases;
		_borderBases = _borderBases - _attacks;
		_borderBases = _borderBases select {GVAR(_x,"side") != _side};
		private _targetBase = selectRandom _borderBases;
		if (count _borderBases > 0 && {!isNull _targetBase}) then {
			_basesToSpawn = [_basesToSpawn,[],{_x distance _targetBase},"ASCEND"] call BIS_fnc_sortBy;
			_spawnBase = _basesToSpawn#0;
			_spawns = GVARS(_spawnBase,"spawnPoints",[]);
			if (!isNil "_spawns" && {count _spawns > 0}) then {
				_spawns = [_spawns,[],{_x distance _targetBase},"ASCEND"] call BIS_fnc_sortBy;
				_pos = _spawns#0;
			} else {
				_roads = _spawnBase nearRoads 250;
				if (count _roads > 0) then {
					_roads = [_roads,[],{_x distance _targetBase},"ASCEND"] call BIS_fnc_sortBy;
					_road = _roads#0;
					_pos = ASLToAGL getPosASL _road;
				} else {
					_pos = getPosATL _spawnBase;
					_pos = [_pos, 0, 25, 6, 0, 0.6, 0,[],[_pos,_pos]] call BIS_fnc_findSafePos;
				};
			};
		};
	};

	// If there is no attack or frontier, just select random deployable base
	if (count _pos == 0 && {count _basesToSpawn > 0}) then {
		_spawnBase = selectRandom _basesToSpawn;
		_pos = getPosWorld _spawnBase;
	};
	_pos
};

ACF_ec_findBestSpawnPosArt = {
	params ["_battalion"];
	private _side = GVAR(_battalion,"side");
	private _spawnBase = objNull;
	private _pos = [];
	private _roads = [];
	private _road = objNull;

	private _basesToSpawn = [_side] call ACF_findSpawnBases;

	//artillery goes in the back
	_basesToSpawn = [_basesToSpawn,[],{_x distance _battalion},"ASCEND"] call BIS_fnc_sortBy;
	if (count _basesToSpawn > 0) then {
		_spawnBase = _basesToSpawn#0;
		private _spawns = GVARS(_spawnBase,"spawnPoints",[]);
		if (count _spawns > 0) then {
			_spawns = [_spawns,[],{_x distance _battalion},"ASCEND"] call BIS_fnc_sortBy;
			_pos = _spawns#0;
		} else {
			_roads = _spawnBase nearRoads 250;
			if (count _roads > 0) then {
				_roads = [_roads,[],{_x distance _battalion},"ASCEND"] call BIS_fnc_sortBy;
				_road = _roads#0;
				_pos = ASLToAGL getPosASL _road;
			} else {
				_pos = getPosATL _spawnBase;
				_pos = [_pos, 0, 25, 6, 0, 0.6, 0,[],[_pos,_pos]] call BIS_fnc_findSafePos;
			};
		};
	};

	_pos
};

// This is most basic version, will neeed many improvements like
//	- Weighted random or ensuring balanced units are bought
// 	- Selecting optimal deployment position(s)
ACF_buyStartingComposition = {
	params ["_battalion"];
	// Buy combat units when you have time
	for "_i" from 0 to 3 do {
		if !(IS_AI_ENABLED(_battalion)) exitWith {};
		[_battalion] spawn ACF_ec_requestUnitAI;
		sleep 8;
	};
};

ACF_ec_buyGroup = {
	params ["_battalion", "_groupToBuy","_pos"];
	if !(isOnRoad _pos) then {
		_pos = [_pos, 0, 30, 10, 0, 0.5, 0,[],[_pos,_pos]] call BIS_fnc_findSafePos;
	};
	[_groupToBuy, _battalion getVariable "side", _pos] call ACF_grp_createGroup;
};