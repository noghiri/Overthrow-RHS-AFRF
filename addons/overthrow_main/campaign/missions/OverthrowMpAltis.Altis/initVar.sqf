
OT_nation = "Altis";
OT_saveName = "Overthrow.altis.001";

OT_tutorial_backstoryText = "Altis, the main island of the Republic of Altis and Stratis, is located in the Mediterranean Sea to the east of Malta. As of 2040, Altis is currently under occupation by NATO forces following a brutal civil war a half decade prior, and the nation is still recovering. NATO originally occupied the country under the promise of a complete withdrawal of forces and return to local democratic rule; despite this, NATO soldiers still occupy the island's military installations. The economy continues to stagnate and citizens are becoming increasingly angry at the lack of local autonomy.";
OT_startDate = [2040,7,14,8,00];

OT_startCameraPos = [11646.6,6406.52,2];
OT_startCameraTarget = [13808.2,6387.16,0];

//Used to control updates and persistent save compatability. When these numbers go up, that section will be reinitialized on load if required. (ie leave them alone)
OT_economyVersion = 2;
OT_NATOversion = 2;
OT_CRIMversion = 1;

OT_faction_NATO = "OPF_F";
OT_spawnFaction = "IND_G_F"; //This faction will have a rep in spawn town

OT_flag_NATO = "rhs_Flag_Russia_F";
OT_flag_CRIM = "Flag_Syndikat_F";
OT_flag_IND = "Flag_Altis_F";
OT_flagImage = "\A3\ui_f\data\map\markers\flags\Altis_ca.paa";
OT_flagMarker = "flag_Tanoa";

OT_populationMultiplier = 0.5; //Used to tweak populations per map

//Interactable items that spawn in your house
OT_item_Storage = "B_CargoNet_01_ammo_F"; //Your spawn ammobox
OT_item_Map = "Mapboard_altis_F";
OT_item_Tent = "Land_TentDome_F";
OT_item_Safe = "Land_MetalCase_01_small_F";

//Animals to spawn (@todo: spawn animals)
OT_allLowAnimals = ["Rabbit_F","Turtle_F"];
OT_allHighAnimals = ["Goat_random_F"];
OT_allFarmAnimals = ["Hen_random_F","Cock_random_F","Sheep_random_F"];
OT_allVillageAnimals = ["Hen_random_F","Cock_random_F"];
OT_allTownAnimals = ["Alsatian_Random_F","Fin_random_F"];

OT_fuelPumps = ["Land_FuelStation_02_pump_F","Land_FuelStation_01_pump_F","Land_fs_feed_F","Land_FuelStation_Feed_F"];

OT_churches = ["Land_Church_03_F","Land_Church_01_F","Land_Church_02_F","Land_Temple_Native_01_F"];

OT_language_local = "LanguageGRE_F";
OT_identity_local = "Head_Greek";

OT_language_western = "LanguageRUS_F";
OT_identity_western = "Head_Euro";

OT_language_eastern = "LanguageRUS_F";
OT_identity_eastern = "Head_Euro";

OT_face_localBoss = "TanoanBossHead";


OT_civType_gunDealer = "C_man_p_fugitive_F";
OT_civType_local = "C_man_1";
OT_civType_carDealer = "C_man_w_worker_F";
OT_civType_shopkeeper = "C_man_w_worker_F";
OT_civType_worker = "C_man_w_worker_F";
OT_civType_priest = "C_man_w_worker_F";
OT_vehTypes_civ = []; //populated automatically, but you can add more here and they will appear in streets
OT_vehType_distro = "C_Van_01_box_F";
OT_vehType_ferry = "C_Boat_Transport_02_F";
OT_vehType_service = "C_Offroad_01_repair_F";
OT_vehTypes_civignore = ["C_Hatchback_01_F","C_Hatchback_01_sport_F",OT_vehType_service]; //Civs cannot drive these vehicles for whatever reason

OT_illegalHeadgear = ["H_MilCap_gen_F","H_Beret_gen_F","H_HelmetB_TI_tna_F"];
OT_illegalVests = ["V_TacVest_gen_F"];

