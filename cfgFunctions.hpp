class cfgFunctions
{
    class AC
    {
        tag = "AC";
        class ArmaCommander
        {
			class ModuleAcGame {file = "\AC\functions\fn_moduleAcGame.sqf";};
			class NumberToSide {file = "\AC\functions\fn_numberToSide.sqf";};
			class Loaded {
					file = "\AC\functions\fn_loaded.sqf";
					preInit = 1;
				};
        };
	};
};