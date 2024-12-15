ACF_ai_manageBattalionMovement = {
    params ["_battalion"];
    {
        // Only force movement check for groups that might be stuck
        private _lastMoveTime = GVARS(_x,"lastMoveTime",time);
        private _forceCheck = (time - _lastMoveTime) > 30;
        
        [_x, _forceCheck] call ACF_ai_manageGroupMovement;
    } forEach AC_operationGroups;
};

// Central function to manage AI group movement states and behaviors
ACF_ai_manageGroupMovement = {
    params ["_group", ["_forceCheck", false]];
    if (isNull _group) exitWith {};
    
    // Skip if group has orders and isn't stuck (unless force check)
    if (!_forceCheck && {GVARS(_group,"canGetOrders",false)}) exitWith {};
    
    private _leader = leader _group;
    private _lastPos = GVARS(_group,"lastPos",[0,0,0]);
    private _lastMoveTime = GVARS(_group,"lastMoveTime",time);
    private _currentWP = currentWaypoint _group;
    private _isStuck = (time - _lastMoveTime) > 60;
    
    // Update position tracking
    if (_leader distance _lastPos > 5) then {
        SVARG(_group,"lastPos",getPosATL _leader);
        SVARG(_group,"lastMoveTime",time);
    };

    // Check if group is in transport
    if ([_group] call ACF_isTransported) exitWith {};
    
    // Handle stuck with GET OUT waypoint
    if (_currentWP > 0) then {
        private _wpType = waypointType [_group, _currentWP];
        if (_wpType == "GETOUT" && _isStuck) then {
            while {count waypoints _group > 0} do {
                deleteWaypoint ((waypoints _group)#0);
            };
            SVARG(_group,"canGetOrders",true);
        };
    };

    // Handle general stuck state
    if (_isStuck) then {
        // Check if group is part of an ongoing operation
        private _isAttacking = false;
        private _isDefending = false;
        private _battalion = [side _group] call ACF_battalion;
        
        if (!isNull _battalion) then {
            _isAttacking = _group in GVARS(_battalion,"attacks",[]);
            _isDefending = GVARS(_group,"defending",false);
        };

        if (!_isAttacking && !_isDefending) then {
            // Only RTB if not part of an active operation
            private _rtbPos = [_group] call ACF_rtbPos;
            if (!isNil "_rtbPos") then {
                [_group, _rtbPos, B_COMBAT, true, 25] call ACF_ai_move;
                if(DEBUG_MODE) then {
                    systemChat format ["Group %1 stuck - RTB initiated", _group];
                };
            };
        } else {
            if(DEBUG_MODE) then {
                systemChat format ["Group %1 stuck but has active orders - maintaining position", _group];
            };
        };
    };
};

// Find tactical position considering other groups
ACF_findTacticalPosition = {
    params ["_base", "_group"];
    
    private _basePos = getPosATL _base;
    private _otherGroups = AC_operationGroups select {
        side _x == side _group && 
        _x != _group && 
        (leader _x distance _base) < DEFENSE_DISTANCE
    };
    
    // Get average position of other groups
    private _avgPos = [0,0,0];
    {
        _avgPos = _avgPos vectorAdd (getPosATL leader _x);
    } forEach _otherGroups;
    
    if (count _otherGroups > 0) then {
        _avgPos = _avgPos vectorMultiply (1/count _otherGroups);
        
        // Find position on opposite side of base from average position
        private _dir = _avgPos getDir _basePos;
        private _tacticalPos = _basePos getPos [DEFENSE_DISTANCE * 0.75, _dir + 180 + (random 90 - 45)];
        _tacticalPos
    } else {
        // If no other groups, pick random position around base
        _basePos getPos [DEFENSE_DISTANCE * 0.75, random 360]
    };
};