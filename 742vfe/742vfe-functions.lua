
FUELS = dataref_table( "sim/flightmodel/weight/m_fuel" )
dataref( "SQUIB_TEST_SW" , "B742/APU/squib_test_sw" , "writable")

---------------------------------------------------
function enq_apu_start () 
---------------------------------------------------

        -- Check APU bat
        add_test (1 , 3 , 'apu_rpm', nil, nil  , nil , 10 )
        add_schedule (0, 'dc_meter_sw', 'apubat') ;
        add_test (1 , 5 , 'dc_volts', nil, nil  , 20 , nil )
        add_schedule (0, 'apu_gen1_trip_sw', 'trip'  ) 
        add_schedule (timer_1, 'apu_gen1_trip_sw', 'off'  )
        add_schedule (0, 'apu_gen2_trip_sw', 'trip'  ) 
        add_schedule (timer_1, 'apu_gen2_trip_sw', 'off'  )
        add_schedule (0, 'apu_gen1_close_sw', 'off') ;
        add_schedule (0, 'apu_gen2_close_sw', 'off') ;
        
        
        add_schedule (2 , 'APU_fire_det_sw', 'both') ; 
         
        add_schedule (2 , 'apu_start', 'off') ;
        
        add_schedule (0, 'MSG', 'START APU') ;
       
        if (flag_checks ) then add_schedule (timer_1, 'apu_squib_test', 'on') end
        add_schedule (timer_1, 'apu_squib_test', 'off') ;
        
        if (flag_checks ) then 
          add_schedule (timer_1, 'apu_test_A', 'fire') ;
          add_schedule (timer_1, 'apu_test_A', 'off') ;
          add_schedule (timer_1, 'apu_test_A', 'fault') ;
          end 
        add_schedule (timer_2, 'apu_test_A', 'off') ;
        
        if (flag_checks ) then 
          add_schedule (timer_1, 'apu_test_B', 'fire') ;
          add_schedule (timer_1, 'apu_test_B', 'off') ;
          add_schedule (timer_1, 'apu_test_B', 'fault') ;
          end 
        add_schedule (timer_2, 'apu_test_B', 'off') ;
        
        if (flag_checks ) then
          add_schedule (timer_1, 'apu_test_B', 'fire') ;
          add_schedule (timer_1, 'apu_test_A', 'fire') ;
          end 
        add_schedule (timer_1, 'apu_test_B', 'off') ;
        add_schedule (0, 'apu_test_A', 'off') ;
        
        if (flag_checks ) then
          add_schedule (timer_1, 'apu_test_B', 'fault') ;
          add_schedule (0, 'apu_test_A', 'fault') ;
          add_schedule (timer_1, 'apu_test_B', 'off') ;
          add_schedule (0, 'apu_test_A', 'off') ;
          end 
        
        add_test (1 , 5 , 'apu_oil_qty', nil, nil  , 2.5 , nil ) 
        add_schedule (0, 'apu_bleed_air', 'close' )
        
        add_schedule (timer_1, 'apu_start', 'on') ;
        
        add_test (1, 30, 'apu_door_lit' , nil, 'off') 
        
        add_schedule (1, 'apu_start', 'start') ;
        add_schedule (1, 'apu_start', 'on') ;
        
        add_test (1 , 30 , 'apu_rpm', nil, nil  , 80 , nil ) 
        
         -- Check AC freq
        add_schedule (0, 'ac_meter_sw', 'apugen1') ;
        add_test (1 , 5 , 'ac_freq', nil, nil  , 380 , nil )
        
        
        

end 


---------------------------------------------------
function enq_ess_elect () 
---------------------------------------------------
        --- chocks = get ( interfaces['chocks']['dataref'] ) ; 
        -- If no chocks 
        if (on_chocks == nil or on_chocks <= 1  ) then
           add_schedule (timer_2, 'elect_pump_cap', 'open' ) ;
           add_schedule (timer_2, 'elect_pump4', 'on' ) ;
           end 
        
        add_schedule (3, 'stdby_power', 'manual') ;
        add_schedule (3, 'stdby_power', 'off') ;
        add_schedule (timer_2, 'stdby_power', 'normal') ;
        
        
        -------------------------------------
        add_schedule (0, 'POV', 'FE-rovh') ; 
        add_schedule (3, 'radio_master_ess', 'on') ;
        add_schedule (2, 'radio_master_n2', 'on') ;
        add_schedule (2, 'nav_lights', 'on') ;
        
        add_schedule (2, 'logo_lights', 'on') ;
        
        add_schedule (0, 'POV', 'FE-insovh') ; 
        add_schedule (2, 'ins_1_ovh', 'stdby') ;
        add_schedule (timer_2, 'ins_1_ovh', 'align') ;
        add_schedule (timer_2, 'ins_2_ovh', 'stdby') ;
        add_schedule (timer_2, 'ins_2_ovh', 'align') ;
        add_schedule (timer_2, 'ins_3_ovh', 'stdby') ;
        add_schedule (timer_2, 'ins_3_ovh', 'align') ;
        
        add_schedule (0, 'POV', 'FE-rovh') ; 
        add_schedule (2, 'no_smoking', 'on') ;
        add_schedule (timer_2, 'fasten_belts', 'on') ;
end 


---------------------------------------------------
function enq_powering () 
---------------------------------------------------
--- Now we have power !
        if (SUN_PITCH < 0 ) then
           add_schedule (timer_2, 'light_front_panel', 0.5 ) ;
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
        add_schedule (timer_2, 'galley_pwr', 'on', 2) 
        add_schedule (timer_2, 'galley_pwr', 'on', 3) 
        add_schedule (timer_2, 'galley_pwr', 'on', 4) 
        -- 
        
        add_schedule (0, 'galley_control_gen', 'norm' )
        add_schedule (timer_2, 'galley_control_fan', 'auto' )
        
        add_schedule (timer_2, 'galley_chiller', 'on', 1 ) 
        add_schedule (timer_2, 'galley_chiller', 'on', 2 )
        add_schedule (timer_2, 'galley_chiller', 'on', 3 )
        
        end 
        
---------------------------------------------------
function enq_press_from_apu () 
---------------------------------------------------
        -- air valves
        add_schedule (2, 'air_valves', 'close' )
        add_schedule (0, 'pack_valves', 'close' )
        add_schedule (0, 'isolation_valves', 'close' )
        
        add_schedule (timer_2, 'apu_bleed_air', 'open' )
        
        add_schedule (2, 'POV', 'FE-PACK') ; 
        add_schedule (timer_2, 'isolation_valves', 'open', 1  )
        add_schedule (4, 'isolation_valves', 'open', 2  )
        
        
        
        
        add_schedule (4, 'pack_controls', 'auto' )
        
        add_schedule (2, 'pack_meters', 'pack1' ) ;
        add_schedule (timer_2, 'pack_valves', 'open', 1 )
        add_schedule (4, 'pack_meters', 'pack2' ) ;
        add_schedule (timer_2, 'pack_valves', 'open', 2 )
        add_schedule (4, 'pack_meters', 'pack3' ) ;
        add_schedule (timer_2, 'pack_valves', 'open', 3 )
        
        
        add_schedule (8, 'pack_controls', 'auto')
        
        add_schedule (timer_2, 'recirculating_fans', 'on', 2 ) 
        add_schedule (timer_2, 'recirculating_fans', 'on', 3 ) 
        add_schedule (timer_2, 'recirculating_fans', 'on', 4 ) 
        add_schedule (timer_2, 'gasper', 'on')
       
        
        add_schedule (timer_2, 'trim_air', 'open')
        add_schedule (timer_2, 'heat_mode', -30 , 1)
        add_schedule (timer_2, 'heat_mode', -30 , 2)
        add_schedule (timer_2, 'heat_mode', -30 , 3)
        add_schedule (timer_2, 'heat_mode', -30 , 4)
        add_schedule (timer_2, 'heat_mode', -30 , 5)

end 

 -----------------------------------------------------------------------------------------
function add_schedule (delay, equipment, status, number)  
 
-- delay = -1 if init 
    local nbsch = table.getn(enqueue) + 1
    timer_utc=timer_utc + delay
    enqueue[nbsch] = {}
    
    enqueue[nbsch]['type']='action' 
    if (delay < 0  ) then 
       enqueue[nbsch]['time']=UTC_SECONDS-delay
    else 
       enqueue[nbsch]['time']= nil 
       enqueue[nbsch]['pre_delay']=delay
       end  
    enqueue[nbsch]['equipment']= equipment
    if ( number ) then enqueue[nbsch]['number']= number end 
    if ( status ) then enqueue[nbsch]['status']= status end 
    --- default processing
    if (nbsch>1) then
       enqueue[nbsch-1]['next']={}
       enqueue[nbsch-1]['next'][1]=nbsch 
       end 
    if (equipment == 'END') then cl_act_end = nbsch end 
    return nbsch
    end
    
    
   
