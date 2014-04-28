/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-


static void read_control_switch()
{
    #ifdef PANIC_BUTTON_CH 

        static bool panic_debouncer;
        int8_t PB_Position = readPB();
 
        if(PB_Position != 0) { 
          
          if(PB_Position == 255) return; 
          
            if (panic_debouncer == false) {
            panic_debouncer = true;
            return;
            }
      
        (PB_Position > 0) ? set_mode(MANUAL)  :  set_mode(RTL)     ;
        (PB_Position > 0) ? (flight_mode_selected = 0) : (flight_mode_selected = 8) ; 
     
        prev_WP = current_loc; 
        panic_debouncer = false;
        
        return;
         
        }  
         
    #endif
    
    static bool switch_debouncer;
    
    int8_t switchPosition = readSwitch();
    
    // If switchPosition = 255 this indicates that the mode control channel input was out of range
    // If we get this value we do not want to change modes.
    if(switchPosition == 255) return; 
    
  
    if (ch3_failsafe) {
        // when we are in ch3_failsafe mode then RC input is not
        // working, and we need to ignore the mode switch channel
        return;
    }



  #if MODES_CIRCLE != ENABLED

    // we look for changes in the switch position. If the
    // RST_SWITCH_CH parameter is set, then it is a switch that can be
    // used to force re-reading of the control switch. This is useful
    // when returning to the previous mode after a failsafe or fence
    // breach. This channel is best used on a momentary switch (such
    // as a spring loaded trainer switch).
    if (oldSwitchPosition != switchPosition ||
        (g.reset_switch_chan != 0 &&
         hal.rcin->read(g.reset_switch_chan-1) > RESET_SWITCH_CHAN_PWM)) {

        if (switch_debouncer == false) {
            // this ensures that mode switches only happen if the
            // switch changes for 2 reads. This prevents momentary
            // spikes in the mode control channel from causing a mode
            // switch
            switch_debouncer = true;
            return;
        }

        set_mode((enum FlightMode)(flight_modes[switchPosition].get()));

        oldSwitchPosition = switchPosition;
        prev_WP = current_loc;
    }

    if (g.reset_mission_chan != 0 &&
        hal.rcin->read(g.reset_mission_chan-1) > RESET_SWITCH_CHAN_PWM) {
        // reset to first waypoint in mission
        prev_WP = current_loc;
        change_command(0);
    }

    switch_debouncer = false;

    if (g.inverted_flight_ch != 0) {
        // if the user has configured an inverted flight channel, then
        // fly upside down when that channel goes above INVERTED_FLIGHT_PWM
        inverted_flight = (control_mode != MANUAL && hal.rcin->read(g.inverted_flight_ch-1) > INVERTED_FLIGHT_PWM);
    }
    
  #elif MODES_CIRCLE == ENABLED

    static bool stop_switch_timer ;
 
    if ( switchPosition == 0 ) oldSwitchPosition = 0 ;  
    
    if ( control_mode == INITIALISING )
       { set_mode(MANUAL)        ;
         flight_mode_selected = 0 ; 
         stop_switch_timer = false; }
    
    if ( stop_switch_timer != true ) m_switch_time = millis() ;  
      
   
    // we look for changes in the switch position. If the
    // RST_SWITCH_CH parameter is set, then it is a switch that can be
    // used to force re-reading of the control switch. This is useful
    // when returning to the previous mode after a failsafe or fence
    // breach. This channel is best used on a momentary switch (such
    // as a spring loaded trainer switch).
    if ((g.reset_switch_chan != 0 &&
         hal.rcin->read(g.reset_switch_chan-1) > RESET_SWITCH_CHAN_PWM)) {

        if (switch_debouncer == false) {
            // this ensures that mode switches only happen if the
            // switch changes for 2 reads. This prevents momentary
            // spikes in the mode control channel from causing a mode
            // switch
            switch_debouncer = true;
            return;
        }
        set_mode(CIRCLE)        ;
        oldSwitchPosition = switchPosition;
        flight_mode_selected = 5 ; 
        prev_WP = current_loc;
        stop_switch_timer = false;
        return;
    }

     if (switch_debouncer == false) {
            // this ensures that mode switches only happen if the
            // switch changes for 2 reads. This prevents momentary
            // spikes in the mode control channel from causing a mode
            // switch
            switch_debouncer = true;
            return;
        }
     
    if (g.inverted_flight_ch != 0) {
        // if the user has configured an inverted flight channel, then
        // fly upside down when that channel goes above INVERTED_FLIGHT_PWM
        inverted_flight = (control_mode != MANUAL && hal.rcin->read(g.inverted_flight_ch-1) > INVERTED_FLIGHT_PWM);
    }
       
    if (g.reset_mission_chan != 0 &&
        hal.rcin->read(g.reset_mission_chan-1) > RESET_SWITCH_CHAN_PWM) {
        // reset to first waypoint in mission
        prev_WP = current_loc;
        change_command(0);
    }

        
if ( oldSwitchPosition == 0 && switchPosition != 0 )   {     
  
 if ( flight_mode_selected == 0 && switchPosition == -1 )
    { flight_mode_selected = max_selectable_f_modes ; 
      oldSwitchPosition = switchPosition ; 
      stop_switch_timer = true; 
      m_switch_time = millis() ; 
      return;}
      
 if ( flight_mode_selected == 0 && switchPosition == 1 )
    { flight_mode_selected = 1 ; 
      oldSwitchPosition = switchPosition ; 
      stop_switch_timer = true; 
      m_switch_time = millis() ; 
      return;}
      
 if ( flight_mode_selected == max_selectable_f_modes && switchPosition == 1 )
    { flight_mode_selected = 0 ; 
      oldSwitchPosition = switchPosition ; 
      stop_switch_timer = true; 
      m_switch_time = millis() ; 
      return;}
      
 if ( flight_mode_selected == max_selectable_f_modes && switchPosition == -1 )
    { flight_mode_selected = flight_mode_selected + switchPosition ; 
      oldSwitchPosition = switchPosition ; 
      stop_switch_timer = true; 
      m_switch_time = millis() ; 
      return;}
      
 if ( flight_mode_selected > 0 && flight_mode_selected < max_selectable_f_modes )
    { flight_mode_selected = flight_mode_selected + switchPosition ; 
      oldSwitchPosition = switchPosition ; 
      stop_switch_timer = true; 
      m_switch_time = millis() ; 
      return; }
      
 else return;
}


if ( millis() >= m_switch_time + 3000 )
 {
    if ( flight_mode_selected == 0 ) 
       { set_mode(MANUAL)        ;  }
         
    if ( flight_mode_selected == 1 ) 
       { set_mode(STABILIZE)     ;  }
         
    if ( flight_mode_selected == 2 ) 
       { set_mode(TRAINING)      ;  }
       
    if ( flight_mode_selected == 3 ) 
       { set_mode(FLY_BY_WIRE_A) ;  }
       
    if ( flight_mode_selected == 4 ) 
       { set_mode(FLY_BY_WIRE_B) ;  }
       
    if ( flight_mode_selected == 5 ) 
       { set_mode(CIRCLE)        ;  }
                
    if ( flight_mode_selected == 6 ) 
       { set_mode(LOITER)        ;  }
       
    if ( flight_mode_selected == 7 ) 
       { set_mode(AUTO)          ;  }
       
    if ( flight_mode_selected == 8 ) 
       { set_mode(RTL)           ;  }
       
    if ( flight_mode_selected == 9 ) 
       { set_mode(GUIDED)        ;  }
       
    #if THERMAL_HUNTING_MODE == FLIGHT_MODE_THERMAL   
    if ( flight_mode_selected == 10 ) 
       { set_mode(THERMAL)        ;  }
    #endif
  
}
else return ;
 
      
    prev_WP = current_loc;
    switch_debouncer = false;
    stop_switch_timer = false;
    
   #endif
}

