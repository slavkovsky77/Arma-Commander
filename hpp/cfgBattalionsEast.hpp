class Recon_O : BattalionBase
{
	name = "CSAT Recon Battalion";
	faction = "CSAT";
	side = 0;
	flag = "\a3\Data_f\Flags\flag_CSAT_co.paa";
	icon = "\a3\Data_f\cfgFactionClasses_OPF_ca.paa";
	supports[] = {"Artillery155","Artillery82","Artillery155_Smoke","NeophronDefault","NeophronBomb"};

	class hqElement
	{
		name = "O_hqSquad";
	}

	class combatElement
	{
		class O_InfSquad
		{
			count = 12;
			skill = 0.4;
			cost = 12;
		}
		class O_ReconTeam
		{
			count = 10;
			skill = 0.6;
			cost = 10;
		}
		class O_AtTeam
		{
			count = 10;
			skill = 0.6;
			cost = 12;
		}
		class O_AATeam
		{
			count = 4;
			skill = 0.4;
			cost = 10;
		}
		class O_ViperSquad
		{
			count = 2;
			skill = 0.9;
			cost = 22;
		}
		class O_Recon_Motorized
		{
			count = 5;
			skill = 0.6;
			cost = 16;
		}
		class O_SniperTeam
		{
			count = 2;
			skill = 0.9;//0.75
			cost = 6;//7
		}
		class O_Kamysh
		{
			count = 4;
			skill = 0.4;
			cost = 35;
		}
		class O_Orca
		{
			count = 2;
			skill = 0.6;
			cost = 30;
		}
	}
	class Reserves
	{
		modifier = 1.25;
		skill = 0.4;
		units[] =
		{
            "O_soldier_SL_F",
            "O_soldier_F",
            "O_soldier_LAT_F",
            "O_soldier_LAT_F",
            "O_soldier_AT_F",
            "O_soldier_M_F",
            "O_soldier_TL_F",
            "O_soldier_AR_F",
            "O_soldier_A_F",
            "O_medic_F"
		};
	}
}

// Guard battalion
class Infantry_O : BattalionBase
{
	name = "CSAT Guard Infantry Battalion";
	faction = "CSAT";
	side = 0;
	flag = "\a3\Data_f\Flags\flag_CSAT_co.paa";
	icon = "\a3\Data_f\cfgFactionClasses_OPF_ca.paa";
	supports[] = {"Artillery82","Artillery82_Smoke","NeophronDefault"};

	class hqElement
	{
		name = "O_hqSquad";
	}

	class combatElement
	{
		class O_InfSquad_Urban
		{
			count = 14;
			skill = 0.4;
			cost = 12;
		}
		class O_UrbanTeam
		{
			count = 6;
			skill = 0.4;
			cost = 8;
		}
		class O_UrbanSquad
		{
			count = 3;
			skill = 0.3;
			cost = 15;
		}
		class O_AtTeamUrban
		{
			count = 10;
			skill = 0.6;
			cost = 12;
		}
		class O_AATeamUrban
		{
			count = 4;
			skill = 0.4;
			cost = 10;
		}
		class O_Patrol_Motorized
		{
			count = 2;
			skill = 0.4;
			cost = 22;
		}
		class O_Marid
		{
			count = 2;
			skill = 0.4;
			cost = 27;
		}
		class O_Kamysh
		{
			count = 2;
			skill = 0.4;
			cost = 35;
		}
	}
	class Reserves
	{
		modifier = 0.85;
		skill = 0.3;
		units[] =
		{
			// Urban variants
            "O_soldierU_SL_F",
            "O_soldierU_F",
            "O_soldierU_LAT_F",
            "O_soldierU_LAT_F",
            "O_soldierU_AT_F",
            "O_soldierU_M_F",
            "O_soldierU_TL_F",
            "O_soldierU_AR_F",
            "O_soldierU_A_F",
            "O_soldierU_medic_F"
		};
	}
}

class Tank_O : BattalionBase
{
	name = "CSAT Tank Battalion";
	faction = "CSAT";
	side = 0;
	flag = "\a3\Data_f\Flags\flag_CSAT_co.paa";
	icon = "\a3\Data_f\cfgFactionClasses_OPF_ca.paa";
	supports[] = {"Artillery155","Artillery155_Smoke","NeophronDefault"};

	class hqElement
	{
		name = "O_hqSquad";
	}

	class combatElement
	{
		class O_InfSquad
		{
			count = 12;
			skill = 0.4;
			cost = 12;
		}
		class O_ReconTeam
		{
			count = 4;
			skill = 0.6;
			cost = 10;
		}
		class O_AtTeam
		{
			count = 6;
			skill = 0.4;
			cost = 12;
		}
		class O_Marid
		{
			count = 2;
			skill = 0.4;
			cost = 28;
		}
		class O_Varsuk
		{
			count = 1;
			skill = 0.4;
			cost = 45;
		}
		class O_Angara
		{
			count = 1;
			skill = 0.4;
			cost = 55;
		}
		class O_Angara_K
		{
			count = 1;
			skill = 0.4;
			cost = 60;
		}
		class O_Tigris
		{
			count = 1;
			skill = 0.4;
			cost = 40;
		}
	}
	class Reserves
	{
		modifier = 1;
		skill = 0.3;
		units[] =
		{
            "O_soldier_SL_F",
            "O_soldier_F",
            "O_soldier_LAT_F",
            "O_soldier_LAT_F",
            "O_soldier_AT_F",
            "O_soldier_M_F",
            "O_soldier_TL_F",
            "O_soldier_AR_F",
            "O_soldier_A_F",
            "O_medic_F"
		};
	}
}


class Spetsnaz_O : BattalionBase
{
	name = "Spetsnaz Battalion";
	faction = "CSAT";
	side = 0;
	flag = "\a3\Data_f\Flags\flag_CSAT_co.paa";
	icon = "\a3\Data_f\cfgFactionClasses_OPF_ca.paa";
	supports[] = {"Artillery155","Artillery82","Artillery155_Smoke","NeophronDefault","NeophronBomb"};

	class hqElement
	{
		name = "O_R_hqSquad";
	}

	class combatElement
	{
		class O_R_InfSquad
		{
			count = 12;
			skill = 0.6;
			cost = 15;
		}
		class O_R_ReconTeam
		{
			count = 10;
			skill = 0.8;
			cost = 13;
		}
		class O_AtTeam
		{
			count = 10;
			skill = 0.6;
			cost = 12;
		}
		class O_R_Recon_Motorized
		{
			count = 4;
			skill = 0.8;
			cost = 18;
		}
		class O_Kamysh
		{
			count = 2;
			skill = 0.4;
			cost = 35;
		}
		class O_Angara
		{
			count = 1;
			skill = 0.4;
			cost = 55;
		}
		class O_Angara_K
		{
			count = 1;
			skill = 0.4;
			cost = 60;
		}
		class O_Tigris
		{
			count = 1;
			skill = 0.4;
			cost = 40;
		}
	}
	class Reserves
	{
		modifier = 1.25;
		skill = 0.5;
		units[] =
		{
            "O_R_soldier_LAT_F",
            "O_R_soldier_LAT_F",
            "O_soldier_AT_F",
            "O_R_soldier_M_F",
            "O_R_soldier_TL_F",
            "O_R_soldier_AR_F",
            "O_medic_F"
		};
	}
}


