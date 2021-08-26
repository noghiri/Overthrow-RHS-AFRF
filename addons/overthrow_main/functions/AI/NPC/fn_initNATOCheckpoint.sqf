params ["_group", "_dirOff"];
private _xStart = 0;
private _yStart = 0;
private _numStatic = 0;
{
	if (vehicle _x != _x) then {
		_numStatic = _numStatic + 1;
		_xStart = _xStart + (getPos _x select 0); 
		_yStart = _yStart + (getPos _x select 1);
	}
}foreach units _group;

private _start = [(_xStart / _numStatic),(_yStart / _numStatic)];

private _outerRange = 70;
private _innerRange = 30;
private _searchingRange = 5;
private _aSide = [];
private _bSide = [];
private _inrange = [];
private _searching = [];
private _searched = [];
private _searchedFoot = [];
private _gone = [];
private _vehs = [];
private _warned = [];
private _leaving = [];

private _bargates = _start nearobjects ["Land_BarGate_F",50];
private _abargates = [];
private _bbargates = [];
private _coneDir1 = 90+_dirOff;
private _coneDir2 = 270+_dirOff;

if(_coneDir1 > 360) then {
	_coneDir1 = _coneDir1 - 360;
};
if(_coneDir2 > 360) then {
	_coneDir2 = _coneDir2 - 360;
};
{
	private _dir = [_x, _start] call BIS_fnc_dirTo;
	if(_dir >= _coneDir1 && _dir < _coneDir2) then {
		if(!(_x in _abargates)) then {
			_abargates pushback _x;
		};
	} else {
		if(!(_x in _bbargates)) then {
			_bbargates pushback _x;				
		};
	};

}forEach _bargates;

[_group,_start,50,4] call CBA_fnc_taskPatrol;

