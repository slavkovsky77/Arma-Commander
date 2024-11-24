#include "\AC\defines\commonDefines.inc"


// Library for optimized data sent on network:
// Functions have as short names as possible to shorten the message.
// Marcos using those functions will be much more readable

// Local part of group inicialization
// Called by macro SEND_GROUP_DATA(data)
AGD = {
	params ["_group","_data"];
	_data params ["_typeStr","_callsign","_skill"];

	//do not duplicate groups when server handles a JIP
	if (_group in AC_operationGroups) exitWith {};

	SVARG(_group,"callsign",_callsign);
	SVARG(_group,"typeStr",_typeStr);
	SVARG(_group,"skill",_skill);

	// Find data from config of the group
	private _module = MGVARS(_typeStr,objNull);
	if (!isNull _module) then {
		SVARG(_group,"marker",GVAR(_module,"icon"));
		SVARG(_group,"type",GVAR(_module,"type"));
	} else {
		private _groupConfig = configfile >> "AC" >> "Groups" >> _typeStr;
		SVARG(_group,"marker",getText (_groupConfig >> "icon"));
		SVARG(_group,"type",getNumber (_groupConfig >> "type"));
	};

	[_group] call ACF_ui_createGroupIcon;

	AC_operationGroups pushBack _group;

};

RGD = {
	params ["_group"];
	AC_operationGroups - [_group];
};

// Add data to object
ADO = {
	params ["_obj","_var","_data"];
	private _array = GVARS(_obj,_var,[]);
	_array pushBack _data;
	SVARG(_var,_array);
};

// Add data to missionNamespace
ADM = {
	params ["_var","_data"];
	private _array = MGVARS(_var,[]);
	_array pushBack _data;
	MSVARG(_var,_array);
};

// Remove data from object
RDO = {
	params ["_obj","_var","_data"];
	private _array = GVARS(_obj,_var,[]);

	// DeleteAt will change the variable itself, no need to setVar
	_array deleteAt (_array findIf {_x == _data});
};

RDM = {
	params ["_var","_data"];
	private _array = MGVARS(_var,[]);

	// DeleteAt will change the variable itself, no need to setVar
	_array deleteAt (_array findIf {_x == _data});
};

ACF_sendJipData = {
	params ["_client"]; // ID of client

	AC_operationGroups = AC_operationGroups - [grpNull]; // Make sure null groups are not sent

	{
		private _dataArray = [GVAR(_x,"typeStr"),GVAR(_x,"callsign"),GVAR(_x,"skill")];
		SEND_GROUP_DATA(_x,_dataArray);
	} forEach AC_operationGroups;

	[AC_endTimeServer] remoteExec ["ACF_runEndTimer",_client];

	// Base data are synced automatically
	// Send end timer
};

ACF_sendLoadData = {
	params ["_client"]; // ID of client

	[AC_endTimeServer] remoteExec ["ACF_runEndTimer",_client];

	// Base data are synced automatically
	// Send end timer
};

// Send notification to selected clients:
// Used by macro SEND_NOTIFICATION
NN = {
	params ["_type","_message"];
	private _text = "";

	// Message types:
	private _text = switch (_type) do {
		case NN_TIME_REMAINING: 	{format ["Time remaining: %1 minutes",_message]};
		case NN_BASE_ATTACKED:		{format ["Enemy is capturing %1!", _message]};
		case NN_BASE_CAPTURED: 		{format ["%1 captured by %2", _message#0,_message#1]};
		case NN_GROUP_LOST: 		{format ["Group %1 Lost", _message]};
		case NN_GROUP_KILLED: 		{"Enemy group wiped out"};
		case NN_GROUP_DETECTED: 	{"Enemy group detected"};
		case NN_BASE_DETECTED: 		{"Enemy base detected"};
		case NN_COMMANDER_PLAYER_S: {"You joined the command"};
		case NN_COMMANDER_S:		{_message + " joined the command"};
		case NN_COMMANDER_PLAYER: 	{"You are the commander"};
		case NN_COMMANDER_AI:		{"AI is in command"};
		case NN_COMMANDER_LEAVE:	{_message + " left the command"};
		case NN_COMMANDER: 			{_message + " is the commander"};
		case NN_CUSTOM:				{_message};
		default 					{_message};
	};

	["NewIntel",[_text]] call BIS_fnc_showNotification;
};

// Called with macro REQUEST_SWITCH(unit)
ACF_s = {
	params ["_unit","_originalUnit"];
	if (isPlayer _unit || GVARS(_unit,"reserved",false)) exitWith {["Trying to switch into occupied unit"] call BIS_fnc_log};

	// Check if ownership wasn't requested before
	private _timeout = 2;

	if (GVARS(_unit,"#switch",-10) < time + 2) then {

		SVARG(_unit,"#switch",time);

		SVARG(_unit,"#name",name _unit);
		//_unit setVariable ["#name",name _unit, _clientId];
		//helicopter crash on switch fix?
		//private _localityChanged = group _unit setGroupOwner owner _originalUnit;
		[_unit,_timeout] remoteExec ["ACF_switchToUnit",_originalUnit];
	};
};
