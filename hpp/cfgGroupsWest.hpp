// Base classes
class B_InfantryBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
	type = TYPE_INFANTRY;
		transport = false;
    units[] = {};
    vehicles[] = {};
};
class B_ReconBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\b_recon.paa";
	type = TYPE_INFANTRY;
		transport = false;
    units[] = {};
    vehicles[] = {};
};
class B_MotorizedBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
	type = TYPE_MOTORIZED;
		transport = false;
    units[] = {};
    vehicles[] = {};
}
class B_MechanizedBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa";
	type = TYPE_MOTORIZED;
		transport = false;
    units[] = {};
    vehicles[] = {};
};
class B_ArtilleryBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\b_art.paa";
	type = TYPE_ARTILLERY;
		transport = false;
    units[] = {};
    vehicles[] = {};
};
class B_TankBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\b_armor.paa";
	type = TYPE_MOTORIZED;
		transport = false;
    units[] = {};
    vehicles[] = {};
};
class B_HeliBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\b_air.paa";
	type = TYPE_AIR;
		transport = false;
    units[] = {};
    vehicles[] = {};
};

// Actual classes
class B_InfSquad : B_InfantryBase
{
    name = "Infantry Squad";
    tooltip = "Regular NATO infantry squad";
    units[] =
    {
        "B_soldier_SL_F",
        "B_soldier_F",
        "B_soldier_LAT_F",
        "B_soldier_M_F",
        "B_soldier_TL_F",
        "B_soldier_AR_F",
        "B_soldier_A_F",
        "B_medic_F"
    };
};

class B_W_InfSquad : B_InfSquad
{
    units[] =
    {
        "B_W_soldier_SL_F",
        "B_W_soldier_F",
        "B_W_soldier_LAT_F",
        "B_W_soldier_M_F",
        "B_W_soldier_TL_F",
        "B_W_soldier_AR_F",
        "B_W_soldier_A_F",
        "B_W_medic_F"
    };
};

class B_ReconTeam : B_ReconBase
{
    name = "Recon Team";
    tooltip = "5 member recon team.";
    units[] =
    {
        "B_recon_TL_F",
        "B_recon_M_F",
        "B_recon_medic_F",
        "B_recon_LAT_F",
        "B_recon_exp_F"
    };
};

class B_SniperTeam : B_ReconBase
{
    name = "Sniper Team";
    tooltip = "Sniper team consisting of 2 elite soldiers.";
    units[] =
    {
        "B_Sniper_F",
        "B_spotter_F"
    };
};

class B_W_SniperTeam : B_SniperTeam
{
    name = "Sniper Team";
    tooltip = "Sniper team consisting of 2 elite soldiers.";
    units[] =
    {
        "B_ghillie_lsh_F",
        "B_T_spotter_F"
    };
};

class B_CTRG_squad : B_ReconBase
{
	name = "Special Forces Squad";
	tooltip = "CTRG 6 man squad of elite soldiers.";
	units[] = {
		"B_Story_SF_Captain_F",
		"B_CTRG_soldier_M_medic_F",
		"B_CTRG_soldier_AR_A_F",
		"B_CTRG_soldier_GL_LAT_F",
		"B_CTRG_Sharphooter_F",
		"B_CTRG_soldier_engineer_exp_F"
	};
};

class B_AtTeam : B_InfantryBase
{
    name = "AT Team";
    tooltip = "Anti-tank team using guided and unguided AT weapons.";
    units[] =
    {
        "B_Soldier_AT_F",
        "B_Soldier_AT_F",
        "B_Soldier_LAT_F",
        "B_Soldier_AAT_F"
    };
    icon = "\A3\ui_f\data\map\markers\nato\b_support.paa";
};

class B_W_AtTeam : B_AtTeam
{
    units[] =
    {
        "B_W_Soldier_AT_F",
        "B_W_Soldier_AT_F",
        "B_W_Soldier_LAT_F",
        "B_W_Soldier_AAT_F"
    };
};

class B_AATeam : B_InfantryBase
{
    name = "AA Team";
    tooltip = "Anti-air team consisting of 2 AA troopers.";
    units[] =
    {
        "B_soldier_AA_F",
        "B_soldier_AA_F"
    };
    icon = "\A3\ui_f\data\map\markers\nato\b_support.paa";
};

