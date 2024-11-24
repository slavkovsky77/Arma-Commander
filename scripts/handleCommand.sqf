#include "\AC\defines\commonDefines.inc"

// Handle commander interface

// Assign commanders to battalion
ACF_com_initCommanders = {
	{
		private _side = GVAR(_x,"side");
		private _i = allPlayers findIf {side group _x == _side};
		private _name = "";
		if (_i > -1) then {_name = name (allPlayers#_i)};
		SVARG(_x,"#commander",_name);
	} forEach AC_battalions;
};

ACF_com_handleDisconnect = {
	params ["_id", "_uid", "_name", "_owner"];
	private _leaderIndex = AC_battalions findIf {GVARS(_x,"#commander","") == _owner};
	if (_leaderIndex > -1) then {
		[AC_battalions#_leaderIndex] call ACF_com_transferCommand;
	};
};

ACF_com_transferCommand = {
	params["_battalion",["_leavingPlayer",objNull]];
	private _side = GVAR(_battalion,"side");

	private _name = "";
	private _i = allPlayers findIf {side group _x == _side &&
		!GVARS(_x,"#leftCommand",false)
	};
	if (_i > -1) then {
		private _unit = allPlayers#_i;
		private _otherSideUnits = (allPlayers select {side group _x == _side}) - [_unit];
		_name = name _unit;
		if(AC_sharedCommanding) then {
			private _leaverName = name _leavingPlayer;
			SEND_NOTIFICATION(NN_COMMANDER_LEAVE,_leaverName,_unit);
			SEND_NOTIFICATION(NN_COMMANDER_LEAVE,_leaverName,_otherSideUnits);
		} else {
			SEND_NOTIFICATION(NN_COMMANDER_PLAYER,"",_unit);
			SEND_NOTIFICATION(NN_COMMANDER,_name,_otherSideUnits);
		};
	} else {
		SEND_NOTIFICATION(NN_COMMANDER_AI,"",(allPlayers select {side group _x == _side}));
	};

	SVARG(_battalion,"#commander",_name);
	DBG(["Transferring command %1", _name]);
};

ACF_com_takeCommand = {
	params["_battalion","_player"];

	private _side = GVAR(_battalion,"side");
	private _name = name player;
	SVARG(player,"#leftCommand",false);
	private _otherSideUnits = (allPlayers select {side group _x == _side}) - [_player];

	if(AC_sharedCommanding) then {
		SEND_NOTIFICATION(NN_COMMANDER_PLAYER_S,"",_player);
		SEND_NOTIFICATION(NN_COMMANDER_S,_name,_otherSideUnits);
	} else {
		SEND_NOTIFICATION(NN_COMMANDER_PLAYER,"",_player);
		SEND_NOTIFICATION(NN_COMMANDER,_name,_otherSideUnits);
	};
	SVARG(_battalion,"#commander",_name);
	DBG(["Transferring command %1", _name]);
};