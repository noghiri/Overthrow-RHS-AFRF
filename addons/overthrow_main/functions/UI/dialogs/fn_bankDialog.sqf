// fnc_bankDialog calls goes here.

closedialog 0;
createDialog "OT_dialog_bank";
openMap false;

disableSerialization;

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

cryptoReturn = {
	//This returns a multiplier to the sell value of a crypto variable;
	private _dayCheck = true; //Turn this FALSE if you want to use pure RNG per sell which would be very easily exploitable;
	private _xAxis = 0; //It caps at 1;
	if (_dayCheck) then {
		_xAxis = dayTime/24; //DayTime goes from 0 to 24.00000;
	} else {
		_xAxis = random (100)/100;
	};
	private _playerTrade = player getvariable ["OT_arr_trade",[1,1]] select 1;
	//Player Trade skill maxes out at 20, so basically the more skill you have, the better results 
	private _tradeConstant = 0.5 * (_playerTrade/20);
	private _ret = false;
	//Remember cos (90) < 0.00001 because
	// cos (90) != 0;

	//This is cos (1.5*pi*x  +  pi) + 1.5; 
	//It should restrict X to 0 to 1, float;
	//It should imply Y to 0.5 to 2.5;
	_ret = cos (pi*((1.5 * _xAxis) + 1)) + 1 + _tradeConstant;
	_ret
};

globalCryptoCap = {
	//Oh boh here comes math;
	//One half is nato abandoned TOWNs, make sure they're towns.
	//One half is reputation for towns.
	private _ret = 0.0000; //toFixed 4;
	private _TotalTowns = count (OT_allTowns);
	private _AllTownRep = 0; //caps at count(OT_allTowns) varies per Nation/Island;

	private _townPos = []; //town position of towns;
	private _townName = ""; //town name of towns;
	//private _stability = server getVariable [format["stability%1",_townName], 100];
	private _support = 0; //support in towns; caps at 2525;

	private _abandonedTownArray = []; //Caps at count(OT_allTowns) I think;
	private _TotalAbandonedTowns = 0; //Additive by 1;
	private _abandoned = server getVariable ["NATOabandoned",[]];
	{
		_townPos = markerPos(_x);
		_townName = _townPos call OT_fnc_nearestTown;
		_support = [_townName] call OT_fnc_support;
		_AllTownRep = _AllTownRep + (_AllTownRep/2525);

		if (_x in _abandoned) then {
			_abandonedTownArray pushBackUnique _x; //gets names;
		};

	}foreach(OT_allTowns);

	_AllTownRep = [(_AllTownRep / _TotalTowns) ,4] call BIS_fnc_cutDecimals; //Averages total of rep; Sets a value of 1 if all towns have good rep;
	_AllTownRep = _AllTownRep/2; //halves it for adding later;
	if (_AllTownRep > 0.5000) then {_AllTownRep = 0.5000};
	_TotalAbandonedTowns = [(count(_abandonedTownArray)/_TotalTowns) ,4] call BIS_fnc_cutDecimals; //Sets a value of 1 max if all towns are abandoned;
	_TotalAbandonedTowns = _TotalAbandonedTowns/2; //Halves it for adding later;
	if (_TotalAbandonedTowns > 0.5000) then {_TotalAbandonedTowns = 0.5000};
	_ret = _TotalAbandonedTowns + _AllTownRep;
	_ret = [_ret ,4] call BIS_fnc_cutDecimals; //Making sure it's 4 digits;
	if (_ret > 1.0000) then {_ret = 1.0000};
	if (_ret < 0.0001) then {_ret = 0.0001};
	//Its maximum and minimum is between 1.0000 to 0.0001;
	_ret
};

