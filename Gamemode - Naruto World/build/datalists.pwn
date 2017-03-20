new Scripts[][32] =
{
	"header",	// [02] Header script:		First script to be loaded
	"timer",	// [26] Timer system:		Handling any timed action in each other script
	"net",		// [05] Net system:			Preparing client socket connections and new functions
	"misc",		// [01] Miscellaneous:		Anything not related to the other scripts
	"path",		// [29] Paths:				Arrange positions and paths, mainly for NPCs
	"npcs",		// [20] NPCs:				Connecting non-playing characters
	"security",	// [16] Security script:	Anti-cheat and main security systems
	"camera",	// [13] Camera:				Used as camera library, camera interpolation and movies
	"target",	// [25] Target:				Used as camera library, camera interpolation and movies
	"pickups",  // [15] Pickups:			Teleports, info pickups and etc
	"nametags", // [19] Name-tags:			Player details written on each player in-game
	"chars",	// [06] Characters:			Characters library and information loading
	"drawing",	// [09] Drawing:			Text and images to be drawn on the screen as 2D
	"sound",	// [12] Sound:				Play and use sounds/musics in-game
	"support",	// [17] Support:			Help commands, menus and options, and also game descriptions
	"user",		// [08] Accounts:			Accounts, registration and login script
	"admin",	// [14] Administration:		Admin mode, admin commands and etc
	"intro",	// [28] Introduction:		Opening screen
	"powers",	// [22] Powers:				Player powers/abilities to be casted in-game
	"gameplay",	// [07] Gameplay:			Anything related to the gameplay itselfs (stats, fighting, etc)
	"control",	// [24] Controller:			Main menu options, HUD buttons, keys, game controller and etc
	"chat",		// [04] Chat:				Game chat writing and reading + functions
	"bgmusic",	// [33] Background Music:	Play and sync background soundtracks
	"map",		// [11] Map:				World full map built with objects
	"teams",	// [10] Teams:				Teams library, team information and in-game spawns
	"money",	// [18] Money:				Script and library used for ryo (money)
	"world",	// [21] World gameplay:		Managing weather, time and more world stuff
	"level",	// [23] Levels:				Player XP and levels system
	"anim",		// [27] Animations:			Player animations
	"village",	// [30] Village:			Village management and population
	"sobjects", // [31] Special Objects:	Usable and scripted objects over all the map
	"perms",	// [32] Permissions:		Managing player in-game permissions
	"footer"	// [03] Footer script:		Last script to be loaded
}, cache_prefix = (_:cache_func)+(_:cache_max_func)+((_:cache_max_func)*(sizeof(Scripts)-1))+1;
new Levels[][data_Level] =
{
	{0,"None"},
	{250,"Player Level 1 Name"},
	{550,"Player Level 2 Name"},
	{900,"Player Level 3 Name"},
	{1300,"Player Level 4 Name"},
	{1750,"Player Level 5 Name"},
	{2250,"Player Level 6 Name"},
	{2800,"Player Level 7 Name"},
	{3400,"Player Level 8 Name"},
	{4050,"Player Level 9 Name"},
	{4750,"Player Level 10 Name"},
	{5500,"Player Level 11 Name"},
	{6300,"Player Level 12 Name"},
	{7150,"Player Level 13 Name"},
	{8050,"Player Level 14 Name"},
	{9000,"Player Level 15 Name"},
	{10000,"Player Level 16 Name"},
	{11050,"Player Level 17 Name"},
	{12150,"Player Level 18 Name"},
	{13300,"Player Level 19 Name"},
	{14500,"Player Level 20 Name"},
	{15750,"Player Level 21 Name"},
	{17050,"Player Level 22 Name"},
	{18400,"Player Level 23 Name"},
	{19800,"Player Level 24 Name"},
	{21250,"Player Level 25 Name"},
	{22750,"Player Level 26 Name"},
	{24300,"Player Level 27 Name"},
	{25900,"Player Level 28 Name"},
	{27550,"Player Level 29 Name"},
	{29250,"Player Level 30 Name"}
};
new SkinList[][data_Skin] =
{
	// Creation Skins
	{88,"Naruto_Uzumaki"},
	{111,"Sasuke_Uchiha"},
	{137,"Sakura_Haruno"},
	{50,"Kakashi_Hatake"},
	{105,"Sai"},
	{133,"Yamato"},
	{103,"Rock_Lee"},
	{93,"Neji_Hyuuga"},
	{122,"Tenten"},
	{27,"Might_Guy"},
	{116,"Shikamaru Nara"},
	{14,"Choji_Akimichi"},
	{37,"Ino_Yamanaka"},
	{11,"Asuma_Sarutobi"},
	{35,"Hinata_Hyuuga"},
	{61,"Kiba_Inuzuka"},
	{117,"Shino_Aburame"},
	{71,"Kurenai_Yuhi"},
	{26,"Gaara"},
	{58,"Kankuro"},
	{121,"Temari"},
	{12,"Baki"},
	{13,"Chiyo"},
	{39,"Iruka_Umino"},
	{22,"Ebisu"},
	{10,"Aoba"},
	{70,"Kotetsu_Hagane"},
	{44,"Izumo_Kamizuki"},
	{38,"Inoichi_Yamanaka"},
	{115,"Shikaku_Nara"},
	{73,"Kushina_Uzumaki"},
	{2,"Anko"},
	{69,"Konohamaru_Sarutobi"},
	{118,"Shizune"},
	{129,"Tsunade"},
	{46,"Jiraiya"},
	{95,"Orochimaru"},
	{33,"Hashirama_Senju"},
	{127,"Tobirama_Senju"},
	{36,"Hiruzen_Sarutobi"},
	{82,"Minato_Namikaze"},
	{16,"Danzo_Shimura"},
	{41,"Itachi_Uchiha"},
	{67,"Kisame"},
	{34,"Hidan"},
	{54,"Kakuzu"},
	{40,"Hiruko"},
	{19,"Deidara"},
	{68,"Konan"},
	{151,"KonanWings"},
	{85,"Nagato"},
	{48,"Kabuto"},
	{119,"Suigetsu"},
	{47,"Juugo"},
	{59,"Karin_Uzumaki"},
	{63,"KillerBee"},
	{1,"A"},
	{80,"Mei_Terumi"},
	{81,"Mifune"},
	{94,"Onoki"},
	{131,"White_Zetsu"},
	{135,"Zetsu"},
	{130,"Utakata"},
	{24,"Fu"},
	{132,"Yagura"},
	{134,"Yugito"},
	{104,"Roshi"},
	{31,"Han"},
	{124,"Tobi"},
	{120,"Tayuya"},
	{106,"SakonandUkon"},
	{62,"Kidomaru"},
	{65,"Kimimaro"},
	{102,"Third_Raikage"},
	{83,"Second_Mizukage"},
	{84,"Mu"},
	{60,"Fourth_Kazekage"},
	{30,"Haku"},
	{29,"Ginkaku"},
	{66,"Kinkaku"},
	{32,"Hanzo"},
	{128,"Torune"},
	{25,"Fuu"},
	{9,"Ao"},
	{15,"Chojuro"},
	{114,"Shi"},
	{18,"Darui"},
	{72,"Kurotsuchi"},
	{45,"Izuna_Uchiha"},
	{75,"Madara_Uchiha"},
	{108,"Sasori"},
	{17,"DanzoShimura2"},
	{20,"Deidara2"},
	{21,"DeidaraDead"},
	{23,"Enma"},
	{28,"GedoMazo"},
	{42,"ItachiUchiha2"},
	{43,"ItachiUchihaDead"},
	{49,"Kabuto2"},
	{51,"KakashiHatake2"},
	{52,"KakashiHatake3"},
	{55,"Kakuzu2"},
	{56,"Kakuzu3"},
	{57,"KakuzuDead"},
	{64,"KillerBee2"},
	{76,"MadaraUchihaS"},
	{77,"MadaraUchihaR"},
	{78,"MadaraUchihaMS"},
	{79,"MadaraUchihaES"},
	{86,"NagatoDead"},
	{87,"NagatoDead2"},
	{89,"NarutoUzumakiSix"},
	{90,"NarutoUzumakiAnger"},
	{91,"NarutoUzumakiNTMode"},
	{145,"NarutoUzumakiSageMode"},
	{96,"PainPath_Animal"},
	{97,"PainPath_Asura"},
	{98,"PainPath_Deva"},
	{99,"PainPath_Human"},
	{100,"PainPath_Naraka"},
	{101,"PainPath_Preta"},
	{107,"Samurai"},
	{109,"Sasori2"},
	{110,"SasoriDead"},
	{112,"Sasuke_UchihaTaka"},
	{113,"Sasuke_UchihaES"},
	{123,"Teuchi"},
	{125,"Tobi2"},
	{126,"Tobi3"},
	{136,"KingofHell"},
	{138,"Ameyuri_Ringo"},
	{139,"Fuguki_Suikazan"},
	{140,"Jinin_Akebino"},
	{141,"Jinpachi_Munaishi"},
	{142,"Kushimaru_Kuriarare"},
	{143,"Mangetsu_Hoozuki"},
	{144,"Zabuza_Momochi"},
	// Beta Test Skins
	{166,"Villager"}
};
new PlayerActions[][2] =
{
	{1197,ACTION_JUMP},		// JUMP_LAUNCH
	{1198,ACTION_JUMP},		// JUMP_LAUNCH_R
	{1196,ACTION_LAND},		// JUMP_LAND
	{1129,ACTION_LAND},		// FALL_COLLAPSE
	{1246,ACTION_SPRINT},	// SPRINT_CIVI
	{1130,ACTION_FALL}		// FALL_FALL
};
new MenuOptions[MAX_MENU_BUTTONS][16] =
{
	"MENU",
	"STATS",
	"FRIENDS",
	"PARTY",
	"MAP",
	"OPTIONS"
};
new PInfoTypes[][32] =
{
	"Stats",
	"Detailed Stats",
	"Character (Lore)",
	"Profile",
	"Friend List",
	"Accolades",
	"Acheivements"
};
new StartOptions[MAX_STARTUP_BUTTONS][data_StartupButtons] =
{
	#define START_OPTION_WORLD 0
	{"NARUTO WORLD",14549042},
	#define START_OPTION_BATTLE 1
	{"FREE BATTLES",14549042},
	#define START_OPTION_TRAINING 2
	{"TRAINING",14549042},
	#define START_OPTION_MOVIE 3
	{"MOVIE MAKER",14549042},
	#define START_OPTION_TUTORIALS 4
	{"TUTORIALS",56882},
	#define START_OPTION_MOVIES 5
	{"MOVIES",56882},
	#define START_OPTION_BG 6
	{"GAME INFO & BG",56882},
	#define START_OPTION_COMMUNITY 7
	{"COMMUNITY",56882},
	#define START_OPTION_SETTINGS 8
	{"SETTINGS",56882},
	#define START_OPTION_EXIT 9
	{"EXIT GAME",-570425294}
};
new CommunityLinks[][data_Link] =
{
	{"Website",WEBURL,link_website},
	{"Register a Character","google.co.il",link_website},
	{"Community Forum","sa-mp.co.il",link_website},
	{"Community TeamSpeak","ts.sa-mp.co.il:9600",link_teamspeak}
};
new SpecialObjects[][data_SpecialObject] =
{
	{sotype_plant,653,2.8,7.0,0,soeffect_damage,0.6,70.0}, // Cactus
	{sotype_plant,757,1.8,2.0,0,soeffect_damage,0.9,40.0}, // Cactus
	{sotype_plant,5045,4.5,6.0,0,soeffect_poison,0.2,150.0}, // Mushroom
	{sotype_plant,5052,7.5,5.0,0,soeffect_poison,0.2,300.0}, // Mushroom
	{sotype_plant,5053,6.5,4.0,0,soeffect_poison,0.2,250.0}, // Mushroom
	{sotype_plant,5057,14.0,2.0,0,soeffect_plantsnd,0.0,50.0}, // Plants
	{sotype_plant,5055,11.0,2.0,0,soeffect_plantsnd,0.0,50.0}, // Plants
	{sotype_plant,5417,5.0,3.0,0,soeffect_plantsnd,0.0,65.0}, // Plants
	{sotype_plant,5360,6.0,5.0,0,soeffect_plantsnd,0.0,85.0}, // Plants
	{sotype_plant,762,5.0,10.0,0,soeffect_plantsnd,0.0,70.0}, // Plants
	{sotype_plant,826,4.0,4.0,0,soeffect_plantsnd,0.0,65.0}, // Plants
	{sotype_plant,5056,8.0,21.0,0,soeffect_plantsnd,0.0,110.0}, // Plants
	{sotype_street,1256,5.0,2.2,3,soeffect_none,0.0,350.0}, // Bench
	{sotype_pickup,2936,2.5,1.5,0,soeffect_none,2.0,0.0}, // Rock
	{sotype_tree,845,6.0,2.0,0,soeffect_none,0.0,300.0}, // Tree
	{sotype_tree,664,4.0,52.0,0,soeffect_none,0.0,1500.0}, // Tree
	{sotype_tree,5354,4.0,41.0,0,soeffect_none,0.0,1500.0}, // Tree
	{sotype_tree,5396,14.0,30.0,5,soeffect_none,0.0,1500.0}, // Tree
	//{sotype_tree,5096,blah,blah,blah,blah,blah},// DAMN THAT'S TOO BIG!
	{sotype_tree,5361,3.0,9.0,0,soeffect_none,0.0,300.0}, // Tree
	{sotype_tree,5433,8.0,30.0,2,soeffect_none,0.0,850.0}, // Tree
	{sotype_tree,5464,10.0,34.0,1,soeffect_none,0.0,950.0}, // Tree
	{sotype_tree,5359,4.0,48.0,3,soeffect_none,0.0,1200.0} // Tree
};
new Names[][data_Name] =
{
	// Male Names
	{"Zachary",1},
	{"Camren",1},
	{"Ramiro",1},
	{"Keagan",1},
	{"Lee",1},
	{"Jayce",1},
	{"Holden",1},
	{"Joshua",1},
	{"Savion",1},
	{"Bernard",1},
	{"Leland",1},
	{"Edwin",1},
	{"Alejandro",1},
	{"Aldo",1},
	{"Avery",1},
	{"Bennett",1},
	{"Carlos",1},
	{"Tyree",1},
	{"Cyrus",1},
	{"Thaddeus",1},
	{"Winston",1},
	{"Aaron",1},
	{"Yair",1},
	{"Kadyn",1},
	{"Arjun",1},
	{"Harrison",1},
	{"Lawrence",1},
	{"Byron",1},
	{"Jamal",1},
	{"Kristian",1},
	{"Lewis",1},
	{"Zaiden",1},
	{"Bryan",1},
	{"Tyrese",1},
	{"Casey",1},
	{"Leonard",1},
	{"Leroy",1},
	{"Christopher",1},
	{"Ronald",1},
	{"Bronson",1},
	{"Rex",1},
	{"Arnav",1},
	{"Silas",1},
	{"Tristan",1},
	{"Brian",1},
	{"Garrett",1},
	{"Levi",1},
	{"Kaeden",1},
	{"Armani",1},
	{"Cade",1},
	{"Damien",1},
	{"Mark",1},
	{"Peter",1},
	{"Aedan",1},
	{"Callum",1},
	{"Malachi",1},
	{"Tucker",1},
	{"Nasir",1},
	{"Raphael",1},
	{"Aiden",1},
	{"Leo",1},
	{"Devyn",1},
	{"Ryan",1},
	{"Anthony",1},
	{"Cesar",1},
	{"Simon",1},
	{"Gunner",1},
	{"Abdiel",1},
	{"Deon",1},
	{"Gustavo",1},
	{"Jamie",1},
	{"Alden",1},
	{"Malaki",1},
	{"Richard",1},
	{"Andrew",1},
	{"Gaige",1},
	{"Jamari",1},
	{"Yurem",1},
	{"Maximilian",1},
	{"Izaiah",1},
	{"Killian",1},
	{"Darion",1},
	{"Kasey",1},
	{"Quinton",1},
	{"Gabriel",1},
	{"Carmelo",1},
	{"Sheldon",1},
	{"Gordon",1},
	{"Ethan",1},
	{"Van",1},
	{"Dereon",1},
	{"Nathan",1},
	{"Jimmy",1},
	{"Franklin",1},
	{"Niko",1},
	{"Leonardo",1},
	{"Landin",1},
	{"Aydin",1},
	{"Uzi",1},
	{"Houston",1},
	// Female Names
	{"Amina",2},
	{"Leah",2},
	{"Janelle",2},
	{"Kaylee",2},
	{"Alma",2},
	{"Anika",2},
	{"Belen",2},
	{"Addisyn",2},
	{"Jayla",2},
	{"Mariah",2},
	{"Janiya",2},
	{"Yaretzi",2},
	{"Kaitlin",2},
	{"Anahi",2},
	{"Jennifer",2},
	{"Mckinley",2},
	{"Mayra",2},
	{"Pamela",2},
	{"Ayanna",2},
	{"Mariela",2},
	{"Jazlyn",2},
	{"Zion",2},
	{"Haylee",2},
	{"Ingrid",2},
	{"Alice",2},
	{"Leilani",2},
	{"Brynn",2},
	{"Jazlene",2},
	{"Ariella",2},
	{"Selah",2},
	{"Kimberly",2},
	{"Gianna",2},
	{"Annabel",2},
	{"Addison",2},
	{"Sadie",2},
	{"Sarah",2},
	{"Melina",2},
	{"Edith",2},
	{"Madelyn",2},
	{"Rubi",2},
	{"Chloe",2},
	{"Eden",2},
	{"Lillianna",2},
	{"Jaqueline",2},
	{"Sophia",2},
	{"Micaela",2},
	{"Madalynn",2},
	{"Elaine",2},
	{"Julianna",2},
	{"Evangeline",2},
	{"Leslie",2},
	{"Aliana",2},
	{"Kenley",2},
	{"Riya",2},
	{"Katherine",2},
	{"Kamari",2},
	{"Briley",2},
	{"Izabelle",2},
	{"Keira",2},
	{"Hallie",2},
	{"Halle",2},
	{"Adeline",2},
	{"Sylvia",2},
	{"Kira",2},
	{"Sanaa",2},
	{"Laney",2},
	{"Katrina",2},
	{"Adison",2},
	{"Haleigh",2},
	{"Jocelyn",2},
	{"Gabriela",2},
	{"Itzel",2},
	{"Beatrice",2},
	{"Shayla",2},
	{"Jamiya",2},
	{"Rihanna",2},
	{"Nathaly",2},
	{"Fiona",2},
	{"Jaslyn",2},
	{"Lilah",2},
	{"Carina",2},
	{"Brianna",2},
	{"Alondra",2},
	{"Ryleigh",2},
	{"Jaylynn",2},
	{"Mila",2},
	{"Shyanne",2},
	{"Daphne",2},
	{"Aisha",2},
	{"Leticia",2},
	{"Akira",2},
	{"Lara",2},
	{"Jaylah",2},
	{"Patience",2},
	{"Sarai",2},
	{"Lyric",2},
	{"Shannon",2},
	{"Cassie",2},
	{"Jaslene",2},
	{"Abril",2},
	// Last Names
	{"Porter",3},
	{"Johns",3},
	{"Burch",3},
	{"Oneill",3},
	{"Bailey",3},
	{"Garner",3},
	{"Mclaughlin",3},
	{"Todd",3},
	{"Dixon",3},
	{"Moss",3},
	{"Wu",3},
	{"Gross",3},
	{"Casey",3},
	{"Donovan",3},
	{"Stuart",3},
	{"Diaz",3},
	{"Krause",3},
	{"Avery",3},
	{"Arroyo",3},
	{"Monroe",3},
	{"Ortiz",3},
	{"Nolan",3},
	{"Villanueva",3},
	{"Meyer",3},
	{"Patel",3},
	{"Jefferson",3},
	{"Oliver",3},
	{"Fritz",3},
	{"Stevens",3},
	{"Sharp",3},
	{"Russell",3},
	{"Haas",3},
	{"Bishop",3},
	{"Wagner",3},
	{"Blackburn",3},
	{"Arnold",3},
	{"Alexander",3},
	{"Gardner",3},
	{"Oneal",3},
	{"Brock",3},
	{"Mcgee",3},
	{"Olsen",3},
	{"Clements",3},
	{"Wood",3},
	{"Weaver",3},
	{"Hernandez",3},
	{"Blake",3},
	{"Hoover",3},
	{"Beck",3},
	{"Soto",3},
	{"Hardin",3},
	{"Kramer",3},
	{"Stokes",3},
	{"Watkins",3},
	{"Jones",3},
	{"Grant",3},
	{"Villegas",3},
	{"Salinas",3},
	{"Fitzpatrick",3},
	{"Shaw",3},
	{"Wise",3},
	{"Santana",3},
	{"Everett",3},
	{"Downs",3},
	{"Harrington",3},
	{"Guerrero",3},
	{"May",3},
	{"Cardenas",3},
	{"Reynolds",3},
	{"Lucas",3},
	{"Yu",3},
	{"Castro",3},
	{"Hancock",3},
	{"Washington",3},
	{"Mathis",3},
	{"Foley",3},
	{"Morse",3},
	{"Malone",3},
	{"Cordova",3},
	{"Ashley",3},
	{"Galvan",3},
	{"Ibarra",3},
	{"Lam",3},
	{"Combs",3},
	{"Preston",3},
	{"Waters",3},
	{"Fowler",3},
	{"Jacobs",3},
	{"Hobbs",3},
	{"Dillon",3},
	{"Harper",3},
	{"Franco",3},
	{"Holden",3},
	{"Wiley",3},
	{"Haynes",3},
	{"Gonzales",3},
	{"Hall",3},
	{"Mckee",3},
	{"Bradford",3},
	{"Cohen",3},
	{"Daugherty",3}
};
new PermissionFamilies[][data_PermissionFamilies] =
{
	{"self_team","Team"},
	{"konoha_maint","Konoha Maintenance"},
	{"konoha_keys","Konoha Privileges"}
};
#define PERMISSION_FAMILY_SELF_TEAM 0
#define PERMISSION_FAMILY_KONOHA_MAINTENACE 1
#define PERMISSION_FAMILY_KONOHA_PREVILEGES 2
new Permissions[][data_Permissions] =
{
	{PERMISSION_FAMILY_SELF_TEAM,"manage_village_perms","Manage Village Permissions"},
	{PERMISSION_FAMILY_SELF_TEAM,"villager_deaths_notice","Villager Death Updates"},
	{PERMISSION_FAMILY_KONOHA_PREVILEGES,"hokage_floor","Hokage Floor"}
};
new TeamKeys[][16] =
{
	"konoha",
	"sand",
	"mist",
	"cloud",
	"stone",
	"sound",
	"akatsuki",
	"iron"
};
#define TEAMKEY_KONOHA 0
#define TEAMKEY_SAND 1
#define TEAMKEY_MIST 2
#define TEAMKEY_CLOUD 3
#define TEAMKEY_STONE 4
#define TEAMKEY_SOUND 5
#define TEAMKEY_AKATSUKI 6
#define TEAMKEY_IRON 7
