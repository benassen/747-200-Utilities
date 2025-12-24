require('LuaXML')
require("graphics")


if (AIRCRAFT_FILENAME == "B742_PW_Felis.acf" ) then
----------------------------------------------------------------------------------------------------
-- Missing datarefs
--- FE altimeter (or cabin altitude) setting
--- B742/INT_EPRL/EPRL_decr (present in doc but not in v1.0.3) 
--- Fuel used gauges X 4
--  APU Hourmeter
--  chronometers X 3

--- Speedbrake is controled by device axis, no save/restore
-- 
--  TODO 
--   INSs data should be deleted when the IRS selector is set to “OFF”
----------------------------------------------------------------------------------------------------
DataRef( "SUN_PITCH", "sim/graphics/scenery/sun_pitch_degrees")
 

dofile(SCRIPT_DIRECTORY .."742vfe/742vfe-functions.lua")


interfaces = {} 
pilot_pov = {}  
check_lists = {}     

active_panel = 1 ; 

flag_debug = true
flag_checks = true

was_over_10k = false
was_airborne_flag = false 

vfe_wnd = nil
 



 
SaveDir = SYSTEM_DIRECTORY.."Output/situations/" ; 
ValidatedSaveDir = SaveDir ;
DirIsWritable = false 

load_742_config ()  
--- ValidatedSaveDir 
print_debug ("START of Symphony execution") 
print_debug(" ===========================================" )

TmpSaveDir = ValidatedSaveDir ; 
CurrentSaveNam="TEST" ; 
FutureSaveNam = nil 
FutureNb = nil
FutureTi = nil 

CurrentAutoSaveSaveNam = '742-AUTO-SAVE-'
ActiveAutoSave = {} 
LastAutoSaveTs = nil 
LastAutoSaveNum = nil

CurrentSavePage= 1 
NbSavePerPage = 20 
NbCockpitSaves = 0 

CockpitSaves = {} 
ActiveCockpitSave = {} 
sizeimmediate = 0 
CockpitSavesAreas = {}
SelectedSave = nil  

--- SaveDir = "DD" ;   
-- 
instrument_warn_l = nil
instrument_warn_r = nil 

meters_above_ground = nil
feet_above_ground = nil


msg_to_display = {}
msg_to_display['title'] = nil
msg_to_display['lines'] = {}
msg_to_display['lines'][1]= nil 

DataRef( "UTC_SECONDS", "sim/time/zulu_time_sec")
DataRef( "DAY_IN_YEAR", "sim/time/local_date_days") 

b742_day_stamp = DAY_IN_YEAR ; 
b742_time_stamp = UTC_SECONDS ;
b742_time_start = UTC_SECONDS ;


--- Pilot Head
DataRef( "PILOT_HEAD_X", "sim/aircraft/view/acf_peX")
DataRef( "PILOT_HEAD_Y", "sim/aircraft/view/acf_peY")
DataRef( "PILOT_HEAD_Z", "sim/aircraft/view/acf_peZ")
--- DataRef( "PILOT_HEAD_PHI", "sim/graphics/view/pilots_head_phi")
DataRef( "PILOT_HEAD_PSI", "sim/graphics/view/pilots_head_psi")
DataRef( "PILOT_HEAD_THE", "sim/graphics/view/pilots_head_the")

DataRef( "VR_ENABLED", "sim/graphics/VR/enabled")
if ( VR_ENABLED and VR_ENABLED > 0 ) then flag_move_pov = false 
else flag_move_pov = true end 

flag_auto_save = false
FutureNb = 5 -- 5 autosave
FutureTi = 5 -- every 5 minutes
flag_all_cl = false 
timer_1 = 0.8
timer_2 = 1.5 


DataRef( "POS_X", "sim/flightmodel/position/local_x")
DataRef( "POS_Y", "sim/flightmodel/position/local_y")
DataRef( "POS_Z", "sim/flightmodel/position/local_z")
--- 
local Aircraft = AIRCRAFT_FILENAME 
print_debug(Aircraft..' ('..PLANE_TAILNUMBER..')' )
print_debug(" ===========================================" )

timer_utc = UTC_SECONDS

-- Display VFE windows
create_vfe_wnd()

--- Load interfaces array from xml
load_interfaces () ; 

--- Load user prefs
load_742_config () 

--- Scan for saves and compare to present 
timer_backup = nil 
if (ValidatedSaveDir) then 
   tableSav = directory_to_table( ValidatedSaveDir )
   for i,cockpitSav in ipairs(tableSav) do
        if (string.sub(cockpitSav, -5 ) == '.b742' ) then 
           local CkSaveName=string.sub(cockpitSav, 1, -6) 
           local CkSavInfos = {}  
           load_742_cockpit_info (ValidatedSaveDir..'/'..cockpitSav, CkSavInfos ) 
           if ( CkSavInfos['is_ok']) then 
              activate_menu(3) 
              sizeimmediate = sizeimmediate + 1 
              ActiveCockpitSave[CkSaveName] = true 
              timer_backup = UTC_SECONDS
              end 
           end 
        end 
   end

current_cl_num = 0
cl_act_end = nil 





pilot_head_init = {} 
time_to = {}    -- time_to
enqueue = {}    -- 2 x array



check_lists = {}
icl=1 
cl_fe_init = icl
check_lists[icl]             = { ['code'] = 'FE-INIT' , ['title'] = 'Cockpit Safety check' , ['active']=true  }  
icl=icl+1 
cl_power_ext = icl 
check_lists[cl_power_ext]    = { ['code'] = 'POWER-UP' , ['title'] = 'Powering with EXT power', ['active']=true }
icl=icl+1
cl_power_apu = icl
check_lists[cl_power_apu]    = { ['code'] = 'FE-APU-START' ,  ['title'] = 'Powering with APU', ['active']=true } 
icl=icl+1
cl_ovh_checks = icl
check_lists[icl]             = { ['code'] = 'OVERHEAD-CHK' , ['title'] = 'Overhead Check', ['active']=true } 
--[[   INS init on the EFB
icl=icl+1
cl_ins_init_pos = icl
check_lists[icl]             = { ['code'] = 'INS-INIT-POS' , ['title'] = 'INS initial POS' , ['active']=true} 
 ]] 
icl=icl+1
cl_apu_pressure = icl
check_lists[icl]             = { ['code'] = 'APU-START' , ['title'] = 'Start APU & pressurisation' , ['active']=true} 
icl=icl+1
cl_panel_check = icl 
check_lists[icl]             = { ['code'] = 'FE-CHECKS' ,['title'] = 'FE Panel checks', ['active']=true } 
icl=icl+1
cl_before_start = icl
check_lists[icl]             = { ['code'] = 'FE-BEF-START' ,['title'] = 'Before Start' , ['active']=true} 
icl=icl+1
cl_start_all = icl
check_lists[icl]             = { ['code'] = 'FE-START-ENG' ,  ['title'] = 'Start engines' , ['active']=true} 
icl=icl+1
cl_taxi = icl
check_lists[icl]             = { ['code'] = 'FE-TAXI' ,  ['title'] = 'Taxi' , ['active']=true} 
icl=icl+1
cl_before_to = icl
check_lists[icl]             = { ['code'] = 'FE-BEFORE-TO' ,  ['title'] = 'Before takeoff' , ['active']=true} 

icl=icl+1
cl_after_to = icl
check_lists[icl]             = { ['code'] = 'FE-AFTER-TO' ,  ['title'] = 'After takeoff' , ['active']=true} 