function add_test (delay, delayout, equipment, number, status , minval, maxval)  
 
    -- delay = -1 if init 
    local nbsch = table.getn(enqueue) + 1
    timer_utc=timer_utc + delay
    if (delayout ~= nil and delayout > 0 ) then 
       time_out_utc = timer_utc + delayout
    else 
       time_out_utc = timer_utc + 20
       end 
       
       
    enqueue[nbsch] = {}
    enqueue[nbsch]['type']='test'
    
    if (delay < 0  ) then 
       enqueue[nbsch]['time']=UTC_SECONDS-delay
       enqueue[nbsch]['pre_delay']=-delay 
    else 
       enqueue[nbsch]['time']= nil 
       enqueue[nbsch]['pre_delay']=delay
       end
         
    enqueue[nbsch]['equipment']= equipment
    if ( delayout ) then enqueue[nbsch]['delayout']= delayout end
    if ( number ) then enqueue[nbsch]['number']= number end 
    if ( minval ) then enqueue[nbsch]['minval']= minval end 
    if ( maxval ) then enqueue[nbsch]['maxval']= maxval end 
    if ( status ) then enqueue[nbsch]['status']= status end
    
    --- default processing
    if (nbsch>1) then
       enqueue[nbsch-1]['next']={}
       enqueue[nbsch-1]['next'][1]=nbsch 
       end 
    
    return nbsch
    
   
   end 
  
   
 -----------------------------------------------------------------------------------------
 function get_acft_status ()  
  
  meters_above_ground = get("sim/flightmodel/position/y_agl")
  feet_above_ground = meters_above_ground / 3.28084
  
  if (DAY_IN_YEAR ~= b742_day_stamp) then
     b742_time_stamp = UTC_SECONDS + (24*3600) 
  else
     b742_time_stamp = UTC_SECONDS ;
     end 
  
    
  
  
  SecondsZ = UTC_SECONDS
  HourZ=math.floor(SecondsZ/3600)
  MinutesZ=math.floor(SecondsZ-(HourZ*3600))
  
  HourZ=string.format("%.2f",SecondsZ/3600 ) 
  CurrentSaveNam=PLANE_TAILNUMBER.."-D"..string.format("%03d", get("sim/time/local_date_days")) .."-"..HourZ 
  
  
  
  --- List of saves in save directory
  if (SaveDir and active_panel == 3 ) then -- 
     --- print (SaveDir)
     tableSav = directory_to_table( ValidatedSaveDir )
     
     --- Load saves 
     for k in pairs (CockpitSaves) do
        CockpitSaves [k] = nil
        end
     NbCockpitSaves =  0 
     for i,filename in ipairs(tableSav) do
        if (string.sub(filename, -5 ) == '.b742' ) then 
           NbCockpitSaves = NbCockpitSaves + 1  
           table.insert(CockpitSaves, string.sub(filename, 1, -6) )
           end 
        end 
     end
     
  --- Check if saving dir is writab le  
  if (TmpSaveDir ~= ValidatedSaveDir and active_panel == 2 ) then
    fileTst = io.open(TmpSaveDir..'/test.txt', "w")
    if ( fileTst ) then
       DirIsWritable = true
       io.close(fileTst)
       os.remove(TmpSaveDir..'/test.txt')    
    else 
       DirIsWritable = false   
       end
    end    
  
  if ( timer_backup and (UTC_SECONDS > ( timer_backup +10))  ) then 
     ActiveCockpitSave = {} 
     sizeimmediate = 0 
     end
  
  -----  Autosave 
  if (ActiveAutoSave['nb_in_cycle'] and ActiveAutoSave['interval'] and ActiveAutoSave['prefix']) then
     if (not LastAutoSaveTs or ( LastAutoSaveTs < (b742_time_stamp - (ActiveAutoSave['interval']*60) ) ) ) then 
        -- Autosaving
        if ( not LastAutoSaveNum ) then 
           LastAutoSaveNum = 0 
        else
           LastAutoSaveNum = LastAutoSaveNum + 1 
           end 
        AutoSaveName=ActiveAutoSave['prefix']..string.format("%02d",( LastAutoSaveNum % ActiveAutoSave['nb_in_cycle']  ) + 1 ) 
        save_742_sit (1, AutoSaveName) 
        LastAutoSaveTs = b742_time_stamp 
        end  
     end 
  
  if (active_panel ~= 2 ) then FutureSaveNam = nil end 
  
  
  if (meters_above_ground and meters_above_ground > 10) then
     airborne_flag = true 
     onground_flag = false
     was_airborne_flag = true 
  else
     airborne_flag = false
     onground_flag = true 
     end 
   
  alt_ft_pilot = get("sim/cockpit2/gauges/indicators/altitude_ft_pilot")   
  if (alt_ft_pilot > 10500) then was_over_10k = true end 
  
  current_alt_meter = get("sim/flightmodel/position/elevation") 
  current_alt_ft = current_alt_meter * 3.28084
  
  -- Baro settings
  -- sim/cockpit/misc/barometer_setting2
  -- sim/cockpit/misc/barometer_setting
  
  -- 5 on chocks, 1 = parking brakes  
  on_chocks = get ( interfaces['chocks']['dataref'] ) ;
    
   ---- 
   current_QNH_inhg = get ("sim/weather/barometer_sealevel_inhg")
   current_QNH_hpa = current_QNH_inhg * 33.864
   -- Fuel in tanks kg
   fuel_kg_center = get (interfaces['fuel_in_tanks_kg']['dataref'], 0 )
   fuel_kg_main_1 = get (interfaces['fuel_in_tanks_kg']['dataref'], 1 )
   fuel_kg_main_2 = get (interfaces['fuel_in_tanks_kg']['dataref'], 2 )
   fuel_kg_main_3 = get (interfaces['fuel_in_tanks_kg']['dataref'], 3 )
   fuel_kg_main_4 = get (interfaces['fuel_in_tanks_kg']['dataref'], 4 )
   fuel_kg_rese_1 = get (interfaces['fuel_in_tanks_kg']['dataref'], 5 )
   fuel_kg_rese_4 = get (interfaces['fuel_in_tanks_kg']['dataref'], 6 )
   fuel_r1 = string.format("%.1f", tonumber(fuel_kg_rese_1)/1000 )
   fuel_1 = string.format("%.1f", tonumber(fuel_kg_main_1)/1000 )
   fuel_2 = string.format("%.1f", tonumber(fuel_kg_main_2)/1000 )
   fuel_c = string.format("%.1f", tonumber(fuel_kg_center)/1000 )
   fuel_3 = string.format("%.1f", tonumber(fuel_kg_main_3)/1000 )
   fuel_4 = string.format("%.1f", tonumber(fuel_kg_main_4)/1000 )
   fuel_r4 = string.format("%.1f", tonumber(fuel_kg_rese_4)/1000 )
    
   --- 742 Aircraft status 
  EXT1_volts = string.format("%03d",get ("B742/INT_elec/AC_gen_volt", 6  ) )
  EXT1_freq = string.format("%03d",get ("B742/INT_elec/AC_gen_freq", 6  )) 
  EXT2_volts = string.format("%03d",get ("B742/INT_elec/AC_gen_volt", 7  ) )
  EXT2_freq = string.format("%03d",get ("B742/INT_elec/AC_gen_freq", 7 )) 
      
      
  TR_bus_volt_1 = string.format("%02d",get ("B742/INT_elec/DC_TR_volt_1"  ) ) 
  TR_bus_amp_1 =  string.format("%02d",get ("B742/INT_elec/DC_TR_amp_1"  ))
  TR_bus_volt_2 = string.format("%02d",get ("B742/INT_elec/DC_TR_volt_2"  ) )
  TR_bus_amp_2 =  string.format("%02d",get ("B742/INT_elec/DC_TR_amp_2"  ))
  TR_bus_volt_3 = string.format("%02d", get ("B742/INT_elec/DC_TR_volt_3"  ) )
  TR_bus_amp_3 =  string.format("%02d", get ("B742/INT_elec/DC_TR_amp_3"  ))
  TR_bus_volt_ESS = string.format("%02d",get ("B742/INT_elec/DC_TR_volt_ESS"  ) )
  TR_bus_amp_ESS =  string.format("%02d",get ("B742/INT_elec/DC_TR_amp_ESS"  ))
      
      --- manifold pressure
  pressure1 = get ("B742/INT_air/manifol_press" , 0 )
  pressure2 = get ("B742/INT_air/manifol_press" , 1 )
  pressure3 = get ("B742/INT_air/manifol_press" , 2 )
      
      -- N2
  N2_1 = get ("B742/INT_eng/corrected_N2" , 0 )
  N2_2 = get ("B742/INT_eng/corrected_N2" , 1 )
  N2_3 = get ("B742/INT_eng/corrected_N2" , 2 )
  N2_4 = get ("B742/INT_eng/corrected_N2" , 3 )
      -- N1
  N1_1 = get ("B742/INT_eng/corrected_N1" , 0 )
  N1_2 = get ("B742/INT_eng/corrected_N1" , 1 )
  N1_3 = get ("B742/INT_eng/corrected_N1" , 2 )
  N1_4 = get ("B742/INT_eng/corrected_N1" , 3 )
  
  
  
  
       
      
  allign_mode1 = get (interfaces['ins_perf_index']['dataref'], 0 ) 
  insope1 = get ("B742/INT_INS/oper_mode" , 0 ) 
      --- local inspre1 = get ("B742/INT_INS/precission_index" , 0 ) 
  inspi1 = get ("B742/INT_INS/PI_number" , 0 ) 
      
  allign_mode2 = get (interfaces['ins_perf_index']['dataref'], 1 ) 
  insope2 = get ("B742/INT_INS/oper_mode" , 1 ) 
      --- local inspre2 = get ("B742/INT_INS/precission_index" , 1 ) 
  inspi2 = get ("B742/INT_INS/PI_number" , 1 )
      
  allign_mode3 = get (interfaces['ins_perf_index']['dataref'], 2 ) 
  insope3 = get ("B742/INT_INS/oper_mode" , 2 ) 
      --- local inspre3 = get ("B742/INT_INS/precission_index" , 2 ) 
  inspi3 = get ("B742/INT_INS/PI_number" , 2 ) 
      
     
  APU1_volts = string.format("%03d",get ("B742/INT_elec/AC_gen_volt", 4  ))
  APU1_freq = string.format("%03d",get ("B742/INT_elec/AC_gen_freq", 4  ))
  APU2_volts = string.format("%03d",get ("B742/INT_elec/AC_gen_volt", 5  )) 
  APU2_freq = string.format("%03d",get ("B742/INT_elec/AC_gen_freq", 5  ))  
  
   end 
  
   
 -----------------------------------------------------------------------------------------
 function monitor_cl () 
 
 --- Check blinking alarms
 --[[ 
 if (get (interfaces['instr_warn_button_lit_L']['dataref'])==1 ) then 
    instrument_warn_l = UTC_SECONDS
    end 
 if (get (interfaces['instr_warn_button_lit_R']['dataref'])==1 ) then 
    instrument_warn_r = UTC_SECONDS
    end 
 --]]
    
 --  every second or every frame
 if not SUPPORTS_FLOATING_WINDOWS then
    print_msg () 
    end 
  
  
  
  --- Activate menus
  --- DataRef( "INS_ALIGN", "B742/INT_INS/allign_mode")
  -- Menu cl_ins_init_pos
  -- 
  -- 
  -- 
  -- 
  if  onground_flag and on_chocks >=5    then
     check_lists[cl_fe_init]['active']=true 
  else 
     check_lists[cl_fe_init]['active']=false 
     end
  -- 
  if  onground_flag and on_chocks >=5    then
     check_lists[cl_ovh_checks]['active']=true 
  else 
     check_lists[cl_ovh_checks]['active']=false 
     end
  
  -- 
  if  onground_flag and on_chocks >=5    then
     check_lists[cl_panel_check]['active']=true 
  else 
     check_lists[cl_panel_check]['active']=false 
     end
  -- 
  --  
  if (cl_ins_init_pos ) then 
    if (get(interfaces['ins_perf_index']['dataref'] , 0  ) > get(interfaces['ins_desired_PI']['dataref'] , 0  )   ) then
       check_lists[cl_ins_init_pos]['active']=false 
    else 
       check_lists[cl_ins_init_pos]['active']=true
       end 
     end 
  --[[  
  if (cl_ovh_checks ) then 
    if (get(interfaces['ins_perf_index']['dataref'] , 0  ) > get(interfaces['ins_desired_PI']['dataref'] , 0  )   ) then
       check_lists[cl_ovh_checks]['active']=false 
    else 
       check_lists[cl_ovh_checks]['active']=true
       end 
     end 
     ]]
     
     
     
  -- if EXT power avail   
  if ( (get (interfaces['ac_gen_volt']['dataref'] , 6 ) > 100 ) and (get (interfaces['ac_volts_bus_1']['dataref']) == 0  ) and onground_flag and on_chocks >=5   ) then
     check_lists[cl_power_ext]['active']=true 
  else 
     check_lists[cl_power_ext]['active']=false 
     end 
     
  -- cl power plane with apu  
  if ( (get (interfaces['ac_gen_freq']['dataref'] , 4 ) > 100 )  or ( get (interfaces['ac_volts_bus_1']['dataref']) > 0  )  or not onground_flag or on_chocks < 5 ) then
     check_lists[cl_power_apu]['active']=false
  else 
     check_lists[cl_power_apu]['active']=true 
     end 
     
  -- C/L apu + pressure  
  if ((get (interfaces['ac_gen_freq']['dataref'] , 4 ) > 100) or not onground_flag or on_chocks < 5 ) then
     check_lists[cl_apu_pressure]['active']=false
     
  else 
     check_lists[cl_apu_pressure]['active']=true
     end
     
  -- C/L before start  
  if (N1_1 < 2 and  N1_2 < 2 and  N1_3 < 2 and N1_4 < 2 ) and (pressure1 > 1 and pressure2 > 1 ) and onground_flag then
     check_lists[cl_before_start]['active']=true
     
  else 
     check_lists[cl_before_start]['active']=false
     end  
     
  -- C/L start 4 engines 
  if (N1_1 < 2 and  N1_2 < 2 and  N1_3 < 2 and N1_4 < 2 )   and (pressure1 > 1 and pressure2 > 1 ) and onground_flag  then
     check_lists[cl_start_all]['active']=true 
  else 
     check_lists[cl_start_all]['active']=false
     end 
     
 -- C/L taxi  
  if onground_flag and N1_1 > 5  and  N1_2 > 5 and  N1_3 > 5 and N1_4 > 5  then
     check_lists[cl_taxi]['active']=true
     
  else 
     check_lists[cl_taxi]['active']=false
     end  
  
  -- C/L before T/O  
  if onground_flag and N1_1 > 5  and  N1_2 > 5 and  N1_3 > 5 and N1_4 > 5 then
     check_lists[cl_before_to]['active']=true
  else 
     check_lists[cl_before_to]['active']=false
     end  
     
 -- C/L after T/O  
  if airborne_flag then
     check_lists[cl_after_to]['active']=true
  else 
     check_lists[cl_after_to]['active']=false
     end  
     
  -- C/L passing 10000 
  if alt_ft_pilot > 10000 then
     check_lists[cl_climb_10000]['active']=true
  else 
     check_lists[cl_climb_10000]['active']=false
     end  
     
  -- C/L descending 10000 
  if was_over_10k and alt_ft_pilot < 10000 then
     check_lists[cl_descent_10000]['active']=true
  else 
     check_lists[cl_descent_10000]['active']=false
     end 
     
     
  -- C/L taxi after landing 
  if onground_flag and was_airborne_flag then
     check_lists[cl_taxi_after_ld]['active']=true
  else 
     check_lists[cl_taxi_after_ld]['active']=false
     end 
  
  -- C/L Parking 
  if onground_flag and was_airborne_flag then
     check_lists[cl_parked]['active']=true
  else 
     check_lists[cl_parked]['active']=false
     end 
  
  
  -- C/L End of flight 
  if onground_flag and was_airborne_flag then
     check_lists[cl_end_flight]['active']=true
  else 
     check_lists[cl_end_flight]['active']=false
     end
     
     
     
  
  -- If complete 
  if (current_cl_num > 0  and check_lists[current_cl_num]['complete']) then
     check_lists[current_cl_num]['active']=false
     end 
     
  
     
     
  --[[ 
  local EXT1_volts = get ("B742/INT_elec/AC_gen_volt", 6  ) 
       local EXT1_freq = get ("B742/INT_elec/AC_gen_freq", 6  )
       imgui.TextUnformatted("EXT 1 = "..EXT1_volts.."V "..EXT1_freq.."Hz" )
  --- Align 
  local ins10 = get ("B742/INT_INS/allign_mode" , 0 )
  local ins11 = get ("B742/INT_INS/allign_mode" , 1 )
  local ins12 = get ("B742/INT_INS/allign_mode" , 2 ) 
  
  
  --- DataRef( "INS_ALIGN", "B742/INT_INS/allign_mode")
  local volt1 = get ("B742/INT_elec/DC_TR_volt_1" )
  local amp1 = get ("B742/INT_elec/DC_TR_amp_1" )
  local bvolt1 = get ("B742/INT_elec/DC_bus_volt_1" )
   local bamp1 = get ("B742/INT_elec/DC_bus_amp_1" )
  ]] 
    
  local Act_Success = false 
  local Act_Failure = false
  local Act_delay = false 
   
   local actions_to_remove = {} 
   if ( table.getn(enqueue) > 0 ) then
      ----- Loop on actions in the queue 
      for i, action in ipairs(enqueue) do
         if (action['time'] and action['time'] <= UTC_SECONDS ) then
            
            if (action['type']=='action') then 
            -------------------------------------------
               do_action(action['equipment'], action['status'], action['number'])
               Act_Success = true 
               
           
            elseif (action['type']=='test') then
            ------------------------------------------- 
            
               if (action['delayout']) then 
                   action['timeout']=action['time']+action['delayout']  
               else  
                  action['timeout'] = action['time']
                  end 
               
               
               tst = do_test(action['equipment'], action['status'] , action['minval'], action['maxval'], action['number'])
               
               if (tst) then
                  Act_Success = true  
                   MsgAddQ("- test "..action['equipment'].." OK ") 
               else 
                 if (action['timeout'] <= UTC_SECONDS) then
                    --- Failure
                   Act_Failure = true
                   MsgAddQ("- test "..action['equipment'].." not OK ", 4 )  
                 else 
                   Act_delay = true
                   
                   end  
                 end 
               
                
               end 
                
            
            local next_action 
            --- schedule next action
            if (action['next'] and action['next'][1] and Act_Success ) then 
              next_action = action['next'][1] 
              if ( enqueue[next_action] ) then  enqueue[next_action]['time']=UTC_SECONDS+ enqueue[next_action]['pre_delay'] end 
              end  
              
            --- if failure end of cl
            if (Act_Failure ) then 
               --- local act_failure =  add_schedule (3, 'TITLE', 'Condition on '..action['equipment']..'failed !') ;
               --- enqueue[act_failure]['time']=UTC_SECONDS 
               --- add_schedule (timer_20, 'END', ' end ')  
               --- do_action('END', status, number)
               
               if (action['error'] and action['error'][1])  then
                  next_action = action['error'][1]
                  enqueue[next_action]['time']=UTC_SECONDS+ enqueue[next_action]['pre_delay']
                  
               elseif ( cl_act_end and enqueue[cl_act_end] ) then 
                  enqueue[cl_act_end]['time']=UTC_SECONDS+ enqueue[cl_act_end]['pre_delay']
                  end 
                
               end   
              
            --- Suppress this action from scheduler
            if (Act_Success or Act_Failure ) then 
              enqueue[i]['time']=nil ;
              actions_to_remove[i]= i ;
              end 
            
            end 
         end  
         --- End of loop on actions 
         if (current_cl_num == 0) then 
            -- Purge queue
            for i in ipairs(enqueue) do
               enqueue[i] = nil 
               end 
            end 
      end 
