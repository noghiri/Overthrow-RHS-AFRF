private _town = (getpos player) call OT_fnc_nearestTown;

private _stock = server getVariable format["gunstock%1",_town];
if(isNil "_stock") then {
	private _numguns = round(random 7)+3;
	private _count = 0;
	_stock = [[OT_item_BasicGun,0],[OT_item_BasicAmmo,0]];
	_stock pushback [OT_ammo_50cal,0];

	private _p = (cost getVariable "I_HMG_01_high_weapon_F") select 0;
	_p = _p + ((cost getVariable "I_HMG_01_support_high_F") select 0);
	private _quad = ((cost getVariable "C_Quadbike_01_F") select 0) + 60;
	_p = _p + _quad;
	_p = _p + 50; //Convenience cost

	_stock pushback ["Set_HMG",_p];
	_stock pushback ["C_Quadbike_01_F",_quad];

	{
		// name price
		_stock pushBack [_x,0];
	}foreach(OT_allStaticBackpacks);

	private _tostock = [];
	while {_count < _numguns} do {
		private _type = selectRandom OT_allWeapons;
		if !(_type in _tostock) then {

			_tostock pushBack [_type,0];
			_count = _count + 1;

			_stock pushBack [_type,0];

			private _base = [_type] call BIS_fnc_baseWeapon;
			private _magazines = getArray (configFile >> "CfgWeapons" >> _base >> "magazines");

			_stock pushBack [selectRandom _magazines,0];
		};
	};

	{
		// name, price
		_stock pushBack [_x, 0];
	}foreach(OT_allOptics);

	{
		_stock pushBack [_x,_price];
	}foreach(OT_allDrugs);

	server setVariable [format["gunstock%1",_town],_stock,true];
};

createDialog "OT_dialog_buy";
{
	_x params ["_cls","_price"];
	if !(isNil "_cls") then {
		private _txt = _cls;
		private _pic = "";

		[_cls] call {
			params ["_cls"];
			if(_cls == "Set_HMG") exitWith {
				_txt = "Quadbike w/ HMG Backpacks";
				_pic = "C_Quadbike_01_F" call OT_fnc_magazineGetPic;
			};
			if(_cls isKindOf ["Default",configFile >> "CfgMagazines"]) exitWith {
				_txt = format["--- %1",_cls call OT_fnc_magazineGetName];
				_pic = _cls call OT_fnc_magazineGetPic;
			};
			if(_cls in OT_allStaticBackpacks) exitWith {
				_txt = format["--- %1",_cls call OT_fnc_vehicleGetName];
				_pic = _cls call OT_fnc_vehicleGetPic;
			};
			if(_cls isKindOf "Land") exitWith {
				_txt = format["%1",_cls call OT_fnc_vehicleGetName];
				_pic = _cls call OT_fnc_vehicleGetPic;
			};
			_txt = _cls call OT_fnc_weaponGetName;
			_pic = _cls call OT_fnc_weaponGetPic;
		};
		if(_cls in OT_allDrugs) then {
			//Original script line;
			//_price = [_town,_cls] call OT_fnc_getDrugPrice;

			//debug goes here.
			private _trade = objNull;
			if (player getvariable ["OT_trade",[1,1]] isEqualType []) then {
				_trade = player getVariable ["OT_trade",[1, 1]];
			} else {
				_trade = [player getVariable ["OT_trade", 1], 1];
			};
			//debug ends here;
			_trade = _trade select 1; //buff is a player's trade skill
			private _stability = (server getVariable format["stability%1", _town])/100;
			private _population = server getVariable format["population%1",_town];

			//Dorf modified into;
			if(_stability < 0.25) then {_stability = 0.25}; //Max 25% stability discount
			if(_population > 1000) then {_population = 1000};
			private _baseprice = cost getVariable _cls select 0;
			//This makes bigger populations contribute to 1, small population 2;
			private _inverse_population = abs((_population - 1000)/1000) + 1;

			//This pricing should reflect drug pricing from increase of population is higher pricing
			//In addition too greater stability, the more expensive the drugs
			_price = _baseprice * (_stability * _inverse_population); //Reduces pricing by stability 
			//_price = round (_price * ((30 + _buff - 1)/100)); //Added buff constant to reduce price by half of purchase - Dorf cant math rn it 5 am;
			_price = _price - _trade + 1; //20 bucks discount;
			if (_price < 40) then {_price = 40 - _trade + 1}; //Bottom dollar price, cannot be lower than 40;
		}else{
			_price = [OT_nation,_cls] call OT_fnc_getPrice; //Normal buy/sell pricing
		};
		private _idx = lbAdd [1500,format["%1",_txt]];
		lbSetData [1500,_idx,_cls];
		lbSetValue [1500,_idx,_price];
		lbSetPicture [1500,_idx,_pic];
	};
}foreach(_stock);
