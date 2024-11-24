#include "\AC\defines\commonDefines.inc"

ACF_ai_strategyAgent = {
	if(DEBUG_MODE) then {
		systemChat format ["[AI] Strategy Agent Started"];
	};
	
	private _infoTick = time;
	
	while {!AC_ended} do {
		// Prepare data for strategy decisions
		{
			[_x] call ACF_ai_calculateDefensesAndThreat;
			true
		} count AC_bases;
		sleep 1;

		//Run AI planning
		{
			if (IS_AI_ENABLED(_x)) then {
				private _side = GVAR(_x,"side");
				if(DEBUG_MODE) then {
					systemChat format ["[%1] Strategic planning cycle", _side];
				};
				
				[_x] call ACF_ai_assignAttacks;
				sleep 1;
				[_x] call ACF_ai_assignDefenders;
				sleep 1;
				[_x] call ACF_assignIdleGroups;
			};
			true
		} count AC_battalions;
		sleep STRATEGY_TICK;

		// Show AI info every 60 seconds
		if(DEBUG_MODE && (time > _infoTick + 60)) then {
			[] call ACF_ai_showAiInfo;
			_infoTick = time;
		};
	};
};

// Find out current defenses for the base - both their number and list of all units
ACF_ai_calculateDefensesAndThreat = {
	params ["_base"];
	private _side = GVAR(_base,"side");
	private _baseName = GVAR(_base,"callsign");
	
	// if(DEBUG_MODE) then {
	// 	systemChat format ["[%1] Calculating defense/threat for base %2", _side, _baseName];
	// };
	
	if (_side == sideEmpty) exitWith {
		if(DEBUG_MODE) then {
			systemChat format ["Base %1 is empty - zeroing all values", _baseName];
		};
		_base setVariable ["def_currentStr",0]; // Strength of units assigned to defense of the base
		_base setVariable ["thr_currentStr",0];
		_base setVariable ["att_costDet",0]; // How "expensive" is detected to attack into a location at the moment
		_base setVariable ["def_costDet",0]; // How "expensive" is detected to defend a location at the moment
		_base setVariable ["thr_currentDetStr",0];
		_base setVariable ["def_currentDetStr",0]; // How many detected units are assigned to defense of the base
	};
   	private _enemySide = [_side] call ACF_enemySide;
	private _friendlyGroups = (AC_operationGroups select {side _x == _side });
	private _enemyGroups = AC_operationGroups - _friendlyGroups;
	private _defCurrentStr = 0;
	private _defCurrentStrDet = 0;

	//determine defender detection type
	private _color = switch (_side) do {
	    case west: { "Wdetected" };
	    case east: { "Edetected" };
	    case resistance: { "Idetected" };
	    default { "Wdetected"};
	};

	//determine enemy detection type
	private _color2 = switch (_enemySide) do {
	    case west: { "Wdetected" };
	    case east: { "Edetected" };
	    case resistance: { "Idetected" };
	    default { "Edetected"};
	};
	private _defCurrent = [];
	private _thrCurrent = [];

	{
		_defCurrent pushbackUnique _x;
		true
	} count (_friendlyGroups select {leader _x distance _base < DEFENSE_DISTANCE});

	{
		_defCurrentStr = _defCurrentStr + ([_x] call ACF_ai_groupStrength);
		if (GVARS(_x,_color2,false)) then {
			_defCurrentStrDet = _defCurrentStrDet + ([_x] call ACF_ai_groupStrength);
		};
		true
	} count _defCurrent;

	{
		_defCurrentStr = _defCurrentStr + PLAYER_STRENGTH;
		true
	} count (allPlayers select {private _p = _x; _defCurrent findIf {group _p == _x} > -1});

	private _thrCurrentStr = 0;
	private _thrCurrentStrDet = 0;
	private _baseThreatDistance = THREAT_DISTANCE + GVAR(_base,"out_perimeter");
	_thrCurrent append _enemyGroups select {_base distance leader _x < _baseThreatDistance};

	{
		_thrCurrentStr = _thrCurrentStr + ([_x] call ACF_ai_groupStrength);
		if (GVARS(_x,_color,false)) then {
			_thrCurrentStrDet = _thrCurrentStrDet + ([_x] call ACF_ai_groupStrength);
		};
		true
	} count _thrCurrent;

	{
		_thrCurrentStr = _thrCurrentStr + PLAYER_STRENGTH;
		true
	} count (allPlayers select {private _p = _x; _thrCurrent findIf {group _p == _x} > -1});

	// What exacly is defenseCost?
	private _attackCostDet = _defCurrentStrDet * ATTACK_DEFENSE_RATIO;
	private _defenseCostDet = _thrCurrentStrDet * DEFENSIVE_RATIO - _defCurrentStr;

	_base setVariable ["def_currentStr",_defCurrentStr]; // Strength of units assigned to defense of the base
	_base setVariable ["thr_currentStr",_thrCurrentStr];
	_base setVariable ["att_costDet",_attackCostDet]; // How "expensive" is detected to attack into a location at the moment
	_base setVariable ["def_costDet",_defenseCostDet]; // How "expensive" is detected to defend a location at the moment
	_base setVariable ["thr_currentDetStr",_thrCurrentStrDet];
	_base setVariable ["def_currentDetStr",_defCurrentStrDet]; // How many detected units are assigned to defense of the base
	// TODO ::
	if(DEBUG_MODE) then {
		systemChat format ["[%1] Base %2: Defense/Threat(%2) Spotted(%3/%4) Cost-Atack/Deffense(%3/%4)", 
			_side, 
			_baseName,
			if(_thrCurrentStr > 0) then {(_defCurrentStr/_thrCurrentStr) toFixed 2} else {"∞"},
			count (_defCurrent select {GVARS(_x,_color2,false)}),
			count _defCurrent,
			_attackCostDet,
			_defenseCostDet
		];
	};
};

