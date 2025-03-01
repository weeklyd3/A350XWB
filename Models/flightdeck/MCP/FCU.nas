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