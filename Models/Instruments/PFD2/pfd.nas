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
		"size": [2048, 4096], # Size of the underlying texture (should be a power of 2, required) [Resolution]
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
		foreach (elem; ["guides", "fdroll", "fdpitch", "fpv", "ils_rollout", "radioaltimeter", "pitch_ladder", "horizon", "ahrs", "ball", "airspeed", "overspeed_barber_poles", "vls", "alpha_prot", "mach", "speed_trend", "speed_trend_up", "speed_trend_down", "te_flaps", "le_flaps", "ils", "loc", "loc_left", "loc_right", "gs", "gs_up", "gs_down", "ils_ident", "ils_frequency", "ils_distance", "ils_distance_label", "hundred_numbers", "hundreds", "thousands", "ten_thousands", "alt_tape", "alt_fl", "alt_below_1", "alt_above_1", "alt_above_2", "moves_with_alt", "alt_ground_level", "vs_needle", "vs_exact", "vs_text", "stall", "fma_2_3", "fma_2_top", "fma_3_top", "fma_2_middle", "fma_3_middle", "fma_2.5", "vs_fpa", "fma_2_vs_value", "fma_2_vs"]) {
			returned.svg_items[elem] = group.getElementById(elem);
			if (group.getElementById(elem) == nil) {
				setprop("/sim/messages/copilot", "pfd svg item " ~ elem ~ " does not exist!!!");
				print("pfd svg item " ~ elem ~ " does not exist!!!");
				setprop("/sim/messages/copilot", "");
			}
		}
		foreach (elem; ["alt_fl", "alt_below_1", "alt_above_1", "alt_above_2", "vs_text", "mach", "ils_ident", "ils_frequency", "ils_distance", "fma_2_top", "fma_3_top", "fma_2_middle", "fma_3_middle", "fma_2.5", "fma_2_vs_value", "fma_2_vs"]) {
			returned.svg_items[elem].enableUpdate();
		}
		# prolly overkill to use all these decimal places but idc
		returned.svg_items.ahrs.set('clip', 'rect(24.87083043, 78.44894918, 84.97357342, 26.45833025)');
		returned.svg_items.hundred_numbers.set('clip', 'rect(50.31527746, 102.9760859, 60.58640126, 96.78219079)');
		var digitClip = 'rect(52.09407101, 102.9760859, 58.80760772, 87.31248981)';
		returned.svg_items.hundreds.set('clip', digitClip);
		returned.svg_items.thousands.set('clip', digitClip);
		returned.svg_items.ten_thousands.set('clip', digitClip);
		returned.svg_items.alt_tape.set('clip', 'rect(25.39999704, 98.86790097, 85.15798798, 85.91866498)');
		returned.svg_items.vs_needle.set('clip', 'rect(20.12420599, 115.0937366, 90.77747274, 109.8020705)');
		returned.svg_items.speed_trend_up.set('clip', 'rect(25.4, 20.79915799, 55.16561856, 6.349999259)');
		returned.svg_items.speed_trend_down.set('clip', 'rect(55.16561856, 20.79915799, 84.66665679, 6.349999259)');
		returned.svg_items.ahrs.updateCenter();
		returned.svg_items.fpv.updateCenter();
		returned.timer = maketimer(1 / 10, returned, me.update);
		returned.timer.start();
		returned.svg_items.radioaltimeter.enableUpdate();

		returned.update_items = [
			# attitude
			props.UpdateManager.FromHashValue('attitude_roll', 0.025, func(roll) {
				if (roll == nil) return;
				returned.svg_items.fpv.setRotation(roll * math.pi / 180);
				returned.svg_items.ahrs.setRotation(-roll * 3.1415926535 / 180);
			}),
			props.UpdateManager.FromHashValue('attitude_pitch', 0.025, func(pitch) {
				returned.svg_items.pitch_ladder.setTranslation(0, (pitch_to_px(pitch)) * scale_constant);
				var pitch_translation = pitch_to_px(pitch);
				if (pitch_translation > 70) {
					pitch_translation = 70;
				}
				if (pitch_translation < -70) {
					pitch_translation = -70;
				}
				returned.svg_items.horizon.setTranslation(0, pitch_translation * scale_constant);
			}),
			props.UpdateManager.FromHashValue('vv', 0.5, func(vv) {
				if (vv) returned.svg_items.fpv.show();
				else returned.svg_items.fpv.hide();
			}),
			props.UpdateManager.FromHashValue('attitude_fpa', 0.025, func(fpa) {
				returned.svg_items.fpv.setTranslation(0, -pitch_to_px(fpa) * scale_constant); 
			}),
			props.UpdateManager.FromHashValue('altitude_indicated', 1, func(altitude) {
				var hundred = math.fmod(altitude, 100);
				var hundreds = math.fmod(altitude, 1000);
				var hundreds_digit = math.floor(hundreds / 100);
				var thousands = math.fmod(altitude, 10000);
				var thousands_digit = math.floor(thousands / 1000);
				var ten_thousands = math.fmod(altitude, 100000);
				var ten_thousands_digit = math.floor(ten_thousands / 10000);
				returned.svg_items.hundred_numbers.setTranslation(0, 60 * scale_constant * hundred / 100);
				if (hundred <= 80) returned.svg_items.hundreds.setTranslation(0, 22 * scale_constant * hundreds_digit);
				else returned.svg_items.hundreds.setTranslation(0, 22 * scale_constant * (hundreds_digit + (hundred - 80) / 20));
				if (hundreds <= 980) returned.svg_items.thousands.setTranslation(0, 22 * scale_constant * thousands_digit);
				else returned.svg_items.thousands.setTranslation(0, 22 * scale_constant * (thousands_digit + (hundreds - 980) / 20));
				if (thousands <= 9980) returned.svg_items.ten_thousands.setTranslation(0, 22 * scale_constant * ten_thousands_digit);
				else returned.svg_items.ten_thousands.setTranslation(0, 22 * scale_constant * (ten_thousands_digit + (thousands - 9980) / 20));
				# move the altitude tape
				var five_fl_below = math.floor(altitude / 500) * 5 - 5;
				returned.svg_items.alt_below_1.updateText(convert_fl(five_fl_below));
				returned.svg_items.alt_fl.updateText(convert_fl(five_fl_below + 5));
				returned.svg_items.alt_above_1.updateText(convert_fl(five_fl_below + 10));
				returned.svg_items.alt_above_2.updateText(convert_fl(five_fl_below + 15));
				returned.svg_items.alt_tape.setTranslation(0, 20 * (altitude / 100 - five_fl_below - 5) * scale_constant);
				returned.svg_items.moves_with_alt.setTranslation(0, altitude / 100 * 20 * scale_constant);
			}),
			props.UpdateManager.FromHashValue('altitude_vs_needle', 0.1, func(needle) {
				returned.svg_items.vs_needle.setRotation(needle * D2R);
			}),
			props.UpdateManager.FromHashValue('altitude_vs_translate', 0.5, func(vs_translate) {
				returned.svg_items.vs_exact.setTranslation(0, vs_translate * scale_constant);
			}),
			props.UpdateManager.FromHashValue('altitude_vs', 50, func(vertical_speed) {
				if (math.abs(vertical_speed) > 200) returned.svg_items.vs_exact.show();
				else returned.svg_items.vs_exact.hide();
				returned.svg_items.vs_text.updateText(sprintf("%02d", math.abs(vertical_speed) / 100));
			}),
			props.UpdateManager.FromHashValue('altitude_radio', 0.5, func(ra) {
				#var ra = (num(pfd_props.altitude.radio.getValue()) - 4);
				returned.svg_items.alt_ground_level.setTranslation(0, ra * 20 / 100 * scale_constant);
				if (ra < 30) {
					returned.svg_items.fdroll.hide();
					returned.svg_items.ils_rollout.show();
				} else {
					returned.svg_items.fdroll.show();
					returned.svg_items.ils_rollout.hide();
				}
				if (ra > 2500) returned.svg_items.radioaltimeter.hide();
				else {
					returned.svg_items.radioaltimeter.show();
					var roundTo = 1;
					if (ra > 5) roundTo = 5;
					if (ra > 50) roundTo = 10;
					returned.svg_items.radioaltimeter.updateText(sprintf("%d", math.round(ra / roundTo) * roundTo));
				}
			}),
			props.UpdateManager.FromHashValue('airspeed_indicated', 0.1, func(speed) {
				if (speed < 30) speed = 30;
				returned.svg_items.airspeed.setTranslation(0, 2.645 * (speed - 30) * scale_constant);
			}),
			props.UpdateManager.FromHashValue('airspeed_max', 0.1, func(maxspeed) {
				returned.svg_items.overspeed_barber_poles.setTranslation(0, -2.645 * (maxspeed - 30) * scale_constant);
			}),
			props.UpdateManager.FromHashValue('airspeed_vamax', 0.1, func(vamax) {
				returned.svg_items.stall.setTranslation(0, -2.645 * (vamax - 30) * scale_constant);
			}),
			props.UpdateManager.FromHashValue('airspeed_vaprot', 0.1, func(vaprot) {
				returned.svg_items.alpha_prot.setTranslation(0, -2.645 * (vaprot - 30) * scale_constant);
			}),
			props.UpdateManager.FromHashValue('airspeed_vls', 0.1, func(vls) {
				returned.svg_items.vls.setTranslation(0, -2.645 * (vls - 30) * scale_constant);
			}),
			props.UpdateManager.FromHashValue('airspeed_mach', 0.0005, func(mach) {
				if (mach > 0.5) {
					returned.svg_items.mach.show();
				}
				if (mach > 0.45) {
					returned.svg_items.mach.updateText(sprintf(".%d", mach * 1000));
				}
				if (mach < 0.45) returned.svg_items.mach.hide();
			}),
			props.UpdateManager.FromHashValue('fd_enabled', 0.5, func(value) {
				if (value) returned.svg_items.guides.show();
				else returned.svg_items.guides.hide();
			}),
			props.UpdateManager.FromHashValue('fd_roll', 0.1, func(roll) {
				returned.svg_items.fdroll.setTranslation(roll * 1.5 * scale_constant, 0);
			}),
			props.UpdateManager.FromHashValue('fd_pitch', 0.1, func(pitch_offset) {
				if (pitch_offset < -9) pitch_offset = -9;
				if (pitch_offset > 9) pitch_offset = 9;
				returned.svg_items.fdpitch.setTranslation(0, -pitch_to_px(pitch_offset) / 2 * scale_constant);
			}),
			props.UpdateManager.FromHashValue('ls', 0.5, func(ls) {
				if (ls) returned.svg_items.ils.show();
				else returned.svg_items.ils.hide();
			}),
			props.UpdateManager.FromHashValue('ils_gs', 0.0025, func(gs) {
				returned.svg_items.gs.setTranslation(0, -80 * gs * scale_constant);
				if (gs > 0.999) {
					returned.svg_items.gs_up.show();
					returned.svg_items.gs_down.hide();
				} else if (gs < -0.999) {
					returned.svg_items.gs_up.hide();
					returned.svg_items.gs_down.show();
				} else {
					returned.svg_items.gs_up.show();
					returned.svg_items.gs_down.show();
				}
			}),
			props.UpdateManager.FromHashValue('ils_gs_in_range', 0.5, func(gs_in_range) {
				if (gs_in_range) returned.svg_items.gs.show();
				else returned.svg_items.gs.hide();
			}),
			props.UpdateManager.FromHashValue('ils_loc', 0.0025, func(loc) {
				returned.svg_items.loc.setTranslation(80 * loc * scale_constant, 0);
				returned.svg_items.ils_rollout.setTranslation(90 * loc * scale_constant, 0);
				if (loc > 0.999) {
					returned.svg_items.loc_right.show();
					returned.svg_items.loc_left.hide();
				} else if (loc < -0.999) {
					returned.svg_items.loc_right.hide();
					returned.svg_items.loc_left.show();
				} else {
					returned.svg_items.loc_right.show();
					returned.svg_items.loc_left.show();
				}
			}),
			props.UpdateManager.FromHashValue('ils_loc_in_range', 0.5, func(loc_in_range) {
				if (loc_in_range) returned.svg_items.loc.show();
				else returned.svg_items.loc.hide();
			}),
			props.UpdateManager.FromHashValue('wing_flap', 0.001, func(flap_pos) {
				var flap_pos_norm = 0;
				if (flap_pos <= 0.29) flap_pos_norm = flap_pos * 0.25 / 0.29;
				if (flap_pos > 0.29 and flap_pos <= 0.596) flap_pos_norm = 0.25 + 0.25 * (flap_pos - 0.29) / 0.306;
				if (flap_pos > 0.596 and flap_pos <= 0.645) flap_pos_norm = 0.5 + 0.25 * (flap_pos - 0.596) / 0.049;
				if (flap_pos > 0.645) flap_pos_norm = 0.75 + (flap_pos - 0.645) * 0.25 / 0.355;
				returned.svg_items.te_flaps.setTranslation(76 * flap_pos_norm * scale_constant, 38.504 * scale_constant * flap_pos_norm);
			}),
			props.UpdateManager.FromHashValue('wing_slat', 0.001, func(slat_pos) {
				var slat_pos_norm = 0;
				if (slat_pos <= 0.29) slat_pos_norm = slat_pos * 0.5 / 0.29;
				else slat_pos_norm = (slat_pos - 0.29) / 0.71 + 0.5;
				returned.svg_items.le_flaps.setTranslation(-24.682 * slat_pos_norm * scale_constant, 5.028 * scale_constant * slat_pos_norm);
			})
		];
		return returned;
	},
	create_props: func(hash) {
		hash.attitude = {
			pitch: props.globals.getNode('/orientation/model/pitch-deg'),
			roll: props.globals.getNode('/orientation/model/roll-deg'),
			aoa: props.globals.getNode('/fdm/jsbsim/aero/alpha-deg'),
			fpa: props.globals.getNode('/systems/pfd/fpa-sane')
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
			trend: props.globals.getNode('/systems/pfd/speed-trend'),
			max: props.globals.getNode('/systems/pfd/max-speed'),
			vls: props.globals.getNode('/systems/pfd/vls'),
			vaprot: props.globals.getNode('/systems/pfd/v-alpha-prot'),
			vamax: props.globals.getNode('/systems/pfd/v-alpha-max')
		};
		hash.wing = {
			flap: props.globals.getNode('/surface-positions/flap-pos-norm'),
			slat: props.globals.getNode('/fdm/jsbsim/fcs/slat-pos-norm')
		};
		hash.ils = {
			frequency: props.globals.getNode('instrumentation/nav/frequencies/selected-mhz'),
			name: props.globals.getNode('/instrumentation/nav/nav-id'),
			dme: props.globals.getNode('/instrumentation/dme/indicated-distance-nm'),
			dme_in_range: props.globals.getNode('/instrumentation/dme/in-range'),
			loc: props.globals.getNode('instrumentation/nav/heading-needle-deflection-norm'),
			loc_in_range: props.globals.getNode('/instrumentation/nav/in-range'),
			gs: props.globals.getNode('instrumentation/nav/gs-needle-deflection-norm'),
			gs_in_range: props.globals.getNode('/instrumentation/nav/gs-in-range')
		};
		hash.fma = {
			vs: props.globals.getNode('/it-autoflight/input/vs'),
			fpa: props.globals.getNode('/it-autoflight/input/fpa')
		}
	},
	update: func() {
		# generate notification
		var notification = {};
		foreach (key; keys(pfd_props)) {
			foreach (key2; keys(pfd_props[key])) {
				notification[key ~ "_" ~ key2] = pfd_props[key][key2].getValue();
			}
		}
		notification.ls = me.properties.ls.getValue();
		notification.vv = me.properties.vv.getValue();
		foreach (item; me.update_items) item.update(notification);
		# update fma
		me.svg_items.fma_3_top.updateText(itaf.UpdateFma.latText);
		if (itaf.UpdateFma.vertText != 'FPA' and itaf.UpdateFma.vertText != 'V/S') {
			me.svg_items.fma_2_top.updateText(itaf.UpdateFma.vertText);
			me.svg_items.fma_2_top.show();
			me.svg_items.vs_fpa.hide();
		} else {
			me.svg_items.fma_2_vs.updateText(itaf.UpdateFma.vertText);
			var vs_value = "";
			if (itaf.UpdateFma.vertText == 'V/S') {
				vs_value_raw = pfd_props.fma.vs.getValue();
				if (vs_value_raw >= 0) vs_value = "+";
				else vs_value_raw = "";
				vs_value ~= sprintf("%d", vs_value_raw);
			} else {
				vs_value_raw = pfd_props.fma.fpa.getValue();
				if (vs_value_raw >= 0) vs_value = "+";
				else vs_value_raw = "";
				vs_value ~= sprintf("%.1f", vs_value_raw);
			}
			me.svg_items.fma_2_vs_value.updateText(vs_value);
			me.svg_items.fma_2_top.hide();
			me.svg_items.vs_fpa.show();
		}
		if (itaf.UpdateFma.latText == itaf.UpdateFma.vertText) {
			# land or flare or rollout
			me.svg_items['fma_2.5'].updateText(itaf.UpdateFma.latText);
			me.svg_items.fma_2_3.hide();
			me.svg_items['fma_2.5'].show();
		} else {
			me.svg_items.fma_2_3.show();
			me.svg_items['fma_2.5'].hide();
		}
		var pitch = pfd_props.attitude.pitch.getValue();
		var roll = pfd_props.attitude.roll.getValue();
		# update fd
		# update altimeter
		if (pfd_props.altitude.radio.getValue() != nil) {

		}
		var altitude = pfd_props.altitude.indicated.getValue();

		# vsi
		var vertical_speed = pfd_props.altitude.vs.getValue();

		# set airspeed
		var vls = pfd_props.airspeed.vls.getValue();
		var speed = pfd_props.airspeed.indicated.getValue();
		var maxspeed = pfd_props.airspeed.max.getValue();
		var speed_trend = pfd_props.airspeed.trend.getValue();
		if (abs(speed_trend) > 2) {
			me.svg_items.speed_trend.setTranslation(0, -speed_trend * 2.645 * scale_constant);
			me.svg_items.speed_trend.show();
		}
		if (abs(speed_trend < 1)) me.svg_items.speed_trend.hide();
		# set mach
		var mach = pfd_props.airspeed.mach.getValue();
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
		# ils
		var has_ils = me.properties.ls.getValue();
		if (has_ils) {
			me.svg_items.ils_frequency.updateText(sprintf("%.02f", pfd_props.ils.frequency.getValue()));
			var gs = pfd_props.ils.gs.getValue();
			var loc = pfd_props.ils.loc.getValue();
			me.svg_items.ils_ident.updateText(pfd_props.ils.name.getValue());
			if (pfd_props.ils.dme_in_range.getValue()) {
				me.svg_items.ils_distance.updateText(sprintf("%.1f", pfd_props.ils.dme.getValue()));
				me.svg_items.ils_distance.show();
				me.svg_items.ils_distance_label.show();
			} else {
				me.svg_items.ils_distance.hide();
				me.svg_items.ils_distance_label.hide();
			}
			me.svg_items.ils.show();
		} else me.svg_items.ils.hide();
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