// Anime Fantasy: Naruto World #18 script: money
#define function<%1> forward money_%1; public money_%1
function<OnGameModeInit()>
{
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
#undef function
@f(_,money.Give(playerid,amount))
{
	PlayerInfo[playerid][pMoney] = math_bonds(PlayerInfo[playerid][pMoney]+amount,0,MAX_MONEY);
	ptd_Update(playerid,e_PlayerTD:ptd_stats,"money");
}
@f(_,money.Take(playerid,amount))
{
	PlayerInfo[playerid][pMoney] = math_bonds(PlayerInfo[playerid][pMoney]-amount,0,MAX_MONEY);
	ptd_Update(playerid,e_PlayerTD:ptd_stats,"money");
}
@f(_,money.Get(playerid)) return PlayerInfo[playerid][pMoney];
@f(_,money.Reset(playerid,amount))
{
	PlayerInfo[playerid][pMoney] = 0;
	ptd_Update(playerid,e_PlayerTD:ptd_stats,"money");
}
