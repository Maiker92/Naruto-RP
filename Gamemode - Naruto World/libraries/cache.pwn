@f(_,cache.get(code,defvalue = INVALID_CACHE)) return Cache[_:code] == INVALID_CACHE ? (Cache[_:code] = defvalue) : Cache[_:code];
@f(_,cache.set(code,value)) return Cache[_:code] = value, 1;
@f(bool,cache.exist(code)) return Cache[_:code] == INVALID_CACHE;
