
FUELS = dataref_table( "sim/flightmodel/weight/m_fuel" )
dataref( "SQUIB_TEST_SW" , "B742/APU/squib_test_sw" , "writable")

 -----------------------------------------------------------------------------------------
function add_schedule (delay, equipment, status, number)  
 
-- delay = -1 if init 
    local nbsch = table.getn(enqueue) + 1
    timer_utc=timer_utc + delay
    enqueue[nbsch] = {}
    
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
    
    return nbsch
    
   
    
   end 
   
 -----------------------------------------------------------------------------------------
 function monitor_cl () 
   
   local actions_to_remove = {} 
   if ( table.getn(enqueue) > 0 ) then
      for i, action in ipairs(enqueue) do
         if (action['time'] and action['time'] <= UTC_SECONDS ) then
            do_action(action['equipment'], action['status'], action['number'])
            --- schedule next action
            -- 
            if (action['next'] and action['next'][1]) then 
              local next_action = action['next'][1] 
              if ( enqueue[next_action] ) then  enqueue[next_action]['time']=UTC_SECONDS+ enqueue[next_action]['pre_delay'] end 
              end  
            --- Suppress from scheduler
            enqueue[i]['time']=nil ;
            actions_to_remove[i]= i ;
            end 
         end
      end 
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
        
       init_complete = 1
       
   elseif (equipment=='TITLE') then
      msg_to_display['title'] = status 
      
   elseif (equipment=='MSG') then
      MsgAddQ(status) 
      
   elseif (equipment=='POV')  then 
      set_pov( status )
       
   elseif (interfaces[equipment] == nil or not interfaces[equipment])  then 
      MsgAddQ("!! Equipment "..equipment.." not found !!")   
   else 
     logMsg("XYacl: "..equipment.." --> "..status ) 
     if (number ~= nil ) then 
        index_eqt=tonumber(number)-1
        MsgAddQ("- "..equipment.." #"..index_eqt.." to '"..status..'"')  
     else
        index_eqt= false
        MsgAddQ("- "..equipment.." to '"..status.."'") 
  
        end
     
     if ( ( interfaces[equipment]['values'] == nil or not interfaces[equipment]['values'] )  and status ~= nil ) then 
        value_to_affect = status    
        
     elseif (interfaces[equipment]['values'][status] ~= nil ) then
        value_to_affect =   interfaces[equipment]['values'][status] 
        end 
       
      
     
     if ( not interfaces[equipment]) then
         logMsg("XYacl: ".." !!! Action Eqt :  "..equipment.." not found ")
         return 
         end 
     
     if (interfaces[equipment]['pilot_head'] ) then set_pov( interfaces[equipment]['pilot_head'] ) end
      
     if ( equipment == 'aux_power_1' and status == 'close') then --- Check if there is external power
        is_gpu1 = get ( interfaces['AC1_conn']['dataref'] ) ;
        if (is_gpu1 == nil or is_gpu1 ==  0  ) then
           logMsg("XYacl: ".."   !!!  External power not available." ) 
           Prereq = false 
           end
           
     elseif (equipment == 'aux_power_2' and status == 'close') then  --- Check if there is external power
        is_gpu2 = get ( interfaces['AC2_conn']['dataref'] ) ;
        if (is_gpu2 == nil or is_gpu2 ==  0  ) then
           logMsg("XYacl:  !!!  External power not available." ) 
           Prereq = false 
           end
        
        end
        
     
     
     if (Prereq and value_to_affect ~= nil ) then
        
        if (equipment == 'battery' and status == 'off') then  
           set ( interfaces['battery_cap']['dataref'], interfaces[equipment]['values']['open'] ) ;
           end 
     
        --- single dataref type = 1
        if ( interfaces[equipment]['type']==1 ) then 
           logMsg("XYacl: Dataref "..interfaces[equipment]['dataref'].." set to "..value_to_affect)    
           set ( interfaces[equipment]['dataref'], value_to_affect ) ; 
           
         --- type 2 array 
        elseif ( interfaces[equipment]['type']==2 and  interfaces[equipment]['size_a'] > 0 ) then
           if (index_eqt and index_eqt < interfaces[equipment]['size_a']) then 
             
              logMsg("XYacl: ".."Dataref "..interfaces[equipment]['dataref'].."["..index_eqt.."] set to "..value_to_affect) 
              set_array ( interfaces[equipment]['dataref'], index_eqt, value_to_affect ) ; 
           else    
              for index=0,interfaces[equipment]['size_a']-1,1 do
           
                 logMsg("XYacl: ".."Dataref  "..interfaces[equipment]['dataref'].."["..index.."] set to "..value_to_affect) 
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
                 logMsg("XYacl:  --> default 0 ")
                 index_to_set = 0 
                 end
           else 
              
              index_to_set =  interfaces[equipment]['values'][status]-1 
              logMsg("XYacl:  --> "..index_to_set)
              end 
           
           for index=0,interfaces[equipment]['size_a'],1 do
                 if ( index == index_to_set) then 
                    logMsg("XYacl: ---> set "..interfaces[equipment]['dataref'].."["..index.."] to 1 ")
                    set_array ( interfaces[equipment]['dataref'], index, 1  ) ; 
                 else 
                    logMsg("XYacl: ---> set "..interfaces[equipment]['dataref'].."["..index.."] to 0 ")
                    set_array ( interfaces[equipment]['dataref'], index, 0  ) ;
                    end 
                 end   
           end
           
           
        --- if (equipment == 'battery' and status == 'on') then  BATTERY_CAP =  0     end
            
     elseif (Prereq)  then 
        logMsg("   !!!  no status  /"..status.. "/ for equipment "..equipment )  
        end
        
     end      
   end 
 
 --------------------------------------------------------------------------------  
 function set_pov( phpos )

     if (phpos == 'INIT' ) then -- Console 
        set_pilots_head(pilot_head_init['X'], pilot_head_init['Y'], pilot_head_init['Z'], pilot_head_init['PSI'], pilot_head_init['THE']) 
        
     elseif (pilot_pov[phpos] ) then 
        set_pilots_head(pilot_pov[phpos]['x'], pilot_pov[phpos]['y'], pilot_pov[phpos]['z'], pilot_pov[phpos]['psi'], pilot_pov[phpos]['the'])
        end
        
      
  
     end 
     

   
