// Anime Fantasy: Naruto World #26 script: timer
#define function<%1> forward timer_%1; public timer_%1
//#define DEBUG // Allow this to check out the accuracy of the timer
const MAXIMUM = cellmax - MIN_SCRIPT_TIMER_INTERVAL;
#if defined DEBUG
	new tickCountOffset = -1;
#endif
forward SharedScriptTimer();
public SharedScriptTimer()
{
	if((serverUptime + MIN_SCRIPT_TIMER_INTERVAL) >= MAXIMUM) serverUptime = (serverUptime + MIN_SCRIPT_TIMER_INTERVAL) - MAXIMUM;
	serverUptime += MIN_SCRIPT_TIMER_INTERVAL;
	#if defined DEBUG
		if(tickCountOffset == -1) tickCountOffset = GetTickCount();
		new tick = GetTickCount()-tickCountOffset;
		printf("%d/%d (%d loss)",tick,serverUptime,tick-serverUptime);
	#endif
	GlobalScriptTimer(serverUptime);
	Loop(player,i) if(IsPlayerConnected(i) && PlayerInfo[i][pStatus] != e_PlayerStatus:player_status_none) LocalScriptTimer(serverUptime,i);
}
function<OnGameModeInit()>
{
	// (sorry sa-mp :( )
	SetTimer("SharedScriptTimer",MIN_SCRIPT_TIMER_INTERVAL,1);
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
// Timer
@f(bool,timer.MeetsTimeUnit(&interval,{e_TimeUnit,_}:timeunit)) return (interval % (_:timeunit)) == 0;
#undef function
