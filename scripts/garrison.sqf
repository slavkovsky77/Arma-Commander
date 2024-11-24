#include "\AC\defines\commonDefines.inc"
/*
	All garrison functionality.

	Synchronized variables:
	- Detected
	- Side
	- nSoldiers
	- nSoldiersOriginal
*/

//give a garrison all data it needs: side, troops number, postions
AC_gar_createGarrison = {
	params ["_base", "_troopCount",["_visible",true],["_slowDeploy",false]];
	private _side = _base getVariable "side";
	SVARG(_base,"deployed", DEPLOYED_FALSE);
	(group _base) setVariable ["Edetected", _visible, true]; //visibility for enemy
	(group _base) setVariable ["Wdetected", _visible, true]; //visibility for enemy
	(group _base) setVariable ["Idetected", _visible, true]; //visibility for enemy
	_base setVariable ["nSoldiersOriginal", _troopCount, true];

	if (_slowDeploy) then {
		SVARG(_base,"#slowDeployTime",time);
	};
};

AC_gar_deployGarrison = {
	params ["_base"];
	private _side = _base getVariable "side";
	private _battalion = [_side] call ACF_battalion;

	// If base changed size and got new reinforcements recently, they are deployed slowly in the base
	private _slowDeploy = false;
	if (time - GVARS(_base,"#slowDeployTime", -1000) < 60) then {
		_slowDeploy = true;
	};

	if (_base getVariable "deployed" != DEPLOYED_FALSE || _side == sideEmpty || _side == sideunknown) exitWith {};
	SVARG(_base,"deployed", DEPLOYED_BUSY);

	private _staticGroup = createGroup _side;

	_staticGroup deleteGroupWhenEmpty true;
	if !(local _staticGroup) then {
	    [_staticGroup, true] remoteExec ["deleteGroupWhenEmpty", groupOwner _staticGroup];
	};
	_base setVariable ["staticGroup", _staticGroup];
	_staticGroup setVariable ["base", _base];

	private _positions = _base getVariable ["gar_positions",[]];
	private _directions = _base getVariable ["gar_directions",[]];
	private _stances = _base getVariable ["gar_stances",[]];
	private _specialPos = _base getVariable ["gar_specialAtt",[]];
	private _nSoldiers = _base getVariable ["nSoldiers",0];

	private _soldierArray = [];


	private _skill = 0.4;
	private _module = GVARS(_battalion,"module",objNull);


	// Loadouts
	private _customLoadouts = GVARS(_module,"Loadouts",false);
	private _loadouts = [];
	if (_customLoadouts) then {
		_loadouts = GVARS(_module,"unitLoadouts",[]);
		if (count _loadouts == 0) then {_customLoadouts = false};
	};

	if (isNull _module) then {
		private _conf = configfile >> "AC" >> "Battalions" >> _battalion getVariable "type" >> "Reserves";
		_soldierArray = getArray (_conf >> "units");
		_skill = getNumber (_conf >> "skill");
	} else {
		_soldierArray = GVAR(_module,"reserves");
		//if (GVAR(_module,"Loadouts")) then {_loadouts =  GVAR(_module,"unitLoadouts"); };
		_skill = GVAR(_module,"skill");
	};
	_skill = _skill * GVARS(_battalion,"skillMultiplier",1);

	// Decide static dynamic counts
	private _dynamicCount = ceil (_nSoldiers * GARRISON_STATIC_DYNAMIC_RATIO);
	private _staticCount = _nSoldiers - _dynamicCount;

	//make sure there are not more static units than static positions
	private _positionsCount = count _positions;
	if (_staticCount > _positionsCount) then {
		_staticCountOriginal = _staticCount;
		_staticCount = _positionsCount;
		_dynamicCount = _dynamicCount + (_staticCountOriginal - _staticCount);
	};
	private _soldierNum = count _soldierArray - 1;


	private ["_selected", "_unit", "_gun", "_stance"];

	// Create dynamic group
	private _basePos = getPosATL _base;
	for "_i" from 1 to _dynamicCount do {
		if (_slowDeploy) then {
			// Wait until no enemies are nearby
			waitUntil{sleep 0.2; !GVARS(_base,"#contested",false)};
			sleep 10;
		} else {
			sleep SPAWN_TIMEOUT;
		};

		_selected = random _soldierNum;
		_unit = _staticGroup createUnit [_soldierArray#_selected, _basePos, [], 20,"FORM"];
		[_unit] joinSilent _staticGroup; //side fix
		_unit triggerDynamicSimulation true; //test
		_unit setSkill _skill;
		if (_customLoadouts) then {_unit setUnitLoadout (_loadouts#_selected);};

	};

	//create static group in correct positions and turrets
	for "_i" from 0 to (_staticCount - 1) do {
		if (_slowDeploy) then {
			// Wait until no enemies are nearby
			waitUntil{sleep 0.2; !GVARS(_base,"#contested",false)};
			sleep 10;
		} else {
			sleep SPAWN_TIMEOUT;
		};

		_selected = random _soldierNum;
		_unit = _staticGroup createUnit [_soldierArray#_selected, [100,100,100], [], 0,"CAN_COLLIDE"];
		[_unit] joinSilent _staticGroup; //side fix
		_unit triggerDynamicSimulation true; //test
		_unit setPosATL _positions#_i;
		_unit setSkill _skill;
		if (_customLoadouts) then {_unit setUnitLoadout (_loadouts#_selected);};

		//move soldier into turret or correct position and place
		if (!isNull (_specialPos select _i)) then {
			_gun = _specialPos select _i;
			_unit assignAsGunner _gun;
			_unit moveInGunner _gun;
		} else {
			_unit setPosATL (_positions select _i);
			_unit setDir (_directions select _i);
			_stance = _stances select _i;
			if (_stance != "UP") then {
				_unit setUnitPos _stance;
			};
		};
		_unit disableAI "PATH";
		_unit disableAI "MINEDETECTION";
		_unit disableAI "COVER";
	};

	//QRF Force, dynamic team will slowly seek out targets
    _staticGroup setCombatMode "RED";
	private _wp = _staticGroup addWaypoint [_base, 5];
	_wp setWaypointType "GUARD";
    _staticGroup allowFleeing 0;
	_staticGroup setSpeedMode "LIMITED";

	_base setVariable ["deployed", DEPLOYED_TRUE];
};

AC_gar_undeployGarrison = {
	params ["_base"];
	if (GVAR(_base,"deployed") != DEPLOYED_TRUE) exitWith {};
	_base setVariable ["deployed", DEPLOYED_BUSY];

	private _staticGroup = _base getVariable ["staticGroup",grpNull];

	private _aliveSoldierCount = ({alive _x} count units _staticGroup); // + ({alive _x} count units _dynamicGroup)
	//save current state of forces in base

	_base setVariable ["nSoldiers", _aliveSoldierCount, true];

	//delete all units + groups
	{
		sleep DESPAWN_TIMEOUT;
		deleteVehicle _x;
	} forEach units _staticGroup;

    _staticGroup deleteGroupWhenEmpty true;
	if !(local _staticGroup) then {
	    [_staticGroup, true] remoteExec ["deleteGroupWhenEmpty", groupOwner _staticGroup];
	};

	_base setVariable ["staticGroup", grpNull];
	SVARG(_base,"deployed", DEPLOYED_FALSE);
};

AC_gar_changeOwner = {
	// Change side, markers, soldier count
	params ["_base", "_side", "_soldierCount",["_notify",true]];

	private _modifier = 1;
 	private _battalion = [_side] call ACF_battalion;
	private _module = GVARS(_battalion,"module",objNull);
	private _resupplyCount = _soldierCount;
	if (isNull _module) then {
		private _conf = configfile >> "AC" >> "Battalions" >> _battalion getVariable "type" >> "Reserves";
		_modifier = getNumber (_conf >> "modifier");
		_resupplyCount = ceil (_soldierCount / _modifier / 2);
	} else {
		_modifier = GVARS(_module,"modifier",1);
		_resupplyCount = ceil (_soldierCount / _modifier / 2);
	};

	private _staticGroup = _base getVariable ["staticGroup",grpNull];
	//delete all units + groups
	{
		sleep DESPAWN_TIMEOUT;
		deleteVehicle _x;
	} forEach units _staticGroup;

    _staticGroup deleteGroupWhenEmpty true;
	if !(local _staticGroup) then {
	    [_staticGroup, true] remoteExec ["deleteGroupWhenEmpty", groupOwner _staticGroup];
	};

	_base setVariable ["side", _side, true];
	_base setVariable ["nSoldiers", 0, true];

	sleep 1;
	[_base,_side] call ACF_createFlag;

	if (_notify) then {
		private _texts = [_base getVariable "callsign", GVARS(([_side] call ACF_battalion),"faction", "unknown")];
		SEND_NOTIFICATION(NN_BASE_CAPTURED,_texts,0);
	};

	_base setVariable ["nSoldiers", _resupplyCount, true];
	[_base, _soldierCount, true,true] call AC_gar_createGarrison;
};