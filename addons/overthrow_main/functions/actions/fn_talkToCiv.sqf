private _civ = _this;

OT_interactingWith = _civ;

private _town = (getpos player) call OT_fnc_nearestTown;
private _standing = [_town] call OT_fnc_support;
private _civprice = [_town,"CIV",_standing] call OT_fnc_getPrice;
private _influence = player getvariable "influence";
private _money = player getVariable ["money",0];

private _options = [];

if (side _civ isEqualTo west) exitWith {
	_options pushBack ["Cancel",{}];
	_options call OT_fnc_playerDecision;
};

//make sure any purchases come to me, not my vehicle
player setVariable ["OT_shopTarget","Self",false];

private _canRecruit = true;

private _canBank = false; //for the priest;
private _canBuy = false;
private _canBuyVehicles = false;
private _canBuyBoats = false;
private _canBuyGuns = false;
private _canSell = false;
private _canSellDrugs = true;
private _canIntel = true;
private _canMission = false;
private _canTute = false;
private _canGangJob = false;
private _isShop = false;

if !((_civ getvariable ["shop",[]]) isEqualTo []) then {_canSellDrugs = true;_canRecruit = false;_canBuy=true;_canSell=true;_isShop = true};
if (_civ getvariable ["carshop",false]) then {_canSellDrugs = true;_canRecruit = false;_canBuyVehicles=true};
if (_civ getvariable ["harbor",false]) then {_canSellDrugs = true;_canRecruit = false;_canBuyBoats=true};
if (_civ getvariable ["gundealer",false]) then {_canSellDrugs = false;_canRecruit = false;_canBuyGuns=true;_canIntel=false;_canTute =true};
if (_civ getvariable ["employee",false]) then {_canSellDrugs = false;_canRecruit = false;_canBuyGuns=false;_canIntel=false};
if (_civ getvariable ["notalk",false]) then {_canSellDrugs = false;_canRecruit = false;_canBuyGuns=false;_canIntel=false};
if (_civ getvariable ["factionrep",false]) then {_canSellDrugs = false;_canRecruit = false;_canBuyGuns=false;_canIntel=false;_canMission=true};
if (_civ getvariable ["crimleader",false]) then {_canSellDrugs = true;_canRecruit = false;_canBuyGuns=false;_canIntel=false;_canMission=false;_canGangJob=true};
if (_civ getvariable ["criminal",false]) then {_canSellDrugs = true;_canRecruit = false;_canBuyGuns=false;_canIntel=false;_canMission=false};
if (_civ getvariable ["priest",false]) then {_canSellDrugs = true;_canRecruit = false;_canBuyGuns=false;_canIntel=false;_canMission=false;_canBank = true};

if (_civ call OT_fnc_hasOwner) then {_canRecruit = false;_canIntel = false;_canSellDrugs=false};

if !((_civ getvariable ["garrison",""]) isEqualTo "") then {_canRecruit = false;_canIntel = false;_canSellDrugs=false};
if !((_civ getvariable ["polgarrison",""]) isEqualTo "") then {_canRecruit = false;_canIntel = false;_canSellDrugs=false};

private _delivery = _civ getVariable ["OT_delivery",[]];
if((count _delivery) > 0) then {
	_delivery params ["_itemcls","_numitems"];
	_canRecruit = false;
	_canIntel = false;
	_canSellDrugs=false;
	_options pushBack [
		format["Deliver %1 x %2",_numitems,_itemcls call OT_fnc_weaponGetName],{
			params ["_civ","_itemcls","_numitems"];
			_stock = player call OT_fnc_unitStock;
			_found = false;
			{
				_x params ["_cls","_num"];
				if(_cls isEqualTo _itemcls && _num >= _numitems) exitWith {
					_found = true;
				};
			}foreach(_stock);
			if(_found) then {
				[player,_civ,["I have a delivery for you",selectRandom ["About time!","OK, thanks","Sweet, thanks"]],{
					params ["_civ","_itemcls","_numitems"];
					_count = 0;
					while {_count < _numitems} do {
						[player, _itemcls] call {
							params ["_unit", "_cls"];
							if(_cls isKindOf ["Rifle",configFile >> "CfgWeapons"]) exitWith {
								_unit removeWeapon _cls;
							};
							if(_cls isKindOf ["Launcher",configFile >> "CfgWeapons"]) exitWith {
								_unit removeWeapon _cls;
							};
							if(_cls isKindOf ["Pistol",configFile >> "CfgWeapons"]) exitWith {
								_unit removeWeapon _cls;
							};
							if(_cls isKindOf ["Binocular",configFile >> "CfgWeapons"]) exitWith {
								_unit removeItem _cls;
							};
							if(_cls isKindOf ["Default",configFile >> "CfgMagazines"]) exitWith {
								_unit removeMagazine _cls;
							};
							_unit removeItem _cls;
						};
						_count = _count + 1;
					};
					_civ setVariable ["OT_deliveryDone",true,true];
					_civ setVariable ["OT_deliveredBy",player,true];
					_civ setVariable ["OT_delivery",[],true];
				},[_civ,_itemcls,_numitems]] spawn OT_fnc_doConversation;
			}else{
				"You do not have the required item/s" call OT_fnc_notifyMinor;
			};
		},
		[_civ,_itemcls,_numitems]
	];
};

