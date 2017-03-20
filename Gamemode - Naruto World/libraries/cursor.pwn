@f(_,cursor.Show(playerid))
{
	PlayerInfo[playerid][pCursorShow] = true;
	SelectTextDraw(playerid,CC_CURSOR_SELECTION);
}
@f(_,cursor.Hide(playerid))
{
	PlayerInfo[playerid][pCursorShow] = false;
	CancelSelectTextDraw(playerid);
}
@f(_,cursor.Toggle(playerid))
{
	PlayerInfo[playerid][pCursorShow] = !PlayerInfo[playerid][pCursorShow];
	if(PlayerInfo[playerid][pCursorShow]) SelectTextDraw(playerid,CC_CURSOR_SELECTION);
	else CancelSelectTextDraw(playerid);
}
@f(bool,cursor.IsVisible(playerid)) return PlayerInfo[playerid][pCursorShow];
@f(_,cursor.SetPosition(playerid,x,y)) if(PlayerInfo[playerid][pCursorShow]) SetCursorPosition(playerid,x,y);