cryptoDisplayAll = {
	private _globalCryptoCap = call globalCryptoCap; //Should be 4 digit float value from 0.0001 to 1;
	private _returnCryptoValue = call cryptoReturn;
	private _bankCrypto = player getVariable ["OT_arr_BankVault",[0, 0]] select 1;
	private _playerMoney = player getVariable ["money", 0];
	private _ctrl = (findDisplay 8005) displayCtrl 1100;
	private _playerMoneyStr = "Wallet: $"; //String;
	_playerMoneyStr = _playerMoneyStr + ([player getVariable ["money", 0], 1, 0, true] call CBA_fnc_formatNumber);
	_playerMoneyStr = _playerMoneyStr + "<br/>Your APX Storage: " + ([_bankCrypto, 1, 4, true] call CBA_fnc_formatNumber);
	//GLOBAL APX Capacity is dictated by an algorithm and need to be re-evaluated and called upon else where;
	private _cryptoCap = [call globalCryptoCap]; //Array format hopefully can expand upon in the future;
	_playerMoneyStr = _playerMoneyStr + "<br/>Global APX Market Cap: " + ([_cryptoCap select 0, 1, 4, true] call CBA_fnc_formatNumber);
	_ctrl ctrlSetStructuredText parseText format["<t size=""2"">Crypto Exchange</t><br/><t size=""1.1"">Apexium (APX)</t><br/><t size=""0.7"">Approximately 0.0001 APX to $100,000 %1 Dollars<br/>%2</t>", OT_Nation, _playerMoneyStr];

	private _idcc = 1600;
	private _idc = 0;
	for [{private _i = 0}, {_i < 4}, {_i = _i + 1}] do {
		_idc = _idcc + _i;
		if (_idc isEqualTo 1602) then {
			private _cryptoCount = 0; //presets the amount of crypto you can sell in integer;
			if (_bankCrypto > 0.0000) then {
				_cryptoCount = 1;
			};
			private _fiatQty = round(_returnCryptoValue * _cryptoCount * 100000);
			_cryptoCount = _cryptoCount * 0.0001; //this is multiplied by 1 or 0 if player has no money;
			ctrlSetText [_idc, format ["Sell (%1) APX for $(%2) %3D",_cryptoCount,[_fiatQty, 1, 4, true] call CBA_fnc_formatNumber, toUpper OT_Nation select [0,2]]];

		};
		if (_idc isEqualTo 1603) then {
			//2000000/(100000*2.5)
			private _wallet_cap = 2000000; //2 million cap to fiat wallet;
			private _cryptoCount = _bankCrypto / 0.0001; //how many do you have to sell;;
			private _cryptoMultiplier = floor ((_wallet_cap - _playerMoney)/(100000*_returnCryptoValue)); //At cost price you can sell based on wallet size;
			if (_cryptoCount > _cryptoMultiplier) then {
				_cryptoCount = _cryptoMultiplier;
			};
			private _fiatQty = round(_returnCryptoValue * _cryptoCount * 100000);
			_cryptoCount = _cryptoCount * 0.0001; //This turns into value;
			ctrlSetText [_idc, format ["Sell All (%1) APX for $(%2) %3D",_cryptoCount,[_fiatQty, 1, 4, true] call CBA_fnc_formatNumber, toUpper OT_Nation select [0,2]]];
		};
		ctrlEnable [_idc, true];
		ctrlShow [_idc, true];
	};
};

bankDisplayAll = {
	private _bankMoney = player getVariable ["OT_arr_BankVault",[0, 0]] select 0;
	private _ctrl = (findDisplay 8005) displayCtrl 1101;
	private _playerMoneyStr = "Wallet: $"; //String;
	_playerMoneyStr = _playerMoneyStr + ([player getVariable ["money", 0], 1, 0, true] call CBA_fnc_formatNumber);
	_playerMoneyStr = _playerMoneyStr + "<br/>Bank: $" + ([_bankMoney, 1, 0, true] call CBA_fnc_formatNumber);
	_ctrl ctrlSetStructuredText parseText format["<t size=""2"">Bank of %1</t><br/><t size=""1.1"">%1 Dollar (%2D)</t><br/><t size=""0.7"">We don't offer an interest rate. And their bank doesn't trade APX.<br/>%3</t>", OT_Nation, toUpper OT_Nation select [0,2], _playerMoneyStr];

	private _idcc = 1604;
	private _idc = 0;
	for [{private _i = 0}, {_i < 4}, {_i = _i + 1}] do {
		_idc = _idcc + _i;
		ctrlEnable [_idc, true];
		ctrlShow [_idc, true];
	};
};

