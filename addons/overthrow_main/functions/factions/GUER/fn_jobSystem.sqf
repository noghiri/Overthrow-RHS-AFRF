
OT_allJobs = [];
{
    private _code = gettext (_x >> "condition");
    private _target = gettext (_x >> "target");
    private _script = gettext (_x >> "script");
    private _repeat = getnumber (_x >> "repeatable");
    private _chance = getnumber (_x >> "chance");
    private _expires = getnumber (_x >> "expires");
    private _requestable = (getnumber (_x >> "requestable")) isEqualTo 1;

    OT_allJobs pushback [configName _x, _target, compileFinal _code, compileFinal preprocessFileLineNumbers _script, _repeat, _chance, _expires, _requestable];
}foreach("true" configClasses ( configFile >> "CfgOverthrowMissions" ));

job_system_counter = 12; //why is this here it's not a global variable;
["job_system","_counter%10 isEqualTo 0","call OT_fnc_jobLoop"] call OT_fnc_addActionLoop;
//dorf added this here to solve job problems.
publicVariable "OT_allJobs";
//dorf added this here to help initiate job loops;
//job_system_counter = 0;
//publicVariable "job_system_counter";