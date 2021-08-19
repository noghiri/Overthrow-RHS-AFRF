private ["_town","_cls","_cost","_baseprice","_stability"];
private "_inverse_population";

_town = _this select 0;
_cls = _this select 1;
_price = 0;

_cost = cost getVariable _cls;
_baseprice = _cost select 0;

_stability = (server getVariable format["stability%1",_town]) / 100;
_population = server getVariable format["population%1",_town];
if (_stability < 0.25) then {_stability = 0.25}; //Minimum 25% stability discount
if(_population > 1000) then {_population = 1000};
_inverse_population = abs((_population - 1000)/1000) + 2;

//This pricing should reflect drug pricing from increase of population is higher pricing
//In addition too greater stability, the more expensive the drugs
_price = _baseprice + _baseprice * (_stability * _inverse_population);

//Does this mean if not in town then pricei s cheaper?
if !(_town in OT_allTowns) then {_price = round(_price * 0.63)};

round(_price);