buttonSetAction [1603, '[] spawn OT_fnc_importDialog']; //For search too
if(count (player nearObjects [OT_portBuilding,30]) isEqualTo 0) exitWith {};
private _town = player call OT_fnc_nearestTown;
_items = OT_Resources + OT_allItems + OT_allBackpacks + ["V_RebreatherIA"];
if(_town in (server getVariable ["NATOabandoned",[]]) || OT_adminMode) then {
	_items = OT_Resources + OT_allItems + OT_allBackpacks + ["V_RebreatherIA"] + OT_allWeapons + OT_allMagazines + OT_allAttachments + OT_allStaticBackpacks + OT_allOptics + OT_allVests + OT_allHelmets + OT_allClothing;
}else{
	hint format ["Only legal items may be imported while NATO controls %1",_town];
};
private _cursel = lbCurSel 1500;
lbClear 1500;
private _done = [];
//Search variables begins here;
private _SearchTerm = tolower (ctrlText 1700); // "" when nothing is selected;
private _numitems = 0;
private _name = "";
private _idx = "";
private _pic = "";
private _price = "";
//Variables for search within for loop is here;
private _found_ST = -1;
private _found_name_ST = -1;
private _search_bool = false; //New boolean to define search parameters 
private _price_bool = false; //Previously added list items were moved so this checks for conditions to enable them.

if !(_SearchTerm isEqualTo "") then {
	_search_bool = true; //search term boolean is not empty;
};

{
	_cls = _x;
	_price_bool = false; //resets price bool;
	if (_search_bool) then {
		_name = "";
	};
	//_found_ST = tolower(_cls) find _SearchTerm;
	//We either find the name or the class name of the item.
	if(_cls isKindOf ["Default",configFile >> "CfgWeapons"]) then {
		_cls = [_x] call BIS_fnc_baseWeapon;
	};
	if !((_cls in _done) || (_cls in OT_allExplosives)) then {
		_done pushbackUnique _cls;
		_price = [OT_nation,_cls,100] call OT_fnc_getPrice;
		//_name = "";
		_pic = "";

		if(_price > 0) then {
			_numitems = _numitems + 1;
			if(_cls isKindOf ["None",configFile >> "CfgGlasses"]) then {
				_name = _cls call OT_fnc_glassesGetName;
				_pic = _cls call OT_fnc_glassesGetPic;
			};
			if(_cls isKindOf ["Default",configFile >> "CfgWeapons"]) then {
				_name = _cls call OT_fnc_weaponGetName;
				_pic = _cls call OT_fnc_weaponGetPic;
			};
			if(_cls isKindOf ["Default",configFile >> "CfgMagazines"]) then {
				_name = _cls call OT_fnc_magazineGetName;
				_pic = _cls call OT_fnc_magazineGetPic;
			};
			if(_cls isKindOf "Bag_Base") then {
				_name = _cls call OT_fnc_vehicleGetName;
				_pic = _cls call OT_fnc_vehicleGetPic;
			};
			if (!(_pic isEqualTo "") && !(_name isEqualTo "")) then { 
				//Get rid of bad eggs if there is no picture or name found for the item.
				_price_bool = true; //This offsets duplicates
			};
		};
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
		_idx = lbAdd [1500,format["%1",_name]];
		lbSetPicture [1500,_idx,_pic];
		lbSetValue [1500,_idx,_price];
		lbSetData [1500,_idx,_cls];
	};
}foreach(_items);

if(_cursel >= _numitems) then {_cursel = 0};
lbSetCurSel [1500, _cursel];