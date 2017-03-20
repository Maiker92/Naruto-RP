// Natives
native IsValidVehicle(vehicleid);
native gpci(playerid,const serial[],maxlen);
native Float:GetGravity();
// Native Renames
native call(const function[], const format[], {Float,_}:...) = CallLocalFunction;