OT_clothes_locals = ["U_I_C_Soldier_Bandit_2_F","U_I_C_Soldier_Bandit_3_F","U_C_Poor_1","U_C_Poor_2","U_C_Poor_shorts_1","U_C_Poloshirt_blue","U_C_Poloshirt_burgundy","U_C_Poloshirt_redwhite","U_C_Poloshirt_stripped"];
OT_clothes_expats = ["U_I_C_Soldier_Bandit_5_F","U_C_Poloshirt_blue","U_C_Poloshirt_burgundy","U_C_Poloshirt_redwhite","U_C_Poloshirt_salmon","U_C_Poloshirt_stripped","U_C_Man_casual_6_F","U_C_Man_casual_4_F","U_C_Man_casual_5_F"];
OT_clothes_tourists = [];
OT_clothes_priest = ["U_C_Man_casual_2_F", "U_C_Scientist", "U_C_CBRN_Suit_01_White_F", "U_C_FormalSuit_01_tshirt_black_F"];
OT_clothes_port = "U_Marshal";
OT_clothes_shops = ["U_C_Man_casual_2_F","U_C_Man_casual_3_F","U_C_Man_casual_1_F"];
OT_clothes_carDealers = ["U_Marshal"];
OT_clothes_harbor = ["U_C_man_sport_1_F","U_C_man_sport_2_F","U_C_man_sport_3_F"];
OT_clothes_guerilla = ["U_I_C_Soldier_Para_1_F","U_I_C_Soldier_Para_2_F","U_I_C_Soldier_Para_3_F","U_I_C_Soldier_Para_4_F"];
OT_clothes_police = ["U_I_G_resistanceLeader_F","U_BG_Guerilla2_1","U_BG_Guerilla2_3","U_I_C_Soldier_Para_4_F"];
OT_vest_police = "V_TacVest_blk_POLICE";
OT_hat_police = "H_Cap_police";
OT_clothes_mob = "U_I_C_Soldier_Camo_F";

//NATO stuff
OT_NATO_HMG = "rhs_KORD_high_MSV";
OT_NATO_Vehicles_AirGarrison = [
	["RHS_Mi8mt_Cargo_vvsc",1],
	["RHS_Mi8mt_vvsc",1],
	["RHS_Mi24Vt_vvs",1],
	["RHS_Mi8AMT_vvsc",2],
	["rhs_ka60_c",3],
	["RHS_Mi24P_vvsc",1],
	["RHS_Mi8mt_vvsc",2]
];

OT_NATO_Vehicles_JetGarrison = [
	["RHS_Su25SM_vvsc",1]
];

OT_NATO_Vehicles_StaticAAGarrison = [
	"RHS_ZU23_MSV",
	"RHS_ZU23_MSV"
]; //Added to every airfield

if(OT_hasJetsDLC) then {
	OT_NATO_Vehicles_JetGarrison pushback ["rhs_mig29s_vvsc",1];
	OT_NATO_Vehicles_JetGarrison pushback ["rhs_mig29sm_vvsc",1];
	OT_NATO_Vehicles_StaticAAGarrison pushback "rhs_p37_turret_vpvo";
	OT_NATO_Vehicles_StaticAAGarrison pushback "O_SAM_System_04_F";
};

OT_NATO_StaticGarrison_LevelOne = ["rhs_KORD_high_MSV"];
OT_NATO_StaticGarrison_LevelTwo = ["rhs_KORD_high_MSV","rhs_KORD_high_MSV","rhs_KORD_high_MSV","rhs_btr60_msv"];
OT_NATO_StaticGarrison_LevelThree = ["rhs_Kornet_9M133_2_msv","rhs_igla_AA_pod_msv","rhs_KORD_high_MSV","rhs_KORD_high_MSV","rhs_KORD_high_MSV","rhs_btr60_msv","rhs_btr80a_msv"];

OT_NATO_CommTowers = ["Land_TTowerBig_1_F","Land_TTowerBig_2_F"];

OT_NATO_Unit_Sniper = "rhssaf_army_o_m10_para_sniper_m82a1";
OT_NATO_Unit_Spotter = "rhssaf_army_o_m10_para_spotter";
OT_NATO_Unit_AA_spec = "rhs_msv_emr_aa";
OT_NATO_Unit_AA_ass = "rhs_msv_emr_aa";
OT_NATO_Unit_HVT = "rhssaf_army_o_m10_digital_officer";
OT_NATO_Unit_TeamLeader = "rhs_msv_emr_sergeant";
OT_NATO_Unit_SquadLeader = "rhs_msv_emr_officer_armored";