end




function do_test(equipment, status , minval , maxval, number)
-----------------------------------------------------------
-- 
local tst_result = true 
local LocMin 
local LocMax

if (minval ) then LocMin = tonumber(minval) end 
if (maxval ) then LocMax = tonumber(maxval) end 
if (status and interfaces[equipment]['values'][status]) then
   delta = math.abs(tonumber(interfaces[equipment]['values'][status]))*0.02
   LocMin = tonumber(interfaces[equipment]['values'][status]) - delta
   LocMax = tonumber(interfaces[equipment]['values'][status]) + delta
   end 
 
if (interfaces[equipment] == nil or not interfaces[equipment])  then 
   MsgAddQ("!! Equipment "..equipment.." not found !!", 4 )  
   return false 
else 
   local Eqt=interfaces[equipment] 
-- read equipt val
   local eqt_read = get(Eqt['dataref'])
   
   --- print_debug(equipment.." read --> "..eqt_read )    
   
 
   
   if (Eqt['readmin'] and Eqt['readmax'] and Eqt['valmin'] and Eqt['valmax'] and ( Eqt['readmax'] ~= Eqt['readmin'] ) ) then
      --- print_debug(equipment.." min et max definis " ) 
      eqt_val =  ((eqt_read-Eqt['readmin'])/(Eqt['readmax']-Eqt['readmin']))  * (Eqt['valmax']-Eqt['valmin']) + Eqt['valmin']
   else 
      eqt_val = tonumber(eqt_read)  
      end 
      
   --- print_debug(equipment.." val ==> "..eqt_val )
      
   
   
   if (LocMin ) then 
      if (eqt_val < LocMin ) then return false end 
      end 
         
   if (LocMax ) then
      if (eqt_val >  LocMax ) then return false end 
      end
      
   
   end 