factionDisplayAll = {
	//Factions statistics;
	//Faction display All is displaying the donation scroll down box on the right when initiating "where is my money?" dialogue to the priest;
	//It is recalled to refresh the screen to update the list upon player input;

	lbClear 1103;
	private _ctrl = (findDisplay 8005) displayCtrl 1102;
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

handleWallet = { 
	//Handles all Fiat Dollars transactions through this;

	params ["_amount", "_terminology"]; 	//_amount is the change in money, negative/positive integers;
	//Basically checks if player can be given money to wallet;
	private _BDplusmin = ["","-", "+"]; //#0 is wallet amount indicator, #1 is bank amount indicator for notification string;
	private _playerBank_arr = player getVariable ["OT_arr_BankVault",[0, 0]];
	private _playerWallet = player getVariable ["money",0];
	private _money_cap = 2000000; // 2 million cap CONSTANT;
	private _playerBank_money = _playerBank_arr select 0;
	private _playerBank_crypto = _playerBank_arr select 1;

	private _doNotify = false;

	//Legacy "money" check to see if wallet is greater than 2 million TAD;
	if (_playerWallet > _money_cap) then {
		//Skim player wallet til 2 million 
		//Should not take in consideration of the _amount parameter of handleWallet;
		//Then notify players of money moving into the bank
		player setVariable ["money",_money_cap, true];
		private _changed_amount = _playerWallet - _money_cap;
		_playerBank_money = _playerBank_money + _changed_amount;

		player setVariable ["OT_arr_BankVault", [_playerBank_money, _playerBank_arr select 1], true];
		format["Wallet %1$(%2), Bank +$(%2)",_BDplusmin#1,[_changed_amount, 1, 0, true] call CBA_fnc_formatNumber] call OT_fnc_notifyMinor;
	};
	private _wallet_amount = 0; // for reporting notification in end;
	private _bank_amount = 0;// for reporting notif in end;
	private _crypto_amount = 0.0000;

	if (_terminology isEqualTo "withdrawal") then {

		//Withdrawals money from bank;
		if ((_playerWallet + _amount) > _money_cap) then {
				//if withdrawn money is exceeding the cap;
				//Then make amount less;
				_amount = _money_cap - _playerWallet;
				if (_amount isEqualTo 0) then {
					_BDplusmin = ["","",""];
				};
		};
		if (_amount > 0) then {
			//_amount is the input change for player wallet => bank;
			_BDplusmin = ["Withdrawn", "+","-"];
			_wallet_amount = _amount;
			[_amount] call OT_fnc_money;
			_bank_amount = _amount;
			_playerBank_money = _playerBank_money - _bank_amount;
			player setVariable ["OT_arr_BankVault", [_playerBank_money, _playerBank_crypto], true];	
			_doNotify = true;
		};

	};

	if (_terminology isEqualTo "deposit") then {
		if ((_playerWallet < _amount)) then {
			_amount = _playerWallet;
		};

		if (_amount > 0) then {
			//Deposits money into bank;
			_BDplusmin = ["Deposited","-", "+"];
			_wallet_amount = _amount;
			_playerBank_money = _playerBank_money + _amount;
			_bank_amount = _amount;
			[-_wallet_amount] call OT_fnc_money;
			player setVariable ["OT_arr_BankVault", [_playerBank_money, _playerBank_crypto], true];
			_doNotify = true;
		};

	};

	if (_terminology isEqualTo "sell" || _terminology isEqualTo "buy") then {
		private _globalCryptoCap = call globalCryptoCap; //Should be 4 digit float value from 0.0001 to 1;
		private _fiatRatio = 10000; //This is a constant to convert 0.0001 to 1;
		private _cryptoReturn = call cryptoReturn;
		_playerWallet = player getVariable ["money",0];
		if (_terminology isEqualTo "sell") then {
			//Sells crypto;
			SystemChat str _amount;
			SystemChat str _playerBank_crypto;
			if (_amount > _playerBank_crypto) then {
				_amount = _playerBank_crypto;
			};

			if (([_amount ,4] call BIS_fnc_cutDecimals) >= 0.0001) then {
				//Sell Crypto because _amount is greater than minimum;
				//Need to check player wallet is able to be filled up;
				private _wallet_cap = 2000000; //2 million cap to fiat wallet;
				private _cryptoCount = _amount / 0.0001; //how many you can sell;
				private _cryptoMultiplier = floor ((_wallet_cap - _playerWallet)/(100000*_cryptoReturn)); //how many you can sell At cost price based on wallet size;
				if (_cryptoCount > _cryptoMultiplier) then {
					_cryptoCount = _cryptoMultiplier; //if player had 0 wallet cash, it would use this value to dictate sells;
				};
				private _fiatQty = round(_cryptoReturn * _cryptoCount * 100000); //this is the money you get back to your account;
				_cryptoCount = _cryptoCount * 0.0001; //This turns into value of 0.0001 APXs to sell;;

				if ((_fiatQty + _playerWallet) <= _money_cap) then {
					_wallet_amount = _fiatQty + _playerWallet;
					_crypto_amount = _cryptoCount;
					_playerBank_crypto = _playerBank_crypto - _crypto_amount;
					if (_playerBank_crypto < 0.0000) then {_playerBank_crypto = 0.0000};
					player setVariable ["OT_arr_BankVault", [_playerBank_money, _playerBank_crypto], true];
					[_wallet_amount] call OT_fnc_money;
					_doNotify = true;
				};
			};
		};

	};
	
	//For withdrawals and deposits;&& (_terminology isEqualTo "deposit" || _terminology isEqualTo "withdrawal")
	//if (_doNotify && count (_BDplusmin) == 3 && (typename _BDplusmin) isEqualTo "ARRAY") then {
	if (_doNotify) then {
		private _BDreply = "";
	 	if (_terminology isEqualTo "deposit" || _terminology isEqualTo "withdrawal") then {
			_BDreply = format["%1 %2$(%4) Wallet, %3$(%5) Bank ",
			_BDplusmin#0,
			_BDplusmin#1,
			_BDplusmin#2,
			[_wallet_amount, 1, 0, true] call CBA_fnc_formatNumber, 
			[_bank_amount, 1, 0, true] call CBA_fnc_formatNumber
			];
			_BDreply call OT_fnc_notifyMinor;
		} else {
			//Buy/sell cryptos final notifications goes here;
		};
		call cryptoDisplayAll;
		call bankDisplayAll;

	};
};

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
			"You do not have enough Money in the Bank" call OT_fnc_notifyMinor;
		} else {
			[-_val] call OT_fnc_money;
			//Adds rep to the faction and deducts players their fiat money in bank;
			format["Transferred $%1 (%2D) from Bank of %3 to fund %4 (%5)",[_val, 1, 0, true] call CBA_fnc_formatNumber, toUpper OT_Nation select [0,2], OT_Nation, _name, _cls] call OT_fnc_notifyMinor;
			_isDone = true;
		};
	} else {
		if ((_val) > _playerCrypto) then {
			//Notify players they are poor and no money in bank to do this;
			"You do not have enough Crypto in the Exchange" call OT_fnc_notifyMinor;
		} else {
			_playerCrypto = _playerCrypto - _val;
			player setVariable ["OT_arr_BankVault", [_playerFiat,_playerCrypto], true];
			//Adds rep to the faction and deducts players their fiat money in bank;
			format["Transferred $%1 (APX) from Crypto Exchange to fund %2 (%3)",[_val, 1, 4, true] call CBA_fnc_formatNumber, _name, _cls] call OT_fnc_notifyMinor;
			_isDone = true;
		};
	};

	if (_isDone) then {
		server setVariable [format["standing%1", _cls], _standing + round (random(_chance)), true];
		//private _rep = server getVariable [format["factionrep%1",_cls], 0]; this seems like to be position based? i forgot
		//One of the faction variables was a coordinate [x,y,z] for the spawned NPC i think, i did not use that feature here;
		call factionDisplayAll;
	};
};

