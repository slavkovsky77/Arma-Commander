#include "\AC\defines\commonDefines.inc"

/*
	Basic command UI events.
	Mostly if button was pressed, it will be handled by these functions:
*/

// Handle pressing switch button
ACF_ui_buttonSwitchPressed = {
	//disableSerialization;
	params ["_group"];

	// Find unit to switch into:
	private _units = units _group select {alive _x};
	private _freeUnits = _units select {!isPlayer _x};
	private _unit = objNull;
	playSound "FD_CP_Clear_F";

	if (_freeUnits findIf {leader _group == _x} > -1) then {
		_unit = leader _group;
	} else {
		if (count _freeUnits > 0) then {
			_unit = _freeUnits#0;
		};
	};

	if (!isNull _unit) then {
		[_unit,player] remoteExecCall ["ACF_s",2];
		//REQUEST_SWITCH(_unit);
	} else {
		// Disable switch button
		private _switchButton = (UGVAR("ac_groupInfo") ctHeaderControls 1) select 3;
		_switchButton ctrlEnable false;
	};
};

// Show or hide buy button
ACF_ui_buttonRequisitionPressed = {
	// Find out position of the button in the table
	private _battalion = AC_playerBattalion;

	// Center a screen and show drop zones
	AC_deployMode = true;
	[] call ACF_drawSpawnZones;

	waitUntil {AC_markerPlaced};

	private _pos = [];
	if (AC_dropzone != "" && AC_markerPlaced) then {
		_pos = getMarkerPos AC_dropzone;
	} else {
		private _bases = [AC_playerSide] call ACF_findSpawnBases;
		_pos = getPosWorld (selectRandom _bases);
	};

	private _index = (ctCurSel UGVAR("ac_buyList"));
	[_battalion, _index,_pos] remoteExec ["ACF_ec_orderGroup",2];

	AC_deployMode = false;
	[] call ACF_eraseSpawnZones;
	AC_markerPlaced = false;

};

ACF_ui_reinforceOrdered = {
	if (count AC_selectedGroups == 0 || {isNull (AC_selectedGroups#0)}) exitWith {};
	private _group = AC_selectedGroups#0;
	playSound "FD_CP_Clear_F";

	// Disable the reinforce button
	((UGVAR("AC_groupInfo") ctRowControls 0)#3) ctrlEnable false;

	// TODO: This issue needs really a proper handling.
	// Prevent buying a new tank until the old one is destroyed or damaged beyond repair. How can I do it?

	[_group,AC_playerBattalion,GVARS(_group,"resupplyCost",10)] remoteExec ["ACF_resupplyGroup",2];
};

ACF_ui_baseReinforceOrdered = {
	if (count AC_selectedGroups == 0 || {isNull (AC_selectedGroups#0)}) exitWith {};
	private _base = AC_selectedGroups#0;
	_base = leader _base;
	playSound "FD_CP_Clear_F";

	[_base,AC_playerBattalion] remoteExec ["ACF_ui_baseReinforce",2];
};

// @TODO: Manage command permissions
// There also must be a list of commanders, maybe even a local variable showing if you are commanding or not
SVARG(player,"#leftCommand",false);

ACF_ui_switchCommand = {
	params["_button"];

	// Taking command need to be local to proper transferral of commands
	if(IS_COMMANDER) then {
		SVARG(player,"#leftCommand",true);
		//[AC_playerBattalion] remoteExecCall ["ACF_com_transferCommand",2,true];
		[AC_playerBattalion,player] call ACF_com_transferCommand;

		// Hide buy menu, take request button away
		UGVAR("AC_BuyList") ctrlShow false;
		UGVAR("AC_SupportsList") ctrlShow false;
		[] call ACF_ui_updateCommandUI;
	} else {
		if(AC_sharedCommanding || IS_AI_ENABLED(AC_playerBattalion)) then {
			//[AC_playerBattalion,player] remoteExecCall ["ACF_com_takeCommand",2,true];
			[AC_playerBattalion,player] call ACF_com_takeCommand;
		} else {
			DBG(["Cannot take command"]);
		}
	};
};

// @TODO: Maybe add a description?
ACF_ui_setSelectionText = {
	params["_button"];
	AC_commandButtonFocused = true;
	if (IS_COMMANDER) then {
		_button ctrlSetText "LEAVE COMMAND";
	} else {
		if(AC_sharedCommanding || IS_AI_ENABLED(AC_playerBattalion)) then {
			_button ctrlSetText "TAKE COMMAND";
		} else {
			_button ctrlSetText "CANNOT TAKE COMMAND";
		};
	};
};

ACF_ui_showCommandName = {
	params["_button"];
	AC_commandButtonFocused = false;

	private _name = GVARS(AC_playerBattalion,"#commander","");
	if (AC_sharedCommanding) exitWith {
		_button ctrlSetText "Shared Command";
	};
	if (IS_COMMANDER) exitWith {
		_button ctrlSetText "You are in command";
	};
	if (_name == "") exitWith {
		_button ctrlSetText "AI is in command";
	};

	_button ctrlSetText format ["%1 is in Command",_name];
};
