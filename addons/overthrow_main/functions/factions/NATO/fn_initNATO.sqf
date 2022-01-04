if (!isServer) exitwith {};
OT_NATO_GroundForces = [];
OT_NATO_Group_Recon = "";
OT_NATO_Group_Engineers = "";
//making variables with all our possible groups in it
//yes this is spaghetti
//i don't fuckin care anymore, i hate arma
_allFactionGroups = [];
_natoGroupsInfantry = [];
_natoGroupsSupport = [];
_allSideSubfactions = "true" configClasses (configFile >> "CfgGroups" >> OT_side_NATO);
diag_log format ["All side groups: %1", _allSideSubfactions];
_allSubfactions = _allSideSubfactions select {configName (_x) in OT_subfaction_NATO};
{
	_grp = "true" configClasses (_x);
	_allFactionGroups append _grp;
} forEach _allSubfactions;
diag_log format["Faction Groups: %1", _allFactionGroups];
_natoInfantryGroupConfigs = _allFactionGroups select {(getText (_x >> "aliveCategory") in ["Mechanized","Infantry","Motorized"]) or (getText (_x >> "name") in ["Infantry","Mechanized Infantry","Motorized Infantry"])};
{
	_grp = "true" configClasses (_x);
	_natoGroupsInfantry append _grp;
} forEach _natoInfantryGroupConfigs;
diag_log format["Infantry Groups: %1", _natoGroupsInfantry];
_natoGroupSupportConfigs = _allFactionGroups select {(getText (_x >> "aliveCategory") in ["Support"]) or (getText (_x >> "name") in ["Support"])};
{
	_grp = "true" configClasses (_x);
	_natoGroupsSupport append _grp;
} forEach _natoGroupSupportConfigs;
//fallback if there's no support in your preferred faction <glares at russian orbat>
if (count _natoGroupsSupport == 0) then {
	_natoGroupsSupport = "true" configClasses (configFile >> "CfgGroups" >> OT_side_NATO >> OT_faction_NATO >> "Support");
	diag_log format["Support Groups: None found in factions. Falling back to %1 support units.", OT_faction_NATO];
};
diag_log format["Support Groups: %1", _natoGroupsSupport];
{
	private _name = configName _x;
	if((_name find "Recon") > -1) then {
		OT_NATO_Group_Recon = _x;
		OT_NATO_Group_Engineers = _x;
	};
	private _numtroops = count("true" configClasses _x);
	if(_numtroops > 5) then {
		OT_NATO_GroundForces pushback _x;
		diag_log format["Adding %1 to ground forces.", _name];
	};
}foreach(_natoGroupsInfantry);

{
	private _name = configName _x;
	if((_name find "ENG") > -1) then {
		OT_NATO_Group_Engineers = _x;
		diag_log format["Adding %1 to supports.", _name];
	};
}foreach(_natoGroupsSupport);

OT_NATO_Units_LevelOne = [];
OT_NATO_Units_LevelTwo = [];
OT_NATO_Units_CTRGSupport = [];

(OT_loadingMessages call BIS_fnc_selectRandom) remoteExec['OT_fnc_notifyStart',0,false];

private _c = 0;