handleBank = {
	params ["_terminology", "_amount"];
	private _isDone = false; //false carries this successfully into handling money;
	private _replyString = "";

	private _playerBank_arr = player getVariable ["OT_arr_BankVault",[0, 0]];
	private _playerWallet = player getVariable ["money",0];
	private _money_cap = 2000000; // 2 million cap CONSTANT;
	private _playerBank_money = _playerBank_arr select 0;

	if (_terminology isEqualTo "withdrawal") then {
		//withdrawal up to the _amount of the player's wallet.
		if (_playerBank_money > 0) then {
			if (_playerBank_money < _amount) then {
				//if player bank money is less than amount then we make all account money into amount withdrawal;
				_amount = _playerBank_money;
			}; // else ammount is just normal amount;
		} else {
			//if player bank money is zero or less;
			_isDone = true;
			_replyString = "Your bank is empty";
		};

	};
	if (_terminology isEqualTo "deposit") then { 
		//deposit an _amount of the player's cash money into the bank.
		//Amount needs to be negative in the end to be fed into handleWallet;
		if (_playerWallet > 0) then {
			if (_playerWallet < _amount) then {
				_amount = _playerWallet;
			};
			//needs to be negative to be fed as deposit into 
			//_amount = -1 * _amount;
		} else {
			_isDone = true;
			_replyString = "Your wallet is empty";
		};
	};

	//Formatted reply controlled by _isDone;
	if (_isDone) then {
		//reply normally
		_replyString call OT_fnc_notifyMinor;
	} else {
		[_amount, _terminology] call handleWallet;
		call cryptoDisplayAll;
		call bankDisplayAll;
	};
};

