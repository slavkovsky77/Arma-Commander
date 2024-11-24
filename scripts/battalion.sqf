#include "\AC\defines\commonDefines.inc"

/*
	Battalion synchronized variables:

*/

// Return battalion for your side
ACF_battalion = {
	params ["_side"];
	if (_side isEqualType 0) then {_side = [_side] call AC_fnc_numberToSide};
	private _i = (AC_battalions findIf {_x getVariable "side" isEqualTo _side});
	if (_i == -1) exitWith {objNull};
	AC_battalions#_i // This is return value
};

ACF_createCustomBattalion = {
	params ["_module"];

	// Init customBatModule - register reserves
	private _units = [];
	private _loadouts = [];
	private _customLO = GVARS(_module,"Loadouts",false);
	{
		{
			_units pushBack (typeOf _x);
			if (_customLO) then { _loadouts pushBack (getUnitLoadout _x); };
			deleteVehicle _x;
		} forEach (units group _x);
	} forEach ((synchronizedObjects _module) select {_x isKindOf "Man"});
	SVARG(_module,"reserves",_units);

	// Save loadouts if needed
	if (_customLO) then {
		SVARG(_module,"unitLoadouts",_loadouts);
	};

};

ACF_initBattalion = {
	params ["_battalion"];
	private _side = [GVAR(_battalion,"side")] call AC_fnc_numberToSide;
	SVARG(_battalion,"side",_side);
	private _type = [_battalion, _side] call ACF_battalionType;

	[_battalion, _side] call ACF_setMultipliers;

	// Register custom battalions
	private _customBatModule = objNull;
	if (_type == "Custom") then {
		private _customBattalions = entities "AC_ModuleCustomBattalion";
		private _i = _customBattalions findIf {[GVAR(_x,"side")] call AC_fnc_numberToSide == _side};
		if (_i > -1) then {
			_customBatModule = _customBattalions#_i;
		};
	};
	if (_type == "Custom" && isNull _customBatModule) exitWith {
		["Create Custom Battalion Module not found!"] call BIS_fnc_error;
	};

	// Write variables into object
	_battalion setVariable ["attacks",[]];
	_battalion setVariable ["requestQueue",0];
	if (isNull _customBatModule) then {
		private _batConfig = configfile >> "AC" >> "Battalions" >> _type;
		_battalion setVariable ["faction",getText (_batConfig >> "faction")];
		_battalion setVariable ["flag",getText (_batConfig >> "flag")];
	} else {
		_battalion setVariable ["faction",GVAR(_customBatModule,"faction"),true];
		_battalion setVariable ["flag",GVAR(_customBatModule,"flag"),true];
		_battalion setVariable ["module",_customBatModule,true];
	};

	// Initialize list buy list (including tooltip). Format: Classname, cost, name, tooltip
	private _list = [];
	if (isNull _customBatModule) then {
		{
			private _grpConf = configfile >> "AC" >> "Groups" >> configName _x;
			_list pushBack [configName _x, getNumber (_x >> "cost"),getText (_grpConf >> "name"), getText (_grpConf >> "tooltip")];
		} forEach ("true" configClasses (configfile >> "AC" >> "Battalions" >> GVAR(_battalion,"type") >> "combatElement"));
	};

	// Find out if there are any custom groups to add
	{
		if (_side == [GVAR(_x,"side")] call AC_fnc_numberToSide) then {
			_list pushBack [GVAR(_x,"typeStr"), GVAR(_x,"cost"),GVAR(_x,"name"), GVAR(_x,"tooltip")];
		};
	} forEach (entities "AC_ModuleRegisterGroup");

	[_battalion,_type] call ACF_registerSupports;

	//init unit table at server start to prevent UI mistmatch, possibly merge unittable and unit list later.
 	private _table = [_battalion] call ACF_ec_unitTable;

	SVARG(_battalion,"ec_unitList",_list);
};

