#include "\AC\defines\commonDefines.inc";

/*
	Initialization of all bases: Script running on each machine locally
	Synchronized variables:
		- side
		- name
		- nSoldiers
		- nSoldiersOriginal
		- flag
*/

ACF_nav_initBases = {
	{
		// @CLEANUP: Is this needed? Probably not
		if (isNil {GVAR(_x,"detected")}) then {
			private _detected = true;
			if (GVAR(_x,"hidden") == 1) then {_detected = false};
			SVARG(_x,"detected",_detected);

			SVARG(_x,"Wdetected",_detected);
			SVARG(_x,"Edetected",_detected);
			SVARG(_x,"Idetected",_detected);
		};

		private _side = [GVAR(_x,"side")] call AC_fnc_numberToSide;
		SVARG(_x,"side",_side);

		switch (_side) do {
		    case WEST: { SVARG(_x,"Wdetected",true); };
		    case EAST: { SVARG(_x,"Edetected",true); };
		    case RESISTANCE: { SVARG(_x,"Idetected",true); };
		};

		[_x] call ACF_nav_setPerimeters;

		if (isServer) then {
			[_x] call ACF_nav_randomizeLocation;
			//dummy group for icon system
			private _newGroup = createGroup civilian;
			[_x] join _newGroup;
			SVARG(_newGroup,"base",_x);
			[_x] call ACF_nav_setGarrison;
			[_x, GVAR(_x,"nSoldiers")] spawn AC_gar_createGarrison;
			[_x,_side] call ACF_createFlag;
			[_x] call ACF_nav_setBaseName;
		};
	} forEach AC_bases;
	// Create AI neighbor connections and location cache for strategy
	{[_x] call ACF_nav_scanNeighbors} forEach AC_bases;
	{[_x] call ACF_nav_rescanMissingNeighbors} forEach AC_bases;
	{[_x] call ACF_nav_scanPlaces} forEach AC_bases;
};

ACF_nav_randomizeLocation = {
	params ["_base"];
	private _randomLocations = (synchronizedObjects _base) select {_x isKindOf "AC_ModuleRandomLocation"};
	if (count _randomLocations == 0) exitWith {};

	private _weights = [];
	{
		private _weight = GVARS(_x,"Weight",1);

		if(_weight isEqualType "") then {
			_weight = compile _weight;
		};
		_weights pushBack _weight;
	} forEach _randomLocations;

	private _finalLocation = _randomLocations selectRandomWeighted _weights;
	_base setPosWorld getPosWorld _finalLocation;
	{deleteVehicle _x} forEach _randomLocations;
};