static int8_t readSwitch(void){
uint16_t pulsewidth = hal.rcin->read(g.flight_mode_channel - 1);
#if MODES_CIRCLE != ENABLED
    if (pulsewidth <= 910 || pulsewidth >= 2090) return 255;            // This is an error condition
    if (pulsewidth > 1230 && pulsewidth <= 1360) return 1;
    if (pulsewidth > 1360 && pulsewidth <= 1490) return 2;
    if (pulsewidth > 1490 && pulsewidth <= 1620) return 3;
    if (pulsewidth > 1620 && pulsewidth <= 1749) return 4;              // Software Manual
    if (pulsewidth >= 1750) return 5;                                   // Hardware Manual
    return 0;
#elif MODES_CIRCLE == ENABLED
    if (pulsewidth <= 910 || pulsewidth >= 2090) return 255;       
    if (pulsewidth > 911 && pulsewidth <= 1360) return -1;
    if (pulsewidth > 1360 && pulsewidth <= 1620) return 0;
    if (pulsewidth > 1620 && pulsewidth < 2090) return 1; 
#endif 
  }

static void reset_control_switch()
{
    oldSwitchPosition = 0;
    read_control_switch();
}

         
static int8_t readPB(void){
    #ifdef PANIC_BUTTON_CH 
             uint16_t pulsewidth2 = hal.rcin->read(PANIC_BUTTON_CH - 1);
             if (pulsewidth2 <= 910 || pulsewidth2 >= 2090) return 255;       
             if (pulsewidth2 > 911 && pulsewidth2 <= 1360) return -1;
             if (pulsewidth2 > 1360 && pulsewidth2 <= 1620) return 0;
             if (pulsewidth2 > 1620 && pulsewidth2 < 2090) return 1; 
    #else 
             return 0;
    #endif    
}
 
 


