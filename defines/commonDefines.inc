// -------------------------------------
// BASIC CONSTANTS
// -------------------------------------
#define SPAWN_TIMEOUT   0.5
#define DESPAWN_TIMEOUT 0.1
#define STRATEGY_TICK   15
#define DETECTION_THRESHOLD 3.1

// -------------------------------------
// GAME MODES
// -------------------------------------
#define GAME_MODE_CLASSIC 0
#define GAME_MODE_LAST_STAND 1
#define GAME_MODE_CUSTOM 2

// -------------------------------------
// MACROS for setting and getting variables
// -------------------------------------
#define GVAR(object,variable) (object getVariable variable)
#define GVARS(object,variable,defaultValue) (object getVariable [variable,(defaultValue)])
#define SVAR(object,variable,value) (object setVariable [variable,value])
#define SVARG(object,variable,value) (object setVariable [variable,value, true])
#define MGVAR(value,defaultValue) (missionnamespace getVariable [value, defaultValue])
#define MGVARS(value,defaultValue) (missionnamespace getVariable [value, defaultValue])
#define MSVAR(variable,value) (missionnamespace setVariable [variable,value])
#define MSVARG(variable,value) (missionnamespace setVariable [variable,value,true])
#define UGVAR(variable) (uiNamespace getVariable variable)
#define UGVARS(variable,defaultValue) (uiNamespace getVariable [variable,defaultValue])
#define USVAR(variable,value) (uiNamespace setVariable [variable,value])
#define USVARG(variable,value) (uiNamespace setVariable [variable,value,true])
#define CLAMP(var,minv,maxv) var = ((var max minv) min maxv)

#define DM(pos) private _mrk = createMarker [str _pos,_pos];_mrk setMarkerShape "ICON"; _mrk setMarkerType "hd_dot";
#define DBG(array) (if(DEBUG_MODE) then {systemChat format array})

// Supports
#define SUPPORT_CAS 	    0
#define SUPPORT_ARTY 	    1

#define SUPPORT_CANNON      0
#define SUPPORT_MISSILES    1
#define SUPPORT_COMBINED    2
#define SUPPORT_BOMBS       3

// New battle agent
#define BA_CHANGE_RATE 0.4

// As how many units player counts :)
#define PLAYER_STRENGTH 5

// Commander macros
#define IS_COMMANDER (!GVARS(player,"#leftCommand",false) && (!isMultiplayer || {name player == AC_playerBattalion getVariable ["#commander",""]} || {AC_sharedCommanding}))

#define IS_AI_ENABLED(battalion) (battalion getVariable ["#commander",""] == "")

// Switch unit macro
#define REQUEST_SWITCH(unit) [unit,originalUnit] remoteExecCall ["ACF_s",2]

// Notification macros:
#define SEND_NOTIFICATION(type,message,targets) ([type,message] remoteExecCall ["NN",targets])
#define NN_TIME_REMAINING   0
#define NN_BASE_CAPTURED    1
#define NN_GROUP_LOST       2
#define NN_GROUP_KILLED     3
#define NN_GROUP_DETECTED   4
#define NN_BASE_DETECTED    5
#define NN_COMMANDER_PLAYER 6
#define NN_COMMANDER        7
#define NN_CUSTOM           8
#define NN_BASE_ATTACKED    9

#define NN_COMMANDER_AI         10
#define NN_COMMANDER_PLAYER_S   11
#define NN_COMMANDER_S          12
#define NN_COMMANDER_LEAVE      13

// --------------------------
// Optimized sending variables over network
// --------------------------
#define SEND_GROUP_DATA(grp,data) ([grp,data] remoteExecCall ["AGD",0,true])
#define REMOVE_GROUP(grp) ([grp] remoteExecCall ["RGD",0,true])
#define ADD_DATA_OBJECT(obj,var,data) ([obj,var,obj] remoteExecCall ["ADO",0,true])
#define ADD_DATA_MISSION(var,data) ([var,data] remoteExecCall ["ADM",0,true])
#define REMOVE_DATA_OBJECT(obj,var,data) ([obj,var,data] remoteExecCall ["RDO",0,true])
#define REMOVE_DATA_MISSION(var,data) ([var,data] remoteExecCall ["RDM",0,true])

