class Militia_FIA : BattalionBase
{
	name = "FIA Battalion";
	faction = "FIA";
	side = 1;

	flag = "\a3\Data_f\Flags\flag_FIA_co.paa";
	icon = "\a3\Data_f\cfgFactionClasses_IND_G_ca.paa";
	supports[] = {"Artillery82","Artillery82_Smoke"};

	class hqElement
	{
		name = "B_G_hqSquad";
	}

	class combatElement
	{
		class B_G_InfSquad
		{
			count = 14;
			skill = 0.3;//0.35
			cost = 8;
		}
		class B_G_InfTeam
		{
			count = 8;
			skill = 0.3;//0.35
			cost = 6;
		}
		class B_G_AtTeam
		{
			count = 10;
			skill = 0.4;//6
			cost = 8;
		}
		class B_CTRG_squad
		{
			count = 1;
			skill = 0.9;//0.78
			cost = 18;
		}
		class B_G_SniperTeam
		{
			count = 4;
			skill = 0.6;//0.7
			cost = 8;//6
		}
		class B_G_VeteranInfantry
		{
			count = 6;
			skill = 0.6;
			cost = 14;
		}
		class B_G_motorizedMG
		{
			count = 8;
			skill = 0.4;
			cost = 10;
		}
		class B_G_motorizedAT
		{
			count = 8;
			skill = 0.4;//6
			cost = 12;
		}
	}
	class Reserves
	{
		modifier = 0.675;
		skill = 0.3;
		units[] = {
			"B_G_officer_F",
			"B_G_Soldier_lite_F",
			"B_G_Soldier_GL_F",
			"B_G_Soldier_AR_F",
			"B_G_soldier_M_F",
			"B_G_Soldier_LAT_F",
			"B_G_Soldier_LAT_F",
			"B_G_Soldier_LAT_F",
			"B_G_medic_F"
		};
	}
}

class Recon_B : BattalionBase
{
	name = "NATO Ranger Battalion";
	faction = "NATO";
	side = 1;
	flag = "\a3\Data_f\Flags\flag_NATO_co.paa";
	icon = "\a3\Data_f\cfgFactionClasses_BLU_ca.paa";
	supports[] = {"Artillery155","ArtilleryMLRS","Artillery155_Smoke","WipeoutDefault","WipeoutGun","WipeoutBomb"};

	class hqElement
	{
		name = "B_hqSquad";
	}

	class combatElement
	{
		class B_InfSquad
		{
			count = 12;
			skill = 0.4;
			cost = 12;
		}
		class B_ReconTeam
		{
			count = 10;
			skill = 0.6;
			cost = 10;
		}
		class B_SniperTeam
		{
			count = 2;
			skill = 0.9;//0.75
			cost = 6;//8
		}
		class B_MotorizedRecon
		{
			count = 6;
			skill = 0.6;
			cost = 16;
		}
		class B_CTRG_squad
		{
			count = 1;
			skill = 0.9;//0.78
			cost = 18;
		}
		class B_AtTeam
		{
			count = 10;
			skill = 0.6;
			cost = 12;
		}
		class B_AATeam
		{
			count = 4;
			skill = 0.6;
			cost = 10;
		}
		class B_Marshall
		{
			count = 4;
			skill = 0.4;
			cost = 30;
		}
		class B_Hummingbird
		{
			count = 4;
			skill = 0.6;
			cost = 25;
		}
		class B_Ghosthawk
		{
			count = 2;
			skill = 0.6;
			cost = 35;
		}
	}
	class Reserves
	{
		modifier = 1.675;
		skill = 0.5;
		units[] = {
			// All types of units, even advanced launchers, etc.
			"B_officer_F",
			"B_Soldier_TL_F",
			"B_Soldier_AR_F",
			"B_Soldier_LAT_F",
			"B_Soldier_LAT_F",
			"B_Soldier_M_F",
			"B_soldier_AT_F",
			"B_medic_F"
		};
	}
}

class Tank_B : BattalionBase
{
	name = "NATO Mechanized Battalion";
	side = 1;
	faction = "NATO";
	flag = "\a3\Data_f\Flags\flag_NATO_co.paa";
	icon = "\a3\Data_f\cfgFactionClasses_BLU_ca.paa";
	supports[] = {"Artillery155","Artillery155_Smoke","WipeoutDefault"};

	class hqElement
	{
		name = "B_hqSquad";
	}

	class combatElement
	{
		class B_InfSquad
		{
			count = 12;
			skill = 0.4;
			cost = 12;
		}
		class B_ReconTeam
		{
			count = 4;
			skill = 0.5;
			cost = 10;
		}
		class B_AtTeam
		{
			count = 6;
			skill = 0.4;
			cost = 12;
		}
		class B_Panther
		{
			count = 1;
			skill = 0.4;
			cost = 30;
		}
		class B_Rhino
		{
			count = 1;
			skill = 0.4;
			cost = 40;
		}
		class B_Slammer
		{
			count = 1;
			skill = 0.4;
			cost = 45;
		}
		class B_SlammerUP
		{
			count = 1;
			skill = 0.4;
			cost = 50;
		}
		class B_Cheetah
		{
			count = 1;
			skill = 0.4;
			cost = 40;
		}
	}
	class Reserves
	{
		modifier = 1.25;
		skill = 0.4;
		units[] = {
			// All types of units, even advanced launchers, etc.
			"B_officer_F",
			"B_Soldier_TL_F",
			"B_Soldier_AR_F",
			"B_Soldier_LAT_F",
			"B_Soldier_LAT_F",
			"B_Soldier_M_F",
			"B_soldier_AT_F",
			"B_medic_F"
		};
	}
}

class Tank_B_W : BattalionBase
{
	name = "NATO Mechanized Battalion (Woodland)";
	side = 1;
	faction = "NATO";
	flag = "\a3\Data_f\Flags\flag_NATO_co.paa";
	icon = "\a3\Data_f\cfgFactionClasses_BLU_ca.paa";
	supports[] = {"Artillery155","Artillery155_Smoke","WipeoutDefault"};

	class hqElement
	{
		name = "B_W_hqSquad";
	}

	class combatElement
	{
		class B_W_InfSquad
		{
			count = 12;
			skill = 0.4;
			cost = 12;
		}
		class B_W_AtTeam
		{
			count = 6;
			skill = 0.4;
			cost = 12;
		}
		class B_W_Panther
		{
			count = 1;
			skill = 0.4;
			cost = 30;
		}
		class B_W_Rhino
		{
			count = 1;
			skill = 0.4;
			cost = 40;
		}
		class B_W_Slammer
		{
			count = 1;
			skill = 0.4;
			cost = 45;
		}
		class B_W_SlammerUP
		{
			count = 1;
			skill = 0.4;
			cost = 50;
		}
		class B_W_Cheetah
		{
			count = 1;
			skill = 0.4;
			cost = 40;
		}
	}
	class Reserves
	{
		modifier = 1.25;
		skill = 0.4;
		units[] = {
			// All types of units, even advanced launchers, etc.
			"B_W_officer_F",
			"B_W_Soldier_TL_F",
			"B_W_Soldier_AR_F",
			"B_W_Soldier_LAT2_F",
			"B_W_Soldier_LAT2_F",
			"B_W_Soldier_M_F",
			"B_W_soldier_AT_F",
			"B_W_medic_F"
		};
	}
}
