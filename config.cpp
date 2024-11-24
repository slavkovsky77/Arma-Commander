#include "BIS_AddonInfo.hpp"
class CfgPatches
{
	class AC
	{
		author="Will";
		name="AC Functions";
		url="";
		requiredAddons[] = {"A3_Functions_F"};		
        requiredVersion=0.1;
		units[]={};
		weapons[]={};
	};
};

#include "cfgMissions.hpp"
#include "cfgFunctions.hpp"
#include "cfgUI.hpp"

#include "defines\moduleDefines.inc"
#include "cfgVehicles.hpp"
#include "cfgFactionClasses.hpp"
#include "cfgNotifications.hpp"

class AC
{
	#include "hpp\cfgGroups.hpp"
	#include "hpp\cfgBattalions.hpp"
	#include "hpp\cfgSupports.hpp"
};