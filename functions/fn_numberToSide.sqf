params ["_number"];
if (_number isEqualType sideUnknown) exitWith {_number};

private _side = sideUnknown;
switch (_number) do {
	case 0: {_side = EAST};
	case 1: {_side = WEST};
	case 2: {_side = RESISTANCE};
	case 3: {_side = CIVILIAN};
	case 4: {_side = sideUnknown};
	case 5: {_side = sideEnemy};
	case 6: {_side = sideFriendly};
	case 7: {_side = sideLogic};
	case 8: {_side = sideEmpty};
	case 9: {_side = sideAmbientLife};
	default {
		["Number is not valid side"] call BIS_fnc_error;
	};
};
_side