bankTransaction = {
	//Dorf: This was converted from characterPerks but hope to function better;
	//PARAMETERS: fed _transaction type (withdrawal/deposit/buy/sell) and _currency (float/integer) and amount in percentages (integer)
	//HANDLING Money: Sent/given from/to the player to themselves;
	//HANDLING Crypto: Sent/Given from player to server as well as other players (ON/OFFline);
	params ["_transaction", "_currency", "_amount", "_faction", "_faction_arr", "_wallet", "_total_bankvault_arr", "_total_crypto", "_total_money"];
	disableSerialization;

	//call factionDisplayAll;
	//call cryptoDisplayAll;
	//call bankDisplayAll;

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
	private _isDone = false; //handles refresh probably;
	_faction = true;
	_faction_arr = [];
	if (_faction) then { //declare faction RNG here from list in game.

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
					//_idx = lbAdd [1103,format["%1 (%3), Reputation: %2",_name,_rep,_cls select [0,3]]];
					//lbSetData [1103,_idx,_name + ":" + _cls]; //params to feed in i assuem;
					_faction_arr pushBackUnique [_cls, _name, _rep]; 
				};
			};
		}foreach(OT_allFactions);

		_faction_arr = selectRandom _faction_arr; //Remember this is [_clsName,_name,_side,_flag]; also _name has dupes so use _cls;
		//Check for rep before adding it cause it matters for raising rep usage;
	};

	if (_currency isEqualTo "crypto") then {
		//This block handles exchange;
		//[_transaction, _amount] call handleCrypto;
		if (_transaction isEqualTo "buy") then {
			//buy of Crypto using money;
			[_amount, _transaction] call handleWallet;
		} else {
			//Sell Crypto;
			[_amount, _transaction] call handleWallet;
		}
	};

	if (_currency isEqualTo "money") then {
		//This block handles banking money;
		if (_transaction isEqualTo "withdrawal") then {
			//withdrawal of money;
			[_transaction, _amount] call handleBank;
		} else {
			//Deposit of money;
			[_transaction, _amount] call handleBank;
		};
		_isDone = true;
	};

	if (_isDone) then {
		call cryptoDisplayAll;
		call bankDisplayAll;
		call factionDisplayAll; //Does not need to be called again because, no faction manipulation can be done; unless....
	};
};
