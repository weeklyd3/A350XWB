#======
# INIT
#======

A350XWBMain = {};

A350XWBMain.new = func {
  var obj = {
    parents : [A350XWBMain],
  };
  
  obj.init();
  
  return obj;
}

#======
# CRON
#======

A350XWBMain.fastcron = func {
  #fast code runs in here (EICAS)
  eicassystem.schedule();
  # schedule the next call
  settimer(func { me.fastcron(); },0.1);
}

A350XWBMain.slowcron = func {
  #1 second code runs in here
  enginesystem.schedule();
  # schedule the next call
  settimer(func { me.slowcron(); },1);
}

#=============
# START NASAL
#=============
A350XWBMain.loadscripts = func {
  globals.A350XWB.enginesystem = A350XWB.Engines.new();
  globals.A350XWB.eicassystem = A350XWB.EICAS.new();
}

A350XWBMain.init = func {
  #This is here so the reinit only runs once instead of twice
  me.loadscripts();
  
  #Start the cron timers
  settimer(func { me.fastcron(); },0);
  settimer(func { me.slowcron(); },0);
  
  print('A350XWB Systems started');
}

A350XWBMain.reinit = func {
  #This is here so the reinit only runs once instead of twice
  if ( getprop("/sim/signals/reinit") ) {
    #Add reinit functions in here
    print('A350XWB Systems restarted');
  }
}

A350XWBListener1 = setlistener("/sim/signals/fdm-initialized", func { globals.A350XWB.main = A350XWBMain.new(); removelistener(A350XWBListener1); });
A350XWBListener2 = setlistener("/sim/signals/reinit", func { globals.A350XWB.main.reinit(); });

setlistener("controls/lighting/landing-light",
  func {
    if(getprop("controls/lighting/landing-light")) setprop("controls/lighting/landing-lights-norm",1); else setprop("controls/lighting/landing-lights-norm",0);
  }
);
var idle_thrust = 0;
var climb_thrust = 0.75;
var mct = 0.85;
var toga = 1;
var throttle_to_angle = func(throttle) {
  # returns between 0 and 1
  if (throttle <= 0.01) return 0;
  if (0.01 < throttle and throttle <= (climb_thrust - 0.02)) return 0.5482 * (throttle - 0.01) / (climb_thrust - 0.02);
  if (throttle > (climb_thrust - 0.02) and throttle <= (climb_thrust + 0.02)) return 0.5482;
  if (throttle > (climb_thrust + 0.02) and throttle <= (mct - 0.01)) return 0.5482 + 0.2258 * (throttle - climb_thrust - 0.02) / (mct - climb_thrust - 0.03);
  if (throttle > (mct - 0.01) and throttle <= (mct + 0.01)) return 0.5482 + 0.2258;
  if (throttle > (mct + 0.01) and throttle <= (toga - 0.01)) return 0.5482 + 0.2258 + 0.226 * (throttle - mct - 0.01) / (toga - mct - 0.02);
  if (throttle > (toga - 0.01)) return 1;
}
setlistener("controls/engines/engine/throttle", func(value) {
  var throttle = value.getValue();
  setprop("controls/engines/engine/angle", throttle_to_angle(throttle));
});
setlistener("controls/engines/engine[1]/throttle", func(value) {
  var throttle = value.getValue();
  setprop("controls/engines/engine[1]/angle", throttle_to_angle(throttle));
});