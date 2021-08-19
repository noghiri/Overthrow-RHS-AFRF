private _b = player call OT_fnc_nearestRealEstate;
private _handled = false;
private _type = "buy";
private _isfactory = false;
//Below declares for ONLINE/OFFLINE player info regarding housing 
//Verified for targeted individual home owners
private _bubble_popped = false; 
//Landlords will not be able to hold onto property when they pass X houses
private _bubble_cap = 21;
//GUID of _owner_uid variable works ON/OFFLine
private _owner_uid = ""; //_building call OT_fnc_getOwner;
//Declares of boolean of owner is the same GUID as player 
private _owner_is_player = ""; //_owner_uid isEqualTo getplayeruid player;
//Below is for checking online players
private _owner_isonline = false;
private _owner_on = "Offline";
private _online_owner = objNull; //This is actually player name not UID
//NOTE YOU CAN CHANGE "OWNED" WITH "LEASED" for array checks.
//Cannot lease, cannot sell, cannot see owner of building
if(typename _b isEqualTo "ARRAY") then {
	private _building = (_b select 0);
	private _building_hasOwner = _building call OT_fnc_hasOwner;
	//Owner uid and stuff needs to rely on array aspect above

	//Buy type by default cause it has no owners
	if !(_building_hasOwner) then {
		_handled = true;
	//SELL order due to having owners
	}else{ 
		//Owner is checked to exist before setting uid and player boolean
		//This ends up going to the if blocks to sell but does not imply sold yet;
		//@TODO reliably make this work 
		_owner_uid = _building call OT_fnc_getOwner;
		_owner_is_player = _owner_uid isEqualTo (getplayeruid player);

		//If owner is not player
		//Check online, then calculate bubble_pop value for house owner
		//If bubble is popped and it's over cap, it will allow the ability to sell their house 
		//Either offline or remote execution methods without their permission via refund eviction 
		if(!_owner_is_player) then {
			//Loop to check if owner is online first 
			{
				if(getplayeruid _x isEqualTo _owner_uid) exitWith {_owner_isonline = true;_owner_on = "Online";_online_owner = _x};
			}foreach(allplayers);
			//House Owner is ONLINE then use remote calculations
			if (_owner_isonline) then {
				//Makes a private home check to see if they spawn using this house 
				private _home = _online_owner getVariable "home";
				//Exits when player is trying to sell someones home 
				if(_home distance _building < 5) exitWith {"You cannot sell their home spawn" call OT_fnc_notifyMinor;_err = true};

				//Count of leased array over bubble cap implies ownership change permit
				if (count (_online_owner getVariable "owned") > _bubble_cap) then {
					_type = "sell";
					_bubble_popped = true;
					_handled = true;
				} else {
					"Not for sale, this Building owner is within Deedlock protection." call OT_fnc_notifyMinor
				};
				//Player cannot buy a house that has not reached housing bubble

			//House Owner OFFLINE so use offline methods to check if they reached the bubble_cap
			}else{
				private _home = [_owner_uid, "home"] call OT_fnc_getOfflinePlayerAttribute;
				if(_home distance _building < 5) exitWith {"You cannot sell their home spawn" call OT_fnc_notifyMinor;_err = true};

				//Count of leased array over bubble cap implies ownership change permit
				if (count ([_owner_uid, "owned"] call OT_fnc_getOfflinePlayerAttribute) > _bubble_cap) then {
					_type = "sell";
					_bubble_popped = true;
					_handled = true;
				} else {
					"Not for sale, this Building owner is within Deedlock protection." call OT_fnc_notifyMinor
				};
			};

		//Else, Home Owner Equals to player. Sell your house normally
		} else {

			private _home = player getVariable "home";
			//Exits when player is trying to sell their own home 
			if(_home distance _building < 5) exitWith {"You cannot sell your home" call OT_fnc_notifyMinor;_err = true};
			//If not exited, changes to sell
			_type = "sell";
			_handled = true;
		};
	};
};
if(_handled) then {
	//b was the player call of nearest Realestate 
	_b params ["_building","_price","_sell","_lease","_totaloccupants"];

	if(typeof _building isEqualTo OT_flag_IND) exitWith {
		[] call OT_fnc_garrisonDialog;
	};

	private _town = (getpos _building) call OT_fnc_nearestTown;

	//gets player money, returns 0 if not found
	private _money = player getVariable ["money",0];

	if(_type == "buy" && _money < _price) exitWith {"You cannot afford that" call OT_fnc_notifyMinor};


	private _mrkid = format["bdg-%1",_building];
	private _owned = player getVariable "owned"; //Remember this is different from "leased"
	private _total_bdgs_count = count (player getVariable "owned");
	private _total_lsd_count = count (player getVariable "leased");

	if(_type isEqualTo "buy") then {

		//Remember _id is building ID bunch of numbers like "15425"
		private _id = [_building] call OT_fnc_getBuildID;
		//set owner of building to player UID
		[_building,getPlayerUID player] call OT_fnc_setOwner;
		//Subtracts money from player;
		[-_price] call OT_fnc_money;

		buildingpositions setVariable [_id,position _building,true];
		_owned pushback _id;
		[player,"Building Purchased",format["Bought: %1 in %2 for $%3. You have %4 Owned and %5 Leased", getText(configFile >> "CfgVehicles" >> (typeof _building) >> "displayName"),(getpos _building) call OT_fnc_nearestTown,_price, _total_bdgs_count, _total_lsd_count]] call BIS_fnc_createLogRecord;
		format["You have %2 Buildings, %1 Leased, Deedlock %2/%3.", _total_lsd_count, _total_bdgs_count, _bubble_cap] call OT_fnc_notifyMinor;
		_building addEventHandler ["Dammaged",OT_fnc_buildingDamagedHandler];
	}else{
		//This entire block is for selling houses 
		//2021- Dorf: I edited this with intent to balance hoarding landlords

		_owner_uid = _building call OT_fnc_getOwner;
		_owner_is_player = _owner_uid isEqualTo (getplayeruid player);

		// Fetch the list of buildable houses
		private _buildableHouses = (OT_Buildables param [9, []]) param [2, []];
		//If the houses are in the list of buildings in town, or are in a list of buildable ones then 
		//They will be sold or deleted depending on _building OT_fnc_getBuildID _id
		if((typeof _building) in OT_allRealEstate or {((typeOf _building) in _buildableHouses)}) then {
			private _id = [_building] call OT_fnc_getBuildID;
			private _leased = ""; //uses in both if routes below
			//Sets the owner as nobody
			[_building,nil] call OT_fnc_setOwner;

			//Owner is not the player and bubble is popped
			//@TODO Make it prettier
			if (_bubble_popped && !_owner_is_player) then {
				//bubble popped and owner is not the player
				if (_owner_isonline) then {
					//Owner is online so we refund like this 

					private _total_sold = (_online_owner getVariable ["money", 0])+_sell;
					_online_owner setVariable ["money",_total_sold, true];
					
					//Should unlease, then delete data of lease for owner and set new variable _leased
					//a way to obtain _leased data array from ONLINE owner
					_leased = _online_owner getVariable ["leased",[]];
					_leased deleteAt (_leased find _id);
					_online_owner setVariable ["leased", _leased, true];
				}else{
					//Owner is Offline so we refund like that
					private _total_sold = ([_owner_uid, "money"] call OT_fnc_getOfflinePlayerAttribute)+_sell;
					//We must refund them their money forcefully like selling
					[_owner_uid, "money", _total_sold] call OT_fnc_setOfflinePlayerAttribute;

					//Should unlease, then delete data of lease for owner and set new variable _leased
					//a way to obtain _leased data array from OFFLINE owner
					_leased = [_owner_uid, "leased"] call OT_fnc_getOfflinePlayerAttribute;
					_leased deleteAt (_leased find _id);
					[_owner_uid, "leased", _leased] call OT_fnc_setOfflinePlayerAttribute;

				};
				//Sad Refund noises, poor capitalist pig
				playSound "3DEN_notificationDefault";
				//Sets owner as nobody
				deleteMarker _mrkid;

				//Declares owner array of someone from this house
				private _some_owned = "";
				//This must delete OWNER buliding from their array, not the player thats near it
				if (_owner_isonline) then {
					_some_owned = _online_owner getVariable "owned";
					_some_owned deleteAt (_some_owned find _id);
					_online_owner setVariable ["owned",_some_owned,true];
				} else {
					_some_owned = [_owner_uid, "owned"] call OT_fnc_getOfflinePlayerAttribute;
					_some_owned deleteAt (_some_owned find _id);
					[_owner_uid, "owned", _some_owned] call OT_fnc_setOfflinePlayerAttribute;
				};
				[player,"Building Owner Refunded",format["Refund sent: %1 in %2 for $%3 to %4",getText(configFile >> "CfgVehicles" >> (typeof _building) >> "displayName"),(getpos _building) call OT_fnc_nearestTown,_sell, players_NS getVariable format["name%1", _owner_uid]]] call BIS_fnc_createLogRecord;
				format["Refund sent to %1, $%2. For selling a land deed of %3 on %4.", players_NS getVariable format["name%1", _owner_uid],_sell, getText(configFile >> "CfgVehicles" >> (typeof _building) >> "displayName"), (getpos _building) call OT_fnc_nearestTown] call OT_fnc_notifyMinor;

			} else {
				//OWNER IS PLAYER
				if (_owner_is_player) then {
					//get _leased array from online player variable
					_leased = player getVariable ["leased",[]];
					// Deletes the leased array at index of _id
					_leased deleteAt (_leased find _id); 
					//Declares new _leased value as public variable named "leased" to the player
					player setVariable ["leased",_leased,true];

					//Declares new lease data by finding from online player same as above 
					private _leasedata = player getVariable ["leasedata",[]];
					private _leasedataID = (_leasedata apply {_x select 0}) findIf {_x == _id};
					_leasedata deleteAt _leasedataID;
					player setVariable ["leasedata",_leasedata,true];

					//Deletes marker on map and calls money on value of _sell
					deleteMarker _mrkid;
					_owned deleteAt (_owned find _id);
					[player,"Building Sold",format["Sold: %1 in %2 for $%3",getText(configFile >> "CfgVehicles" >> (typeof _building) >> "displayName"),(getpos _building) call OT_fnc_nearestTown,_sell]] call BIS_fnc_createLogRecord;
					format["You have %2 Buildings, %1 Leased, Deedlock %2/%3.", _total_lsd_count, _total_bdgs_count, _bubble_cap] call OT_fnc_notifyMinor;
					[_sell] call OT_fnc_money;
				} else {
					//Owner is not player, this implies bubble is not popped
					if (!_owner_is_player) then {"Not for sale, this Building owner is within Deedlock protection." call OT_fnc_notifyMinor};
				};
			};


		// Fallback for unknown buildings
		}else{
			_owned deleteAt (_owned find ([_building] call OT_fnc_getBuildID));
		};

		// Always attempt to remove the building, because it might be played-placed (for map-placed buildings, this won't do anything)
		deleteVehicle _building;
	};

	//Hello future Arma scripters and "_some_owned"
	//Im so sorry this ugly line below is redundant due to coding above by me, doRf
	//Optimize this soon ~~ 2021
	player setVariable ["owned",_owned,true];


}else{
	if !(_isfactory) then {
		"There are no buildings for sale nearby" call OT_fnc_notifyMinor;
	};
};