class B_W_AATeam : B_AATeam
{
    units[] =
    {
        "B_W_soldier_AA_F",
        "B_W_soldier_AA_F"
    };
};


class B_MotorizedRecon : B_ReconBase
{
	name = "Motorized Recon";
	tooltip = "Recon Team mounted in Prowler LSV.";
	units[] =
	{
		"B_recon_TL_F",
		"B_recon_M_F",
		"B_recon_medic_F",
		"B_recon_LAT_F",
		"B_recon_exp_F"
	};
	vehicles[] =
	{
		"B_LSV_01_armed_F"
	};
};

class B_Marshall : B_MechanizedBase
{
	name = "Marshall APC";
	tooltip = "Marshall Wheeled APC with three crewmen.";
	units[] =
	{
		"B_crew_F",
		"B_crew_F",
		"B_crew_F"
	};
	vehicles[] =
	{
		"B_APC_Wheeled_01_cannon_F"
	};
};

class B_Panther : B_MechanizedBase
{
	name = "Panther APC";
	tooltip = "Panther heavy tracked APC with limited firepower.";
	units[] =
	{
		"B_crew_F",
		"B_crew_F",
		"B_crew_F"
	};
	vehicles[] =
	{
		"B_APC_Tracked_01_rcws_F"
	};
};

class B_W_Panther : B_Panther
{
	units[] =
	{
		"B_W_crew_F",
		"B_W_crew_F",
		"B_W_crew_F"
	};
	vehicles[] =
	{
		"B_T_APC_Tracked_01_rcws_F"
	};
};

class B_Rhino : B_TankBase
{
	name = "Tank Destroyer";
	tooltip = "Rhino tank destroyer";
	units[] =
	{
		"B_crew_F",
		"B_crew_F",
		"B_crew_F"
	};
	vehicles[] =
	{
		"B_AFV_Wheeled_01_cannon_F"
	};
};

class B_W_Rhino : B_Rhino
{
	units[] =
	{
		"B_W_crew_F",
		"B_W_crew_F",
		"B_W_crew_F"
	};
	vehicles[] =
	{
		"B_T_AFV_Wheeled_01_cannon_F"
	};
};

class B_Slammer : B_TankBase
{
	name = "Slammer Tank";
	tooltip = "Slammer Main Battle Tank";
	units[] =
	{
		"B_crew_F",
		"B_crew_F",
		"B_crew_F"
	};
	vehicles[] = {
		"B_MBT_01_cannon_F"
	};
};

class B_W_Slammer : B_Slammer
{
	units[] =
	{
		"B_W_crew_F",
		"B_W_crew_F",
		"B_W_crew_F"
	};
	vehicles[] = {
		"B_T_MBT_01_cannon_F"
	};
};


class B_SlammerUP : B_Slammer
{
	name = "Slammer (urban)";
	vehicles[] =
	{
		"B_MBT_01_TUSK_F"
	};
};

class B_W_SlammerUP : B_W_Slammer
{
	name = "Slammer (urban)";
	vehicles[] =
	{
		"B_T_MBT_01_TUSK_F"
	};
};

class B_Cheetah : B_TankBase
{
    name = "IFV-6a Cheetah (AA)";
    tooltip = "Anti-air vehicle armed with rockets and powerful 30mm cannons.";
    units[] =
    {
        "B_crew_F",
        "B_crew_F",
        "B_crew_F"
    };
    vehicles[] =
    {
        "B_APC_Tracked_01_AA_F"
    };
    icon = "\A3\ui_f\data\map\markers\nato\b_support.paa";
};

class B_W_Cheetah : B_Cheetah
{
    units[] =
    {
        "B_W_crew_F",
        "B_W_crew_F",
        "B_W_crew_F"
    };
    vehicles[] =
    {
        "B_T_APC_Tracked_01_AA_F"
    };
};


class B_Sandstorm : B_ArtilleryBase
{
	name = "Sandstrom MLRS";
	tooltip = "Missile Artillery Piece";
	units[] = {
		"B_crew_F",
		"B_crew_F"
	};
	vehicles[] =
	{
		"B_MBT_01_mlrs_F"
	};
};

