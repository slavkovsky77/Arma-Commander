#include "\AC\defines\commonDefines.inc"
#include "\a3\Ui_f\hpp\defineCommonGrids.inc"
// ---------------------
// INIT STRATEGIC UI
// ---------------------

// 1. Recognize type of player (commander x non-commander), side
// 2. Show him proper controls
// 3. Show proper controls at the start

// Server side, global UI objects
// This function is big pile of shit, really
ACF_initCommandUI = {
	[] call ACF_ui_initCommandUI;

	// Load correct values into battalionInfo and buyList
	[] call ACF_ui_updateBattalionInfo;
	[] call ACF_ui_addMissionButtonHandlers;
	[] call ACF_ui_initBuyList;
	[] call ACF_ui_initSupportList;

	[] spawn {
		while {true} do {
			[] call ACF_ui_updateCommandUI;
			sleep 1;
		};
	};
};

// Command UI defines: TODO move to defines folder
ACF_ui_initCommandUI = {
	//disableSerialization;
	private _colorSidePlayer = (side group player) call BIS_fnc_sideColor;
	_colorSidePlayer set [3,0.8];

	// Group info
	private _table = (findDisplay 12) ctrlCreate ["RscAcGroupInfo", -1];
	USVAR("AC_groupInfo",_table);
	private _rankIcon = "\A3\Ui_f\data\GUI\Cfg\Ranks\captain_gs.paa";
	private _typeIcon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
	private _texts = ["",""];

	for "_i" from 0 to 1 do {
		private _header = ctAddHeader _table;
		(_header#1) params ["_background","_col1","_col2","_col3"];
		_background ctrlSetBackgroundColor _colorSidePlayer;
		_col2 ctrlSetText (_texts select _i);
		if (_i == 1) then {
			_col1 ctrlSetText _rankIcon;
			_col1 ctrlSetPosition [0 + 5 * pixelW, 0 + 15 * pixelW];
			_col1 ctrlCommit 0;
			_col2 ctrlSetTextColor [1, 1, 1, 0.6];
			_col2 ctrlSetFontHeight 0.03;
			_col3 ctrlSetText "SWITCH";
			_col3 ctrlSetTooltip "Switch into leader of the group";
			_col3 ctrlAddEventHandler ["MouseButtonClick",{[AC_selectedGroups select 0] call ACF_ui_buttonSwitchPressed}];
			private _pos = ctrlPosition _col3;
			_col3 ctrlSetPosition [(_pos select 0) - 5 * pixelW, (_pos select 1) - 10 * pixelH];
			_col3 ctrlCommit 0;
		} else {
			_col3 ctrlEnable false;
		};
	};

	private _ammoIcon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\rearm_ca.paa";
	private _menIcon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa";
	private _vehicleIcon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\car_ca.paa";

	private _texts = ["0","0"];
	private _icons = [_menIcon, _vehicleIcon];
	private _buttonText = ["Resupply",""];

	for "_i" from 0 to 1 do {
		private _row = ctAddRow _table;
		(_row#1) params ["_background","_col1","_col2","_col3"];

		if (_i == 0) then {
			_col3 ctrlAddEventHandler ["MouseButtonClick",{[] call ACF_ui_reinforceOrdered}];
		};
		_background ctrlSetBackgroundColor DEFAULT_BACKGROUND;
		_col1 ctrlSetTextColor [1.0, 1.0, 1.0, 1.0];
		_col1 ctrlSetText (_icons#_i);
		_col3 ctrlSetText (_buttonText#_i);
		_col3 ctrlEnable false;
	};

	// Base info
	private _table = (findDisplay 12) ctrlCreate ["RscAcBaseInfo", -1];
	USVAR("AC_baseInfo",_table);
	private _baseIcon = "\a3\Ui_f\data\Map\GroupIcons\badge_gs.paa";
	private _texts = ["Omicron","Base"];

	for "_i" from 0 to 1 do {
		private _header = ctAddHeader _table;
		(_header select 1) params ["_background","_col1","_col2","_col3"];
		_background ctrlSetBackgroundColor _colorSidePlayer;

		_col2 ctrlSetText (_texts select _i);

		_background ctrlSetBackgroundColor _colorSidePlayer;

		if (_i == 1) then {
			_col1 ctrlSetText _baseIcon;
			_col1 ctrlSetPosition [0 + 5 * pixelW, 0 + 15 * pixelW];
			_col1 ctrlSetScale 1.1;
			_col1 ctrlCommit 0;
			_col2 ctrlSetTextColor [1,1,1,0.5];
			_col2 ctrlSetFontHeight 0.03;

			_col3 ctrlSetText "100%";
			_col3 ctrlSetPosition [0 + 180 * pixelW, 0 + 15 * pixelW];
			_col3 ctrlSetScale 1.1;
			_col3 ctrlCommit 0;

		};
	};

	private _row = ctAddRow _table;
	(_row select 1) params ["_background","_col1","_col2","_col3"];
	_background ctrlSetBackgroundColor DEFAULT_BACKGROUND;
	_col1 ctrlSetText "\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa";
	_col1 ctrlSetTextColor [1.0, 1.0, 1.0, 1.0];
	_col2 ctrlSetText "-1 Soldiers";
	_col3 ctrlSetText "Reinforce";
	_col3 ctrlSetTooltip "Reinforce base manpower";
	_col3 ctrlEnable false;
	_col3 ctrlAddEventHandler ["MouseButtonClick",{[] call ACF_ui_baseReinforceOrdered}];

	// ActionsList
	private _table = (findDisplay 12) ctrlCreate ["RscAcActionsList", -1];
	USVAR("AC_actionsList",_table);
	private _icons = [
		"\a3\Ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa",
		"\a3\Ui_f\data\IGUI\Cfg\simpleTasks\types\attack_ca.paa",
		"\a3\Ui_f\data\IGUI\Cfg\simpleTasks\types\scout_ca.paa",
		"\a3\Ui_f\data\IGUI\Cfg\simpleTasks\types\truck_ca.paa",
		"\a3\Ui_f\data\IGUI\Cfg\simpleTasks\types\use_ca.paa",
		"\a3\Ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa"
	];
	private _texts = ["Fast Move", "Move","Stealth Move","Get in","Land","Fire mission"];
	private _tooltips = [
		"Fast move, disregarding combat.",
		"Normal movement, ready to fight",
		"Slow and silent movement, don't fire unless fired upon",
		"Interaction with vehicle",
		"Land the aircraft",
		"Fire at position"

	];

	for "_i" from 0 to (count _texts) - 1 do
	{
		private _row = ctAddRow _table;
		(_row select 1) params ["_background","_col1","_col2"];
		_background ctrlSetBackgroundColor DEFAULT_BACKGROUND;
		_col1 ctrlSetText (_icons select _i);
		_col1 ctrlSetTextColor [1.0, 1.0, 1.0, 1.0];
		_col2 ctrlSetText toUpper (_texts select _i);
		_col2 ctrlSetTooltip (_tooltips select _i);
	};

	// Battalion bar
	private _table = (findDisplay 12) ctrlCreate ["RscAcBattalionInfo", -1];
	USVAR("AC_battalionInfo",_table);
	private _header = ctAddHeader _table;
	(_header select 1) params ["_background","_col1","_col2"];

	_background ctrlSetBackgroundColor _colorSidePlayer;
	_col1 ctrlSetText "\A3\Ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";
	_col2 ctrlSetText "Battalion Resources";

	private _row = ctAddRow _table;
	(_row select 1) params ["_background","_rpIcon","_rpText","_newRpText","_requisitionButton"];
	_background ctrlSetBackgroundColor _colorSidePlayer;

	_rpIcon ctrlSetText "a3\Ui_f\data\IGUI\Cfg\Actions\getincommander_ca.paa";
	_newRpText ctrlSetText "00:00 + 5";
	_newRpText ctrlSetTextColor [1,1,1,0.5];
	_requisitionButton ctrlSetText "REQUISITION";
	_requisitionButton ctrlSetTooltip "Request new units";
	(ctrlPosition _requisitionButton) params ["_px","_py"];
	_requisitionButton ctrlSetPosition [_px + 0 * pixelW, _py - 11 * pixelH];
	_requisitionButton ctrlCommit 0;

	_requisitionButton ctrlAddEventHandler ["MouseButtonClick",{[] call ACF_ui_RequisitionButton}];

	// Disable buying by subordinate
	if (IS_COMMANDER) then {_requisitionButton ctrlEnable true};

	// Buy list
	private _table = (findDisplay 12) ctrlCreate ["RscAcBuyList", -1];
	USVAR("AC_buyList",_table);
	private _header = ctAddHeader _table;
	(_header select 1) params ["_background","_col1","_col2"];

	_background ctrlSetBackgroundColor _colorSidePlayer;
	_col1 ctrlSetText "\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa";
	_col2 ctrlSetText "Request Reinforcements";

	// Supports list
	private _table = (findDisplay 12) ctrlCreate ["RscAcBuyList", -1];
	USVAR("ac_supportsList",_table);
	private _header = ctAddHeader _table;
	(_header select 1) params ["_background","_col1","_col2"];
	_background ctrlSetBackgroundColor _colorSidePlayer;
	_col1 ctrlSetText "\A3\ui_f\data\igui\cfg\simpleTasks\types\destroy_ca.paa";
	_col2 ctrlSetText "Request Supports";

	// Keep only battalion bar shown
	{
		UGVAR(_x) ctrlShow false;
	} forEach ["AC_groupInfo","AC_baseInfo","AC_actionsList","AC_buyList","ac_supportsList"];

	// Commander bar
	private _table = (findDisplay 12) ctrlCreate ["RscAcCommanderInfo", -1];
	USVAR("AC_commanderInfo",_table);
	private _header = ctAddHeader _table;
	(_header select 1) params ["_background","_button"];
	_background ctrlSetBackgroundColor _colorSidePlayer;
	_button ctrlAddEventHandler ["MouseButtonClick",{[_this select 0] call ACF_ui_switchCommand}];
	_button ctrlAddEventHandler ["MouseEnter",{[_this select 0] call ACF_ui_setSelectionText}];
	_button ctrlAddEventHandler ["MouseExit",{[_this select 0] call ACF_ui_showCommandName}];
	[_button] call ACF_ui_showCommandName;

	// Score info
	private _table = (findDisplay 12) ctrlCreate ["RscAcScoreInfo", -1];
	USVAR("AC_scoreInfo",_table);
	private _header = ctAddHeader _table;
	(_header select 1) params ["_background","_flag1","_text1","_timer","_text2","_flag2"];
	_background ctrlSetBackgroundColor _colorSidePlayer;

	AC_battalions params ["_bat1","_bat2"];
	private _type = _bat1 getVariable "type";
	private _side1 = GVAR(_bat1,"side");
	_text1 ctrlSetText str (count (AC_bases select {GVAR(_x,"side") == _side1}));

	private _module1 = GVARS(_bat1,"module",objnull);
	if (isNull _module1) then {
		_flag1 ctrlSetText (getText (configfile >> "AC" >> "Battalions" >> _type >> "icon"));
	} else {
		_flag1 ctrlSetText GVAR(_module1,"BatIcon");
	};

	private _type = (_bat2) getVariable "type";
	private _side2 = GVAR(_bat2,"side");
	_text2 ctrlSetText str (count (AC_bases select {GVAR(_x,"side") == _side2}));

	private _module2 = GVARS(_bat2,"module",objnull);
	if (isNull _module2) then {
		_flag2 ctrlSetText (getText (configfile >> "AC" >> "Battalions" >> _type >> "icon"));
	} else {
		_flag2 ctrlSetText GVAR(_module2,"BatIcon");
	};

	//_timer ctrlSetText ([3000, "HH:MM:SS"] call BIS_fnc_secondsToString);
};

// Add data into the buy list. Rows, names and prices
ACF_ui_initBuyList = {
	private _data = GVAR(AC_playerBattalion,"ec_unitList");
	private _unitTable = [AC_playerBattalion] call ACF_ec_unitTable;
	private _dataCount = count _data;
	USVAR("AC_buyH",_dataCount + 1);
	private _buyList = UGVAR("ac_buyList");

	// Attempt to do dynamic positioning of the buy list
	private _pos = ctrlposition _buyList;
	_pos set [1, safeZoneY + safeZoneH - (4 + _dataCount) * GUI_GRID_H]; // Y coordinates
	_pos set [3, GUI_GRID_H * (_dataCount + 1)]; // Table height
	_buyList ctrlSetPosition _pos;
	_buyList ctrlCommit 0;

	for "_i" from 0 to (count _data) - 1 do {
		private _row = ctAddRow _buyList;
		(_row#1) params ["_backgroud","_count","_text","_rp","_icon","_button"];
		(_data#_i) params ["_type","_cost","_name","_tooltip"];
		_backgroud ctrlSetBackgroundColor DEFAULT_BACKGROUND;

		_rp ctrlSetText str _cost;
		_icon ctrlSetText "a3\Ui_f\data\IGUI\Cfg\Actions\getincommander_ca.paa";
		_icon ctrlSetScale 0.8;
		_icon ctrlCommit 0;
		_text ctrlSetText _name;
		_count ctrlSetText format ["%1/%1",_unitTable#_i#1];
		_count ctrlSetTextColor [1,1,1,0.4];
		_count ctrlSetScale 0.8;
		_count ctrlCommit 0;

		_button ctrlSetText "REQUEST";
		_button ctrlSetTooltip _tooltip;
		_button ctrlAddEventHandler ["MouseButtonClick",{
			[] spawn ACF_ui_buttonRequisitionPressed;
		}];
	};
};

ACF_ui_initSupportList = {
	private _data = GVARS(AC_playerBattalion,"ec_supportsList",[]);
	private _unitTable = [AC_playerBattalion] call ACF_ec_unitTable;
	private _dataCount = count _data;
	private _list = UGVAR("ac_supportsList");
	private _height = _dataCount + 1;

	// Attempt to do dynamic positioning of the buy list
	private _pos = ctrlposition _list;
	_pos set [1, safeZoneY + safeZoneH - (3 + UGVARS("ac_buyH",10) + _height) * GUI_GRID_H]; // Y coordinates
	_pos set [3, GUI_GRID_H * _height]; // Table height
	_list ctrlSetPosition _pos;
	_list ctrlCommit 0;

	for "_i" from 0 to (_dataCount) - 1 do {
		private _row = ctAddRow _list;
		(_row#1) params ["_backgroud","_count","_text","_rp","_icon","_button"];
		(_data#_i) params ["_name","_tooltip","_cost","_currentTimeout"];
		_backgroud ctrlSetBackgroundColor DEFAULT_BACKGROUND;

		_rp ctrlSetText str _cost;
		_icon ctrlSetText "a3\Ui_f\data\IGUI\Cfg\Actions\getincommander_ca.paa";
		_icon ctrlSetScale 0.8;
		_icon ctrlCommit 0;
		_text ctrlSetText _name;
		_count ctrlSetText ([_currentTimeout] call ACF_timer);
		_count ctrlSetTextColor [1,1,1,0.4];
		_count ctrlSetScale 0.8;
		_count ctrlCommit 0;

		_button ctrlEnable false;
		_button ctrlSetText "REQUEST";
		_button ctrlSetTooltip _tooltip;
		_button ctrlAddEventHandler ["MouseButtonClick",{
				[] spawn ACF_ui_buttonSupportsPressed;
		}];
	};
};