return tst_result
end 






function do_action(equipment, status, number) 
----------------------------------------------------------- 
---- 
    
   local Prereq = true -- default : OK
   
   
   
   if (equipment=='END') then -- end of all 
       msg_to_display['title'] = false 
       set_pov( 'INIT' ) 
       if (msg_to_display['lines']) then 
         for k in pairs (msg_to_display['lines']) do
            msg_to_display['lines'][k] = nil
            end
          end 
        
       current_cl_num = 0
       
   elseif (equipment=='OK') then
    if (status and check_lists[status] ) then 
      print_debug("CL "..status.." finished ")
      check_lists[status]['complete']=true
    else 
      print_debug("CL "..current_cl_num.." finished ")
      check_lists[current_cl_num]['complete']=true 
      end  
      
   elseif (equipment=='TITLE') then
      msg_to_display['title'] = status
      
   elseif (equipment=='WAIT') then
      -- Do nothing
      
   elseif (equipment=='MSG') then
      MsgAddQ(status) 
      
   elseif (equipment=='ERROR') then
      MsgAddQ(status, 2 ) 
      
   elseif (equipment=='POV')  then 
      set_pov( status )
       
   elseif (interfaces[equipment] == nil or not interfaces[equipment])  then 
      MsgAddQ("!! Equipment "..equipment.." not found !!", 4 )   
      
      
      
   else 
     print_debug(equipment.." --> "..status ) 
     if (number ~= nil ) then 
        index_eqt=tonumber(number)-1
        MsgAddQ("- "..equipment.." #"..index_eqt.." to '"..status..'"')  
     else
        index_eqt= false
        MsgAddQ("- "..equipment.." to '"..status.."'") 
        end
     
     if ( not interfaces[equipment]) then
         print_debug(" !!! Action Eqt :  "..equipment.." not found ")
         return
     else 
         Eqt=interfaces[equipment] 
         end
     
     if ( ( interfaces[equipment]['values'] == nil or not interfaces[equipment]['values'] )  and status ~= nil ) then 
        value_to_affect = status    
        
     elseif (interfaces[equipment]['values'][status] ~= nil ) then
        value_to_affect =   interfaces[equipment]['values'][status] 
        end 
     
     if (Eqt['readmin'] and Eqt['readmax'] and Eqt['valmin'] and Eqt['valmax'] and ( Eqt['valmax'] ~= Eqt['valmin'] ) ) then
         --- eqt_read = (eqt_val + Eqt['valmin']) / (Eqt['valmax']-Eqt['valmin']) * (Eqt['readmax']-Eqt['readmin']) + Eqt['readmin'] 
         value_to_affect = ((value_to_affect - Eqt['valmin']) / (Eqt['valmax']-Eqt['valmin']) * (Eqt['readmax']-Eqt['readmin'])) + Eqt['readmin']            
        end 
     
      
     
     if (interfaces[equipment]['pilot_head'] ) then set_pov( interfaces[equipment]['pilot_head'] ) end
      
     if ( equipment == 'aux_power_1' and status == 'close') then --- Check if there is external power
        is_gpu1 = get ( interfaces['AC1_conn']['dataref'] ) ;
        if (is_gpu1 == nil or is_gpu1 ==  0  ) then
           print_debug("   !!!  External power not available." ) 
           Prereq = false 
           end
           
     elseif (equipment == 'aux_power_2' and status == 'close') then  --- Check if there is external power
        is_gpu2 = get ( interfaces['AC2_conn']['dataref'] ) ;
        if (is_gpu2 == nil or is_gpu2 ==  0  ) then
           print_debug("!!!  External power not available." ) 
           Prereq = false 
           end
        
        end
        
     
     
     if (Prereq and value_to_affect ~= nil ) then
        
        if (equipment == 'battery' and status == 'off') then  
           set ( interfaces['battery_cap']['dataref'], interfaces[equipment]['values']['open'] ) ;
           end 
     
        --- single dataref type = 1
        if ( interfaces[equipment]['type']==1 ) then 
           print_debug("Dataref "..interfaces[equipment]['dataref'].." set to "..value_to_affect)    
           set ( interfaces[equipment]['dataref'], value_to_affect ) ; 
           
         --- type 2 array 
        elseif ( interfaces[equipment]['type']==2 and  interfaces[equipment]['size_a'] > 0 ) then
           if (index_eqt and index_eqt < interfaces[equipment]['size_a']) then 
             
              print_debug("Dataref "..interfaces[equipment]['dataref'].."["..index_eqt.."] set to "..value_to_affect) 
              set_array ( interfaces[equipment]['dataref'], index_eqt, value_to_affect ) ; 
           else    
              for index=0,interfaces[equipment]['size_a']-1,1 do
           
                 print_debug("Dataref  "..interfaces[equipment]['dataref'].."["..index.."] set to "..value_to_affect) 
                 set_array ( interfaces[equipment]['dataref'], index, value_to_affect ) ; 
                 end
              end 
              
        ---- Type 3 radio button 
        elseif ( interfaces[equipment]['type']==3 and  interfaces[equipment]['size_a'] > 0 ) then 
           if (status == 0 )  then
              --- All to 0
               index_to_set = tonumber(interfaces[equipment]['size_a']) + 1 
           elseif (interfaces[equipment]['values'][status] > interfaces[equipment]['size_a'] or interfaces[equipment]['values'][status] < 0)  then
              if (interfaces[equipment]['default'] ) then
                 index_to_set = interfaces[equipment]['default'] - 1
              else 
                 print_debug("  --> default 0 ")
                 index_to_set = 0 
                 end
           else 
              
              index_to_set =  interfaces[equipment]['values'][status]-1 
              print_debug(" --> "..index_to_set)
              end 
           
           for index=0,interfaces[equipment]['size_a'],1 do
                 if ( index == index_to_set) then 
                    print_debug("---> set "..interfaces[equipment]['dataref'].."["..index.."] to 1 ")
                    set_array ( interfaces[equipment]['dataref'], index, 1  ) ; 
                 else 
                    print_debug("---> set "..interfaces[equipment]['dataref'].."["..index.."] to 0 ")
                    set_array ( interfaces[equipment]['dataref'], index, 0  ) ;
                    end 
                 end   
           end
           
           
        --- if (equipment == 'battery' and status == 'on') then  BATTERY_CAP =  0     end
            
     elseif (Prereq)  then 
        print_debug("   !!!  no status  /"..status.. "/ for equipment "..equipment )  
        end
        
     end      
   end 
 
 --------------------------------------------------------------------------------  
 function set_pov( phpos )
  if ( flag_move_pov) then
     if (phpos == 'INIT' ) then 
        set_pilots_head(pilot_head_init['X'], pilot_head_init['Y'], pilot_head_init['Z'], pilot_head_init['PSI'], pilot_head_init['THE']) 
     elseif (pilot_pov[phpos] ) then 
        set_pilots_head(pilot_pov[phpos]['x'], pilot_pov[phpos]['y'], pilot_pov[phpos]['z'], pilot_pov[phpos]['psi'], pilot_pov[phpos]['the'])
        end
        
     end 
      
  
     end 
     

   