{
	private _name = configName _x;
	private _unitCfg = _x;
	if(!(_name isEqualTo OT_NATO_Unit_Police) && !(_name isEqualTo OT_NATO_Unit_PoliceCommander)) then {
		[_name] call {
			params ["_name"];
			//TODO: Change this section to work off variables.
			if((_name find "_sergeant") > -1) exitWith {
				OT_NATO_Unit_TeamLeader = _name;
			};
			if((_name find "_officer_armored") > -1) exitWith {
				OT_NATO_Unit_SquadLeader = _name;
			};
			if((_name find "_rva_crew_officer") > -1 || (_name find "_rva_crew_officer") > -1) exitWith {
				OT_NATO_Unit_HVT = _name
			};
			if((_name find "_vdv_recon_") > -1) exitWith {
				OT_NATO_Units_CTRGSupport pushback _name
			};
			if(
				(_name find "_Recon_") > -1
				|| (_name find "_recon_") > -1
				|| (_name find "_story_") > -1
				|| (_name find "_Story_") > -1
				|| (_name find "_lite_") > -1
				|| (_name find "_HeavyGunner_") > -1
			) exitWith {};

			private _role = getText (_x >> "role");
			if(_role in ["MachineGunner","Rifleman","CombatLifeSaver"]) then {OT_NATO_Units_LevelOne pushback _name};
			if(_role in ["Grenadier","MissileSpecialist","Marksman"]) then {OT_NATO_Units_LevelTwo pushback _name};
			if(_role == "Marksman" && (_name find "sniper") > -1) then {OT_NATO_Unit_Sniper = _name};
			if(_role == "Marksman" && (_name find "spotter") > -1) then {OT_NATO_Unit_Spotter = _name};
			if(_role == "MissileSpecialist" && (_name find "_aa") > -1) then {OT_NATO_Unit_AA_spec = _name};

			//Generate and cache alternative loadouts for this unit
			private _loadout = getUnitLoadout _unitCfg;
			private _loadouts = [];
			for "_i" from 1 to 5 do {
				_loadouts pushback ([_loadout] call OT_fnc_randomizeLoadout);
			};
			spawner setVariable [format["loadouts_%1",_name],_loadouts,false];
			_c = _c + 1;
			if(_c isEqualTo 10) then {
				sleep 0.1;
				_c = 0;
			};
		};
	};
}foreach(format["(getNumber(_x >> 'scope') isEqualTo 2) && (getText(_x >> 'faction') in %1) && ((configName _x) isKindOf 'SoldierWB' || (configName _x) isKindOf 'SoldierGB')", OT_subfaction_NATO] configClasses (configFile >> "CfgVehicles"));
//previous line: this is compatible with normal Blufor and RHS Opfor/Russians. Swap SoldierGB for SoldierEB for CSAT support. don't ask me why the this. TODO: figure out better way
//better way probably entails getting the Type of _x and finding out if it's in an array of types.
(OT_loadingMessages call BIS_fnc_selectRandom) remoteExec['OT_fnc_notifyStart',0,false];

//Generate and cache gendarm loadouts
private _loadout = getUnitLoadout OT_NATO_Unit_Police;
private _loadouts = [];
for "_i" from 1 to 5 do {
	_loadouts pushback ([_loadout,OT_allBLUSMG] call OT_fnc_randomizeLoadout);
};
spawner setVariable [format["loadouts_%1",OT_NATO_Unit_Police],_loadouts,false];

private _loadout = getUnitLoadout OT_NATO_Unit_PoliceCommander;
private _loadouts = [];
for "_i" from 1 to 5 do {
	_loadouts pushback ([_loadout,OT_allBLUSMG] call OT_fnc_randomizeLoadout);
};
spawner setVariable [format["loadouts_%1",OT_NATO_Unit_PoliceCommander],_loadouts,false];

OT_NATO_Units_LevelTwo = OT_NATO_Units_LevelOne + OT_NATO_Units_LevelTwo;

OT_NATOobjectives = [];
OT_NATOcomms = [];

OT_NATOobjectives = server getVariable ["NATOobjectives",[]];
OT_NATOcomms = server getVariable ["NATOcomms",[]];
OT_NATOhvts = server getVariable ["NATOhvts",[]];
OT_allObjectives = [];
OT_allComms = [];
OT_NATOHelipads = [];

private _diff = server getVariable ["OT_difficulty",1];