class B_Scorcher : B_ArtilleryBase
{
	name = "Scorcher Artillery";
	tooltip = "NATO 155mm artillery piece";
	units[] =
	{
		"B_crew_F",
		"B_crew_F",
		"B_crew_F"
	};
	vehicles[] =
	{
		"B_MBT_01_arty_F"
	};
};

// FIA groups
class B_G_VeteranInfantry : B_InfantryBase
{
	name = "Veteran Infantry";
	tooltip = "Skilled and well equipped FIA infantry squad.";
	units[] = {
		"B_G_Soldier_TL_F",
		"B_G_soldier_AR_F",
		"B_G_soldier_M_F",
		"B_G_medic_F",
		"B_G_Soldier_A_F",
		"B_G_Soldier_LAT_F",
		"B_G_soldier_GL_F"
	};
};

class B_G_InfSquad : B_InfantryBase
{
	name = "Infantry Squad";
	tooltip = "Basic FIA infantry squad.";
	units[] = {
		"B_G_Soldier_SL_F",
		"B_G_soldier_AR_F",
		"B_G_soldier_M_F",
		"B_G_medic_F",
		"B_G_Soldier_A_F",
		"B_G_Soldier_LAT2_F",
		"B_G_Soldier_F"
	};
};

class B_G_InfTeam : B_ReconBase
{
	name = "Recon Team";
	tooltip = "FIA 5 member team used trained for reconniassance.";
	units[] = {
		"B_G_Soldier_SL_F",
		"B_G_soldier_AR_F",
		"B_G_soldier_M_F",
		"B_G_medic_F",
		"B_G_Soldier_F"
	};
};

class B_G_AtTeam : B_InfantryBase
{
    name = "AT Team";
    tooltip = "Anti-tank team consisting of 4 AT gunners";
    units[] =
    {
        "B_G_soldier_TL_F",
        "B_G_Soldier_LAT_F",
        "B_G_Soldier_LAT_F",
        "B_G_Soldier_LAT_F"
    };
};

class B_G_SniperTeam : B_ReconBase
{
    name = "Sharpshooter Team";
    tooltip = "Sharpshooter team consisting of 2 elite guerilla fighters.";
    units[] =
    {
        "B_G_Sharpshooter_F",
        "B_G_Sharpshooter_F"
    };
};

class B_G_motorizedMG : B_MotorizedBase
{
	name = "MG Offroad";
	tooltip = "3 member team in offroad equipped with Heavy machinegun";
	units[] = {
		"B_G_engineer_F",
		"B_G_Soldier_lite_F",
		"B_G_Soldier_lite_F"
	};
	vehicles[] =
	{
		"B_G_Offroad_01_armed_F"
	};
};

class B_G_motorizedAT : B_MotorizedBase
{
	name = "AT Offroad";
	tooltip = "3 member team in offroad equipped with Rocket launcher";
	units[] = {
		"B_G_engineer_F",
		"B_G_Soldier_lite_F",
		"B_G_Soldier_lite_F"
	};
	vehicles[] =
	{
		"B_G_Offroad_01_AT_F"
	};
};

class B_G_Mortar: B_ArtilleryBase
{
	name = "Mortar";
	tooltip = "FIA 2 member mortar team.";
	icon = "\A3\ui_f\data\map\markers\nato\b_mortar.paa";
	units[] = {
		"B_G_Soldier_Lite_F",
		"B_G_Soldier_Lite_F"
	};
	vehicles[] =
	{
		"B_G_Mortar_01_F"
	};
};

class B_Hummingbird : B_HeliBase
{
    name = "MH-9 Hummingbird";
    tooltip = "Light transport helicopter with 6 seats for transport";
    units[] =
    {
        "B_Helipilot_F",
        "B_Helipilot_F"
    };
	vehicles[] =
	{
		"B_Heli_Light_01_F"
	};
};

class B_Ghosthawk : B_HeliBase
{
    name = "UH-80 Ghost Hawk";
    tooltip = "Medium transport helicopter with 8 cargo seats, armed with rockets and machineguns.";
    units[] =
    {
        "B_Helipilot_F",
        "B_Helipilot_F",
		"B_helicrew_F",
		"B_helicrew_F"
    };
	vehicles[] =
	{
		"B_Heli_Transport_01_F"
	};
};