-------------------------------------------------------------------------------------------------------------    
function print_debug (Msg) 
 if (Msg and flag_debug ) then logMsg("742vfe: "..Msg ) end
end 
   
-------------------------------------------------------------------------------------------------------------    
function load_interfaces () 
 
local xfile = xml.load(SCRIPT_DIRECTORY .."742vfe/742vfe-data.xml")
  
  
 ieqt = 0 
 ipov = 0
 
 size = table.getn(xfile)
 for i, bloc_lvl1 in ipairs(xfile) do
  
    
    if ( bloc_lvl1[0] == 'cmd' ) then 
      ieqt = ieqt + 1 
      
      --- print( '   name = '.. bloc_lvl1.name.." type=".. bloc_lvl1.type )
      interfaces[bloc_lvl1.name]= {} 
      interfaces[bloc_lvl1.name]['dataref']= bloc_lvl1.dataref
      interfaces[bloc_lvl1.name]['type']= tonumber(bloc_lvl1.type)
      current_eqt = bloc_lvl1.name 
      
      --- if (bloc_lvl1.pilot_head) then interfaces[bloc_lvl1.name]['pilot_head']= bloc_lvl1.pilot_head end 
      if (bloc_lvl1.readmin) then interfaces[bloc_lvl1.name]['readmin']= tonumber(bloc_lvl1.readmin) end 
      if (bloc_lvl1.valmin) then interfaces[bloc_lvl1.name]['valmin']= tonumber(bloc_lvl1.valmin) end 
      if (bloc_lvl1.readmax) then interfaces[bloc_lvl1.name]['readmax']= tonumber(bloc_lvl1.readmax) end 
      if (bloc_lvl1.valmax) then interfaces[bloc_lvl1.name]['valmax']= tonumber(bloc_lvl1.valmax) end 
      
      if (bloc_lvl1.size_a) then interfaces[bloc_lvl1.name]['size_a']= tonumber(bloc_lvl1.size_a) end 
      if (bloc_lvl1.default) then interfaces[bloc_lvl1.name]['default']= tonumber(bloc_lvl1.default) end 
      if (bloc_lvl1.readonly) then interfaces[bloc_lvl1.name]['readonly']= true end 
      ----- 
      if (table.getn(bloc_lvl1)>0) then 
        interfaces[bloc_lvl1.name]['values']={} 
        ival = 0 
        for j, name in ipairs( bloc_lvl1) do
          ival = ival + 1
          interfaces[bloc_lvl1.name]['values'][name.name]=tonumber(name.value) 
          end
        end 
  
     elseif (bloc_lvl1[0] == 'pilot_head') then
       ipov = ipov + 1 
       pilot_pov[bloc_lvl1.name]= {}
       pilot_pov[bloc_lvl1.name]['x']= bloc_lvl1.x
       pilot_pov[bloc_lvl1.name]['y']= bloc_lvl1.y
       pilot_pov[bloc_lvl1.name]['z']= bloc_lvl1.z
       pilot_pov[bloc_lvl1.name]['psi']= bloc_lvl1.psi
       pilot_pov[bloc_lvl1.name]['the']= bloc_lvl1.the
     end 
  
     end
  
   --- print_debug(" nb "..ieqt.." = "..current_eqt )
   end
   

-------------------------------------------------------------------------------------------------------------    
function save_current_view() 

file = io.open(SCRIPT_DIRECTORY .."742vfe/742-views.xml", "a")
io.output(file)
   --- DataRef( "PILOT_HEAD_X", "sim/aircraft/view/acf_peX")
   --- DataRef( "PILOT_HEAD_Y", "sim/aircraft/view/acf_peY")
   --- DataRef( "PILOT_HEAD_Z", "sim/aircraft/view/acf_peZ")

   --- DataRef( "PILOT_HEAD_PSI", "sim/graphics/view/pilots_head_psi")
   --- DataRef( "PILOT_HEAD_THE", "sim/graphics/view/pilots_head_the")
   
   io.write('\n<pilot_head name="aaa" x="'..PILOT_HEAD_X..'" y="'..PILOT_HEAD_Y..'" z="'..PILOT_HEAD_Z..'" psi="'..PILOT_HEAD_PSI..'" the="'..PILOT_HEAD_THE..'" /> ' ) 
   
   
   io.close(file) 

   end
   
-------------------------------------------------------------------------------------------------------------    
function save_742_config () 

file = io.open(SCRIPT_DIRECTORY .."742vfe/742-config.xml", "w")
if ( file ) then 
   io.output(file)
   
   io.write('\n<?xml version="1.0" encoding="iso-8859-1"?>' ) 
   io.write('\n<742config> ' ) 
   io.write('\n<cfg save_dir="'..ValidatedSaveDir..'" /> ' ) 
   io.write('\n</742config> ' ) 
   
   
   io.close(file)
   
   end  

end

------------------------------------------------------------------------------------------------------------    
function load_742_config () 

file = io.open(SCRIPT_DIRECTORY .."742vfe/742-config.xml", "r")
if ( file ) then 
local xfilecfg = xml.load(SCRIPT_DIRECTORY .."742vfe/742-config.xml")  
sizecfg = table.getn(xfilecfg)



for i, cfg_lvl1 in ipairs(xfilecfg) do
   if ( cfg_lvl1[0] == 'cfg' ) then
      ValidatedSaveDir =  cfg_lvl1.save_dir 
      end 
   
   end

   end

end 

-------------------------------------------------------------------------------------------------------------
function print_msg ()

local transparent_percent = 0.65
local x_lowerleft = 4       
local y_lowerleft = 500
local x_size = 220           
local y_size = 240  
local abstand = 4
local h_color= "white"
local w_color =  "cyan"
local g_color =  "green"

local x = x_lowerleft
local y = y_lowerleft
local nblines = 20 

   if (current_cl_num and current_cl_num > 0 and check_lists[current_cl_num]['title']) then 
   
    XPLMSetGraphicsState(0, 0, 0, 1, 1, 0, 0)

    -- draw the instrument's base
    glColor4f(0, 0, 0, transparent_percent)
    graphics.draw_rectangle( x, y, x+x_size, y+y_size )
    glColor4f(20, 20, 20, transparent_percent)
    graphics.set_width( 0.1 )
    graphics.draw_line(x, y, x, y + y_size)
    graphics.draw_line(x, y, x + x_size, y)
    graphics.draw_line(x, y + y_size, x + x_size, y + y_size)
    graphics.draw_line(x + x_size, y + y_size, x + x_size, y)
    
    draw_string( x + abstand + 5, y + y_size -25, check_lists[current_cl_num]['title'], h_color )
    
    ----- Then lines
    local idlin = 0 
    if (msg_to_display['lines'] and table.getn(msg_to_display['lines']) > 0 ) then
       local firsttd = math.max (table.getn(msg_to_display['lines']) - nblines + 1, 1 )
       --- firsttd = 1
       local lasttd = table.getn(msg_to_display['lines'])   
       for iline = firsttd , lasttd , 1  do 
          idlin = idlin+1 
          if ( iline == lasttd )  then 
             draw_string( x + abstand, y + y_size -30 - 10 * idlin  , msg_to_display['lines'][iline]['Msg'], g_color )
          else
             draw_string( x + abstand, y + y_size -30 - 10 * idlin  , msg_to_display['lines'][iline]['Msg'], w_color )
             end 
          end 
       end 
     
      
      end 
   end 
 
 ------------------------------------------------------------------------------------ 
 function MsgAddQ(MsgToAdd, isev ) --- add a line to msg queue
 -------------------------------------------------------------------------------------- 
    
    if ( isev and isev > 0 ) then table.insert(msg_to_display['lines'], { ["Msg"]=MsgToAdd, ["Sev"]=isev } )   
    else table.insert(msg_to_display['lines'], {  ["Msg"]=MsgToAdd, ["Sev"]= 0 } ) end 
    end 
    
  ------------------------------------------------------------------------------------    
 function save_pos ()
  ------------------------------------------------------------------------------------ 

 
file = io.open(SCRIPT_DIRECTORY .."742vfe/742-POV.xml", "w")
io.output(file)
 
   io.write('\n<742_pos name="new" x="'..get("sim/flightmodel/position/local_x")..'" y="'..get("sim/flightmodel/position/local_y")..'" z="'..get("sim/flightmodel/position/local_z")..'" /> ' ) 
   
  
   io.close(file) 


    end 
    
    
 ------------------------------------------------------------------------------------    
 function load_pos ()
 ------------------------------------------------------------------------------------ 
