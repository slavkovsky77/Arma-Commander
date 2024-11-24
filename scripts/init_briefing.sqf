player createDiarySubject ["AC","Arma Commander"];

player createDiaryRecord [
	"Diary",
	[
		"Game Rules",
		"Capture bases on the map. <br/>Every captured base will give your side income. <br/>When scenario time runs out, side with more bases wins."
	]
];

player createDiaryRecord [
	"AC",
	[
		"Commanding and subordinates",
		"When playing in multiple players on one side, only one can be commander. Other players can take control of groups, or all of them can cooperate in one group."
	]
];
player createDiaryRecord [
	"AC",
	[
		"Single Player, Coop, TvT",
		"Arma Commander can be played in single player, as the mode was originally created for. But multiplayer is limited numbers is also supported, both Coop and TvT."
	]
];
player createDiaryRecord [
	"AC",
	[
		"Capturing Bases",
		"Capturing bases takes some time, so side of the opponent can react on the attack and try to deflect it. Capturing is indicated by symbol of the base on map going red, and percentage appearing next to base name. Progress of capturing is indicated by flag in the center of base going down, switching color and then going up. Only after attacker's flag gets on top of flag pole, and percentage of his color gets to 100% is base captured."
	]
];
player createDiaryRecord [
	"AC",
	[
		"Resupplying",
		"Every group can take losses, run out of ammunition or just lost its transport. For this there is resupply button on group tabs, which will refill the group into its original status. Ammmunition is refilled automatically and reinforcements are dropped on parachute. <br/>Resupply is available when you have enough Requisition points and group is near a base far enough from the fighting."
	]
];
player createDiaryRecord [
	"AC",
	[
		"Taking Control of Groups",
		"You can assume direct control of your groups by clicking on 'Switch' button. You will switch into the leader of selected group (if it's not taken by another player), and fight on the batlefield yourself. <br/>Only exception are artillery units, which has to be commanded remotely."
	]
];
player createDiaryRecord [
	"AC",
	[
		"Requesting units",
		"Request new groups by pressing REQUISITION button on map screen. <br/>You have to place landing zone and then order new groups.<br/>New groups are bought for requisition points. There is limit on how many groups of one type you can request, and there is also limit on simultaneously deployed groups."
	]
];

if (hasInterface && isMultiplayer) then {
	titlecut ["","BLACK FADED",10];
};

/*
"Game Rules"
"Capture bases on the map<br/> Every captured base will give your side income. <br/>When scenario time runs out, side with more bases wins."

// Game mechanics
"Requesting units"
"Request new groups by pressing REQUISITION button on map screen. <br/>You have to place landing zone and then order new groups.<br/>New groups are bought for requisition points. There is limit on how many groups of one type you can request, and there is also limit on simultaneously deployed groups."

"Taking Control of Groups"
"You can assume direct control of your groups by clicking on 'Switch' button. You will switch into the leader of selected group (if it's not taken by another player), and fight on the batlefield yourself. <br/>Only exception are artillery units, which has to be commanded remotely."

"Resupplying"
"Every group can take losses, run out of ammunition or just lost its transport. For this there is resupply button on group tabs, which will refill the group into its original status. Ammmunition is refilled automatically and reinforcements are dropped on parachute. <br/>Resupply is available when you have enough Requisition points and group is far enough from the fighting."

"Capturing Bases"
"Capturing bases takes some time, so side of the opponent can react on the attack and try to deflect it. Capturing is indicated by symbol of the base on map going red, and percentage appearing next to base name. Progress of capturing is indicated by flag in the center of base going down, switching color and then going up. Only after attacker's flag gets on top of flag pole, and percentage of his color gets to 100% is base captured."

"Single Player, Coop, TvT"
"Arma Commander can be played in single player, as the mode was originally created for. But multiplayer is limited numbers is also supported, both Coop and TvT. "

"Commanding and subordinates"
"When playing in multiple players on one side, only one can be commander. Other players can take control of groups, or all of them can cooperate in one group."
*/
