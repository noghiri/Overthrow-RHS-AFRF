
closeDialog 0; //close last dialogue window (i think)
private _gotjob = false;
private _jobdef = [];
private _activeJobs = spawner getVariable ["OT_activeJobIds",[]];
private _completed = server getVariable ["OT_completedJobIds",[]];
//private _gangid = OT_interactingWith getVariable ["OT_gangid",-1]; //not sure if necessary but gang id is checked below...
private _params = [];
private _id = "";
private _jobcode = {};
//private _faction = OT_interactingWith getvariable ["faction",""]; //looks like this doesn't need to be defined;
private _expiry = 0;
//private _pos = getpos player;
//private _standing = server getVariable [format["standing%1",_faction],0];
//private _inSpawnDistance = true; //Dorf moved these statements below within the if statement below;
//private _town = _pos call OT_fnc_nearestTown;
//private _stability = server getVariable [format["stability%1",_town],100];
//private _population = server getVariable [format["population%1",_town],50];

{
    _x params ["_name",["_target",""],"_condition","_code","_repeat","_chance","_expires"];
    _jobdef = _x;
    _jobcode = _code;
    _expiry = _expires;
    call {
        if((toLower _target) isEqualTo "faction") exitWith {
            private _faction = OT_interactingWith getvariable ["faction",""];
            _id = format["%1-%2",_name,_faction]; //changed from _gangid;
            //Faction jobs does not have _base;
            //needs this declared _inSpawnDistance, _standing, _town, _stability, _population
            private _pos_inSpawnDistance = server getVariable [format["factionrep%1",_faction],[]]; //gets position of faction rep (array of 3, coordinates);
            private _standing = server getVariable [format["standing%1",_faction],0];
            //if(([_inSpawnDistance,_base,_stability] call _condition) && !(_id in _completed) && !(_id in _activeJobs) && !(_id in OT_jobsOffered)) then {
            if (count _pos_inSpawnDistance > 0) then {
                private _town = _pos_inSpawnDistance call OT_fnc_nearestTown;
                private _inSpawnDistance = _pos_inSpawnDistance call OT_fnc_inSpawnDistance; //returns true if working;
                private _stability = server getVariable [format["stability%1",_town],100];
                private _population = server getVariable [format["population%1",_town],50];
                if(([_inSpawnDistance, _standing, _town, _stability, _population] call _condition) && !(_id in _completed) && !(_id in _activeJobs) && !(_id in OT_jobsOffered)) then {
                    _gotjob = true;
                    _params = [_faction];
                };
            };
        };
    };
    if(_gotjob) exitWith {};
}foreach([OT_allJobs,[],{random 100},"ASCEND",{_x select 7}] call BIS_fnc_SortBy);

if !(_gotjob) exitWith {
    [OT_interactingWith,player,["We don't have any more jobs at the moment."]] spawn OT_fnc_doConversation;
};

private _job = [_id,_params] call _jobcode;
OT_jobShowing = _job;
OT_jobShowingID = _id;
OT_jobShowingExpiry = _expiry;
OT_jobsOffered pushback _id;
if(count _job isEqualTo 0) exitWith {call OT_fnc_requestJobFaction}; //Previously this was requestJobGang??...
_job params ["_info","_markerPos","_setup","_fail","_success","_end","_jobparams"];

OT_jobShowingType = "faction";

createDialog "OT_dialog_joboffer";
disableSerialization;

_job params ["_info","_markerPos"];
_info params ["_title","_desc"];

_textctrl = (findDisplay 8000) displayCtrl 1199;

_textctrl ctrlSetStructuredText parseText format["
    <t align='center' size='1.1'>%1</t><br/><br/>
    <t align='center' size='0.8'>%2</t><br/>
",_title,_desc];

_job