if (_canRecruit) then {
	_options pushBack [
		format["Recruit Civilian (-$%1)",_civprice],OT_fnc_recruitCiv
	];
};

if (_canGangJob) then {
	private _gangid = _civ getVariable ["OT_gangid",-1];
	if(_gangid > -1) then {
		_gang = OT_civilians getVariable [format["gang%1",_gangid],[]];
		if(count _gang > 0) then {
			private _name = _gang select 8;
			private _rep = player getVariable [format["gangrep%1",_gangid],0];
			_options pushback format["<t align='center' size='2'>%1</t><br/><br/><t align='center' size='0.8'>Your Rep: %2",_name,_rep];
			_options pushBack [format["Do you have any jobs for me?"], {
				OT_jobsOffered = [];
				call OT_fnc_requestJobGang;
			}];
			if(_rep >= 100) then {
				_options pushBack [format["Do you want to join the resistance?"], {
					params ["_gangid","_gang","_name"];
					private _talk = ["Do you want to join the resistance?"];
					private _civ = OT_interactingWith;
					private _town = _gang select 2;
					private _support = [_town] call OT_fnc_support;
					private _code = {};
					if(_support >= 100) then {
						_talk pushback format["We've heard good things about what you've been doing. I guess we're in"];
						_talk pushback "Good to have you on board";
						_code = {
							params ["_civ","","_gangid"];
							[_civ,_gangid,player] call OT_fnc_gangJoinResistance;
						};
					}else{
						_talk pushback format["I dunno, you've been a big help to us but support for your 'resistance' isnt great around here."];
						_code = {
							params ["_civ","_town","_gangid","_gang","_name"];
							_gangoptions = [];
							_gangoptions pushBack [
								"Offer $5000",{
									params ["_civ","_town","_gangid","_gang","_name"];
									private _cash = player getVariable ["money",0];
									if(_cash >= 5000) then {
										[
											player,
											_civ,
											["What if I gave you $5000?",format["Yeah, OK.",_name]],
											{
												params ["_civ","_gangid"];
												[_civ,_gangid,player] call OT_fnc_gangJoinResistance;
												[-5000] call OT_fnc_money;
											},
											[_civ,_gangid]
										] call OT_fnc_doConversation;
									}else{
										"You cannot afford that" call OT_fnc_notifyMinor;
									};
								},
								[_civ,_town,_gangid,_gang,_name]
							];

							_gangoptions pushBack ["Cancel",{}];
							_gangoptions call OT_fnc_playerDecision;
						}
					};
					[
						player,
						_civ,
						_talk,
						_code,
						[_civ,_town,_gangid,_gang,_name]
					] call OT_fnc_doConversation;
				},[_gangid,_gang,_name]];
			};
		};
	};
};

if (_canMission) then {
	_factionName = _civ getvariable ["factionrepname",""];
	_faction = _civ getvariable ["faction",""];
	private _standing = server getVariable [format["standing%1",_faction],0];
	_options pushback format["<t align='center' size='2'>%1</t><br/><br/><t align='center' size='0.8'>Current Standing: +%2",_factionName,_standing];

	_options pushBack [format["Do you have any jobs for me?"], {
		OT_jobsOffered = [];
		call OT_fnc_requestJobFaction;
	}];

	_options pushBack [format["Buy Gear"], {
		private _civ = OT_interactingWith;
		_faction = _civ getvariable ["faction",""];
		private _standing = server getVariable [format["standing%1",_faction],0];

		_gear = spawner getvariable[format["facweapons%1",_faction],[]];
		_s = [];
		{
			if !(_x in OT_allExplosives) then {
				_s pushback [_x,-1];
			};
		}foreach(_gear);
		//Some factions do not offer ANY gear; i think maybe? RHS influenced?
		createDialog "OT_dialog_buy";
		[OT_nation,_standing,_s,1.2] call OT_fnc_buyDialog;
	}];
	_options pushBack [format["Buy Blueprints"], {
		private _civ = OT_interactingWith;
		_faction = _civ getvariable ["faction",""];
		_factionName = _civ getvariable ["factionrepname",""];
		private _standing = server getVariable [format["standing%1",_faction],0];

		_gear = spawner getvariable[format["facvehicles%1",_faction],[]];
		_s = [];
		_blueprints = server getVariable ["GEURblueprints",[]];

		{
			if !(_x in _blueprints) then {
				_cost = cost getVariable[_x,[100,0,0,0]];
				_req = 0;
				_base = _cost select 0;
				if(_base > 1000) then {_req = 10};
				if(_base > 5000) then {_req = 20};
				if(_base > 10000) then {_req = 40};
				if(_base > 20000) then {_req = 50};
				if(_base > 30000) then {_req = 60};
				if(_base > 40000) then {_req = 70};
				if(_base > 50000) then {_req = 80};
				if(_base > 60000) then {_req = 90};
				if(_base > 100000) then {_req = 95};

				_s pushback [_x,-1,_standing >= _req,format["+%1 standing to %2 required for this blueprint",_req,_factionName]];
			};
		}foreach(_gear);
		createDialog "OT_dialog_buy";
		[OT_nation,_standing,_s,5] call OT_fnc_buyDialog;
	}];
};

