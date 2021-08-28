// fnc_bankDialog calls goes here.

closedialog 0;
createDialog "OT_dialog_bank";
openMap false;

disableSerialization;

params ["_support", "_money"];

handleMoney = {
	params = ["_term", "_amount"];

	if (_term == "withdrawal") then {
		//withdrawal up to the percentage capacity of the player's wallet.
		hint "Withdrawal ordered";

	} else { 
		hint "deposit ordered";
		//deposit a percentage of the player's cash money into crypto.
	};

};
/*
private _fitness = player getVariable ["OT_arr_fitness",[1, 1]];
private _ctrl = (findDisplay 8003) displayCtrl 1100;
_ctrl ctrlSetStructuredText parseText format["<t size=""2"">Fitness</t><br/><t size=""1.1"">Level %1</t><br/><t size=""0.7"">Increases the distance you can sprint</t>",_fitness select 1];

private _trade = player getVariable ["OT_arr_trade",[1, 1]];
_ctrl = (findDisplay 8003) displayCtrl 1101;
_ctrl ctrlSetStructuredText parseText format["<t size=""2"">Trade</t><br/><t size=""1.1"">Level %1</t><br/><t size=""0.7"">Ability to negotiate better purchasing prices</t>",_trade select 1];

private _stealth = player getVariable ["OT_arr_stealth",[1, 1]];
_ctrl = (findDisplay 8003) displayCtrl 1102;
_ctrl ctrlSetStructuredText parseText format["<t size=""2"">Stealth</t><br/><t size=""1.1"">Level %1</t><br/><t size=""0.7"">Less chance of NATO finding illegal items</t>",_stealth select 1];

getPerkLevel = {
	params ["_perk", "_perk_level"];
	_perk_level = player getVariable [format["OT_arr_%1",_perk],[1,1]];
	_perk_level = _perk_level select 0;
	_perk_level;
};

getPerkPrice = {
	private _perk = _this select 0;
	private _selected_perk = player getVariable [format["OT_arr_%1",_perk],[1,1]];
	private _price = 10;
	_selected_perk = _selected_perk select 0;
	if(_selected_perk isEqualTo 2) then {
		_price = 100;
	};
	if(_selected_perk isEqualTo 3) then {
		_price = 500;
	};
	if(_selected_perk isEqualTo 4) then {
		_price = 1000;
	};
	_price;
};

getResetPrice = {
	params ["_perk", "_influence", "_price"];
	_perk = _this select 0; //gets perk name not sure what do with this tbh fam.
	_influence = player getVariable ["influence", 0];	
	_price = round (_influence * 0.25) + 1000; //Quarter of a player's entire influence plus 1k
	_price;
};

private _price = ["fitness"] call getPerkPrice;
ctrlSetText [1600,format["Roll for Level Increase (-%1 Influence) %2/5",_price, ["fitness"] call getPerkLevel]];
_price = ["fitness"] call getResetPrice;
ctrlSetText [1603,format["Reset Level (-%1 Influence)", _price]];

_price = ["trade"] call getPerkPrice;
ctrlSetText [1601,format["Roll for Level Increase (-%1 Influence) %2/5",_price, ["trade"] call getPerkLevel]];
_price = ["trade"] call getResetPrice;
ctrlSetText [1604,format["Reset Level (-%1 Influence)", _price]];

_price = ["stealth"] call getPerkPrice;
ctrlSetText [1602,format["Roll for Level Increase (-%1 Influence) %2/5",_price, ["stealth"] call getPerkLevel]];
_price = ["stealth"] call getResetPrice;
ctrlSetText [1605,format["Reset Level (-%1 Influence)", _price]];

//Display of increase is disabled when it reaches 5.
if(_fitness select 0 isEqualTo 5) then {
	ctrlShow [1600,false];
};

if(_trade select 0 isEqualTo 5) then {
	ctrlShow [1601,false];
};

if(_stealth select 0 isEqualTo 5) then {
	ctrlShow [1602,false];
};

//Display of reset is disabled when it reaches lvl 1.
if(_stealth select 0 isEqualTo 1) then {
	ctrlShow [1603,false];
};

if(_stealth select 0 isEqualTo 1) then {
	ctrlShow [1604,false];
};

if(_stealth select 0 isEqualTo 1) then {
	ctrlShow [1605,false];
};

buyPerk = {
	//Dorf: I rewrote this to sort of loop the function into accepting the reset button while displaying its costs;
	//Reset costs Constant + 1/4 of the influence of a Player to let them dump unspent resources;
	//In the future these perks should be balanced where there is still 5 level ups but, the levels can increase to 21 due to RNG.
	//RNG included will incentivise spending influence to reset your skills.
	params ["_perk", "_reset_perk", "_price", "_reset_price", "_selected_perk_arr", "_selected_perk", "_selected_perk_rng"];
	disableSerialization;

	//We set perk variables here if they don't exist.
	_selected_perk_arr = player getVariable [format["OT_arr_%1",_perk],[1, 1]];
	_selected_perk = _selected_perk_arr select 0;
	_selected_perk_rng = _selected_perk_arr select 1;
	_price = [_perk] call getPerkPrice;
	_reset_price = [_perk] call getResetPrice;
	private _inf = player getVariable ["influence",0];
	if((_inf < _reset_price) && (_reset_perk)) exitWith {"You do not have enough influence to reset this perk" call OT_fnc_notifyMinor};
	if((_inf < _price && (!_reset_perk))) exitWith {"You do not have enough influence" call OT_fnc_notifyMinor};

	if (_reset_perk) then {
		_selected_perk = 1;
		_selected_perk_rng = 1;
	} else {
		_selected_perk = _selected_perk + 1;
		//This is mimicking X Dice rolls where if all hits, you get a +X to your stat.
		//Max stat you're possible to obtain per character is a 21, 5 (base guaranteed) + 16 (from 3d2); (full is 21% but usable is subtracted to 20%)
		_selected_perk_rng = _selected_perk_rng + 1 + floor(1/(ceil(random 2))) + floor(1/(ceil(random 2))) + floor(1/(ceil(random 2))) + floor(1/(ceil(random 2.5)));
	};
	//This is actually where you "set" the variables for perks...
	player setVariable [format["OT_arr_%1",_perk],[_selected_perk, _selected_perk_rng],true];
	private _idcc = 1100;
	private _idc = 1600;
	if(_perk isEqualTo "trade") then {_idc = 1601;_idcc = 1101};
	if(_perk isEqualTo "stealth") then {_idc = 1602;_idcc = 1102};


	if(_selected_perk isEqualTo 5) then {
		ctrlEnable [_idc,false];
	} else {
		ctrlEnable [_idc,true];
	};
	if (_selected_perk isEqualTo 1) then {
		ctrlEnable [_idc+3, false]; //This is +3 because I set up the _idc to be +3 from respective leveling button ids.
	} else {
		ctrlEnable [_idc+3, true];
	};

	if (_reset_perk) then {
		player setVariable ["influence",_inf - _reset_price,true];
	} else {
		player setVariable ["influence",_inf - _price,true];
	};

	//These are the displays of subtext and main text boxes
	private _ctrl = (findDisplay 8003) displayCtrl _idcc;
	_txt = format["<t size=""2"">Fitness</t><br/><t size=""1.1"">Level %1</t><br/><t size=""0.7"">Increases the distance you can sprint</t>",_selected_perk_rng];
	if(_perk isEqualTo "trade") then {
		_txt = format["<t size=""2"">Trade</t><br/><t size=""1.1"">Level %1</t><br/><t size=""0.7"">Ability to negotiate better purchasing prices</t>",_selected_perk_rng];
	};
	if(_perk isEqualTo "stealth") then {
		_txt = format["<t size=""2"">Stealth</t><br/><t size=""1.1"">Level %1</t><br/><t size=""0.7"">Less chance of people recognizing you or finding illegal items</t>",_selected_perk_rng];
	};

	//Reset levels show when a single level is levelled up 
	//Reset levels doesn't refresh beyond the selected level when it is levelled up;

	_ctrl ctrlSetStructuredText parseText _txt;
	_price = [_perk] call getPerkPrice;
	//_reset_price = [_perk] call getResetPrice;
	ctrlSetText [_idc,format["Roll for Level Increase (-%1 Influence) %2/5",_price,_selected_perk]];
	//ctrlSetText [_idc+3, format ["Reset Level (-%1 Influence)",_reset_price]];
	if(_selected_perk isEqualTo 5) then {
		ctrlShow [_idc,false];
	} else {
		ctrlShow [_idc,true];
	};
	private _perk_names = ["fitness", "trade", "stealth"];
	for [{private _i = 0}, {_i < 3}, {_i = _i + 1}] do {
		_selected_perk_arr = player getVariable [format["OT_arr_%1",_perk_names select _i],[1,1]];
		_selected_perk = _selected_perk_arr select 0;
		_reset_price = [_perk_names select _i] call getResetPrice;
		_idc = 1600 + _i + 3;
		ctrlSetText [_idc, format ["Reset Level (-%1 Influence)",_reset_price]];

		if (_selected_perk isEqualTo 1) then {
			ctrlEnable [_idc, false]; //This is +3 because I set up the _idc to be +3 from respective leveling button ids.
		} else {
			ctrlEnable [_idc, true];
		};

		if(_selected_perk isEqualTo 1) then {
			ctrlShow [_idc,false];
		} else {
			ctrlShow [_idc,true];
		};
	};

};
*/