# Arma Commander

Arma Commander is large scale strategy game mode, in which player controls Army Battalion, and captures bases on the island. Player can control his troops from the map, or assume their direct control on the battlefield. Mode can be played in Single Player or Coop against AI Battalion, or in Team vs. Team setup.

## How to Play
- Launch Arma with the Mod
- Go to Multiplayer -> Server Browser -> Host Server
- Select one of the missions called Arma Commander (currently available on Malden only)
- (You can go to Params in lobby to change settings of the mission, select battalions fighting the battle, etc.)

## Game Rules

- Request troops of your selection on the battlefield
- Attack enemy and empty bases on the map
- Each captured base will generate some income to buy reinforcements
- Battalion that owns more bases when time runs out is victorious

## Game Mechanics

### Requesting units
Request new groups by pressing REQUISITION button on map screen.
You have to place landing zone and then order new groups.
New groups are bought for requisition points. There is limit on how many groups of one type you can request, and there is also limit on simultaneously deployed groups.

### Taking Control of Groups
You can assume direct control of your groups by clicking on 'Switch' button. You will switch into the leader of selected group (if it's not taken by another player), and fight on the batlefield yourself.
Only exception are artillery units, which has to be commanded remotely.

### Resupplying
Every group can take losses or run out of ammunition. For this there is resupply button on group tabs, which will refill the group into its original status. Ammmunition is refilled automatically and reinforcements are dropped on parachute.
Resupply is available when you have enough Requisition points and group is near a spawn base location.

### Capturing Bases
Capturing bases takes some time, so side of the opponent can react on the attack and try to deflect it. Capturing is indicated by symbol of the base on map going red, and percentage appearing next to base name. Progress of capturing is indicated by flag in the center of base going down, switching color and then going up. Only after attacker's flag gets on top of flag pole, and percentage of his color gets to 100% is base captured.

### Single Player, Coop, TvT
Arma Commander can be played in single player, as the mode was originally created for. But multiplayer is limited numbers is also supported, both Coop and TvT.

### Commanding and subordinates
When playing in multiple players on one side, only one can be commander. Other players can take control of groups, or all of them can cooperate in one group.

### Battalions
Player can select in lobby with which battalion he wants to fight with. Each battalion has composition of different group, providing different tactical options and different game experience.

###Game Modes
There are two types of mission, differing in starting situation:
Frontline: Both Battalions start with equal resources and starting bases.
Invasion: Invading Battalion start with only one base, but large resources, while defeners have most bases on the map, and very limited resources.

-----

## How to setup new Arma Commander Missions
1. Place Arma Commander Game Mode module on map.
2. Place two teams of playable units on their starting locations, they will become the command group for both sides.
3. Place two Battalion modules near the teams, select their side and battalion type, and select their starting resources (100-200 is good for start).
4. Place bases around the map.
4.1. Bases must belong to correct side — If NATO and CSAT battalions are fighting each other, do not place a Base with INDEP owner. You can place EMPTY base instead.
4.2. Select appropriate amount of defending soldiers.
4.3. You can create positions for defenders: Place group of soldiers into positions they should guard, and synchronize leader with module of the Base.
5. Create description.ext in the mission folder with the line below: It will include all required lobby parameters and respawn + revive settings.
6. #include "\AC\commonDescription.inc"

More detailed tutorial can be found here: https://steamcommunity.com/sharedfiles/filedetails/?id=1675219998

## FAQ:
Is Arma Commander compatible with other mods?
- Yes, you can create your own battalions and groups inside on any island, supporting any mod. Guide on how to do it is in discussions section.
Will there be some High Command functionality?
- High Command is hard to modify, so I don’t use it. But I want to improve the controls of the current interface (like chaining waypoints).
Are there more missions to play?
- Yes! There is dedicated channel for unofficial missions on the Discord server: https://discord.gg/M8ffgUX
- And there is workshop collection with Arma Commander missions: https://steamcommunity.com/sharedfiles/filedetails/?id=1595093662
Will there be more assets - helicopters, airplanes, naval?
- Yes, I want to support them at some point.


## Links:
- BI forums thread: https://forums.bohemia.net/forums/topic/220819-arma-commander-spcooptvt-game-mode/
- Discord Server: https://discord.gg/M8ffgUX
- Trello Board: https://trello.com/b/c4yJLqox
- Gitlab repository: https://gitlab.com/silliaris/arma-commander
- In-depth mission creation tutorials (thanks to FlaK): https://steamcommunity.com/sharedfiles/filedetails/?id=1675219998
