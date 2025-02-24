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
setprop("/controls/apu/starter", 0);
setprop('/systems/apu/running', 0);
setprop("/controls/apu/switch", 0);
setprop("/systems/apu/fault", 0);
setprop("/systems/apu/n", 0);
setprop("/systems/apu/egt", 0);
setprop("/systems/apu/bleed", 0);
setprop("/systems/apu/bleed-fault", 0);
setprop("/systems/apu/gen", 1);
setprop("/systems/apu/gen-fault", 0);
# shut off apu starter
setlistener("/systems/apu/n", func(value) {
	if (value.getValue() > 99.5) setprop("/controls/apu/starter", 0);
});
setprop("/systems/air/cockpit-temp-cmd", 24);
setprop("/systems/air/cockpit-temp", 24);
setprop("/systems/air/cabin-temp-cmd", 24);
setprop("/systems/air/cabin-temp", 24);
setprop("/systems/air/pack-flow", 1);
setprop("/systems/air/pack-1", 1);
setprop("/systems/air/pack-2", 1);
setprop("/systems/air/pack-1-fault", 0);
setprop("/systems/air/pack-2-fault", 0);
setprop("/systems/air/hot-air-1", 1);
setprop("/systems/air/hot-air-2", 1);
setprop("/systems/air/hot-air-1-fault", 0);
setprop("/systems/air/hot-air-2-fault", 0);
# 0 = off
# 1 = auto
# 2 = open
setprop("/systems/air/x-bleed", 1);
setprop("/engines/engine/bleed", 1);
setprop("/engines/engine[1]/bleed", 1);
setprop("/engines/engine/bleed-fault", 0);
setprop("/engines/engine[1]/bleed-fault", 0);
setprop("/engines/engine/fuel-flow_pph", 0);
setprop("/engines/engine[1]/fuel-flow_pph", 0);

setprop("/fdm/jsbsim/fcs/slat-cmd-norm", 0);
setprop("/fdm/jsbsim/fcs/flap-cmd-norm-actual", 0);
setprop("/fdm/jsbsim/fcs/flap-mode", 0);
var slats = props.globals.getNode("/fdm/jsbsim/fcs/slat-cmd-norm");
var ias = props.globals.getNode('/instrumentation/airspeed-indicator/indicated-speed-kt');
setlistener("/controls/flight/flaps", func(value) {
	var pos = value.getValue();
	if (pos == 0) {
		# wants no flaps
		setprop("/fdm/jsbsim/fcs/slat-cmd-norm", 0);
		setprop("/fdm/jsbsim/fcs/flap-cmd-norm-actual", 0);
		setprop("/fdm/jsbsim/fcs/flap-mode", 0);
	}
	if (pos == 0.29) {
		# wants flaps 1.
		setprop("/fdm/jsbsim/fcs/slat-cmd-norm", 0.29);
		if (ias.getValue() < 210) {
			# they actually want flaps
			setprop("/fdm/jsbsim/fcs/flap-cmd-norm-actual", 0.29);
			setprop("/fdm/jsbsim/fcs/flap-mode", 1.5);
		} else {
			setprop("/fdm/jsbsim/fcs/flap-cmd-norm-actual", 0);
			setprop("/fdm/jsbsim/fcs/flap-mode", 1);
		}
	}
	if (pos == 0.596) {
		# wants flaps 2
		setprop("/fdm/jsbsim/fcs/slat-cmd-norm", 0.29);
		setprop("/fdm/jsbsim/fcs/flap-cmd-norm-actual", 0.596);
		setprop("/fdm/jsbsim/fcs/flap-mode", 2);
	}
	if (pos == 0.645) {
		# wants flaps 3
		setprop("/fdm/jsbsim/fcs/slat-cmd-norm", 0.29);
		setprop("/fdm/jsbsim/fcs/flap-cmd-norm-actual", 0.645);
		setprop("/fdm/jsbsim/fcs/flap-mode", 3);
	}
	if (pos == 1) {
		# wants full flaps.
		setprop("/fdm/jsbsim/fcs/slat-cmd-norm", 1);
		setprop("/fdm/jsbsim/fcs/flap-mode", 4);
		setprop("/fdm/jsbsim/fcs/flap-cmd-norm-actual", 1);
	}
}, 0, 0);
setprop("/instrumentation/fcu/alt-increment", 1000);
setprop("/instrumentation/fcu/alt-knob", 0);
setprop("/instrumentation/fcu/spd-knob", 0);
setprop("/instrumentation/efis/inputs/range-nm", 40);
setprop("/instrumentation/efis[1]/inputs/range-nm", 40);
setprop("/instrumentation/efis/vd/horizontal-range", 0);
setprop("/instrumentation/efis/vd/scale", 0);
setprop("/instrumentation/efis/vd/low", 0);
setprop("/instrumentation/efis/vd/low-displacement", 0);
setprop("/instrumentation/efis/vd/tick-scale", 0);
setprop("/it-fbw/law", 0);
setprop("/systems/pfd/speed-trend-raw", 0);
setprop("/fdm/jsbsim/zero", 0);
#foreach (gen; ['1a', '1b', '2a', '2b']) {
#	setprop("/controls/electric/gen-" ~ gen, 1);
#	setprop("/controls/electric/drive-" ~ gen, 1);
#}
setlistener("/sim/signals/fdm-initialized", func() {
	#setprop('/engines/engine/running', 0);
});
var flex_active = props.globals.getNode('/systems/fadec/limit/takeoff/flex-activated');
setlistener("/fdm/jsbsim/gear/wow", func(wow) {
	flex_active.setValue(0);
});
print('HIIII');