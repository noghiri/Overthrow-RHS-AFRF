
private _idx = lbCurSel 1500;
private _uid = lbData [1500,_idx];

private _generals = server getVariable ["generals",[]];
if (player call BIS_fnc_admin isEqualTo 2) then {
    if (_uid in (server getVariable ["generals",[]])) then {
        private _uid_index = _generals find _uid;
        _generals deleteAt _uid_index;
    } else {
        //this gives the person general status;
        _generals pushBackUnique _uid; //changed to unique incase dupes
    };
    server setVariable ["generals",_generals,true];
};

disableSerialization;

//am general short form? 
//Checks player UID if it's in sever's variable of generals array;
_amgen = (getPlayerUID player) in (server getVariable ["generals",[]]);

_isonline = false;
_on = "Offline";
_player = objNull;
{
    if(getplayeruid _x isEqualTo _uid) exitWith {_isonline = true;_on = "Online";_player = _x};
}foreach(allplayers);

_money = 0;
//This gets player money into _money, depends on if theyre online or not.
if(_isonline) then {
    _money = _player getVariable["money",0];
}else{
    _money = [_uid,"money"] call OT_fnc_getOfflinePlayerAttribute;
};

//This matches _on variable to general being online i think
if(_uid in (server getVariable ["generals",[]])) then {
    _on = _on + " (General)";
};

_text = format["<t size='0.8'>%1</t><br/>",lbText [1500,_idx]];
_text = _text + format["<t size='0.65'>%1</t><br/>",_on];

if(_amgen) then {
    _text = _text + format["<t size='0.65'>$%1</t>",[_money, 1, 0, true] call CBA_fnc_formatNumber];
};

_textctrl = (findDisplay 8000) displayCtrl 1102;
_textctrl ctrlSetStructuredText parseText _text;
if (_amgen && _uid != (getplayeruid player)) then {
    if (_uid in _generals) then {
        //revokes general displays it too.
        ctrlSetText [1600, "Revoke General"];
    } else {
        ctrlSetText [1600, "Make General"]; //make general displays;
    }; 
};
//ctrlShow [1600,true]; //to show (not used)
//ctrlEnable [1600,false]; //This disables make general button i think;
