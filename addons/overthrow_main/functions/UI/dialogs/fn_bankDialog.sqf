// fnc_bankDialog calls goes here.

closedialog 0;
createDialog "OT_dialog_bank";
openMap false;

disableSerialization;

handleWallet = {
	params = ["_amount"];
	//Intakes [-integer] or [integer] for subtracting or addition;
	//Basically checks if player can be given money to wallet;
	//Will notify players if they don't have enough money;
	//@TODO FINISH THIS Sept 05;
	private _plusmin = "-";
	private _playerBank_arr = player getVariable ["OT_arr_BankVault",[0, 0]];
	private _playerWallet = player getVariable ["money",0];
	_amount = _amount select 0; //This is the change in money, negative/positive integers;
	private _totalMoney = 0;
	private _money_cap = 2000000; // 2 million cap CONSTANT;
	private _playerBank_money = _playerBank_arr select 0;

	//Legacy "money" check to see if wallet is greater than 2 million TAD;
	if (_playerWallet > _money_cap) then {
		//Skim player wallet til 2 million 
		//Should not take in consideration of the _amount parameter of handleWallet;
		//Then notify players of money moving into the bank
		player setVariable ["money",_money_cap, true];
		private _changed_amount = _playerWallet - _money_cap;
		_playerBank_money = _playerBank_money + _changed_amount;

		player setVariable ["OT_arr_BankVault", [_playerBank_money, _playerBank_arr select 1], true];
		format["Wallet %1$(%2), Bank +$(%2)",_plusmin,[_changed_amount, 1, 0, true] call CBA_fnc_formatNumber] call OT_fnc_notifyMinor;
	};

	if (_amount > 0) then {
		//_amount is the input change for player money/bank;
		_plusmin = "+"
		private _wallet_amount = 0; // for reporting notification in end;
		private _bank_amount = 0;// for reporting notif in end;
		if (_money_cap >= (_playerWallet + _amount)) then {
			//if player's changed _amount of money does not exceed the _money_cap of 2 million;

			[_amount] call OT_fnc_money;
			//player setVariable ["money", _money_cap, true]; //First we set money to 2 million on _money_cap;
			//_wallet_amount = _amount;
			//_playerBank_money = _playerBank_money + ((_playerWallet + _amount) - _money_cap);
			//player setVariable ["OT_arr_BankVault", [_playerBank_money, _playerBank_arr select 1], true];
			//_playerWallet = _money_cap; //This gets used in notification formatting below;
			//format []
		} else {
			//if player's changed _amount of money and wwallet exceeds _money_cap of 2 million constant;
			//2 million goes in _playerWallet, excess goes in bank automatically;
			//players will be notified through _wallet_amount and _bank_amount;
			_bank_amount = _playerWallet + _amount - _money_cap ;
			_wallet_amount = _bank_amount + 
			_playerWallet = _money_cap;

			player setVariable ["money", _playerWallet, true];
		
		};

		//Deliver player notification to money
		
		format ["%1%2",_plusmin, _playerWallet]call OT_fnc_notifyMinor;
	} else {

	};
};

handleBank = {
	params = ["_term", "_amount"];

	if (_term == "withdrawal") then {
		//withdrawal up to the percentage capacity of the player's wallet.
		hint "Withdrawal ordered";

	} else { 
		hint "deposit ordered";
		//deposit a percentage of the player's cash money into crypto.
	};

};

handleCrypto = {
	params = ["_term", "_amount"];
	//_term can be buy/sell;
	//_amount can be 0.0001~1 for sell orders or 100,000 to 2,000,000 on buy orders;

	if (_term isEqualTo "buy") {

	} else {

	};
};

factionsToText = {
	//This filters factions and gives a text list for display;
	//NAME1, 'Reputation': INTEGER1 <linebreak> 
	//NAME2, 'Reputation': INTEGER2 <linebreak>
	//Etc etc., currently not used

	params ["_factions_text", "_rep"];
	_factions_text = [];
	{ 
		_x params ["_cls","_name","_side"]; 
		//Filters out the factions that does not have _cls, aka locational spawn coordinates, not on map or not helping resistance (BLUFOR);
		if !(server getVariable [format["factionrep%1",_cls],[]] isEqualTo []) then {
			_rep = server getVariable [format["standing%1",_name],0];
			_factions_text pushback _name + ", Reputation:" + str _rep; 
		};
	}foreach(OT_allFactions); 
	_factions_text = _factions_text joinString "<br/>";
	_factions_text;
};

