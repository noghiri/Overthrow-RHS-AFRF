// fnc_bankDialog calls goes here.

closedialog 0;
createDialog "OT_dialog_bank";
openMap false;

disableSerialization;

params ["_support", "_money"];

handleMoney = {
	params = ["_term", "_amount"]

	if (_term == "withdrawal") then {
		//withdrawal up to the percentage capacity of the player's wallet.
		hint "Withdrawal ordered";

	} else { 
		hint "deposit ordered";
		//deposit a percentage of the player's cash money into crypto.
	};

}