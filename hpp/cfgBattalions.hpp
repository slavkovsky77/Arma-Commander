#include "\AC\defines\commonDefines.inc"

class Battalions
{
	class BattalionBase
	{
		name = "BattalionBase";
		side = 8;
		faction = "FIA";

		flag = "\a3\Data_f\Flags\flag_FIA_co.paa";
		icon = "\a3\Data_f\cfgFactionClasses_IND_G_ca.paa";

		supports[] = {};

		class hqElement {}
		class combatElement {}

		class Reserves
		{
			modifier = 1;
			skill = 0.4;
			units[] = {};
		}
	}

	#include "\AC\hpp\cfgBattalionsWest.hpp"
	#include "\AC\hpp\cfgBattalionsEast.hpp"
	#include "\AC\hpp\cfgBattalionsIndependent.hpp"
}