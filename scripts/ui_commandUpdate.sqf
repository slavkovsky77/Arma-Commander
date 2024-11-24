#include "\AC\defines\commonDefines.inc"

/*
	UI updates:
	Functions for updating whole UI and all its parts.
*/

// Update each visible UI element
ACF_ui_updateCommandUI = {
	if (!visibleMap) exitWith {};
	private _object = AC_mouseOver;
	if (count AC_selectedGroups > 0) then {_object = AC_selectedGroups select 0};
	private _updateFunctions = [ACF_ui_updateActionsList, ACF_ui_updateGroupInfo, ACF_ui_updateBattalionInfo, ACF_ui_updateBuyList, ACF_ui_updateBaseInfo];
	{
		if (ctrlShown UGVAR(_x)) then {
			[_object] call (_updateFunctions#_forEachIndex);
		};
	} forEach ["ac_actionsList", "ac_groupInfo", "ac_battalionInfo", "ac_buyList", "ac_baseInfo"];
};

ACF_ui_updateBaseInfo = {
	params ["_object"];
	//disableSerialization;
	private _base = leader _object;

	private _side = GVARS(_base,"side",sideUnknown);
	private _table = UGVAR("ac_baseInfo");
	private _color = [_side] call BIS_fnc_sideColor;
	//private _ammo = "? supplies";
	private _soldiers = "? soldiers";
	if (_side == AC_playerSide) then {
		_ammo = format ["%1 Supplies", (_base getVariable ["supplies",999])];
		_soldiers = format ["%1 Soldiers", (_base getVariable ["nSoldiers",999])];
	};
	private _value = GVARS(_base,"BaseValue",1);
	private _1 = (1 - GVARS(_base,"noincome",0)) * _value;
	private _2 = (1 - GVARS(_base,"novictory",0)) * _value;
	private _3 = [", Can Deploy.", "."] select (GVARS(_base,"nospawn",0) == 1);
	private _baseDescription = format ["%1 RP, %2 VP%3",_1,_2,_3];
	private _soldiersColor = [GVAR(_base,"nSoldiers"), GVAR(_base,"nSoldiersOriginal")] call ACF_ui_depletionColor;

	private _percent = "";
	private _percentColor = [1,1,1,1];
	if (GVAR(_base,"contested")) then {
		private _score = GVARS(_base,"score",0);
		_percent = format ["%1%2",abs _score,"%"];

		if (_side == sideUnknown || _side == sideEmpty) then {
			if (_score > 0) then {
				_percentColor = [GVAR(AC_battalions#0,"side")] call BIS_fnc_sideColor;
			};
			if (_score < 0) then {
				_percentColor = [GVAR(AC_battalions#1,"side")] call BIS_fnc_sideColor;
			};
		} else {
			if (_score < 0) then {
				_percentColor = [[_side] call ACF_enemySide] call BIS_fnc_sideColor;
			};
		};
	};

	//Info: Color, callsign, supplies, soldiers, resupply option, reinforceOption (dis)
	((_table ctHeaderControls 0)#0) ctrlSetBackgroundColor _color;
	((_table ctHeaderControls 1)# 0) ctrlSetBackgroundColor _color;
	((_table ctHeaderControls 0)# 2) ctrlSetText GVAR(_base,"callsign");
	((_table ctHeaderControls 1)# 2) ctrlSetText _baseDescription;

	((_table ctHeaderControls 1)# 3) ctrlSetTextColor _percentColor;
	((_table ctHeaderControls 1)# 3) ctrlSetText _percent;

	((_table ctRowControls 0)# 2) ctrlSetText _soldiers;
	((_table ctRowControls 0)# 2) ctrlSetTextColor _soldiersColor;


	//Reinfocement code
	private _tooltip = "";
	private _button = (_table ctRowControls 0)#3;
	// Show extra info for friendly base
	if (_side == AC_playerSide) then {
		//can units be reinforced?
		private _reinforceCost = GVAR(_base,"nSoldiersOriginal") - GVAR(_base,"nSoldiers");
		private _modifier = 1;

		if (_reinforceCost > 0) then {

			private _battalion = [_side] call ACF_battalion;
			private _module = GVARS(_battalion,"module",objNull);
			if (isNull _module) then {
				private _conf = configfile >> "AC" >> "Battalions" >> _battalion getVariable "type" >> "Reserves";
				_modifier = getNumber (_conf >> "modifier");
				_reinforceCost = ceil (_reinforceCost * _modifier);
			} else {
				_modifier = GVARS(_module,"modifier",1);
				_reinforceCost = ceil (_reinforceCost * _modifier);
			};

			_button ctrlSetText format ["Reinforce: %1", _reinforceCost];
			_tooltip = format ["Reinforce for %1 points. \nAvailable only when garrison is not deployed.",_reinforceCost];
			if ( GVAR(AC_playerBattalion,"points") >= _reinforceCost && GVARS(_base,"deployed", DEPLOYED_FALSE) == DEPLOYED_FALSE ) then {
				_button ctrlEnable true;
			} else {
				_button ctrlEnable false;
			};
		} else {
			_button ctrlSetText "No Reinforce";
			_button ctrlEnable false;
		};
	} else {
		_button ctrlSetText "No Reinforce";
		_button ctrlEnable false;
	};
	_button ctrlSetTooltip _tooltip;


};

// Shows selected unit, if there is none, show hovered unit
ACF_ui_updateGroupInfo = {
	params ["_group"];
	//disableSerialization;

	private _side = side _group;
	private _table = UGVAR("ac_groupInfo");

	// Show info, update all variable fields
	private _sideColor = [side _group] call BIS_fnc_sideColor;
	private _groupName = _group getVariable ["callsign", ""];
	private _rankIcon = [_group getVariable ["skill",0.4]] call ACF_ui_getRankIcon;

	// Show type of the unit
	private _groupType = [GVARS(_group,"typeStr",""),"name"] call ACF_getGroupString;

	private _ammo = "? ammo";
	private _soldiers = "? soldiers";
	private _vehicles = "? vehicles";
	private _soldiersColor = [1,1,1,1];
	private _vehicleColor = [1,1,1,1];

	// Show extra info for friendly units
	if (_side == AC_playerSide) then {
		private _nUnits = {alive _x} count units _group;
		_ammo = format ["%1%2 ammo",(_group getVariable ["ammo", 50]) * 100,"%"];
		_soldiers = format ["%1 soldiers",_nUnits];
		_soldiersColor = [_nUnits, count ([GVAR(_group,"typeStr"),"units"] call ACF_getGroupArray)] call ACF_ui_depletionColor;

		// Show correct vehicle
		([_group] call ACF_getGroupVehicles) params [["_vehicle",objNull]];
		if (!isNull _vehicle) then {
			private _name = _vehicle getVariable ["AC_name",""];
			if (_name == "") then {
				_name = getText (configfile >> "CfgVehicles" >> typeOf _vehicle >> "DisplayName");
				_vehicle setVariable ["AC_name", _name];
			};
			_vehicles = _name;
		} else {
			_vehicles = "-";
		};

		// Check if unit can be reinforced:
		private _resupplyCost = [_group,AC_playerBattalion] call ACF_canResupply;
		private _button = (_table ctRowControls 0)#3;

		if (_resupplyCost > 0) then {
			_button ctrlSetText format ["Resupply: %1", _resupplyCost];
		} else {
			_button ctrlSetText "No Resupply";
		};

		private _tooltip = "";
		if (_resupplyCost > -1 && {GVAR(AC_playerBattalion,"points") >= _resupplyCost}) then {
			_button ctrlEnable true;
			_tooltip = format ["Resupply for %1 points. \nAvailable only when group is at a deployment base",_resupplyCost];
		} else {
			_button ctrlEnable false;
		};
		_button ctrlSetTooltip _tooltip;
	};

	// Update ctrls
	private _headerBackground1 = (_table ctHeaderControls 0) select 0;
	private _headerBackground2 = (_table ctHeaderControls 1) select 0;
	_headerBackground1 ctrlSetBackgroundColor _sideColor;
	_headerBackground2 ctrlSetBackgroundColor _sideColor;

	{
		private _row = _table ctHeaderControls _forEachIndex;
		private _headerTextCtrl = _row select 2;
		private _headerColorCtrl = _row select 0;

		_headerColorCtrl ctrlSetBackgroundColor _sideColor;
		_headerTextCtrl ctrlSetText _x;
	} forEach [_groupName, _groupType];
	private _headerRank = (_table ctHeaderControls 1) select 1;

	_headerRank ctrlSetText _rankIcon;

	{
		private _textCtrl = (_table ctRowControls _forEachIndex) select 2;
		_textCtrl ctrlSetText _x;
	} forEach [_soldiers,_vehicles];

	{
		private _textCtrl = (_table ctRowControls _forEachIndex) select 2;
		_textCtrl ctrlSetTextColor _x;
	} forEach [_soldiersColor,_vehicleColor];

	//

	// Check if unit can be switched
	private _switchButton = (_table ctHeaderControls 1) select 3;

	if (_side == AC_playerSide
		&& {GVAR(_group,"type") != TYPE_ARTILLERY}
		&& {_group != group player}
	) then {
		_switchButton ctrlEnable true;
	} else {
		_switchButton ctrlEnable false;
	};
};

ACF_ui_updateBattalionInfo = {
	//disableSerialization;
	(UGVAR("ac_battalionInfo") ctRowControls 0) params ["_background","_icon","_points","_income","_requisitionButton"];

	private _countdown = 0;
	if (!isNil "AC_nextIncomeTime") then {
		_countdown = AC_nextIncomeTime - time;
	};


	private _side = AC_playerSide;
	private _basesIncome = 0;
	{
		_basesIncome = _basesIncome + GVARS(_x,"BaseValue",1);
	} forEach (AC_bases select {GVAR(_x,"side") == _side && {GVARS(_x,"noincome",0) == 0} });

	private _baseScore = _basesIncome + GVARS(AC_playerBattalion,"BasicIncome",5);
	private _score = floor (_baseScore * GVARS(AC_playerBattalion,"incomeMultiplier",1));

	_points ctrlSetText (str (floor GVAR(AC_playerBattalion,"points")));
	_income ctrlSetText format ["| +%1 in %2 |", _score, [_countdown] call ACF_timer];

	// Enable or disable requisition button depending on player being commander
	if (ctrlEnabled _requisitionButton && {!IS_COMMANDER}) then {
		_requisitionButton ctrlEnable false;
	};
	if (!ctrlEnabled _requisitionButton && {IS_COMMANDER}) then {
		_requisitionButton ctrlEnable true;
	};
};

ACF_ui_updateBuyList = {
	//disableSerialization;
	private _table = UGVAR("ac_buyList");
	private _rGroups = GVAR(AC_playerBattalion,"requestQueue");
	private _points = GVAR(AC_playerBattalion,"points");

	private _hqGroup = GVARS(AC_playerBattalion,"hqElement",grpNull);
	private _aliveGroups = {side _x == AC_playerSide && {{alive _x} count units _x > 0} && {_x != _hqGroup}} count AC_operationGroups;
	private _remainingSlots = AC_unitCap - (_aliveGroups + _rGroups);
	if(_remainingSlots < 0) then {_remainingSlots = 0}; // Hard cap just to prevent confusion

	private _unitList = [AC_playerBattalion] call ACF_ec_unitTable;

	// Header: Update unit count
	(_table ctHeaderControls 0)#3 ctrlSetText format ["%1/%2", _remainingSlots, AC_unitCap];

	for "_i" from 0 to (ctRowCount _table) - 1 do {
		(_unitList#_i) params ["_type","_count","_cost","_originalCount","_condition"];

		private _unitCount = (_table ctRowControls _i)#1;
		_unitCount ctrlSetText format ["%1/%2",_count,_originalCount];

		private _rowButton = (_table ctRowControls _i)#5;
		if (_points < _cost || {_remainingSlots == 0} || _count <= 0 || !(call _condition)) then {
			_rowButton ctrlEnable false;
		} else {
			_rowButton ctrlEnable true;
		};
	};

	// Update score list along it:
	private _table = UGVAR("ac_supportsList");
	private _supportsArray = GVARS(AC_playerBattalion,"ec_supportsList",[]);

	{
		private _timerCtrl = (_table ctRowControls _forEachIndex)#1;
		private _requestCtrl = (_table ctRowControls _forEachIndex)#5;
		private _timeout = ((_x#3) - time) max 0;
		private _cost = _x#2;
		private _condition = _x#9;

		_timerCtrl ctrlSetText ([_timeout] call ACF_timer);
		if (_timeout <= 0 && {_points >= _cost} && {call _condition}) then {
			_requestCtrl ctrlEnable true;
		} else {
			_requestCtrl ctrlEnable false;
		};
	} forEach _supportsArray;
};

ACF_ui_updateScoreInfo = {
	//disableSerialization;
	private _table = UGVAR("AC_scoreInfo");
	private _side1 = GVAR(AC_battalions#0,"side");
	private _points1 = [_side1] call ACF_victoryPoints;
	private _side2 = GVAR(AC_battalions#1,"side");
	private _points2 = [_side2] call ACF_victoryPoints;

	// Default values because some trouble with initialization at start
	(_table ctHeaderControls 0) params ["_background",["_flag1",controlNull],["_text1",controlNull],["_timer",controlNull],["_text2",controlNull]];
	_text1 ctrlSetText str _points1;
	_text2 ctrlSetText str _points2;

	if (!isNil "AC_endTime" && {AC_endTime > 0}) then {
		private _timeToEnd = [AC_endTime, "HH:MM:SS"] call BIS_fnc_secondsToString;
		_timer ctrlSetText _timeToEnd;
	};

	// Update commander's name
	// @TODO: When mouse over, do not change the name
	if (!AC_commandButtonFocused) then {
		private _table = UGVAR("AC_commanderInfo");
		(_table ctHeaderControls 0) params ["_background",["_button",controlNull]];
		[_button] call ACF_ui_showCommandName;
	};
};

ACF_ui_updateActionsList = {
	params ["_group"];
	private _table = UGVAR("ac_actionsList");
	private _transportButton = (_table ctRowControls 3) select 2;
	private _landButton = (_table ctRowControls 4) select 2;
	private _fireButton = (_table ctRowControls 5) select 2;

	// Determine get in, get out, unload text:
	private _text = "GET IN";
	switch ([_group] call ACF_ui_vehicleActionType) do {
		case ACTION_GET_OUT: {_text = "GET OUT"};
		case ACTION_UNLOAD: {_text = "UNLOAD TRANSPORT"};
	};

	if (ctrlText _transportButton != _text) then {
		_transportButton ctrlSetText _text;
	};

	// Handle land button
	if (AC_selectedGroups findIf {[_x] call ACF_grp_isAircraft} > -1) then {
		_landButton ctrlEnable true;
	} else {
		_landButton ctrlEnable false;
	};

	// Handle fire button
	if (AC_selectedGroups findIf {GVAR(_x,"type") == TYPE_ARTILLERY} > -1) then {
		_fireButton ctrlEnable true;
	} else {
		_fireButton ctrlEnable false;
	};


	_table ctSetCurSel ([] call ACF_ui_highlightedAction);
};

ACF_ui_highlightedAction = {
	if (count AC_selectedGroups == 0) exitWith {-1};
	private _firstSelected = AC_selectedGroups#0;
	private _index = -1;
	if (UGVARS("fireMission",false)) exitWith {5};

	// Find out mode of first unit and find out if this works across the board
	switch (true) do {
		case (AC_selectedGroups findIf {GVARS(_group,"#b",B_DEFAULT) != B_TRANSPORT} == -1): {
			_index = 0;
		};
		case (AC_selectedGroups findIf {GVARS(_group,"#b",B_DEFAULT) != B_COMBAT && GVARS(_group,"#b",B_DEFAULT) != B_DEFAULT} == -1): {
			_index = 1;
		};
		case (AC_selectedGroups findIf {GVARS(_group,"#b",B_DEFAULT) != B_SILENT} == -1): {
			_index = 2;
		};
	};
	_index
};