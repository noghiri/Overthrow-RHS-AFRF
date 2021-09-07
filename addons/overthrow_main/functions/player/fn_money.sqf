if!(hasInterface) exitWith {};
private _amount = _this select 0;
private _total_money = (player getVariable ["money",0])+_amount;
if(_total_money < 0) then {
    _total_money = 0;
};
player setVariable ["money",_total_money,true];
playSound "3DEN_notificationDefault";
private _plusmin = "";
if(_amount > 0) then {
    _plusmin = "+";
};
if(count _this > 1) then {
    format["%3: %1$%2",_plusmin,[_amount, 1, 0, true] call CBA_fnc_formatNumber,_this select 1] call OT_fnc_notifyMinor;
}else{
    format["%1$%2",_plusmin,[_amount, 1, 0, true] call CBA_fnc_formatNumber] call OT_fnc_notifyMinor;
};
