/*Written by Dorf in 2021:
To handle take in factions selected in the donation menu by priest NPC dialog;

INPUT: feeds in params of [MONEY AMOUNT in INTEGER, CURRENCY TYPE in STRING lower case];
Example: [1, "money"] or [1, "crypto"];
OTHER INPUT: cursor selection on idc 1103 in display 8005;
OUTPUT: notify players faction rep increase;
CAVEATS: It should be RNG;
*/

//closeDialog 0;
private _idx = lbCurSel 1103;
inputData = lbData [1103, _idx]; //ARRAY of _cls, _name, _rep where CLS is a 3 digit spawner location for rep NPC;
//OT_inputHandler = {
factionDonation = {
	params ["_amount", "_typeOfMoney"];
	inputMoneyAmount = _amount; //integer
	inputTypeOfMoney = _typeOfMoney; //string lower case;
	systemChat str _typeOfMoney;
	//_playerInput = parseNumber(ctrltext 1400); //pop up dialog for players to enter values;
	//private _rep = server getVariable [format["factionrep%1",inputData select 0], 0];
	private _name = inputData select 1;
	private _playerVault = player getVariable ["OT_arr_BankVault",[0, 0]];
	private _playerFiat = _playerVault select 0;
	private _playerCrypto = _playerVault select 1;
	private _amountMultiplier = 1;
	private _val = _amountMultiplier * inputMoneyAmount;
	private _standing = server getVariable [format["standing%1",_name],0]; //gets the faction standing from inputData from array elements in OT_allFactions;
	private _isDone = false;
	private _chance = 50; //This is the random value between 0 to X added to faction standings;
	if (inputTypeOfMoney isEqualTo "money") then {
		systemChat "made it in money";
		if ((_val) > _playerFiat) then {
			//Notify players they are poor and no money in bank to do this;
			"You don't have enough Money in the Bank" call OT_fnc_notifyMinor;
		} else {
			//Adds rep to the faction and deducts players their fiat money in bank;
			format["Transferred $%1 (%2D) from Bank of %3 to fund %4",[_val, 1, 0, true] call CBA_fnc_formatNumber, toUpper OT_Nation select [0,2], OT_Nation, _name] call OT_fnc_notifyMinor;
			_isDone = true;
		};
	} else {
		if ((_val) > _playerCrypto) then {
			//Notify players they are poor and no money in bank to do this;
			"You don't have enough Crypto in the Exchange" call OT_fnc_notifyMinor;
		} else {
			//Adds rep to the faction and deducts players their fiat money in bank;
			format["Transferred $%1 (APX) from Crypto Exchange to fund %2",[_val, 1, 4, true] call CBA_fnc_formatNumber, _name] call OT_fnc_notifyMinor;
			_isDone = true;
		};
	};
	systemChat "should broadcast rep increase here";

	if (_isDone) then {server setVariable [format["standing%1", _name], _standing + round (random(_chance)), true]};
};
/* Example code block for future reference;
OT_inputHandler = {
	_val = parseNumber(ctrltext 1400);
	_cash = server getVariable ["money",0];
	if(_val > _cash) then {_val = _cash};
	if(_val > 0) then {
		[-_val] call OT_fnc_resistanceFunds;
		_player = objNull;
		private _uid = inputData;
		{
		    if(getplayeruid _x isEqualTo _uid) exitWith {_player = _x};
		}foreach(allplayers);
		if !(isNull _player) then {
			[_val] remoteExec ["OT_fnc_money",_player,false];
		}else{
			private _money = [_uid,"money"] call OT_fnc_getOfflinePlayerAttribute;
			[_uid,"money",_money+_val] call OT_fnc_setOfflinePlayerAttribute;
		};
		format["Transferred $%1 resistance funds to %2",[_val, 1, 0, true] call CBA_fnc_formatNumber,players_NS getvariable [format["name%1",_uid],"player"]] call OT_fnc_notifyMinor;
	};
};
*/

//["How much to donate to this faction?",1000] call OT_fnc_inputDialog; //optional choice combined with _playerInput;
