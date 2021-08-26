buttonSetAction [1604, '[] spawn OT_fnc_warehouseDialog'];
private _cursel = lbCurSel 1500;
lbClear 1500;
private _itemVars = (allVariables warehouse) select {((toLower _x select [0,5]) isEqualTo "item_")};
_itemVars sort true;
private _numitems = 0;

//Search variables begins here;
private _SearchTerm = tolower (ctrlText 1700); // "" when nothing is selected;
private _name = "";
private _idx = "";
private _pic = "";
private _price = "";
//Variables for search within for loop is here;
private _found_ST = -1;
private _found_name_ST = -1;
private _search_bool = false; //New boolean to define search parameters 
//_price_bool for this case has nothing to do with price, it has to do with checking if the item exists.
private _price_bool = false; //Previously added list items were moved so this checks for conditions to enable them.
if !(_SearchTerm isEqualTo "") then {
	_search_bool = true; //search term boolean is not empty;
};
backpackItems player select 2 call OT_fnc_weaponGetPic isEqualTo "";
{
	private _d = warehouse getVariable [_x,false];
	if(_d isEqualType []) then {
		_d params [["_cls","",[""]], ["_num",0,[0]]];
		_price_bool = false; //resets price bool;
		if (_search_bool) then {
			_name = "";
		};

		if ((_cls isEqualType "") && _num > 0) then {
			_numitems = _numitems + 1;
			([_cls] call {
				params ["_cls"];
				if(_cls isKindOf ["Default",configFile >> "CfgWeapons"]) exitWith {
					_name = _cls call OT_fnc_weaponGetName;
					_pic = _cls call OT_fnc_weaponGetPic;
					if (!(_pic isEqualTo "") && !(_name isEqualTo "")) then { 
						//Get rid of bad eggs if there is no picture or name found for the item.
						_price_bool = true; //This offsets duplicates to price seeking searched name;
						[_name,_pic]
					};
				};
				if(_cls isKindOf ["Default",configFile >> "CfgMagazines"]) exitWith {
					_name = _cls call OT_fnc_magazineGetName;
					_pic = _cls call OT_fnc_magazineGetPic;
					if (!(_pic isEqualTo "") && !(_name isEqualTo "")) then { 
						_price_bool = true;
						[_name,_pic]
					};
				};
				if(_cls isKindOf "Bag_Base") exitWith {
					_name = _cls call OT_fnc_vehicleGetName;
					_pic = _cls call OT_fnc_vehicleGetPic;
					if (!(_pic isEqualTo "") && !(_name isEqualTo "")) then { 
						_price_bool = true;
						[_name,_pic]
					};
				};
				if(isClass (configFile >> "CfgGlasses" >> _cls)) exitWith {
					_name = gettext(configFile >> "CfgGlasses" >> _cls >> "displayName");
					_pic = gettext(configFile >> "CfgGlasses" >> _cls >> "picture");
					if (!(_pic isEqualTo "") && !(_name isEqualTo "")) then { 
						_price_bool = true;
						[_name,_pic]
					};
				};
				_name = _cls call OT_fnc_vehicleGetName;
				_pic = _cls call OT_fnc_vehicleGetPic;
				if (!(_pic isEqualTo "") && !(_name isEqualTo "")) then { 
					_price_bool = true;
					[_name,_pic]
				};
			}) //params ["_name","_pic"];
		};

		//Normal class name is easy to check for;
		//if _name is "" then it is -1 still...
		if (_search_bool) then {
			_found_name_ST = tolower(_name) find _SearchTerm;
		};
		//If searching for a name is found and searchTerm is not empty (_search_bool == true)
		//OR If there is no term for search (_search_bool == false);
		//Before needs to be true AND price needs to exist;
		if ((((_found_name_ST > -1) && _search_bool) || !_search_bool) && _price_bool) then {
			_idx = lbAdd [1500,format["%1 x %2",_num,_name]];
			lbSetPicture [1500,_idx,_pic];
			lbSetValue [1500,_idx,_num];
			lbSetData [1500,_idx,_cls];
		};
	};
}foreach(_itemVars);

if(_cursel >= _numitems) then {_cursel = 0};
lbSetCurSel [1500, _cursel];