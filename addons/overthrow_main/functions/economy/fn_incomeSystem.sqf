/* ----------------------------------------------------------------------------
Function: incomeSystem
---------------------------------------------------------------------------- */
//Manages passive income for all players (Lease + taxes)
//Capital tax due to players doing landlord simulator -Dorf
//TLDR, below 10k and tax on, you're just linear taxing
//from 10k to 70.9k it's a double digit percentage of lease, so 10k is 10% tax, 70k is 70% tax
//from 70.9k to 100999k it's stuck to 71% up until it hits 100.9k where the player earns flat 29291
//The rest is taxed to the resistance, viva la revolution

waitUntil {sleep 1;server getVariable ["StartupType",""] != ""};
income_system_lasthour = date select 3;

["income_system_loop","_counter%3 isEqualTo 0 && {!(income_system_lasthour isEqualTo (date select 3))}","
income_system_lasthour = date select 3;

if(OT_fastTime) then {
	if(income_system_lasthour isEqualTo 19) then {
		setTimeMultiplier 8;
	};
	if(income_system_lasthour isEqualTo 7) then {
		setTimeMultiplier 4;
	};
};

if(income_system_lasthour in [0,6,12,18]) then {
	private _inf = 1;
	private _total = 0;

	_t = call OT_fnc_getTaxIncome;
	_total = _t select 0;
	_inf = _t select 1;

	_totax = 0;
	_tax = server getVariable [""taxrate"",0];
	if(_tax > 0) then {
		_totax = round(_total * (_tax / 100));
	};

	{
		private _owned = _x getvariable [""leasedata"",[]];
		_lease = 0;
		{
			_x params [""_id"",""_cls"",""_pos"",""_town""];
			private _data = [_cls,_town] call OT_fnc_getRealEstateData;
			_lease = _lease + (_data select 2);
		}foreach(_owned);
		if(_lease > 0) then {
			_tt = 0;
			if(_tax > 0) then {
				_tt = round(_lease * (_tax / 100));
				if(_lease >= 10000 and _lease < 70999) then {_tt = round(_lease * (_lease*0.00001))};
				if(_lease >= 70999 and _lease < 100999) then {_tt = round(_lease * (0.71))};
				if(_lease >= 100999) then {_tt = (_lease - 29291)};
			};
			_totax = _totax + _tt;
			[_lease-_tt,""Lease Income""] remoteExec [""OT_fnc_money"",_x,false];
		};
	}foreach([] call CBA_fnc_players);

	[_totax] call OT_fnc_resistanceFunds;
	_total = _total - _totax;

	_numPlayers = count([] call CBA_fnc_players);
	if(_numPlayers > 0) then {
		if(isNil ""_total"") then {_total = 0};
		_perPlayer = round(_total / _numPlayers);
		if(_perPlayer > 0) then {
			private _diff = server getVariable [""OT_difficulty"",1];
			if(_diff isEqualTo 0) then {_perPlayer = round(_perPlayer * 1.2)};
			if(_diff isEqualTo 2) then {_perPlayer = round(_perPlayer * 0.8)};

			_inf remoteExec [""OT_fnc_influenceSilent"",0,false];
			{
				_money = _x getVariable [""money"",0];
				_x setVariable [""money"",_money+_perPlayer,true];
			}foreach([] call CBA_fnc_players);
			format [""Tax income: $%1 (+%2 Influence)"",[_perPlayer, 1, 0, true] call CBA_fnc_formatNumber,_inf] remoteExec [""OT_fnc_notifyMinor"",0,false];
		}else{
			_inf remoteExec [""OT_fnc_influence"",0,false];
		};
	};
};
"] call OT_fnc_addActionLoop;
