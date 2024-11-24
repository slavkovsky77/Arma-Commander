#include "\AC\defines\commonDefines.inc";

// This is list of commonly used functions without any dependency on existing Arma Commander functionality

// Pick up random locaiton within predefined radius
ACF_randomPos = {
	params ["_center", "_radius"];
	_center params ["_xPos","_yPos"];

	private _xRandom = random _radius * 2 - _radius;
	private _yRandom = random _radius * 2 - _radius;

	_xPos = _xPos + _xRandom;
	_yPos = _yPos + _yRandom;

	private _pos = [_xPos, _yPos, 0];
	_pos
};

ACF_nearestArrayObject = {
	params ["_pos","_arr"];
	private _dist = 10e10;
	private _closestObj = objNull;
	private _currentElementDistance = 0;
	{
		_currentElementDistance = _x distance2D _pos;
		if (_currentElementDistance < _dist) then {
			_closestObj = _x;
			_dist = _currentElementDistance;
		};
	} forEach _arr;
	_closestObj
};

// Point in middle between 2 positions
ACF_middlePos = {
	params ["_pos1","_pos2"];
	if (_pos2 isEqualType objNull) then {_pos2 = getPosWorld _pos2};
	{
		if (_x isEqualType objNull) then {_x = getPosWorld _x};
		if (count _x < 3) then {_x set [2,0]};
	} forEach [_pos1, _pos2];

	private _middlePos = _pos1 vectorAdd _pos2;
	_p0 = (_middlePos select 0) * 0.5;
	_p1 = (_middlePos select 1) * 0.5;

	_middlePos = [_p0, _p1, 0];
	_middlePos
};

ACF_phoneticalWord = {
	params ["_index","_side"];

	if (isNil "AC_phonecticalWordsWest") then {
		AC_phonecticalWordsWest = [
			"Alpha",
			"Bravo",
			"Charlie",
			"Delta",
			"Echo",
			"Foxtrot",
			"Golf",
			"Hotel",
			"India",
			"Juliett",
			"Kilo",
			"Lima",
			"Mike",
			"November",
			"Oscar",
			"Papa",
			"Quebec",
			"Romeo",
			"Sierra",
			"Tango",
			"Uniform",
			"Victor",
			"Whiskey",
			"X-Ray",
			"Yankee",
			"Zulu"
		];
		AC_phonecticalWordsIndep = [
			"Apples",
			"Butter",
			"Charlie",
			"Duff",
			"Edward",
			"Freddie",
			"George",
			"Harry",
			"Ink",
			"Johnnie",
			"King",
			"London",
			"Monkey",
			"Nuts",
			"Orange",
			"Pudding",
			"Queenie",
			"Robert",
			"Sugar",
			"Tommy",
			"Uncle",
			"Vinegar",
			"William",
			"Xylophone",
			"Yorker",
			"Zebra"
		];

		AC_phonecticalWordsEast = [
			"Anna",
			"Boris",
			"Center",
			"Dmitri",
			"Elena",
			"Fyodor",
			"Gregory",
			"Chariton",
			"Ivan",
			"Jot",
			"Konstantin",
			"Leonid",
			"Mikhail",
			"Nikolai",
			"Olga",
			"Pavel",
			"Chelovek",
			"Roman",
			"Sergej",
			"Tatyana",
			"Ulyana",
			"Vasilij",
			"Shchuka",
			"Znak",
			"Yurij",
			"Zina"
		];
	};
	private _nameArray = AC_phonecticalWordsWest;
	if (_side == EAST) then {
		_nameArray = AC_phonecticalWordsEast;
	};
	if (_side == independent) then {
		_nameArray = AC_phonecticalWordsIndep;
	};
	_nameArray#_index
};

ACF_phoneticalWordAuto = {
	params ["_side"];

	// Convert number to side if needed
	if (_side isEqualType 0) then {
		_side = [_side] call AC_fnc_numberToSide;
	};

	private _index = 0;
	private _word = "";

	if (isNil "AC_phoneticalIndexWest") then {
		AC_phoneticalIndexWest = 0;
		AC_phoneticalIndexEast = 0;
	};

	if (_side == EAST) then {
		if (AC_phoneticalIndexEast > 25) then {
			AC_phoneticalIndexEast = 0;
		};
		_word = [AC_phoneticalIndexEast, east] call ACF_phoneticalWord;
		AC_phoneticalIndexEast = AC_phoneticalIndexEast + 1;
	} else {
		if (AC_phoneticalIndexWest > 25) then {
			AC_phoneticalIndexWest = 0;
		};
		_word = [AC_phoneticalIndexWest, west] call ACF_phoneticalWord;
		AC_phoneticalIndexWest = AC_phoneticalIndexWest + 1;
	};
	_word
};

ACF_assignCallsign = {
	params ["_battalion"];
	private _index = GVARS(_battalion,"phIndex",0);
	private _side = GVARS(_battalion,"side",sideUnknown);

	private _maxIndex = 25;
	private _callsign = [_index,_side] call ACF_phoneticalWord;

	_index = _index + 1;
	if (_index >= _maxIndex) then {
		_index = 0;
	};
	SVARG(_battalion,"phIndex",_index);
	_callsign
};