-------------------------------------------------------------------------------------------------------------    
function load_interfaces () 
 
local xfile = xml.load(SCRIPT_DIRECTORY .."XYacl/XYacl-data.xml")
  
 
 ieqt = 0 
 ipov = 0
 size = table.getn(xfile)
 for i, bloc_lvl1 in ipairs(xfile) do
  
    --- logMsg(" i = "..i ) 
    
    if ( bloc_lvl1[0] == 'cmd' ) then 
      ieqt = ieqt + 1 
      --- print( '   name = '.. bloc_lvl1.name.." type=".. bloc_lvl1.type )
      interfaces[bloc_lvl1.name]= {} 
      interfaces[bloc_lvl1.name]['dataref']= bloc_lvl1.dataref
      interfaces[bloc_lvl1.name]['type']= tonumber(bloc_lvl1.type)
      --- if (bloc_lvl1.pilot_head) then interfaces[bloc_lvl1.name]['pilot_head']= bloc_lvl1.pilot_head end 
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
  
  
   end
   

-------------------------------------------------------------------------------------------------------------    
function save_current_view() 

file = io.open(SCRIPT_DIRECTORY .."742-data2.xml", "a")
io.output(file)
   --- DataRef( "PILOT_HEAD_X", "sim/aircraft/view/acf_peX")
   --- DataRef( "PILOT_HEAD_Y", "sim/aircraft/view/acf_peY")
   --- DataRef( "PILOT_HEAD_Z", "sim/aircraft/view/acf_peZ")

   --- DataRef( "PILOT_HEAD_PSI", "sim/graphics/view/pilots_head_psi")
   --- DataRef( "PILOT_HEAD_THE", "sim/graphics/view/pilots_head_the")
   
   io.write('\n<pilot_head name="aaa" x="'..PILOT_HEAD_X..'" y="'..PILOT_HEAD_Y..'" z="'..PILOT_HEAD_Z..'" psi="'..PILOT_HEAD_PSI..'" the="'..PILOT_HEAD_THE..'" /> ' ) 
   
   
   io.close(file) 

   end




--[[ 
--[[  
function draw_rect()
       graphics.set_color(RECT_R, RECT_G, RECT_B, RECT_ALPHA)
       --- graphics.draw_rectangle(SCREEN_WIDTH/2-80, SCREEN_HIGHT/2-5, SCREEN_WIDTH/2+40, SCREEN_HIGHT/2+20)
       graphics.draw_rectangle(20, SCREEN_HIGHT/2+5 , 200, SCREEN_HIGHT/2+25)
       graphics.set_width(10)
       graphics.set_color(LINE_R, LINE_G, LINE_B)

end
]] 



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
   if (msg_to_display['title'] ) then 
   
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
    
    draw_string( x + abstand + 5, y + y_size -25, msg_to_display['title'], h_color )
    
    ----- Then lines
    local idlin = 0 
    if (msg_to_display['lines'] and table.getn(msg_to_display['lines']) > 0 ) then
       local firsttd = math.max (table.getn(msg_to_display['lines']) - nblines + 1, 1 )
       --- firsttd = 1
       local lasttd = table.getn(msg_to_display['lines'])   
       for iline = firsttd , lasttd , 1  do 
          idlin = idlin+1 
          if ( iline == lasttd )  then 
             draw_string( x + abstand, y + y_size -30 - 10 * idlin  , msg_to_display['lines'][iline], g_color )
          else
             draw_string( x + abstand, y + y_size -30 - 10 * idlin  , msg_to_display['lines'][iline], w_color )
             end 
          end 
       end 
     
      
      end 
   end 
 
 function MsgAddQ(MsgToAdd) --- add a line to msg queue
    table.insert(msg_to_display['lines'], MsgToAdd)  
    end 
    
 function save_pos ()

 
file = io.open(SCRIPT_DIRECTORY .."XYacl/POV.xml", "w")
io.output(file)
 
   io.write('\n<742_pos name="new" x="'..get("sim/flightmodel/position/local_x")..'" y="'..get("sim/flightmodel/position/local_y")..'" z="'..get("sim/flightmodel/position/local_z")..'" /> ' ) 
   
  
   io.close(file) 


    end 
    
 function load_pos ()

 
file = io.open(SCRIPT_DIRECTORY .."742-save.xml", "r")
   set ("sim/flightmodel/position/local_x", 26422.175169752)
   set ("sim/flightmodel/position/local_y", -20.500583274204)
   set ("sim/flightmodel/position/local_z", -26241.905447964)
   --- sim/flightmodel/position/q
   io.close(file) 


    end 
 
  
  
  
  
