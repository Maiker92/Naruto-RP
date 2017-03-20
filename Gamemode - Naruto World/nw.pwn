/* Anime Fantasy: Naruto World by Amit_B (c) AF.Oversight-Group.net 2013-2016 */
// Base SA-MP Functions
#include "a_samp.inc"
#include "a_sampdb.inc"
#include "a_http.inc"
// Additions / Plugin Functions
#include "./include/streamer.inc"
#include "./include/sqlitei.inc"
#include "./include/y_files.inc"
#include "./include/socket.inc"
#include "./include/keys.inc"
#include "./include/FCNPC.inc"
#include "./include/fixes2.inc"
#include "./include/crashdetect.inc"
// Build
#include "./build/definitions.pwn"
#include "./build/color-definitions.pwn"
#include "./build/initialize.pwn"
#include "./build/datalists.pwn"
#include "./build/natives.pwn"
#include "./build/callbacks.pwn"
// Scripts
#include "./scripts/header.pwn"
#include "./scripts/timer.pwn"
#include "./scripts/net.pwn"
#include "./scripts/misc.pwn"
#include "./scripts/path.pwn"
#include "./scripts/security.pwn"
#include "./scripts/camera.pwn"
#include "./scripts/target.pwn"
#include "./scripts/pickups.pwn"
#include "./scripts/nametags.pwn"
#include "./scripts/chars.pwn"
#include "./scripts/drawing.pwn"
#include "./scripts/sound.pwn"
#include "./scripts/support.pwn"
#include "./scripts/user.pwn"
#include "./scripts/admin.pwn"
#include "./scripts/intro.pwn"
#include "./scripts/powers.pwn"
#include "./scripts/gameplay.pwn"
#include "./scripts/control.pwn"
#include "./scripts/chat.pwn"
#include "./scripts/bgmusic.pwn"
#include "./scripts/map.pwn"
#include "./scripts/teams.pwn"
#include "./scripts/money.pwn"
#include "./scripts/npcs.pwn"
#include "./scripts/world.pwn"
#include "./scripts/level.pwn"
#include "./scripts/anim.pwn"
#include "./scripts/village.pwn"
#include "./scripts/sobjects.pwn"
#include "./scripts/perms.pwn"
#include "./scripts/footer.pwn"
// Libraries
#include "./libraries/cache.pwn"
#include "./libraries/player.pwn"
#include "./libraries/string.pwn"
#include "./libraries/math.pwn"
#include "./libraries/color.pwn"
#include "./libraries/sqlite.pwn"
#include "./libraries/object.pwn"
#include "./libraries/dialog.pwn"
#include "./libraries/property.pwn"
#include "./libraries/encrypt.pwn"
#include "./libraries/convert.pwn"
#include "./libraries/vworld.pwn"
#include "./libraries/infofile.pwn"
#include "./libraries/file.pwn"
#include "./libraries/list.pwn"
#include "./libraries/key.pwn"
#include "./libraries/area.pwn"
#include "./libraries/time.pwn"
#include "./libraries/cursor.pwn"
#include "./libraries/event.pwn"
#include "./libraries/textline.pwn"
/* TODO:
XP
Dealing Deaths
NPCs
code optimization (cells)
kick/ban system
cmd procesor (sscanf?)
Darkness
Character Voices
Show in-game tips (like cheats in single player)
movie: hide all text draws and then load them again
movie textdraw box
master server to tell ALL SERVERS ping and details
auto login program
name tag addition text
ability = catch only one / not catch afk
ichiraku ramen
movie start with delay
npc follow
tp admin command
second logout shown dialog without characters, and exited the SA
akatsuki stone
remove spawn debugging
find memory for opening chat
join/quit messages
close cursor = close menu
logs system
log crashdetect errors
move logs to SQL & enum of log types
colors script: error color, input color, etc...
move to 0.3.7 R2
encrypt passwords
idle time is not increasing when cursor is visible; make sure the player is really in-game
npc paths system
script comment / documention
make movie/soundtrack clickable
full credit list
paths: add path usage
sobjects: area height
dialog list: select with 1-9
permission: deny more than one player to manage at the same time
scripts: unload / load
update community tab
YSF: SetPlayerSkinForPlayer
dialog - pages
socket injection
-
route go c - crash*  33 -1 4
check affect power*
transform end crashed* - end crashed
activate buff* - dialog use
dialog parent doesn't getting showed up
villager - return to route - goes to some other places
grant permission says different approve msg
-
program:
options (in-program)
-
ability upgrade
*/
// my current mission: make use of path again in village script and also document it
