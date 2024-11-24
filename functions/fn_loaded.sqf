#include "\AC\defines\commonDefines.inc"
#include "\a3\Ui_f\hpp\defineCommonColors.inc"

addMissionEventHandler ["Loaded", {
	AC_Loaded = true;

	[] spawn {
		if(DEBUG_MODE) then {systemChat format ["loaded"]};

		[] spawn {
			waitUntil {time > 20 && !isNull (findDisplay 12)};
			// Place dropzone marker
			(findDisplay 12 displayctrl 51) ctrlAddEventHandler ["MouseButtonClick",{
				params ["_map","_button"];
				if (!AC_markerPlaced && AC_deployMode) then {
					private _mousePosWorld = _map posScreenToWorld getMousePosition;
					if (AC_deployMarkers findIf {getMarkerPos _x distance2D _mousePosWorld <= DEPLOY_RADIUS} > -1) then {
						AC_markerPlaced = true;
						playSound "addItemOk";
					} else {
						playSound "addItemFailed";
					};
				};
				if (AC_supportMode && AC_supportsPlaced#0 == 0) then {
					AC_supportsPlaced = _map posScreenToWorld getMousePosition;
				};
			}];

			(findDisplay 12 displayctrl 51) ctrlAddEventHandler ["Draw",{
				params ["_map"];
				if (AC_deployMode && !AC_markerPlaced) then {
					AC_dropzone setmarkerposlocal (_map posScreenToWorld getMousePosition);
				};
				if (AC_supportMode) then {
					private _radius = [] call ACF_getSupportRadius;
					_map drawEllipse [_map posScreenToWorld getMousePosition, _radius, _radius, 0, [0,0,0,1], "#(rgb,8,8,3)color(0,0,0,0.3)"];
				};
			}];
			addMissionEventHandler ["Map", {
				params ["_opened"];
				if (!_opened) then {
					[] call ACF_eraseSpawnZones;
					AC_deployMode = false;
					AC_markerPlaced = false;
					AC_supportsPlaced = [0,0,0];
					AC_supportMode = false;
				};
			}];
		};

		/*
			Events on mouseClick and cursor icon handling
		*/

		addMissionEventHandler ["GroupIconClick",{
			if (_this select 3 == 0) then {
				[_this select 1] call ACF_ui_groupIconLeftClick;
			};
		}];

		addMissionEventHandler ["MapSingleClick",{
			if !(isNull AC_mouseOver) exitWith {};
			[] spawn {
				sleep 0.05;
				AC_selectedGroups = [];
				UGVAR("ac_groupInfo") ctrlShow false;
				UGVAR("ac_baseInfo") ctrlShow false;
				UGVAR("ac_actionsList") ctrlShow false;
			};
		}];


		addMissionEventHandler ["GroupIconOverEnter", {
			AC_mouseOver = _this select 1;
			private _base = leader AC_mouseOver;
			private _pSide = AC_playerSide;
			private _color = switch (_pSide) do {
			    case west: { "Wdetected" };
			    case east: { "Edetected" };
			    case resistance: { "Idetected" };
		    	default { "Wdetected"};
			};

			// Return if group is not visible
			if (count AC_selectedGroups > 0 || {side AC_mouseOver != _pSide && !GVARS(AC_mouseOver,_color,false)} ) exitWith {};

			private _baseObj = GVARS(AC_mouseOver,"base",objNull);
			if (!isNull _baseObj) then {
				if (GVARS(_baseObj,"side",sideEmpty) == _pSide || {GVARS(_baseObj,_color,false)}) then {
					UGVAR("ac_baseInfo") ctrlShow true;
				};
			} else {
				UGVAR("ac_groupInfo") ctrlShow true;
				if (side AC_mouseOver == _pSide && IS_COMMANDER) then {
					UGVAR("ac_actionsList") ctrlShow true;
				};
			};

			[] call ACF_ui_updateCommandUI;
		}];

		addMissionEventHandler ["GroupIconOverLeave", {
			AC_mouseOver = grpNull;
			if (count AC_selectedGroups == 0) then {
				UGVAR("ac_groupInfo") ctrlShow false;
				UGVAR("ac_baseInfo") ctrlShow false;
				UGVAR("ac_actionsList") ctrlShow false;
			};
		}];

		addMissionEventHandler ["Map", {
			params ["_opened"];
			if (_opened) then {
				UGVAR("ac_battalionInfo") ctrlShow true;
			} else {
				{
					UGVAR(_x) ctrlShow false;
				} forEach ["ac_groupInfo","ac_baseInfo","ac_actionsList","ac_buyList","ac_battalionInfo","ac_supportsList"];
				AC_selectedGroups = [];
			};
		}];
		//

		"text" cutText ["", "BLACK FADED", 1, true, true];

		waituntil {time > 0 && {!isNull player} && {alive player}};

		// Play music at the start
		if (["Music",0] call BIS_fnc_getParamValue == 1) then {
			[] spawn {
				sleep 1;
				private _tracks = ["EventTrack01a_F_Tacops","EventTrack01b_F_Tacops","EventTrack02a_F_Tacops","EventTrack02b_F_Tacops","EventTrack03a_F_Tacops","EventTrack03b_F_Tacops"];
				0 fadeMusic 0;
				playMusic selectRandom _tracks;
				10 fadeMusic 1;
			};
		};

		//sync time
		[clientOwner] remoteExecCall ["ACF_sendLoadData",2];

		AC_playerSide = side group player;
		AC_playerSideColor = [AC_playerSide] call BIS_fnc_sideColor;
		AC_playerBattalion = [AC_playerSide] call ACF_battalion;

		// Make sure that HQ element is initialized
		[group player,AC_playerBattalion,AC_playerSide] remoteExec ["ACF_initHqElement",2];

		// Select commander locally
		if (leader group player == player && GVARS(AC_playerBattalion,"#commander","") == "") then {
			private _name = name player;
			if (!isMultiplayer) then {_name = profileName};
			SVARG(AC_playerBattalion,"#commander", _name);
		};

		disableMapIndicators [true,true,false,false];
		[] call ACF_ui_initUI;

		sleep 0.5;
		"text" cutText ["", "BLACK IN", 1, true, true];

		//[] call ACF_addSwitchAction;

		[] spawn {
			while {true} do {
				sleep 5;
				[] call ACF_visibleVehiclesAgent;
			};
		};
	};
}];