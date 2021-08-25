//Generates a civilian identity [face, clothes, [first name index,last name index], glasses ]
private _glasses = "";
if((random 100) < 35) then {_glasses = selectRandom OT_allGlasses};
//names here are set in an array of index numbers from first and last [0,0] to [first,last]
[selectRandom OT_faces_local, selectRandom OT_clothes_locals, [round random ((count OT_firstNames_local) - 1),round random ((count OT_lastNames_local) - 1)],_glasses]
