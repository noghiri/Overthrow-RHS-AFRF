//debug for old character sheet stats ahead; delete when converted in future;
private _fitness = objNull;
if (_this getvariable ["OT_fitness",[1,1]] isEqualType []) then {
	_fitness = _this getVariable ["OT_fitness",[1, 1]];
} else {
	_fitness = [_this getVariable ["OT_fitness", 1], 1];
};
_fitness = _fitness select 1;
//debug ends

//private _fitness = _this getVariable ["OT_fitness",[1,1]];

if(ace_advanced_fatigue_anreserve < 2300) then {
	ace_advanced_fatigue_anreserve = ace_advanced_fatigue_anreserve + (_fitness * 6); //12 multiply originally is down to 6;
	if((_fitness) isEqualTo 5) then {ace_advanced_fatigue_anreserve = 2300};
};

[OT_fnc_perkSystem,_this,2] call CBA_fnc_waitAndExecute;
