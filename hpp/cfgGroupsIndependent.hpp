// Syndikat groups
//
class I_InfantryBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\n_inf.paa";
	type = TYPE_INFANTRY;
        transport = false;
    units[] = {};
    vehicles[] = {};
};
class I_ReconBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\n_recon.paa";
	type = TYPE_INFANTRY;
        transport = false;
    units[] = {};
    vehicles[] = {};
};
class I_MotorizedBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\n_motor_inf.paa";
	type = TYPE_MOTORIZED;
        transport = false;
    units[] = {};
    vehicles[] = {};
}
class I_MechanizedBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\n_mech_inf.paa";
	type = TYPE_MOTORIZED;
        transport = false;
    units[] = {};
    vehicles[] = {};
};
class I_ArtilleryBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\n_art.paa";
	type = TYPE_ARTILLERY;
        transport = false;
    units[] = {};
    vehicles[] = {};
};
class I_TankBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\n_armor.paa";
	type = TYPE_MOTORIZED;
        transport = false;
    units[] = {};
    vehicles[] = {};
};
class I_HeliBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\n_air.paa";
	type = TYPE_AIR;
        transport = false;
    units[] = {};
    vehicles[] = {};
};

// Syndikat groups
class I_C_infantrySquad_Para : I_InfantryBase
{
    name = "Paramilitary Squad";
    tooltip = "Experienced Syndikat Light infantry.";
    units[] =
    {
        "I_C_Soldier_Para_2_F",
        "I_C_Soldier_Para_4_F",
        "I_C_Soldier_Para_6_F",
        "I_C_Soldier_Para_1_F",
        "I_C_Soldier_Para_7_F",
        "I_C_Soldier_Para_5_F",
        "I_C_Soldier_Para_8_F",
        "I_C_Soldier_Para_3_F"
    };
};

class I_C_infantryTeam_Bandit : I_InfantryBase
{
    name = "Bandit Team";
    tooltip = "Poorly equipped and trained infantry team.";
    units[] =
    {
        "I_C_Soldier_Bandit_4_F",
        "I_C_Soldier_Bandit_3_F",
        "I_C_Soldier_Bandit_5_F",
        "I_C_Soldier_Bandit_6_F"
    };
};

class I_C_infantrySquad_Bandit : I_InfantryBase
{
    name = "Bandit Squad";
    tooltip = "12 member squad of poorly trained soldiers.";
    units[] =
    {
        "I_C_Soldier_Bandit_4_F",
        "I_C_Soldier_Bandit_3_F",
        "I_C_Soldier_Bandit_5_F",
        "I_C_Soldier_Bandit_6_F",
        "I_C_Soldier_Bandit_2_F",
        "I_C_Soldier_Bandit_8_F",
        "I_C_Soldier_Bandit_1_F",
        "I_C_Soldier_Bandit_6_F",
        "I_C_Soldier_Bandit_2_F",
        "I_C_Soldier_Bandit_8_F",
        "I_C_Soldier_Bandit_1_F",
        "I_C_Soldier_Bandit_3_F"
    };
};

class I_C_AtTeam : I_InfantryBase
{
    name = "AT Team";
    tooltip = "Paramilitary AT team consisting of team leader and 3 AT launchers.";
    units[] =
    {
        "I_C_Soldier_Para_6_F",
        "I_C_Soldier_Para_5_F",
        "I_C_Soldier_Para_5_F",
        "I_C_Soldier_Para_5_F"
    };
};

class I_C_Motorized_MG : I_MotorizedBase
{
    name = "Mot. Ambush Team";
    tooltip = "Offroad with 5 Syndikat soldiers inside.";
    units[] = {
        "I_C_Soldier_Bandit_4_F",
        "I_C_Soldier_Bandit_3_F",
        "I_C_Soldier_Bandit_2_F"
    };
    vehicles[] = {
        "I_C_Offroad_02_LMG_F"
    };
};

class I_C_Motorized_AT : I_MotorizedBase
{
    name = "Mot. AT Team";
    tooltip = "AT Offroad AT team inside.";
    units[] =
    {
        "I_C_Soldier_Para_6_F",
        "I_C_Soldier_Para_5_F",
        "I_C_Soldier_Para_5_F"
    };
    vehicles[] =
    {
        "I_C_Offroad_02_AT_F"
    };
};

class I_C_Mortar
{
    name = "Mortar";
    tooltip = "Syndikat mortar team";
    icon = "\A3\ui_f\data\map\markers\nato\n_mortar.paa";
    type = TYPE_ARTILLERY;
    units[] =
    {
        "I_C_Soldier_Para_1_F",
        "I_C_Soldier_Para_2_F"
    };
    vehicles[] =
    {
        "I_G_Mortar_01_F"
    };
};

// Independent Groups
class I_gorgon: I_MechanizedBase
{
    name = "Gorgon APC";
    tooltip = "Versatile wheeled APC capable of defeating both infantry and armor.";
    vehicles[] = {"I_APC_Wheeled_03_cannon_F"};
    units[] =
    {
        "I_crew_F",
        "I_crew_F",
        "I_crew_F"
    };
};

