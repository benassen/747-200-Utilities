require('LuaXML')
require("graphics")

DataRef( "SUN_PITCH", "sim/graphics/scenery/sun_pitch_degrees")
 

dofile(SCRIPT_DIRECTORY .."XYacl/XYacl-functions.lua")


interfaces = {} 
pilot_pov = {}      


local RECT_R = 0.1            -- Value Red of Box (0.0 to 1.0)
local RECT_G = 0.1            -- Value Green of Box (0.0 to 1.0)
local RECT_B = 0.1            -- Value Blue of Box (0.0 to 1.0)
local RECT_ALPHA = 0.1        -- Alpha of  (0.0 to 1.0)
local LINE_R = 0.0            -- Value Red of Line (0.0 to 1.0)
local LINE_G = 0.0            -- Value Green of  (0.0 to 1.0)
local LINE_B = 1.0            -- Value Blue of Line (0.0 to 1.0)
local MESSAGE_TIME = 5.0      -- Time for Displaying the Message in SECs




msg_to_display = {}
msg_to_display['title'] = nil
msg_to_display['lines'] = {}
msg_to_display['lines'][1]= nil 

DataRef( "UTC_SECONDS", "sim/time/zulu_time_sec")
--- Pilot Head
DataRef( "PILOT_HEAD_X", "sim/aircraft/view/acf_peX")
DataRef( "PILOT_HEAD_Y", "sim/aircraft/view/acf_peY")
DataRef( "PILOT_HEAD_Z", "sim/aircraft/view/acf_peZ")
--- DataRef( "PILOT_HEAD_PHI", "sim/graphics/view/pilots_head_phi")
DataRef( "PILOT_HEAD_PSI", "sim/graphics/view/pilots_head_psi")
DataRef( "PILOT_HEAD_THE", "sim/graphics/view/pilots_head_the")


DataRef( "POS_X", "sim/flightmodel/position/local_x")
DataRef( "POS_Y", "sim/flightmodel/position/local_y")
DataRef( "POS_Z", "sim/flightmodel/position/local_z")
--- 
logMsg("XYacl: Aircraft = "..AIRCRAFT_FILENAME )
logMsg("XYacl: ===========================================" )
--- logMsg("Position  X="..POS_X.." Y="..POS_Y.." Z="..POS_Z  )




 

load_interfaces () ; 





init_complete = 1
timer_utc = UTC_SECONDS

pilot_head_init = {} 
time_to = {}    -- time_to
enqueue = {}    -- 2 x array




