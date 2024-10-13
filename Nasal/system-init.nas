setprop("engines/engine/yellow-pump", 1);
setprop("engines/engine/green-pump", 1);
setprop("engines/engine[1]/yellow-pump", 1);
setprop("engines/engine[1]/green-pump", 1);
setprop("engines/engine/yellow-pump-fault", 0);
setprop("engines/engine/green-pump-fault", 0);
setprop("engines/engine[1]/yellow-pump-fault", 0);
setprop("engines/engine[1]/green-pump-fault", 0);
setprop("/fdm/jsbsim/fcs/rudder-fbw-output", 0);
setprop("/fdm/jsbsim/fcs/aileron-fbw-output", 0);
setprop("/fdm/jsbsim/fcs/elevator-fbw-output", 0);
setprop("/overhead/christmas-tree", 0);
setprop("/systems/apu/starter", 0);
setprop('/systems/apu/running', 0);
setprop("/systems/apu/switch", 0);
setprop("/systems/apu/fault", 0);
setprop("/systems/apu/n", 0);
setprop("/systems/apu/egt", 0);
setprop("/systems/apu/bleed", 0);
setprop("/systems/apu/bleed-fault", 0);
setprop("/systems/apu/gen", 1);
setprop("/systems/apu/gen-fault", 0);
# shut off apu starter
setlistener("/systems/apu/n", func(value) {
	if (value.getValue() > 99.5) setprop("/systems/apu/starter", 0);
});
print('HIIII');