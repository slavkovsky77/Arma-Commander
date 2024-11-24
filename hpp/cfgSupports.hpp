#include "\AC\defines\commonDefines.inc"

class Supports
{
    class SupportBase {
        name = "ArtillerySupport";
        tooltip = "Empty Tooltip";
        cost = 15;
        timeout = 30;
        nRounds = 4;
        type = SUPPORT_ARTY;
        ammo = "Sh_155mm_AMOS";
        radius = 100;
    };
    class Artillery155: SupportBase {
        name = "155 mm Artillery Strike";
        tooltip = "4 rounds strike in 100 meter radius";
        cost = 15;
        timeout = 30;
        nRounds = 4;
        type = SUPPORT_ARTY;
        ammo = "Sh_155mm_AMOS";
        radius = 100;
    };
    class Artillery155_Smoke: SupportBase {
        name = "155 mm Smoke Screen";
        tooltip = "4 rounds strike in 100 meter radius";
        cost = 10;
        timeout = 30;
        nRounds = 4;
        type = SUPPORT_ARTY;
        ammo = "Smoke_120mm_AMOS_White";
        radius = 100;
    };

    class Artillery82: SupportBase {
        name = "82 mm Mortar Strike";
        tooltip = "8 rounds strike in 120 meter radius";
        cost = 10;
        timeout = 15;
        nRounds = 8;
        type = SUPPORT_ARTY;
        ammo = "Sh_82mm_AMOS";
        radius = 120;
    };
    class Artillery82_Smoke: SupportBase {
        name = "82 mm Smoke Screen";
        tooltip = "8 rounds strike in 120 meter radius";
        cost = 6;
        timeout = 15;
        nRounds = 8;
        type = SUPPORT_ARTY;
        ammo = "Smoke_82mm_AMOS_White";
        radius = 120;
    };

    class ArtilleryMLRS: SupportBase {
        name = "230 mm Rocket Strike";
        tooltip = "Cluster strike in 80 meter radius";
        cost = 20;
        timeout = 30;
        nRounds = 1;
        type = SUPPORT_ARTY;
        ammo = "R_230mm_Cluster"; //R_230mm_HE is bugged, flying into wrong areas
        radius = 80;
    };

    class NeophronDefault: SupportBase {
        name = "To-199 Air Strike";
        tooltip = "To-199 Neophron Air Strike with cannon and missiles";
        cost = 25;
        timeout = 30;
        nRounds = SUPPORT_COMBINED;
        type = SUPPORT_CAS;
        ammo = "O_Plane_CAS_02_F";
        radius = 500;
    };
    class NeophronBomb: SupportBase {
        name = "To-199 Bomb Run";
        tooltip = "To-199 Neophron Air Strike with 250 KG bombs";
        cost = 25;
        timeout = 30;
        nRounds = SUPPORT_BOMBS;
        type = SUPPORT_CAS;
        ammo = "O_Plane_CAS_02_F";
        radius = 700;
    };
    class WipeoutDefault: SupportBase {
        name = "A-164 Air Strike";
        tooltip = "A-164 Wipeout Air Strike with cannon and missiles";
        cost = 28;
        timeout = 30;
        nRounds = SUPPORT_COMBINED;
        type = SUPPORT_CAS;
        ammo = "B_Plane_CAS_01_F";
        radius = 500;
    };
    class WipeoutGun: SupportBase {
        name = "A-164 Gun Run";
        tooltip = "BRRRRRRRRT!";
        cost = 10;
        timeout = 30;
        nRounds = SUPPORT_CANNON;
        type = SUPPORT_CAS;
        ammo = "B_Plane_CAS_01_F";
        radius = 500;
    };
    class WipeoutBomb: SupportBase {
        name = "A-164 Bomb Run";
        tooltip = "A-164 Wipeout Air Strike with GBU-12";
        cost = 28;
        timeout = 30;
        nRounds = SUPPORT_BOMBS;
        type = SUPPORT_CAS;
        ammo = "B_Plane_CAS_01_F";
        radius = 700;
    };
    class BuzzardDefault: SupportBase {
        name = "A-143 Air Strike";
        tooltip = "A-143 Buzzard Air Strike with cannon and missiles";
        cost = 22;
        timeout = 30;
        nRounds = SUPPORT_COMBINED;
        type = SUPPORT_CAS;
        ammo = "I_Plane_Fighter_03_CAS_F";
        radius = 700;
    };
    class BuzzardBomb: SupportBase {
        name = "A-143 Bomb Run";
        tooltip = "A-143 Buzzard Air Strike with 250 KG bomb";
        cost = 25;
        timeout = 30;
        nRounds = SUPPORT_BOMBS;
        type = SUPPORT_CAS;
        ammo = "I_Plane_Fighter_03_CAS_F";
        radius = 700;
    };
}