if((server getVariable "StartupType") == "NEW" || (server getVariable ["NATOversion",0]) < OT_NATOversion) then {
	diag_log "Overthrow: Generating NATO";
	server setVariable ["NATOversion",OT_NATOversion,false];
	private _abandoned = server getVariable ["NATOabandoned",[]];

	(OT_loadingMessages call BIS_fnc_selectRandom) remoteExec['OT_fnc_notifyStart',0,false];
	sleep 0.3;
	{
		private _stability = server getVariable format ["stability%1",_x];
		if(_stability < 11 && !(_x in _abandoned)) then {
			_abandoned pushback _x;
		};
	}foreach (OT_allTowns);
	server setVariable ["NATOabandoned",_abandoned,true];
	private _startingResources = 500;
	if(_diff isEqualTo 1) then {_startingResources = 1500};
	if(_diff isEqualTo 2) then {_startingResources = 2500};
    server setVariable ["NATOresources",_startingResources,true];
	server setVariable ["garrisonHQ",1000,false];
	OT_NATOobjectives = [];
	OT_NATOcomms = [];
	OT_NATOhvts = [];
	server setVariable ["NATOobjectives",OT_NATOobjectives,false];
	server setVariable ["NATOcomms",OT_NATOcomms,false];
	server setVariable ["NATOhvts",OT_NATOhvts,false];

	private _numHVTs = 6;
	if(_diff == 0) then {_numHVTs = 4};
	if(_diff == 2) then {_numHVTs = 8};

	//Find military objectives. If the new map init isn't set, fall back to the default Unholy Alliance.
	_groundvehs = [];
	if(count OT_all_NATO_Vehicles == 0) then {
		_groundvehs = OT_allBLUOffensiveVehicles select {!((_x isKindOf "Air") || (_x isKindOf "Tank") || (_x isKindOf "Ship"))};
	}else
	{
		_groundvehs = OT_all_NATO_Vehicles select {!((_x isKindOf "Air") || (_x isKindOf "Tank") || (_x isKindOf "Ship"))};
	};
	{
		_x params ["_pos","_name","_worth"];
		if !(_name in _abandoned) then {
			diag_log format["Overthrow: Initializing %1",_name];
			OT_NATOobjectives pushBack _x;
			server setVariable [format ["vehgarrison%1",_name],[],true];

            private _base = 8;
            private _statics = OT_NATO_StaticGarrison_LevelOne;
            if(_worth > 500) then {
                _base = 16;
                _statics = OT_NATO_StaticGarrison_LevelTwo;
            };
            if(_worth > 1000) then {
                _base = 24;
                _statics = OT_NATO_StaticGarrison_LevelThree;
            };
			if((random 300) < ((count _groundvehs)+_base)) then {
				_veh = (selectRandom _groundvehs);
				diag_log format["Adding %1 to %2",_veh call OT_fnc_vehicleGetName,_name];
				_statics pushbackUnique _veh;
			};
			private _garrison = floor(_base + random(8));

			if(_name isEqualTo OT_NATO_HQ) then {
				_garrison = 48;
				server setVariable [format ["vehgarrison%1",_name],OT_NATO_HQ_Vehicles,true];
				_garr = [];
				{
					_x params ["_class","_num"];
					_count = 0;
					while {_count < _num} do {
						_count = _count + 1;
						_garr pushback _class;
					};
				}foreach(OT_NATO_Vehicles_JetGarrison);
				server setVariable [format ["airgarrison%1",_name],_garr,true];
				OT_NATO_HQPos = _pos;
				if((count OT_NATO_HQ_garrisonPos) isEqualTo 0) then {
					OT_NATO_HQ_garrisonPos = _pos;
				};
			}else{
				server setVariable [format ["airgarrison%1",_name],[],true];
				server setVariable [format ["vehgarrison%1",_name],_statics,true];
			};
			server setVariable [format ["garrison%1",_name],_garrison,true];

		}else{
			OT_NATOobjectives pushBack _x;
		};
		//Check for helipads
		if !(_name in OT_allAirports) then {
			private _helipads = (_pos nearObjects ["Land_HelipadCircle_F", 400]) + (_pos nearObjects ["Land_HelipadSquare_F", 400]);
			if((count _helipads) > 0) then {
				OT_NATOHelipads pushbackUnique _x;
			};
		};
	}foreach (OT_objectiveData + OT_airportData);

	private _count = 0;
	private _done = [];
	while {_count < _numHVTs} do {
		private _ob = selectRandom (OT_NATOobjectives - ([[OT_NATO_HQ,OT_NATO_HQPos]] + _done));
		private _name = _ob select 1;
		_done pushback _ob;
		private _id = format["%1%2",_name,round(random 99999)];
		OT_NATOhvts pushback [_id,_name,""];
		_count = _count + 1;
	};

	(OT_loadingMessages call BIS_fnc_selectRandom) remoteExec['OT_fnc_notifyStart',0];
	sleep 0.3;
	//Add comms towers
	{
		_x params ["_pos","_name"];
		OT_NATOcomms pushBack [_pos,_name];
		private _garrison = floor(4 + random(4));
		server setVariable [format ["garrison%1",_name],_garrison,true];
	}foreach (OT_commsData);

	server setVariable ["NATOobjectives",OT_NATOobjectives,true];
	server setVariable ["NATOcomms",OT_NATOcomms,true];
	server setVariable ["NATOhvts",OT_NATOhvts,true];
	diag_log "Overthrow: Distributing NATO vehicles";

    //Weighted airport list to distribute air vehicles
    private _prilist = [];
    {
        _x params ["_pos","_name","_worth"];
		if(_name != OT_NATO_HQ) then {
	        _prilist pushback _name;
			if(_worth > 900) then {
	            _prilist pushback _name;
	        };
	        if(_worth > 1200) then {
	            _prilist pushback _name;
	        };
	        if(_worth > 2500) then {
	            _prilist pushback _name;
	        };
		};
    }foreach(OT_airportData);

	if((count _prilist) > 0) then {
		{
			_x params ["_type","_num"];
			private _count = 0;
			while {_count < _num} do {
				private _name = _prilist call BIS_fnc_selectRandom;
				private _garrison = server getVariable [format["airgarrison%1",_name],[]];
				_garrison pushback _type;
				_count = _count + 1;
				server setVariable [format ["airgarrison%1",_name],_garrison,true];
			};
		}foreach(OT_NATO_Vehicles_AirGarrison);

		//Distribute some random Air vehicles. Fall back to random NATO planes if the variable is empty in the initVar.sqf for the map.
		_airvehs = [];
		if(count OT_all_NATO_Vehicles == 0) then {
			_airvehs = OT_allBLUOffensiveVehicles select {_x isKindOf "Air"};
			diag_log format["Air vehicles, fallback: %1", _airvehs]
		} else {
			_airvehs = OT_all_NATO_Vehicles select {_x isKindOf "Air"};
			diag_log format["Air vehicles, init spec: %1", _airvehs]
		};
		{
			_name = _x;
			if((random 200) < (count _airvehs)) then {
				_type = selectRandom _airvehs;
				private _garrison = server getVariable [format["airgarrison%1",_name],[]];
				_garrison pushback _type;
				server setVariable [format ["airgarrison%1",_name],_garrison,true];
			};
		}foreach(_prilist);
	};

	//Distribute static AA to airfields
	{
		_x params ["","_name"];
		_vehs = server getVariable [format ["vehgarrison%1",_name],[]];
		_vehs = _vehs + OT_NATO_Vehicles_StaticAAGarrison;
		server setVariable [format ["vehgarrison%1",_name],_vehs,true];
	}foreach(OT_airportData);

	diag_log "Overthrow: Setting up NATO checkpoints";
	{
		if((server getVariable [format ["garrison%1",_x],-1]) isEqualTo -1) then {
			private _garrison = floor(8 + random(6));
			if(_x in OT_NATO_priority) then {
				_garrison = floor(12 + random(6));
			};

			//_x setMarkerText format ["%1",_garrison];
			_x setMarkerAlpha 0;
			server setVariable [format ["garrison%1",_x],_garrison,true];
		};
	}foreach (OT_NATO_control);

	diag_log "Overthrow: Garrisoning towns";
	{
		private _town = _x;
		private _garrison = 0;
		private _stability = server getVariable format ["stability%1",_town];
		private _population = server getVariable format ["population%1",_town];
		if(_stability > 10) then {
			private _max = round(_population / 30);
			_max = _max max 4;
			_garrison = 2+round((1-(_stability / 100)) * _max);
			if(_town in OT_NATO_priority) then {
				_garrison = round(_garrison * 2);
			};
		};
		server setVariable [format ["garrison%1",_x],_garrison,true];
	}foreach (OT_allTowns);
	sleep 0.3;
};
diag_log "Overthrow: NATO Init Done";

