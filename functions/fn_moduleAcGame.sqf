//disableSerialization;
private _mode = param [0,"",[""]];
private _input = param [1,[],[[]]];
private _module = _input param [0,objNull,[objNull]];

switch _mode do {
	case "init": {

		if (is3den) exitWith {};

		// Execute the game mode
		[] execVM "\AC\scripts\init_common.sqf";
	};
	case "attributesChanged3DEN": {
	};
	case "registeredToWorld3DEN": {
	};
	case "unregisteredFromWorld3DEN": {
	};
	case "connectionChanged3DEN": {
	};
};
