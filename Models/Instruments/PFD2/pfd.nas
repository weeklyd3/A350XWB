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
		var returned = {parents: [pfd], svg_items: {}, properties: {}};
		foreach (property; ["ls", "vv"]) {
			setprop("/instrumentation/" ~ name ~ "/" ~ property, 1);
			returned.properties[property] = props.globals.getNode("/instrumentation/" ~ name ~ "/" ~ property);
		}
		returned.font_mapper = func(doesnt, matter) {
			return "ECAMFontRegular.ttf";
		}
		var display = canvas.new({
		"name": name,   # The name is optional but allow for easier identification
		"size": [1024, 2048], # Size of the underlying texture (should be a power of 2, required) [Resolution]
		"view": [118.870, 149.277],  # Virtual resolution (Defines the coordinate system of the canvas [Dimensions]
					# which will be stretched the size of the texture, required)
		"mipmapping": 1       # Enable mipmapping (optional)
		});
		display.addPlacement({"node": name, "texture": "pfd_test.png"});
		returned.show = func() {
			var window = canvas.Window.new([889 / 2, 564], "dialog");
			window.setCanvas(display);
		};
		var path = "Aircraft/A350XWB/Models/Instruments/PFD2/pfd.svg";
		# create an image child
		var group = display.createGroup('svg');
		canvas.parsesvg(group, path, {"font-mapper": returned.font_mapper});
		foreach (elem; ["guides", "fdroll", "fdpitch", "fpv", "ils_rollout", "radioaltimeter", "pitch_ladder", "horizon", "ahrs", "ball", "airspeed", "overspeed_barber_poles", "mach", "te_flaps", "loc", "loc_left", "loc_right", "gs", "gs_up", "gs_down", "hundred_numbers", "hundreds", "thousands", "ten_thousands", "alt_tape", "alt_fl", "alt_below_1", "alt_above_1", "alt_above_2", "moves_with_alt", "alt_ground_level", "vs_needle", "vs_exact", "vs_text", "stall"]) {
			returned.svg_items[elem] = group.getElementById(elem);
		}
		foreach (elem; ["alt_fl", "alt_below_1", "alt_above_1", "alt_above_2", "vs_text", "mach"]) {
			returned.svg_items[elem].enableUpdate();
		}
		# prolly overkill to use all these decimal places but idc
		returned.svg_items.hundred_numbers.set('clip', 'rect(50.31527746, 102.9760859, 60.58640126, 96.78219079)');
		var digitClip = 'rect(52.09407101, 102.9760859, 58.80760772, 87.31248981)';
		returned.svg_items.hundreds.set('clip', digitClip);
		returned.svg_items.thousands.set('clip', digitClip);
		returned.svg_items.ten_thousands.set('clip', digitClip);
		returned.svg_items.alt_tape.set('clip', 'rect(25.39999704, 98.86790097, 85.15798798, 85.91866498)');
		returned.svg_items.vs_needle.set('clip', 'rect(20.12420599, 115.0937366, 90.77747274, 109.8020705)');
		returned.svg_items.ahrs.updateCenter();
		returned.svg_items.fpv.updateCenter();
		returned.timer = maketimer(1 / 10, returned, me.update);
		returned.timer.start();
		returned.svg_items.radioaltimeter.enableUpdate();
		setlistener("instrumentation/nav/heading-needle-deflection-norm", func(prop) {
			var value = prop.getValue();
			returned.svg_items.loc.setTranslation(80 * scale_constant * value, 0);
			returned.svg_items.ils_rollout.setTranslation(90 * value * scale_constant, 0);
			if (value < -0.999) {
				returned.svg_items.loc_left.show();
				returned.svg_items.loc_right.hide();
			} else if (value > 0.999) {
				returned.svg_items.loc_left.hide();
				returned.svg_items.loc_right.show();
			} else {
				returned.svg_items.loc_left.show();
				returned.svg_items.loc_right.show();
			}
		});
		setlistener("instrumentation/nav/gs-needle-deflection-norm", func(prop) {
			var value = prop.getValue();
			returned.svg_items.gs.setTranslation(0, 80 * scale_constant * -value);
			# 1 is full fly up
			if (value > 0.999) {
				returned.svg_items.gs_up.show();
				returned.svg_items.gs_down.hide();
			} else if (value < -0.999) {
				returned.svg_items.gs_up.hide();
				returned.svg_items.gs_down.show();
			} else {
				returned.svg_items.gs_up.show();
				returned.svg_items.gs_down.show();
			}
		});
		return returned;
	},
	create_props: func(hash) {
		hash.attitude = {
			pitch: props.globals.getNode('/orientation/model/pitch-deg'),
			roll: props.globals.getNode('/orientation/model/roll-deg'),
			aoa: props.globals.getNode('/fdm/jsbsim/aero/alpha-deg')
		};
		hash.fd = {
			enabled: props.globals.getNode('/it-autoflight/output/fd1'),
			roll: props.globals.getNode('/it-autoflight/fd/roll-bar'),
			pitch: props.globals.getNode('/it-autoflight/fd/pitch-bar')
		};
		hash.altitude = {
			indicated: props.globals.getNode('/instrumentation/altimeter/indicated-altitude-ft'),
			vs: props.globals.getNode('/it-autoflight/internal/vert-speed-fpm'),
			vs_needle: props.globals.getNode('/systems/pfd/vs-needle'),
			vs_translate: props.globals.getNode('/systems/pfd/vs-text-translation'),
			radio: props.globals.getNode('/position/gear-agl-ft')
		};
		hash.airspeed = {
			indicated: props.globals.getNode('/instrumentation/airspeed-indicator/indicated-speed-kt'),
			mach: props.globals.getNode('/instrumentation/airspeed-indicator/indicated-mach'),
			max: props.globals.getNode('/systems/pfd/max-speed')
		};
		hash.wing = {
			flap: props.globals.getNode('/surface-positions/flap-pos-norm')
		};
	},
	update: func() {
		# update attitude
		var pitch = pfd_props.attitude.pitch.getValue();
		var roll = pfd_props.attitude.roll.getValue();
		if (pfd_props.attitude.roll.getValue() != nil) {
			# when starting paused, it's nil for some reason until the first frame
			# the timer doesn't care if it's paused so it'll spew errors if it's nil
			me.svg_items.ahrs.setRotation(-roll * 3.1415926535 / 180);
			me.svg_items.pitch_ladder.setTranslation(0, (pitch_to_px(pitch)) * scale_constant);
			var pitch_translation = pitch_to_px(pitch);
			if (pitch_translation > 70) {
				pitch_translation = 70;
			}
			if (pitch_translation < -70) {
				pitch_translation = -70;
			}
			me.svg_items.horizon.setTranslation(0, pitch_translation * scale_constant);
		}
		# update fd
		if (pfd_props.fd.enabled.getValue()) {
			me.svg_items.guides.show();
			if (pfd_props.altitude.radio.getValue() > 30) {
				me.svg_items.fdroll.show();
				me.svg_items.ils_rollout.hide();
			} else {
				me.svg_items.fdroll.hide();
				me.svg_items.ils_rollout.show();
			}
			me.svg_items.fdroll.setTranslation(pfd_props.fd.roll.getValue() * 1.5 * scale_constant, 0);
			var pitch_offset = pfd_props.fd.pitch.getValue();
			if (pitch_offset < -9) pitch_offset = -9;
			if (pitch_offset > 9) pitch_offset = 9;
			me.svg_items.fdpitch.setTranslation(0, -pitch_to_px(pitch_offset) / 2 * scale_constant);
		} else me.svg_items.guides.hide();
		# update altimeter
		if (pfd_props.altitude.radio.getValue() != nil) {
			var ra = (num(pfd_props.altitude.radio.getValue()) - 4);
			me.svg_items.alt_ground_level.setTranslation(0, ra * 20 / 100 * scale_constant);
			if (ra > 2500) me.svg_items.radioaltimeter.hide();
			else {
				me.svg_items.radioaltimeter.show();
				me.svg_items.radioaltimeter.updateText(sprintf("%d", math.round(ra)));
			}
		}
		if (getprop("/it-autoflight/output/fd1")) {
			if (ra > 30) {
				me.svg_items.ils_rollout.hide();
				me.svg_items.fdroll.show();
			} else {
				me.svg_items.ils_rollout.show();
				me.svg_items.fdroll.hide();
			}
		}
		var altitude = pfd_props.altitude.indicated.getValue();
		var hundred = math.fmod(altitude, 100);
		var hundreds = math.fmod(altitude, 1000);
		var hundreds_digit = math.floor(hundreds / 100);
		var thousands = math.fmod(altitude, 10000);
		var thousands_digit = math.floor(thousands / 1000);
		var ten_thousands = math.fmod(altitude, 100000);
		var ten_thousands_digit = math.floor(ten_thousands / 10000);
		me.svg_items.hundred_numbers.setTranslation(0, 60 * scale_constant * hundred / 100);
		if (hundred <= 80) me.svg_items.hundreds.setTranslation(0, 22 * scale_constant * hundreds_digit);
		else me.svg_items.hundreds.setTranslation(0, 22 * scale_constant * (hundreds_digit + (hundred - 80) / 20));
		if (hundreds <= 980) me.svg_items.thousands.setTranslation(0, 22 * scale_constant * thousands_digit);
		else me.svg_items.thousands.setTranslation(0, 22 * scale_constant * (thousands_digit + (hundreds - 980) / 20));
		if (thousands <= 9980) me.svg_items.ten_thousands.setTranslation(0, 22 * scale_constant * ten_thousands_digit);
		else me.svg_items.ten_thousands.setTranslation(0, 22 * scale_constant * (ten_thousands_digit + (thousands - 9980) / 20));
		# move the altitude tape
		var five_fl_below = math.floor(altitude / 500) * 5 - 5;
		me.svg_items.alt_below_1.updateText(convert_fl(five_fl_below));
		me.svg_items.alt_fl.updateText(convert_fl(five_fl_below + 5));
		me.svg_items.alt_above_1.updateText(convert_fl(five_fl_below + 10));
		me.svg_items.alt_above_2.updateText(convert_fl(five_fl_below + 15));
		me.svg_items.alt_tape.setTranslation(0, 20 * (altitude / 100 - five_fl_below - 5) * scale_constant);
		me.svg_items.moves_with_alt.setTranslation(0, altitude / 100 * 20 * scale_constant);
		# vsi
		var vertical_speed = pfd_props.altitude.vs.getValue();
		me.svg_items.vs_needle.setRotation(pfd_props.altitude.vs_needle.getValue() * D2R);
		if (math.abs(vertical_speed) > 200) me.svg_items.vs_exact.show();
		else me.svg_items.vs_exact.hide();
		me.svg_items.vs_text.updateText(sprintf("%02d", math.abs(vertical_speed) / 100));
		me.svg_items.vs_exact.setTranslation(0, pfd_props.altitude.vs_translate.getValue() * scale_constant);
		# set airspeed
		var speed = pfd_props.airspeed.indicated.getValue();
		if (speed < 30) speed = 30;
		me.svg_items.airspeed.setTranslation(0, 2.645 * (speed - 30) * scale_constant);
		var maxspeed = pfd_props.airspeed.max.getValue();
		me.svg_items.overspeed_barber_poles.setTranslation(0, -2.645 * (maxspeed - 30) * scale_constant);
		# set mach
		var mach = pfd_props.airspeed.mach.getValue();
		if (mach > 0.5) {
			me.svg_items.mach.show();
			me.svg_items.mach.updateText(sprintf(".%d", mach * 1000));
		}
		if (mach < 0.45) me.svg_items.mach.hide();
		# fpv
		var has_vv = me.properties.vv.getValue();
		var fpv = me.svg_items.fpv;
		if (has_vv and pitch != nil) {
			fpv.show();
			var fpa = pitch - pfd_props.attitude.aoa.getValue();
			fpv.setTranslation(0, -pitch_to_px(fpa) * scale_constant); 
			fpv.setRotation(roll * math.pi / 180);
		} else {
			fpv.hide();
		}
		# bottom part - flaps
		var flap_pos = pfd_props.wing.flap.getValue();
		var flap_pos_norm = 0;
		if (flap_pos <= 0.29) flap_pos_norm = flap_pos * 0.25 / 0.29;
		if (flap_pos > 0.29 and flap_pos <= 0.596) flap_pos_norm = 0.25 + 0.25 * (flap_pos - 0.29) / 0.306;
		if (flap_pos > 0.596 and flap_pos <= 0.645) flap_pos_norm = 0.5 + 0.25 * (flap_pos - 0.596) / 0.049;
		if (flap_pos > 0.645) flap_pos_norm = 0.75 + (flap_pos - 0.645) * 0.25 / 0.355;
		me.svg_items.te_flaps.setTranslation(76 * flap_pos_norm * scale_constant, 38.504 * scale_constant * flap_pos_norm);
	},
	svg_items: {}
};
var pfd_props = {};
pfd.create_props(pfd_props);
var convert_fl = func(number) {
	var as_string = sprintf("%03d", math.abs(number));
	return as_string;
}
var pfd1 = pfd.new('PFD_L');
var pfd2 = pfd.new('PFD_R');