if (_canBank) then {
	//All these private variables if they're used inside option needs to be put INSIDE option;
	private _civ = OT_interactingWith;
	private _town = (getpos player) call OT_fnc_nearestTown;
	private _name = _civ getvariable ["name","Archcrypto"];
	private _support = [_town] call OT_fnc_support;
	_options pushback format["<t align='center' size='2'>%1</t><br/><br/><t align='center' size='0.8'>Current Town Standing: %2<br/><br/>""What do you want?""</t>",_name,_support];
	
	_options pushBack [format["Where is my Money?"], { //Put every variable you need in this bish or expect the options to not work;
		private _town = (getpos player) call OT_fnc_nearestTown;
		private _support = [_town] call OT_fnc_support;

		if(_support < -1 then { //Bug test at -1, but real at 50;
			format["Resistance Support in this town is too low (%1) < 50",_support] call OT_fnc_notifyMinor;
		}else{
			[_support, player getVariable ["money", 0]] call OT_fnc_bankDialog;
		};
	}];

	_options pushBack [
		format["I want to Donate to your Church."], {
			private _civ = OT_interactingWith;
			private _town = (getpos player) call OT_fnc_nearestTown;
			private _name = _civ getvariable ["name","Archcrypto"];
			private _support = [_town] call OT_fnc_support;
			private _talk = ["I want to Donate to your Church."];

			private _code = {};
			if(_support > -1) then { //Bug test at -1 but real at 20
				private _money = player getVariable ["money", 0];
				if (_money > 2000) then { //_baseCost effective here too;
					_talk pushback "Nice, you can buy us some new GPUs.";
					//[_town, _support, player getVariable ["money", 0]] call OT_fnc_donateDialog;
					_code = {
						/* KISS loop deletion;
						private _abandonedTownArray = [];
						private _abandoned = server getVariable ["NATOabandoned",[]];
						{
							if (_x in _abandoned) then {
								_abandonedTownArray = pushBackUnique _x; //gets names;
							};
						}foreach(OT_allTowns);
 						*/
						_donateTownsList = [];
						private _baseCost = 2000; //2000 for GPU base cost 2021;
						private _abandoned = server getVariable ["NATOabandoned",[]];
						//Sorted by distance;
						private _sorted_OT_allTowns = [OT_allTowns, [], {markerPos(_x) distance player}, "ASCEND"] call BIS_fnc_sortBy; 
							
						//This is out of 5 because max list for UI;
						for [{private _i = 0}, {(_i < count (_sorted_OT_allTowns)) && (count (_donateTownsList) < 5)}, {_i = _i+1}] do { 
							//params _x gives town names by default;
							private _townPos = markerPos(_sorted_OT_allTowns select _i); //town position of all towns;
							private _townName = _townPos call OT_fnc_nearestTown; //town name of all towns;
							private _stability = server getVariable [format["stability%1",_townName], 100];
							private _support = [_townName] call OT_fnc_support;
							private _distance = (player distance _townPos); //_distance is in meters from town to church town;
							private _cost = floor(_distance); //in meters;
							private _go = {
								_this spawn {
									//spawn cannot call other local functions on the same scope as itself.
									//It can, however, call other global functions.
									//If you want to call a local function which has NOT been created inside a spawned function, then do this:
									//_fncOne = { systemChat"This is _fncOne" }; _fncTwo = { call (_this select 0) }; [_fncOne] spawn _fncTwo;

									private _townPos = _this;
									private _townName = _townPos call OT_fnc_nearestTown;
									//private _stability = server getVariable [format["stability%1",_townName], 100];
									private _support = [_townName] call OT_fnc_support;
									private _baseCost = 2000;
									private _distance = floor (player distance _townPos);
									private _cost = floor(_distance); //in meters;
									private _abandoned = server getVariable ["NATOabandoned",[]];

									if (_support < 0) then {
										//shouldn't have shot so many civilians now the price is higher;
										_cost = _cost + round(abs(1000 - _support)*100); //100 multiplied by negative stability;
									} else { //Stability between 0 and 999;
										_cost = _cost + round((1000 - _support)*100);
									};
									if (_townName in _abandoned) then {
										_cost = round(_cost * 0.75); //25% off if abandoned
									};
									//_cost reflects perk player has due to trade;
									_cost = round (_cost * (5/(player getVariable ["OT_arr_trade",[1,1]] select 1)));

									if (_distance < 1500) then {
										_cost = _baseCost;
									};

									_money = player getVariable ["money",0];
									if(_money < _cost) then {
										"You cannot afford that!" call OT_fnc_notifyMinor;
									}else{
										[-_cost] call OT_fnc_money;
										systemChat format["Donated to %1, For (-$%2)",_townName,_cost];
										private _chance = 60;
										if (player getVariable ["ot_isSmoking", false]) then {
											_chance = 80;
										};
										if (random(100) < _chance) then {
											private _add_support = +(round(random 50));
											[_townName, _add_support] call OT_fnc_support;
											format["%1 Gained %2 Resistance Support", _townName, _add_support] call OT_fnc_notifyMinor;
										};
									};
								};
							};
							//If support is under +100, and town is either bandoned or stability is less than 90;
							//pushes into donation list if stability is below 100; should cap over 1000 globally per town one day;
							if (_support < 100 && (_townName in _abandoned || _stability < 90)) then {
								//will push results if stability cap is over 1000, cap for future towns;
								if (_support < 0) then {
									//shouldn't have shot so many civilians now the price is higher;
									_cost = _cost + round(abs(100 - _support)*100); //100 multiplied by negative stability;
								} else { //Stability between 0 and 999;
									_cost = _cost + round((100 - _support)*100);
								};
								if (_townName in _abandoned) then { //_x is a name;
									_cost = round(_cost * 0.75); //25% off if abandoned
								};
								_cost = round (_cost * (5/(player getVariable ["OT_arr_trade",[1,1]] select 1)));
								//If _distance is less than 1.5km from player, then the town is cheaper, else expensive;
								//This makes people go to closer churches for a better price.
								if(_distance < 1500) then {
									//This is a dialog choice fed into fn_playerDecision.sqf,
									//Then bound to OT_choices and used within main.hpp,
									//Then called by OT_fnc_choiceMade in format of [name, code, args];
									//_t is town name;
									//_cost is cost calculated from distance (assumed);
									//_go is a spawn;
									//_p is marked position;
									_donateTownsList pushback [format["Donate to %1 for (-$%2)",_townName,_baseCost],_go,_townPos];
								} else {
									_donateTownsList pushback [format["Donate to %1 for (-$%2)",_townName,_baseCost + _cost],_go,_townPos];
								};
							};
						};	
						//}foreach(OT_allTowns); //OT_allTowns is only names;
						//Looks like _donateTownsList is an array of single elements.
						_donateTownsList call OT_fnc_playerDecision;
				
					};
				} else {
					_talk pushback format ["$%1?!?, go hustle some medicine. You can't afford a single GPU here.", _money];
					"You need more than $2000 to help an Archcrypto" call OT_fnc_notifyMinor;
					_code = {};
				};
			} else {
				_talk pushback "Our Blockchain does not trust you here.";
				"This Archcrypto needs at least 20 town support" call OT_fnc_notifyMinor;
				_code = {};
			};

			[
				player, //player;
				_civ,	//OT_interactWith;	
				_talk,	//Convo the NPC replies with in system chat;
				_code,	//Code to execute, can include other nested call OT_fnc_doConversation;
				[_town,_support,_name] //Params to be passed into ( i assume in _code);
			] call OT_fnc_doConversation;
		}
	];
	
	// Works good, maybe more options in future;
	_options pushBack [
		format["Why's the church locked?"], {
			private _civ = OT_interactingWith;
			private _town = (getpos player) call OT_fnc_nearestTown;
			private _name = _civ getvariable ["name","Archcrypto"];
			private _support = [_town] call OT_fnc_support;

			private _talk = ["Why's the church locked?"];
			private _code = {

			};

			if(_support > 0) then {
				_talk pushback "I been mining Crypto here since 2013.";
				_code = {};
			} else {
				_talk pushback "None of your business Fiat hoarder.";
				_code = {};
			};

			[
				player, //player;
				_civ,	//OT_interactWith;	
				_talk,	//Convo the NPC replies with in system chat;
				_code,	//Code to execute, can include other nested call OT_fnc_doConversation;
				[_town,_support,_name] //Params to be passed into ( i assume in _code);
			] call OT_fnc_doConversation;
		}
	];

	_options pushBack [
		format["Who keeps Ringing that Bell!?"], {
			private _civ = OT_interactingWith;
			private _town = (getpos player) call OT_fnc_nearestTown;
			private _name = _civ getvariable ["name","Archcrypto"];
			private _support = [_town] call OT_fnc_support;

			private _talk = ["Who keeps Ringing that Bell!?"];
			private _code = {

			};

			if(_support > 50) then {
				_talk pushback "I ring the bell to let other Crypto holders know the servers are still operational.";
				_code = {};
			} else {
				_talk pushback "I'm glad you asked Stranger!";
				_talk pushback "On the top floor, the turbo-encabulator inside has reached a high level of development. So whenever a forescent skor motion is required, it may also be employed in conjunction with a drawn reciprocation dingle arm, to reduce sinusoidal repleneration.";
				_talk pushback "And that's why I ring the bell every 5 minutes.";
				_code = {};
			};

			[
				player, //player;
				_civ,	//OT_interactWith;	
				_talk,	//Convo the NPC replies with in system chat;
				_code,	//Code to execute, can include other nested call OT_fnc_doConversation;
				[_town,_support,_name] //Params to be passed into ( i assume in _code);
			] call OT_fnc_doConversation;
		}
	];

};
//_options call OT_fnc_playerDecision;
if (_canBuy) then {
	_options pushBack [
		"Buy",{
			private _civ = OT_interactingWith;
			private _town = (getpos player) call OT_fnc_nearestTown;
			private _standing = [_town] call OT_fnc_support;

			_cat = _civ getVariable "OT_shopCategory";
			player setVariable ["OT_shopTarget","Self",false];

			createDialog "OT_dialog_buy";

			if(_cat isEqualTo "Clothing") then {
				[_town,_standing] call OT_fnc_buyClothesDialog;
			}else{
				_s = [];
				{
					if((_x select 0) isEqualTo _cat) exitWith {
						{
							_s pushback [_x,-1];
						}foreach(_x select 1);
					};
				}foreach(OT_items);

				if(_cat isEqualTo "Surplus") then {
					{
						_s pushback [_x,-1];
					}foreach(OT_allBackpacks);
				};
				[_town,_standing,_s] call OT_fnc_buyDialog;
			};
		}
	];
};

//The gun dealer does not have a title card;
if (_canTute) then {
	//gun dealer
	_options pushBack [format["Do you have any jobs for me?"], {
		OT_jobsOffered = [];
		call OT_fnc_requestJobResistance;
	}];
	_options pushBack [
		"Do you know any gangs nearby?",{
			private _civ = OT_interactingWith;
			private _town = (getpos player) call OT_fnc_nearestTown;
			private _talk = ["Do you know any gangs nearby?"];
			//find nearest gang
			private _gangid = -1;
			private _gang = [];
			private _name = "";
			private _revealed = server getVariable ["revealedGangs",[]];
			{
				_x params ["_pos","_name"];
				private _gangs = OT_civilians getVariable [format["gangs%1",_name],[]];
				private _found = false;
		        if(count _gangs > 0) then {
					if !((_gangs select 0) in _revealed) then {
						_gangid = _gangs select 0;
						_found = true
					};
				};
				if(_found) exitWith {};
			}foreach([OT_townData,[],{(_x select 0) distance2D player},"ASCEND",{((_x select 0) distance2D player) < 3000}] call BIS_fnc_SortBy);

			private _code = {

			};

			if(_gangid > -1) then {
				_gang = OT_civilians getVariable [format["gang%1",_gangid],[]];
				_name = _gang select 8;
				private _support = [_town] call OT_fnc_support;
				if(_support > 50) then {
					_talk pushback format["I know of a gang called %1, I'll mark their camp on your map, maybe they'll have some jobs for you",_name];
					_talk pushback "Thanks!";
					_talk pushback "Anything for the resistance";
					_code = {
						params ["_town","_gangid","_gang"];
						private _town = (getpos player) call OT_fnc_nearestTown;
                        _mrkid = format["gang%1",_town];
                        _mrk = createMarker [_mrkid, _gang select 4];
                        _mrkid setMarkerType "ot_Camp";
                        _mrkid setMarkerColor "colorOPFOR";
						private _revealed = server getVariable ["revealedGangs",[]];
                        _revealed pushback _gangid;
						server setVariable ["revealedGangs",_revealed,true];
					};
				}else{
					_talk pushback format["I do, but I doubt they'd like it if I told you where they were",_name];
					_code = {
						params ["_town","_gangid","_gang","_name"];
						_gangoptions = [];
						_gangoptions pushBack [
							"Offer $50",{
								params ["_town","_gangid","_gang","_name"];
								private _civ = OT_interactingWith;
								private _cash = player getVariable ["money",0];
								//CHecks to see if player has 50 or more money;
								//[player, OT_interactingWith, ["Player Pick option 1", formatted response], {params for class and code to do}, [_variables matching params]] OT_fnc_doConversation.
								if(_cash >= 50) then {
									[
										player,
										_civ,
										["What if I gave you $50?",format["Yeah, OK. I know of a gang called %1, I'll mark their camp on your map, maybe they'll have some jobs for you",_name]],
										{
											params ["_town","_gangid","_gang","_name"];
											private _town = (getpos player) call OT_fnc_nearestTown;
											[-50] call OT_fnc_money;
											_mrkid = format["gang%1",_town];
					                        _mrk = createMarker [_mrkid, _gang select 4];
					                        _mrkid setMarkerType "ot_Camp";
					                        _mrkid setMarkerColor "colorOPFOR";
											private _revealed = server getVariable ["revealedGangs",[]];
					                        _revealed pushback _gangid;
											server setVariable ["revealedGangs",_revealed,true];
										},
										[_town,_gangid,_gang,_name]
									] call OT_fnc_doConversation;
								}else{
									"You cannot afford that" call OT_fnc_notifyMinor;
								};
							},
							[_town,_gangid,_gang,_name]
						];

						_gangoptions pushBack ["Cancel",{}];
						_gangoptions call OT_fnc_playerDecision;
					}
				};
			}else{
				_talk pushback "Sorry, but I don't know about any gangs near here";
				_code = {};
			};

			[
				player, //player;
				_civ,	//OT_interactWith;	
				_talk,	//Convo the NPC replies with in system chat;
				_code,	//Code to execute, can include other nested call OT_fnc_doConversation;
				[_town,_gangid,_gang,_name] //Params to be passed into ( i assume in _code);
			] call OT_fnc_doConversation;
		}
	];

	_done = player getVariable ["OT_tutesDone",[]];
	if !("NATO" in _done) then {
		_options pushBack [
			"So, about those NATO soldiers...",{
				private _civ = OT_interactingWith;
				[
					player,
					_civ,
					[
						"So, about those NATO soldiers...",
						"Yes! I will gladly pay you $250 to get them off my back",
						"Alright I'll see what I can do"
					],
					(OT_tutorialMissions select 0)
				] call OT_fnc_doConversation;
			}
		];
	};
	if !("Drugs" in _done) then {
		_options pushBack [
			"You sell Ganja right?",{
				private _civ = OT_interactingWith;
				[
					player,
					_civ,
					[
						"You sell Ganja right?",
						"I sure do, wanna blaze it?",
						"Not right now, I need some cash first",
						"Oh OK, sell it to the civilians then"
					],
					(OT_tutorialMissions select 1)
				] call OT_fnc_doConversation;
			}
		];
	};
	if !("Economy" in _done) then {
		_options pushBack [
			"So how can I make money legally?",{
				private _civ = OT_interactingWith;
				[
					player,
					_civ,
					[
						"How can I make some legal money?",
						"Legal money? Where's the fun in that. I guess you could try selling to stores or leasing houses.",
						"Thanks."
					],
					(OT_tutorialMissions select 1)
				] call OT_fnc_doConversation;
			}
		];
	};
};

if (_canBuyBoats) then {
	_options pushBack [
		"Buy Boat",{
			createDialog "OT_dialog_buy";
			{
				private _civ = OT_interactingWith;
				_cls = _x select 0;
				private _town = (getpos player) call OT_fnc_nearestTown;
				private _standing = [_town] call OT_fnc_support;

				_price = [_town,_cls,_standing] call OT_fnc_getPrice;
				if("fuel depot" in (server getVariable "OT_NATOabandoned")) then {
					_price = round(_price * 0.5);
				};
				_idx = lbAdd [1500,format["%1",_cls call OT_fnc_vehicleGetName]];
				lbSetPicture [1500,_idx,_cls call OT_fnc_vehicleGetPic];
				lbSetData [1500,_idx,_cls];
				lbSetValue [1500,_idx,_price];
			}foreach(OT_boats);
		}
	];
	_options pushBack [
		"Ferry Service",{
			"Where do you want to go?" call OT_fnc_notifyMinor;
			_ferryoptions = [];
			{
				private _p = markerPos(_x); //returns an 3 item array;
				private _t = _p call OT_fnc_nearestTown; //town name
				private _dist = (player distance _p);
				private _cost = floor(_dist * 0.005);
				private _go = {
					_this spawn {
						//spawn cannot call other local functions on the same scope as itself.
						//It can, however, call other global functions.
						//If you want to call a local function which has NOT been created inside a spawned function, then do this:
						//_fncOne = { systemChat"This is _fncOne" }; _fncTwo = { call (_this select 0) }; [_fncOne] spawn _fncTwo;

						private _destpos = _this;
						player setVariable ["OT_ferryDestination",_destpos,false];
						private _desttown = _destpos call OT_fnc_nearestTown;
						private _pos = (getpos player) findEmptyPosition [10,100,OT_vehType_ferry];
						if (count _pos isEqualTo 0) exitWith {
							"Not enough space, please clear an area nearby" call OT_fnc_notifyMinor;
						};
						private _cost = floor((player distance _destpos) * 0.005);
						player setVariable ["OT_ferryCost",_cost,false];
						_money = player getVariable ["money",0];
						if(_money < _cost) then {
							"You cannot afford that!" call OT_fnc_notifyMinor
						}else{
							[-_cost] call OT_fnc_money;
							_veh = OT_vehType_ferry createVehicle _pos;

							clearWeaponCargoGlobal _veh;
							clearMagazineCargoGlobal _veh;
							clearBackpackCargoGlobal _veh;
							clearItemCargoGlobal _veh;

							private _dir = 0;
							while {!(surfaceIsWater ([_pos,800,_dir] call BIS_fnc_relPos)) && _dir < 360} do {
								_dir = _dir + 45;
							};

							_veh setDir _dir;
							player reveal _veh;
							createVehicleCrew _veh;
							_veh lockDriver true;
							private _driver = driver _veh;
							player moveInCargo _veh;

							_driver globalchat format["Departing for %1 in 10 seconds",_desttown];

							sleep 5;
							_driver globalchat format["Departing for %1 in 5 seconds",_desttown];
							sleep 5;

							private _g = group (driver _veh);
							private _wp = _g addWaypoint [_destpos,50];
							_wp setWaypointType "MOVE";
							_wp setWaypointSpeed "NORMAL";

							_veh addEventHandler ["GetOut", {
								params ["_vehicle","_position","_unit"];
								_unit setVariable ["OT_ferryDestination",[],false];
							}];

							systemChat format["Departing for %1, press Y to skip (-$%2)",_desttown,_cost];

							waitUntil {
								!alive player
								|| !alive _veh
								|| !alive _driver
								|| (vehicle player isEqualTo player)
								|| (player distance _destpos < 80)
							};

							if(vehicle player isEqualTo _veh && alive _driver) then {
								_driver globalchat format["We've arrived in %1, enjoy your stay",_desttown];
							};
							sleep 15;
							if(vehicle player isEqualTo _veh && alive _driver) then {
								moveOut player;
								_driver globalchat "Alright, bye";
							};
							//Max 80% chance nato search is avoided when selling.
							private _stealth = player getvariable ["OT_arr_stealth",[1,1]] select 1;
							if(random 100 > round ((_stealth - 1) * 4)) then {
								[player] spawn OT_fnc_NATOsearch;
							};
							if(!alive _driver) exitWith{};
							_timeout = time + 800;

							_wp = _g addWaypoint [_pos,0];
							_wp setWaypointType "MOVE";
							_wp setWaypointSpeed "NORMAL";

							waitUntil {_veh distance _pos < 100 || time > _timeout};
							if(!alive _driver) exitWith{};

							deleteVehicle _driver;
							deleteVehicle _veh;
						};
					};
				};
				if(_dist > 1000) then {
					//_t is town name;
					//_cost is cost calculated from distance (assumed);
					//_go is a spawn;
					//_p is marked position;
					_ferryoptions pushback [format["%1 (-$%2)",_t,_cost],_go,_p];
				};
			}foreach(OT_ferryDestinations);
			//Looks like _ferryoptions is an array of single elements.
			_ferryoptions call OT_fnc_playerDecision;
		}
	];
};

if (_canBuyVehicles) then {
	_options pushBack [
		"Buy Vehicles",OT_fnc_buyVehicleDialog
	];
};

if (_canBuyGuns) then {
	_options pushBack [
		"Buy",OT_fnc_gunDealerDialog
	];
};

if (_canSell) then {
	_options pushBack [
		"Sell",{
			private _civ = OT_interactingWith;
			private _town = (getpos player) call OT_fnc_nearestTown;
			private _standing = [_town] call OT_fnc_support;

			_cat = _civ getVariable "OT_shopCategory";
			_categorystock = [player,_cat] call OT_fnc_unitStock;

			player setVariable ["OT_shopTarget","Self",false];
			player setVariable ["OT_shopTargetCategory",_cat,false];

			createDialog "OT_dialog_sell";
			[_categorystock,_town,_standing] call OT_fnc_sellDialog;
		}
	];
};

if (_isShop) then {
	_options pushBack [format["Do you have any jobs for me?"], {
		OT_jobsOffered = [];
		private _support = [_town] call OT_fnc_support;
		if(_support < 0) then {
			format["Resistance Support in this town is too low (%1)",_support] call OT_fnc_notifyMinor;
		}else{
			call OT_fnc_requestJobShop;
		};
	}]
};

OT_drugSelling = "";
OT_drugQty = 0;

if (_canSellDrugs) then {
	{
		_drugcls = _x;
		if(((items player) find _x) > -1 && !(_civ getVariable["OT_askedDrugs",false])) then {

			_drugname = _x call OT_fnc_weaponGetName;
			_options pushBack [format ["Sell %1",_drugname],{
				OT_drugSelling = _this;
				_drugcls = _this;
				_drugname = _drugcls call OT_fnc_weaponGetName;
				if(((items player) find _drugcls) isEqualTo -1) exitWith {};
				_num = 0;
				{
					if(_x select 0 isEqualTo _drugcls) exitWith {_num = _x select 1};
				}foreach(player call OT_fnc_unitStock);
				OT_drugQty = _num;

				private _town = (getpos player) call OT_fnc_nearestTown;
				private _price = [_town,_drugcls] call OT_fnc_getDrugPrice;
				private _civ = OT_interactingWith;
				_civ setVariable["OT_askedDrugs",true,true];


				player globalchat (
					format [selectRandom [
							"Would you like to buy some %1?",
							"Wanna buy some %1?",
							"Hey, want some %1?",
							"You wanna buy some %1?",
							"Pssst! %1?",
							"Hey you looking for any %1?"
						],
						_drugname
					]);

				if(side _civ isEqualTo civilian) then {
					//Dinky Code by Dorf to balance sale chances in populated areas vs non
					//Most populated places should be easier to sell with cheaper priced drugs
					//Least populated places should be harder to sell with higher priced drugs
					//private _playerInTown = (getPos player) call OT_fnc_nearestTown;
					private _stability = (server getVariable format["stability%1", _town])/100;
					private _population = server getVariable format["population%1",_town];
					if (_stability < 0.25) then {_stability = 0.25}; //Max 25% stability discount
					if(_population > 1000) then {_population = 1000};
					
					//private _baseprice = (_price * 1); // constant of base price could be changed

					private _inverse_population = abs((_population - 1000)/1000) + 2;
					//This pricing should reflect drug pricing from increase of population is higher pricing
					//In addition too greater stability, the more expensive the drugs
					//_price = _price = [_town,_drugcls] call OT_fnc_getDrugPrice;
					_price = round (_price);
					private _stealth = player getVariable ["OT_arr_stealth",[1,1]] select 1;
					private _trade = player getvariable ["OT_arr_trade",[1,1]] select 1;
					//This is a 100% chance to avoid the cops only if you're lvl 20 on stealth.
					if((player call OT_fnc_unitSeenNATO) && (random 100 > (100 - ((_stealth - 1)*5)))) then {
						[player] remoteExec ["OT_fnc_NATOsearch",2,false];
					}else{
						//Trade skill impacts selling capability in addition to...
						//large number in below code to dictate a percentage bonus to selling in
						//higher population areas (aka easier to sell with more people around)
						private _rng_cap = 100 - round(abs((_population - 1000)/1000) * 30); //30 Percent bonus chance to sell
						//if (_rng_cap > random 100) then { //dictated 70% to 99% of success 
						//if((random 100) > (60-((_trade - 1)*3))) then { //Dictates almost 40% to 100% chance of success
						if ((_rng_cap - 20 + _trade) > random 100) then { 
							//Above Dictates 50% minimum without skill, 70% with max skill, 79% without skill high demand, and 99% with skill high demand,
							[_civ,player,["How much?",format["$%1",_price],"OK"],
							{
								private _drugSell = _this select 0;
								[
									round(
										([(getpos player) call OT_fnc_nearestTown,_drugSell] call OT_fnc_getDrugPrice) //*1.2 constant here removed;
									)
								] call OT_fnc_money;
								player removeItem _drugSell;
								OT_interactingWith addItem _drugSell;
								OT_interactingWith setVariable ["OT_Talking",false,true];
								private _town = (getpos player) call OT_fnc_nearestTown;
								//Cocaine makes stability drop more.
								private _drug_chance = 50;
								if (_drugname isEqualTo "Blow") then {
									_drug_chance = 15; //85% chance.
								};
								if((random 100 > _drug_chance) && !isNil "_town") then {
									[_town,-1] call OT_fnc_stability;
								};
								//Trade gains the ability to gain more influence
								if(random 100 > (80 - (_trade + 1)*2)) then {
									1 call OT_fnc_influence;
								};
							}, [OT_drugSelling]] call OT_fnc_doConversation;
						}else{
							[_civ,player,["No, thank you"],{OT_interactingWith setVariable ["OT_Talking",false,true];}] call OT_fnc_doConversation;
						};
					};
				}else{
					_price = [OT_nation,_drugcls] call OT_fnc_getDrugPrice;
					if(player call OT_fnc_unitSeenNATO) then {
						[player] remoteExec ["OT_fnc_NATOsearch",2,false];
					}else{
						if((random 100) > 5) then {
							[
								_civ,
								player,
								[format["OK I'll give you $%1 for each",_price],"OK"],
								{
									[([OT_nation,OT_drugSelling] call OT_fnc_getDrugPrice) * OT_drugQty] call OT_fnc_money;
									for "_t" from 1 to OT_drugQty do {
										player removeItem OT_drugSelling
									};
									OT_interactingWith setVariable ["OT_Talking",false,true];
								}
							] call OT_fnc_doConversation;
							[_town,-OT_drugQty] call OT_fnc_stability;
						}else{
							[_civ,player,["No, go away!"],{OT_interactingWith setVariable ["OT_Talking",false,true];player setCaptive false;}] call OT_fnc_doConversation;
							if(player call OT_fnc_unitSeenCRIM) then {
								hint "You are dealing on enemy turf";
								player setCaptive false;
							};
						};
					};
				};
			},_drugcls];
		};
	}foreach(OT_allDrugs);
};

_options pushBack ["Cancel",{}];

_options call OT_fnc_playerDecision;