---------------------------------------------------------------------------------
function check_and_do ( cl ) 
 
  if  (init_complete ~= 0 ) then --- Only if no C/L in course
   
  if ( cl == 'FE-INIT') then
    chocks = get ( interfaces['chocks']['dataref'] ) ;
    if (chocks == nil or chocks <= 1  ) then
       init_complete = 0
       add_schedule (-1, 'TITLE', 'Chocks must be set !! ') ; 
       add_schedule (10, 'END', ' --- ') 
       
    else
    
     
       
      init_complete = 0
      
      --- Read if DC is available
      --- add_schedule (0, 'dc_meter_sws', 'tr1') ; 
      --- add_schedule (3, 'dc_meter_sws', 'tr2') ; 
      --- add_schedule (3, 'dc_meter_sws', 'tr3') ; 
      
      add_schedule (-1, 'TITLE', 'FE Cockpit Safety Checks') ;
      add_schedule (0, 'POV', 'cons-1') ;
      add_schedule (3 , 'xpond', 'stdby')
      add_schedule (1, 'wx_radar', 'off')
      
      add_schedule (1, 'POV', 'FE-1') ; 
      add_schedule (3, 'galley_pwr', 'off') 
      add_schedule (3, 'air_pump', 'off') 
      add_schedule (3, 'stdby_power', 'off') ;
      ----
      add_schedule (0, 'apu_gen1_trip_sw', 'off') ;
      add_schedule (0, 'apu_gen2_trip_sw', 'off') ;
      add_schedule (0, 'apu_gen1_close_sw', 'off') ;
      add_schedule (0, 'apu_gen2_close_sw', 'off') ;
      
      add_schedule (3, 'END', 'FE Cockpit Safety Checks')
      
      
      end 
       
    elseif ( cl == 'POWER-UP') then
    ------------------------------------------------------
      is_gpu = get ( interfaces['AC1_conn']['dataref'] ) ; 
      if (is_gpu ~= nil and  is_gpu > 0   ) then
        
        init_complete = 0
        
        add_schedule (-1, 'TITLE', 'FE Establishing power with GPU') ;
        -----------------------------------------------
        add_schedule (0, 'POV', 'FE-elec') ; 
        add_schedule (2 , 'battery', 'on') ;
        add_schedule (1, 'battery_cap', 'close') ;
        add_schedule (3, 'aux_power_1', 'close') ;
        add_schedule (2, 'aux_power_2', 'close') ;
        add_schedule (3, 'stdby_power', 'manual') ;
        add_schedule (3, 'stdby_power', 'off') ;
        add_schedule (1, 'stdby_power', 'normal') ;
        
        
        -------------------------------------
        add_schedule (0, 'POV', 'FE-rovh') ; 
        add_schedule (3, 'radio_master_ess', 'on') ;
        add_schedule (2, 'radio_master_n2', 'on') ;
        add_schedule (2, 'nav_lights', 'on') ;
        
        add_schedule (2, 'logo_lights', 'on') ;
        
        add_schedule (0, 'POV', 'FE-insovh') ; 
        add_schedule (2, 'ins_1_ovh', 'stdby') ;
        add_schedule (1, 'ins_1_ovh', 'align') ;
        add_schedule (1, 'ins_2_ovh', 'stdby') ;
        add_schedule (1, 'ins_2_ovh', 'align') ;
        add_schedule (1, 'ins_3_ovh', 'stdby') ;
        add_schedule (1, 'ins_3_ovh', 'align') ;
        
        add_schedule (0, 'POV', 'FE-rovh') ; 
        add_schedule (2, 'no_smoking', 'on') ;
        add_schedule (1, 'fasten_belts', 'on') ;
        
        add_schedule (3, 'END' , 'POWER UP')
     else --- No GPU connected
        init_complete = 0
        add_schedule (-1, 'TITLE', 'Ask for GPU first !! ') ; 
        add_schedule (10, 'END', ' --- ')
        end 
     
   elseif ( cl == 'APU-START') then
    ------------------------------------------------------
    
      --- Check APU Batt
      apu_bat_volt = 24 
      if (apu_bat_volt ~= nil and  apu_bat_volt > 15   ) then
      
        ---- Start APU 
        init_complete = 0
        add_schedule (-1, 'TITLE', 'FE Start APU & pressurisation') ;
        add_schedule (0, 'POV', 'FE-APU') ; 
        add_schedule (2 , 'apu_start', 'on') ;
       
        add_schedule (1, 'apu_squib_test', 'on') ;
        add_schedule (1, 'apu_squib_test', 'off') ;
        
        add_schedule (1, 'apu_test_A', 'fire') ;
        add_schedule (1, 'apu_test_A', 'off') ;
        add_schedule (1, 'apu_test_A', 'fault') ;
        add_schedule (1, 'apu_test_A', 'off') ;
        
        add_schedule (1, 'apu_test_B', 'fire') ;
        add_schedule (1, 'apu_test_B', 'off') ;
        add_schedule (1, 'apu_test_B', 'fault') ;
        add_schedule (1, 'apu_test_B', 'off') ;
        
        add_schedule (1, 'apu_test_B', 'fire') ;
        add_schedule (0, 'apu_test_A', 'fire') ;
        add_schedule (1, 'apu_test_B', 'off') ;
        add_schedule (0, 'apu_test_A', 'off') ;
        add_schedule (1, 'apu_test_B', 'fault') ;
        add_schedule (0, 'apu_test_A', 'fault') ;
        add_schedule (1, 'apu_test_B', 'off') ;
        add_schedule (0, 'apu_test_A', 'off') ;
        
        
        add_schedule (1, 'apu_start', 'start') ;
        add_schedule (4, 'apu_start', 'on') ;
        
        add_schedule (15, 'apu_gen1_trip_sw', 'close') ;
        --- add_schedule (1, 'apu_gen1_trip_sw', 'off') ;
        add_schedule (1, 'apu_gen2_trip_sw', 'close') ;
        --- add_schedule (1, 'apu_gen2_trip_sw', 'off') ;
        
        add_schedule (5, 'apu_gen1_close_sw', 'close') ;
        add_schedule (2, 'aux_power_1', 'off') ;
        add_schedule (2, 'apu_gen2_close_sw', 'close') ;
        add_schedule (2, 'aux_power_2', 'off') ;
        -- add_schedule (1, 'apu_gen2_close_sw', 'off') ;
        
        
        --- Now we have power !
        if (SUN_PITCH < 0 ) then
           add_schedule (1, 'light_front_panel', 0.5 ) ;
           add_schedule (0, 'light_front_left_big_panel', 0.5 ) ;
           add_schedule (0, 'light_front_left_panel', 0.5 ) ;
           add_schedule (0, 'light_main_panel_bkgr', 0.5 ) ;
           add_schedule (0, 'light_dome', 1 ) ;
           add_schedule (0, 'light_control_stand_panel', 0.5 ) ;
           add_schedule (0, 'light_center_fwd_panel', 0.5 ) ;
           add_schedule (0, 'light_FE_panel', 0.5 ) ;
           add_schedule (0, 'light_FE_panel_bkgrd', 0.5 ) ;
           add_schedule (0, 'light_FE_panel_map', 0.5 ) ;
           end 
        
        
        --- Galley
        add_schedule (2, 'galley_pwr', 'on', 1) 
        add_schedule (1, 'galley_pwr', 'on', 2) 
        add_schedule (1, 'galley_pwr', 'on', 3) 
        add_schedule (1, 'galley_pwr', 'on', 4) 
        -- 
        
        add_schedule (0, 'galley_control_gen', 'norm' )
        add_schedule (1, 'galley_control_fan', 'auto' )
        
        add_schedule (1, 'galley_chiller', 'on', 1 ) 
        add_schedule (1, 'galley_chiller', 'on', 2 )
        add_schedule (1, 'galley_chiller', 'on', 3 )
        
        -- air valves
        add_schedule (2, 'air_valves', 'close' )
        add_schedule (0, 'pack_valves', 'close' )
        add_schedule (0, 'isolation_valves', 'close' )
        
        add_schedule (1, 'apu_bleed_air', 'open' )
        
        add_schedule (2, 'POV', 'FE-PACK') ; 
        add_schedule (1, 'isolation_valves', 'open', 1  )
        add_schedule (4, 'isolation_valves', 'open', 2  )
        
        
        
        
        add_schedule (4, 'pack_controls', 'auto' )
        
        add_schedule (2, 'pack_meters', 'pack1' ) ;
        add_schedule (1, 'pack_valves', 'open', 1 )
        add_schedule (8, 'pack_meters', 'pack2' ) ;
        add_schedule (1, 'pack_valves', 'open', 2 )
        add_schedule (8, 'pack_meters', 'pack3' ) ;
        add_schedule (1, 'pack_valves', 'open', 3 )
        
        
        add_schedule (8, 'pack_controls', 'auto')
        
        add_schedule (1, 'recirculating_fans', 'on', 2 ) 
        add_schedule (1, 'recirculating_fans', 'on', 3 ) 
        add_schedule (1, 'recirculating_fans', 'on', 4 ) 
        add_schedule (1, 'gasper', 'on')
       
        
        add_schedule (1, 'trim_air', 'open')
        add_schedule (1, 'heat_mode', -30 , 1)
        add_schedule (1, 'heat_mode', -30 , 2)
        add_schedule (1, 'heat_mode', -30 , 3)
        add_schedule (1, 'heat_mode', -30 , 4)
        add_schedule (1, 'heat_mode', -30 , 5)
        
        add_schedule (3, 'END' , 'APU STARTED & PACKS CONFIG')
     else --- No APU BAT voltage
        init_complete = 0
        add_schedule (-1, 'TITLE', 'Insufficient APU battery voltage  !! ') ; 
        add_schedule (3, 'END', ' --- ')
        
        end 
      
      
   elseif ( cl == 'OVERHEAD-CHK') then 
      ------------------------------------------------------ 
      --- Read INS1 status
      set ( interfaces['ins_1_mode']['dataref'], interfaces['ins_1_mode']['values']['dsrtk/sts'] ) ; 
      ins1sts = get ( interfaces['ins_1_right_txt']['dataref'] ) ;
      if (string.len(ins1sts)>4) then 
         sts = tonumber(string.sub(ins1sts, 5, 5)) 
         end
         
      --- 8 or below on the INS before anythings on the overhead
      if (sts ~= nil and  sts <= 8  ) then
        init_complete = 0
        
        
        
        add_schedule (-1, 'TITLE', 'FE Overhead checks') ; 
        
        add_schedule (0, 'POV', 'FE-OVH-H') ;
        add_schedule (1, 'window_heat_power_lights', 'on') ; 
        add_schedule (1, 'window_heat_sw_2L', 'on') ; 
        add_schedule (1, 'window_heat_sw_1L', 'on') ;
        add_schedule (1, 'window_heat_sw_1R', 'on') ;
        add_schedule (1, 'window_heat_sw_2R', 'on') ;
        add_schedule (8, 'window_heat_gard', 'off') ;
        add_schedule (1, 'window_heat_sw_1R', 'ovrd') ;
        add_schedule (1, 'window_heat_sw_1L', 'ovrd') ;
        add_schedule (1, 'window_heat_sw_1R', 'on') ;
        add_schedule (1, 'window_heat_sw_1L', 'on') ;
        add_schedule (1, 'window_heat_gard', 'on') ;
        add_schedule (3, 'window_heat_power_lights', 'off') ; 
        
        
        --- heat probe tests 
        add_schedule (3, 'probe_heater_L', 'test') ;
        add_schedule (1, 'probe_heater_L', 'on') ;
        add_schedule (2, 'probe_heater_L', 'off') ;
        add_schedule (1, 'probe_heater_R', 'test') ;
        add_schedule (1, 'probe_heater_R', 'on') ;
        add_schedule (1, 'probe_heater_R', 'off') ;
        
        add_schedule (0, 'POV', 'FE-rovh') ;
        add_schedule (3, 'mach_test', 'test') ;
        add_schedule (1, 'mach_test', 'normal') ;
        add_schedule (1, 'overrot_test', 'test') ;
        add_schedule (1, 'overrot_test', 'normal') ;
        add_schedule (1, 'stall_warning', 'test') ;
        add_schedule (1, 'stall_warning', 'normal') ;
        
        add_schedule (0, 'POV', 'FE-ovh') ;
        add_schedule (1, 'compass_mode', 'slave', 1 ) ;
        add_schedule (1, 'alt_flaps_le', 'off', 1 ) ;
        add_schedule (0, 'alt_flaps_le', 'off', 1 ) ;
        add_schedule (0, 'alt_flaps_te_inbd', 'off') ;
        add_schedule (0, 'alt_flaps_te_outbd', 'off' ) ;
        
        add_schedule (1, 'deck_door', 'close' ) ;
        add_schedule (1, 'emerg_lights_cap', 'open' ) ;
        add_schedule (0, 'emerg_lights_sw', 'on' ) ;
        add_schedule (1, 'emerg_lights_sw', 'armed' ) ;
        add_schedule (1, 'emerg_lights_cap', 'close' ) ;
 
        add_schedule (1, 'cvr_test', 'push' ) ;
        add_schedule (4, 'cvr_test', 'release' ) ;
        
        
        add_schedule (1, 'wheel_fire_test', 'push' ) ;
        add_schedule (1, 'wheel_fire_test', 'release' ) ;
        
        add_schedule (1, 'compass_mode', 'slave', 2 ) ;
        
        add_schedule (2, 'body_gr_steer_cap', 'open' ) ;
        add_schedule (2, 'body_gr_steer_sw', 'arm' ) ;
        
        add_schedule (1, 'anti_skid_sw', 'on' ) ;
        add_schedule (2, 'anti_skid_cap', 'close' ) ;
        
        --- 
        add_schedule (1, 'TITLE', 'END of FE Overhead checks') ;   
        add_schedule (3, 'END', cl..' end ')
         
        
      else
        init_complete = 0
        add_schedule (-1, 'TITLE', 'INS alignment first !!! ') ; 
        add_schedule (3, 'END', ' --- ')
         
        end 
      
      
     elseif ( cl == 'FE-CHECKS') then 
      ------------------------------------------------------ 
       
        init_complete = 0
        add_schedule (-1, 'TITLE', 'FE Panel checks') ; 
        add_schedule (0, 'POV', 'FE-FIRE') ; 
        
        add_schedule (2, 'squib_test_sw', 'rightbottle') ; 
        add_schedule (1, 'squib_test_sw', 'leftbottle') ; 
        add_schedule (1, 'squib_test_sw', 'off') ; 
        
        add_schedule (2, 'fire_detectA_sw', 'firetest') ; 
        add_schedule (1, 'fire_detectA_sw', 'off') ;
        add_schedule (1, 'fire_detectB_sw', 'firetest') ;
        add_schedule (1, 'fire_detectB_sw', 'off') ; 
        add_schedule (1, 'fire_detect_sw', 'firetest') ;
        add_schedule (1, 'fire_detect_sw', 'off') ;
        
        add_schedule (1, 'fire_detectA_sw', 'faulttest') ; 
        add_schedule (1, 'fire_detectA_sw', 'off') ;
        add_schedule (1, 'fire_detectB_sw', 'faulttest') ;
        add_schedule (1, 'fire_detectB_sw', 'off') ; 
        add_schedule (1, 'fire_detect_sw', 'faulttest') ;
        add_schedule (1, 'fire_detect_sw', 'off') ;    
        
        add_schedule (0, 'nacelle_temp_sw', 'both') ; 
        
        add_schedule (1, 'aft_cargo_heat_sw', 'test') ;  
        add_schedule (1, 'aft_cargo_heat_sw', 'off') ; 
        
        add_schedule (1, 'lower_cargo_heatA_sw', 'test') ;  
        add_schedule (1, 'lower_cargo_heatA_sw', 'off') ;    
        add_schedule (1, 'lower_cargo_heatB_sw', 'test') ;  
        add_schedule (1, 'lower_cargo_heatB_sw', 'off') ; 
        add_schedule (1, 'lower_cargo_heat_both_sw', 'test') ;  
        add_schedule (1, 'lower_cargo_heat_both_sw', 'off') ;
        
        add_schedule (1, 'wing_LE_overheat_test', 'sys2') ;
        add_schedule (1, 'wing_LE_overheat_test', 'sys1') ;
        add_schedule (1, 'wing_LE_overheat_test', 'off') ;
        add_schedule (0, 'wing_LE_overheat_L', 'both') ;
        add_schedule (0, 'wing_LE_overheat_R', 'both') ;
        
        add_schedule (1, 'POV', 'FE-FIRE2') ;
        
        add_schedule (1, 'brake_temp_sw', 'LF' ) ;
        add_schedule (1, 'brake_temp_test', 'on' ) ;
        add_schedule (1, 'brake_temp_sw', 'RF' ) ;
        add_schedule (1, 'brake_temp_sw', 'LR' ) ;
        add_schedule (1, 'brake_temp_sw', 'RR' ) ;
        add_schedule (1, 'brake_temp_test', 'off' ) ;
        add_schedule (1, 'brake_temp_sw', 'LF' ) ;
        add_schedule (1, 'brake_temp_sw', 'RF' ) ;
        add_schedule (1, 'brake_temp_sw', 'LR' ) ;
        add_schedule (1, 'brake_temp_sw', 'RR' ) ;
        add_schedule (1, 'brake_temp_sw', 0 ) ;
        
        add_schedule (1, 'EFDARS_lamp_test', 'on' ) ; 
        add_schedule (1, 'EFDARS_lamp_test', 'off' ) ; 
        
        add_schedule (1, 'askid_lamp_test', 'prim' ) ;
        add_schedule (1, 'askid_lamp_test', 'off' ) ; 
        add_schedule (1, 'askid_lamp_test', 'alt' ) ; 
        add_schedule (1, 'askid_lamp_test', 'off' ) ;
        
        add_schedule (1, 'landing_gear_sw', 'gearprim' ) ; 
        add_schedule (1, 'landing_gear_sw', 'gearalt' ) ;
        add_schedule (1, 'landing_gear_sw', 'tiltprim' ) ;
        add_schedule (1, 'landing_gear_sw', 'tiltalt' ) ;
        add_schedule (1, 'landing_gear_sw', 'doorprim' ) ;
        add_schedule (1, 'landing_gear_sw', 'dooralt' ) ;
        add_schedule (1, 'landing_gear_sw', 0 ) ;
        
        add_schedule (1, 'water_gau_butt', 'read' ) ; 
        add_schedule (2, 'water_gau_butt', 'off' ) ; 
        
        --- Fuel
        add_schedule (1, 'POV', 'FE-FUEL') ;
        add_schedule (1, 'gages_test_butt', 'test' ) ; 
        add_schedule (3, 'gages_test_butt', 'off' ) ; 
        
        add_schedule (1, 'reset_fuel', 'reset' ) ; 
        add_schedule (1, 'reset_fuel', 'off' ) ; 
        
        add_schedule (1, 'fuel_heat_sw', 'on' , 1 ) ; 
        add_schedule (1, 'fuel_heat_sw', 'off', 1 ) ;
        add_schedule (1, 'fuel_heat_sw', 'on' , 2 ) ; 
        add_schedule (1, 'fuel_heat_sw', 'off', 2 ) ;
        add_schedule (1, 'fuel_heat_sw', 'on' , 3 ) ; 
        add_schedule (1, 'fuel_heat_sw', 'off', 3 ) ;
        add_schedule (1, 'fuel_heat_sw', 'on' , 4 ) ; 
        add_schedule (1, 'fuel_heat_sw', 'off', 4 ) ;
        
        --- Crosfeed valves
        add_schedule (1, 'fuel_crossfeed_valves', 'open', 5 ) ; 
        add_schedule (2, 'fuel_crossfeed_valves', 'close', 5 ) ; 
        
        add_schedule (1, 'fuel_crossfeed_valves', 'close', 1) ; 
        add_schedule (2, 'fuel_crossfeed_valves', 'open', 1 ) ;
        
        add_schedule (1, 'fuel_crossfeed_valves', 'open', 2 ) ; 
        add_schedule (2, 'fuel_crossfeed_valves', 'close', 2 ) ; 
        
        add_schedule (1, 'fuel_crossfeed_valves', 'open', 3 ) ; 
        add_schedule (2, 'fuel_crossfeed_valves', 'close', 3 ) ; 
        
        add_schedule (1, 'fuel_crossfeed_valves', 'close', 4) ; 
        add_schedule (2, 'fuel_crossfeed_valves', 'open', 4 ) ;
        
        add_schedule (1, 'fuel_crossfeed_valves', 'open', 6 ) ; 
        add_schedule (2, 'fuel_crossfeed_valves', 'close', 6 ) ; 
        
        add_schedule (1, 'fuel_boost_pump', 'on', 1 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 3 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 5 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 7 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 9 ) ;
        
        add_schedule (1, 'fuel_boost_pump', 'off', 1 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 2 ) ;
        add_schedule (1, 'fuel_boost_pump', 'off', 3 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 4 ) ;
        add_schedule (1, 'fuel_boost_pump', 'off', 5 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 6) ;
        add_schedule (1, 'fuel_boost_pump', 'off', 7 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 8 ) ;
        add_schedule (1, 'fuel_boost_pump', 'off', 9 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 10 ) ;
        
        add_schedule (1, 'fuel_boost_pump', 'on', 1 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 3 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 5 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 7 ) ;
        add_schedule (1, 'fuel_boost_pump', 'on', 9 ) ;
        
        --- hydraulics
        add_schedule (1, 'POV', 'FE-HYD') ;
        
        add_schedule (1, 'hyd_qty_check', 'test' ) ; 
        add_schedule (2, 'hyd_qty_check', 'off' ) ;
        
        add_schedule (1, 'air_pump_sw', 'off' ) ;
        --  
        --- 
        add_schedule (3, 'TITLE', 'END of FE panel checks') ;   
        add_schedule (5, 'END', cl..' end ')
   
     elseif ( cl == 'FE-BEF-START') then 
      ------------------------------------------------------ 
       
        init_complete = 0
        add_schedule (-1, 'TITLE', 'FE checks before Start') ; 
        add_schedule (0, 'POV', 'FE-PACK') ; 
        add_schedule (2, 'pack_valves', 'close', 2 ) 
        
        add_schedule (2, 'pack_valves', 'close', 2 )
        add_schedule (0, 'POV', 'FE-HYD') ; 
        add_schedule (1, 'air_pump_sw', 'auto' , 1  ) ;
        add_schedule (1, 'elect_pump_cap', 'open' ) ;
        add_schedule (1, 'elect_pump4', 'on' ) ;
        
        add_schedule (1, 'air_valves', 'open' , 1 )
        add_schedule (1, 'air_valves', 'open' , 2 )
        add_schedule (1, 'air_valves', 'open' , 3 )
        add_schedule (1, 'air_valves', 'open' , 4 )
        
        --- 
        add_schedule (3, 'TITLE', 'END of checks') ;   
        add_schedule (5, 'END', cl..' end ')
        
     elseif ( cl == 'FE-START-ENG') then 
      ------------------------------------------------------ 
       
        init_complete = 0
        add_schedule (-1, 'TITLE', 'FE Starting engines') ; 
        -- Checks if INS are on NAV mode (to be done)
        
        -- Double check fuel pumps 
        add_schedule (2, 'fuel_boost_pump', 'on' ) 
        -- Double check seat belts
        add_schedule (0, 'no_smoking', 'on') ;
        add_schedule (0, 'fasten_belts', 'on') ; 
        
        -- Double check
        add_schedule (0, 'body_gr_steer_cap', 'open' ) ;
        add_schedule (1, 'body_gr_steer_sw', 'arm' ) ;
        
        -- Beacon on
        add_schedule (1, 'beacon', 'on' ) ;
        
        add_schedule (2, 'pack_valves', 'close', 3 ) 
        add_schedule (1, 'galley_pwr', 'off', 1 ) 
        add_schedule (1, 'galley_pwr', 'off', 2 ) 
        add_schedule (1, 'galley_pwr', 'off', 3 ) 
        add_schedule (1, 'galley_pwr', 'off', 4 )
        
        add_schedule (3 , 'xpond', 'xpdr') 
        add_schedule (2, 'pack_valves', 'close', 1 )
        add_schedule (2, 'start_valve_cap', 'open' ) 
        add_schedule (1, 'start_valve_sw', 'on' ) 
        
        
        -- TODO after N2 monitoring
        add_schedule (1, 'engine_ignition_1', 'gndstart' , 4  ) 
        add_schedule (20, 'fuel_cut_off_4', 'idle')  
        
        add_schedule (10, 'engine_ignition_1', 'gndstart' , 1  ) 
        add_schedule (20, 'fuel_cut_off_1', 'idle')
        add_schedule (10, 'engine_ignition_1', 'gndstart' , 2  ) 
        add_schedule (20, 'fuel_cut_off_2', 'idle')
        add_schedule (10, 'engine_ignition_1', 'gndstart' , 3  ) 
        add_schedule (20, 'fuel_cut_off_3', 'idle')
        
        add_schedule (1, 'start_valve_sw', 'off' )
        add_schedule (2, 'start_valve_cap', 'close' )  
        add_schedule (0, 'engine_ignition_1', 'off'  ) 
        add_schedule (0, 'engine_ignition_2', 'off'  ) 
        
        
        add_schedule (1, 'probe_heater_L', 'on') ;
        add_schedule (1, 'probe_heater_R', 'on') ;
        
        add_schedule (1, 'apu_bleed_air', 'close' )
        
        --- TODO gen voltage checks
        add_schedule (1, 'bus_gen_close', 'close' , 4  ) 
        add_schedule (2, 'bus_gen_close', 'close' , 1  )
        add_schedule (2, 'bus_gen_close', 'close' , 2  )
        add_schedule (2, 'bus_gen_close', 'close' , 3  )
        
        add_schedule (2, 'apu_split', 'close'   )
        add_schedule (2, 'apu_split', 'off'   )
        
        add_schedule (1, 'galley_pwr', 'on', 1 ) 
        add_schedule (1, 'galley_pwr', 'on', 2 ) 
        add_schedule (1, 'galley_pwr', 'on', 3 ) 
        add_schedule (1, 'galley_pwr', 'on', 4 )
        
        add_schedule (2, 'pack_valves', 'open', 1 )
        add_schedule (1, 'pack_valves', 'open', 2 )
        add_schedule (1, 'pack_valves', 'open', 3 )
       
        add_schedule (1, 'air_pump_sw', 'auto' , 1  ) ;
        add_schedule (1, 'air_pump_sw', 'auto' , 2  )
        add_schedule (1, 'air_pump_sw', 'auto' , 3  )
        add_schedule (1, 'air_pump_sw', 'auto' , 4  )
        
        add_schedule (1, 'elect_pump4', 'off' ) ;
        add_schedule (1, 'elect_pump_cap', 'close' ) ;
        add_schedule (1, 'aft_cargo_heat_sw', 'on') ; 
        
        add_schedule (2, 'apu_start', 'off'   )
        
        
        
        --- 
        add_schedule (3, 'TITLE', 'Engines started,') ;   
        add_schedule (5, 'END', cl..' end ')
     
     end   
     
    
    pilot_head_init['X'] = PILOT_HEAD_X
    pilot_head_init['Y'] = PILOT_HEAD_Y
    pilot_head_init['Z'] = PILOT_HEAD_Z
    pilot_head_init['PSI'] = PILOT_HEAD_PSI
    pilot_head_init['THE'] = PILOT_HEAD_THE
    
 else 
    logMsg("XYacl: !!! There is allready a C/L in progress ") 
    end
    
 end  





if (AIRCRAFT_FILENAME == "B742_PW_Felis.acf" ) then

  do_often("monitor_cl()") 
  do_every_draw("print_msg ()")
  
  add_macro("747-200-1 FE Cockpit Safety check", "check_and_do('FE-INIT')" ) 
  add_macro("747-200-2 FE Establishing power with GPU", "check_and_do('POWER-UP')" )
  add_macro("747-200-3 FE Overhead Check", "check_and_do('OVERHEAD-CHK')" )
  add_macro("747-200-4 FE Start APU & pressurisation", "check_and_do('APU-START')" )
  add_macro("747-200-5 FE Panel checks", "check_and_do('FE-CHECKS')" )
  add_macro("747-200-6 FE Before Start", "check_and_do('FE-BEF-START')" )
  add_macro("747-200-7 FE Starting engines", "check_and_do('FE-START-ENG')" )
  
  
  
  end
