#include "\AC\defines\commonDefines.inc"


// Distance sorting utility
ACF_ai_sortByDistance = {
    params ["_elements", "_target", ["_ascending", true]];
    [
        _elements,
        [],
        {
            private _pos1 = if (typeName _x == "GROUP") then {leader _x} else {_x};
            private _pos2 = if (typeName _target == "GROUP") then {leader _target} else {_target};
            _pos1 distance2D _pos2
        },
        if(_ascending) then {"ASCEND"} else {"DESCEND"}
    ] call BIS_fnc_sortBy
};

// Side detection color utility
ACF_ai_getDetectionColor = {
    params ["_side"];
    private _color = switch (_side) do {
        case west: { "Wdetected" };
        case east: { "Edetected" };
        case resistance: { "Idetected" };
        default { "Edetected" };
    };
    _color
};

// Add new helper functions at the top of the file
ACF_ai_findNearestRoad = {
    params ["_pos", "_searchRadius", "_referencePos"];
    private _roads = _pos nearRoads _searchRadius;
    if (count _roads > 0) then {
        _roads = [_roads, _referencePos] call ACF_ai_sortByDistance;
        private _nearest_road = ASLToAGL getPosASL (_roads#0);
        _nearest_road
    } else {
        []
    };
};


ACF_ai_findNearestSpawn = {
    params ["_base", "_spawnTypes", "_referencePos"];
    private _spawns = [];
    {
        _spawns append GVARS(_base,_x,[]);
    } forEach _spawnTypes;
    
    if (count _spawns > 0) then {
        _spawns = [_spawns, _referencePos] call ACF_ai_sortByDistance;
        _spawns#0
    } else {
        []
    };
};


ACF_ai_findSafePos = {
    params ["_basePos", "_searchRadius"];
    private _safePos = [_basePos, 0, _searchRadius, 4, 0, 0.6, 0,[],[_basePos,_basePos]] call BIS_fnc_findSafePos;
    _safePos
};


// Helper to get available combat groups
ACF_ai_getAvailableAttackGroups = {
    params ["_side", "_hqGroup"];
    AC_operationGroups select {
        side _x == _side
        && {GVARS(_x,"canGetOrders",true)}
        && {_x != _hqGroup}
        && {GVAR(_x,"type") != TYPE_ARTILLERY}
        && {GVAR(_x,"type") != TYPE_AIR}
        && {!([_x] call ACF_grp_isUtility)}
    };
};