// Constants
#define VERSION "1.0.0 Beta"
#define LAUNCHER_VERSION "1.0.0 Beta 3"
//#define AFURL "c.sa-mp.co.il/af/"
#define AFURL "hosted.oversight-group.net/amit/projects/af/"
#define NWURL AFURL "nw/"
#define WEBURL "AF.Oversight-Group.net"
#define GAME_LEVEL 1
//#define DEBUG_EVENTS // Allow this to view which event is being called in the log file
#pragma dynamic 2000000 // SHOULD REMOVE THAT FAST AND OPTIMIZE THIS SHITTY CODE!!!
// String Limits
#define M_S 128
#define M_D_L 2560
#define M_S_DB 256
#define MAX_NAME_LENGTH 32
// Player Limits
#undef MAX_PLAYERS
#define MAX_PLAYERS 300
#define MAX_CONNECTIONS 100
#define MAX_NPCS 100
// System Limits
#define MAX_CACHE_ITEMS 2500
#define MAX_CHARACTERS 150
#define MAX_PTD 150
#define MAX_PTD_ALPHA 10
#define MAX_STREAMED_OBJECTS 12000
#define MAX_DIALOGS 70
#define MAX_GPROPERTIES 1200
#define MAX_MENU_BUTTONS 6
#define MAX_STARTUP_BUTTONS 10
#define MAX_TEAMS 10
#define MAX_TEAM_SPAWNS 10
#define MAX_VIRTUAL_WORLDS 1000
#define MAX_SOUNDS 100
#define MAX_SOUND_TYPES 3
#define MAX_MOVIES 10
#define MAX_MOVIE_PATHS 20
#define MAX_MAPS 20
#define MAX_OBJECTS_PER_MAP 2000
#define MAX_SPICKUPS 100
#define MAX_PROGRESS_BARS 5
#define MAX_CHAT_LENGTH 190
#define MAX_MONEY 9999999
#define MAX_HELP_FILES 10
#define MAX_POWER_CATEGORIES 9
#define MAX_POWERS_PER_CATEGORY 5
#define MAX_POWER_EFFECTS 4
#define MAX_POWER_EFFECT_PARAMS 5
#define MAX_POWERS 300
#define MAX_ACTIVE_POWERS 150
#define MAX_LISTS 30
#define MAX_LIST_ITEMS 25
#define MAX_EFFECTS_PER_TIME 5
#define MAX_BUFFS_PER_PLAYER 10
#define MAX_STREAMED_AREAS (MAX_STREAMED_OBJECTS+MAX_PLAYERS+MAX_NPCS)
#define MAX_CHARACTER_NICKNAMES 5
#define MAX_TARGET_OBJECTS 10
#define MAX_SIDE_MENUS 10
#define MAX_SIDE_BUTTONS 15
#define MIN_KEY_ID 48
#define MAX_KEY_ID 124
#define MIN_SCRIPT_TIMER_INTERVAL 10
#define OBJECT_MAX_INTERIORS 5
#define OBJECT_MAX_VIRTUAL_WORLDS 5
#define ADMIN_MAX_LEVEL 5
#define MAX_CONPL_IDLE_TIME 180
#define MAX_CON_IDLE_TIME 40
#define NPC_MIN_ATTACKSPEED 1700
#define NPC_MAX_ATTACKSPEED 200
#define NPC_MIN_DISTANCE 2.0
#define MAX_INTROS 20
#define MAX_INTRO_NPCS 5
#define MAX_PATHS 100
#define MAX_PATH_POSITIONS 30
#define MAX_PATH_CONNECTIONS 5
#define MAX_ROUTES 300
#define MAX_TEAM_PATHS 50
#define MAX_VILLAGERS 100
#define MAX_OBJECT_MODELS 450
#define MAX_OBJECTS_PER_MODEL 900
#define MAX_SOBJECT_SEATS 5
#define MAX_RESPECT 100
#define MAX_TEXT_LINES 10
#define MAX_SKINS 300
#define MAX_TEAM_PERMISSIONS 5
// System Settings
#define OBJECT_STREAM_DISTANCE_S 75.0
#define OBJECT_STREAM_DISTANCE_L 475.0
#define PLAYER_STREAM_DISTANCE 550.0
#define NAMETAG_DRAW_DISTANCE 45.0
#define NAMETAG_DRAW_DISTANCE_NPC 35.0
#define NAMETAG_DRAW_ALPHA 175
#define WORLD_Y_OFFSET 0.0 // Figured out how to take out GTA SA map! no need for this (previous value was 5500.0)
#define NULL_TXD "samaps:map"
#define NPC_IDLE_SCRIPT "idle"
#define PLAYER_DEFAULT_VISION 50.0
#define PLAYER_DEFAULT_HEARING 100.0
#define PLAYER_DEFAULT_NOISE 100.0
#define NPC_DEFAULT_VISION 50.0
#define DEFAULT_SOUND_RADIUS 30.0
#define DEFAULT_CAMERA_DISTANCE 8.5
#define VILLAGERS_PER_POPULATION_POINT 12
#define OBJECT_MODEL_ID_OFFSET 13632
#define SPAWN_Z_OFFSET 1.8
#define PROTECTION_BASE 80.0
#define WORLD_GRAVITY 0.008
#define DELAY_BETWEEN_MUSIC 4000
// Invalid Values
#define INVALID_CACHE (-cellmax)
#define INVALID_CONNECTION -1
#define INVALID_CHARACTER -1
#define INVALID_PLAYER_TEXT_DRAW (PlayerText:0xFFFF)
#define INVALID_STREAMED_OBJECT INVALID_OBJECT_ID
#define NO_DB_RESULT (DBResult:(-1))
#define INVALID_VIRTUAL_WORLD 0
#define INVALID_MAP -1
#define INVALID_SPICKUP -1
#define INVALID_LIST_ID -1
#undef INVALID_TEXT_DRAW
#define INVALID_TEXT_DRAW Text:0xFFFF
#define INVALID_AREA -1
#define INVALID_ROUTE 255
#define INVALID_VILLAGER_ID -1
// Directories
#define DIR_MAIN "AFNW"
#define DIR_MOVIES DIR_MAIN "/Movies"
#define DIR_MAPS DIR_MAIN "/Maps"
#define DIR_INFOFILES DIR_MAIN "/Info Files"
#define DIR_HELP DIR_MAIN "/Help Files"
#define DIR_DESC DIR_MAIN "/Descriptions"
#define DIR_LOGS DIR_MAIN "/Logs"
#define DIR_DEBUG DIR_MAIN "/Debug Data"
// Files
#define FILE_GAMEDATA DIR_MAIN "/game.db"
#define FILE_SERVERDATA DIR_MAIN "/server.db"
// Key Modifiers
#define MOD_ALT 0x1
#define MOD_CONTROL 0x2
#define MOD_SHIFT 0x4
#define MOD_WIN 0x8
#define MOD_KEYUP 0x1000
// Key IDs
#define KEYID_NONE 0
#define KEYID_0 48
#define KEYID_1 49
#define KEYID_2 50
#define KEYID_3 51
#define KEYID_4 52
#define KEYID_5 53
#define KEYID_6 54
#define KEYID_7 55
#define KEYID_8 56
#define KEYID_9 57
#define KEYID_A 65
#define KEYID_B 66
#define KEYID_C 67
#define KEYID_D 68
#define KEYID_E 69
#define KEYID_F 70
#define KEYID_G 71
#define KEYID_H 72
#define KEYID_I 73
#define KEYID_J 74
#define KEYID_K 75
#define KEYID_L 76
#define KEYID_M 77
#define KEYID_N 78
#define KEYID_O 79
#define KEYID_P 80
#define KEYID_Q 81
#define KEYID_R 82
#define KEYID_S 83
#define KEYID_T 84
#define KEYID_U 85
#define KEYID_V 86
#define KEYID_W 87
#define KEYID_X 88
#define KEYID_Y 89
#define KEYID_Z 90
#define KEYID_F1 112
#define KEYID_F2 113
#define KEYID_F3 114
#define KEYID_F4 115
#define KEYID_F5 116
#define KEYID_F6 117
#define KEYID_F7 118
#define KEYID_F8 119
#define KEYID_F9 120
#define KEYID_F10 121
#define KEYID_F11 122
#define KEYID_F12 123
// Virtual World IDs
#define VW_WORLD 0
#define VW_OBJECTS 1
#define VW_LOGIN 2
#define VW_MOVIE 3
#define VW_NPCS 4
#define VW_INTRO 5
#define VW_END 50
// Camera Interpolate Endings
#define CIE_NONE 0
#define CIE_ACTION 1
#define CIE_MOVIE 2
// Loading Parts
#define LOADING_NONE -1
#define LOADING_START 0
#define LOADING_OBJECTS 1
#define LOADING_SECURITY 2
#define LOADING_POWERS 3
#define LOADING_TEXTDRAWS 4
#define LOADING_ANIMATIONS 5
#define LOADING_END 6
#define LOADING_END2 7
// Position Status
#define PS_NONE 0
#define PS_GROUND 1
#define PS_AIR 2
#define PS_WATER 3
// Notification Types
#define NOTIFICATION_ERROR 0
#define NOTIFICATION_INFO 1
// Player Actions
#define ACTION_JUMP 1
#define ACTION_LAND 2
#define ACTION_SPRINT 3
#define ACTION_FALL 4
// Lists
#define LIST_CASTCODES 0
// NPC Commands
#define NPCCMD_NONE 0
#define NPCCMD_ATTACK 1
#define NPCCMD_DEFEND 2
#define NPCCMD_MOVE 3
#define NPCCMD_FOLLOW 4
#define NPCCMD_FOCUS 5
#define NPCCMD_SCAN 6
#define NPCCMD_SPREAD 7
#define NPCCMD_WATCH 8
#define NPCCMD_RETREAT 9
#define NPCCMD_CHASE 10
#define NPCCMD_PUSH 11
#define NPCCMD_GROUPUP 12
#define NPCCMD_FORMATION 13
#define NPCCMD_CAPTURE 14
#define NPCCMD_ABILITY 15
#define NPCCMD_PROCMD 16
#define NPCCMD_CANCEL 17
// Player Icons
#define ICON_TARGET 1
// Chat Radius
#define CHAT_DISTANCE_SAY 20
#define CHAT_DISTANCE_SHOUT 40
#define CHAT_DISTANCE_WHISPER 5
#define CHAT_DISTANCE_ME 20
#define CHAT_DISTANCE_POWER 50
// Float Values
#define FLOAT_INFINITY (Float:0x7F800000)
#define FLOAT_NINFINITY (Float:0xFF800000)
#define FLOAT_NAN (Float:0xFFFFFFFF)
// Attached Object Slot
#define AOSLOT_PATHSELECT1 0
#define AOSLOT_PATHSELECT2 1
// Directive Functions
#define f(%1) (format(fstring,sizeof(fstring),%1), fstring)
#define callback(%0,%1); public %1() { for(new i = 0; i < sizeof(Scripts); i++) if(e_id(%0,i,#%1) != -1) { e_dbg(i,#%1); if(!call(fstring[0],"")) break; } return 1; }
#define callbackd(%0,%1,<%2>); public %1() { for(new i = 0; i < sizeof(Scripts); i++) if(e_id(%0,i,#%1) != -1) { e_dbg(i,#%1); if(!call(fstring[0],"")) break; else %2; } return 1; }
#define callbackx(%0,%1(<%2>,<%3>,<%4>)); public %1(%3) { for(new i = 0; i < sizeof(Scripts); i++) if(e_id(%0,i,#%1) != -1) { e_dbg(i,#%1); if(!call(fstring[0],%2,%4)) break; } return 1; }
#define callbackz(%0,%1(<%2>,<%3>,<%4>)); public %1(%3) { for(new i = 0; i < sizeof(Scripts); i++) if(e_id(%0,i,#%1) != -1) { e_dbg(i,#%1); if(!call(fstring[0],%2,%4)) return 0; } return 1; }
#define callbackr(%0,%1(<%2>,<%3>,<%4>),%5); public %1(%3) { for(new i = 0; i < sizeof(Scripts); i++) if(e_id(%0,i,#%1) != -1) { e_dbg(i,#%1); if(!call(fstring[0],%2,%4)) break; } return %5; }
#define callbacks(%0,%1(<%2>,<%3>,<%4>,<%5>)); public %1(%3) { for(new i = 0; i < sizeof(Scripts); i++) if(e_id(%0,i,#%5) != -1) { e_dbg(i,#%5); if(!call(fstring[0],%2,%4)) break; } return 1; }
#define callbackc(%0,%1(<%2>,<%3>,<%4>)); public %1(%3) { for(new i = 0; i < sizeof(Scripts); i++) if(e_id(%0,i,#%1) != -1) { e_dbg(i,#%1); if(call(fstring[0],%2,%4)) return 1; } return 0; }
#define callbackcs(%0,%1(<%2>,<%3>,<%4>,<%5>)); public %1(%3) { for(new i = 0; i < sizeof(Scripts); i++) if(e_id(%0,i,#%5) != -1) { e_dbg(i,#%5); if(call(fstring[0],%2,%4)) return 1; } return 0; }
#define callbackx_PARTA(%0,%1(<%3>)); public %1(%3) { for(new i = 0; i < sizeof(Scripts); i++) if(e_id(%0,i,#%1) != -1) // FUCK PAWN
#define callbackx_PARTB(<%2>,<%4>); { e_dbg(i,#%1); if(call(fstring[0],%2,%4) == -1) break; } return 1; } // FUCK PAWN
#define Loop(%1,%2) for(new %2_ = 0, %2 = %1[0]; %2_ < %1s; %2 = %1[++%2_])
#define LoopEx(%1,%2,<%3>) for(new %2_ = 0, %2 = %1[0]; %2_ < %1s && (%3); %2 = %1[++%2_])
#define LoopAr(%1,%2,%3) for(new %3_ = 0, %3 = %1[%2][0]; %3_ < %1s[%2]; %3 = %1[%2][++%3_])
#define ElementArrayAdd(%1,%2,%3) %1[%2 = (%1s++)] = %3
#define ElementArrayDel(%1,%2,%3) for(new %1_i = %2; %1_i < %1s - 1; %1_i++) %1[%1_i] = %1[%1_i+1]; %1[%1s--] = %3
#define command(%1,%2) if(!strcmp(#%1,%2[1],true,strlen(#%1)) && ((%2[strlen(#%1) + 1] == '\0' && command_%1(playerid,"")) || (%2[strlen(#%1) + 1] == ' ' && command_%1(playerid,%2[strlen(#%1) + 2])))) return 1
#define shortcut(%1,%2,%3) if(!strcmp(#%1,%2[1],true,strlen(#%1)) && ((%2[strlen(#%1) + 1] == '\0' && command_%3(playerid,"")) || (%2[strlen(#%1) + 1] == ' ' && command_%3(playerid,%2[strlen(#%1) + 2])))) return 1
#define cmd.%1(%2,%3) stock command_%1(%2,%3)
#define acmd.%1(%2,%3) forward admincmd_%1(%2,%3); public admincmd_%1(%2,%3)
#define equal(%1,%2) (!strcmp(%1,%2,true) && strlen(%1) == strlen(%2))
#define GetStringArg(%1,%2) str_reset(%2); for(new sa_%2 = 0, tmpsa_%2 = 0, str_%2[sizeof(%2)]; (tmpsa_%2 = getarg(%1,sa_%2)) != '\0'; sa_%2++) str_%2[sa_%2] = tmpsa_%2, %2 = str_%2
#define str_space(%1) (!strlen(%1) ? (" ") : (%1))
#define @f(%1,%2.%3) forward %1:%2_%3; stock %1:%2_%3
#define tostring(%1) (valstr(n2s,(%1)), n2s)
#define HOLDING(%0) ((newkeys & (%0)) == (%0))
#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define PRESSING(%0,%1) (%0 & (%1))
#define RELEASED(%0) (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
