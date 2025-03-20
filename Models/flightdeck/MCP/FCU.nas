print("initializing fcu panel");
# copied from https://wiki.flightgear.org/Canvas_SVG_Intro
var inhg_to_hpa = 33.8639;
setprop("instrumentation/altimeter/unit", "inHg");
setprop("instrumentation/altimeter/std", 0);
var get_qnh_string = func() {
	if (getprop("instrumentation/altimeter/std")) return "Std";
	if (getprop("instrumentation/altimeter/unit") == "inHg") {
		return math.round(num(getprop("instrumentation/altimeter/setting-inhg")) * 100) / 100;
	} else {
		return math.round(num(getprop("instrumentation/altimeter/setting-hpa")));
	}
}
var change_qnh = func(positive) {
	if (getprop("instrumentation/altimeter/std")) return print("standard pressure set");
	if (getprop("instrumentation/altimeter/unit") == "inHg") {
		print("raw setting:", getprop("instrumentation/altimeter/setting-inhg"));
		var current_inhg = math.round(num(getprop("instrumentation/altimeter/setting-inhg")) * 100) / 100;
		print("rounded:", current_inhg);
		if (positive) current_inhg += 0.01;
		else current_inhg -= 0.01;
		print(current_inhg);
		setprop("instrumentation/altimeter/setting-inhg", current_inhg);
	} else {
		var current_hpa = math.round(num(getprop("instrumentation/altimeter/setting-hpa")));
		if (positive) current_hpa += 1;
		else current_hpa -= 1;
		setprop("instrumentation/altimeter/setting-hpa", current_hpa);
	}
}
var increase_qnh = func() { change_qnh(1); };
var decrease_qnh = func() { change_qnh(0); };
var qnh_settings = [
	{
		std: props.globals.initNode('/instrumentation/efis/std', 0, "BOOL"), 
		hpa: props.globals.initNode('/instrumentation/efis/hpa', 1, "BOOL"),
		qnh: props.globals.initNode('/instrumentation/efis/qnh', 29.92, 'DOUBLE'),
		qnh_hpa: props.globals.initNode('/instrumentation/efis/hpa-value', 1013, 'DOUBLE')
	},
	{
		std: props.globals.initNode('/instrumentation/efis[1]/std', 0, "BOOL"), 
		hpa: props.globals.initNode('/instrumentation/efis[1]/hpa', 1, "BOOL"),
		qnh: props.globals.initNode('/instrumentation/efis[1]/qnh', 29.92, 'DOUBLE'),
		qnh_hpa: props.globals.initNode('/instrumentation/efis[1]/hpa-value', 1013, 'DOUBLE')
	}
];
var sync_qnh = 1;
var inhg_to_hpa = 33.86389;
var hpa_to_inhg = 1 / inhg_to_hpa;
var qnh_std = func(number) {
	qnh_settings[number].std.toggleBoolValue();
};
var hpa_inhg = func(number) {
	if (qnh_settings[number].hpa.getValue()) {
		# using hpa right now, change to inhg
		var inhg = math.round(qnh_settings[number].qnh_hpa.getValue() * 100 * hpa_to_inhg) / 100;
		qnh_settings[number].qnh.setValue(inhg);
		qnh_settings[number].qnh_hpa.setValue(inhg_to_hpa * inhg);
	} else {
		# using inhg right now, change to hpa
		var hpa = math.round(qnh_settings[number].qnh.getValue() * inhg_to_hpa);
		qnh_settings[number].qnh.setValue(hpa * hpa_to_inhg);
		qnh_settings[number].qnh_hpa.setValue(hpa);
	}
	qnh_settings[number].hpa.toggleBoolValue();
};
var qnh_edit = func(number, amount) {
	if (qnh_settings[number].hpa.getValue()) {
		qnh_settings[number].qnh_hpa.setValue(math.max(745, math.min(1100, qnh_settings[number].qnh_hpa.getValue() + amount)));
		qnh_settings[number].qnh.setValue(qnh_settings[number].qnh_hpa.getValue() * hpa_to_inhg);
	} else {
		qnh_settings[number].qnh.setValue(math.max(22, math.min(32.48, qnh_settings[number].qnh.getValue() + amount * 0.01)));
		qnh_settings[number].qnh_hpa.setValue(qnh_settings[number].qnh.getValue() * inhg_to_hpa);
	}
};
#var fcu_canvas = canvas.new({
#  "name": "FCU",   # The name is optional but allow for easier identification
#  "size": [1024, 1024], # Size of the underlying texture (should be a power of 2, required) [Resolution]
#  "view": [2048, 74],  # Virtual resolution (Defines the coordinate system of the canvas [Dimensions]
#                        # which will be stretched the size of the texture, required)
#  "mipmapping": 1       # Enable mipmapping (optional)
#});
#var path = "Aircraft/A350XWB/Models/flightdeck/MCP/fcu_screen.svg";
# create an image child
#var group = fcu_canvas.createGroup('svg');
#canvas.parsesvg(group, path);
#fcu_canvas.addPlacement({"node": "Cube.001"});*/
# functions for knobs
var alt_knob = props.globals.getNode('/instrumentation/fcu/alt-knob');
var hdg_knob = props.globals.initNode('/instrumentation/fcu/hdg-knob', 0, 'INT');
var alt_increment = props.globals.getNode('/instrumentation/fcu/alt-increment');
var target_alt = props.globals.getNode('/it-autoflight/input/alt');
var change_alt = func(amount) { # amount is 1 or -1
	var increment = alt_increment.getValue();
	target_alt.adjustValue(amount * alt_increment.getValue());
	alt_knob.adjustValue(amount);
}
var spd_knob = props.globals.getNode('/instrumentation/fcu/spd-knob');
var target_spd = props.globals.getNode('/it-autoflight/input/kts');
var target_mach = props.globals.getNode('/it-autoflight/input/mach');
var kts_mach = props.globals.getNode('/it-autoflight/input/kts-mach');
var change_spd = func(amount) { # amount is 1 or -1
	if (kts_mach.getValue()) {
		var increment = 0.01;
		target_mach.adjustValue(increment * amount);
	} else {
		var increment = 1;
		target_spd.adjustValue(increment * amount);
	}
	spd_knob.adjustValue(amount);
}