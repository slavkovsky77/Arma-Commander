// Additional groups that don't exist in CfgGroups
#include "\AC\defines\commonDefines.inc"

class Groups
{
	class HqSquadBase
	{
		name = "HQ Element";
		tooltip = "";
		icon = "\A3\ui_f\data\map\markers\nato\b_hq.paa";
		type = TYPE_INFANTRY;
		transport = false;
		vehicles[] = {};
		units[] = {};
	};

	class B_hqSquad: HqSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_hq.paa";
		units[] = {
			"B_officer_F",
			"B_officer_F",
			"B_Soldier_TL_F",
			"B_medic_F"
		};
	};
	class B_W_hqSquad: HqSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_hq.paa";
		units[] = {
			"B_W_officer_F",
			"B_W_officer_F",
			"B_W_Soldier_TL_F",
			"B_W_medic_F"
		};
	};
	class B_T_hqSquad: HqSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_hq.paa";
		units[] = {
			"B_T_officer_F",
			"B_T_officer_F",
			"B_T_Soldier_TL_F",
			"B_T_medic_F"
		};
	};

	class B_G_hqSquad: HqSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_hq.paa";
		units[] = {
			"B_G_officer_F",
			"B_G_officer_F",
			"B_G_Soldier_TL_F",
			"B_G_medic_F"
		};
	};

	class O_hqSquad: HqSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\o_hq.paa";
		units[] = {
			"O_officer_F",
			"O_officer_F",
			"O_Soldier_TL_F",
			"O_medic_F"
		};
	};
	class O_R_hqSquad: HqSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\o_hq.paa";
		units[] = {
			"O_R_Soldier_TL_F",
			"O_R_Soldier_TL_F",
			"O_R_Soldier_M_F",
			"O_R_medic_F"
		};
	};
	class O_T_hqSquad: HqSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\o_hq.paa";
		units[] = {
			"O_T_officer_F",
			"O_T_officer_F",
			"O_T_Soldier_TL_F",
			"O_T_medic_F"
		};
	};
	class I_hqSquad: HqSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\n_hq.paa";
		units[] = {
			"I_officer_F",
			"I_officer_F",
			"I_Soldier_TL_F",
			"I_medic_F"
		};
	};
	class I_C_hqSquad: HqSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\n_hq.paa";
		units[] = {
			"I_C_Soldier_Para_6_F",
			"I_C_Soldier_Para_1_F",
			"I_C_Soldier_Para_4_F",
			"I_C_Soldier_Para_3_F"
		};
	};


	#include "\AC\hpp\cfgGroupsWest.hpp"
	#include "\AC\hpp\cfgGroupsEast.hpp"
	#include "\AC\hpp\cfgGroupsIndependent.hpp"


	/*
	// Militia Squad - light squad without heavy weapons
	class MilitiaSquadBase
	{
		name = "Militia Squad";
		icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
	};

	class B_MilitiaSquad: MilitiaSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
		units[] = {
			"B_Soldier_SL_F",
			"B_soldier_AR_F",
			"B_soldier_M_F",
			"B_medic_F",
			"B_Soldier_lite_F",
			"B_Soldier_lite_F",
			"B_Soldier_lite_F",
			"B_Soldier_lite_F"
		};
	};

	// No lite soldiers, so I use normal onces, but only 7 ppl
	class B_T_MilitiaSquad: MilitiaSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
		units[] = {
			"B_T_Soldier_SL_F",
			"B_T_soldier_AR_F",
			"B_T_soldier_M_F",
			"B_T_medic_F",
			"B_T_Soldier_AAR_F",
			"B_T_Soldier_F",
			"B_T_Soldier_F"
		};
	};

	class B_G_MilitiaSquad: MilitiaSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
		units[] = {
			"B_G_Soldier_SL_F",
			"B_G_soldier_AR_F",
			"B_G_soldier_M_F",
			"B_G_medic_F",
			"B_G_Soldier_AAR_F",
			"B_G_Soldier_F",
			"B_G_Soldier_F"
		};
	};

	class O_MilitiaSquad: MilitiaSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
		units[] = {
			"O_Soldier_SL_F",
			"O_soldier_AR_F",
			"O_soldier_M_F",
			"O_medic_F",
			"O_Soldier_lite_F",
			"O_Soldier_lite_F",
			"O_Soldier_lite_F",
			"O_Soldier_lite_F"
		};
	};

	// No lite soldiers, so I use normal onces, but only 7 ppl
	class O_T_MilitiaSquad: MilitiaSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
		units[] = {
			"O_T_Soldier_SL_F",
			"O_T_soldier_AR_F",
			"O_T_soldier_M_F",
			"O_T_medic_F",
			"O_T_Soldier_AAR_F",
			"O_T_Soldier_F",
			"O_T_Soldier_F"
		};
	};

	class I_MilitiaSquad: MilitiaSquadBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\i_inf.paa";
		units[] = {
			"I_Soldier_SL_F",
			"I_soldier_AR_F",
			"I_soldier_M_F",
			"I_medic_F",
			"I_Soldier_lite_F",
			"I_Soldier_lite_F",
			"I_Soldier_lite_F",
			"I_Soldier_lite_F"
		};
	};

	class TruckBase
	{
		name = "Transport";
		icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
	};
	class B_Truck: TruckBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
		vehicles[] = {"B_Truck_01_transport_F"};
		units[] = {
			"B_Soldier_lite_F",
			"B_Soldier_lite_F"
		};
	};
	class O_Truck: TruckBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
		vehicles[] = {"O_Truck_03_transport_F"};
		units[] = {
			"O_Soldier_lite_F",
			"O_Soldier_lite_F"
		};
	};

	class ApcWheeledBase
	{
		name = "APC";
		icon = "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa";
	};
	class B_Marshall: ApcWheeledBase
	{
		name = "Marshall APC";
		icon = "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa";
		vehicles[] = {"B_APC_Wheeled_01_cannon_F"};
		units[] = {
			"B_Crew_F",
			"B_Crew_F",
			"B_Crew_F"
		};
	};
	class O_Kamysh: ApcWheeledBase
	{
		name = "Kamysh APC";
		icon = "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa";
		vehicles[] = {"O_APC_Tracked_02_cannon_F"};
		units[] = {
			"O_Crew_F",
			"O_Crew_F",
			"O_Crew_F"
		};
	};

	class MortarBase
	{
		name = "Mortar Team";
		icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
	};
	class B_Mortar: MortarBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_mortar.paa";
		vehicles[] = {"B_Mortar_01_F"};
		units[] = {
			"B_Soldier_Lite_F",
			"B_Soldier_Lite_F"
		};
	};

	class B_G_Mortar: MortarBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_mortar.paa";
		vehicles[] = {"B_G_Mortar_01_F"};
		units[] = {
			"B_G_Soldier_Lite_F",
			"B_G_Soldier_Lite_F"
		};
	};

	class O_Mortar: MortarBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\o_mortar.paa";
		vehicles[] = {"O_Mortar_01_F"};
		units[] = {
			"O_Soldier_Lite_F",
			"O_Soldier_Lite_F"
		};
	};
	class I_C_Mortar: MortarBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\o_mortar.paa";
		vehicles[] = {"I_Mortar_01_F"};
		units[] = {
			"I_C_Soldier_Para_7_F",
			"I_C_Soldier_Para_7_F"
		};
	};


	// Sniper teams for FIA and AAF

	class SniperBase
	{
		name = "Sniper team";
	}

	class B_sniperTeam: SniperBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_recon.paa";
		vehicles[] = {};
		units[] = {
			"B_sniper_F",
			"B_spotter_F"
		};
	}
	class I_sniperTeam: SniperBase
	{
		icon = "\A3\ui_f\data\map\markers\nato\b_recon.paa";
		vehicles[] = {};
		units[] = {
			"I_sniper_F",
			"I_spotter_F"
		};
	}

	//
	// New groups for FIA: Truck, AT offroad, MG offroad, sniper team, CTRG team
	//
	class B_G_motorizedMG
	{
		name = "MG Offroad";
		icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
		vehicles[] = {"B_G_Offroad_01_armed_F"};
		units[] = {
			"B_G_engineer_F",
			"B_G_Soldier_lite_F"
		};
	};

	class B_G_motorizedAT
	{
		name = "AT Offroad";
		icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
		vehicles[] = {"B_G_Offroad_01_AT_F"};
		units[] = {
			"B_G_engineer_F",
			"B_G_Soldier_lite_F"
		};
	};
	*/
};