while {!(isNil "_group") && count (units _group) > 0} do {

	_group setVariable ["VCM_NORESCUE",true];
	_group setVariable ["VCM_TOUGHSQUAD",true];

	_vehs = [];
	_friendly = [];
	
	private _leader = leader _group;
	//For each thing comming to the checkpoint
	{
		_unit = _x;
		_iscar = false;
		if(_unit isKindOf "LandVehicle" && !(side _x isEqualTo west)) then {			
			_iscar = true;
			_f = false;

			if (_vehs find _x isEqualTo -1 && _x distance _start < _innerRange && captive _unit) then {
				_vehs pushBack _x;
			};
		};
		if(_unit isKindOf "LandVehicle" && (side _x isEqualTo west) && group _x != _group) then {
			_friendly pushback _x;
		};
		if !(_unit in _inrange || _unit in _searching || _unit in _searched) then {
			if(_unit call OT_fnc_unitSeenNATO) then {
				if(! isPlayer _unit) then {
					NOTPLAYER = true;
				};

				if((isPlayer _unit) && (captive _unit)) then {
					if(_iscar) then {
						if(_unit distance _start <= _innerRange) then {
							[_leader, {_this globalchat "Please drive into the search area and STAY in your vehicle!"}] remoteExec ["call", _unit, false];
							
							_inrange pushback _unit;
						} else {
							if(!(_unit in _warned) && _unit distance _start <= _outerRange) then {
								[_leader, {_this globalchat "WARNING! You are approching a checkpoint. SLOW DOWN!"}] remoteExec ["call", _unit, false];
								_warned pushback _unit;
								
							};
						}
					}else{						
						if(_unit distance _start < _innerRange && !(_unit in _inrange)) then {
							_inrange pushBack _unit;
							[_leader, {_this globalchat "Stand still inside the checkpoint while we search you."}] remoteExec ["call", _unit, false];
						};
					};
				};
			};
		};

		//Subject direction watch
		//Two sides A and B, a search is needed to cross sides
		if((isPlayer _unit) && (captive _unit) && _unit distance _start > _searchingRange) then { //Dont cont units in the middle as they are crossing over
		 	if(_unit call OT_fnc_unitSeenNATO) then {
				private _dir = [_unit, _start] call BIS_fnc_dirTo;

				if(_dir >= _coneDir1 && _dir < _coneDir2) then {
					if(!(_unit in _aSide)) then {
						_aSide pushback _unit;
					};
				} else {
					if(!(_unit in _bSide)) then {
						_bSide pushback _unit;				
					};
				};
			};
		};
		if(_unit in _aSide && _x distance _start > _outerRange) then {
			_aSide deleteAt (_aSide find _unit);
		};
		if(_unit in _bSide && _x distance _start > _outerRange) then {
			_bSide deleteAt (_bSide find _unit);
		};
		
	}foreach(_start nearentities [["CaManBase","LandVehicle"],_outerRange]);

	//Gates
	if((count _vehs) > 0 || (count _friendly) > 0) then {
		if((count _aSide) > 0) then {
			{
				_x animate ["Door_1_rot",1];
			}foreach(_abargates);
		};
		if((count _bSide) > 0) then {
			{
				_x animate ["Door_1_rot",1];
			}foreach(_bbargates);
		};
		if((count _friendly) > 0 || (count _searched) > 0) then {
			{
				_x animate ["Door_1_rot",1];
			}foreach(_bargates);
		};
	}else{
		
		if((count _friendly) == 0 && (count _vehs) == 0) then {
			{
				_x animate ["Door_1_rot",0];
			}foreach(_bargates);
		} else {
			if((count _aSide) == 0) then {
				{
					_x animate ["Door_1_rot",0];
				}foreach(_abargates);
			};
			if((count _bSide) == 0) then {
				{
					_x animate ["Door_1_rot",0];
				}foreach(_bbargates);
			};
		};
	};

	//For each thing that enters the checkpoint
	_gone = [];
	
	{
		//Wanted
		if(! captive _x) then {
			_gone pushback _x;
		};

		//Leaving
		if(_x distance _start > _innerRange && isPlayer _x && !(_x in _searched) && !(_x in _leaving) ) then {
			//Unit is leaving without a search
			_leaving pushback _x;
			[_leader, {_this globalchat "Get back here or we WILL open fire!"}] remoteExec ["call", _x, false];
		};

		//Unit has left the area
		if(_x distance _start > _outerRange) then {			
			_gone pushback _x;

			//Was not searched
			if(isPlayer _x && !(_x in _searched)) then {
				_x setCaptive false;
				[_x] call OT_fnc_revealToNATO;
			};

		//Is still in area
		}else{

			//Is in search range
			if(_x distance _start < _searchingRange) then {
				//If not being searched or already searched
				if !(_x in _searching || _x in _searched) then {
						//Start searching
						_searching pushback _x;

				}else{
					//Being searched
					if(!(_x in _searched)) then {
						if([_x,_leader] call OT_fnc_NATOCpSearch) then {
							_searched pushBack _x;
							_searching deleteAt(_searching find _x);
						} else {
							_gone pushBack _x;
						};
					};
				};

			}else{
				//Was being searched and moved out of the search area
				if (_x in _searching) then {
					if(isPlayer _x) then {[_leader, {_this globalchat "Return to the checkpoint immediately and wait while you are searched"}] remoteExec ["call", _x, false];};
					_searching deleteAt(_searching find _x);
				}
			};
		};
		if(! alive _x) then {
			_gone pushBack _x;
		};
	}foreach(_inrange);

	//For every thing that has left the checkpoint area
	{
		if (crew _x select 0 != _x) then {
		  _gone append crew _x;
		};
		_inrange deleteAt (_inrange find _x);
		if(_x in _searched) then {
			_searched deleteAt (_searched find _x);
			if(_x in _aSide) then {_aSide deleteAt (_aSide find _x);};
			if(_x in _bSide) then {_bSide deleteAt (_bSide find _x);};
		};
		if(_x in _leaving) then {
			_leaving deleteAt (_leaving find _x);
		};
		if(_x in _warned) then {
			_warned deleteAt (_warned find _x);
		};
		
	}foreach(_gone);	
	sleep 2;

	if(count _inrange > 0) then {
		diag_log format ["_inrange:%1 _searched:%2 _searching:%3 _vehs:%4 _searchedFoot:%5 (_inrange select 0 distance _start):%6 _leader:%7", _inrange, _searched, _searching, _vehs, _searchedFoot, (_inrange select 0 distance _start), _leader];
	}
};