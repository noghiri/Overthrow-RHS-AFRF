//Priest hours begins now. -Dorf 2021 revived.
private ["_town","_id","_pos","_building","_tracked","_civs","_vehs","_group","_all","_shopkeeper","_groups"];
if (!isServer) exitwith {};
sleep random 2;

_count = 0;
params ["_town","_spawnid"];
_posTown = server getVariable _town;
_pop = server getVariable format["population%1",_town];

_groups = [];

private _church = server getVariable [format["churchin%1",_town],[]];
if !(_church isEqualTo []) then {
	//add some names;
	//This is just for flavour; Is entirely different from actual unit name.
	private _firstname = selectRandom OT_firstNames_local;
	private _lastname = selectRandom OT_lastNames_local;
	private _fullname = "Archcrypto " + _lastname  + " " + _firstname;

	//spawn the priest
	_group = createGroup civilian;
	_group setBehaviour "CARELESS";
	_groups pushback _group;
	//_pos = [[[_church,20]]] call BIS_fnc_randomPos;
	_pos = [_church,[0,20]] call SHK_pos_fnc_pos;
	_priest allowDamage false;

	_priest = _group createUnit [OT_civType_priest, _pos, [],0, "NONE"];
	[_priest] call OT_fnc_initPriest;


	_priest setVariable ["priest",true,true]; //public variable priest get checked in talktociv.sqf
	_priest setVariable ["name",_fullname,true];
	//spawner setVariable [format ["priest%1",_town],_priest,true];

	sleep 0.3;

	spawner setvariable [_spawnid,(spawner getvariable [_spawnid,[]]) + _groups,false];
};