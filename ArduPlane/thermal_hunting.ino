
 static void ThermalHunting()
 {
    static FlightMode previous_control_mode;
    
    static bool still_in_thermal;
    
    #if THERMAL_HUNTING_MODE == FLIGHT_MODE_THERMAL
    
    if(control_mode == THERMAL)
    {
     still_in_thermal = false; 
     if (read_climb_rate() > g.thermal_vspeed  && current_loc.alt >= thermal_hunting_min_altitude  && current_loc.alt < thermal_hunting_max_altitude) {
     prev_WP = next_WP;
     set_mode(LOITER);
     previous_control_mode = THERMAL;
     throttle_suppressed = true;
     still_in_thermal = true;
     
      }
      
    }
    
    if(control_mode == LOITER && previous_control_mode == THERMAL && still_in_thermal == true)
    { 
     static bool soaring_debouncer;
     
     if (read_climb_rate() < 0 || current_loc.alt >= thermal_hunting_max_altitude  || current_loc.alt < thermal_hunting_min_altitude) {
         
       if (soaring_debouncer == false) {
            soaring_debouncer = true;
            
        if (g.loiter_radius < 0) {
            g.loiter_radius = g.loiter_radius + 1;
            } else {
             g.loiter_radius = g.loiter_radius - 1;
            }

            return;
       }
        
       throttle_suppressed = false;    
       set_mode(THERMAL);
       next_WP = prev_WP;
       prev_WP = current_loc;
       previous_control_mode = LOITER;
       soaring_debouncer = false;
       still_in_thermal = false;
      }
      
      else { 
            if (g.loiter_radius < 0) {
             g.loiter_radius = g.loiter_radius - 1;
            } else {
             g.loiter_radius = g.loiter_radius + 1;
            }
      }
    }
    #endif
    
    #if THERMAL_HUNTING_MODE == FLIGHT_MODE_AUTO
   
     
    if(control_mode == AUTO)
    {
     still_in_thermal = false;    
     if (read_climb_rate() > g.thermal_vspeed  && current_loc.alt >= thermal_hunting_min_altitude  && current_loc.alt < thermal_hunting_max_altitude) {
     prev_WP = next_WP;
     set_mode(LOITER);
     throttle_suppressed = true;
     previous_control_mode = AUTO;
     still_in_thermal = true;
     
      }
      
    }
    
    if(control_mode == LOITER && previous_control_mode == AUTO && still_in_thermal == true)
    { 
     static bool soaring_debouncer;
     
     if (read_climb_rate() < 0 || current_loc.alt >= thermal_hunting_max_altitude  || current_loc.alt < thermal_hunting_min_altitude) {
         
       if (soaring_debouncer == false) {
            soaring_debouncer = true;
            
        if (g.loiter_radius < 0) {
            g.loiter_radius = g.loiter_radius + 1;
            } else {
             g.loiter_radius = g.loiter_radius - 1;
            }
            return;
       }
       
       throttle_suppressed = false;     
       set_mode(AUTO);
       next_WP = prev_WP;
       prev_WP = current_loc;
       previous_control_mode = LOITER;
       soaring_debouncer = false;
       still_in_thermal = false;
      }
        else { 
            if (g.loiter_radius < 0) {
             g.loiter_radius = g.loiter_radius - 1;
            } else {
             g.loiter_radius = g.loiter_radius + 1;
            }
      }
    }
    #endif

  }