{
	_x params ["_pos","_name","_pri"];
	private _mrk = createMarker [_name,_pos];
	_mrk setMarkerShape "ICON";
	if(_name in (server getVariable "NATOabandoned")) then {
		_mrk setMarkerType OT_flagMarker;
	}else{
		if(_name isEqualTo OT_NATO_HQ) then {
			_mrk setMarkerType "ot_HQ";
		}else{
			_mrk setMarkerType "flag_NATO";
		};
	};

	_mrk = createMarker [_name+"_restrict",_pos];
	_mrk setMarkerShape "ELLIPSE";
	_mrk setMarkerBrush "BDIAGONAL";
	private _dist = 200;
	if(_name in OT_NATO_priority) then {_dist = 500};
	_mrk setMarkerSize [_dist, _dist];
	_mrk setMarkerColor "ColorRed";
	if(_name in (server getVariable "NATOabandoned")) then {
		_mrk setMarkerAlpha 0;
	}else{
		_mrk setMarkerAlpha 0.4;
	};

	server setVariable [_name,_pos,true];

	OT_allObjectives pushback _name;

	//Check for helipads
	if !((server getVariable "StartupType") == "NEW" || (server getVariable ["NATOversion",0]) < OT_NATOversion) then {
		if !(_name in OT_allAirports) then {
			private _helipads = (_pos nearObjects ["Land_HelipadCircle_F", 400]) + (_pos nearObjects ["Land_HelipadSquare_F", 400]);
			if((count _helipads) > 0) then {
				OT_NATOHelipads pushbackUnique _x;
			};
		};
	};

	//Set supply cache locations for this session
	//first try to find a warehouse to put it at
	private _warehouses = (_pos nearObjects [OT_warehouse, 400]);
	private _supplypos = _pos;
	if((count _warehouses) isEqualTo 0) then {
		//just pick a random position
		_supplypos = _pos findEmptyPosition [4,100,OT_item_Storage];
	}else{
		//put it at the warehouse
		_supplypos = (getpos(_warehouses select 0)) findEmptyPosition [4,100,OT_item_Storage];
	};
	spawner setVariable [format["NATOsupply%1",_name],_supplypos,false];

	//Now generate whats in it
	private _items = [];
	private _wpns = [];
	private _mags = [];

	private _done = 0;
	private _supplyamount = (_pri - 50) + (random 200);
	diag_log format["Supply at %1: %2", _name, _supplyamount];
	while {_done < _supplyamount} do {
		private _rnd = random 100;
		_rnd call {
			if(_this > 90) exitWith {
				//Add some radios (10% chance)
				_done = _done + 13;
				_items pushback ["ItemRadio",(2-_diff)+(round(random (5-_diff)))];
			};
			if(_this > 89) exitWith {
				//Add a random launcher (1% chance)
				_done = _done + 50;
				_wpn = selectRandom OT_allBLULaunchers;
				_wpns pushback [_wpn,1+(round(random (2-_diff)))];
				_mags pushback [(getArray (configFile >> "CfgWeapons" >> _wpn >> "magazines")) select 0,5];
			};
			if (_this > 30) exitWith {
				//Add a random ammo, and maybe a random weapon. 59% chance.
				if(_this > 30) then {
					//Add random ammunition (59% chance total).
					_done = _done + 10;
					_mags pushback [selectRandom OT_allBLURifleMagazines,3+(round(random (4-_diff)) * 2)];
				};
				if(_this > 60) exitWith {
					//Add a random rifle (29% chance total)
					_done = _done + 25;
					_wpn = "";
					if (count OT_NATO_weapons_Rifles != 0) then {
						_wpn = selectRandom OT_NATO_weapons_Rifles;
					} else {
						_wpn = selectRandom OT_allBLURifles;
					};
					_wpns pushback [_wpn,1+(round(random (2-_diff)))];
					_mags pushback [(getArray (configFile >> "CfgWeapons" >> _wpn >> "magazines")) select 0,5];
				};
				if(_this > 45) exitWith {
					//Add a random pistol (15% chance total)
					_done = _done + 12;
					_wpn = "";
					if (count OT_NATO_weapons_Pistols != 0) then {
						_wpn = selectRandom OT_NATO_weapons_Pistols;
					} else {
						_wpn = selectRandom OT_allBLUPistols; 
					};
					_wpns pushback [_wpn,1+(round(random (3-_diff)))];
					_mags pushback [(getArray (configFile >> "CfgWeapons" >> _wpn >> "magazines")) select 0,5];
				};
			};
			//Add some meds (% chance)
			_done = _done + 20;
			_items pushback [selectRandom ["ACE_fieldDressing","ACE_fieldDressing","ACE_morphine"],(2-_diff)+(round(random (5-_diff)))];
		};
	};
	spawner setVariable [format["NATOsupplyitems%1",_name],[_items,_wpns,_mags],false];
}foreach(OT_NATOobjectives);
sleep 0.3;

