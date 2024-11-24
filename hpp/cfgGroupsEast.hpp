class O_InfantryBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
	type = TYPE_INFANTRY;
        transport = false;
    units[] = {};
    vehicles[] = {};
}
class O_ReconBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\o_recon.paa";
	type = TYPE_INFANTRY;
        transport = false;
    units[] = {};
    vehicles[] = {};
}
class O_MotorizedBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
	type = TYPE_MOTORIZED;
        transport = false;
    units[] = {};
    vehicles[] = {};
}
class O_MechanizedBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa";
	type = TYPE_MOTORIZED;
        transport = false;
    units[] = {};
    vehicles[] = {};
}
class O_ArtilleryBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\o_art.paa";
	type = TYPE_ARTILLERY;
        transport = false;
    units[] = {};
    vehicles[] = {};
}
class O_TankBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\o_armor.paa";
	type = TYPE_MOTORIZED;
        transport = false;
    units[] = {};
    vehicles[] = {};
}
class O_HeliBase
{
    name = "";
    tooltip = "";
    icon = "\A3\ui_f\data\map\markers\nato\o_air.paa";
	type = TYPE_AIR;
        transport = false;
    units[] = {};
    vehicles[] = {};
};

class O_InfSquad : O_InfantryBase
{
    name = "Infantry Squad";
    tooltip = "Regular CSAT infantry squad";
    units[] =
    {
        "O_soldier_SL_F",
        "O_soldier_F",
        "O_soldier_LAT_F",
        "O_soldier_M_F",
        "O_soldier_TL_F",
        "O_soldier_AR_F",
        "O_soldier_A_F",
        "O_medic_F"
    };
}

class O_R_InfSquad : O_InfantryBase
{
    name = "Spetsnaz Infantry Squad";
    tooltip = "Russian special forces infantry squad";
    units[] =
    {
        "O_R_soldier_TL_F",
        "O_R_soldier_GL_F",
        "O_R_soldier_LAT_F",
        "O_R_soldier_M_F",
        "O_R_soldier_TL_F",
        "O_R_soldier_AR_F",
        "O_R_JTAC_F",
        "O_R_medic_F"
    };
}

class O_InfSquad_Urban : O_InfantryBase
{
    name = "Infantry Squad";
    tooltip = "Regular CSAT infantry squad";
    units[] =
    {
        "O_soldierU_SL_F",
        "O_soldierU_F",
        "O_soldierU_LAT_F",
        "O_soldierU_M_F",
        "O_soldierU_TL_F",
        "O_soldierU_AR_F",
        "O_soldierU_A_F",
        "O_soldierU_medic_F"
    };
}

class O_UrbanTeam : O_InfantryBase
{
    name = "Urban Patrol";
    tooltip = "CSAT urban infantry team";
    units[] =
    {
        "O_soldierU_TL_F",
        "O_soldierU_AR_F",
        "O_soldierU_F",
        "O_soldierU_LAT_F",
        "O_soldierU_medic_F"
    };
}

class O_R_InfTeam : O_InfantryBase
{
    name = "Spetsnaz Infantry Team";
    tooltip = "4 man Spetsnaz team";
    units[] =
    {
        "O_R_soldier_TL_F",
        "O_R_soldier_LAT_F",
        "O_R_soldier_AR_F",
        "O_medic_F"
    };
}

class O_UrbanSquad : O_InfantryBase
{
    name = "Urban Assault Squad";
    tooltip = "Regular CSAT infantry squad";
    units[] =
    {
        "O_soldierU_SL_F",
        "O_soldierU_F",
        "O_soldierU_LAT_F",
        "O_soldierU_M_F",
        "O_soldierU_TL_F",
        "O_soldierU_AR_F",
        "O_soldierU_A_F",
        "O_Urban_HeavyGunner_F",
        "O_soldierU_GL_F",
        "O_soldierU_medic_F"
    };
}

class O_ReconTeam : O_ReconBase
{
    name = "Recon Team";
    tooltip = "5 member recon team.";
    units[] =
    {
        "O_recon_TL_F",
        "O_recon_M_F",
        "O_recon_medic_F",
        "O_recon_LAT_F",
        "O_recon_exp_F"
    };
}

class O_R_ReconTeam : O_ReconBase
{
    name = "Spetsnaz Recon Team";
    tooltip = "6 member recon team.";
    units[] =
    {
        "O_R_recon_TL_F",
        "O_R_recon_M_F",
        "O_R_recon_AR_F",
        "O_R_recon_medic_F",
        "O_R_recon_LAT_F",
        "O_R_recon_exp_F"
    };
}

class O_AtTeam : O_InfantryBase
{
    name = "AT Team";
    tooltip = "Anti-tank team consisting of 2 Titan AT gunners";
    units[] =
    {
        "O_Soldier_AT_F",
        "O_Soldier_AT_F",
        "O_Soldier_AAT_F",
        "O_Soldier_AAT_F"
    };
}

class O_AtTeamUrban : O_AtTeam
{
    units[] =
    {
        "O_soldierU_AT_F",
        "O_SoldierU_AT_F",
        "O_SoldierU_AAT_F",
        "O_SoldierU_AAT_F"
    };
}