// Check if battalion type was overriden
ACF_battalionType = {
	params ["_battalion","_side"];
	private _param = "BattalionInd";
	if (_side == west) then {_param ="BattalionWest"};
	if (_side == east) then {_param = "BattalionEast"};

	private _type = [_param,-1] call BIS_fnc_getParamValue;
	if (_type == -1) then {
		_type = GVAR(_battalion,"type");
	};

	switch (_type) do {
		case INFANTRY_O: 		{_type = "Infantry_O"};
		case TANK_O: 			{_type = "Tank_O"};
		case SPETSNAZ_O: 		{_type = "Spetsnaz_O"};
		case RECON_O: 			{_type = "Recon_O"};
		case MILITIA_FIA: 		{_type = "Militia_FIA"};
		case RECON_B:			{_type = "Recon_B"};
		case TANK_B: 			{_type = "Tank_B"};
		case TANK_B_W: 			{_type = "Tank_B_W"};
		case MECHANIZED_I: 		{_type = "MECHANIZED_I"};
		case MILITIA_SYNDIKAT:	{_type = "Militia_Syndikat"};
		case LDF:				{_type = "Battalion_LDF"};
		case CUSTOM:			{_type = "Custom"};
	};
	SVARG(_battalion,"type",_type);
	_type
};

ACF_setMultipliers = {
	params ["_battalion","_side"];
	private _income = 1;
	private _skill = 1;
	private _strat = 1;
	switch (_side) do {
		case WEST: {
			_income = (["Income_West",1] call BIS_fnc_getParamValue) * GVAR(AC_gameModule,"IncomeMultiplier");
			_skill = ["Skill_West",1] call BIS_fnc_getParamValue;
			_strat = ["Strategic_Skill_West",1] call BIS_fnc_getParamValue;
		};
		case EAST: {
			_income = (["Income_East",1] call BIS_fnc_getParamValue) * GVAR(AC_gameModule,"IncomeMultiplier");
			_skill = ["Skill_East",1] call BIS_fnc_getParamValue;
			_strat = ["Strategic_Skill_East",1] call BIS_fnc_getParamValue;
		};
		case INDEPENDENT: {
			_income = (["Income_Indep",1] call BIS_fnc_getParamValue) * GVAR(AC_gameModule,"IncomeMultiplier");
			_skill = ["Skill_Indep",1] call BIS_fnc_getParamValue;
			_strat = ["Strategic_Skill_Indep",1] call BIS_fnc_getParamValue;
		};
	};
	SVARG(_battalion,"incomeMultiplier",_income);
	SVARG(_battalion,"skillMultiplier",_skill);
	SVARG(_battalion,"stratMultiplier",_strat);
};

// Register player group into battalion
ACF_initHqElement = {
	params ["_group","_battalion","_side"];
	if (_group in AC_operationGroups) exitWith {};

	private _type = "";
	switch (_side) do {
		case WEST: 			{_type = "B_hqSquad"};
		case EAST: 			{_type = "O_hqSquad"};
		case RESISTANCE:	{_type = "I_hqSquad"};
	};

	// Initialize group:
	private _data = [_type,"Command",0.4];
	SEND_GROUP_DATA(_group,_data);
	SVARG(_battalion,"hqElement",_group);
};

// Return all bases that are neighboring different side
ACF_borderBases = {
	params ["_side"];
	private _bases = [];
	private _sideBases = AC_bases select {GVAR(_x,"side") == _side};
	private _color = switch (_side) do {
	    case WEST: { "Wdetected" };
	    case EAST: { "Edetected" };
	    case RESISTANCE: { "Idetected" };
	};
	{
		if (GVARS(_x,"neighbors",[]) findIf {GVAR(_x,"side") != _side && GVARS(_x,_color,false)} > -1) then {
			_bases pushbackunique _x;
		};
	} forEach _sideBases;

	// All known non-side bases that are neighboring the side
	{
		if (GVARS(_x,"neighbors",[]) findIf {GVAR(_x,"side") == _side} > -1 && {GVARS(_x,_color,false)} ) then {
			_bases pushbackunique _x;
		};
	} forEach (AC_bases select {GVAR(_x,"side") != _side});

	//fallback: if no known border bases, then all non-side bases are counted
	if (count _bases < 1) then {
		{
			if ( GVARS(_x,_color,false) ) then {
				_bases pushbackunique _x;
			};
		} forEach (AC_bases select {GVAR(_x,"side") != _side});
	};

	_bases
};

// Total strength of all COMBAT units (might get updated later)
// NOT USED ATM
ACF_ai_battalionStrength = {
	params ["_battalion"];

	// TODO: Do I want to count also artillery?
	private _allGroups = [_battalion] call ACF_combatGroups;
	private _totalStrength = 0;

	// Current combat effectiveness
	{
		_totalStrength = _totalStrength + ([_x] call ACF_ai_groupStrength);
	} forEach _allGroups;

	_battalion setVariable ["strength", _totalStrength];
	_totalStrength
};