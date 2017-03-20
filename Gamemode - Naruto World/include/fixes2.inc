#include <a_samp>
//#include <sscanf2>

stock const
	ERROR_INVALID_CLIENT[] = "Invalid client connecting from ",
	ERROR_RCON_EXPLOIT[] = "Warning: /rcon command exploit from: ",
	ERROR_PLAYER_DIALOG[] = "Warning: PlayerDialogResponse PlayerId: ",
	ERROR_DIALOG_CRASH[] = "Warning: PlayerDialogResponse crash exploit from PlayerId: ",
	ERROR_PACKET_MODIFIED[] = "Packet was modified, sent by id: ",
	ERROR_PORT_REFUSED[] = "Remote Port Refused for Player: ",
	ERROR_BLOCKING[] = "Blocking ",
	ERROR_SERVER_FULL[] = " due to a 'server full' attack";


native SetTimer_(const func[], const delay, const interval, const count);
native SetTimerEx_(const func[], const delay, const interval, const count, const format[], {Float, _}:...);
native KillTimer_(timer) = KillTimer;