publicVariable "OT_allObjectives";

{
	_x params ["_pos","_name"];
	private _mrk = createMarker [_name,_pos];
	_mrk setMarkerShape "ICON";
	_mrk setMarkerType "loc_Transmitter";
	if(_name in (server getVariable "NATOabandoned")) then {
		_mrk setMarkerColor "ColorGUER";
	}else{
		_mrk setMarkerColor "ColorBLUFOR";
	};
	server setVariable [_name,_pos,true];
	OT_allComms pushback _name;
	OT_allObjectives pushback _name;

	_mrk = createMarker [_name+"_restrict",_pos];
	_mrk setMarkerShape "ELLIPSE";
	_mrk setMarkerBrush "BDIAGONAL";
	private _dist = 40;
	if(_name in OT_NATO_priority) then {_dist = 500};
	_mrk setMarkerSize [_dist, _dist];
	_mrk setMarkerColor "ColorRed";
	if(_name in (server getVariable "NATOabandoned")) then {
		_mrk setMarkerAlpha 0;
	}else{
		_mrk setMarkerAlpha 0.4;
	};
}foreach(OT_NATOcomms);
sleep 0.3;
private _revealed = server getVariable ["revealedFOBs",[]];
{
	_x params ["_pos","_garrison","_upgrades"];
	OT_flag_NATO createVehicle _pos;

	private _count = 0;
	private _group = creategroup blufor;
	while {_count < _garrison} do {
		//@TODO modify start position to fix spawning in rocks
		//_start setVectorUp surfaceNormal position _start 
		private _start = [[[_pos,50]]] call BIS_fnc_randomPos;

		private _civ = _group createUnit [OT_NATO_Units_LevelOne call BIS_fnc_selectRandom, _start, [],0, "NONE"];
		_civ setVariable ["garrison","HQ",false];
		_civ setRank "LIEUTENANT";
		_civ setVariable ["VCOM_NOPATHING_Unit",true,false];
		_civ setBehaviour "SAFE";

		_count = _count + 1;
	};
	_group call OT_fnc_initMilitaryPatrol;

	[_pos,_upgrades] call OT_fnc_NATOupgradeFOB;

	private _id = str _pos;
	if(_id in _revealed) then {
		//create marker
		_mrkid = createMarker [format["natofob%1",_id],_pos];
		_mrkid setMarkerShape "ICON";
		_mrkid setMarkerType "mil_Flag";
		_mrkid setMarkerColor "ColorBLUFOR";
		_mrkid setMarkerAlpha 1;
	};
}foreach(server getVariable ["NATOfobs",[]]);


//Dorf added pub variables below; Will swap to case-by-case server calls in future;
publicVariable "OT_NATO_GroundForces";
publicVariable "OT_NATO_Group_Recon";
publicVariable "OT_NATO_Group_Engineers";

publicVariable "OT_NATO_Units_LevelOne";
publicVariable "OT_NATO_Units_LevelTwo";
publicVariable "OT_NATO_Units_CTRGSupport";

publicVariable "OT_NATOobjectives";
publicVariable "OT_NATOcomms";
publicVariable "OT_NATOhvts";
publicVariable "OT_NATOHelipads";
//Dorfs pub variables done;
publicVariable "OT_allObjectives";
publicVariable "OT_allComms";
OT_NATOInitDone = true;
publicVariable "OT_NATOInitDone";