icl=icl+1
cl_climb_10000 = icl
check_lists[icl]             = { ['code'] = 'CLIMB-10000' ,  ['title'] = 'Passing > 10.000 ' , ['active']=true} 

icl=icl+1
cl_descent_10000 = icl
check_lists[icl]             = { ['code'] = 'DESCENT-10000' ,  ['title'] = 'Passing < 10.000 ' , ['active']=true} 

icl=icl+1
cl_taxi_after_ld = icl
check_lists[icl]             = { ['code'] = 'TAXI-AFTER-LDG' ,  ['title'] = 'Taxi after landing ' , ['active']=true} 
icl=icl+1
cl_parked = icl
check_lists[icl]             = { ['code'] = 'PARKING' ,  ['title'] = 'Parking' , ['active']=true} 

icl=icl+1
cl_end_flight = icl
check_lists[icl]             = { ['code'] = 'END-FLIGHT' ,  ['title'] = 'Flight Termination' , ['active']=true} 





---------------------------------------------------------------------------------
function check_and_do ( cl_num ) 
  
  if  (current_cl_num == 0 ) then --- Only if no C/L in course   // ~=
  
  cl = check_lists[cl_num]['code'] 
   
  
  print_debug("current cl = "..cl_num.." ["..cl.."] "  )
   
  if ( cl == 'FE-INIT') then
       current_cl_num = cl_num 
 
      add_schedule (-1 , 'POV', 'cons-1') ;
      add_schedule (timer_1 , 'xpond', 'stdby')
      add_schedule (timer_1, 'wx_radar', 'off')
      
      add_schedule (3, 'POV', 'cons-2') ;
      add_schedule (timer_1, 'throttle_ratio_all', 0) 
      add_schedule (timer_1, 'fuel_cut_off_1', 'cutoff') 
      add_schedule (0, 'fuel_cut_off_2', 'cutoff') 
      add_schedule (0, 'fuel_cut_off_3', 'cutoff') 
      add_schedule (0, 'fuel_cut_off_4', 'cutoff') 
      --- gear handle to OFF
      add_schedule (0, 'MSG', 'GEAR LEVER DOWN') ;
      add_schedule (0, 'gear_lever', 'dn' ) 
      
      add_schedule (3, 'POV', 'FE-ovh') 
      -- Alternate flap switches
      add_schedule (timer_1, 'MSG', 'ALTERNATE FLAPS OFF' )
      add_schedule (timer_1, 'alt_flaps_te_outbd', 'off' ) 
      add_schedule (0, 'alt_flaps_te_inbd', 'off' ) 
      add_schedule (0, 'alt_flaps_le', 'off' )    
      
      -- Eng ignition
      add_schedule (0, 'MSG', 'ENGINE IGNITION OFF' )
      add_schedule (timer_1, 'engine_ignition_1', 'off' ) 
      add_schedule (0, 'engine_ignition_2', 'off' ) 
      

      
      add_schedule (3, 'POV', 'FE-1') ; 
      add_schedule (timer_1, 'galley_pwr', 'off') 
      add_schedule (timer_1, 'air_pump', 'off') 
      add_schedule (timer_2, 'stdby_power', 'off') ;
      ----
      add_schedule (0, 'apu_gen1_trip_sw', 'off') ;
      add_schedule (0, 'apu_gen2_trip_sw', 'off') ;
      add_schedule (0, 'apu_gen1_close_sw', 'off') ;
      add_schedule (0, 'apu_gen2_close_sw', 'off') ;
      
      add_schedule (timer_1, 'MSG', 'AIR DRIVEN HYD PUMPS OFF' )
      add_schedule (timer_2, 'air_pump_sw', 'off' )
      

      
      
      add_schedule (0, 'OK') ;
      add_schedule (5, 'END', 'FE Cockpit Safety Checks')
      
   
       
    elseif ( cl == 'POWER-UP') then
    ------------------------------------------------------
      is_gpu = get ( interfaces['AC1_conn']['dataref'] ) ;
      current_cl_num = cl_num 
      if (is_gpu ~= nil and  is_gpu > 0   ) then
        
        
        
        --- add_schedule (-1, 'TITLE', 'FE Establishing power with GPU') ;
        -----------------------------------------------
        add_schedule (-2 , 'POV', 'FE-elec') ; 
        add_schedule (2 , 'battery', 'on') ;
        add_schedule (timer_2, 'battery_cap', 'close') ;
        add_schedule (3, 'aux_power_1', 'close') ;
        add_schedule (2, 'aux_power_2', 'close') ;
        
        
        
        
        enq_ess_elect () 
        
        add_schedule (3, 'END' , 'POWER UP')
        
        
        
     else --- No GPU connected
    
        add_schedule (-1, 'ERROR', 'External power must be available ') ; 
        add_schedule (5, 'END', ' --- ')
        
       end 
  
   
   elseif ( cl == 'INS-INIT-POS') then
   ------------------------------------------------------
      current_cl_num = cl_num
      add_schedule (-1 , 'POV', 'cons-2') ; 
      add_schedule (0 , 'ins1_pos_lat', get ("sim/flightmodel/position/latitude") ) ; 
      add_schedule (0 , 'ins1_pos_lon', get ("sim/flightmodel/position/longitude") ) ; 
      add_schedule (0 , 'ins2_pos_lat', get ("sim/flightmodel/position/latitude") ) ; 
      add_schedule (0 , 'ins2_pos_lon', get ("sim/flightmodel/position/longitude") ) ; 
      add_schedule (0 , 'ins3_pos_lat', get ("sim/flightmodel/position/latitude") ) ; 
      add_schedule (0 , 'ins3_pos_lon', get ("sim/flightmodel/position/longitude") ) ; 
      add_schedule (0, 'OK') ;
      add_schedule (3, 'END' , 'INS POS')  
      
  
   
   elseif ( cl == 'FE-APU-START') then
    ------------------------------------------------------
      current_cl_num = cl_num
      
        add_schedule (-1 , 'POV', 'FE-elec') ; 
        add_schedule (2 , 'battery', 'on') ;
        add_schedule (timer_2, 'battery_cap', 'close') ;
      
        ---- Powering with APU 
        add_schedule (2 , 'POV', 'FE-APU') ; 
        
        enq_apu_start () 
        
        add_schedule (1, 'apu_gen1_trip_sw', 'close') ;
        add_schedule (1, 'apu_gen1_close_sw', 'close') ;
        add_schedule (1, 'apu_gen2_trip_sw', 'close') ;
        add_schedule (2, 'apu_gen2_close_sw', 'close') ;
        
        enq_ess_elect () 
        
        enq_powering () 
        enq_press_from_apu () 
        if (cl_power_ext) then add_schedule (0, 'OK', cl_power_ext ) end  
        if (cl_apu_pressure) then add_schedule (0, 'OK', cl_apu_pressure ) end 
        add_schedule (0, 'OK' )
        add_schedule (3, 'END' , 'APU started') 
      
     
   elseif ( cl == 'APU-START') then
    ------------------------------------------------------
      current_cl_num = cl_num
      
        ---- Start APU 
        
        add_schedule (-2 , 'POV', 'FE-APU') ; 
        
        enq_apu_start () 
        
        add_schedule (1, 'apu_gen1_trip_sw', 'close') ;
        add_schedule (1, 'apu_gen2_trip_sw', 'close') ;
        
        
        add_schedule (2, 'apu_gen1_close_sw', 'close') ;
        add_schedule (2, 'aux_power_1', 'off') ;
        add_schedule (2, 'apu_gen2_close_sw', 'close') ;
        add_schedule (2, 'aux_power_2', 'off') ;
        -- add_schedule (timer_2, 'apu_gen2_close_sw', 'off') ;
        
        
        enq_powering () 
        
        enq_press_from_apu ()
        
        if (cl_power_apu) then add_schedule (0, 'OK', cl_power_apu ) end
        add_schedule (0, 'OK' )
        add_schedule (3, 'END' , 'APU STARTED & PACKS CONFIG')
         
     
      
      
   elseif ( cl == 'OVERHEAD-CHK') then 
      ------------------------------------------------------ 
      current_cl_num = cl_num
      --- Read INS1 status
      perf_ind1 = get (interfaces['ins_perf_index']['dataref'], 0 ) 
      desired_pi1 = get (interfaces['ins_desired_PI']['dataref'], 0 ) 
      
      
      if (perf_ind1 ~= nil and  desired_pi1 ~= nil and perf_ind1 <= desired_pi1  ) then
        --- add_schedule (-1, 'TITLE', 'FE Overhead checks') ; 
        
        add_schedule (-2, 'POV', 'FE-OVH-H') ;
        
        add_schedule (0, 'MSG', 'WINDOW HEATERS') ;
        if (flag_checks ) then 
           add_schedule (timer_2, 'window_heat_power_lights', 'on') ; 
           end 
        add_schedule (timer_1, 'window_heat_sw_2L', 'on') ; 
        add_schedule (timer_1, 'window_heat_sw_1L', 'on') ;
        add_schedule (timer_1, 'window_heat_sw_1R', 'on') ;
        add_schedule (timer_1, 'window_heat_sw_2R', 'on') ;
        if (flag_checks ) then  
           add_schedule (8, 'window_heat_gard', 'off') ;
           add_schedule (timer_1, 'window_heat_sw_1R', 'ovrd') ;
           add_schedule (timer_1, 'window_heat_sw_1L', 'ovrd') ;
           add_schedule (timer_1, 'window_heat_sw_1R', 'on') ;
           add_schedule (timer_1, 'window_heat_sw_1L', 'on') ;
           end 
        add_schedule (timer_2, 'window_heat_gard', 'on') ;
        add_schedule (3, 'window_heat_power_lights', 'off') ; 
        
        
        --- heat probe tests 
        add_schedule (0, 'MSG', 'PROBE HEATERS') ;
        if (flag_checks ) then
           add_schedule (3, 'probe_heater_L', 'test') ;
           add_schedule (timer_1, 'probe_heater_L', 'on') ;
           end 
        add_schedule (timer_2, 'probe_heater_L', 'off') ;
        if (flag_checks ) then 
           add_schedule (timer_1, 'probe_heater_R', 'test') ;
           add_schedule (timer_1, 'probe_heater_R', 'on') ;
           end 
        add_schedule (timer_1, 'probe_heater_R', 'off') ;
        
        add_schedule (0, 'MSG', 'MACH TEST') ;
        add_schedule (0, 'POV', 'FE-rovh') ;
        if (flag_checks ) then 
           add_schedule (3,   'mach_test', 'test') ;
           end 
        add_schedule (timer_1, 'mach_test', 'normal') ;
        if (flag_checks ) then
          add_schedule (timer_2, 'overrot_test', 'test') ;
          end 
        add_schedule (timer_1, 'overrot_test', 'normal') ;
        
        add_schedule (0, 'MSG', 'STALL WARNING') ;
        if (flag_checks ) then 
           add_schedule (timer_2, 'stall_warning', 'test') ;
           end 
        add_schedule (timer_1, 'stall_warning', 'normal') ;
        
        add_schedule (0, 'POV', 'FE-ovh') ;
        add_schedule (timer_2, 'compass_mode', 'slave', 1 ) ;
        add_schedule (timer_2, 'alt_flaps_le', 'off', 1 ) ;
        add_schedule (0, 'alt_flaps_le', 'off', 1 ) ;
        add_schedule (0, 'alt_flaps_te_inbd', 'off') ;
        add_schedule (0, 'alt_flaps_te_outbd', 'off' ) ;
        
        add_schedule (timer_2, 'deck_door', 'close' ) ;
        
        if (flag_checks ) then 
          add_schedule (timer_2, 'emerg_lights_cap', 'open' ) ;
          add_schedule (0, 'emerg_lights_sw', 'on' ) ;
          end 
        add_schedule (timer_1, 'emerg_lights_sw', 'armed' ) ;
        add_schedule (timer_2, 'emerg_lights_cap', 'close' ) ;
        
        if (flag_checks ) then
          add_schedule (timer_2, 'cvr_test', 'push' ) ;
          add_schedule (4, 'cvr_test', 'release' ) ;
          end 
        
        if (flag_checks ) then 
          add_schedule (timer_2, 'wheel_fire_test', 'push' ) ;
          add_schedule (timer_1, 'wheel_fire_test', 'release' ) ;
          end 
        
        add_schedule (timer_2, 'compass_mode', 'slave', 2 ) ;
        
        add_schedule (2, 'body_gr_steer_cap', 'open' ) ;
        add_schedule (timer_2, 'body_gr_steer_sw', 'arm' ) ;
        
        add_schedule (timer_2, 'anti_skid_sw', 'on' ) ;
        add_schedule (timer_1, 'anti_skid_cap', 'close' ) ;
        
        
        if (flag_checks ) then 
          add_schedule (timer_1, 'POV', 'OVH-YAW') ;
          add_schedule (timer_2, 'yaw_dumper_tst_up', 'tcl' ) ;
          add_schedule (timer_1, 'POV', 'ALARMS') ;
          add_schedule (timer_2, 'yaw_dumper_tst_up', 'off' ) ;
          add_schedule (timer_2, 'yaw_dumper_tst_up', 'ydr' ) ;
          add_schedule (timer_2, 'yaw_dumper_tst_up', 'off' ) ;
          
          add_schedule (timer_2, 'yaw_dumper_tst_dn', 'tcl' ) ;
          add_schedule (timer_2, 'yaw_dumper_tst_dn', 'off' ) ;
          add_schedule (timer_2, 'yaw_dumper_tst_dn', 'ydr' ) ;
          add_schedule (timer_2, 'yaw_dumper_tst_dn', 'off' ) ;
        else 
          add_schedule (0, 'yaw_dumper_tst_up', 'off' ) ; 
          add_schedule (0, 'yaw_dumper_tst_dn', 'off' ) ; 
          end
        --- 
        add_schedule (timer_2, 'TITLE', 'END of FE Overhead checks') ; 
        add_schedule (0, 'OK') ;
        add_schedule (3, 'END', cl..' end ')
       
         
        
      else
        
        add_schedule (-1, 'ERROR', 'INS alignment first !!! ') ; 
        add_schedule (5, 'END', ' --- ')
        
         
        end 
      
      
     elseif ( cl == 'FE-CHECKS') then 
      ------------------------------------------------------ 
        current_cl_num = cl_num
        
        --- add_schedule (-1, 'TITLE', 'FE Panel checks') ; 
        add_schedule (-2, 'POV', 'FE-FIRE') ; 
        
        add_schedule (0, 'MSG', 'SQUIB TEST') ;
        if (flag_checks ) then
          add_schedule (2, 'squib_test_sw', 'rightbottle') ; 
          add_schedule (timer_1, 'squib_test_sw', 'leftbottle') ; 
          end 
        add_schedule (timer_1, 'squib_test_sw', 'off') ; 
        
        add_schedule (0, 'MSG', 'FIRE DETECT') ;
        if (flag_checks ) then add_schedule (timer_2, 'fire_detectA_sw', 'firetest') end 
        add_schedule (timer_1, 'fire_detectA_sw', 'off') ;
        if (flag_checks ) then add_schedule (timer_2, 'fire_detectB_sw', 'firetest') end
        add_schedule (timer_1, 'fire_detectB_sw', 'off') ; 
        if (flag_checks ) then add_schedule (timer_2, 'fire_detect_sw', 'firetest') end
        add_schedule (timer_1, 'fire_detect_sw', 'off') ;
        
        if (flag_checks ) then add_schedule (timer_2, 'fire_detectA_sw', 'faulttest') end
        add_schedule (timer_1, 'fire_detectA_sw', 'off') ;
        if (flag_checks ) then add_schedule (timer_2, 'fire_detectB_sw', 'faulttest') end
        add_schedule (timer_1, 'fire_detectB_sw', 'off') ; 
        if (flag_checks )  then add_schedule (timer_2, 'fire_detect_sw', 'faulttest') end 
        add_schedule (timer_1, 'fire_detect_sw', 'off') ;    
        
        add_schedule (0, 'nacelle_temp_sw', 'both') ; 
        
        if (flag_checks ) then  add_schedule (timer_2, 'aft_cargo_heat_sw', 'test') end  
        add_schedule (timer_2, 'aft_cargo_heat_sw', 'off') ; 
        
        if (flag_checks ) then add_schedule (timer_2, 'lower_cargo_heatA_sw', 'test') end   
        add_schedule (timer_1, 'lower_cargo_heatA_sw', 'off') ;    
        if (flag_checks ) then add_schedule (timer_2, 'lower_cargo_heatB_sw', 'test') end  
        add_schedule (timer_1, 'lower_cargo_heatB_sw', 'off') ; 
        if (flag_checks ) then add_schedule (timer_2, 'lower_cargo_heat_both_sw', 'test') end  
        add_schedule (timer_1, 'lower_cargo_heat_both_sw', 'off') ;
        
        if (flag_checks ) then 
          add_schedule (0, 'MSG', 'WING LE OVERHEAT') ;
          add_schedule (timer_1, 'wing_LE_overheat_test', 'sys2') ;
          add_schedule (timer_1, 'wing_LE_overheat_test', 'off') ;
          add_schedule (timer_1, 'wing_LE_overheat_test', 'sys1') ;
          add_schedule (timer_1, 'wing_LE_overheat_test', 'off') ;
        else
          add_schedule (0, 'wing_LE_overheat_test', 'off') ;
          end 
        add_schedule (0, 'wing_LE_overheat_L', 'both') ;
        add_schedule (0, 'wing_LE_overheat_R', 'both') ;
        
        add_schedule (timer_2, 'POV', 'FE-FIRE2') ;
        
        if (flag_checks ) then 
          add_schedule (0, 'MSG', 'BRAKE TEMP MONITOR') ;
          add_schedule (timer_2, 'brake_temp_sw', 'LF' ) ;
          add_schedule (timer_2, 'brake_temp_test', 'on' ) ;
          add_schedule (timer_2, 'brake_temp_sw', 'RF' ) ;
          add_schedule (timer_2, 'brake_temp_sw', 'LR' ) ;
          add_schedule (timer_2, 'brake_temp_sw', 'RR' ) ;
          add_schedule (timer_2, 'brake_temp_test', 'off' ) ;
          add_schedule (timer_2, 'brake_temp_sw', 'LF' ) ;
          add_schedule (timer_2, 'brake_temp_sw', 'RF' ) ;
          add_schedule (timer_2, 'brake_temp_sw', 'LR' ) ;
          add_schedule (timer_2, 'brake_temp_sw', 'RR' ) ;
          end  
        add_schedule (timer_2, 'brake_temp_sw', 0 ) ;
        
        if (flag_checks ) then  
           add_schedule (0, 'MSG', 'EFDARS TEST') ;
           add_schedule (timer_1, 'EFDARS_lamp_test', 'on' ) 
           add_schedule (timer_2, 'EFDARS_lamp_test', 'off' ) ; 
           end 
        
        
        if (flag_checks ) then 
          add_schedule (timer_2, 'askid_lamp_test', 'prim' ) ;
          add_schedule (timer_1, 'askid_lamp_test', 'off' ) ; 
          add_schedule (timer_2, 'askid_lamp_test', 'alt' ) ; 
          end 
        add_schedule (timer_1, 'askid_lamp_test', 'off' ) ;
        
        if (flag_checks ) then 
          add_schedule (0, 'MSG', 'LANDING GEAR') ;
          add_schedule (timer_2, 'landing_gear_sw', 'gearprim' ) ; 
          add_schedule (timer_2, 'landing_gear_sw', 'gearalt' ) ;
          add_schedule (timer_2, 'landing_gear_sw', 'tiltprim' ) ;
          add_schedule (timer_2, 'landing_gear_sw', 'tiltalt' ) ;
          add_schedule (timer_2, 'landing_gear_sw', 'doorprim' ) ;
          add_schedule (timer_2, 'landing_gear_sw', 'dooralt' ) ;
          end 
        add_schedule (timer_2, 'landing_gear_sw', 0 ) ;
        
        if (flag_checks ) then 
           add_schedule (0, 'MSG', 'POTABLE WATER') ;
           add_schedule (timer_1, 'water_gau_butt', 'read' )  
           add_schedule (timer_2*2, 'water_gau_butt', 'off' ) 
           end 
        
        --- Fuel
        add_schedule (0, 'POV', 'FE-FUEL') ;
        add_schedule (0, 'MSG', 'FUEL CHECKS') ; 
        
        if (flag_checks ) then 
          add_schedule (0, 'MSG', 'CHECKS FUEL GAUGES') ;    
          add_schedule (timer_2, 'gages_test_butt', 'test' ) ;
          add_schedule (2, 'gages_test_butt', 'off' ) ; 
          add_schedule (8, 'WAIT' ) ; 
          end
          
        if (flag_checks ) then  
           add_schedule (timer_2, 'reset_fuel', 'reset' ) ; 
           end 
        add_schedule (timer_1, 'reset_fuel', 'off' ) ; 
        
        add_schedule (0, 'MSG', 'FUEL HEAT') ; 
        if (flag_checks ) then 
           add_schedule (timer_2, 'fuel_heat_sw', 'on' , 1 )  
           add_schedule (timer_1/2, 'fuel_heat_sw', 'off', 1 ) ;
           add_schedule (timer_2, 'fuel_heat_sw', 'on' , 2 ) 
           add_schedule (timer_1/2, 'fuel_heat_sw', 'off', 2 ) ;
           add_schedule (timer_2, 'fuel_heat_sw', 'on' , 3 )
           add_schedule (timer_1/2, 'fuel_heat_sw', 'off', 3 ) ;
           add_schedule (timer_2, 'fuel_heat_sw', 'on' , 4 ) 
           add_schedule (timer_1/2, 'fuel_heat_sw', 'off', 4 ) 
        else 
           add_schedule (0, 'fuel_heat_sw', 'off', 1 ) ;
           add_schedule (0, 'fuel_heat_sw', 'off', 2 ) ;
           add_schedule (0, 'fuel_heat_sw', 'off', 3 ) ;
           add_schedule (0, 'fuel_heat_sw', 'off', 4 ) 
           end 
        
        
        --- Crosfeed valves
        add_schedule (0, 'MSG', 'CROSSFEED VALVES') ; 
        if (flag_checks ) then 
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'open', 5 ) ; 
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'close', 5 ) ; 
          
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'close', 1) ; 
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'open', 1 ) ;
          
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'open', 2 ) ; 
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'close', 2 ) ; 
          
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'open', 3 ) ; 
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'close', 3 ) ; 
          
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'close', 4) ; 
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'open', 4 ) ;
          
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'open', 6 ) ; 
          add_schedule (timer_2*2, 'fuel_crossfeed_valves', 'close', 6 ) ; 
        else 
          add_schedule (0, 'fuel_crossfeed_valves', 'close', 5 ) 
          add_schedule (0, 'fuel_crossfeed_valves', 'open', 1 ) 
          add_schedule (0, 'fuel_crossfeed_valves', 'close', 2 )
          add_schedule (0, 'fuel_crossfeed_valves', 'close', 3 )
          add_schedule (0, 'fuel_crossfeed_valves', 'open', 4 )
          add_schedule (0, 'fuel_crossfeed_valves', 'close', 6 ) ;   
          end 
        
        add_schedule (0, 'MSG', 'FUEL BOOST PUMPS') ; 
        if (flag_checks ) then 
          add_schedule (timer_1, 'fuel_boost_pump', 'on', 1 ) ;
          add_schedule (timer_2, 'fuel_boost_pump', 'on', 3 ) ;
          add_schedule (timer_2, 'fuel_boost_pump', 'on', 5 ) ;
          add_schedule (timer_2, 'fuel_boost_pump', 'on', 7 ) ;
          add_schedule (timer_2, 'fuel_boost_pump', 'on', 9 ) ;
         
          add_schedule (5, 'fuel_boost_pump', 'off', 1 )
          add_schedule (timer_1, 'fuel_boost_pump', 'on', 2 ) 
          add_schedule (timer_2, 'fuel_boost_pump', 'off', 3 ) 
          add_schedule (timer_1, 'fuel_boost_pump', 'on', 4 ) 
          add_schedule (timer_2, 'fuel_boost_pump', 'off', 5 ) 
          add_schedule (timer_1, 'fuel_boost_pump', 'on', 6) 
          add_schedule (timer_2, 'fuel_boost_pump', 'off', 7 ) 
          add_schedule (timer_1, 'fuel_boost_pump', 'on', 8 ) 
          add_schedule (timer_2, 'fuel_boost_pump', 'off', 9 )  
          add_schedule (timer_1, 'fuel_boost_pump', 'on', 10 ) 
          
          add_schedule (5, 'fuel_boost_pump', 'on', 1 ) 
          add_schedule (timer_2, 'fuel_boost_pump', 'on', 3 )
          add_schedule (timer_2, 'fuel_boost_pump', 'on', 5 )
          add_schedule (timer_2, 'fuel_boost_pump', 'on', 7 )
          add_schedule (timer_2, 'fuel_boost_pump', 'on', 9 ) 
          
          
        else 
          add_schedule (0, 'fuel_boost_pump', 'on', 1 ) 
          add_schedule (0, 'fuel_boost_pump', 'on', 2 ) 
          add_schedule (0, 'fuel_boost_pump', 'on', 3 ) 
          add_schedule (0, 'fuel_boost_pump', 'on', 4 )
          add_schedule (0, 'fuel_boost_pump', 'on', 5 ) 
          add_schedule (0, 'fuel_boost_pump', 'on', 6 ) 
          add_schedule (0, 'fuel_boost_pump', 'on', 7 ) 
          add_schedule (0, 'fuel_boost_pump', 'on', 8 ) 
          add_schedule (0, 'fuel_boost_pump', 'on', 9 ) 
          end 
          
          
          
        --- Pressurization
        add_schedule (timer_2, 'POV', 'FE-PACK') ; 
        
        add_schedule (timer_2, 'fe_baro_rotary', current_QNH_hpa )
        
        -- TODO Find dataref to set cabin altitude
        --- add_schedule (timer_2, 'cabin_alt_ft', current_alt_ft )
        
        --- TODO real cruising FL
        add_schedule (timer_2, 'cabin_alt_rotary', 31 )
        add_schedule (timer_2, 'pressu_mode', 'auto' )
        
        
        
        
        
        --- hydraulics
        add_schedule (timer_2, 'POV', 'FE-HYD') ;
        
        add_schedule (3, 'hyd_qty_check', 'test' ) ; 
        add_schedule (2, 'hyd_qty_check', 'off' ) ;
        
        add_schedule (timer_2, 'air_pump_sw', 'off' ) ;
        --  
        --- 
        add_schedule (0, 'OK') ;
        add_schedule (3, 'TITLE', 'END of FE panel checks') ;   
        add_schedule (5, 'END', cl..' end ')
       
   
     elseif ( cl == 'FE-BEF-START') then 
      ------------------------------------------------------ 
        current_cl_num = cl_num
        
        add_schedule (-1, 'TITLE', 'FE checks before Start') ; 
        add_schedule (0, 'MSG', 'BEFORE START') ; 
        add_schedule (0, 'POV', 'FE-PACK') ; 
        add_schedule (0, 'MSG', 'CLOSE PACK VALVE') ; 
        add_schedule (2, 'pack_valves', 'close', 2 ) 
        
        
        
        add_schedule (0, 'POV', 'FE-HYD') ; 
        add_schedule (0, 'MSG', 'AIR PUMP & ELECT PUMP') ;
        add_schedule (timer_2, 'air_pump_sw', 'auto' , 1  ) ;
        add_schedule (timer_2, 'elect_pump_cap', 'open' ) ;
        add_schedule (timer_2, 'elect_pump4', 'on' ) ;
        
        add_schedule (0, 'MSG', 'AIR VALVES OPEN') ;
        add_schedule (timer_2, 'air_valves', 'open' , 1 )
        add_schedule (timer_2, 'air_valves', 'open' , 2 )
        add_schedule (timer_2, 'air_valves', 'open' , 3 )
        add_schedule (timer_2, 'air_valves', 'open' , 4 )
        
        --- 
        
        --- add_schedule (0, 'MSG', 'END OF DO LIST') ;   
        add_schedule (0, 'OK') ;
        add_schedule (5, 'END', cl..' end ')
       
        
     
     elseif ( cl == 'FE-START-ENG') then 
      ------------------------------------------------------ 
        current_cl_num = cl_num
        
        cl_act_end = nil 
        --- add_schedule (-1, 'TITLE', 'FE Starting engines') ; 
        -- Checks if INS are on NAV mode (to be done)
        
        add_schedule (0, 'POV', 'FE-ovh') ;
        -- Double check fuel pumps 
        add_schedule (-2 , 'fuel_boost_pump', 'on' ) 
        -- Double check seat belts
        add_schedule (0, 'no_smoking', 'on') ;
        add_schedule (0, 'fasten_belts', 'on') ; 

        add_schedule (3 , 'xpond', 'xpdr') 
        
        -- Double check
        add_schedule (0, 'body_gr_steer_cap', 'open' ) ;
        add_schedule (timer_2, 'body_gr_steer_sw', 'arm' ) ;
        
        -- Beacon on
        add_schedule (0, 'MSG', 'BEACON ON') ;
        add_schedule (timer_2, 'beacon', 'on' ) ;
        
        add_schedule (0, 'POV', 'FE-PACK') ; 
        add_schedule (0, 'MSG', 'CLOSE PACK VALVE') ; 
        add_schedule (2, 'pack_valves', 'close', 3 )
        add_schedule (2, 'pack_valves', 'close', 1 ) 
        
        add_schedule (0, 'POV', 'FE-1') ;
        add_schedule (0, 'MSG', 'PWR OFF GALLEY') ;
        add_schedule (timer_2, 'galley_pwr', 'off', 1 ) 
        add_schedule (timer_2, 'galley_pwr', 'off', 2 ) 
        add_schedule (timer_2, 'galley_pwr', 'off', 3 ) 
        add_schedule (timer_2, 'galley_pwr', 'off', 4 )
        
        
        
        --- check duct pressure
        
        add_test (1 , 5 , 'DUCT_PSI_R', nil, nil  , 20 , nil )
        
        add_schedule (0, 'POV', 'ovh_ignit') ;
        add_schedule (0, 'MSG', 'OPEN START VALVE') ;
        add_schedule (2, 'start_valve_cap', 'open' ) 
        add_schedule (timer_2, 'start_valve_sw', 'on' ) 
        
        
        
        
        --- Start 4 
        add_schedule (0, 'MSG', 'STARTING #4') ;
        add_schedule (timer_2, 'engine_ignition_1', 'gndstart' , 4  ) 
        -- N2 monitoring
        add_schedule (0, 'POV', 'FE-2') ;
        add_test (1 , 30 , 'N2-4', nil, nil  , 20 , nil )
        add_schedule (0, 'POV', 'cons-2') ;
        add_schedule (timer_2, 'fuel_cut_off_4', 'idle')  
         -- N2 monitoring
        add_test (1 , 30 , 'N1-4', nil, nil  , 20 , nil )
        
        
       
        add_schedule (0, 'POV', 'ovh_ignit') 
        
        add_schedule (0, 'MSG', 'STARTING #1')
        add_schedule (2, 'engine_ignition_1', 'gndstart' , 1  ) 
        -- N2 monitoring
        add_schedule (0, 'POV', 'FE-2') ;
        add_test (1 , 30 , 'N2-1', nil, nil  , 20 , nil )
        add_schedule (0, 'POV', 'cons-2') ;
        add_schedule (timer_2, 'fuel_cut_off_1', 'idle')
        -- N2 monitoring
        add_test (1 , 30 , 'N1-1', nil, nil  , 20 , nil )
        
        add_schedule (0, 'MSG', 'STARTING #2')
        add_schedule (timer_2, 'POV', 'ovh_ignit') ;
        add_schedule (2, 'engine_ignition_1', 'gndstart' , 2  ) 
        -- N2 monitoring
        add_schedule (0, 'POV', 'FE-2') ;
        add_test (1 , 30 , 'N2-2', nil, nil  , 20 , nil )
        add_schedule (0, 'POV', 'cons-2') ;
        add_schedule (timer_2, 'fuel_cut_off_2', 'idle')
        -- N2 monitoring
        add_test (1 , 30 , 'N1-2', nil, nil  , 20 , nil )
        
        add_schedule (0, 'MSG', 'STARTING #3')
        add_schedule (0, 'POV', 'ovh_ignit') ;
        add_schedule (2, 'engine_ignition_1', 'gndstart' , 3  ) 
        -- N2 monitoring
        add_schedule (timer_2, 'POV', 'FE-2') ;
        add_test (1 , 30 , 'N2-3', nil, nil  , 20 , nil )
        add_schedule (0, 'POV', 'cons-2') ;
        add_schedule (timer_2, 'fuel_cut_off_3', 'idle')
        -- N2 monitoring
        add_test (1 , 30 , 'N1-3', nil, nil  , 20 , nil )
        
        
        add_schedule (0, 'POV', 'ovh_ignit') ;
        add_schedule (timer_2, 'start_valve_sw', 'off' )
        add_schedule (2, 'start_valve_cap', 'close' )  
        add_schedule (0, 'engine_ignition_1', 'off'  ) 
        add_schedule (0, 'engine_ignition_2', 'off'  ) 
        
        add_schedule (0, 'POV', 'FE-OVH-H') ;
        add_schedule (0, 'MSG', 'PROBE HEATERS ON')
        add_schedule (timer_2, 'probe_heater_L', 'on') ;
        add_schedule (timer_2, 'probe_heater_R', 'on') ;
        
        add_schedule (0, 'POV', 'FE-1') ;
        add_schedule (0, 'MSG', 'STOPPING APU')
        add_schedule (timer_2, 'apu_bleed_air', 'close' )
        
        --- TODO gen voltage checks
        add_schedule (timer_2, 'bus_gen_close', 'close' , 4  ) 
        
        add_schedule (0, 'apu_gen1_trip_sw', 'off'  ) 
        add_schedule (0, 'apu_gen2_trip_sw', 'off'  ) 
        add_schedule (0, 'apu_gen1_close_sw', 'off') ;
        add_schedule (0, 'apu_gen2_close_sw', 'off') ;
        
        add_schedule (timer_2, 'bus_gen_close', 'close' , 1  )
        add_schedule (timer_2, 'bus_gen_close', 'close' , 2  )
        add_schedule (timer_2, 'bus_gen_close', 'close' , 3  )
        
        add_schedule (timer_2, 'apu_split', 'close'   )
        add_schedule (timer_2, 'apu_split', 'off'   )
        
        add_schedule (0, 'MSG', 'PWR ON GALLEY') ;
        add_schedule (timer_2, 'galley_pwr', 'on', 1 ) 
        add_schedule (timer_2, 'galley_pwr', 'on', 2 ) 
        add_schedule (timer_2, 'galley_pwr', 'on', 3 ) 
        add_schedule (timer_2, 'galley_pwr', 'on', 4 )
        
        
        add_schedule (0, 'MSG', 'OPENING PACK VALVES') ;
        add_schedule (2, 'pack_valves', 'open', 1 )
        add_schedule (timer_2, 'pack_valves', 'open', 2 )
        add_schedule (timer_2, 'pack_valves', 'open', 3 )
       
        add_schedule (0, 'MSG', 'AIR PUMPS TO AUTO') ;
        add_schedule (timer_2, 'air_pump_sw', 'auto' , 1  ) ;
        add_schedule (timer_2, 'air_pump_sw', 'auto' , 2  )
        add_schedule (timer_2, 'air_pump_sw', 'auto' , 3  )
        add_schedule (timer_2, 'air_pump_sw', 'auto' , 4  )
        
        add_schedule (0, 'MSG', 'ELECTRIC PUMP TO OFF') ;
        add_schedule (timer_2, 'elect_pump4', 'off' ) ;
        add_schedule (timer_2, 'elect_pump_cap', 'close' ) ;
        add_schedule (timer_2, 'aft_cargo_heat_sw', 'on') ; 
        
        add_schedule (2, 'apu_start', 'stop'   )
        
        
        
         
        add_schedule (3, 'TITLE', 'Engines started,') ;   
        add_schedule (5, 'END', cl..' end ')
        
    elseif ( cl == 'FE-TAXI') then 
      ------------------------------------------------------ 
        current_cl_num = cl_num
        
        add_schedule (-1, 'TITLE', 'FE Taxi') ; 
        
        -- APU close
        add_schedule (0, 'apu_bleed_air', 'close' )
        add_schedule (0, 'apu_start', 'stop') ;
        
        add_schedule (timer_2, 'fuel_heat_sw', 'off' , 1 ) ;
        add_schedule (timer_2, 'fuel_heat_sw', 'off' , 2 ) ;
        add_schedule (timer_2, 'fuel_heat_sw', 'off' , 3 ) ;
        add_schedule (timer_2, 'fuel_heat_sw', 'off' , 4 ) ;
        add_schedule (timer_2, 'aft_cargo_heat_sw', 'normal')
        
        
        add_schedule (0, 'OK') ;
        add_schedule (5, 'END', cl..' end ')
    
    elseif ( cl == 'FE-BEFORE-TO') then 
      ------------------------------------------------------ 
        current_cl_num = cl_num
        
        add_schedule (-1, 'TITLE', 'Before take off') ; 
        
        add_schedule (0, 'engine_ignition_1', 'fltstart', 1 ) 
        add_schedule (timer_2, 'engine_ignition_1', 'fltstart', 2 ) 
        add_schedule (timer_2, 'engine_ignition_1', 'fltstart', 3 ) 
        add_schedule (timer_2, 'engine_ignition_1', 'fltstart', 4 ) 
        
        add_schedule (timer_2, 'engine_ignition_2', 'fltstart', 1 )
        add_schedule (timer_2, 'engine_ignition_2', 'fltstart', 2 )
        add_schedule (timer_2, 'engine_ignition_2', 'fltstart', 3 )
        add_schedule (timer_2, 'engine_ignition_2', 'fltstart', 4 )  
        
        -- close all packs
        add_schedule (0, 'MSG', 'CLOSING PACK VALVES') ;
        add_schedule (0, 'pack_valves', 'close' ) 
        -- pressure on auto
        add_schedule (timer_2, 'pressu_mode', 'auto' ) 
        -- fuel press extinguis
        -- all boost pump on 
        add_schedule (0, 'fuel_boost_pump', 'on' , 1 )  
        add_schedule (0, 'fuel_boost_pump', 'on' , 2 ) 
        add_schedule (0, 'fuel_boost_pump', 'on' , 3 ) 
        add_schedule (0, 'fuel_boost_pump', 'on' , 4 ) 
        
        -- test if  > 4500kg
        add_schedule (0, 'fuel_boost_pump', 'on' , 5 ) 
        add_schedule (0, 'fuel_boost_pump', 'on' , 6 ) 
        
        add_schedule (0, 'fuel_boost_pump', 'on' , 7 ) 
        add_schedule (0, 'fuel_boost_pump', 'on' , 8 ) 
        add_schedule (0, 'fuel_boost_pump', 'on' , 9 ) 
        add_schedule (0, 'fuel_boost_pump', 'on' , 10 ) 
        
        add_schedule (0, 'OK') ;
        add_schedule (5, 'END', cl..' end ')
        
    elseif ( cl == 'FE-AFTER-TO') then 
      ------------------------------------------------------ 
        current_cl_num = cl_num
        add_schedule (-1, 'TITLE', 'After take off') ;
        
        --- gear handle to OFF
        add_schedule (0, 'MSG', 'GEAR LEVER OFF') ;
        add_schedule (0, 'gear_lever', 'off' ) 
        ---  turnoff lights.
        add_schedule (timer_1, 'turnoff_L', 'off' ) 
        add_schedule (timer_1, 'turnoff_R', 'off' ) 
        -- off engine ignition
        add_schedule (0, 'MSG', 'ENGINE IGNITION OFF') ;
        add_schedule (0, 'engine_ignition_1', 'off', 1 ) 
        add_schedule (timer_2, 'engine_ignition_1', 'off', 2 ) 
        add_schedule (timer_2, 'engine_ignition_1', 'off', 3 ) 
        add_schedule (timer_2, 'engine_ignition_1', 'off', 4 ) 
        
        add_schedule (timer_2, 'engine_ignition_2', 'off', 1 )
        add_schedule (timer_2, 'engine_ignition_2', 'off', 2 )
        add_schedule (timer_2, 'engine_ignition_2', 'off', 3 )
        add_schedule (timer_2, 'engine_ignition_2', 'off', 4 )
        
        --- pack valves
        add_schedule (0, 'MSG', 'OPENING PACK VALVES') ;
        add_schedule (0, 'pack_valves', 'open', 3 )
        add_schedule (30, 'pack_valves', 'open', 2 )
        add_schedule (30, 'pack_valves', 'open', 1 )
        
        --- fuel heat to AUTO
        add_schedule (0, 'MSG', 'FUEL HEAT AUTO') ;
        add_schedule (timer_2, 'fuel_heat_sw', 'auto' , 1 ) ;
        add_schedule (timer_2, 'fuel_heat_sw', 'auto' , 2 ) ;
        add_schedule (timer_2, 'fuel_heat_sw', 'auto' , 3 ) ;
        add_schedule (timer_2, 'fuel_heat_sw', 'auto' , 4 ) ; 
        
        add_schedule (0, 'MSG', 'Call the AFTER TAKEOFF checklist') ;
        add_schedule (0, 'OK') ;
        add_schedule (5, 'END', cl..' end ')
        
    elseif ( cl == 'CLIMB-10000') then 
      ------------------------------------------------------ 
        current_cl_num = cl_num
        add_schedule (-1, 'TITLE', 'Climb > 10.000 feet') ;
        
        --- Turn off the seatbelt signs &  landing lights.
        add_schedule (0, 'fasten_belts', 'off')  
        add_schedule (timer_1, 'no_smoking', 'off') 
        add_schedule (timer_1, 'landing_outbd_L', 'off') 
        add_schedule (timer_1, 'landing_outbd_R', 'off')
        add_schedule (timer_1, 'landing_inbd_L', 'off')
        add_schedule (timer_1, 'landing_inbd_R', 'off')
        
        
        
        add_schedule (0, 'OK') ;
        add_schedule (5, 'END', cl..' end ')
        
        
   elseif ( cl == 'DESCENT-10000') then 
      ------------------------------------------------------ 
        current_cl_num = cl_num
        add_schedule (-1, 'TITLE', 'Descent < 10.000 feet') ;
        add_schedule (0, 'fasten_belts', 'on')  
        add_schedule (timer_1, 'no_smoking', 'on') 
        add_schedule (timer_1, 'landing_outbd_L', 'on') 
        add_schedule (timer_1, 'landing_outbd_R', 'on')
        add_schedule (timer_1, 'landing_inbd_L', 'on')
        add_schedule (timer_1, 'landing_inbd_R', 'on')
        
        -- turn off fuel heat
        add_schedule (0, 'MSG', 'FUEL HEAT ON') ;
        add_schedule (timer_2, 'fuel_heat_sw', 'on' , 1 ) ;
        add_schedule (timer_2, 'fuel_heat_sw', 'on' , 2 ) ;
        add_schedule (timer_2, 'fuel_heat_sw', 'on' , 3 ) ;
        add_schedule (timer_2, 'fuel_heat_sw', 'on' , 4 ) ; 
        
        -- turn on ignition
        add_schedule (0, 'MSG', 'ENGINE IGNITION ON') ;
        add_schedule (0, 'engine_ignition_1', 'on', 1 ) 
        add_schedule (timer_2, 'engine_ignition_1', 'on', 2 ) 
        add_schedule (timer_2, 'engine_ignition_1', 'on', 3 ) 
        add_schedule (timer_2, 'engine_ignition_1', 'on', 4 ) 
        
        add_schedule (timer_2, 'engine_ignition_2', 'on', 1 )
        add_schedule (timer_2, 'engine_ignition_2', 'on', 2 )
        add_schedule (timer_2, 'engine_ignition_2', 'on', 3 )
        add_schedule (timer_2, 'engine_ignition_2', 'on', 4 )
        
        add_schedule (0, 'MSG', 'Call DESCENT/ APPROACH checklist') ;
        add_schedule (0, 'OK') ;
        add_schedule (5, 'END', cl..' end ')
        
        
    
     elseif ( cl == 'TAXI-AFTER-LDG') then 
      ------------------------------------------------------ 
        current_cl_num = cl_num
        add_schedule (-1, 'TITLE', 'Taxi after landing') ;
        
        --- Open the outflow valves
        add_schedule (timer_2, 'outflow_valve_L', 'open' ) 
        add_schedule (timer_2, 'outflow_valve_R', 'open' )  
        --  Turn the pressurization mode selector to MAN
        add_schedule (timer_2, 'MSG', 'PRESSURIZATION MAN' ) 
        add_schedule (timer_2, 'pressu_mode', 'auto' ) 
        --  Turn off the Aft Cargo Heat. 
               
        
        
        add_schedule (0, 'OK') ;
        add_schedule (5, 'END', cl..' end ') 
        
     elseif ( cl == 'PARKING') then 
      ------------------------------------------------------ 
        current_cl_num = cl_num
        add_schedule (-1, 'TITLE', 'ON BLOCKS') ;
        
        --- Start APU
        enq_apu_start ()
        
        -- Turn off all fuel boost pumps.
        add_schedule (0, 'MSG', 'FUEL BOOST PUMP OFF') ;
        add_schedule (timer_2, 'fuel_boost_pump', 'off' , 1 )  
        add_schedule (timer_2, 'fuel_boost_pump', 'off' , 2 ) 
        add_schedule (timer_2, 'fuel_boost_pump', 'off' , 3 ) 
        add_schedule (timer_2, 'fuel_boost_pump', 'off' , 4 ) 
        
        add_schedule (timer_2, 'fuel_boost_pump', 'off' , 5 ) 
        add_schedule (timer_2, 'fuel_boost_pump', 'off' , 6 ) 
        
        add_schedule (timer_2, 'fuel_boost_pump', 'off' , 7 ) 
        add_schedule (timer_2, 'fuel_boost_pump', 'off' , 8 ) 
        add_schedule (timer_2, 'fuel_boost_pump', 'off' , 9 ) 
        add_schedule (timer_2, 'fuel_boost_pump', 'off' , 10 ) 
        
        -- Turn off ADPs 1, 2 and 3.
        add_schedule (0, 'MSG', '1-3 AIR PUMPS OFF') ;
        add_schedule (timer_2, 'air_pump_sw', 'off' , 1  ) ;
        add_schedule (timer_2, 'air_pump_sw', 'off' , 2  )
        add_schedule (timer_2, 'air_pump_sw', 'off' , 3  )
      
        -- Close engine bleed valves 2, 3 and 4.
        add_schedule (0, 'MSG', 'CLOSE ENG BLEED VALVES') ;
        add_schedule (timer_2, 'air_valves', 'close' , 2 )
        add_schedule (timer_2, 'air_valves', 'close' , 3 )
        add_schedule (timer_2, 'air_valves', 'close' , 4 )
        
        -- Shut down engines 2, 3 and 4.
        add_schedule (0, 'MSG', 'ENG 2-3-4 SHUTDOWN') ;
        add_schedule (timer_2, 'fuel_cut_off_2', 'cutoff')
        add_schedule (timer_2, 'fuel_cut_off_3', 'cutoff')
        add_schedule (timer_2, 'fuel_cut_off_4', 'cutoff')
        
        add_schedule (0, 'MSG', 'APU POWERING') ;
        add_schedule (timer_1, 'apu_gen1_trip_sw', 'close') ;
        add_schedule (timer_1, 'apu_gen2_trip_sw', 'close') ;
        add_schedule (timer_1, 'apu_gen1_close_sw', 'close') ;
        add_schedule (timer_1, 'apu_gen2_close_sw', 'close') ;
        
        -- Turn off ADPs 4
        add_schedule (0, 'MSG', 'ENG #1 STOP') ;
        add_schedule (timer_1, 'air_pump_sw', 'off' , 4  ) ; 
        add_schedule (timer_2, 'air_valves', 'close' , 1 )  
        add_schedule (timer_2, 'fuel_cut_off_1', 'cutoff')  
        
        -- APU bleed air
        add_schedule (timer_1, 'apu_bleed_air', 'open'  )
        
        
        -- Turn off beacon
        -- Turn off the probe and window heat.
        
        
        
        add_schedule (0, 'OK') ;
        add_schedule (5, 'END', cl..' end ') 
        
     elseif ( cl == 'END-FLIGHT') then 
      ------------------------------------------------------ 
        current_cl_num = cl_num
        add_schedule (-1, 'TITLE', 'Flight Termination') ;
        
        -- turn off emergency lights
        add_schedule (0, 'POV', 'FE-ovh') ;
        add_schedule (timer_1, 'emerg_lights_sw', 'off'  ) ;  
        
        -- WX radar off
        add_schedule (timer_1, 'wx_radar', 'off'  ) ; 
          
        -- Radio master switch off
        add_schedule (timer_1, 'radio_master_ess', 'off'  ) ; 
        add_schedule (timer_1, 'radio_master_n2', 'off'  ) ;       
        
        
        -- Close APU bleed & all packs
        add_schedule (timer_2, 'apu_bleed_air', 'close' )
        add_schedule (timer_2, 'pack_valves', 'close' )
        
        -- STOP APU
        add_schedule (1, 'apu_start', 'off') ;
        
        
        
        -- navigation lights
        add_schedule (timer_1, 'nav_lights', 'off') 
        
        -- cockpit lights
        add_schedule (timer_1, 'light_front_panel', 0 ) ;
        add_schedule (0, 'light_front_left_big_panel', 0 ) ;
        add_schedule (0, 'light_front_left_panel', 0 ) ;
        add_schedule (0, 'light_main_panel_bkgr', 0 ) ;
        add_schedule (0, 'light_dome', 0 ) ;
        add_schedule (0, 'light_control_stand_panel', 0 ) ;
        add_schedule (0, 'light_center_fwd_panel', 0 ) ;
        add_schedule (0, 'light_FE_panel', 0 ) ;
        add_schedule (0, 'light_FE_panel_bkgrd', 0 ) ;
        add_schedule (0, 'light_FE_panel_map', 0 ) ;
        
        -- Batt OFF
        add_schedule (timer_1, 'battery_cap', 'open') ;
        add_schedule (timer_1, 'battery', 'off') ;
               
        
        
        add_schedule (0, 'OK') ;
        add_schedule (5, 'END', cl..' end ') 
        
     
     end   
     
    
    pilot_head_init['X'] = PILOT_HEAD_X
    pilot_head_init['Y'] = PILOT_HEAD_Y
    pilot_head_init['Z'] = PILOT_HEAD_Z
    pilot_head_init['PSI'] = PILOT_HEAD_PSI
    pilot_head_init['THE'] = PILOT_HEAD_THE
    
 else 
    print_debug("!!! There is allready a C/L in progress ") 
    end
    
 end  






--- =================================================================================



  get_acft_status () 
  do_often("get_acft_status ()") 
  -- 
  do_every_draw("monitor_cl()") 
  
  
  if SUPPORTS_FLOATING_WINDOWS then 
     add_macro( "747-200 Symphony", "create_vfe_wnd()" )
     create_command("742VFE/Symphony", "747-200 Symphony", "create_vfe_wnd()", "", "")
  else 
     add_macro("FE Cockpit Safety check", "check_and_do(1)" ) 
     add_macro("FE Establishing power with GPU", "check_and_do(cl_power_ext)" )
     add_macro("FE Overhead Check", "check_and_do(cl_ovh_checks)" )
     add_macro("FE Start APU & pressurisation", "check_and_do(cl_apu_pressure)" )
     add_macro("FE Panel checks", "check_and_do(5)" )
     add_macro("FE Before Start", "check_and_do(6)" )
     add_macro("FE Starting engines", "check_and_do(7)" )
     end 
  
  
  
  end