file = io.open(SCRIPT_DIRECTORY .."742-save.xml", "r")
   set ("sim/flightmodel/position/local_x", 26422.175169752)
   set ("sim/flightmodel/position/local_y", -20.500583274204)
   set ("sim/flightmodel/position/local_z", -26241.905447964)
   --- sim/flightmodel/position/q
   io.close(file) 


    end 
    
    
 ------------------------------------------------------------------------------------ 
 function activate_menu(id_menu)
 ------------------------------------------------------------------------------------
   if (id_menu == 1 ) then -- do lists
      local nwinLeft, nwinTop, nwinRight, nwinBottom = float_wnd_get_geometry(vfe_wnd)
       -- print_debug ("left="..nwinLeft.." right="..nwinRight.." top="..nwinTop.." bottom="..nwinBottom) 
       float_wnd_set_geometry(vfe_wnd, nwinLeft, nwinTop, nwinLeft + 250 , nwinTop - 500  ) 
       active_panel = 1 
       
   elseif ( id_menu == 2 ) then -- save
      local nwinLeft, nwinTop, nwinRight, nwinBottom = float_wnd_get_geometry(vfe_wnd)
       -- print_debug ("left="..nwinLeft.." right="..nwinRight.." top="..nwinTop.." bottom="..nwinBottom) 
       float_wnd_set_geometry(vfe_wnd, nwinLeft, nwinTop, nwinLeft + 700 , nwinTop - 500  ) 
       active_panel = 2
       
   elseif ( id_menu == 3 ) then -- load
       local nwinLeft, nwinTop, nwinRight, nwinBottom = float_wnd_get_geometry(vfe_wnd)
       -- print_debug ("left="..nwinLeft.." right="..nwinRight.." top="..nwinTop.." bottom="..nwinBottom) 
       float_wnd_set_geometry(vfe_wnd, nwinLeft, nwinTop, nwinLeft + 700 , nwinTop - 550  ) 
       active_panel = 3 
       
       end
       
   
   if (active_panel ~= 2 ) then
       TmpSaveDir= ValidatedSaveDir 
       end 
       
    end 
    
    
 ------------------------------------------------------------------------------------ 
 function draw_vfe_window(wnd, x, y)
 ------------------------------------------------------------------------------------
    win_width = imgui.GetWindowWidth()
    win_height = imgui.GetWindowHeight()
    win_x = x 
    win_y = y 
    local nblines = 24
    local cx, cy 
    
     
    --- Top level menu  
    if imgui.Button('Do List') then    
       activate_menu(1)
       end
        
    imgui.SameLine() 
    
    imgui.TextUnformatted( '747-200' ) 
    
    imgui.SameLine() 
    
    
    
    local ut_men_width, ut_men_height = imgui.CalcTextSize('Save_____Load')
    imgui.SetCursorPos(win_width  - ut_men_width , imgui.GetCursorPosY())
    if imgui.Button('Save') then
       activate_menu(2) 
       end
       
    imgui.SameLine() 
    if imgui.Button('Load') then
       activate_menu(3)
       end
    
    
       
    --- Separation    
     cx, cy = imgui.GetCursorScreenPos() 
     imgui.DrawList_AddLine(cx, cy, cx + imgui.GetWindowWidth() , cy  , 0xFF8D8C7F, 2)
     imgui.SetCursorPos(cx , cy + 6 )   
    
    --- Menu DO LIST ------------------------------------------------------------------------------------
    if (active_panel == 1) then 
    
    --- display list of c/l if no c/l 
    if  (current_cl_num == 0 ) then 
     
      if imgui.TreeNode("Aircraft status ("..string.format("%2d", b742_time_stamp-b742_time_start).."/"..string.format("%2d", b742_time_stamp)..")") then
      
         
        if ( on_chocks ) then imgui.TextUnformatted("Chocks ON" ) end  
      
        
    
        --- imgui.TextUnformatted("Session started (s) "..  )
        
        -- 
        
        imgui.TextUnformatted("DC "..TR_bus_volt_1.."V/"..TR_bus_amp_1.."A "..TR_bus_volt_2.."V/"..TR_bus_amp_2.."A "..TR_bus_volt_3.."V/"..TR_bus_amp_3.."A "..TR_bus_volt_ESS.."V/"..TR_bus_amp_ESS.."A " ) 
        imgui.TextUnformatted("EXT PWR "..EXT1_volts.."V/"..EXT1_freq.."Hz "..EXT2_volts.."V/"..EXT2_freq.."Hz" )
        imgui.TextUnformatted("APU GEN "..APU1_volts.."V/"..APU1_freq.."Hz "..APU2_volts.."V/"..APU2_freq.."Hz" )
        imgui.TextUnformatted("INS1 "..insope1.." "..allign_mode1..inspi1.." INS2 "..insope2.." "..allign_mode2..inspi2.." INS3 "..insope3.." "..allign_mode3..inspi3) 
        imgui.TextUnformatted("PRES "..string.format("%2d", pressure1).."PSI "..string.format("%2d", pressure2).."PSI "..string.format("%2d", pressure3).."PSI") 
        imgui.TextUnformatted("N2 "..string.format("%2d",N2_1 ).."% "..string.format("%2d",N2_2 ).."% "..string.format("%2d",N2_3 ).."% "..string.format("%2d",N2_4 ).."% ")
        imgui.TextUnformatted("N1 "..string.format("%2d",N1_1 ).."% "..string.format("%2d",N1_2) .."% "..string.format("%2d",N1_3).."% "..string.format("%0d",N1_4) .."% ")
        imgui.TextUnformatted("FUEL /"..fuel_r1.."/"..fuel_1.."/"..fuel_2.."/"..fuel_c.."/"..fuel_3.."/"..fuel_4.."/"..fuel_r4.."/") 
        
        imgui.TextUnformatted("Session started (s) ".. string.format("%2d", b742_time_stamp-b742_time_start).."/"..string.format("%2d", b742_time_stamp) )
        
        
        
        cx, cy = imgui.GetCursorScreenPos() 
        --- imgui.DrawList_AddLine(cx, cy, cx + imgui.GetWindowWidth() , cy  , 0xFF8D8C7F, 2)
        imgui.SetCursorPos(cx , cy + 10 ) 
        
        
        imgui.TreePop()
        end
        
            
      for i, clist in ipairs(check_lists) do
         if ((cl_after_to and i == cl_after_to) or (cl_taxi_after_ld and i == cl_taxi_after_ld )) then
               cx, cy = imgui.GetCursorScreenPos() 
               imgui.DrawList_AddLine(cx, cy, cx + imgui.GetWindowWidth() , cy  , 0xFF8D8C7F, 2)
               imgui.SetCursorPos(cx , cy + 6 )
               end 
         if ((clist['active'] and not clist['complete'])  or flag_all_cl ) then
            if imgui.Button(clist['title']) then
               check_and_do(i)
               end
         else 
            local text_width, text_height = imgui.CalcTextSize(clist['title'])
            cx, cy = imgui.GetCursorScreenPos()
            imgui.DrawList_AddRect(cx-2, cy+2, cx + text_width+8  , cy + text_height+8  , 0xFF8D8C7F, 0.5) 
            imgui.SetCursorPos(cx + 4 , cy + 5 )
            imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF8D8C7F)
            imgui.TextUnformatted(clist['title'])
            imgui.PopStyleColor()
            end 
         end
         
      --- imgui.TextUnformatted("INS1 performance : " .. ins10  )
      --- imgui.TextUnformatted("INS1 operating mode: " .. insope1  )
      --- imgui.TextUnformatted("INS1 precision : " ..inspre1   )
      --- imgui.TextUnformatted("INS1 precision number: " ..inspi1   )
      
      
      
       
      
      -- Display options
      cx, cy = imgui.GetCursorScreenPos() 
      imgui.DrawList_AddLine(cx, cy, cx + imgui.GetWindowWidth() , cy  , 0xFF8D8C7F, 2)
      imgui.SetCursorPos(cx , cy + 6 )    
      if ( not VR_ENABLED or VR_ENABLED == 0 ) then 
         local changed, newVal = imgui.Checkbox("Move pilot head", flag_move_pov)
         if changed then
           flag_move_pov = newVal
           end
         end 
      local changed2, newVal2 = imgui.Checkbox("Activate ALL DO lists", flag_all_cl)
         if changed2 then
           flag_all_cl = newVal2
           end
       
       local changed3, newVal3 = imgui.Checkbox("Bypass checks", not flag_checks)
         if changed3 then
           flag_checks = not newVal3
           end
         
       --[[   
       local ins10 = get ("B742/INT_INS/allign_mode" , 0 )
       local ins11 = get ("B742/INT_INS/allign_mode" , 1 )
       local ins12 = get ("B742/INT_INS/allign_mode" , 2 ) 
       
       imgui.TextUnformatted("INS1 "..insope1.." "..ins10..inspi1 )  
       
       local AC_bus_volt_1 = get ("B742/INT_elec/AC_bus_volt_1"  ) 
       local AC_bus_amp_1 = get ("B742/INT_elec/AC_bus_amp_1"  )
       imgui.TextUnformatted("AC_bus1= "..AC_bus_volt_1.."V "..AC_bus_amp_1.."A" )  
       
       local TR_bus_volt_1 = get ("B742/INT_elec/DC_TR_volt_1"  ) 
       local TR_bus_amp_1 = get ("B742/INT_elec/DC_TR_amp_1"  )
       imgui.TextUnformatted("AC_TR_bus1= "..TR_bus_volt_1.."V "..TR_bus_amp_1.."A" )  
       
       
       ]] 
       
          
    else --- CL in progress 
      local text = check_lists[current_cl_num]['title'] 
      local text_width, text_height = imgui.CalcTextSize(text)
      imgui.SetCursorPos(win_width / 2 - text_width / 2, imgui.GetCursorPosY())
      imgui.TextUnformatted(text)
        
      local idlin = 0 
      if (msg_to_display['lines'] and table.getn(msg_to_display['lines']) > 0 ) then
         local firsttd = math.max (table.getn(msg_to_display['lines']) - nblines + 1, 1 )
         --- firsttd = 1
         local lasttd = table.getn(msg_to_display['lines'])   
         for iline = firsttd , lasttd , 1  do 
            idlin = idlin+1 
            
            if ( msg_to_display['lines'][iline]['Sev']>0 ) then 
               imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF0000FF)
               imgui.TextUnformatted(msg_to_display['lines'][iline]['Msg'])
               imgui.PopStyleColor()
            elseif ( iline == lasttd )  then 
               imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
               imgui.TextUnformatted(msg_to_display['lines'][iline]['Msg'])
               imgui.PopStyleColor()
               
            else
               imgui.PushStyleColor(imgui.constant.Col.Text, 0xFFBDBDBD)
               imgui.TextUnformatted(msg_to_display['lines'][iline]['Msg'])
               imgui.PopStyleColor()
               end
                
            end 
         end 
     
      end -- end of CL in progress  
       
  ----------------------------------------------------------------------------------------    
  elseif  (active_panel == 2) then  --- Page Save
     -- 
     
     -- Save configuration
     if imgui.TreeNode("Configuration") then
        imgui.TextUnformatted("Where to save situations and 742 cockpits (255 chars max) : ") ;
        local changedDir, newSaveDir = imgui.InputText("N0", TmpSaveDir, 255)
        if changedDir then
           TmpSaveDir = newSaveDir
           end
        if (TmpSaveDir ~= ValidatedSaveDir and DirIsWritable ) then
           
            
           --- directory_to_table 
           -- io.open(TmpSaveDir..'/test.txt', "w")
           if imgui.Button('SAVE this directory') then
              ValidatedSaveDir = TmpSaveDir ; 
              save_742_config () 
              end 
              
           end
           
           
        imgui.TreePop()  
        end --- END of save configuration
      
     --- Separation    
     cx, cy = imgui.GetCursorScreenPos() 
     imgui.DrawList_AddLine(cx, cy, cx + imgui.GetWindowWidth() , cy  , 0xFF8D8C7F, 2)
     imgui.SetCursorPos(cx , cy + 6 )
     
     local TitlePage='SAVE SITUATION AND 742 COCKPIT CONFIGURATION'
     local text_width, text_height = imgui.CalcTextSize(TitlePage)
     imgui.SetCursorPos(win_width / 2 - text_width / 2, imgui.GetCursorPosY())
     imgui.TextUnformatted(TitlePage)
     
     
     
     
     imgui.TextUnformatted( "Enter name of save file :" ) ;
     --- Saving situation & cockpit
     if ( not FutureSaveNam ) then
        FutureSaveNam = CurrentSaveNam 
        end 
     
     local changedSavNam, newSavName = imgui.InputText("N2", FutureSaveNam, 255)
        if changedSavNam then
           FutureSaveNam = newSavName
           end  
     
        
     if imgui.Button('SAVE SITUATION & COCKPIT') then
        save_742_sit (1, FutureSaveNam)
        end 
     imgui.SameLine()    
     if imgui.Button('SAVE ONLY COCKPIT') then
        save_742_sit (2, FutureSaveNam)
        end
     --- Separation    
     cx, cy = imgui.GetCursorScreenPos() 
     imgui.DrawList_AddLine(cx, cy, cx + imgui.GetWindowWidth() , cy  , 0xFF8D8C7F, 2)
     imgui.SetCursorPos(cx , cy + 6 )
     
     
     local SubTitle='AUTO SAVE SITUATION AND COCKPIT'
     local text_width, text_height = imgui.CalcTextSize(SubTitle)
     imgui.SetCursorPos(win_width / 2 - text_width / 2, imgui.GetCursorPosY())
     imgui.TextUnformatted(SubTitle) ;
     
     --[[
     local changedAs , newValAs = imgui.Checkbox("AUTO Save", flag_auto_save)
     if changedAs then
        flag_auto_save = newValAs
        end
        
     if (flag_auto_save) then
     ]]
     
     --- PushItemWidth(xxx) 
     --  No auto save in progress
        if ( not ActiveAutoSave['nb_in_cycle'] or not ActiveAutoSave['interval'] or not ActiveAutoSave['prefix']) then
          local changedAsNb, newNb = imgui.SliderInt("I2", FutureNb, 1, 50, "%.0f saves in cycle")
          if changedAsNb then
             FutureNb = newNb
             end
          
          --- imgui.SameLine()
          --- imgui.TextUnformatted( "saves cycle, one save every" ) 
          --- imgui.SameLine()
          -- 
          local changedAsTi, newTi = imgui.SliderInt("I1", FutureTi, 1, 60, "A save every %.0f minutes")
          if changedAsTi then
             FutureTi = newTi 
             end
             
          imgui.TextUnformatted( "Enter prefix of autosave file :" ) ;
       
          if ( not FutureAutoSaveNam ) then
             FutureAutoSaveNam = CurrentAutoSaveSaveNam 
             end 
          changedAutoSavNam, newAutoSavName = imgui.InputText("N1", FutureAutoSaveNam, 255)
          if changedAutoSavNam then
             FutureAutoSaveNam = newAutoSavName
             end      
         
            if imgui.Button('SAVE & ACTIVATES THIS AUTOSAVE') then
               ActiveAutoSave['nb_in_cycle']=FutureNb 
               ActiveAutoSave['interval']=FutureTi
               ActiveAutoSave['prefix']=FutureAutoSaveNam 
               end 
         else 
            imgui.TextUnformatted( 'Autosave in progress :' ) ;
            imgui.TextUnformatted( 'Cycle of '..ActiveAutoSave['nb_in_cycle']..' saves, '..ActiveAutoSave['interval']..' minutes interval between saves' ) ;
            if LastAutoSaveTs then 
               imgui.TextUnformatted( 'Next save in '.. string.format("%2d",(LastAutoSaveTs + (ActiveAutoSave['interval']*60) - b742_time_stamp)) ..' s'  ); 
               end 
            
            --- LastAutoSaveTs or ( LastAutoSaveTs < (b742_time_stamp - (ActiveAutoSave['interval']*60) ) 
            
            
            
            if imgui.Button('DE-ACTIVATES THIS AUTOSAVE') then
               ActiveAutoSave={} 
               LastAutoSaveNum = nil 
               end
         
         
            end 
           
            
     
     
     
     
  ----------------------------------------------------------------------------------------       
  elseif  (active_panel == 3) then  --- Page Load
  -- 
     -- float_wnd_set_geometry(vfe_wnd, 0, 0, 750, 650)
     
    local TitlePage='LOAD SITUATION AND 742 COCKPIT CONFIGURATION'
     local text_width, text_height = imgui.CalcTextSize(TitlePage)
     imgui.SetCursorPos(win_width / 2 - text_width / 2, imgui.GetCursorPosY())
     imgui.TextUnformatted(TitlePage)
     --- Separation    
     cx, cy = imgui.GetCursorScreenPos() 
     imgui.DrawList_AddLine(cx, cy, cx + imgui.GetWindowWidth() , cy  , 0xFF8D8C7F, 2)
     imgui.SetCursorPos(cx , cy + 6 )
     
     imgui.TextUnformatted("List of 742 Cockpit saves")
     imgui.TextUnformatted("--> Select in the list")
     
     --- List of pages
     local NbPages = math.floor(NbCockpitSaves / NbSavePerPage)
     if (NbCockpitSaves > NbPages*NbSavePerPage ) then NbPages = NbPages + 1 end 
     --- imgui.TextUnformatted( NbCockpitSaves.." saves "..NbPages.." pages" )
     
     local FuturePage = nil 
     
     if (NbPages > 1) then 
        imgui.TextUnformatted( "Page " )
        for ipage = 1 , NbPages do 
           imgui.SameLine() 
           if (CurrentSavePage == ipage ) then 
              imgui.TextUnformatted( ipage )
           else 
              if imgui.Button(ipage) then
                 FuturePage=ipage 
                 end 
              end 
              
           end 
        end 
     if (FuturePage)  then CurrentSavePage =   FuturePage end 
     
     
     --- Separation    
     cx, cy = imgui.GetCursorScreenPos() 
     imgui.DrawList_AddLine(cx, cy, cx + imgui.GetWindowWidth() , cy  , 0xFF8D8C7F, 2)
     imgui.SetCursorPos(cx , cy + 6 )
     
     
     
     --- List of files
     local sizesav = table.getn(CockpitSaves) 
     if (not sizesav or sizesav == 0 ) then
        imgui.TextUnformatted( "No 742 Cockpit save in this directory" )
     else 
       -- first present possible cockpit save to load
       if (sizeimmediate and sizeimmediate == 1 ) then
         if (sizeimmediate and sizeimmediate == 1 ) then
            imgui.TextUnformatted( "Cockpit save available for immediate load" )
         elseif ( sizeimmediate and sizeimmediate > 1 ) then
            imgui.TextUnformatted( sizeimmediate.." cockpit saves available for immediate load" )
            end 
         
         for k in pairs (CockpitSaves) do
            if (ActiveCockpitSave[CockpitSaves [k]] ) then
              if imgui.Button('CURRENT SITUATION >>>>> '..CockpitSaves [k]) then
                  SelectedSave = CockpitSaves [k] 
                  load_742_sit (2)
                  SelectedSave = nil 
                  ActiveCockpitSave[CockpitSaves [k]] = nil 
                  sizeimmediate = sizeimmediate -1 
                  end
                end 
            end
            
             
          --- Separation    
          cx, cy = imgui.GetCursorScreenPos() 
          imgui.DrawList_AddLine(cx, cy, cx + imgui.GetWindowWidth() , cy  , 0xFF8D8C7F, 2)
          imgui.SetCursorPos(cx , cy + 6 )
       end
          
       -- 
       for k in pairs (CockpitSaves) do
          if ( (k > (CurrentSavePage-1)*NbSavePerPage ) and k <= CurrentSavePage*NbSavePerPage and not ActiveCockpitSave[CockpitSaves [k]] ) then 
          
             
         
            local text_width, text_height = imgui.CalcTextSize(CockpitSaves [k])
            if ( CockpitSaves [k]  == SelectedSave) then
               -- draw border
               cx, cy = imgui.GetCursorScreenPos()
               imgui.DrawList_AddRect(cx-2, cy+2, cx + text_width+8  , cy + text_height+8  , 0xFF8D8C7F, 0.5) 
               imgui.SetCursorPos(cx + 4 , cy + 5 )
               end 
            
            
            cx, cy = imgui.GetCursorScreenPos() 
            local Area = {} ;  
            Area[1]=cx 
            Area[2]=win_height - cy 
            Area[3]=cx+text_width 
            Area[4]=win_height - cy - text_height
            
            CockpitSavesAreas[k]=Area ;
          
            imgui.TextUnformatted( CockpitSaves [k] ) ;
            end 
          
          
          end
       end    
     
     --- Separation    
     cx, cy = imgui.GetCursorScreenPos() 
     imgui.DrawList_AddLine(cx, cy, cx + imgui.GetWindowWidth() , cy  , 0xFF8D8C7F, 2)
     imgui.SetCursorPos(cx , cy + 12 )
     
     local Dummy='LOAD SITUATION & COCKPIT LOAD COCKPIT ONLY '
     local text_width, text_height = imgui.CalcTextSize(Dummy)
     imgui.SetCursorPos(win_width / 2 - text_width / 2, imgui.GetCursorPosY())
     
     if (SelectedSave) then 
       if imgui.Button('LOAD SITUATION & COCKPIT') then
          load_742_sit (1)
          SelectedSave  = nil 
          end 
       imgui.SameLine()  
       if imgui.Button('LOAD COCKPIT ONLY') then
          load_742_sit (2)
          SelectedSave  = nil 
          end  
        
        end    
        
        
        
        
        
        
        
        
        
     
  end  ---- End of page     
    
    --- imgui.TextUnformatted("UT: " .. hours .. ":" .. minutes )
    --- imgui.TextUnformatted("Azimuth: " .. azimuth .. "°")
    --- imgui.TextUnformatted("Pitch: " .. math.floor(set_pitch) .. "° " .. -math.floor( (math.floor(math.floor(set_pitch)*100)/100 - set_pitch) * 60 ).. "'")
    --- imgui.Image(overlay, 439/2 , 679/2)
    
end

--- =================================================================================
function create_vfe_wnd()
    if ( not vfe_wnd ) then 
      vfe_wnd = float_wnd_create(250, 500, 1, true)
      float_wnd_set_title(vfe_wnd, "747-200 Symphony")
      float_wnd_set_imgui_builder(vfe_wnd, "draw_vfe_window")
      float_wnd_set_onclose(vfe_wnd, "vfe_wnd_close")
      float_wnd_set_resizing_limits(vfe_wnd, 250, 500, 750, 650)
      float_wnd_set_onclick(vfe_wnd, "vfe_wnd_click")
      end 
    
end

function vfe_wnd_close (wnd)
   --- print_debug("Close window" )
   vfe_wnd = nil 
    
end

function vfe_wnd_click(wnd, x,y)
   if active_panel == 3 then 
      --- print_debug("Click window x="..x.." y="..y )
      
      for k in pairs (CockpitSaves) do
         --- print_debug("Area /"..CockpitSaves[k].."/ x = "..CockpitSavesAreas[k][1].."/"..CockpitSavesAreas[k][3].."/ y="..CockpitSavesAreas[k][2].."/"..CockpitSavesAreas[k][4].."/")
         if ( CockpitSavesAreas[k] and CockpitSavesAreas[k][1] < x and CockpitSavesAreas[k][3] > x  and CockpitSavesAreas[k][2] > y and CockpitSavesAreas[k][4] < y ) then 
            --- print_debug("Click "..CockpitSaves[k] )
            SelectedSave = CockpitSaves[k] 
            end  
         end 
      
      
      end 
end
 
---=======================================
-- Saving functions

function save_742_sit (option , SavName)
 
print_debug ('Saving situation in '..ValidatedSaveDir..'/'..SavName)

local situation_file = ValidatedSaveDir..'/'..SavName..".sit" ;

file = io.open(ValidatedSaveDir..'/'..SavName..".b742", "w")
io.output(file)

io.write('<?xml version="1.0" encoding="iso-8859-1"?>' ) 
io.write('\n<742save>' ) 

io.write('\n<sit dir="'..ValidatedSaveDir..'" file="'..SavName..'.b742" />' ) 
io.write('\n<pos lat="'..get ("sim/flightmodel/position/latitude")..'" long="'..get ("sim/flightmodel/position/longitude")..'" elevation="'..feet_above_ground..'" date="'..get("sim/time/local_date_days")..'" time="'..get("sim/time/zulu_time_sec")..'" />' ) 

for i, eqt in pairs(interfaces) do
   if (not eqt['readonly'] or eqt['readonly'] == nil ) then 
      if (eqt['type'] and eqt['type']==1 ) then 
         --- print_debug(i..'='..get(eqt['dataref']))
         io.write('\n<ds n="'..i..'" v="'..get(eqt['dataref'])..'" /> ' ) 
      elseif (eqt['type'] and  ( eqt['type']==2 or  eqt['type']==3 ) ) then
          io.write('\n<xs n="'..i..'" > ' )
         for index = 0 , eqt['size_a']-1 do 
            io.write('<xv i="'..index..'" v="'..get(eqt['dataref'], index)..'" /> ' )
            --- print_debug(i..'['..index..']='..get(eqt['dataref'], index ))
            end
         io.write('</xs> ' )
         end 
      
      end      
   end


io.write('\n</742save>' )    
io.close(file)

if ( option == 1 ) then
   save_situation(situation_file) 
   end  
end 

---======================================================================
function load_742_sit (option) 
if ( option == 1 ) then print_debug ('Loading situation & 742 cockpit '..ValidatedSaveDir..SelectedSave)  
else print_debug ('Loading 742 cockpit '..ValidatedSaveDir..'/'..SelectedSave)  end 


local xfile = xml.load(ValidatedSaveDir..'/'..SelectedSave..".b742")   
size = table.getn(xfile)
 for i, sav_lvl1 in ipairs(xfile) do
    if (interfaces[sav_lvl1.n] and not interfaces[sav_lvl1.n]['readonly']) then 
      if ( sav_lvl1[0] == 'ds' ) then
         -- print_debug(sav_lvl1.n..'='..sav_lvl1.v)  
         set ( interfaces[sav_lvl1.n]['dataref'], sav_lvl1.v ) ;
      elseif ( sav_lvl1[0] == 'xs' ) then
          
         if (table.getn(sav_lvl1)>0) then
            for j, name in ipairs( sav_lvl1) do
               --- print_debug(sav_lvl1.n..'['..name.i..'] ='..name.v) 
               if (sav_lvl1.n == 'fuel_in_tanks_kg') then
                  print_debug ('Tank ['..j..'] '..name.v..'/'.. get(interfaces[sav_lvl1.n]['dataref'],name.i) ..' kg ') ;  
               else 
                  set_array ( interfaces[sav_lvl1.n]['dataref'], name.i , name.v ) ;
                  end    
               end  
            end
           end   
         end 
       
    end   

if ( option == 1 ) then
   load_situation(ValidatedSaveDir..'/'..SelectedSave..".sit")  
   end 
 
end  
  
---======================================================================
function load_742_cockpit_info (file, PosSavInfos) 
PosSavInfos['is_ok']= false 

local xfile = xml.load(file) -- load xml 

 for i, sav_lvl1 in ipairs(xfile) do
    if ( sav_lvl1[0] == 'pos' ) then
       print_debug ('742 cockpit file :'..file..' lat= '..sav_lvl1.lat..' long='..sav_lvl1.long..' elev='..sav_lvl1.elevation..' date='..sav_lvl1.date..' time='..sav_lvl1.time)
       PosSavInfos['lat']=sav_lvl1.lat
       PosSavInfos['long']=sav_lvl1.long
       PosSavInfos['elevation']=sav_lvl1.elevation
       PosSavInfos['date']=sav_lvl1.date
       PosSavInfos['time']=sav_lvl1.time
       
       PosSavInfos['d_lat'] = math.abs( PosSavInfos['lat']-get("sim/flightmodel/position/latitude"))  
       PosSavInfos['d_long'] = math.abs( PosSavInfos['long']-get ("sim/flightmodel/position/longitude"))
       PosSavInfos['d_elevation'] = math.abs( PosSavInfos['elevation']-(get("sim/flightmodel/position/y_agl")/ 3.28084))
       PosSavInfos['d_date'] = math.abs( PosSavInfos['date']-get("sim/time/local_date_days"))
       PosSavInfos['d_time'] = math.abs( PosSavInfos['time']-get("sim/time/zulu_time_sec"))
       
       if (PosSavInfos['d_date']==0 and PosSavInfos['d_time']==0 and PosSavInfos['d_elevation']<2 and PosSavInfos['d_lat'] < 0.01 and PosSavInfos['d_long'] < 0.01 ) then
          PosSavInfos['is_ok']= true
          end
       
       end 
       
    end   

 
end  