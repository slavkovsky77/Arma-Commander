#include "\AC\defines\commonDefines.inc"


// New function to extract target base selection logic
ACF_ai_selectTargetBase = {
    params ["_borderBases", "_side", "_groups"];
    private _targetBases = _borderBases select {GVAR(_x,"side") != _side};
    if (count _targetBases == 0) exitWith { [] };
    
    // Define max values for normalization
    private _maxDistance = 2000;
    private _maxStrength = 100;  // for getPositionStrength
    private _maxHeight = 300;    
    private _maxCover = 50;    
    
    _targetBases = [_targetBases,[],{
        private _base = _x;
        private _basePos = getPosATL _base;
        private _enemySide = GVAR(_base,"side");
        
        // Basic metrics
        private _distance = leader (_groups#0) distance2D _base;
        private _enemyStrength = [_basePos, _enemySide, 100] call ACF_ai_getPositionStrength;
        
        // Terrain analysis
        private _height = getTerrainHeightASL _basePos;
        private _coverObjects = count (nearestTerrainObjects [_basePos, ["TREE", "HOUSE", "WALL", "BUSH"], 100]);
        
        // Normalize all values (0-1 range)
        private _normalizedDistance = (_distance / _maxDistance) min 1;
        private _normalizedStrength = (_enemyStrength / _maxStrength) min 1;
        private _normalizedHeight = (_height / _maxHeight) min 1;
        private _normalizedCover = (_coverObjects / _maxCover) min 1;
        
        // Weighted scoring system
        private _weights = [
            ["distance", 0.4],     // Lower is better
            ["strength", 0.5],     // Lower is better
            ["height", 0.15],      // Higher is better
            ["cover", 0.15]        // Higher is better
        ];
        
        // Calculate final score (lower is better)
        (_normalizedDistance * (_weights#0#1)) +
        (_normalizedStrength * (_weights#1#1)) -
        (_normalizedHeight * (_weights#2#1)) -
        (_normalizedCover * (_weights#3#1))
        
    },"ASCEND"] call BIS_fnc_sortBy;
    
    _targetBases
};

// Attack cleanup utility - just handles attack list
ACF_ai_cleanupAttack = {
    params ["_battalion", "_base"];
    SVARG(_battalion,"attacks", (GVAR(_battalion,"attacks") - [_base]));
};

// Helper to request reinforcements
ACF_ai_requestReinforcements = {
    params ["_battalion", "_side", "_hqGroup", "_targetBase", "_strength", "_requiredStrength"];
    
    private _nDeployedGroups = {
        side _x == _side && 
        {{alive _x} count units _x > 0} && 
        {_x != _hqGroup}
    } count AC_operationGroups;
    
    if (random AC_unitCap >= _nDeployedGroups) then {
        if(DEBUG_MODE) then {
            systemChat format ["[%1] Requesting units for %2 attack (Req: %3, Avail: %4)", 
                _side, 
                GVAR(_targetBase,"callsign"), 
                _requiredStrength, 
                _strength
            ];
        };
        [_battalion] call ACF_ec_requestUnitAI;
    };
};


// Helper to handle counter attacks
ACF_ai_handleCounterAttacks = {
    params ["_battalion", "_side", "_hqGroup"];
    
    private _groups = [_side, _hqGroup] call ACF_ai_getAvailableAttackGroups;
    if (count _groups == 0) exitWith {};
    
    //determine defender detection type
    private _color = [_side] call ACF_ai_getDetectionColor;
    private _foes = AC_operationGroups select {side _x != _side && {GVARS(_x,_color,false)} };  //get strongest foes
    if (count _foes == 0) exitWith {
		if(DEBUG_MODE) then {systemChat format ["No foes founds"]};
	};
    
    _foes = [_foes,[],{[_x] call ACF_ai_groupStrength},"DESCEND"] call BIS_fnc_sortBy;
    private _type = GVARS(_foes#0,"typeStr",""); //group entry
    private _foeType = [_type,"type"] call ACF_getGroupNumber; // unit type
    if(DEBUG_MODE) then {
        systemChat format ["Strongest enemy detected: %1 (%2)", _type, _foeType];
    };

    private _groupsAvail = _groups select {([_x] call ACF_ai_groupThreat) == _foeType };
    private _tarGroup = _foes#0;
    private _tarPos = getPosWorld leader _tarGroup;

    if (count _groupsAvail == 0) exitWith {
        //order counter unit
        private _nDeployedGroups = {side _x == _side && {{alive _x} count units _x > 0} && {_x != _hqGroup}} count AC_operationGroups;
        if (random AC_unitCap >= _nDeployedGroups) then {
            if(DEBUG_MODE) then {
                systemChat format ["[%1] Requesting counter units against %2 threat", 
                    _side,
                    ["Infantry", "Armor", "Support", "Air"] select _foeType
                ];
            };
            _groups = _groups select { ([_x] call ACF_ai_groupThreat) == _foeType };
            private _groupsRequest = [];
            {
                _groupsRequest pushBackUnique GVARS(_x,"typeStr",""); //group entry
            } forEach _groups;
            [_battalion, _groupsRequest] call ACF_ec_requestCounterUnitAI;
        };
        if (_foeType == TYPE_AIR) exitwith {};
        [_tarGroup, _tarPos, _side, _battalion] call ACF_ai_useSupports;
    };

    _groupsAvail = [_groupsAvail, _tarPos] call ACF_ai_sortByDistance;
    private _counterGroup = _groupsAvail#0;
    
    SVARG(_counterGroup,"canGetOrders",false);
    [_tarGroup, _side, _counterGroup] spawn ACF_ai_counterAgent;
};


// Main attack assignment function
ACF_ai_assignAttacks = {
	params ["_battalion"];
	private _side = GVAR(_battalion,"side");
	private _ongoingAttacks = GVARS(_battalion,"attacks",[]);
	private _hqGroup = GVARS(_battalion,"hqElement",grpNull);

	private _maxAttacks = GVARS(_battalion,"MaxAttacks",2); // Get max attacks from module, default 2
	private _borderBases = [_side] call ACF_borderBases;
	private _targetBases = [];
    _borderBases = _borderBases - _ongoingAttacks;

	if (count _ongoingAttacks >= _maxAttacks) exitWith {};
    if (count _borderBases == 0) exitWith {
        ["ATTACK", "No available bases to attack", _side] call ACF_ai_log;
    };

    // Select target base using improved scoring system
    private _groups = [_side, _hqGroup] call ACF_ai_getAvailableAttackGroups;
    if (count _groups == 0) exitWith {
        ["ATTACK", "No available groups for attack", _side] call ACF_ai_log;
    };

    private _scoredBases = [_borderBases, _side, _groups] call ACF_ai_selectTargetBase;
    if (count _scoredBases == 0) exitWith {
        ["ATTACK", "No suitable bases found after scoring", _side] call ACF_ai_log;
    };
    private _targetBase = _scoredBases#0;

    // Calculate required force based on enemy strength
    private _enemySide = GVAR(_targetBase,"side");
    private _requiredStrength = [getPosATL _targetBase, _enemySide, 100] call ACF_ai_getPositionStrength;
    _requiredStrength = _requiredStrength max 10; // Minimum force even for empty bases
    
    // Select groups for attack
    private _attackStrength = 0;
    private _attackGroups = [];
    
    ["ATTACK", format [
        "Target: %1 | Required Strength: %2 | Enemy Side: %3",
        GVAR(_targetBase,"callsign"),
        _requiredStrength toFixed 2,
        _enemySide
    ], _side] call ACF_ai_log;

    {
        private _groupStrength = [_x] call ACF_ai_groupStrength_2;
        _attackStrength = _attackStrength + _groupStrength;
        _attackGroups pushBack _x;
        
        ["ATTACK", format [
            "Adding attack group %1 (Str: %2) Total: %3/%4",
            GVAR(_x,"callsign"),
            _groupStrength toFixed 2,
            _attackStrength toFixed 2,
            _requiredStrength toFixed 2
        ], _side] call ACF_ai_log;

        // Break if we have enough strength
        if (_attackStrength >= _requiredStrength) exitWith {};
    } forEach _groups;
    
    // Launch attack if we have sufficient force
    if (_attackStrength >= _requiredStrength) then {
        {
            SVARG(_x,"canGetOrders",false);
        } forEach _attackGroups;
        
        ["ATTACK", format [
            "Launching attack on %1 with %2 groups (Str: %3/%4)",
            GVAR(_targetBase,"callsign"),
            count _attackGroups,
            _attackStrength toFixed 2,
            _requiredStrength toFixed 2
        ], _side] call ACF_ai_log;

        [_targetBase, _side, _attackGroups] spawn ACF_ai_offensiveAgent;
        SVARG(_battalion,"attacks",GVAR(_battalion,"attacks") + [_targetBase]);
    } else {
        // Request reinforcements if needed
        ["ATTACK", format [
            "Insufficient force for %1 (%2/%3) - Requesting reinforcements",
            GVAR(_targetBase,"callsign"),
            _attackStrength toFixed 1,
            _requiredStrength toFixed 1
        ], _side] call ACF_ai_log;

        if (random AC_unitCap >= {side _x == _side} count AC_operationGroups) then {
            [_battalion] call ACF_ec_requestUnitAI;
        };
    };
};

#define AS_STAGING 	1
#define AS_ATTACK 	2

// Helper to handle offensive staging phase
ACF_ai_handleOffensiveStaging = {
    params ["_base", "_side", "_attackGroups", "_battalion", "_offensiveName"];
    
    // Order all units to move to staging area
    {
        [_x, _base, B_TRANSPORT, false, 5] call ACF_ai_moveToStaging;
    } forEach _attackGroups;

    // Wait until initial timeout, or all units are ready to attack
    private _stagingTimeout = time + 300; // 5 minutes are basic timeout
    waitUntil {
        sleep STRATEGY_TICK;
        _attackGroups findIf {leader _x distance2d _base > DEFENSE_DISTANCE} == -1 || {time > _stagingTimeout}
    };

    // Check for early exit conditions
    if !(IS_AI_ENABLED(_battalion)) exitWith {
        {
            SVARG(_x,"canGetOrders",true);
        } forEach _attackGroups;
        [_battalion, _base] call ACF_ai_cleanupAttack;
        [false, []]
    };

    if (_attackGroups findIf {leader _x distance2d _base < DEFENSE_DISTANCE * 2} == -1) exitWith {
        {
            SVARG(_x,"canGetOrders",true);
            while {count waypoints _x > 0} do {
                deleteWaypoint ((waypoints _x)#0);
            };
        } forEach _attackGroups;
        [_battalion, _base] call ACF_ai_cleanupAttack;
        [false, []]
    };

    // Get reinforcements for staging phase
    _attackGroups = [_base, _battalion, _side, _attackGroups, AS_STAGING] call ACF_ai_attackReinforcements;

    if(DEBUG_MODE) then { 
        if (time > _stagingTimeout) then {
            systemChat format ["%1 Attacking after timeout", _offensiveName];
        } else {
            systemChat format ["%1 Attacking: all units ready", _offensiveName];    
        };
    };

    [true, _attackGroups]
};

// Helper to handle attack initialization
ACF_ai_handleAttackInit = {
    params ["_base", "_side", "_attackGroups", "_battalion", "_offensiveName"];
    
    //determine defender detection type
    private _color = [_side] call ACF_ai_getDetectionColor;

    //use supports
    private _enemyGroups = AC_operationGroups select {side _x != _side && {GVAR(_x,"type") != TYPE_AIR} && {GVARS(_x,_color,false)} };
    if (count _enemyGroups > 0) then {
        _enemyGroups = [_enemyGroups, _base] call ACF_ai_sortByDistance;
        private _tarGroup = _enemyGroups#0;
        private _tarPos = getPosWorld leader _tarGroup;
        [_tarGroup, _tarPos, _side, _battalion, _offensiveName] call ACF_ai_useSupports;
    };

    sleep STRATEGY_TICK;
    if !(IS_AI_ENABLED(_battalion)) exitWith {
        {
            SVARG(_x,"canGetOrders",true);
        } forEach _attackGroups;
        [_battalion, _base] call ACF_ai_cleanupAttack;
        false
    };

    // Order all attacking units to engage
    {
        [_x, _base, B_COMBAT, false, 5] call ACF_ai_moveToBase;
    } forEach _attackGroups;

    true
};

// Info about offensive is stored by the agent
ACF_ai_offensiveAgent = {
    params ["_base","_side","_attackGroups"];

    private _offensiveName = format ["[%1] Offensive %2:", _side, GVAR(_base,"callsign")];
    
    if(DEBUG_MODE) then {
        systemChat format ["%1 Starting agent with groups: %2", _offensiveName, _attackGroups];
    };

    private _battalion = [_side] call ACF_battalion;

    // 1. STAGING PHASE
    private _stagingResult = [_base, _side, _attackGroups, _battalion, _offensiveName] call ACF_ai_handleOffensiveStaging;
    if !(_stagingResult#0) exitWith {};
    _attackGroups = _stagingResult#1;

    // 2. START ATTACK
    private _attackInitResult = [_base, _side, _attackGroups, _battalion, _offensiveName] call ACF_ai_handleAttackInit;
    if !(_attackInitResult) exitWith {};

    private _attackStage = AS_ATTACK;
    sleep STRATEGY_TICK;
    _attackGroups = [_base,_battalion,_side,_attackGroups,_attackStage] call ACF_ai_attackReinforcements;

    // 3. MONITOR AND CONTROL ATTACK
    private _ended = false;
    while {!_ended} do {
        sleep STRATEGY_TICK;

        // Check if AI is still enabled
        if !(IS_AI_ENABLED(_battalion)) exitWith {
            //End the attack, cleanup everything
            {
                [_x, [_x] call ACF_rtbPos,B_TRANSPORT,true] call ACF_ai_move;
            } forEach _attackGroups;
            [_battalion, _base] call ACF_ai_cleanupAttack;
        };

        // Update attack/defense ratio
        private _attDefRatio = (GVAR(_base,"thr_currentStr") max 0.01) / (GVAR(_base,"def_currentDetStr") max 0.01);
        SVARG(_base,"adRatio",_attDefRatio);
        // if(DEBUG_MODE) then {
        //    systemChat format ["%1 Attack/Defense Ratio: %2", _offensiveName, _attDefRatio toFixed 2];
        //};

        // Victory condition
        if (GVAR(_base,"side") == _side) then {
            _ended = true;
            if(DEBUG_MODE) then {
                systemChat format ["%1 Victory", _offensiveName];
            };
        };
          
        if (!_ended && _attDefRatio <= AD_RETREAT_THRESHOLD) then {
            // Retreat
            _ended = true;
            if(DEBUG_MODE) then {
                systemChat format ["%1 Retreating - insufficient force", _offensiveName];
            };
        };  

        if (!_ended) then {
            // Continue attack and update reinforcements
            _attackGroups = [_base,_battalion,_side,_attackGroups,_attackStage] call ACF_ai_attackReinforcements;
            
            // Check if we still have groups
            if (count _attackGroups < 1) then {
                _ended = true;
            };
        };

        // Debug status update
        if(DEBUG_MODE) then {
            private _artGroups = AC_operationGroups select {side _x == _side && {GVAR(_x,"type") == TYPE_ARTILLERY} };
            private _artStatus = if(count _artGroups > 0) then {
                format ["Art:%1", count _artGroups]
            } else { "No Art" };

            systemChat format ["[%1] OFFENSIVE AGENT STATUS | Att/Def Ratio:%2/%3 | Groups:%4 | Art %5", 
                GVAR(_base,"callsign"),
                _attDefRatio toFixed 2,
                AD_RETREAT_THRESHOLD toFixed 2,
                count _attackGroups,
                _artStatus
            ];
        };
    };

    // 3. End the attack, cleanup everything
    {
        [_x, [_x] call ACF_rtbPos,B_TRANSPORT,true] call ACF_ai_move;
    } forEach _attackGroups;
    [_battalion, _base] call ACF_ai_cleanupAttack;
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
	private _color = [_side] call ACF_ai_getDetectionColor;

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
		systemChat format ["Counter %1 pursuing %2, staging timeout: %3s", 
			GVAR(_attackGroup,"callsign"),
			GVAR(_enemy,"callsign"),
			(_stagingTimeout - time) toFixed 2
		];
	};
};


// Improved transport staging finder with flattened logic
ACF_ai_findTransportStaging = {
    params ["_attackGroup", "_attackerPos", "_transPos", "_base"];
    
    // Initial point between attacker and transport
    private _stagingPoint = leader _attackGroup getRelPos [(_attackerPos distance _transPos)/5, leader _attackGroup getRelDir _transPos];
    private _bases = [AC_bases, _stagingPoint] call ACF_ai_sortByDistance;
    
    // First attempt with initial position
    if (_bases#0 distance _stagingPoint < 450) then {
        private _nearestSpawn = [_bases#0, ["stagePoints","spawnPoints"], _attackerPos] call ACF_ai_findNearestSpawn;
        if (count _nearestSpawn > 0) exitWith {_nearestSpawn};
    };
    
    private _nearestRoad = [_stagingPoint, 150, _base] call ACF_ai_findNearestRoad;
    if (count _nearestRoad > 0) exitWith {_nearestRoad};
    
    // Second attempt from attacker position
    _stagingPoint = _attackerPos;
    _bases = [_bases, _stagingPoint] call ACF_ai_sortByDistance;
    
    if (_bases#0 distance _stagingPoint < 450) then {
        private _nearestSpawn = [_bases#0, ["stagePoints","spawnPoints"], _attackerPos] call ACF_ai_findNearestSpawn;
        if (count _nearestSpawn > 0) exitWith {_nearestSpawn};
    };
    
    _nearestRoad = [_stagingPoint, 150, _base] call ACF_ai_findNearestRoad;
    if (count _nearestRoad > 0) exitWith {_nearestRoad};
    
    // If all attempts fail, return initial position
    _stagingPoint = leader _attackGroup getRelPos [(_attackerPos distance _transPos)/5, leader _attackGroup getRelDir _transPos];
	_stagingPoint
};


ACF_ai_transportAgent = {
	params ["_base","_side","_attackGroup","_transportGroup"];
	private _battalion = [_side] call ACF_battalion;
	private _transports = GVARS(_battalion,"transports",[]);
	_transports pushBack _transportGroup;

	// 1. Order all units to stage
	private _attackerPos = getPosATL leader _attackGroup;
	private _transPos = getPosATL leader _transportGroup;

	private _stagingPoint = [_attackGroup, _attackerPos, _transPos, _base] call ACF_ai_findTransportStaging;

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

	// if(DEBUG_MODE) then {
	// 	systemChat format ["[%1] TRANSPORT | Assets:%2 | Infantry:%3 | Active:%4", 
	// 		_side,
	// 		count _transGroups,
	// 		count _infGroups,
	// 		count _ongoingTransports
	// 	];
	// };
};

// Update offensive staging finder to use helpers
ACF_ai_findOffensiveStaging = {
    params ["_base", "_leaderPos"];
    
    // Calculate randomized position
    private _distance = (GVAR(_base,"out_perimeter") + OFFENSIVE_STAGING_DISTANCE);
    private _angleSpread = 45;
    private _baseAngle = _base getRelDir _leaderPos;
    private _randomAngle = _baseAngle + (random _angleSpread - _angleSpread/2);
    private _distanceVar = _distance * (0.8 + random 0.4);
    
    private _stagingPoint = _base getRelPos [_distanceVar, _randomAngle];
    
    // Try roads first
    private _nearestRoad = [_stagingPoint, 60, _leaderPos] call ACF_ai_findNearestRoad;
    if (count _nearestRoad > 0) exitWith {_nearestRoad};
    
    // Try spawn points
    private _nearestSpawn = [_base, ["stagePoints","spawnPoints"], _leaderPos] call ACF_ai_findNearestSpawn;
    if (count _nearestSpawn > 0) exitWith {_nearestSpawn};
    
    // Fallback to safe position
    private _stagingPoint = [getPosATL _base, 30] call ACF_ai_findSafePos;
    _stagingPoint
};

// Perform AI move to staging area
ACF_ai_moveToStaging = {
	params ["_group","_base",["_moveType",B_DEFAULT],"_canGetOrders",["_randomization",0]];
	private _leaderPos = getPosATL leader _group;
	private _distance = (GVAR(_base,"out_perimeter") + OFFENSIVE_STAGING_DISTANCE);
	
	// Add randomization to staging point selection
	private _angleSpread = 45; // Degrees
	private _baseAngle = _base getRelDir _leaderPos;
	private _randomAngle = _baseAngle + (random _angleSpread - _angleSpread/2);
	private _distanceVar = _distance * (0.8 + random 0.4); // 80-120% of original distance
	
	private _stagingPoint = [_base, _leaderPos] call ACF_ai_findOffensiveStaging;

	[_group, _stagingPoint, _moveType, _canGetOrders, _randomization] call ACF_ai_move;
};

// Helper function for base move staging point logic
ACF_ai_findBaseMoveStaging = {
    params ["_base", "_leaderPos"];
    
    // Try capture points first
    private _nearestSpawn = [_base, ["capturePoints"], _leaderPos] call ACF_ai_findNearestSpawn;
    if (count _nearestSpawn > 0) exitWith {_nearestSpawn};
    
    // Try roads
    private _basePos = getPosATL _base;
    private _nearestRoad = [_basePos, 30, _leaderPos] call ACF_ai_findNearestRoad;
    if (count _nearestRoad > 0) exitWith {_nearestRoad};
    
    // Fallback to safe position
    private _stagingPoint = [_basePos, 30] call ACF_ai_findSafePos;
    _stagingPoint
};

// Perform AI move to base area
ACF_ai_moveToBase = {
	params ["_group","_base",["_moveType",B_DEFAULT],"_canGetOrders",["_randomization",0]];
	private _leaderPos = getPosATL leader _group;
	private _stagingPoint = [_base, _leaderPos] call ACF_ai_findBaseMoveStaging;

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
	_availableGroups = [_availableGroups, _base] call ACF_ai_sortByDistance;
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
		systemChat format ["[%1] REINFORCE | Str:%2/%3 | Stage:%4 | Groups:%5/%6", 
			GVAR(_base,"callsign"),
			round _newStr,
			round _idealAttackStr,
			if(_attackStage == AS_STAGING) then {"STAGING"} else {"ASSAULT"},
			count _newAttackers,
			count _availableGroups
		];
	};
	_newAttackers
};

// Improved support and artillery usage function
ACF_ai_useSupports = {
    params ["_targetGroup", "_targetPos", "_side", "_battalion", ["_offensiveName", ""]];
    
    // Check and use support assets
    private _supports = GVARS(_battalion,"ec_supportsList",[]);
    if (count _supports == 0) exitWith {};
	private _vehicle = ([_targetGroup] call ACF_getGroupVehicles) param [0, objNull];
	{
		private _supportType = _x#5;
		private _ammoType = _x#6;
		private _armorValue = _x#7;
		private _chance = _x#2;
		private _readyTime = _x#3;
		
		// Skip if support is not ready
		if (time < _readyTime) then { continue; };
		
		// Skip if random chance check fails
		if (random _chance > 1) then { continue; };
		
		private _shouldFire = false;
		
		// CAS support logic
		if (_supportType == SUPPORT_CAS) then {
			if (isNull _vehicle) then {
				_shouldFire = true;
			} else {
				_shouldFire = _armorValue > 0;
			};
		}
		// Artillery support logic
		else {
			private _ammoFlags = (getText (configfile >> "CfgAmmo" >> _ammoType >> "aiAmmoUsageFlags")) splitString " + ";
			_shouldFire = switch (true) do {
				case (isNull _vehicle): {"64" in _ammoFlags};
				case (_vehicle isKindOf "Tank"): {"512" in _ammoFlags};
				default {"128" in _ammoFlags};
			};
		};
		
		if (_shouldFire) then {
			if(DEBUG_MODE) then {
				systemChat format ["%1 Preparation artillery fire on: %2 [%3]", _offensiveName, _targetGroup, _targetPos];
			};
			[_targetPos, _battalion, _forEachIndex] remoteExec ["ACF_callSupport", 2];
		};
	} forEach _supports;

    // Use artillery units
    private _artGroups = AC_operationGroups select {side _x == _side && {GVAR(_x,"type") == TYPE_ARTILLERY}};
    {
        if (random 3 <= 1) then {
            [_x, _targetPos] call AC_ai_fireMission;
            if(DEBUG_MODE) then {
                systemChat format ["%1 Fire mission called", _offensiveName];
            };
        };
        sleep 1;
    } forEach _artGroups;
};
