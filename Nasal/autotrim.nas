var autotrim = props.globals.getNode('/systems/fbw/autotrim');
var trim = props.globals.getNode('/controls/flight/elevator-trim');
var trim_actual = props.globals.getNode('/fdm/jsbsim/fcs/pitch-trim-pos-norm');
var trim_command = props.globals.getNode('/systems/fbw/g-elevator-no-trim');
var loop = func() {
	if (!autotrim.getValue()) return;
	var target = trim_command.getValue();
	if (target > 1) target = 1;
	if (target < -1) target = -1;
	var current_trim = trim.getValue();
	if (math.abs(target - current_trim) > 0.01) {
		if (target < current_trim) trim.adjustValue(-0.02 / 20);
		else trim.adjustValue(0.02 / 20);
	} else trim.setValue(current_trim);
};
var timer = maketimer(0.05, loop);
timer.simulatedTime = 1;
timer.start();