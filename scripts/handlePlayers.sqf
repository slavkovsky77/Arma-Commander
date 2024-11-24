#include "\AC\defines\commonDefines.inc"

/*
	Handle players in players:
		Init
		Switching to different unit
		Commanding - connecting and disconnecting
*/

ACF_registerUnitToHq = {
	params ["_unit", "_group"];
	if (group _unit == _group) exitWith {};
	[_unit] join _group;
};

// Switch between units and handle all transitions
// All guards for switching to correct unit should been already handled
// Function must be spawned, not called!
ACF_switchToUnit = {
	params ["_unit", "_timeout"];
	["Switching to new unit: %1",_unit] call BIS_fnc_logFormat;
	_timeout = (_timeout - 2) max 0;
	private _side = side _unit;
	private _rank = toLower (rank _unit);
	private _role = getText (configFile >> "CfgVehicles" >> typeOf _unit >> "displayName");
	private _groupType = [GVAR(group _unit,"typeStr"),"name"] call ACF_getGroupString;

	private _leaderRole = "Leader";
	if (leader _unit != _unit) then {_leaderRole = "Member of"};
	private _text = format ["<t size='3'>%2<br/>%1<br/>%3 of %4, %5 </t>",_role,GVARS(_unit,"#name",name _unit),_leaderRole, GVAR(group _unit,"callsign"),_groupType];

	// Remove switch action from the unit you are leaving
	player removeAction GVARS(player,"#switchAction",-1);

	// Effects before switching: Black screen and soldier's info
	1 fadeSound 0;
	"black" cutText ["", "BLACK OUT", 1, true, true];
	sleep 1;
	openMap false;
	"black" cutText ["", "BLACK FADED", 100, true, true];
	"aa" cutText [_text, "BLACK OUT", 1, true, true];
	sleep 2;

	// Transition of player character
	sleep _timeout;
	BIS_DeathBlur ppEffectAdjust [0.0];
	BIS_DeathBlur ppEffectCommit 0.0;

	"aa" cutText [_text, "BLACK IN", 1, true, true];
	sleep 1;
	"black" cutText ["", "BLACK IN", 1, true, true];
	1 fadeSound 1;

	selectPlayer _unit;
	[] call ACF_addSwitchAction;

	// Backup: If unit was killed again:
	sleep 5;
	if (!alive _unit) then {
		[_unit, _side] call ACF_selectRespawnUnit;
	};
};

// Server side respawn selection
// Make sure no other player attempted to become this unit already
ACF_selectRespawnUnit = {
	params["_killed","_side"];
	private _battalion = [_side] call ACF_battalion;
	private _combatGroups = [_side] call ACF_combatGroups;
	private _unitToSwitch = objNull;
	private _commandGroup = GVARS(_battalion,"hqElement",grpNull);

	if (_commandGroup isEqualType []) then {
		if (count _commandGroup > 0) then {
			_commandGroup = _commandGroup#0;
		} else {
			_commandGroup = grpNull;
		};
	};

	private _commandIndex = (units _commandGroup) findIf {alive _x && !isPlayer _x && !GVARS(_x,"reserved",false)};

	//add storage for personal unit here and default to that

	if (_commandIndex > -1) then {
		_unitToSwitch = (units _commandGroup) select _commandIndex;
	} else {
		_i = _combatGroups findIf {alive leader _x && {!isPlayer leader _x} && {GVARS(_x,"type",-1) != TYPE_ARTILLERY} && {!GVARS(leader _x,"reserved",false)}};
		// Empty leader position
		if (_i > -1) then {
			_unitToSwitch = leader (_combatGroups#_i);
		} else {
			private _allCombatUnits = [];
			{_allCombatUnits append (units _x select {alive _x && !isPlayer _x && {!GVARS(_x,"reserved",false)} && {GVARS(group _x,"type",-1) != TYPE_ARTILLERY}})} forEach _combatGroups;
			if (count _allCombatUnits > 0) then {
				_unitToSwitch = _allCombatUnits#0;
			} else {
				["No unit for respawn!"] call BIS_fnc_error;
			};
		};
	};

	if (!isNull _unitToSwitch) then {
		private _timeout = 2;
		SVARG(_unitToSwitch,"reserved",true);

		// Send unit's complete name before switching
		_unitToSwitch setVariable ["#name",name _unitToSwitch, owner _killed];

		[_unitToSwitch, _timeout] remoteExec ["ACF_switchToUnit",_killed];
		sleep 3;
		SVARG(_unitToSwitch,"reserved",false);
	} else {
		sleep 2;
		true remoteExecCall ["openMap",_killed];
	};
};

ACF_addSwitchAction = {
	private _id = player addAction ["SWITCH to group member", {[cursorObject,player] remoteExecCall ["ACF_s",2]}, nil, 1.5, true, true, "", "group cursorObject == group _this && alive cursorObject && !isPlayer cursorObject", 20];
	SVARG(player,"#switchAction",_id);
};

// -----------------------
// ADD HANDLERS FOR KILLED UNITS
// -----------------------

if (isServer) then {
	addMissionEventHandler ["EntityKilled",{
		params ["_killed","_kiler"];

		private _side = side group _killed;

		if (isPlayer _killed) then {
			[_killed, _side] spawn ACF_selectRespawnUnit;
		};

		[_killed] call AC_grp_handleKilledUnit;
		[_killer,_killed] call ACF_grp_addGroupXp;
	}];
};