// Debug hint of all base statuses
ACF_ai_showAiInfo = {
    if(!DEBUG_MODE) exitWith {};
    
    {
        private _battalion = _x;
        private _side = GVAR(_battalion,"side");
        private _attacks = GVARS(_battalion,"attacks",[]);
        private _counters = GVARS(_battalion,"counters",[]);
        private _transports = GVARS(_battalion,"transports",[]);
        
        // Group Statistics
        private _groups = AC_operationGroups select {side _x == _side};
        private _totalStrength = 0;
        private _combatGroups = 0;
        private _supportGroups = 0;
        
        {
            _totalStrength = _totalStrength + ([_x] call ACF_ai_groupStrength);
            if (GVAR(_x,"type") == TYPE_ARTILLERY || GVAR(_x,"type") == TYPE_AIR) then {
                _supportGroups = _supportGroups + 1;
            } else {
                _combatGroups = _combatGroups + 1;
            };
        } forEach _groups;

        // Battalion Overview - Single Line
        systemChat format ["[%1] Battalion: Attacks(%2) Counters(%3) Transport(%4) Combat(%5) Support(%6) Str(%7)", 
            _side,
            _attacks apply {GVAR(_x,"callsign")},
            count _counters,
            count _transports,
            _combatGroups,
            _supportGroups,
            _totalStrength toFixed 1
        ];
        
        // Base Status - Single Line per Base
        private _bases = AC_bases select {GVAR(_x,"side") == _side};
        {
            private _base = _x;
            private _defenders = GVARS(_base,"defenders",[]);
            private _defStr = GVAR(_base,"def_currentStr");
            private _thrStr = GVAR(_base,"thr_currentStr");
            
            systemChat format ["[%1] Base %2: Def(%3/%.1f) Thr(%.1f) Ratio(%4)", 
                _side,
                GVAR(_base,"callsign"),
                count _defenders,
                _defStr,
                _thrStr,
                if(_thrStr > 0) then {(_defStr/_thrStr) toFixed 2} else {"∞"}
            ];
        } forEach _bases;
    } forEach AC_battalions;
};

