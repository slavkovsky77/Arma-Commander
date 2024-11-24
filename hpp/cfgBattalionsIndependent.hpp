class Militia_Syndikat : BattalionBase
{
	name = "Syndikat Battalion";
	faction = "Syndikat";
	side = 2;
	flag = "\a3\Data_F_Exp\Flags\flag_SYND_CO.paa";
	icon = "\a3\Data_F_Exp\FactionIcons\icon_SYND_CA.paa";
	supports[] = {"Artillery82","Artillery82_Smoke"};

	class hqElement
	{
		name = "I_C_hqSquad";
	}

	class combatElement
	{
		class I_C_infantrySquad_Para
		{
			count = 12;
			skill = 0.4;
			cost = 9;
		}
		class I_C_infantryTeam_Bandit
		{
			count = 10;
			skill = 0.3;
			cost = 5;
		}
		class I_C_infantrySquad_Bandit
		{
			count = 10;
			skill = 0.3;
			cost = 11;
		}
		class I_C_AtTeam
		{
			count = 10;
			skill = 0.4; //6
			cost = 8;
		}
		class I_C_Motorized_MG
		{
			count = 8;
			skill = 0.4;
			cost = 13; //12
		}
		class I_C_Motorized_AT
		{
			count = 8;
			skill = 0.4;//6
			cost = 15; //14
		}
	}
	class Reserves
	{
		modifier = 0.675;
		skill = 0.3;
		units[] =
		{
			"I_C_Soldier_Bandit_4_F",
			"I_C_Soldier_Bandit_3_F",
			"I_C_Soldier_Bandit_5_F",
			"I_C_Soldier_Bandit_6_F",
			"I_C_Soldier_Bandit_2_F",
			"I_C_Soldier_Bandit_8_F",
			"I_C_Soldier_Bandit_1_F",
			"I_C_Soldier_Para_2_F",
			"I_C_Soldier_Para_2_F",
			"I_C_Soldier_Para_2_F",
			"I_C_Soldier_Para_4_F",
			"I_C_Soldier_Para_6_F",
			"I_C_Soldier_Para_1_F",
			"I_C_Soldier_Para_7_F",
			"I_C_Soldier_Para_5_F",
			"I_C_Soldier_Para_8_F",
			"I_C_Soldier_Para_3_F"
		};
	}
}

class Mechanized_I : BattalionBase
{
	name = "AAF Mechanized Battalion";
	faction = "AAF";
	side = 2;
	flag = "\a3\Data_f\Flags\Flag_AAF_CO.paa";
	icon = "\a3\Data_f\cfgFactionClasses_IND_ca.paa";
	supports[] = {"Artillery155","ArtilleryMLRS","Artillery155_Smoke","BuzzardDefault","BuzzardBomb"};

	class hqElement
	{
		name = "I_hqSquad";
	}

	class combatElement
	{
		class I_infantrySquad
		{
			count = 12;
			skill = 0.4;
			cost = 12;
		}
		class I_infantryTeam
		{
			count = 10;
			skill = 0.4;
			cost = 6;
		}
		class I_SniperTeam
		{
			count = 2;
			skill = 0.8;
			cost = 5;
		}
		class I_AtTeam
		{
			count = 10;
			skill = 0.6;
			cost = 12;
		}

		class I_Gorgon
		{
			count = 2;
			skill = 0.4;
			cost = 32;
		}
		class I_mora
		{
			count = 4;
			skill = 0.4;
			cost = 28;
		}
		class I_kuma
		{
			count = 1;
			skill = 0.4;
			cost = 45;
		}
		class I_NyxAA
		{
			count = 2;
			skill = 0.4;
			cost = 30;
		}
		class I_Mohawk
		{
			count = 1;
			skill = 0.6;
			cost = 35;
		}
	}
	class Reserves
	{
		modifier = 0.675;
		skill = 0.3;
		units[] =
		{
			"I_officer_F",
			"I_Soldier_TL_F",
			"I_Soldier_AR_F",
			"I_Soldier_LAT2_F",
			"I_Soldier_LAT2_F",
			"I_Soldier_M_F",
			"I_soldier_AT_F",
			"I_medic_F"
		};
	}
}

class Battalion_LDF : BattalionBase
{
	name = "Livonian Defense Battalion";
	faction = "LDF";
	side = 2;
	flag = "\a3\Data_F_Enoch\Flags\flag_EAF_co.paa";
	icon = "\a3\Data_F_Enoch\FactionIcons\icon_EAF_CA.paa";
	supports[] = {"Artillery155","ArtilleryMLRS","Artillery155_Smoke"};

	class hqElement
	{
		name = "I_E_hqSquad";
	}

	class combatElement
	{
		class I_E_infantrySquad
		{
			count = 12;
			skill = 0.4;
			cost = 12;
		}
		class I_E_infantryTeam
		{
			count = 10;
			skill = 0.4;
			cost = 6;
		}
		class I_E_AtTeam
		{
			count = 10;
			skill = 0.6;
			cost = 12;
		}

		class I_E_Odyniec
		{
			count = 8;
			skill = 0.4;
			cost = 25;
		}
		class I_E_Heli
		{
			count = 1;
			skill = 0.6;
			cost = 30;
		}
	}
	class Reserves
	{
		modifier = 0.675;
		skill = 0.3;
		units[] =
		{
			"I_E_officer_F",
			"I_E_Soldier_TL_F",
			"I_E_Soldier_AR_F",
			"I_E_Soldier_LAT2_F",
			"I_E_Soldier_LAT2_F",
			"I_E_Soldier_M_F",
			"I_E_soldier_AT_F",
			"I_E_medic_F"
		};
	}
}