class O_AATeam : O_InfantryBase
{
    name = "AA Team";
    tooltip = "Anti-air team consisting of 2 AA troopers.";
    units[] =
    {
        "O_soldier_AA_F",
        "O_soldier_AA_F"
    };
    icon = "\A3\ui_f\data\map\markers\nato\o_support.paa";
}

class O_AATeamUrban : O_AATeam
{
    units[] =
    {
        "O_soldierU_AA_F",
        "O_soldierU_AA_F"
    };
}


class O_SniperTeam : O_ReconBase
{
    name = "Sniper Team";
    tooltip = "Sniper team consisting of 2 elite soldiers.";
    units[] =
    {
        "O_Sniper_F",
        "O_spotter_F"
    };
}

class O_ViperSquad : O_ReconBase
{
    name = "Viper Squad";
    tooltip = "Special forces squad consisting of 8 men";
    units[] =
    {
        "O_V_Soldier_TL_hex_F",
        "O_V_Soldier_JTAC_hex_F",
        "O_V_Soldier_M_hex_F",
        "O_V_Soldier_Exp_hex_F",
        "O_V_Soldier_LAT_hex_F",
        "O_V_Soldier_Medic_hex_F",
        "O_V_Soldier_hex_F",
        "O_V_Soldier_hex_F"
    };
};

class O_Recon_Motorized : O_ReconBase
{
    name = "Motorized Recon";
    tooltip = "5 memeber recon team in Quilin LSV.";
    type = TYPE_MOTORIZED;
    units[] =
    {
        "O_recon_TL_F",
        "O_recon_M_F",
        "O_recon_medic_F",
        "O_recon_LAT_F",
        "O_recon_exp_F"
    };
    vehicles[] =
    {
        "O_LSV_02_armed_F"
    };
};

class O_R_Recon_Motorized : O_Recon_Motorized
{
    name = "Motorized Spetsnaz Recon";
    units[] =
    {
        "O_R_recon_TL_F",
        "O_R_recon_M_F",
        "O_R_recon_medic_F",
        "O_R_recon_LAT_F",
        "O_R_recon_exp_F"
    };
};

class O_Kamysh : O_MechanizedBase
{
    name = "Kamysh APC";
    tooltip = "Kamysh armored vehicle with 3 crewmen.";
    units[] =
    {
        "O_crew_F",
        "O_crew_F",
        "O_crew_F"
    };
    vehicles[] =
    {
        "O_APC_Tracked_02_cannon_F"
    };
};

class O_Patrol_Motorized : O_MotorizedBase
{
    name = "Ifrit HMG";
    tooltip = "Motorized patrol in Ifrit with heavy machinegun.";
    units[] =
    {
        "O_soldierU_TL_F",
        "O_soldierU_F",
        "O_soldierU_F"
    };
    vehicles[] =
    {
        "O_MRAP_02_hmg_F"
    };
};

class O_Marid : O_MechanizedBase
{
    name = "Marid APC";
    tooltip = "Marid Light APC with 3 crewmen.";
    units[] =
    {
        "O_crew_F",
        "O_crew_F",
        "O_crew_F"
    };
    vehicles[] =
    {
        "O_APC_Wheeled_02_rcws_v2_F"
    };
};

class O_Varsuk : O_TankBase
{
    name = "Varsuk MBT";
    tooltip = "Mobile and deadly Varsuk is main tank of CSAT forces.";
    units[] =
    {
        "O_crew_F",
        "O_crew_F",
        "O_crew_F"
    };
    vehicles[] =
    {
        "O_MBT_02_cannon_F"
    };
};

class O_Angara : O_TankBase
{
    name = "Angara MBT";
    tooltip = "Elite CSAT tank.";
    units[] =
    {
        "O_crew_F",
        "O_crew_F",
        "O_crew_F"
    };
    vehicles[] =
    {
        "O_MBT_04_cannon_F"
    };
};

class O_Angara_K : O_TankBase
{
    name = "Angara-K MBT";
    tooltip = "Elite CSAT tank, variant with 30mm commander's cannon.";
    units[] =
    {
        "O_crew_F",
        "O_crew_F",
        "O_crew_F"
    };
    vehicles[] =
    {
        "O_MBT_04_command_F"
    };
};

class O_Tigris : O_TankBase
{
    name = "ZSU-39 Tigris (AA)";
    tooltip = "Anti-air vehicle armed with rockets and powerful 30mm cannons.";
    units[] =
    {
        "O_crew_F",
        "O_crew_F",
        "O_crew_F"
    };
    vehicles[] =
    {
        "O_APC_Tracked_02_AA_F"
    };
    icon = "\A3\ui_f\data\map\markers\nato\o_support.paa";
};

class O_Sochor : O_ArtilleryBase
{
    name = "Sochor Artillery";
    tooltip = "CSAT 155mm artillery";
    units[] =
    {
        "O_crew_F",
        "O_crew_F",
        "O_crew_F"
    };
    vehicles[] =
    {
        "O_MBT_02_arty_F"
    };
}

class O_Orca : O_HeliBase
{
    name = "PO-30 Orca";
    tooltip = "Medium transport helicopter with 8 cargo seats, armed with rockets and machineguns.";
    units[] =
    {
        "O_Helipilot_F",
        "O_Helipilot_F"
    };
	vehicles[] =
	{
		"O_Heli_Light_02_F"
	};
};