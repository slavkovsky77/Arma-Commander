params ["_vehicle"];

private _totalCurAmmo = 1;
_mags = magazinesAllTurrets _vehicle;
private _maxCount = 0;
{
	_x params ["_mag","_turret","_count"];
	_maxCount = (getNumber (configfile >> "CfgMagazines" >> _mag >> "count"));
	if (_count < _maxCount) then {
		_totalCurAmmo = _totalCurAmmo - ( (1-(_count / _maxCount)) / count _mags) ;
	};
} forEach _mags;

//return safe value
if (_totalCurAmmo < 0) exitWith {0};
_totalCurAmmo;