// --------------------------
// CURSOR ICONS
// --------------------------
#define CURSOR_NORMAL "Track"
#define CURSOR_MOVE "HC_overMission"
#define CURSOR_FIRE_MISSION "HC_overEnemy"
//#define CURSOR_GET_IN "HC_overFriendly"
#define CURSOR_GET_IN "CuratorMoveIn"
#define CURSOR_ATTACK "HC_overEnemy"

// --------------------------
// ACTIONS
// --------------------------
#define ACTION_GET_IN 10
#define ACTION_GET_OUT 11
#define ACTION_UNLOAD 12

// Vehicle movement tweaks and limits
#define VEHICLE_SPEED_LIMIT 45
#define SPEED_LIMIT_AIR 150
#define HELI_ALT 60

// --------------------------
// BATTALION MACROS
// --------------------------
#define RECON_O             0
#define INFANTRY_O          1
#define TANK_O              2
#define SPETSNAZ_O          3

#define MILITIA_FIA         10
#define RECON_B             11
#define TANK_B              12
#define TANK_B_W            13

#define MILITIA_SYNDIKAT    20
#define MECHANIZED_I        21
#define LDF                 22

#define CUSTOM              99

// --------------------------
// TYPE MACROS
// --------------------------
#define TYPE_INFANTRY   0
#define TYPE_MOTORIZED  1
#define TYPE_ARTILLERY  2
#define TYPE_AIR        3

// --------------------------
// BEHAVIORS: SIMPLIFIED BEHAVIORS
// --------------------------
#define B_DEFAULT 0 // Do not change behavior at all
#define B_COMBAT 1 // Default aware behavior with everything turned on
#define B_TRANSPORT 2 // Fastest, but reasonable, no autocombat
#define B_SILENT 3 // Stealth, green mode, slow speed

// -------------------------------------
// STRATEGIC AI MACROS
// -------------------------------------
#define RATIO_CONCEDE 4 // How many times more strength should enemy have to concede

#define ATTACK_DEFENSE_RATIO 1.8        // Attackers want to have x times the force
#define DEFENSIVE_RATIO 1.1            // Defenders want to have x times the force
#define DEFENSE_DISTANCE 450            // Radius of units to be counted as near base
#define OFFENSIVE_STAGING_DISTANCE 275  // meters from start of the perimeter
#define THREAT_DISTANCE OFFENSIVE_STAGING_DISTANCE + 125 // Radius of enemy units from border of the base
#define AD_RETREAT_THRESHOLD 0.6         // What ratio of Attackers/Defenders must be to abandon attack

// -------------------------------------
// DEPLOYMENT CONSTANTS
// -------------------------------------
#define DEPLOYED_FALSE  0
#define DEPLOYED_BUSY   -1
#define DEPLOYED_TRUE   1

// -------------------------------------
// BASE ATTRIBUTES
// -------------------------------------
#define BASE_PERIMETER_MIN 30
#define BASE_PERIMETER_MAX 250

#define DEPLOY_RADIUS 250

#define SPAWN_RANGE 400
#define DESPAWN_RANGE (SPAWN_RANGE + 50)

// -------------------------------------
// BATTLE STATES
// -------------------------------------
#define BATTLE_STATE_ENDED 0
#define BATTLE_STATE_STARTED 1
#define BATTLE_STATE_PERIMETER_BREACHED 3
#define BATTLE_STATE_HQ_BREACHED 4
#define BATTLE_STATE_ATTACKER_RETREAT 5
#define BATTLE_STATE_DEFENDER_CLEANUP 6

// -------------------------------------
// MARKERS
// -------------------------------------
#define COLOR_BLUFOR [0,0.3,0.6,1]
#define COLOR_OPFOR [0.5,0,0,1]
#define COLOR_RESISTANCE [0,0.5,0,1]
#define COLOR_EMPTY [0.7,0.6,0,1]
#define DEBUG_MARKER_ALPHA 0.7
#define DEFAULT_BACKGROUND [0,0,0,0.6] // Dark semitransparent field
#define COLOR_HIGHLIGHT [0.7,0.6,0,1] // Yellow highlight color


// -------------------------------------
// GARRISON
// -------------------------------------
#define UNIT_COUNT_GARRISON 5
#define DEFAULT_COUNT_GARRISON 5
#define GARRISON_STATIC_DYNAMIC_RATIO 0.5

// --------------------------
// AI MISSIONS
// --------------------------
#define MISSION_LIST [0,1,2,3,4]

#define M_IDLE 10
#define M_MOVE 11
#define M_ASSAULT 12

// XP FOR EACH KILL
#define XP_KILL_RATIO 0.01
