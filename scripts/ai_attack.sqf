#include "\AC\defines\commonDefines.inc"


systemChat format ["ai_attack v0.1.4"];

ACF_ai_assignAttacks = {
	params ["_battalion"];
	private _side = GVAR(_battalion,"side");
	private _ongoingAttacks = GVARS(_battalion,"attacks",[]);
	private _hqGroup = GVARS(_battalion,"hqElement",grpNull);

	private _strat = GVARS(_battalion,"stratMultiplier",1); //strategic skill of side AI
	private _borderBases = [_side] call ACF_borderBases;
	private _emptyBases = [];
	private _targetBases = [];
	IF (count _ongoingAttacks < _strat) then {
		//Get a list of frontier bases
		_borderBases = _borderBases - _ongoingAttacks;
		if (count _borderBases > 0) then {
			//Get available non-artillery non-air units
			private _groups = AC_operationGroups select {
				side _x == _side
				&& {GVARS(_x,"canGetOrders",true)}
				&& {_x != _hqGroup}
				&& {GVAR(_x,"type") != TYPE_ARTILLERY}
				&& {GVAR(_x,"type") != TYPE_AIR}
				&& {!([_x] call ACF_grp_isUtility)}
			};
			// Attack empty base if possible
			_emptyBases = _borderBases select {GVAR(_x,"side") == sideEmpty};
			if (count _emptyBases > 0 && count _groups > 0) then {
				//get base near troops
				_groups = [_groups,[],{leader _x distance2D _battalion},"ASCEND"] call BIS_fnc_sortBy;
				private _leadGroup = _groups#0;
				_emptyBases = [_emptyBases,[],{_x distance2D leader _leadGroup},"ASCEND"] call BIS_fnc_sortBy;
				private _emptyBase = _emptyBases#0;
				_groups = [_groups,[],{leader _x distance2D _emptyBase},"ASCEND"] call BIS_fnc_sortBy;
				private _closestGroup = _groups#0;
				_ongoingAttacks pushBack _emptyBase;
				if(DEBUG_MODE) then {
					systemChat format ["[%1] Attacking empty base %2 with %3", _side, GVAR(_emptyBase,"callsign"), _closestGroup];
				};
				SVARG(_closestGroup,"canGetOrders",false);
				[_emptyBase,_side, [_closestGroup]] spawn ACF_ai_offensiveAgent;
				_borderBases = _borderBases - [_emptyBase];
				_groups = _groups - [_closestGroup];
			};

			// Attack any base
			_targetBases = _borderBases select {GVAR(_x,"side") != _side};
			if (count _targetBases > 0) then {
				if (count _groups > 0) then {
					_groups = [_groups,[],{leader _x distance2D _battalion},"ASCEND"] call BIS_fnc_sortBy;
					private _leadGroup = _groups#0;
					_targetBases = [_targetBases,[],{(GVAR(_x,"att_costDet") max 10) * ((_x distance2D leader _leadGroup) /1000)},"ASCEND"] call BIS_fnc_sortBy;
					private _targetBase = _targetBases#0;
					_groups = [_groups,[],{leader _x distance2D _targetBase},"ASCEND"] call BIS_fnc_sortBy;

					// Send adequate strength to attack:
					private _strength = 0;
					private _requiredStrength = (GVAR(_targetBase,"att_costDet")*0.65) max 10;
					_requiredStrength = _requiredStrength + GVAR(_targetBase,"nSoldiersOriginal");

					{
						_strength = _strength + ([_x] call ACF_ai_groupStrength);
						// Create attack only if enough soldiers are available
						if (_strength >= _requiredStrength) exitWith {
							_groups resize (_forEachIndex + 1);
							if(DEBUG_MODE) then {
								systemChat format ["[%1] Attack on %2: str %3/%4", _side, GVAR(_targetBase,"callsign"), _strength, _requiredStrength];
							};
							{
								SVARG(_x,"canGetOrders",false);
							} forEach _groups;
						
							[_targetBase,_side,_groups] spawn ACF_ai_offensiveAgent;
							_ongoingAttacks pushBack _targetBase;
							SVARG(_battalion,"attacks", _ongoingAttacks);
						};
					} forEach _groups;

					if (_strength < _requiredStrength) then {
						private _nDeployedGroups = {side _x == _side && {{alive _x} count units _x > 0} && {_x != _hqGroup}} count AC_operationGroups;
						if (random AC_unitCap >= _nDeployedGroups) then {
							if(DEBUG_MODE) then {
								systemChat format ["[%1] Requesting units for %2 attack (Req: %3, Avail: %4)", _side, GVAR(_targetBase,"callsign"), _requiredStrength, _strength];
							};
							[_battalion] call ACF_ec_requestUnitAI;
						};
					};
					if (count _targetBases > 0) then {
						if(DEBUG_MODE) then {
							private _targetStr = GVAR(_targetBase,"att_costDet");
							systemChat format ["[%1] Target %2: Base(%3) Required(%4) Available(%5)", _side, GVAR(_targetBase,"callsign"), _targetStr, _requiredStrength, _strength];
						};
					};
				} else {
					private _nDeployedGroups = {side _x == _side && {{alive _x} count units _x > 0} && {_x != _hqGroup}} count AC_operationGroups;
					if (random AC_unitCap >= _nDeployedGroups) then {
						if(DEBUG_MODE) then {
							systemChat format ["[%1] No groups for attack - requesting units", _side];
						};
						[_battalion] call ACF_ec_requestUnitAI;
					};
				};
			};
			SVARG(_battalion,"attacks", _ongoingAttacks);
		};
	};

	//try a counter
	_ongoingAttacks = GVARS(_battalion,"counters",[]);
	_groups = AC_operationGroups select {
		side _x == _side
		&& {GVARS(_x,"canGetOrders",true)}
		&& {_x != _hqGroup}
		&& {GVAR(_x,"type") != TYPE_ARTILLERY}
		&& {!([_x] call ACF_grp_isUtility)}
	};
	if ( (count _ongoingAttacks < _strat) && {count _groups > 0} ) then {
		//determine defender detection type
		private _color = switch (_side) do {
			case west: { "Wdetected" };
			case east: { "Edetected" };
			case resistance: { "Idetected" };
		};
		private _foes = AC_operationGroups select {side _x != _side && {GVARS(_x,_color,false)} };	//get strongest foes
		if (count _foes == 0) exitWith {if(DEBUG_MODE) then {systemChat format ["No foes founds"]};};
		_foes = [_foes,[],{[_x] call ACF_ai_groupStrength},"DESCEND"] call BIS_fnc_sortBy;
		private _type = GVARS(_foes#0,"typeStr",""); //group entry
		private _foeType = [_type,"type"] call ACF_getGroupNumber; // unit type
		//if(DEBUG_MODE) then {systemChat format ["%1 %2 type,",_foeType,_type]};

		private _groupsAvail = _groups select {([_x] call ACF_ai_groupThreat) == _foeType };

		private _tarGroup = _foes#0;
		private _tarPos = getPosWorld leader _tarGroup;

		if (count _groupsAvail == 0) exitWith {
			//order counter unit
			private _nDeployedGroups = {side _x == _side && {{alive _x} count units _x > 0} && {_x != _hqGroup}} count AC_operationGroups;
			if (random AC_unitCap >= _nDeployedGroups) exitWith {
				if(DEBUG_MODE) then {
					systemChat format ["[%1] Requesting counter units against %2 threat", 
						_side,
						["Infantry", "Armor", "Support", "Air"] select _foeType
					];
				};
				_groups = _groups  select { ([_x] call ACF_ai_groupThreat) == _foeType };
				private _groupsRequest = [];
				{
					_groupsRequest pushBackUnique GVARS(_x,"typeStr",""); //group entry
				} forEach _groups;
				[_battalion, _groupsRequest] call ACF_ec_requestCounterUnitAI;
			};
			if (_foeType == TYPE_AIR) exitwith {};
			private _supports = GVARS(_battalion,"ec_supportsList",[]);
			if (count _supports == 0) exitwith {};
			{
				//artillery support
				private _fire = false;
				private _vehicle = ([_tarGroup] call ACF_getGroupVehicles) param [0, objNull];
				if (_x#5 == SUPPORT_CAS) then {
					if (isNull _vehicle) then {
						_fire = true;
					} else {
						if (_x#7 > 0)  then {
							_fire = true;
						};
					};
				} else {
					private _usage = ((getText (configfile >> "CfgAmmo" >> _x#6 >> "aiAmmoUsageFlags")) splitString " + ");
					if (isNull _vehicle) then {
						if ("64" in _usage) then {
							_fire = true;
						};
					} else {
						if (_vehicle isKindOf "Tank") then {
							if ("512" in _usage) then {
								_fire = true;
							};
						} else {
							if ("128" in _usage) then {
								_fire = true;
							};
						};
					};
				};
				//
				private _chance = _x#2;
				if (random _chance <= 1 && {_fire} && {time >= _x#3}) then {
					if(DEBUG_MODE) then {
						systemChat format ["[%1 Preparation artillery fire on: %2", _side, GVAR(_targetBase,"callsign")];
					};
					[_tarPos,_battalion,_forEachIndex] remoteExec ["ACF_callSupport",2];
				};
			} forEach _supports;
			// Use artillery units
			private _artGroups = AC_operationGroups select {side _x == _side && {GVAR(_x,"type") == TYPE_ARTILLERY} };
			{
				if (random 3 <= 1) then {
					[_x, _tarPos] call AC_ai_fireMission;
					if(DEBUG_MODE) then {
						systemChat format ["[%1] Fire mission called", _side];
					};
				};
				sleep 1;
			} forEach _artGroups;

		};

		_groupsAvail = [_groupsAvail,[],{leader _x distance2D _tarPos},"ASCEND"] call BIS_fnc_sortBy;

		SVARG(_groupsAvail#0,"canGetOrders",false);
		[ _tarGroup, _side, _groupsAvail#0] spawn ACF_ai_counterAgent;
	};

	if(DEBUG_MODE) then {
		systemChat format ["[%1] Strategic Assessment - Borders Bases: %2, Empty Bases: %3", 
			_side, _borderBases apply {GVAR(_x,"callsign")}, _emptyBases apply {GVAR(_x,"callsign")}];
		
		private _infantry = _groups select {GVAR(_x,"type") == TYPE_INFANTRY};
		private _armor = _groups select {GVAR(_x,"type") == TYPE_MOTORIZED};
		private _artillery = _groups select {GVAR(_x,"type") == TYPE_ARTILLERY};
		private _air = _groups select {GVAR(_x,"type") == TYPE_AIR};

		systemChat format ["[%1] Groups Ready - Total: %2 (INF:%3 ARM:%4 ART:%5 AIR:%6)", 
			_side, count _groups, count _infantry, count _armor, count _artillery, count _air];
		systemChat format ["[%1] Status - Attacks: %2, Multiplier: %3", _side, count _ongoingAttacks, _strat];
	};
};

#define AS_STAGING 	1
#define AS_ATTACK 	2

// Info about offensive is stored by the agent
ACF_ai_offensiveAgent = {
	params ["_base","_side","_attackGroups"];

	private _offensiveName = format ["[%1] Offensive %2:", _side, GVAR(_base,"callsign")];
	
	if(DEBUG_MODE) then {
		systemChat format ["%1 Starting offensive with groups: %2", 
			_offensiveName,
			_attackGroups
		];
	};

	// 1. STAGING PHASE
	// Order all units to move to staging area
	private _attackStage = AS_STAGING;
	{
		[_x, _base, B_TRANSPORT, false, 5] call ACF_ai_moveToStaging;
	} forEach _attackGroups;

	private _battalion = [_side] call ACF_battalion;
	//private _offensiveName = "Offensive " + GVAR(_base,"callsign") + ": ";
	//systemChat (_offensiveName + "Offensive started");

	// Wait until initial timeout, or all units are ready to attack
	private _stagingTimeout = time + 300; // 5 minutes are basic timeout
	waitUntil {
		sleep STRATEGY_TICK;
		_attackGroups findIf {leader _x distance2d _base > DEFENSE_DISTANCE} == -1 || {time > _stagingTimeout}
	};
	if !(IS_AI_ENABLED(_battalion)) exitWith {
		{
			SVARG(_x,"canGetOrders",true);
		} forEach _attackGroups;
		SVARG(_battalion,"attacks", (GVAR(_battalion,"attacks") - [_base]));
	};
	if ( _attackGroups findIf {leader _x distance2d _base < DEFENSE_DISTANCE * 2} == -1 ) exitWith {
		{
			SVARG(_x,"canGetOrders",true);
			while {count waypoints _x > 0} do {
				deleteWaypoint ((waypoints _x)#0);
			};
		} forEach _attackGroups;
		SVARG(_battalion,"attacks", (GVAR(_battalion,"attacks") - [_base]));
	};
	_attackGroups = [_base,_battalion,_side,_attackGroups,_attackStage] call ACF_ai_attackReinforcements;

	if(DEBUG_MODE) then { 
		if (time > _stagingTimeout) then {
			systemChat format ["%1 Attacking after timeout", _offensiveName];
		} else {
			systemChat format ["%1 Attacking: all units ready", _offensiveName];	
		};
	};

	// 2. START ATTACK
	//determine defender detection type
	private _color = switch (_side) do {
	    case west: { "Wdetected" };
	    case east: { "Edetected" };
	    case resistance: { "Idetected" };
	};

	//use supports
	private _enemyGroups = AC_operationGroups select {side _x != _side && {GVAR(_x,"type") != TYPE_AIR} && {GVARS(_x,_color,false)} };
	if (count _enemyGroups > 0) then {
		_enemyGroups = [_enemyGroups,[],{leader _x distance2D _base},"ASCEND"] call BIS_fnc_sortBy;
		private _tarGroup = _enemyGroups#0;
		private _tarPos = getPosWorld leader _tarGroup;
		private _supports = GVARS(_battalion,"ec_supportsList",[]);
		if (count _supports == 0) exitwith {};
		{
			//artillery support
			private _fire = false;
			private _vehicle = ([_tarGroup] call ACF_getGroupVehicles) param [0, objNull];
			if (_x#5 == SUPPORT_CAS) then {
				if (isNull _vehicle) then {
					_fire = true;
				} else {
					if (_x#7 > 0)  then {
						_fire = true;
					};
				};
			} else {
				private _usage = ((getText (configfile >> "CfgAmmo" >> _x#6 >> "aiAmmoUsageFlags")) splitString " + ");
				if (isNull _vehicle) then {
					if ("64" in _usage) then {
						_fire = true;
					};
				} else {
					if (_vehicle isKindOf "Tank") then {
						if ("512" in _usage) then {
							_fire = true;
						};
					} else {
						if ("128" in _usage) then {
							_fire = true;
						};
					};
				};
			};
			private _chance = _x#2;
			if (random _chance <= 1 && {_fire} && {time >= _x#3}) then {
				if(DEBUG_MODE) then {
					systemChat format ["%1 Preparation artillery fire on: %2", _offensiveName, GVAR(_targetBase,"callsign")];
				};
				[_tarPos,_battalion,_forEachIndex] remoteExec ["ACF_callSupport",2];
			};
		} forEach _supports;

		// Use artillery units
		private _artGroups = AC_operationGroups select {side _x == _side && {GVAR(_x,"type") == TYPE_ARTILLERY} };
		{
			if (random 3 <= 1) then {
				[_x, _tarPos] call AC_ai_fireMission;
				if(DEBUG_MODE) then {
					systemChat format ["%1 Fire mission called", _offensiveName];
				};
			};
			sleep 1;
		} forEach _artGroups;

	};

	sleep STRATEGY_TICK;
	if !(IS_AI_ENABLED(_battalion)) exitWith {
		{
			SVARG(_x,"canGetOrders",true);
		} forEach _attackGroups;
		SVARG(_battalion,"attacks", (GVAR(_battalion,"attacks") - [_base]));
	};

	// Order all attacking units to engage
	{
		[_x, _base, B_COMBAT, false, 5] call ACF_ai_moveToBase;
	} forEach _attackGroups;
	_attackStage = AS_ATTACK;

	sleep STRATEGY_TICK;
	_attackGroups = [_base,_battalion,_side,_attackGroups,_attackStage] call ACF_ai_attackReinforcements;

	// Check ending conditions
	private _ended = false;
	while {!_ended} do {
		sleep STRATEGY_TICK;
		if !(IS_AI_ENABLED(_battalion)) exitWith {
			//End the attack, cleanup everything
			{
				[_x, [_x] call ACF_rtbPos,B_TRANSPORT,true] call ACF_ai_move;
			} forEach _attackGroups;
			SVARG(_battalion,"attacks",GVAR(_battalion,"attacks") - [_base]);
		};

		//Use strategy system evaluations for performance and consistency
		private _attDefRatio = (GVAR(_base,"thr_currentStr") max 0.01) / (GVAR(_base,"def_currentDetStr") max 0.01);
		SVARG(_base,"adRatio",_attDefRatio);
		if(DEBUG_MODE) then {
			systemChat format ["%1 offensive Attack/Defense Ratio: %2", _offensiveName, _attDefRatio toFixed 2];
		};

		// Victory condition
		if (GVAR(_base,"side") == _side) then {
			_ended = true;
			if(DEBUG_MODE) then {
				systemChat format ["%1 Victory", _offensiveName];
			};
		} else {
			// Retreat condition
			if (_attDefRatio <= AD_RETREAT_THRESHOLD) then {
				_ended = true;
				if(DEBUG_MODE) then {
					systemChat format ["%1 Retreating  - insufficient force", _offensiveName];
				};
			};
		};
		if (!_ended) then {_attackGroups = [_base,_battalion,_side,_attackGroups,_attackStage] call ACF_ai_attackReinforcements;};
		if (count _attackGroups < 1) then {_ended = true;};

		if(DEBUG_MODE) then {
			systemChat format ["[%1] Combat Analysis", GVAR(_base,"callsign")];
			systemChat format ["* Force Ratio (Attack/Defense): %1", _attDefRatio toFixed 2];
			systemChat format ["* Minimum Force Required: %1", AD_RETREAT_THRESHOLD toFixed 2];
			systemChat format ["* Attacking Groups: %1", _attackGroups];
			
			// Log support decisions
			if(count _enemyGroups > 0) then {
				systemChat format ["* Artillery Support: %1 of %2 batteries engaging %3", 
					{random 3 <= 1} count _artGroups,
					count _artGroups,
					_tarGroug
				];
				systemChat format ["* Priority Target: %1 at grid %2", 
					_tarGroup,
					mapGridPosition _tarPos
				];
			}
		};
	};

	// 3. End the attack, cleanup everything
	{
		[_x, [_x] call ACF_rtbPos,B_TRANSPORT,true] call ACF_ai_move;
	} forEach _attackGroups;
	SVARG(_battalion,"attacks", (GVAR(_battalion,"attacks") - [_base]));


};


ACF_ai_counterAgent = {
	params ["_enemy","_side","_attackGroup"];
	private _battalion = [_side] call ACF_battalion;
	private _counters = GVARS(_battalion,"counters",[]);
	_counters pushBack _attackGroup;

	// 1. Order all units to counter

	private _stagingPoint = getPosWorld leader _enemy;
	[_attackGroup, _stagingPoint, B_COMBAT, false, 5] call ACF_ai_move;

	// 2. attack until initial timeout
	private _color = switch (_side) do {
	    case west: { "Wdetected" };
	    case east: { "Edetected" };
	    case resistance: { "Idetected" };
	};

	private _stagingTimeout = time + 300; // 5 minutes are basic timeout
   	while { sleep STRATEGY_TICK*2; time < _stagingTimeout && {alive leader _attackGroup} && {alive leader _enemy} && {GVARS(_enemy,_color,false)} } do {
		_stagingPoint = getPosWorld leader _enemy;
		if (count waypoints _attackGroup > 0) then {
			if ( _stagingPoint distance2D (getWPPos [_attackGroup, 0]) > 125) then {
				[_attackGroup, _stagingPoint, B_COMBAT, false, 5] call ACF_ai_move;
			};
		} else {
			[_attackGroup, _stagingPoint, B_COMBAT, false, 5] call ACF_ai_move;
		};
	};

	// 3. End the counter, cleanup everything
	SVARG(_attackGroup,"canGetOrders",true);
	SVARG(_battalion,"counters",GVAR(_battalion,"counters") - [_attackGroup]);
	while {count waypoints _attackGroup > 0} do {
		deleteWaypoint ((waypoints _attackGroup)#0);
	};

	if(DEBUG_MODE) then {
		systemChat format ["Counter %1 pursuing %2", 
			GVAR(_attackGroup,"callsign"),
			GVAR(_enemy,"callsign")
		];
		systemChat format ["- Detection Status: %1", GVARS(_enemy,_color,false)];
		systemChat format ["- Time Remaining: %1s", (_stagingTimeout - time) toFixed 0];
	};
};

ACF_ai_transportAgent = {
	params ["_base","_side","_attackGroup","_transportGroup"];
	private _battalion = [_side] call ACF_battalion;
	private _transports = GVARS(_battalion,"transports",[]);
	_transports pushBack _transportGroup;

	// 1. Order all units to stage
	private _attackerPos = getPosATL leader _attackGroup;
	private _transPos = getPosATL leader _transportGroup;

	private _stagingPoint = leader _attackGroup getRelPos [(_attackerPos distance _transPos)/5, leader _attackGroup getRelDir _transPos];
	private _roads = [];
	private _bases = AC_bases;
	private _spawns = [];

	//need a clear space for this
	_bases = [_bases,[],{_x distance _stagingPoint},"ASCEND"] call BIS_fnc_sortBy;
	if ( _bases#0 distance _stagingPoint < 450) then {
		_spawns = GVARS(_bases#0,"stagePoints",[]) + GVARS(_bases#0,"spawnPoints",[]);
		if (count _spawns > 0) then {
			_spawns = [_spawns,[],{_x distance _attackerPos},"ASCEND"] call BIS_fnc_sortBy;
			_stagingPoint = _spawns#0;
		};
	} else {
		_roads = _stagingPoint nearRoads 150;
		if (count _roads > 0) then
		{
			_roads = [_roads,[],{_x distance _base},"ASCEND"] call BIS_fnc_sortBy;
			private _road = _roads#0;
			_stagingPoint = ASLToAGL getPosASL _road;
		} else {
			_stagingPoint = _attackerPos;
			_bases = [_bases,[],{_x distance _stagingPoint},"ASCEND"] call BIS_fnc_sortBy;
			if ( _bases#0 distance _stagingPoint < 450) then {
				_spawns = GVARS(_bases#0,"stagePoints",[]) + GVARS(_bases#0,"spawnPoints",[]);
				if (count _spawns > 0) then {
					_spawns = [_spawns,[],{_x distance _attackerPos},"ASCEND"] call BIS_fnc_sortBy;
					_stagingPoint = _spawns#0;
				};
			} else {
				_roads = _stagingPoint nearRoads 150;
				if (count _roads > 0) then
				{
					_roads = [_roads,[],{_x distance _base},"ASCEND"] call BIS_fnc_sortBy;
					private _road = _roads#0;
					_stagingPoint = ASLToAGL getPosASL _road;
				};
			};
		};
	};

	[_attackGroup, _stagingPoint, B_TRANSPORT, false, 5] call ACF_ai_move;
	[_transportGroup, _stagingPoint, B_TRANSPORT, false, 5] call ACF_ai_move;

	// 2. move until initial timeout
	private _stagingTimeout = time + 600; // 10 minutes are basic timeout
   	while {sleep STRATEGY_TICK*2; time < _stagingTimeout && {alive leader _attackGroup} && {alive leader _transportGroup} && { leader _attackGroup distance2d leader _transportGroup > 100} } do {
		if (currentWaypoint _attackGroup == 1) then {[_attackGroup, _stagingPoint, B_TRANSPORT, false, 5] call ACF_ai_move;};
		if (currentWaypoint _transportGroup == 1) then {[_transportGroup, _stagingPoint, B_TRANSPORT, false, 5] call ACF_ai_move;};
	};

	if ( (time > _stagingTimeout) || {(!alive leader _attackGroup)} || {(!alive leader _transportGroup)} || {(vehicle leader _transportGroup emptyPositions "Cargo" < count units _attackGroup )} || {!(IS_AI_ENABLED(_battalion))} ) exitWith {
		SVARG(_attackGroup,"canGetOrders",true);
		SVARG(_transportGroup,"canGetOrders",true);
		SVARG(_battalion,"transports",GVAR(_battalion,"transports") - [_transportGroup]);
		while {count waypoints _transportGroup > 0} do {
			deleteWaypoint ((waypoints _transportGroup)#0);
		};
		while {count waypoints _attackGroup > 0} do {
			deleteWaypoint ((waypoints _attackGroup)#0);
		};
	};

	//load up
	[_attackGroup, _transportGroup] call ACF_wp_getIn;
	while {sleep STRATEGY_TICK*2; !([_attackGroup] call ACF_isTransported) && {alive leader _attackGroup} && {alive leader _transportGroup} } do {
		[_attackGroup, _transportGroup] call ACF_wp_getIn;
	};
	sleep STRATEGY_TICK*2;
	if ( (!alive leader _attackGroup) || {(!alive leader _transportGroup)} || {!(IS_AI_ENABLED(_battalion))} ) exitWith {
	    [_transportGroup] call ACF_wp_unload;
		SVARG(_attackGroup,"canGetOrders",true);
		SVARG(_transportGroup,"canGetOrders",true);
		SVARG(_battalion,"transports",GVAR(_battalion,"transports") - [_transportGroup]);
	};

	//move to target base
	[_transportGroup, _base, B_TRANSPORT, false, 5] call ACF_ai_moveToStaging;
	[_attackGroup, _base, B_TRANSPORT, false, 5] call ACF_ai_moveToStaging;
	while {sleep STRATEGY_TICK*2; alive leader _attackGroup && {alive leader _transportGroup} && { leader _transportGroup distance2d _base > THREAT_DISTANCE} } do {
		if (currentWaypoint _transportGroup == 1) then {[_transportGroup, _base, B_TRANSPORT, false, 5] call ACF_ai_moveToStaging;};
		if (currentWaypoint _attackGroup == 1) then {[_attackGroup, _base, B_TRANSPORT, false, 5] call ACF_ai_moveToStaging;};
	};
	if ( (!alive leader _attackGroup) || {(!alive leader _transportGroup)} || {!(IS_AI_ENABLED(_battalion))} ) exitWith {
	    [_transportGroup] call ACF_wp_unload;
		SVARG(_attackGroup,"canGetOrders",true);
		SVARG(_transportGroup,"canGetOrders",true);
		SVARG(_battalion,"transports",GVAR(_battalion,"transports") - [_transportGroup]);
	};

    [_transportGroup] call ACF_wp_unload;
	while {sleep STRATEGY_TICK; ([_attackGroup] call ACF_isTransported) && {alive leader _attackGroup} && {alive leader _transportGroup} } do {
	    [_transportGroup] call ACF_wp_unload;
	};

	// End the transport, cleanup everything
	SVARG(_attackGroup,"canGetOrders",true);
	SVARG(_transportGroup,"canGetOrders",true);
	SVARG(_battalion,"transports",GVAR(_battalion,"transports") - [_transportGroup]);

	if(DEBUG_MODE) then {
		systemChat format ["[Transport] %1 -> %2 | Distance: %3m | Capacity: %4/%5 | Status: %6", 
			_attackGroup,
			GVAR(_base,"callsign"),
			round(_stagingPoint distance _base),
			vehicle leader _transportGroup emptyPositions "Cargo",
			count units _attackGroup,
			if([_attackGroup] call ACF_isTransported) then {"Loaded"} else {"Moving"}
		];
	};
};


// Perform AI move to staging area
ACF_ai_moveToStaging = {
	params ["_group","_base",["_moveType",B_DEFAULT],"_canGetOrders",["_randomization",0]];
	private _leaderPos = getPosATL leader _group;
	private _distance = (GVAR(_base,"out_perimeter") + OFFENSIVE_STAGING_DISTANCE);
	private _stagingPoint = _base getRelPos [_distance,_base getRelDir _leaderPos];
	private _roads = _stagingPoint nearRoads 60;
	private _spawns = [];
	if (count _roads > 0) then {
		_roads = [_roads,[],{_x distance _leaderPos},"ASCEND"] call BIS_fnc_sortBy;
		private _road = _roads#0;
		_stagingPoint = ASLToAGL getPosASL _road;
	} else {
		_spawns = GVAR(_base,"stagePoints") + GVAR(_base,"spawnPoints");
		if (count _spawns > 0) then {
			_spawns = [_spawns,[],{_x distance _leaderPos},"ASCEND"] call BIS_fnc_sortBy;
			_stagingPoint = _spawns#0;
		} else {
			_stagingPoint = getPosATL _base;
			_stagingPoint = [_stagingPoint, 0, 30, 4, 0, 0.6, 0,[],[_stagingPoint,_stagingPoint]] call BIS_fnc_findSafePos;
		};
	};

	[_group, _stagingPoint, _moveType, _canGetOrders, _randomization] call ACF_ai_move;
};


// Perform AI move to base area
ACF_ai_moveToBase = {
	params ["_group","_base",["_moveType",B_DEFAULT],"_canGetOrders",["_randomization",0]];
	private _leaderPos = getPosATL leader _group;
	private _stagingPoint = getPosATL _base;
	private _spawns = GVARS(_base,"capturePoints",[]);
	if (count _spawns > 0) then {
		_spawns = [_spawns,[],{_x distance _leaderPos},"ASCEND"] call BIS_fnc_sortBy;
		_stagingPoint = _spawns#0;
	} else {
		private _roads = _stagingPoint nearRoads 30;
		if (count _roads > 0) then
		{
			_roads = [_roads,[],{_x distance _leaderPos},"ASCEND"] call BIS_fnc_sortBy;
			private _road = _roads#0;
			_stagingPoint = ASLToAGL getPosASL _road;
		} else {
			_stagingPoint = [_stagingPoint, 0, 30, 4, 0, 0.6, 0,[],[_stagingPoint,_stagingPoint]] call BIS_fnc_findSafePos;
		};
	};

	[_group, _stagingPoint, _moveType, _canGetOrders, _randomization] call ACF_ai_move;
};

ACF_ai_attackReinforcements = {
	params ["_base","_battalion","_side","_currentAttackers","_attackStage"];
	private _idealAttackStr = (GVAR(_base,"att_costDet")) max 10;
	_idealAttackStr = _idealAttackStr + GVAR(_base,"nSoldiersOriginal");
	private _distance = (GVAR(_base,"out_perimeter"));

	// Check for all units you could put into attack
	private _hqGroup = GVARS(_battalion,"hqElement",grpNull);
	private _newAttackers = [];
	private _newStr = 0;
	_currentAttackers = _currentAttackers select { {alive _x} count units _x > 0 };
	private _availableGroups = _currentAttackers + (AC_operationGroups select {
		side _x == _side
		&& {GVARS(_x,"canGetOrders",true)}
		&& {_x != _hqGroup}
		&& {GVAR(_x,"type") != TYPE_ARTILLERY}
		&& {GVAR(_x,"type") != TYPE_AIR}
		&& {!([_x] call ACF_grp_isUtility)}
	});
	_availableGroups = [_availableGroups,[],{leader _x distance2D _base},"ASCEND"] call BIS_fnc_sortBy;
	{
		_newAttackers pushBackUnique _x;
		SVARG(_x,"canGetOrders",false);
		_newStr = _newStr + ([_x] call ACF_ai_groupStrength);
		if (_currentAttackers find _x == -1 || {currentWaypoint _x == 1}) then {
			if (_attackStage == AS_STAGING) then {
				if (_base distance leader _x > DEFENSE_DISTANCE) then {[_x, _base, B_TRANSPORT, false, 5] call ACF_ai_moveToStaging;};
			} else {
				if (_base distance leader _x > _distance) then {[_x, _base, B_COMBAT, false, 3] call ACF_ai_moveToBase;};
			};
		};
		if (_newStr >= _idealAttackStr) exitWith {};
	} forEach _availableGroups;
	{
		SVARG(_x,"canGetOrders",true);
	} forEach (_currentAttackers - _newAttackers);

	if(DEBUG_MODE) then {
		systemChat format ["[%1] Reinforcements: Required(%2) Current(%3) Available(%4) Stage(%5) Groups(%6)", 
			GVAR(_base,"callsign"),
			round _idealAttackStr,
			round _newStr,
			count _availableGroups,
			if(_attackStage == AS_STAGING) then {"Staging"} else {"Assault"},
			_newAttackers
		];
	};
	_newAttackers
};