class I_mora: I_MechanizedBase
{
    name = "Mora APC";
    tooltip = "Powerful tracked APC with very good anti infantry weaponry, but lacking anti-tank missiles.";
    vehicles[] = {"I_APC_tracked_03_cannon_F"};
    units[] =
    {
        "I_crew_F",
        "I_crew_F",
        "I_crew_F"
    };
};

class I_E_Odyniec: I_MechanizedBase
{
    name = "Odyniec APC";
    tooltip = "Tracked APC for LDF.";
    vehicles[] = {"I_E_APC_tracked_03_cannon_F"};
    units[] =
    {
        "I_E_crew_F",
        "I_E_crew_F",
        "I_E_crew_F"
    };
};

class I_MLR: I_ArtilleryBase
{
    name = "Zamak Artillery";
    tooltip = "Multiple rocket launcher mounted on Zamak truck.";
    vehicles[] = {"I_Truck_02_MRL_F"};
    units[] =
    {
        //"I_crew_F",
        "I_crew_F",
        "I_crew_F"
    };
};

class I_Kuma : I_TankBase
{
	name = "Kuma Tank";
	tooltip = "Kuma Main Battle Tank";
	units[] =
	{
		"I_crew_F",
		"I_crew_F",
		"I_crew_F"
	};
	vehicles[] = {
		"I_MBT_03_cannon_F"
	};
};

class I_NyxAA : I_TankBase
{
	name = "Nyx AA";
	tooltip = "Anti-air armored vehicle.";
	units[] =
	{
		"I_crew_F",
		"I_crew_F"
	};
	vehicles[] = {
		"I_LT_01_AA_F"
	};
    icon = "\A3\ui_f\data\map\markers\nato\n_support.paa";
};

class I_infantrySquad : I_InfantryBase
{
    name = "Infantry Squad";
    tooltip = "8 soldier infantry squad";
    units[] =
    {
        "I_soldier_SL_F",
        "I_soldier_F",
        "I_soldier_LAT2_F",
        "I_soldier_M_F",
        "I_soldier_TL_F",
        "I_soldier_AR_F",
        "I_soldier_A_F",
        "I_medic_F"
    };
};

class I_E_infantrySquad : I_infantrySquad
{
    units[] =
    {
        "I_E_soldier_SL_F",
        "I_E_soldier_F",
        "I_E_soldier_LAT2_F",
        "I_E_soldier_M_F",
        "I_E_soldier_TL_F",
        "I_E_soldier_AR_F",
        "I_E_soldier_A_F",
        "I_E_medic_F"
    };
};

class I_InfantryTeam : I_InfantryBase
{
    name = "Infantry Team";
    tooltip = "4 member infantry team.";
    units[] =
    {
        "I_soldier_TL_F",
        "I_soldier_AR_F",
        "I_soldier_LAT2_F",
        "I_medic_F"
    };
};

class I_E_InfantryTeam : I_InfantryTeam
{
    units[] =
    {
        "I_E_soldier_TL_F",
        "I_E_soldier_AR_F",
        "I_E_soldier_LAT2_F",
        "I_E_medic_F"
    };
};


class I_SniperTeam : I_ReconBase
{
    name = "Sniper Team";
    tooltip = "Sniper team consisting of 2 elite soldiers.";
    units[] =
    {
        "I_Sniper_F",
        "I_spotter_F"
    };
};

class I_AtTeam : I_InfantryBase
{
    name = "AT Team";
    tooltip = "Anti-tank team consisting of two guided AT and one Light AT gunners.";
    units[] =
    {
        "I_Soldier_AT_F",
        "I_Soldier_AT_F",
        "I_Soldier_LAT2_F",
        "I_Soldier_AAT_F"
    };
};

class I_E_AtTeam : I_AtTeam
{
    units[] =
    {
        "I_E_Soldier_AT_F",
        "I_E_Soldier_AT_F",
        "I_E_Soldier_LAT2_F",
        "I_E_Soldier_AAT_F"
    };
};

class I_AATeam : I_InfantryBase
{
    name = "AA Team";
    tooltip = "Anti-air team consisting of 2 AA troopers.";
    units[] =
    {
        "I_soldier_AA_F",
        "I_soldier_AA_F"
    };
    icon = "\A3\ui_f\data\map\markers\nato\n_support.paa";
};

class I_E_AATeam : I_AATeam
{
    units[] =
    {
        "I_E_soldier_AA_F",
        "I_E_soldier_AA_F"
    };
};

class I_E_Heli : I_HeliBase
{
    name = "Czapla helicopter";
    tooltip = "Light helicopter with 6 cargo seats.";
    units[] =
    {
        "I_E_Helipilot_F",
        "I_E_Helipilot_F"
    };
	vehicles[] =
	{
		"I_E_Heli_Light_03_Unarmed_F"
	};
};

class I_Mohawk : I_HeliBase
{
    name = "CH-49 Mohawk";
    tooltip = "Medium transport helicopter with 14 cargo seats.";
    units[] =
    {
        "I_Helipilot_F",
        "I_Helipilot_F"
    };
	vehicles[] =
	{
		"I_Heli_Transport_02_F"
	};
};