OT_NATO_Unit_PoliceCommander = "rhsgref_ins_commander";
OT_NATO_Unit_Police = "rhsgref_ins_squadleader";
OT_NATO_Vehicle_PoliceHeli = "rhsgref_ins_Mi8amt";
OT_NATO_Vehicle_Quad = "O_G_Quadbike_01_F";
OT_NATO_Vehicle_Police = "rhsgref_ins_uaz";
OT_NATO_Vehicle_Transport = ["rhsgref_ins_gaz66","rhsgref_ins_uaz"];
OT_NATO_Vehicle_Transport_Light = "rhsgref_tla_offroad";
OT_NATO_Vehicles_PoliceSupport = ["rhsgref_ins_uaz_dshkm","rhsgref_BRDM2_ins","rhsgref_ins_uaz_ags","RHS_Mi8mt_vdv"];
OT_NATO_Vehicles_ReconDrone = "rhs_pchela1t_vvsc";
OT_NATO_Vehicles_CASDrone = "O_UAV_02_F";
OT_NATO_Vehicles_AirSupport = ["RHS_Ka52_vvsc"];
OT_NATO_Vehicles_AirSupport_Small = ["O_Heli_Light_02_F"];
OT_NATO_Vehicles_GroundSupport = ["rhs_tigr_sts_3camo_msv","rhs_btr70_msv","rhs_tigr_sts_3camo_msv"];
OT_NATO_Vehicles_TankSupport = ["rhs_t90sm_tv","rhs_t72bd_tv"];
OT_NATO_Vehicles_Convoy = ["rhs_btr80a_msv","rhs_tigr_sts_msv","rhs_tigr_m_3camo_msv","rhs_tigr_m_3camo_msv","rhs_tigr_m_3camo_msv"];
OT_NATO_Vehicles_AirWingedSupport = ["RHS_Mi24V_vvsc"];
OT_NATO_Vehicle_AirTransport_Small = "O_Heli_Light_02_unarmed_F";
OT_NATO_Vehicle_AirTransport = ["RHS_Mi8mt_vv","O_Heli_Light_02_unarmed_F","O_Heli_Light_02_unarmed_F"];
OT_NATO_Vehicle_AirTransport_Large = "RHS_Mi8mt_vv";
OT_NATO_Vehicle_Boat_Small = "O_T_Boat_Armed_01_hmg_F";
OT_NATO_Vehicles_APC = ["rhs_bmp2k_msv","rhs_bmp1_msv"];

OT_NATO_Sandbag_Curved = "Land_BagFence_01_round_green_F";
OT_NATO_Barrier_Small = "Land_HBarrier_01_line_5_green_F";
OT_NATO_Barrier_Large = "Land_HBarrier_01_wall_6_green_F";

OT_NATO_Mortar = "rhs_2b14_82mm_msv";

OT_NATO_Vehicle_HVT = "O_mas_idf_SUV_01_F";

OT_NATO_Vehicle_CTRGTransport = "rhs_ka60_grey";

OT_NATO_weapons_Police = ["rhs_weap_M590D_8RD","rhs_weap_akms","rhs_weap_aks74un"];
OT_NATO_weapons_Pistols = ["rhs_weap_makarov_pm","rhs_weap_pya","rhs_weap_tt33","rhs_weap_cz99","rhs_weap_6p53"];

//Criminal stuff
OT_CRIM_Unit = "C_man_p_fugitive_F";
OT_CRIM_Clothes = ["U_I_C_Soldier_Bandit_3_F","U_BG_Guerilla3_1","U_C_HunterBody_grn","U_I_G_Story_Protagonist_F"];
OT_CRIM_Goggles = ["G_Balaclava_blk","G_Balaclava_combat","G_Balaclava_lowprofile","G_Balaclava_oli","G_Bandanna_blk","G_Bandanna_khk","G_Bandanna_oli","G_Bandanna_shades","G_Bandanna_sport","G_Bandanna_tan"];
OT_CRIM_Weapons = ["arifle_AK12_F","arifle_AKM_F","arifle_AKM_F","arifle_AKM_F"];
OT_CRIM_Pistols = ["hgun_Pistol_heavy_01_F","hgun_ACPC2_F","hgun_P07_F","hgun_Rook40_F"];
OT_CRIM_Launchers = ["launch_RPG32_F","launch_RPG7_F","launch_RPG7_F","launch_RPG7_F"];

OT_piers = ["Land_PierConcrete_01_4m_ladders_F","Land_PierWooden_01_platform_F","Land_PierWooden_01_hut_F","Land_PierWooden_02_hut_F"]; //spawns dudes that sell boats n stuff
OT_offices = ["Land_MultistoryBuilding_01_F","Land_MultistoryBuilding_04_F"];
OT_portBuildings = ["Land_Warehouse_01_F","Land_Warehouse_02_F","Land_ContainerLine_01_F","Land_ContainerLine_02_F","Land_ContainerLine_03_F"];
OT_airportTerminals = ["Land_Airport_01_terminal_F","Land_Airport_02_terminal_F","Land_Hangar_F","Land_TentHangar_V1_F"];
OT_portBuilding = "Land_WarehouseShelter_01_F";
OT_policeStation = "Land_Cargo_House_V3_F";
OT_warehouse = "Land_Warehouse_03_F";
OT_warehouses = [OT_warehouse,"Land_dp_smallFactory_F","Land_i_Shed_Ind_F"];
OT_barracks = "Land_Barracks_01_grey_F";
OT_workshopBuilding = "Land_Cargo_House_V4_F";
OT_refugeeCamp = "Land_Medevac_house_V1_F";
OT_trainingCamp = "Land_IRMaskingCover_02_F";
OT_hardwareStore = "Land_dp_smallFactory_F";
OT_radarBuilding = "Land_Radar_Small_F";