ACF_ai_groupThreat = {
	params ["_group"];
 	private _groupUnits = units _group;
	private _result = GVARS(_group, "threat", -1);

	if (_result > -1 && GVARS(_group, "resetThr", false) == false) exitWith {_result};

	private _threatUnit = 0;
	private _soft = 0;
	private _ground = 0;
	private _air = 0;
	{

		_threatUnit = getarray(configfile >> "cfgvehicles" >> typeof _x >> "threat");
		_soft = _soft + (_threatUnit#0 * 8);
		_ground = _ground + (_threatUnit#1 * 8);
		_air = _air + (_threatUnit#2 * 8);

		hintSilent str needService _x;
		true
	} count ([_group] call ACF_getGroupVehicles);

	{
		_threatUnit = getarray(configfile >> "cfgvehicles" >> typeof _x >> "threat");
		_soft = _soft + _threatUnit#0;
		_ground = _ground + _threatUnit#1;
		_air = _air + _threatUnit#2;
		true
	} count _groupUnits;

	if (_air >= (_ground * 0.7) && _air >= (_soft * 0.35) ) then {
		_result = 3;
	} else {
		if (_ground >= _air && _ground >= (_soft * 0.4) ) then {
			_result = 1;
		} else {
			_result = 0;
		};
	};

	if(DEBUG_MODE) then {
		systemChat format ["Group %1: Counter type %2", _group, _result];
	};
	SVARG(_group, "threat", _result);

	_result
};

ACF_ai_groupStrength = {
	params ["_group"];
 	private _groupUnits = units _group;

   	private _battalion = [side _group] call ACF_battalion;
	private _result = GVARS(_group, "str", 0);
	if (_result > 0 && GVARS(_group, "resetStr", false) == false) exitWith {_result};
	if (!isNull GVARS(_group,"base",objNull)) then {
		_result = 1;
	};

	// Find out resupply cost, and save it to the group
	private _type = GVARS(_group,"typeStr","");
	private _unitData = GVARS(_battalion,"ec_unitList",[]);
	private _i = _unitData findIf {_type == _x#0};
	if (_i == -1) exitWith {0};

	private _defaultCost = _unitData#_i#1;
	private _max = count ([_type,"units"] call ACF_getGroupArray);
	private _n = ({alive _x} count _groupUnits);
	private _result = _defaultCost * (_n / _max);
	private _groupType = [_type,"type"] call ACF_getGroupNumber;


	if (_groupType == 0) then {_result=_result*2;};

	{

		_result = _result + GVARS(_x, "VehValue", 1);
		true
	} count ([_group] call ACF_getGroupVehicles);

	if(DEBUG_MODE) then {
		systemChat format ["Group %1 strength, %2 of %3 units, %4 maxstr %6, type %5",
			_result, _n, _max, _defaultCost, _type, _groupType
		];
	};

	SVARG(_group, "resetStr", false);
	SVARG(_group, "str", _result);
	_result
};


//UNUSED
ACF_ai_groupsStrength = {
	params ["_groups"];
	private _totalStr = 0;
	{
		private _vehicleStr = 0; // default str of vehicle
		{
			private _i = AC_vehicleStr findIf {typeOf _x};
			if (_i > -1) then {
				_vehicleStr = _vehicleStr + (AC_vehicleStr#_i);
			} else {
				_vehicleStr = _vehicleStr + 5;
			};
		} forEach ([_group] call ACF_getGroupVehicles);
		_totalStr = _totalStr + ({alive _x} count units _group) + _vehicleStr;
	} forEach _groups;

	_totalStr
};

/*
	PART 2: Planning defense and offensives

	This is brain of the defense decisions. Its main task is to assign
	enough defenders to the front line bases:

	Deciding algorithm:

	- How important is to defend the base: Bases should be defended
	according to their distance from FOB, manpower needed for defense, and avaliable troops

	Testcases:
		No problem: Nobody is attacking, all troops should be divided equally
		One base attack:
		Two-way attack:
		Losing side: Too many enemies attacking your front line
		Lost cause: Too many enemies everywhere, troops should make a last stand (and wait for reinforcements)

	Strategic calculations:

	1. Check if any units can be unassigned from defense
	2. Assign units for defense
	3. Check if offensive can be created: Check all enemy border bases

	---
	- counterattack as special defense function?
	- fn - ACF_findBorderBases; (all, friendly, enemy)
*/

ACF_ai_assignDefenders = {
	params ["_battalion"];
	private _side = GVAR(_battalion,"side");
	// Get a list of our frontier bases
	if(DEBUG_MODE) then {
		systemChat format ["[%1] Starting defender assignment", _side];
	};

	private _bases = [_side] call ACF_borderBases;
	_bases = _bases select {GVAR(_x,"side") == _side};
	private _hqGroup = GVARS(_battalion,"hqElement",grpNull);
	private _availableGroups = [];

	private _basesPriority = [];
	{
		_basesPriority pushBack [_x, GVAR(_x,"def_costDet")];
		true
	} count _bases;

	// Concede badly outnumbered bases
	if(DEBUG_MODE) then {
		{
			_x params ["_base", "_score"];
			systemChat format ["[%1] Base %2 defense priority score: %3", 
				_side,
				GVAR(_base,"callsign"),
				_score
			];
		} forEach _basesPriority;
	};

	// Concede badly outnumbered bases
	private _basesConceded = [];
	private _conceded = [];
	{
		_x params ["_base","_threatStr"];
		if ( (_threatStr > GVAR(_base,"def_currentStr") * RATIO_CONCEDE )
			&& {count _bases - count _basesConceded > 1}
		) then {
			if(DEBUG_MODE) then {
				systemChat format ["[%1] Conceding base %2 - overwhelming threat", 
					_side,
					GVAR(_base,"callsign")
				];
			};
			_basesConceded pushBack [_base,_threatStr];
			_conceded pushback _base;
		};
		true
	} count _basesPriority;

	private _defendedBases = AC_bases select {
		GVAR(_x,"side") == _side
		&& {GVARS(_x,"defended",false)}
	};
	_defendedBases append _conceded;

	_basesPriority = _basesPriority - _basesConceded;

	// Free all assigned defenders from bases
	{
		private _base = _x;
		SVARG(_base,"defended", false);
		{
			SVARG(_x,"canGetOrders",true);
			true
		} count (GVARS(_base,"defenders",[]));
		SVARG(_base,"defenders", []);
		true
	} count _defendedBases;

	_availableGroups = AC_operationGroups select {
		side _x == _side
		&& {GVARS(_x,"canGetOrders",true)}
		&& {_x != _hqGroup}
		&& {GVAR(_x,"type") != TYPE_ARTILLERY}
		&& {GVAR(_x,"type") != TYPE_AIR}
		&& {!([_x] call ACF_grp_isUtility)}
	};

	if (count _availableGroups == 0) exitWith {};

	// Sort bases according to their defensive priority
	_basesPriority sort false;

	private ["_defenders", "_pos","_wp"];
	// Assign nearest groups as long there are defenders needed or no more units available
	{
		_x params ["_base","_score"];
		_defenders = [];
		_pos = getPosWorld _base;

		// Sort groups by distance
		_availableGroups = [_availableGroups,[],{_pos distance2D leader _x},"ASCEND"] call BIS_fnc_sortBy;
		{
			if (_score < 0) exitwith {};
			if (_pos distance2D leader _x < DEFENSE_DISTANCE) then {
				// Make sure that only units coming to real defense are actually assigned
				_wp = [_x, _base, B_COMBAT, false,9] call ACF_ai_moveToBase;
				//_wp setWaypointType "GUARD";
				_score = _score - ([_x] call ACF_ai_groupStrength);
				_availableGroups = _availableGroups - [_x];
				_defenders pushBackUnique _x;
			};
			true
		} count _availableGroups;
		if (count _defenders > 0) then {
			SVARG(_base,"defended", true);
			SVARG(_base,"defenders", _defenders);
		};

		if (count _availableGroups == 0) exitWith  { //requistion additional defenders
			private _nDeployedGroups = {side _x == _side && {{alive _x} count units _x > 0} && {_x != _hqGroup}} count AC_operationGroups;
			if (random AC_unitCap >= _nDeployedGroups) then {
				if(DEBUG_MODE) then {
					systemChat format ["[%1] Requesting new defensive units (Current: %2/%3)", 
						_side,
						_nDeployedGroups,
						AC_unitCap
					];
				};
				[_battalion] call ACF_ec_requestUnitAI;
			};
		};
		true
	} count _basesPriority;

	if(DEBUG_MODE) then {
		private _totalNeeded = 0;
		private _totalAvailable = 0;
		{
			_x params ["_base", "_score"];
			_totalNeeded = _totalNeeded + _score;
		} forEach _basesPriority;
		
		_totalAvailable = {GVARS(_x,"canGetOrders",true)} count _availableGroups;
		
		systemChat format ["[%1] Defense: Required(%1) Available(%2) Conceded(%3)", 
			_side,
			_totalNeeded,
			_totalAvailable,
			_basesConceded apply {GVAR(_x#0,"callsign")}
		];
	};
};

ACF_assignIdleGroups = {
	params ["_battalion"];
	private _side = GVAR(_battalion,"side");
	private _hqGroup = GVARS(_battalion,"hqElement",grpNull);
	private _groups = [];
	_groups = AC_operationGroups select {
		side _x == _side
		&& {GVARS(_x,"canGetOrders",true)}
		&& {_x != _hqGroup}
		&& {GVAR(_x,"type") != TYPE_ARTILLERY}
	 	&& {!([_x] call ACF_grp_isUtility)}
	};

	if (count _groups < 1) exitWith {};
	private _movedGroups = [];
	private _frontlineBases = ([_side] call ACF_borderBases) select {GVAR(_x,"side") == _side};
	private _ongoingTransports = GVARS(_battalion,"transports",[]);
	private _totalTransGroups = AC_operationGroups select {
		side _x == _side
		&& {_x != _hqGroup}
		&& { ([_x] call ACF_grp_isTransport) }
	};

	private _transGroups = _totalTransGroups select { GVARS(_x,"canGetOrders",true) };
	private _infGroups = _groups - _transGroups;
	private _ongoingAttacks = GVARS(_battalion,"attacks",[]);
	_ongoingAttacks = _ongoingAttacks select {GVAR(_x,"side") != sideEmpty};
	private _strat = GVARS(_battalion,"stratMultiplier",1); //strategic skill of side AI
	//assign groups to attacks as reinforcements
	if (count _ongoingAttacks > 0) then {
		{
			private _groupPos = getPosWorld leader _x;
			_ongoingAttacks = [_ongoingAttacks,[],{_x distance _groupPos},"ASCEND"] call BIS_fnc_sortBy;
			private _base = _ongoingAttacks#0;
			private _baseDis = leader _x distance2D _base;
			if (_baseDis > DEFENSE_DISTANCE && {count _ongoingTransports < _strat} && { ([_x] call ACF_grp_isInfantry) } ) then {
				private _seats = count units _x;
				if (count _transGroups > 0) then {
					_transGroups = [_transGroups,[],{leader _x distance2D _groupPos},"ASCEND"] call BIS_fnc_sortBy;
					private _seats = count units _x;
					private _cargo = _x;
					{
						if ( vehicle leader _x emptyPositions "Cargo" >= _seats && {!(vehicle leader _x isKindOf "Plane") || {0 != (getNumber (configfile >> "cfgvehicles" >> typeof vehicle leader _x >> "vtol "))} } && {leader _x distance2D _groupPos < _baseDis } ) exitWith {
								SVARG(_x,"canGetOrders",false);
								SVARG(_cargo,"canGetOrders",false);
							[ _base, _side, _cargo, _x] spawn ACF_ai_transportAgent;
							_transGroups = _transGroups - [_x];
							_movedGroups pushback _x;
							_movedGroups pushback _cargo;
						};
					} forEach _transGroups;
				} else {
					private _nDeployedGroups = {side _x == _side && {{alive _x} count units _x > 0} && {_x != _hqGroup}} count AC_operationGroups;
					if (random AC_unitCap >= (_nDeployedGroups + count _totalTransGroups) ) exitWith {
						if(DEBUG_MODE) then {
							systemChat format ["[%1] Requesting transport units (Need: %2 seats)", 
								_side,
								_seats
							];
						};
						private _groupsRequest = [];
						{
							if ( vehicle leader _x emptyPositions "Cargo" >= _seats) then {_groupsRequest pushBackUnique GVARS(_x,"typeStr","");};
						} forEach _totalTransGroups;
						[_battalion, _groupsRequest] call ACF_ec_requestMobilityUnitAI;
					};
				};
			};

			if (!isNil "_base" && {!isNull _base} && {currentWaypoint _x == 1} ) then {
				[_x, _base, B_TRANSPORT, true, 7] call ACF_ai_moveToStaging;
				_movedGroups pushback _x;
			};
		} forEach _infGroups;
	};

	_groups = _groups - _movedGroups;
	_movedGroups = [];

	_ongoingAttacks = GVARS(_battalion,"counters",[]);
	if  (count _ongoingAttacks < _strat) then {
		{
			if (([_x] call ACF_grp_isAircraft )) then {
				//aircraft actively counter
				private _color = switch (_side) do {
				    case west: { "Wdetected" };
				    case east: { "Edetected" };
				    case resistance: { "Idetected" };
				};
				private _threatType = [_x] call ACF_ai_groupThreat;
				private _foes = AC_operationGroups select {side _x != _side && {([_x] call ACF_ai_groupThreat) != 3} && {[GVARS(_x,"typeStr",""),"type"] call ACF_getGroupNumber == _threatType} && {GVARS(_x,_color,false)} };	//get strongest foes
				if (count _foes > 0) exitWith {
						_foes = [_foes,[],{[_x] call ACF_ai_groupStrength},"DESCEND"] call BIS_fnc_sortBy;
						private _tarGroup = _foes#0;
						private _tarPos = getPosWorld leader _tarGroup;
						SVARG( _x,"canGetOrders",false);
						_movedGroups pushback _x;
						[ _tarGroup, _side, _x] spawn ACF_ai_counterAgent;

						if(DEBUG_MODE) then {
							systemChat format ["[%1] Countering %2 at %3", _side, _tarGroup, _tarPos];
						};
				};
			};
		} forEach _groups;
	};

	_groups = _groups - _movedGroups;
	//assign remaining groups to frontline
	if (count _frontlineBases == 0) exitWith {};
	{
		private _groupPos = getPosWorld leader _x;
		_frontlineBases = [_frontlineBases,[],{_x distance _groupPos},"ASCEND"] call BIS_fnc_sortBy;
		private _base = _frontlineBases#0;
		if (!isNil "_base" && {!isNull _base} && {currentWaypoint _x == 1} && {(_base distance _groupPos > BASE_PERIMETER_MAX)} ) then {
			[_x, _base, B_TRANSPORT, true, 7] call ACF_ai_moveToBase;
			if (DEBUG_MODE) then {
				systemChat format ["[%1] Moving %2 to frontline %3", 
					_side, 
					_x, 
					GVAR(_base,"callsign")
				];
			};
		};
	} forEach _groups;

	if(DEBUG_MODE) then {
		// Transport Analysis
		if(count _transGroups > 0 || count _infGroups > 0) then {
			systemChat format ["[%1] Transport: Assets(%2) Infantry(%3) Ongoing(%4)", 
				_side,
				count _transGroups,
				count _infGroups,
				count _ongoingTransports
			];
		};

		// Strategic Decisions
		if (count _ongoingAttacks > 0 || count _groups > 0) then {
			systemChat format ["[%1] Strategy: Ongoing Attacks(%2) Frontline(%3)", 
				_side,
				_ongoingAttacks apply {GVAR(_x,"callsign")},
				_groups apply {GVAR(_x,"callsign")}
			];
		};
	};
};

ACF_ai_battleEnded = {
	params ["_base","_winner"];
	
	if(DEBUG_MODE) then {
		systemChat format ["Battle ended at %1 - Winner: %2", 
			GVAR(_base,"callsign"),
			_winner
		];
	};

	SVARG(_base,"defended",true);
	private _aiSides = (AC_battalions select {GVARS(_x,"#commander","") == ""}) apply {GVAR(_x,"side")};
	
	{
		if (side _x in _aiSides) then {
			if(DEBUG_MODE) then {
				systemChat format ["Sending group %1 back to base", GVAR(_x,"callsign")];
			};
			[_x, [_x] call ACF_rtbPos, B_TRANSPORT, true, 200] call ACF_ai_move;
		};
	} forEach (GVAR(_base,"defenders"));
	
	SVARG(_base,"defenders", []);
	[_base] call ACF_ai_calculateDefensesAndThreat;
};