AC_markerIndex = 2000;
ACF_createLine = {
	params ["_p1","_p2"];
	private _distance = _p1 distance _p2;
	private _relDir = _p1 getRelDir _p2;

	private _middlePoint = _p1 getRelPos [_distance * 0.5, _relDir];

	private _mrk = createMarkerLocal [str AC_markerIndex, _middlePoint];
	AC_markerIndex = AC_markerIndex + 1;
	_mrk setMarkerShape "RECTANGLE";
	_mrk setMarkerSize [_distance / 2,2];
	_mrk setMarkerColor "colorCivilian";
	_mrk setMarkerDir _relDir + 90;
	_mrk setMarkerAlpha 0.25;
};

ACF_enemySide = {
	params ["_side"];
	private _enemySide = sideUnknown;
	if !(_side in [WEST,EAST,RESISTANCE]) exitWith {_enemySide};
	{
		private _batSide = GVAR(_x,"side");
		if (_batSide != _side) exitWith {
			_enemySide = _batSide;
		};
	} forEach AC_battalions;
	_enemySide
};

ACF_isTransported = {
	params ["_group"];
	private _lead = leader _group;
	private _vehicle = vehicle _lead;
	private _result = false;
	if (_vehicle != _lead) then {
		private _commander = effectiveCommander _vehicle;
		{
			if (_x == _commander && {group _x != _group} && {alive _x} ) exitWith {_result = true;};
		} forEach crew _vehicle;
	};
	_result
};

ACF_runEndTimer = {
	params ["_timeLeft"];
	if (!isNil "AC_endTime") exitWith {};
	private _receiveTime = time;

	while {true} do {
		AC_endTime = (_timeLeft - (time - _receiveTime)) max 0;
		sleep 1;
		if (visibleMap) then {
			[] call ACF_ui_updateScoreInfo;
		};
	};
};


ACF_timer = {
	params ["_number"];

	private _minutes = floor (_number / 60);
	private _seconds = round _number % 60;
	private _minuteStr = str _minutes;
	if (_minutes < 10) then {_minuteStr = format ["0%1",_minutes]};
	private _secondStr = str _seconds;
	if (_seconds < 10) then {_secondStr = format ["0%1",_seconds]};

	private _string = format ["%1:%2",_minuteStr,_secondStr];
	_string
};


ACF_getGroupArray = {
	params [["_groupType",""],"_entry"];
	private _array = [];
	private _module = MGVARS(_groupType,objNull);
	if (!isNull _module && {typeOf _module == "AC_ModuleRegisterGroup"}) then {
		_array = GVAR(_module,_entry);
	} else {
		_array = getArray (configfile >> "AC" >> "Groups" >> _groupType >> _entry);
	};
	_array
};

ACF_getGroupString = {
	params [["_groupType",""],"_entry"];
	private _string = "";
	private _module = MGVARS(_groupType,objNull);
	if (!isNull _module && {typeOf _module == "AC_ModuleRegisterGroup"}) then {
		_string = GVAR(_module,_entry);
	} else {
		_string = getText (configfile >> "AC" >> "Groups" >> _groupType >> _entry);
	};
	_string
};

ACF_getGroupNumber = {
	params [["_groupType",""],"_entry"];
	private _number = 0;
	private _module = MGVARS(_groupType,objNull);
	if (!isNull _module && {typeOf _module == "AC_ModuleRegisterGroup"}) then {
		_number = GVARS(_module,_entry,0);
	} else {
		_number = getNumber (configfile >> "AC" >> "Groups" >> _groupType >> _entry);
	};
	_number
};

ACF_getGroupBool = {
	params [["_groupType",""],"_entry"];
	private _bool = false;
	private _module = MGVARS(_groupType,objNull);
	if (!isNull _module && {typeOf _module == "AC_ModuleRegisterGroup"}) then {
		_bool = GVARS(_module,_entry,false);
	} else {
		_bool = (configfile >> "AC" >> "Groups" >> _groupType >> _entry) call BIS_fnc_getCfgDataBool;
	};
	//if (_bool == 0) then {_bool = false};
	_bool
};

ACF_combatGroups = {
	params ["_side"];
	if (_side isEqualType objNull) then {
		_side = GVARS(_side,"side",sideUnknown);
	};
	private _groups = AC_operationGroups select {
		side _x == _side
		&& {GVAR(_x,"type") != TYPE_ARTILLERY}
		//&& {_x != _hqGroup}
		&& {{alive _x} count units _x > 0}
	};
	_groups
};

ACF_victoryPoints = {
	params ["_side"];
	private _points = 0;
	{
		_points = _points + GVARS(_x,"BaseValue",1);
	} forEach (AC_bases select {GVAR(_x,"side") == _side && {GVARS(_x,"novictory",0) == 0} });
	_points
};
