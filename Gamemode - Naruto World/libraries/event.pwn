@f(_,e.id(eid,script,name[])) return cache_get((_:cache_func)+eid+((_:cache_max_func)*script),funcidx(f("%s_%s",Scripts[script],name)));
@f(_,e.dbg(script,name[]))
{
	currentScript = script;
	if(serverUptime <= 3000) return;
	f("%s_%s",Scripts[script],name);
	if(e_IsDebugException(fstring)) return;
	#if defined DEBUG_EVENTS
		printf("Event debugger: %s",fstring);
	#else
		#pragma unused script
		#pragma unused name
	#endif
}
static exceptions[][32] =
{
	"ScriptTimer",
	"npcs_OnPlayerConnect",
	"OnPlayerUpdate"
};
@f(bool,e.IsDebugException(frmt[]))
{
	for(new i = 0; i < sizeof(exceptions); i++) if(strfind(frmt,exceptions[i]) != -1) return true;
	return false;
}
@f(_,e.CurrentScript()) return currentScript;
@f(_,e.ScriptName(scriptID))
{
	new s[MAX_NAME_LENGTH];
	strmid(s,Scripts[scriptID],0,strlen(Scripts[scriptID]));
	strcat(".pwn",s);
	return s;
}
@f(_,e.ScriptID(name[]))
{
	for(new i = 0; i < sizeof(Scripts); i++) if(equal(Scripts[i],name)) return i;
	return -1;
}
