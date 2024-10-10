print("let's make a pfd here");
var scale_constant = 1 / 3.779528;
var pitch_to_px = func(degrees) {
	# YOU STILL HAVE TO MULTIPLY BY scale_constant!
	if (degrees > 50) {
		return 200 + 2.5 * (degrees - 50);
	}
	if (30 < degrees and degrees <= 50) {
		return 150 + 2.5 * (degrees - 30);
	}
	if (-10 <= degrees and degrees <= 30) {
		return 5 * degrees;
	}
	if (-20 <= degrees and degrees < -10) {
		return -50 + 3.5 * (degrees + 10);
	}
	if (-30 <= degrees and degrees < -20) {
		return -85 + 2.581 * (degrees + 20);
	}
	if (-50 <= degrees and degrees < -30) {
		return -110.81 + 2.5 * (degrees + 30);
	}
	if (degrees < -50) {
		return -160.81 + 2.5 * (degrees + 50);
	}
}
var pfd = {
	new: func(name) {
		print('creating pfd with name', name);
		var display = canvas.new({
		"name": name,   # The name is optional but allow for easier identification
		"size": [1024, 1024], # Size of the underlying texture (should be a power of 2, required) [Resolution]
		"view": [118.870, 149.277],  # Virtual resolution (Defines the coordinate system of the canvas [Dimensions]
					# which will be stretched the size of the texture, required)
		"mipmapping": 1       # Enable mipmapping (optional)
		});
		var path = "Aircraft/A350XWB/Models/Instruments/PFD2/pfd.svg";
		# create an image child
		var group = display.createGroup('svg');
		canvas.parsesvg(group, path);
		foreach (elem; ["fdroll", "fdpitch", "ils_rollout", "radioaltimeter", "pitch_ladder", "horizon", "ahrs", "ball", "airspeed", "overspeed_barber_poles", "te_flaps"]) {
			me.svg_items[elem] = group.getElementById(elem);
		}
		me.svg_items.ahrs.updateCenter();
		display.addPlacement({"node": name, "texture": "pfd_test.png"});
		setlistener("/it-autoflight/output/fd1", func (fd1) {
			if (fd1.getValue()) {
				me.svg_items.fdroll.show();
				me.svg_items.fdpitch.show();
				me.svg_items.ils_rollout.show();
				if (num(getprop("position/altitude-agl-ft")) < 30) {
					me.svg_items.fdroll.hide();
				} else {
					me.svg_items.ils_rollout.hide();
				}
			} else {
				me.svg_items.fdroll.hide();
				me.svg_items.fdpitch.hide();
				me.svg_items.ils_rollout.hide();
			}
		}, 0, 1);
		me.svg_items.radioaltimeter.enableUpdate();
		setlistener("position/gear-agl-ft", func (altimeter) {
			var ra = (num(altimeter.getValue()) - 4);
			me.svg_items.radioaltimeter.updateText(sprintf("%d", math.round(ra)));
			if (ra > 2500) me.svg_items.radioaltimeter.hide();
			else me.svg_items.radioaltimeter.show();
			if (getprop("/it-autoflight/output/fd1")) {
				if (ra > 30) {
					me.svg_items.ils_rollout.hide();
					me.svg_items.fdroll.show();
				} else {
					me.svg_items.ils_rollout.show();
					me.svg_items.fdroll.hide();
				}
			}
		});
		setlistener("/orientation/model/pitch-deg", func(prop) {
			var pitch = prop.getValue();
			me.svg_items.pitch_ladder.setTranslation(0, (pitch_to_px(pitch)) * scale_constant);
			var pitch_translation = pitch_to_px(pitch);
			if (pitch_translation > 70) {
				pitch_translation = 70;
			}
			if (pitch_translation < -70) {
				pitch_translation = -70;
			}
			me.svg_items.horizon.setTranslation(0, pitch_translation * scale_constant);
		});
		setlistener("/orientation/model/roll-deg", func(prop) {
			var roll = -prop.getValue();
			me.svg_items.ahrs.setRotation(roll * 3.1415926535 / 180);
		});
		setlistener("/fdm/jsbsim/aero/beta-rad", func(prop) {
			var slip = prop.getValue();
			print('beta: ', slip);
			me.svg_items.ball.setTranslation(100 * slip * scale_constant, 0);
		});
		setlistener("/instrumentation/airspeed-indicator/indicated-speed-kt", func(prop) {
			var speed = prop.getValue();
			if (speed < 30) speed = 30;
			me.svg_items.airspeed.setTranslation(0, 2.645 * (speed - 30) * scale_constant);
			var maxspeed = 340;
			var overspeed = (speed - maxspeed) * 2.645;
			if (overspeed > 111.5) overspeed = 111.5;
			me.svg_items.overspeed_barber_poles.setTranslation(0, scale_constant * overspeed);
		});
		setlistener("/surface-positions/flap-pos-norm", func(prop) {
			var value = prop.getValue();
			var new_value = 0;
			if (value <= 0.29) new_value = value * 0.25 / 0.29;
			if (value > 0.29 and value <= 0.596) new_value = 0.25 + 0.25 * (value - 0.29) / 0.306;
			if (value > 0.596 and value <= 0.645) new_value = 0.5 + 0.25 * (value - 0.596) / 0.049;
			if (value > 0.645) new_value = 0.75 + (value - 0.645) * 0.25 / 0.355;
			me.svg_items.te_flaps.setTranslation(76 * new_value * scale_constant, 38.504 * scale_constant * new_value);
		});
		setlistener("instrumentation/nav/heading-needle-deflection-norm", func(prop) {
			var value = prop.getValue();
			if (!value) return;
			me.svg_items.ils_rollout.setTranslation(90 * value * scale_constant, 0);
		});
		setlistener("/it-autoflight/fd/pitch-bar", func(offset) {
			var pitch_offset = offset.getValue();
			if (num(getprop("position/altitude-agl-ft")) < 30) pitch_offset = 15 - num(getprop("/orientation/pitch-deg"));
			if (pitch_offset > 9) pitch_offset = 9;
			if (pitch_offset < -9) pitch_offset = -9;
			me.svg_items.fdpitch.setTranslation(0, -pitch_offset * 5 * scale_constant);
		});
		setlistener("/it-autoflight/fd/roll-bar", func(offset) {
			var roll_offset = offset.getValue();
			me.svg_items.fdroll.setTranslation((roll_offset / 10) * scale_constant, 0);
		});
		return {parents: [pfd], canvas: display};
	},
	svg_items: {}
};
var pfd1 = pfd.new('PFD_L');
#var pfd2 = pfd.new('PFD_R');