// TODO: Take any shape for the base
ACF_nav_setPerimeters = {
	params ["_base"];
	// Can be circle only, take the larger area
	private _perimeter = GVARS(_base,"objectArea",BASE_PERIMETER_MIN);
	private _outperimeter =	[(_perimeter#0) max (_perimeter#1), BASE_PERIMETER_MIN, BASE_PERIMETER_MAX] call BIS_fnc_clamp;
	_base setVariable ["out_perimeter", _outperimeter];
};

ACF_nav_setBaseName = {
	params ["_base"];
	private _name = GVAR(_base,"callsign");
	private _finalName = "";
	private _locationName =  "";

	if (_name == "") then {
		// Autodetect name from names of locations around it
		_locationName = text ((nearestLocations [getPosWorld _base,
		["nameCity","Airport","NameMarine","NameCityCapital","NameVillage","NameLocal"],
		400])#0);
		if (!isNil "_locationName" && {_locationName != ""}) then {
			_finalName = _locationName;
			// Make sure first letter is uppercase
			_strArray = _finalName splitString "";
			private _upper = toUpper (_strArray#0);
			if (!isNil "_upper") then {
				_strArray set [0,_upper];
				_finalName = _strArray joinString "";
			}
		} else {
			_locationName = text ((nearestLocations [getPosWorld _base,
			["Area","BorderCrossing","CivilDefense","CulturalProperty","Flag","FlatArea","FlatAreaCity","FlatAreaCitySmall","Hill","Name","RockArea","SafetyZone","Strategic","StrongpointArea","VegetationBroadleaf","VegetationFir","VegetationPalm","VegetationVineyard","ViewPoint"],
			500])#0);
			if (!isNil "_locationName" && {_locationName != ""}) then {
				_finalName = _locationName;
				// Make sure first letter is uppercase
				_strArray = _finalName splitString "";
				private _upper = toUpper (_strArray#0);
				if (!isNil "_upper") then {
					_strArray set [0,_upper];
					_finalName = _strArray joinString "";
				}
			} else {
				// Choose name automatically
				_finalName = [GVAR(_base,"side")] call ACF_phoneticalWordAuto;
			};
		};
	} else {
		_finalName = _name;
	};

	// Add base value to the base callsign
	private _value = GVAR(_x,"BaseValue");
	if(_value != 1) then {
		_finalName = _finalName + format[" [%1]",_value];
	};

	SVARG(_base,"callsign",_finalName);
};

// Scan units in base and set their params as data
ACF_nav_setGarrison = {
	params ["_base"];
	private _synchronizedUnits = synchronizedObjects _base select {_x isKindOf "man"};

	private _garrisonGroup = grpNull;
	if (count _synchronizedUnits > 0) then {
		_garrisonGroup = group (_synchronizedUnits select 0);
	};
	private _positions = [];
	private _directions = [];
	private _specialAtt = [];
	private _stances = [];
	{
		_positions pushBack (getPosATL _x);
		_directions pushBack (direction _x);
		_stances pushBack (unitPos _x);
		private _objParent = objectParent _x;
		if (!isNull _objParent) then {
			_specialAtt pushBack _objParent;
		} else {
			_specialAtt pushBack objNull;
		};
		deleteVehicle _x;
	} forEach units _garrisonGroup;

    _garrisonGroup deleteGroupWhenEmpty true;
	if !(local _garrisonGroup) then {
	    [_garrisonGroup, true] remoteExec ["deleteGroupWhenEmpty", groupOwner _garrisonGroup];
	};

	SVARG(_base,"gar_positions",_positions);
	SVARG(_base,"gar_directions",_directions);
	SVARG(_base,"gar_specialAtt",_specialAtt);
	SVARG(_base,"gar_stances",_stances);
};

// Create connections between bases
#define DIR_DIFF 50
ACF_nav_scanNeighbors = {
	params ["_base"];
	if !(isServer) exitWith {};
	// Make sure there is at least 1 node
	private _range = 1500;
	private _nearbyNodes = (nearestObjects [_base, ["AC_ModuleACBase"], _range]) - [_base];
	while {count _nearbyNodes < 5 && count AC_bases > 6} do {
		_range = _range + 250;
		_nearbyNodes = (nearestObjects [_base, ["AC_ModuleACBase"], _range]) - [_base];
	};
	while {count _nearbyNodes < 1} do {
		_range = _range + 250;
		_nearbyNodes = (nearestObjects [_base, ["AC_ModuleACBase"], _range]) - [_base];
	};

	private _confirmedNeighbors = [];
	// Compare angles with other selected nodes
	{
		private _currentNode = _x;
		private _nodeDir = _base getRelDir _currentNode;

		private _hasGoodAngle = true;
		{
			private _baseDir = _base getRelDir _x;
			private _dirDiff = (_nodeDir max _baseDir) - (_nodeDir min _baseDir);
			if (_dirDiff > 180) then {
				_dirDiff = abs (_dirDiff - 360);
			};

			if (_dirDiff < DIR_DIFF) exitWith {
				_hasGoodAngle = false;
			};
		} forEach _confirmedNeighbors;

		if (_hasGoodAngle) then {
			_confirmedNeighbors pushBack _currentNode;
			if (DEBUG_MODE) then {[_base, _currentNode] call ACF_createLine};
		};

		// If there are enough neighbors, escape the loop.
		if (count _confirmedNeighbors >= 4) exitWith {};
	} forEach _nearbyNodes;

	// Write neighbors into array
	SVARG(_base,"neighbors",_confirmedNeighbors);
};

// Propagate yourself as neighbor if others don't have you in their database
ACF_nav_rescanMissingNeighbors = {
	params ["_base"];
	if !(isServer) exitWith {};
	{
		private _baseNeighbors = GVARS(_x,"neighbors",[]);
		if !(_base in _baseNeighbors) then {
			_baseNeighbors pushBackUnique _base;
			SVARG(_x,"neighbors", _baseNeighbors);
		};
	} forEach GVARS(_base,"neighbors",[]);
};

// Create and change flag in one funtion
ACF_createFlag = {
	params ["_base","_side"];
	private _flag = GVARS(_base,"flag",objNull);
	if (isNull _flag) then {
		_flag = createVehicle ["FlagPole_F", getPosATL _base, [], 0, "CAN_COLLIDE"];
		SVARG(_base,"flag",_flag);
	};
	private _battalion = [_side] call ACF_battalion;
	private _texture = GVARS(_battalion,"flag","");
	_flag forceFlagTexture _texture;
	_flag
};

ACF_nav_scanPlaces = {
	params ["_base"];
	if (isServer) then {
		private _stagingAreas = [];
		private _spawningAreas = [];
		private _captureAreas = [];
		private _baseNeighbors = GVARS(_base,"neighbors",[]);
		private _basePos = getPosATL _base;
		private _scanPos = _basePos;
		private ["_roads", "_road"];
		private _spawns = 0;
		private _maxDistance = 0;

		//main capture zones
		private _stagingPoint = _basePos;
		private _perimeter = GVAR(_base,"out_perimeter") * 0.8;
		myPlaces = selectBestPlaces [_basePos, _perimeter, "meadow - hills - trees - ((houses+forest)*0.75) - (waterDepth*2)", 8, 4];
		{
			_scanPos = _x#0;
			_roads = _scanPos nearRoads 8;
			if (count _roads > 0) then {
				_roads = [_roads,[],{_x distance _scanPos},"ASCEND"] call BIS_fnc_sortBy;
				_road = _roads#0;
				_stagingPoint = ASLToAGL getPosASL _road;
			};
			if (_stagingPoint distance2d _basePos < _perimeter && _stagingPoint distance2d _basePos > 0 ) then {
				_captureAreas pushBackUnique _stagingPoint;
			} else {
				_stagingPoint = [_scanPos, 0, 8, 4, 0, 0.6, 0,[],[_scanPos,_scanPos]] call BIS_fnc_findSafePos;
				if (_stagingPoint distance2d _scanPos != 0 && {_stagingPoint distance2d _basePos <= _perimeter}  ) then {
					_captureAreas pushBackUnique _stagingPoint;
				};
			};
		} forEach myPlaces;

		//neighbor landing zone
		{
			_stagingPoint = _base getRelPos [150, _base getRelDir _x];
			if (_x distance _basePos < 900) then {
				_maxDistance = ((_x distance _basePos)/2) max 150;
			} else {
				_maxDistance = 450;
			};
			myPlaces = selectBestPlaces [_stagingPoint, 75, "meadow - hills - trees - houses - forest - (waterDepth*2)", 30, 4];
			myPlaces = [myPlaces,[],{_x#0 distance _base},"DESCEND"] call BIS_fnc_sortBy;
			{
				_scanPos = _x#0;
				_roads = _scanPos nearRoads 30;
				if (count _roads > 0) then {
					_roads = [_roads,[],{_x distance _scanPos},"ASCEND"] call BIS_fnc_sortBy;
					_road = _roads#0;
					_stagingPoint = ASLToAGL getPosASL _road;
				};
				if (_stagingPoint distance2d _basePos < 250 && {!(_stagingPoint isFlatEmpty [5, -1, 0.6, 3, 0, false] isEqualTo [])} ) exitWith {
					_spawningAreas pushBackUnique _stagingPoint;
					_spawns = _spawns + 1;
				};
				if (count _roads > 0) then {
					_roads = [_roads,[],{_x distance _base},"DESCEND"] call BIS_fnc_sortBy;
					_road = _roads#0;
					_stagingPoint = ASLToAGL getPosASL _road;
				};
				if (_stagingPoint distance2d _basePos < 250 && {!(_stagingPoint isFlatEmpty [5, -1, 0.6, 3, 0, false] isEqualTo [])} ) exitWith {
					_stagingAreas pushBackUnique _stagingPoint;
					_spawns = _spawns + 1;
				};
				_stagingPoint = [_scanPos, 0, 30, 12, 0, 0.5, 0,[],[_scanPos,_scanPos]] call BIS_fnc_findSafePos;
				if (_stagingPoint distance2d _scanPos != 0 && {_stagingPoint distance2d _basePos < 250} && {!(_stagingPoint isFlatEmpty  [5, -1, 0.6, 3, 0, false] isEqualTo [])} ) exitWith {
					_spawningAreas pushBackUnique _stagingPoint;
					_spawns = _spawns + 1;
				};
			} forEach myPlaces;

			//neighbor staging zone
			_stagingPoint = _base getRelPos [_maxDistance-100, _base getRelDir _x];
			myPlaces = selectBestPlaces [_stagingPoint, 75, "meadow - hills - trees - ((houses+forest)*0.75) - (waterDepth*2)", 30, 4];
			myPlaces = [myPlaces,[],{_x#0 distance _base},"DESCEND"] call BIS_fnc_sortBy;
			{
				_scanPos = _x#0;
				_roads = _scanPos nearRoads 30;
				if (count _roads > 0) then {
					_roads = [_roads,[],{_x distance _scanPos},"ASCEND"] call BIS_fnc_sortBy;
					_road = _roads#0;
					_stagingPoint = ASLToAGL getPosASL _road;
				};
				if (_stagingPoint distance2d _basePos < 450 && {!(_stagingPoint isFlatEmpty  [3, -1, 0.6, 3, 0, false] isEqualTo [])} ) exitWith {
					_stagingAreas pushBackUnique _stagingPoint;
				};
				if (count _roads > 0) then {
					_roads = [_roads,[],{_x distance _base},"ASCEND"] call BIS_fnc_sortBy;
					_road = _roads#0;
					_stagingPoint = ASLToAGL getPosASL _road;
				};
				if (_stagingPoint distance2d _scanPos != 0 && {_stagingPoint distance2d _basePos < 450} && {!(_stagingPoint isFlatEmpty  [3, -1, 0.6, 3, 0, false] isEqualTo [])} ) exitWith {
					_stagingAreas pushBackUnique _stagingPoint;
				};
				_stagingPoint = [_scanPos, 0, 30, 10, 0, 0.5, 0,[],[_scanPos,_scanPos]] call BIS_fnc_findSafePos;
				if (_stagingPoint distance2d _scanPos != 0 && {_stagingPoint distance2d _basePos < 450} && {!(_stagingPoint isFlatEmpty  [0, -1, 0.6, 3, 0, false] isEqualTo [])} ) exitWith {
					_stagingAreas pushBackUnique _stagingPoint;
				};
			} forEach myPlaces;
		} forEach _baseNeighbors;

		if (_spawns < count _baseNeighbors) then {
			//main landing zone
			_stagingPoint = _basePos;
			myPlaces = selectBestPlaces [_basePos, 60, "meadow - hills - trees - houses - forest - (waterDepth*2)", 20, 4];
			{
				_scanPos = _x#0;
				_roads = _scanPos nearRoads 30;
				if (count _roads > 0) then {
					_roads = [_roads,[],{_x distance _scanPos},"ASCEND"] call BIS_fnc_sortBy;
					_road = _roads#0;
					_stagingPoint = ASLToAGL getPosASL _road;
				};
				if (_stagingPoint distance2d _basePos < 250 && {!(_stagingPoint isFlatEmpty  [5, -1, 0.6, 3, 0, false] isEqualTo [])} ) exitWith {
					_spawningAreas pushBackUnique _stagingPoint;
				};
				if (count _roads > 0) then {
					_roads = [_roads,[],{_x distance _base},"DESCEND"] call BIS_fnc_sortBy;
					_road = _roads#0;
					_stagingPoint = ASLToAGL getPosASL _road;
				};
				if (_stagingPoint distance2d _basePos < 250 && {!(_stagingPoint isFlatEmpty  [5, -1, 0.6, 3, 0, false] isEqualTo [])} ) exitWith {
					_stagingAreas pushBackUnique _stagingPoint;
				};
				_stagingPoint = [_scanPos, 0, 30, 15, 0, 0.5, 0,[],[_scanPos,_scanPos]] call BIS_fnc_findSafePos;
				if (_stagingPoint distance2d _scanPos != 0 && {!(_stagingPoint isFlatEmpty  [0, -1, 0.6, 3, 0, false] isEqualTo [])} ) exitWith {
					_spawningAreas pushBackUnique _stagingPoint;
				};
			} forEach myPlaces;
		};

		if (DEBUG_MODE) then {
			{
				private _mrk = createMarkerLocal [str _x,_x];
				_mrk setMarkerShapeLocal "ELLIPSE";
				_mrk setMarkerSizeLocal [12,12];
				_mrk setMarkerAlphaLocal 0.45;
			} forEach _stagingAreas;
			{
				private _mrk = createMarkerLocal [str _x,_x];
				_mrk setMarkerShapeLocal "ELLIPSE";
				_mrk setMarkerSizeLocal [12,12];
				_mrk setMarkerAlphaLocal 0.80;
			} forEach _spawningAreas;
			{
				private _mrk = createMarkerLocal [str _x,_x];
				_mrk setMarkerShapeLocal "ELLIPSE";
				_mrk setMarkerSizeLocal [6,6];
				_mrk setMarkerAlphaLocal 0.95;
			} forEach _captureAreas;
		};
		SVARG(_base,"stagePoints",_stagingAreas);
		SVARG(_base,"spawnPoints",_spawningAreas);
		SVARG(_base,"capturePoints",_captureAreas);
	};
};