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
	new: func(name, property_number) {
		print('creating pfd with name', name);
		var returned = {parents: [pfd], svg_items: {}, properties: {}, pfd_props: {}};
		returned.property_number = property_number;
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
			print('showing primary flight display');
			var window = canvas.Window.new([889 / 2, 564], "dialog").set("resize", 1);
			window.setCanvas(display);
		};
		var path = "Aircraft/A350XWB/Models/Instruments/PFD2/pfd.svg";
		# create an image child
		var group = display.createGroup('svg');
		canvas.parsesvg(group, path, {"font-mapper": returned.font_mapper});
		foreach (elem; ["guides", "fdroll", "fdpitch", "fpv", "ils_rollout", "radioaltimeter", "pitch_ladder", "horizon", "ahrs", "pfd_heading_scale", "ball", "airspeed", "overspeed_barber_poles", "vls", "alpha_prot", "speed_selected", "speed_selected_1", "speed_selected_2", "mach", "speed_trend", "speed_trend_up", "speed_trend_down", "speed_trend_up_line", "speed_trend_down_line", "green_dot_speed", "te_flaps", "te_flaps_line", "le_flaps", "wing_scale", "flaps_cmd_frame", "flaps_cmd", "flap_triangle_1", "flap_triangle_2", "flap_triangle_3", "flap_triangle_4", "slat_circle_1", "slat_circle_2", "park_brk", "gear_down", "gear_transit_down", "gear_transit_up", "ils", "loc", "loc_left", "loc_right", "gs", "gs_up", "gs_down", "ils_ident", "ils_frequency", "ils_distance", "ils_distance_label", "ils_course_text_left", "ils_course_text_right", "ils_course_left", "ils_course_right", "ils_course_text", "ils_course", "hundred_numbers", "hundreds", "thousands", "thousands_zero", "ten_thousands", "alt_tape", "alt_fl", "alt_fl_selected", "alt_fl_selected_text", "alt_below_1", "alt_above_1", "alt_above_2", "moves_with_alt", "alt_ground_level", "vs_needle", "vs_exact", "vs_text", "stall", "heading_tape", "heading_tens", "heading_tens_plus_1", "heading_tens_plus_2", "heading_tens_plus_3", "heading_tens_minus_1", "heading_tens_minus_2", "yaw_marker", "track_marker", "fma_2_3", "fma_2_top", "fma_3_top", "fma_2_middle", "fma_3_middle", "fma_2.5", "vs_fpa", "fma_2_vs_value", "fma_2_vs", 'fma_5_fd', 'fma_5_athr', 'fma_5_ap']) {
			returned.svg_items[elem] = group.getElementById(elem);
			if (group.getElementById(elem) == nil) {
				setprop("/sim/messages/copilot", "pfd svg item " ~ elem ~ " does not exist!!!");
				print("pfd svg item " ~ elem ~ " does not exist!!!");
				setprop("/sim/messages/copilot", "");
			}
		}
		foreach (elem; ["alt_fl", "alt_fl_selected_text", "alt_below_1", "alt_above_1", "alt_above_2", "vs_text", "mach", "ils_ident", "ils_frequency", "ils_distance", "ils_course_text_left", "ils_course_text_right", "fma_2_top", "fma_3_top", "fma_2_middle", "fma_3_middle", "fma_2.5", "fma_2_vs_value", "fma_2_vs", "fma_5_ap", "speed_selected_1", "speed_selected_2", "heading_tens", "heading_tens_plus_1", "heading_tens_plus_2", "heading_tens_plus_3", "heading_tens_minus_1", "heading_tens_minus_2", "flaps_cmd"]) {
			returned.svg_items[elem].enableUpdate();
		}
		# prolly overkill to use all these decimal places but idc
		group.getElementById('speed').set('clip', 'rect(25.4, 6.35, 84.66665679, 26.45833025)');
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
		returned.svg_items.te_flaps_line.set('clip', 'rect(0, 500, 500, 26.05140113)');
		returned.svg_items.ahrs.updateCenter();
		returned.svg_items.fpv.updateCenter();
		returned.timer = maketimer(1 / 18, returned, me.update);
		returned.timer.start();
		returned.svg_items.radioaltimeter.enableUpdate();
		returned.create_props(returned.pfd_props);
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
			props.UpdateManager.FromHashValue('attitude_heading_offset', 0.05, func(offset) {
				returned.svg_items.pfd_heading_scale.setTranslation(4 * offset * scale_constant, 0);
			}),
			props.UpdateManager.FromHashValue('attitude_yaw_offset', 0.05, func(offset) {
				returned.svg_items.heading_tape.setTranslation(-4 * offset * scale_constant, 0);
			}),
			props.UpdateManager.FromHashValue('attitude_yaw_number', 0.5, func(number) {
				returned.svg_items.heading_tens.updateText(sprintf("%d", number));
				returned.svg_items.heading_tens_minus_1.updateText(sprintf("%d", math.fmod(number + 35, 36)));
				returned.svg_items.heading_tens_minus_2.updateText(sprintf("%d", math.fmod(number + 34, 36)));
				returned.svg_items.heading_tens_plus_1.updateText(sprintf("%d", math.fmod(number + 37, 36)));
				returned.svg_items.heading_tens_plus_2.updateText(sprintf("%d", math.fmod(number + 38, 36)));
				returned.svg_items.heading_tens_plus_3.updateText(sprintf("%d", math.fmod(number + 39, 36)));
			}),
			props.UpdateManager.FromHashValue('attitude_drift', 0.05, func(drift) {
				returned.svg_items.track_marker.setTranslation(drift * 4 * scale_constant, 0);
				if (returned.pfd_props.fma.trk_fpa.getValue()) returned.svg_items.yaw_marker.setTranslation(-drift * 4 * scale_constant, 0);
			}),
			props.UpdateManager.FromHashValue('attitude_ball', 0.01, func(ball) {
				returned.svg_items.ball.setTranslation(ball * 18 * scale_constant, 0);
			}),
			props.UpdateManager.FromHashValue('ils_course_difference', 0.05, func(course_difference) {
				returned.svg_items.ils_course.setTranslation(course_difference * 4 * scale_constant, 0);
				if (course_difference > 25) {
					returned.svg_items.ils_course_right.show();
					returned.svg_items.ils_course_left.hide();
				} else if (course_difference < -25) {
					returned.svg_items.ils_course_right.hide();
					returned.svg_items.ils_course_left.show();
				} else {
					returned.svg_items.ils_course_right.hide();
					returned.svg_items.ils_course_left.hide();
				}
			}),
			props.UpdateManager.FromHashValue('fma_trk_fpa', 0.5, func(trk_fpa) {
				if (trk_fpa) returned.svg_items.yaw_marker.setTranslation(-drift * 4 * scale_constant, 0);
				else returned.svg_items.yaw_marker.setTranslation(0, 0);
			}),
			props.UpdateManager.FromHashValue('vv', 0.5, func(vv) {
				if (vv) returned.svg_items.fpv.show();
				else returned.svg_items.fpv.hide();
			}),
			props.UpdateManager.FromHashList(['attitude_drift', 'attitude_fpa'], 0.025, func(hash) {
				returned.svg_items.fpv.setTranslation(hash.attitude_drift * 4 * scale_constant, -pitch_to_px(hash.attitude_fpa) * scale_constant); 
			}),
			props.UpdateManager.FromHashValue('altitude_indicated', 0.1, func(altitude) {
				returned.svg_items.thousands_zero.setVisible(altitude > 2000);
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
			props.UpdateManager.FromHashValue('altitude_selected', 1, func(altitude) {
				returned.svg_items.alt_fl_selected.setTranslation(0, -altitude / 100 * 20 * scale_constant);
				var altitude_text_raw = sprintf('%d', altitude / 100);
				if (size(altitude_text_raw) == 2) altitude_text = '0' ~ altitude_text_raw;
				else if (size(altitude_text_raw) == 1) altitude_text = '00' ~ altitude_text_raw;
				else altitude_text = altitude_text_raw;
				returned.svg_items.alt_fl_selected_text.updateText(altitude_text);
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
			props.UpdateManager.FromHashValue('airspeed_gd', 0.1, func(green_dot) {
				returned.svg_items.green_dot_speed.setTranslation(0, -2.645 * (green_dot - 30) * scale_constant);
			}),
			props.UpdateManager.FromHashValue('airspeed_delta', 0.05, func(delta) {
				returned.svg_items.speed_selected.setTranslation(0, -2.645 * (delta) * scale_constant);
				if (delta < -(112 / 2.645)) {
					returned.svg_items.speed_selected_2.show();
				} else returned.svg_items.speed_selected_2.hide();
				if (delta > (112 / 2.645)) {
					returned.svg_items.speed_selected_1.show();
				} else returned.svg_items.speed_selected_1.hide();
			}),
			props.UpdateManager.FromHashValue('airspeed_target', 0.005, func(speed) {
				var indicated_speed_target = '';
				if (speed < 1) {
					# probably mach
					indicated_speed_target = sprintf("%.02f", speed);
				} else {
					# probably kts
					indicated_speed_target = sprintf("%d", speed);
				}
				returned.svg_items.speed_selected_1.updateText(indicated_speed_target);
				returned.svg_items.speed_selected_2.updateText(indicated_speed_target)
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
			props.UpdateManager.FromHashList(['fd_ap1', 'fd_ap2'], 0.5, func(hash) {
				var text = '';
				if (hash.fd_ap1 or hash.fd_ap2) text ~= 'AP';
				if (hash.fd_ap1) text ~= '1';
				if (hash.fd_ap1 and hash.fd_ap2) text ~= '+';
				if (hash.fd_ap2) text ~= '2';
				returned.svg_items.fma_5_ap.updateText(text);
			}),
			props.UpdateManager.FromHashValue('fd_enabled', 0.5, func(value) {
				if (value) {
					returned.svg_items.guides.show();
					returned.svg_items.fma_5_fd.show();
				} else {
					returned.svg_items.guides.hide();
					returned.svg_items.fma_5_fd.hide();
				}
			}),
			props.UpdateManager.FromHashValue('fd_athr_enabled', 0.5, func(enabled) {
				if (enabled) {
					returned.svg_items.fma_5_athr.setColor(1, 1, 1);
				} else {
					returned.svg_items.fma_5_athr.setColor(0, 1, 1);
				}
			}),
			props.UpdateManager.FromHashValue('fd_athr', 0.5, func(value) {
				if (value) {
					returned.svg_items.fma_5_athr.show();
				} else {
					returned.svg_items.fma_5_athr.hide();
				}
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
				if (ls) {
					returned.svg_items.ils.show();
					returned.svg_items.ils_course.show();
					returned.svg_items.ils_course_text.show();
				} else {
					returned.svg_items.ils.hide();
					returned.svg_items.ils_course.hide();
					returned.svg_items.ils_course_text.hide();
				}
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
			props.UpdateManager.FromHashValue('ils_course', 0.5, func(course) {
				returned.svg_items.ils_course_text_left.updateText(sprintf("%d", course));
				returned.svg_items.ils_course_text_right.updateText(sprintf("%d", course));
			}),
			props.UpdateManager.FromHashValue('wing_flap', 0.001, func(flap_pos) {
				var flap_pos_norm = 0;
				if (flap_pos <= 0.29) flap_pos_norm = flap_pos * 0.25 / 0.29;
				if (flap_pos > 0.29 and flap_pos <= 0.596) flap_pos_norm = 0.25 + 0.25 * (flap_pos - 0.29) / 0.306;
				if (flap_pos > 0.596 and flap_pos <= 0.645) flap_pos_norm = 0.5 + 0.25 * (flap_pos - 0.596) / 0.049;
				if (flap_pos > 0.645) flap_pos_norm = 0.75 + (flap_pos - 0.645) * 0.25 / 0.355;
				if (flap_pos_norm < 0.002) returned.svg_items.te_flaps.setColor(1, 1, 1);
				else returned.svg_items.te_flaps.setColor(13 / 255, 192 / 255, 75 / 255);
				returned.svg_items.te_flaps.setTranslation(76 * flap_pos_norm * scale_constant, 38.504 * scale_constant * flap_pos_norm);
				returned.svg_items.te_flaps_line.setTranslation(-76 * scale_constant + 76 * flap_pos_norm * scale_constant, -38.504 * scale_constant + 38.504 * scale_constant * flap_pos_norm);
			}),
			props.UpdateManager.FromHashValue('wing_slat', 0.001, func(slat_pos) {
				var slat_pos_norm = 0;
				if (slat_pos <= 0.29) slat_pos_norm = slat_pos * 0.5 / 0.29;
				else slat_pos_norm = (slat_pos - 0.29) / 1.42 + 0.5;
				if (slat_pos_norm < 0.002) returned.svg_items.le_flaps.setColor(1, 1, 1);
				else returned.svg_items.le_flaps.setColor(13 / 255, 192 / 255, 75 / 255);
				returned.svg_items.le_flaps.setTranslation(-24.682 * slat_pos_norm * scale_constant, 5.028 * scale_constant * slat_pos_norm);
			}),
			props.UpdateManager.FromHashValue('wing_in_transit', 0.5, func(transit) {
				if (transit) {
					returned.svg_items.flaps_cmd_frame.show();
					returned.svg_items.flaps_cmd.setColor(0, 1, 1);
				} else {
					returned.svg_items.flaps_cmd_frame.hide();
					returned.svg_items.flaps_cmd.setColor(13 / 255, 192 / 255, 75 / 255);
					returned.svg_items.flap_triangle_1.setColorFill(1, 1, 1);
					returned.svg_items.flap_triangle_2.setColorFill(1, 1, 1);
					returned.svg_items.flap_triangle_3.setColorFill(1, 1, 1);
					returned.svg_items.flap_triangle_4.setColorFill(1, 1, 1);
					returned.svg_items.slat_circle_1.setColorFill(0, 0, 0, 0);
					returned.svg_items.slat_circle_2.setColorFill(0, 0, 0, 0);
					returned.svg_items.slat_circle_1.setColor(1, 1, 1);
					returned.svg_items.slat_circle_2.setColor(1, 1, 1);
				}
			}),
			props.UpdateManager.FromHashValue('wing_flap_mode', 0.3, func(flap_mode) {
				if (flap_mode > 0) returned.svg_items.wing_scale.show();
				else returned.svg_items.wing_scale.hide();
				var flap_text = "";
				if (flap_mode == 0) flap_text = '';
				else if (flap_mode == 1) flap_text = '1';
				else if (flap_mode == 1.5) flap_text = '1+F';
				else if (flap_mode == 2) flap_text = '2';
				else if (flap_mode == 3) flap_text = '3';
				else if (flap_mode == 4) flap_text = 'FULL';
				returned.svg_items.flaps_cmd.updateText(flap_text);
			}),
			props.UpdateManager.FromHashValue('wing_flap_cmd', 0.01, func(flap_cmd) {
				returned.svg_items.flap_triangle_1.setColorFill(1, 1, 1);
				returned.svg_items.flap_triangle_2.setColorFill(1, 1, 1);
				returned.svg_items.flap_triangle_3.setColorFill(1, 1, 1);
				returned.svg_items.flap_triangle_4.setColorFill(1, 1, 1);
				if (flap_cmd == 0.29)  returned.svg_items.flap_triangle_1.setColorFill(0, 1, 1);
				if (flap_cmd == 0.596)  returned.svg_items.flap_triangle_2.setColorFill(0, 1, 1);
				if (flap_cmd == 0.645)  returned.svg_items.flap_triangle_3.setColorFill(0, 1, 1);
				if (flap_cmd == 1)  returned.svg_items.flap_triangle_4.setColorFill(0, 1, 1);
			}),
			props.UpdateManager.FromHashValue('wing_slat_cmd', 0.01, func(slat_cmd) {
				returned.svg_items.slat_circle_1.setColor(1, 1, 1);
				returned.svg_items.slat_circle_2.setColor(1, 1, 1);
				if (slat_cmd == 0.29)  returned.svg_items.slat_circle_1.setColor(0, 1, 1);
				if (slat_cmd == 1)  returned.svg_items.slat_circle_2.setColor(0, 1, 1);
			}),
			props.UpdateManager.FromHashValue('gear_transit_up', 0.5, func(transit) {
				returned.svg_items.gear_transit_up.setVisible(transit);
			}),
			props.UpdateManager.FromHashValue('gear_transit_down', 0.5, func(down) {
				returned.svg_items.gear_transit_down.setVisible(down);
			}),
			props.UpdateManager.FromHashValue('gear_down', 0.5, func(transit) {
				returned.svg_items.gear_down.setVisible(transit);
			}),
			props.UpdateManager.FromHashValue('gear_park_brk', 0.5, func(park_brk) {
				returned.svg_items.park_brk.setVisible(park_brk);
			})
		];
		return returned;
	},
	create_props: func(hash) {
		hash.attitude = {
			pitch: props.globals.getNode('/orientation/model/pitch-deg'),
			roll: props.globals.getNode('/orientation/model/roll-deg'),
			aoa: props.globals.getNode('/fdm/jsbsim/aero/alpha-deg'),
			fpa: props.globals.getNode('/systems/pfd/fpa-sane'),
			ball: props.globals.getNode('/systems/pfd/slip-skid'),
			yaw_offset: props.globals.getNode('/systems/pfd/yaw-rounded'),
			yaw_number: props.globals.getNode('/systems/pfd/yaw-number'),
			heading_offset: props.globals.getNode('/systems/pfd/heading-rounded'),
			drift: props.globals.getNode('/it-autoflight/internal/drift-angle-deg')
		};
		hash.fd = {
			enabled: props.globals.getNode('/it-autoflight/output/fd1'),
			roll: props.globals.getNode('/it-autoflight/fd/roll-bar'),
			pitch: props.globals.getNode('/it-autoflight/fd/pitch-bar'),
			athr: props.globals.getNode('/it-autoflight/input/athr'),
			athr_enabled: props.globals.getNode('/systems/fadec/throttle/athr'),
			ap1: props.globals.getNode('/it-autoflight/input/ap1'),
			ap2: props.globals.getNode('/it-autoflight/input/ap2')
		};
		hash.altitude = {
			indicated: props.globals.getNode('/instrumentation/altimeter/indicated-altitude-ft'),
			vs: props.globals.getNode('/it-autoflight/internal/vert-speed-fpm'),
			vs_needle: props.globals.getNode('/systems/pfd/vs-needle'),
			vs_translate: props.globals.getNode('/systems/pfd/vs-text-translation'),
			radio: props.globals.getNode('/instrumentation/altimeter/indicated-radio-altitude-ft'),
			selected: props.globals.getNode('/it-autoflight/internal/alt')
		};
		hash.airspeed = {
			indicated: props.globals.getNode('/instrumentation/airspeed-indicator/indicated-speed-kt'),
			gd: props.globals.getNode('/systems/pfd/green-dot-speed'),
			delta: props.globals.getNode('/systems/pfd/speed-delta'),
			target: props.globals.getNode('/systems/pfd/speed-select'),
			mach: props.globals.getNode('/instrumentation/airspeed-indicator/indicated-mach'),
			trend: props.globals.getNode('/systems/pfd/speed-trend'),
			max: props.globals.getNode('/systems/pfd/max-speed'),
			vls: props.globals.getNode('/systems/pfd/vls'),
			vaprot: props.globals.getNode('/systems/pfd/v-alpha-prot'),
			vamax: props.globals.getNode('/systems/pfd/v-alpha-max')
		};
		hash.wing = {
			flap_mode: props.globals.getNode('/fdm/jsbsim/fcs/flap-mode'),
			in_transit: props.globals.getNode('/systems/pfd/flaps-transit'),
			flap: props.globals.getNode('/surface-positions/flap-pos-norm'),
			flap_cmd: props.globals.getNode('/fdm/jsbsim/fcs/flap-cmd-norm-actual'),
			slat: props.globals.getNode('/fdm/jsbsim/fcs/slat-pos-norm'),
			slat_cmd: props.globals.getNode('/fdm/jsbsim/fcs/slat-cmd-norm')
		};
		hash.ils = {
			frequency: props.globals.getNode('instrumentation/nav/frequencies/selected-mhz'),
			course: props.globals.getNode('/instrumentation/nav/radials/selected-deg'),
			course_difference: props.globals.getNode('/systems/pfd/course-difference'),
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
			fpa: props.globals.getNode('/it-autoflight/input/fpa'),
			trk_fpa: props.globals.getNode('/it-autoflight/input/true-course')
		};
		hash.gear = {
			transit_up: props.globals.getNode('/systems/pfd/gear-transit-up'),
			transit_down: props.globals.getNode('/systems/pfd/gear-transit-down'),
			down: props.globals.getNode('/systems/pfd/gear-down'),
			park_brk: props.globals.getNode('/controls/gear/brake-parking')
		};
	},
	update: func() {
		var pfd_props = me.pfd_props;
		# generate notification
		var notification = {};
		foreach (key; keys(me.pfd_props)) {
			foreach (key2; keys(me.pfd_props[key])) {
				notification[key ~ "_" ~ key2] = me.pfd_props[key][key2].getValue();
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
		var pitch = me.pfd_props.attitude.pitch.getValue();
		var roll = me.pfd_props.attitude.roll.getValue();
		# update fd
		# update altimeter
		if (me.pfd_props.altitude.radio.getValue() != nil) {

		}
		var altitude = me.pfd_props.altitude.indicated.getValue();

		# vsi
		var vertical_speed = me.pfd_props.altitude.vs.getValue();

		# set airspeed
		var vls = me.pfd_props.airspeed.vls.getValue();
		var speed = me.pfd_props.airspeed.indicated.getValue();
		var maxspeed = me.pfd_props.airspeed.max.getValue();
		var speed_trend = me.pfd_props.airspeed.trend.getValue();
		if (abs(speed_trend) > 2) {
			me.svg_items.speed_trend.setTranslation(0, -speed_trend * 2.645 * scale_constant);
			me.svg_items.speed_trend.show();
		}
		if (abs(speed_trend) < 1) me.svg_items.speed_trend.hide();
		# set mach
		var mach = me.pfd_props.airspeed.mach.getValue();
		# fpv
		var has_vv = me.properties.vv.getValue();
		var fpv = me.svg_items.fpv;
		if (has_vv and pitch != nil) {
			fpv.show();
			var fpa = pitch - me.pfd_props.attitude.aoa.getValue();
			#fpv.setTranslation(0, -pitch_to_px(fpa) * scale_constant); 
			fpv.setRotation(roll * math.pi / 180);
		} else {
			fpv.hide();
		}
		# ils
		var has_ils = me.properties.ls.getValue();
		if (has_ils) {
			me.svg_items.ils_frequency.updateText(sprintf("%.02f", pfd_props.ils.frequency.getValue()));
			var gs = me.pfd_props.ils.gs.getValue();
			var loc = me.pfd_props.ils.loc.getValue();
			me.svg_items.ils_ident.updateText(me.pfd_props.ils.name.getValue());
			if (me.pfd_props.ils.dme_in_range.getValue()) {
				me.svg_items.ils_distance.updateText(sprintf("%.1f", me.pfd_props.ils.dme.getValue()));
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
var convert_fl = func(number) {
	var as_string = sprintf("%03d", math.abs(number));
	return as_string;
}
var pfd1 = pfd.new('PFD_L', 0);
var pfd2 = pfd.new('PFD_R', 1);