cryptoDisplayAll = {
	private _bankCrypto = player getVariable ["OT_arr_BankVault",[0, 0]] select 1;
	private _ctrl = (findDisplay 8005) displayCtrl 1100;
	private _playerMoneyStr = "Wallet: $"; //String;
	_playerMoneyStr = _playerMoneyStr + ([player getVariable ["money", 0], 1, 0, true] call CBA_fnc_formatNumber);
	_playerMoneyStr = _playerMoneyStr + "<br/>Your APX Storage: " + ([_bankCrypto, 1, 4, true] call CBA_fnc_formatNumber);
	//GLOBAL APX Capacity is dictated by an algorithm and need to be re-evaluated and called upon else where;
	private _cryptoCap = [0.1]; //Array format hopefully can expand upon in the future;
	_playerMoneyStr = _playerMoneyStr + "<br/>Global APX Market Cap: " + ([_cryptoCap select 0, 1, 4, true] call CBA_fnc_formatNumber);
	_ctrl ctrlSetStructuredText parseText format["<t size=""2"">Crypto Exchange</t><br/><t size=""1.1"">Apexium (APX)</t><br/><t size=""0.7"">Approximately 0.0001 APX to $100,000 %1 Dollars<br/>%2</t>", OT_Nation, _playerMoneyStr];
};

bankDisplayAll = {
	private _bankMoney = player getVariable ["OT_arr_BankVault",[0, 0]] select 0;
	private _ctrl = (findDisplay 8005) displayCtrl 1101;
	private _playerMoneyStr = "Wallet: $"; //String;
	_playerMoneyStr = _playerMoneyStr + ([player getVariable ["money", 0], 1, 0, true] call CBA_fnc_formatNumber);
	_playerMoneyStr = _playerMoneyStr + "<br/>Bank: $" + ([_bankMoney, 1, 0, true] call CBA_fnc_formatNumber);
	_ctrl ctrlSetStructuredText parseText format["<t size=""2"">Bank of %1</t><br/><t size=""1.1"">%1 Dollar (%2D)</t><br/><t size=""0.7"">We don't offer an interest rate. And their bank doesn't trade APX.<br/>%3</t>", OT_Nation, toUpper OT_Nation select [0,2], _playerMoneyStr];
};

factionDisplayAll = {
	//Factions statistics;
	//Faction display All is displaying the donation scroll down box on the right when initiating "where is my money?" dialogue to the priest;
	//It is recalled to refresh the screen to update the list upon player input;

	lbClear 1103;
	_ctrl = (findDisplay 8005) displayCtrl 1102;
	_ctrl ctrlSetStructuredText parseText format["<t size=""2"">Factions of %1</t><br/><t size=""1.1"">Donate a little money to keep them happy.</t>",OT_Nation];
	//listbox initiates here;
	private _dupeArray = []; //for using near _dupeCheck;
	{
		_x params ["_cls","_name", "_side"]; //_cls is the class name for the faction;;
		if !(server getVariable [format["factionrep%1",_cls],[]] isEqualTo []) then {
			//Disclaimer: FIA (IND) and FIA (OPFOR) are using the same name for rep, so use class name is advised;
			//THerefore its merged with pushback check -1 for non unique;
			private _dupeCheck = -1;
			_dupeCheck = _dupeArray pushbackUnique _cls; //returned index will not be -1 when pushed uniquely;
			if (_dupeCheck > -1) then {
				private _rep = server getVariable [format["standing%1",_cls],0];
				_idx = lbAdd [1103,format["%1 (%3), Reputation: %2",_name,_rep,_cls select [0,3]]];
				lbSetData [1103,_idx,_name + ":" + _cls]; //params to feed in i assuem;
			};
		};
	}foreach(OT_allFactions);
};

//Initial display to show Faction and reputation list;
call factionDisplayAll;
call cryptoDisplayAll;
call bankDisplayAll;

