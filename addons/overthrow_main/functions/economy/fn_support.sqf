//Use with [_town] call OT_fnc_support;
//Use with [_town, 1] call OT_fnc_support to obtain +1 on town rep;
//Use with [_town, 1, "Town name?"] (not sure how to apply here);
//Use with [_town, 1, "Text", player] call OT_fnc_support
//[(getpos player) call OT_fnc_nearestTown,-5,"Stolen vehicle",player] call OT_fnc_support 
//Dorf 2021: Added cap to PERSONAL town REP if over 2525, it will now be 2525 at CAP;
//Hope this doesn't break some advanced algo somewhere, sorry if it does, technically 146k is national cap in tanoa.
private _town = _this select 0;
if(isNil "_town") exitWith {};
private _rep = (server getVariable [format["rep%1",_town],0]);
if(count _this > 1) then {
    _rep = _rep+(_this select 1);
    if (_rep > 2525) then {_rep = 2525}; //If rep is over 2525 it becomes 2525;
    server setVariable [format["rep%1",_town],_rep,true];
    _totalrep = (server getVariable ["rep",0])+(_this select 1);
    server setVariable ["rep",_totalrep,true];
};

if(count _this > 2) then {
    _pl = "+";
    if((_this select 1) < 0) then {_pl = ""};
    if(count _this > 3) then { //1 is ?? total??, %2 is a number, %3 town name, %4 is plus or minus symbol
        format["%1 (%4%2 %3)",_this select 2,_this select 1,_town,_pl] remoteExec ["OT_fnc_notifyMinor", _this select 3,false];
    }else{
        format["%1 (%4%2 %3)",_this select 2,_this select 1,_town,_pl] remoteExec ["OT_fnc_notifyMinor", 0,false];
    };
};
_rep;
