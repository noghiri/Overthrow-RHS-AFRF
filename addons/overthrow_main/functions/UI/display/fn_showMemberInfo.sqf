params ["_ctrl","_index"];

disableSerialization;

private _uid = _ctrl lbData _index;

_amgen = (getPlayerUID player) in (server getVariable ["generals",[]]);

_isonline = false;
_on = "Offline";
_player = objNull;
{
    if(getplayeruid _x isEqualTo _uid) exitWith {_isonline = true;_on = "Online";_player = _x};
}foreach(allplayers);

_money = 0;
if(_isonline) then {
    _money = _player getVariable["money",0];
}else{
    _money = [_uid,"money"] call OT_fnc_getOfflinePlayerAttribute;
};

if(_uid in (server getVariable ["generals",[]])) then {
    _on = _on + " (General)";
};

_text = format["<t size='0.8'>%1</t><br/>",_ctrl lbText _index];
_text = _text + format["<t size='0.65'>%1</t><br/>",_on];

if(_amgen) then {
    _text = _text + format["<t size='0.65'>$%1</t>",[_money, 1, 0, true] call CBA_fnc_formatNumber];
};

_textctrl = (findDisplay 8000) displayCtrl 1102;
_textctrl ctrlSetStructuredText parseText _text;

if(_amgen && _uid != (getplayeruid player)) then {
    //If current player is a general (_amgen)
    //And _uid is not the player's UID

    //enables control to transfer funds;
    ctrlEnable [1601,true];
    if !(_uid in (server getVariable ["generals",[]])) then {
        ctrlSetText [1600, "Make General"];
    }else{
        ctrlSetText [1600, "Revoke General"]; 
    };
    if (player call BIS_fnc_admin isEqualTo 2) then {
        ctrlEnable [1600,true];
    } else {
        ctrlEnable [1600,false];
        ctrlSetText [1600, "Need Admin"]; 
    };
    ctrlShow [1600,true];
}else{
    //disable transfer funds and make general;
    ctrlEnable [1600,false];
    ctrlEnable [1601,false];
};

//if player is not general then no fund transfer, no make general;
if(!_amgen) then {
    ctrlShow [1600,false];
    ctrlShow [1601,false];
};