factionDonation = {
	//Called from main.hpp for 
	//[Amount, TypeOfMoney] for structure, select 0 is integer/float, while select 1 is string;
	//[100000, "money"] or [0.0001, "crypto"]; 

	params ["_amount", "_typeOfMoney"];
	private _idx = lbCurSel 1103;
	private _inputData = lbData [1103, _idx];
	if (_inputData isEqualTo "") exitWith {}; //nothing selected, therefore exits;
	//_playerInput = parseNumber(ctrltext 1400); //pop up dialog for players to enter values;
	private _name = _inputData splitString ":" select 0;
	private _cls = _inputData splitString ":" select 1;
	private _playerVault = player getVariable ["OT_arr_BankVault",[0, 0]];
	private _playerFiat = _playerVault select 0;
	private _playerCrypto = _playerVault select 1;
	private _amountMultiplier = 1;
	private _val = _amountMultiplier * _amount;
	private _standing = server getVariable [format["standing%1",_cls],0]; //gets the faction standing from inputData from array elements in OT_allFactions;
	private _isDone = false;
	private _chance = 5; //This is the random value between 0 to X added to faction standings; considering 95 is cap for blueprints, 5 is generous;
	if (_typeOfMoney isEqualTo "money") then {
		if ((_val) > _playerFiat) then {
			//Notify players they are poor and no money in bank to do this;
			"You don't have enough Money in the Bank" call OT_fnc_notifyMinor;
		} else {
			//Adds rep to the faction and deducts players their fiat money in bank;
			format["Transferred $%1 (%2D) from Bank of %3 to fund %4 (%5)",[_val, 1, 0, true] call CBA_fnc_formatNumber, toUpper OT_Nation select [0,2], OT_Nation, _name, _cls] call OT_fnc_notifyMinor;
			_isDone = true;
		};
	} else {
		if ((_val) > _playerCrypto) then {
			//Notify players they are poor and no money in bank to do this;
			"You don't have enough Crypto in the Exchange" call OT_fnc_notifyMinor;
		} else {
			//Adds rep to the faction and deducts players their fiat money in bank;
			format["Transferred $%1 (APX) from Crypto Exchange to fund %2 (%3)",[_val, 1, 4, true] call CBA_fnc_formatNumber, _name, _cls] call OT_fnc_notifyMinor;
			_isDone = true;
		};
	};

	if (_isDone) then {
		server setVariable [format["standing%1", _cls], _standing + round (random(_chance)), true];
		//private _rep = server getVariable [format["factionrep%1",_cls], 0]; this seems like to be position based? i forgot
		//One of the faction variables was a coordinate [x,y,z] for the spawned NPC i think, i did not use that feature here;
		call factionDisplayAll
	};
};

/*
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

*/

/*
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
*/
bankTransaction = {
	//Dorf: This was converted from characterPerks but hope to function better;
	//PARAMETERS: fed _transaction type (withdrawal/deposit/buy/sell) and _currency (float/integer) and amount in percentages (integer)
	//HANDLING Money: Sent/given from/to the player to themselves;
	//HANDLING Crypto: Sent/Given from player to server as well as other players (ON/OFFline);
	params ["_transaction", "_currency", "_amount", "_faction", "_faction_arr", "_wallet", "_total_bankvault_arr", "_total_crypto", "_total_money"];
	disableSerialization;

	//_currency dictates handling calls of bank/exchange;
	//_transaction is fed into the calls for bank/exchange;
	//_amount are variably amount, or actual percentages;
	//if _currency == "money" then if deposit/withdrawal
	//if _currency == "crypto" then if buy/sell

	//Params set variables that does not exist yet;
	_wallet = player getVariable ["money", 0]; //wallet is hand held "money";
	_total_bankvault_arr = player getVariable [format["OT_arr_BankVault"],[0, 0]]; //["money", "crypto"];
	_total_crypto = _total_bankvault_arr select 1;
	_total_money = _total_bankvault_arr select 0;
	private isDone = false; //handles refresh probably;

	if (_faction) then { //declare faction RNG here from list in game.
		_faction_arr = selectRandom OT_allFactions; //Remember this is [_clsName,_name,_side,_flag]; also _name has dupes so use _cls;
	};

	if (_currency isEqualTo "crypto") then {
		//This block handles exchange;
		[_transaction, _amount] call handleCrypto;
	};

	if (_currency isEqualTo "money") then {
		//This block handles banking money;
		if (_transaction isEqualTo "withdrawal") then {
			//withdrawal of money;
		} else {
			//Deposit of money;
		};
	};

	if (_isDone) {
		call cryptoDisplayAll;
		call bankDisplayAll;
		call factionDisplayAll;
	};
	//Bottom are references;
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
