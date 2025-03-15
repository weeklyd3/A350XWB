print("let's make a pfd here");
var scale_constant = 1 / 3.779528;
var hud_pitch_scale = 48.401 / 5;
var hud_heading_scale = 8.894594812;
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
	new: func(name, property_number, hud_name) {
		print('creating pfd with name ', name);
		var returned = {parents: [pfd], svg_items: {}, hud_svg_items: {}, properties: {}, pfd_props: {}};
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
		var hud = canvas.new({
			name: hud_name,
			"size": [2048, 2048],
			view: [293 * 3, 212 * 3],
			mipmapping: 1
		});
		print('creating hud with name ', hud_name);
		hud.addPlacement({"node": hud_name, 'texture': 'hud_texture_big.png'});
		display.addPlacement({"node": name, "texture": "pfd_test.png"});
		returned.show = func() {
			print('showing primary flight display');
			var window = canvas.Window.new([889 / 2, 564], "dialog").set("resize", 1);
			window.setCanvas(display);
		};
		# top of hud svg is 7.51541 degrees at standard pilot view
		# bottom of hud svg is 16.75748 degrees at standard pilot view
		# 15.93815
		# 6.85641
		# (7.25709)
		# (15.96306)
		# 15.70604 left
		# 16.14780 right
		# each 5 degrees is thus 46.502322336 units on the svg
		# each 10 degrees of heading is thus 88.94594812 units on the svg
		var path = "Aircraft/A350XWB/Models/Instruments/PFD2/pfd.svg";
		# create an image child
		var group = display.createGroup('svg');
		var hud_group = hud.createGroup('svg');
		canvas.parsesvg(hud_group, 'Aircraft/A350XWB/Models/Instruments/PFD2/hud.svg', {"font-mapper": returned.font_mapper});
		canvas.parsesvg(group, path, {"font-mapper": returned.font_mapper});
		foreach (elem; ["guides", "fdroll", "fdpitch", "fpv", "fpv_group", "ils_rollout", "radioaltimeter", "pitch_ladder", "horizon", "ahrs", "pfd_heading_scale", "pfd_heading_scale_group", "bottom_mask_ground", "ball", "airspeed", "overspeed_barber_poles", "vls", "alpha_prot", "speed_selected", "speed_selected_1", "speed_selected_2", "mach", "airspeed_bottom_line", "speed_trend", "speed_trend_up", "speed_trend_down", "speed_trend_up_line", "speed_trend_down_line", "green_dot_speed", "te_flaps", "te_flaps_line", "le_flaps", "wing_scale", "wing_spoiler", "wing_spoiler_arm", "spoiler", "flaps_cmd_frame", "flaps_cmd", "flap_triangle_1", "flap_triangle_2", "flap_triangle_3", "flap_triangle_4", "slat_circle_1", "slat_circle_2", "park_brk", "gear_down", "gear_transit_down", "gear_transit_up", "ils", "loc", "loc_left", "loc_right", "gs", "gs_up", "gs_down", "ils_ident", "ils_frequency", "ils_distance", "ils_distance_label", "ils_course_text_left", "ils_course_text_right", "ils_course_left", "ils_course_right", "ils_course_text", "ils_course", "hundred_numbers", "hundreds", "thousands", "thousands_zero", "ten_thousands", "alt_tape", "alt_fl", "alt_fl_selected", "alt_fl_selected_text", "alt_below_1", "alt_above_1", "alt_above_2", "moves_with_alt", "alt_ground_level", "vs_needle", "vs_exact", "vs_text", "stall", "heading_tape", "heading_tens", "heading_tens_plus_1", "heading_tens_plus_2", "heading_tens_plus_3", "heading_tens_minus_1", "heading_tens_minus_2", "yaw_marker", "track_marker", "fma_1", "fma_1_man", "fma_1_athr_mode", "fma_1_man_mode", "fma_1_flex_box", "fma_1_orange_box", "fma_1_flex_temp", "fma_2_3", "fma_2_top", "fma_3_top", "fma_2_middle", "fma_3_middle", "fma_2.5", "fma_2_vs_value", 'fma_5_fd', 'fma_5_athr', 'fma_5_ap']) {
			returned.svg_items[elem] = group.getElementById(elem);
			if (group.getElementById(elem) == nil) {
				setprop("/sim/messages/copilot", "pfd svg item " ~ elem ~ " does not exist!!!");
				print("pfd svg item " ~ elem ~ " does not exist!!!");
				setprop("/sim/messages/copilot", "");
			}
		}
		foreach (elem; ["ahrs", "pitch_ladder", "fpv", 'fpv_circle', 'fpv_circle_shadow', 'fpv_diamond', 'fpv_diamond_shadow', 'ra', 'chevrons', 'fpd', 'hud', 'ball', 'heading_scale', 'drift', 'moves_with_speed', 'speed_selected', 'overspeed', 'stall', 'alpha_prot', 'vls', 'heading', 'heading_minus_one', 'heading_plus_one', 'heading_plus_two', 'alt_numbers', 'altitude_hundreds', 'altitude_thousands', 'altitude_ten_thousands', 'altitude_thousands_zero', 'altitude', 'altitude_number', 'altitude_number_minus_one', 'altitude_number_plus_one', 'altitude_number_plus_two', 'vs_needle', 'vs_text', 'loc_needle', 'loc_needle_left', 'loc_needle_right', 'loc', 'gs', 'gs_needle', 'gs_needle_up', 'gs_needle_down', 'ils_course', 'ils_info', 'ils_ident', 'ils_frequency', 'ils_dme', 'ils_distance', 'runway_group']) {
			returned.hud_svg_items[elem] = hud_group.getElementById(elem);
			if (hud_group.getElementById(elem) == nil) {
				setprop("/sim/messages/copilot", "hud svg item " ~ elem ~ " does not exist!!!");
				print("hud svg item " ~ elem ~ " does not exist!!!");
				setprop("/sim/messages/copilot", "");
			}
		}
		returned.synthetic_runway_item = nil;
		foreach (elem; ['ra', 'heading', 'heading_minus_one', 'heading_plus_one', 'heading_plus_two', 'altitude_number', 'altitude_number_minus_one', 'altitude_number_plus_one', 'altitude_number_plus_two', 'vs_text', 'ils_ident', 'ils_frequency', 'ils_distance']) {
			returned.hud_svg_items[elem].enableUpdate();
		}
		returned.hud_svg_items.moves_with_speed.set('clip', 'rect(277.433, 335.544, 362.470, 318.596)');
		returned.hud_svg_items.speed_selected.set('clip', 'rect(277.433, 400, 362.470, 318.596)');
		returned.hud_svg_items.overspeed.set('clip', 'rect(277.433, 400, 362.470, 318.596)');
		returned.hud_svg_items.alpha_prot.set('clip', 'rect(277.433, 400, 362.470, 318.596)');
		returned.hud_svg_items.vls.set('clip', 'rect(277.433, 400, 362.470, 318.596)');
		returned.hud_svg_items.stall.set('clip', 'rect(277.433, 400, 362.470, 318.596)');
		returned.hud_svg_items.alt_numbers.set('clip', 'rect(313.551, 552.992, 326.351, 544.892)');
		returned.hud_svg_items.altitude_hundreds.set('clip', 'rect(315.983, 544.892, 324.017, 531.908)');
		returned.hud_svg_items.altitude_thousands.set('clip', 'rect(315.983, 544.892, 324.017, 531.908)');
		returned.hud_svg_items.altitude_ten_thousands.set('clip', 'rect(315.983, 544.892, 324.017, 533.908)');
		returned.hud_svg_items.altitude.set('clip', 'rect(277.433, 552.876, 362.470,  531.422)');
		returned.hud_svg_items.vs_needle.set('clip', 'rect(0, 575.532, 1000, 570)');
		foreach (elem; ["alt_fl", "alt_fl_selected_text", "alt_below_1", "alt_above_1", "alt_above_2", "vs_text", "mach", "ils_ident", "ils_frequency", "ils_distance", "ils_course_text_left", "ils_course_text_right", "fma_1_athr_mode", "fma_1_man_mode", "fma_1_flex_temp", "fma_2_top", "fma_3_top", "fma_2_middle", "fma_3_middle", "fma_2.5", "fma_2_vs_value", "fma_5_ap", "speed_selected_1", "speed_selected_2", "heading_tens", "heading_tens_plus_1", "heading_tens_plus_2", "heading_tens_plus_3", "heading_tens_minus_1", "heading_tens_minus_2", "flaps_cmd"]) {
			returned.svg_items[elem] = group.getElementById(elem);
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
		returned.svg_items.speed_trend_up_line.set('clip', 'rect(25.4, 20.79915799, 55.16561856, 6.349999259)');
		returned.svg_items.speed_trend_down_line.set('clip', 'rect(55.16561856, 20.79915799, 84.66665679, 6.349999259)');
		returned.svg_items.te_flaps_line.set('clip', 'rect(0, 500, 500, 26.05140113)');
		returned.svg_items.ahrs.updateCenter();
		returned.svg_items.fpv.updateCenter();
		returned.timer = maketimer(1 / 18, returned, me.update);
		returned.timer.start();
		returned.svg_items.radioaltimeter.enableUpdate();
		returned.create_props(returned.pfd_props);
		returned.fma = {
			fma_5_athr: fma_line.new(group, 'fma_5_athr', 'A/THR', [1, 1, 1], 0),
			fma_5_fd: fma_line.new(group, 'fma_5_fd', '1FD2', [1, 1, 1], 1),
			fma_5_ap: fma_line.new(group, 'fma_5_ap', 'AP2', [1, 1, 1], 0),
			fma_3_top: fma_line.new(group, 'fma_3_top', 'something', [1, 1, 1], 0),
			fma_3_middle: fma_line.new(group, 'fma_3_middle', 'something', [1, 1, 1], 0),
			fma_2_middle: fma_line.new(group, 'fma_2_middle', 'something', [1, 1, 1], 0),
			fma_2_top: fma_line.new(group, 'fma_2_top', 'something', [1, 1, 1], 0),
			fma_1_athr_mode: fma_line.new(group, 'fma_1_athr_mode', 'something', [1, 1, 1], 0),
		};
		returned.fma['fma_2.5'] = fma_line.new(group, 'fma_2.5', 'something', [1, 1, 1], 0);
		returned.update_items = [
			#props.UpdateManager.FromHashValue('hud_scale', 0.005, func(scale) {
				#returned.hud_svg_items.hud.setScale(scale, scale);
			#	returned.hud_svg_items.hud.setTranslation(-(1 - scale) * 879 / 2, -(1 - scale) * 636 * 0.5);
			#}),
			# attitude
			props.UpdateManager.FromHashValue('attitude_roll', 0.025, func(roll) {
				if (roll == nil) return;
				returned.svg_items.fpv.setRotation(roll * math.pi / 180);
				returned.svg_items.ahrs.setRotation(-roll * 3.1415926535 / 180);
				returned.hud_svg_items.fpv.setRotation(roll * math.pi / 180);
				returned.hud_svg_items.ahrs.setRotation(-roll * 3.1415926535 / 180);
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
				returned.svg_items.pfd_heading_scale_group.setTranslation(0, pitch_translation * scale_constant);
				returned.svg_items.fpv_group.setTranslation(0, pitch_to_px(pitch) * scale_constant);
				returned.hud_svg_items.pitch_ladder.setTranslation(0, pitch * hud_pitch_scale);
			}),
			props.UpdateManager.FromHashValue('attitude_heading_offset', 0.05, func(offset) {
				returned.svg_items.pfd_heading_scale.setTranslation(-4 * offset * scale_constant, 0);
				returned.hud_svg_items.heading_scale.setTranslation(-hud_heading_scale * offset, 0);
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
				returned.hud_svg_items.heading.updateText(sprintf("%d", math.fmod(number, 36)));
				returned.hud_svg_items.heading_minus_one.updateText(sprintf("%d", math.fmod(number + 35, 36)));
				returned.hud_svg_items.heading_plus_one.updateText(sprintf("%d", math.fmod(number + 37, 36)));
				returned.hud_svg_items.heading_plus_two.updateText(sprintf("%d", math.fmod(number + 38, 36)));
			}),
			props.UpdateManager.FromHashValue('attitude_drift', 0.05, func(drift) {
				returned.svg_items.track_marker.setTranslation(drift * 4 * scale_constant, 0);
			}),
			props.UpdateManager.FromHashValue('attitude_ball', 0.01, func(ball) {
				returned.svg_items.ball.setTranslation(ball * 18 * scale_constant, 0);
				returned.hud_svg_items.ball.setTranslation(ball * 12, 0);
			}),
			props.UpdateManager.FromHashValue('ils_course_difference', 0.05, func(course_difference) {
				returned.svg_items.ils_course.setTranslation(course_difference * 4 * scale_constant, 0);
				returned.hud_svg_items.ils_course.setTranslation(course_difference * hud_heading_scale, 0);
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
			props.UpdateManager.FromHashValue('vv', 0.5, func(vv) {
				if (vv) returned.svg_items.fpv.show();
				else returned.svg_items.fpv.hide();
			}),
			props.UpdateManager.FromHashList(['attitude_drift', 'attitude_fpa'], 0.025, func(hash) {
				returned.svg_items.fpv.setTranslation(hash.attitude_drift * 4 * scale_constant, -pitch_to_px(hash.attitude_fpa) * scale_constant); 
				returned.hud_svg_items.fpv.setTranslation(hash.attitude_drift * hud_heading_scale, -hash.attitude_fpa * hud_pitch_scale);
				returned.hud_svg_items.drift.setTranslation(hash.attitude_drift * hud_heading_scale, 0);
			}),
			props.UpdateManager.FromHashValue('altitude_indicated', 0.1, func(altitude) {
				var altitude_real = altitude;
				var altitude = math.abs(altitude);
				returned.svg_items.thousands_zero.setVisible(altitude > 2000);
				returned.hud_svg_items.altitude_thousands_zero.setVisible(altitude > 2000);
				var hundred = math.fmod(altitude, 100);
				var hundreds = math.fmod(altitude, 1000);
				var hundreds_digit = math.floor(hundreds / 100);
				var thousands = math.fmod(altitude, 10000);
				var thousands_digit = math.floor(thousands / 1000);
				var ten_thousands = math.fmod(altitude, 100000);
				var ten_thousands_digit = math.floor(ten_thousands / 10000);
				returned.svg_items.hundred_numbers.setTranslation(0, 60 * scale_constant * hundred / 100);
				returned.hud_svg_items.alt_numbers.setTranslation(0, 22.5 * hundred / 100);
				if (hundred <= 80) {
					returned.svg_items.hundreds.setTranslation(0, 22 * scale_constant * hundreds_digit);
					returned.hud_svg_items.altitude_hundreds.setTranslation(0, 7 * hundreds_digit);
				} else {
					returned.svg_items.hundreds.setTranslation(0, 22 * scale_constant * (hundreds_digit + (hundred - 80) / 20));
					returned.hud_svg_items.altitude_hundreds.setTranslation(0, 7 * (hundreds_digit + (hundred - 80) / 20));
				}
				if (hundreds <= 980) {
					returned.svg_items.thousands.setTranslation(0, 22 * scale_constant * thousands_digit);
					returned.hud_svg_items.altitude_thousands.setTranslation(0, 7 * thousands_digit);
				} else {
					returned.svg_items.thousands.setTranslation(0, 22 * scale_constant * (thousands_digit + (hundreds - 980) / 20));
					returned.hud_svg_items.altitude_thousands.setTranslation(0, 7 * (thousands_digit + (hundreds - 980) / 20));
				}
				if (thousands <= 9980) {
					returned.svg_items.ten_thousands.setTranslation(0, 22 * scale_constant * ten_thousands_digit);
					returned.hud_svg_items.altitude_ten_thousands.setTranslation(0, 7 * ten_thousands_digit);
				} else {
					returned.svg_items.ten_thousands.setTranslation(0, 22 * scale_constant * (ten_thousands_digit + (thousands - 9980) / 20));
					returned.hud_svg_items.altitude_ten_thousands.setTranslation(0, 7 * (ten_thousands_digit + (thousands - 9980) / 20));
				}
				# move the altitude tape
				var five_fl_below = math.floor(altitude_real / 500) * 5 - 5;
				returned.svg_items.alt_below_1.updateText(convert_fl(five_fl_below));
				returned.hud_svg_items.altitude_number_minus_one.updateText(convert_fl(five_fl_below));
				returned.svg_items.alt_fl.updateText(convert_fl(five_fl_below + 5));
				returned.hud_svg_items.altitude_number.updateText(convert_fl(five_fl_below + 5));
				returned.svg_items.alt_above_1.updateText(convert_fl(five_fl_below + 10));
				returned.hud_svg_items.altitude_number_plus_one.updateText(convert_fl(five_fl_below + 10));
				returned.svg_items.alt_above_2.updateText(convert_fl(five_fl_below + 15));
				returned.hud_svg_items.altitude_number_plus_two.updateText(convert_fl(five_fl_below + 15));
				returned.svg_items.alt_tape.setTranslation(0, 20 * (altitude_real / 100 - five_fl_below - 5) * scale_constant);
				returned.hud_svg_items.altitude.setTranslation(0, 7 * (altitude_real / 100 - five_fl_below - 5));
				returned.svg_items.moves_with_alt.setTranslation(0, altitude_real / 100 * 20 * scale_constant);
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
				returned.hud_svg_items.vs_needle.setRotation(needle * D2R);
			}),
			props.UpdateManager.FromHashValue('altitude_vs_translate', 0.5, func(vs_translate) {
				returned.svg_items.vs_exact.setTranslation(0, vs_translate * scale_constant);
				returned.hud_svg_items.vs_text.setTranslation(0, vs_translate * 63 / 150);
			}),
			props.UpdateManager.FromHashValue('altitude_vs', 50, func(vertical_speed) {
				if (math.abs(vertical_speed) > 200) {
					returned.svg_items.vs_exact.show();
					returned.hud_svg_items.vs_text.show();
				} else {
					returned.svg_items.vs_exact.hide();
					returned.hud_svg_items.vs_text.hide();
				}
				returned.svg_items.vs_text.updateText(sprintf("%02d", math.abs(vertical_speed) / 100));
				returned.hud_svg_items.vs_text.updateText(sprintf("%02d", math.abs(vertical_speed) / 100));
			}),
			props.UpdateManager.FromHashList(['altitude_radio', 'attitude_pitch'], 0.1, func(pfd_hash) {
				#var ra = (num(pfd_props.altitude.radio.getValue()) - 4);
				var ra = pfd_hash.altitude_radio;
				if (ra == nil) ra = 2510;
				var pitch = pfd_hash.attitude_pitch;
				returned.svg_items.alt_ground_level.setTranslation(0, ra * 20 / 100 * scale_constant);
				if (ra < 30) {
					returned.svg_items.fdroll.hide();
					returned.svg_items.ils_rollout.show();
				} else {
					returned.svg_items.fdroll.show();
					returned.svg_items.ils_rollout.hide();
				}
				if (ra > 2500) {
					returned.svg_items.radioaltimeter.hide();
					returned.hud_svg_items.ra.hide();
				} else {
					returned.svg_items.radioaltimeter.show();
					returned.hud_svg_items.ra.show();
					var bottom_mask_translation_ra = ra;
					if (ra > 50) bottom_mask_translation_ra = 50;
					if (ra < 0) bottom_mask_translation_ra = 0;
					var bottom_mask_translation = -86.621 * (50 - bottom_mask_translation_ra) / 50;
					bottom_mask_translation += math.min(70, math.max(-70, pitch_to_px(pitch))) * (50 - bottom_mask_translation_ra) / 50;
					returned.svg_items.bottom_mask_ground.setTranslation(0, bottom_mask_translation * scale_constant);
					var roundTo = 1;
					if (ra > 5) roundTo = 5;
					if (ra > 50) roundTo = 10;
					returned.svg_items.radioaltimeter.updateText(sprintf("%d", math.round(ra / roundTo) * roundTo));
					returned.hud_svg_items.ra.updateText(sprintf("%d", math.round(ra / roundTo) * roundTo));
				}
			}),
			props.UpdateManager.FromHashValue('airspeed_indicated', 0.1, func(speed) {
				if (speed < 30) speed = 30;
				if (speed > 72) returned.svg_items.airspeed_bottom_line.show();
				else returned.svg_items.airspeed_bottom_line.hide();
				returned.hud_svg_items.moves_with_speed.setTranslation(0, 7.8 / 8 * (speed - 30));
				returned.svg_items.airspeed.setTranslation(0, 2.645 * (speed - 30) * scale_constant);
			}),
			props.UpdateManager.FromHashValue('airspeed_gd', 0.1, func(green_dot) {
				returned.svg_items.green_dot_speed.setTranslation(0, -2.645 * (green_dot - 30) * scale_constant);
			}),
			props.UpdateManager.FromHashValue('airspeed_delta', 0.05, func(delta) {
				returned.svg_items.speed_selected.setTranslation(0, -2.645 * (delta) * scale_constant);
				returned.hud_svg_items.speed_selected.setTranslation(0, -7.8 / 8 * (delta));
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
				returned.hud_svg_items.overspeed.setTranslation(0, -7.8 / 8 * (maxspeed - 30));
			}),
			props.UpdateManager.FromHashValue('airspeed_vamax', 0.1, func(vamax) {
				returned.svg_items.stall.setTranslation(0, -2.645 * (vamax - 30) * scale_constant);
				returned.hud_svg_items.stall.setTranslation(0, -7.8 / 8 * (vamax - 30));
			}),
			props.UpdateManager.FromHashValue('airspeed_vaprot', 0.1, func(vaprot) {
				returned.svg_items.alpha_prot.setTranslation(0, -2.645 * (vaprot - 30) * scale_constant);
				returned.hud_svg_items.alpha_prot.setTranslation(0, -7.8 / 8 * (vaprot - 30));
			}),
			props.UpdateManager.FromHashValue('airspeed_vls', 0.1, func(vls) {
				returned.svg_items.vls.setTranslation(0, -2.645 * (vls - 30) * scale_constant);
				returned.hud_svg_items.vls.setTranslation(0, -7.8 / 8 * (vls - 30));
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
				if (text == '') {
					returned.fma.fma_5_ap.hide();
					returned.hud_svg_items.fpv_circle.show();
					returned.hud_svg_items.fpv_circle_shadow.show();
					returned.hud_svg_items.fpv_diamond.hide();
					returned.hud_svg_items.fpv_diamond_shadow.hide();
					text = 'NOPE';
				} else {
					returned.hud_svg_items.fpv_circle.hide();
					returned.hud_svg_items.fpv_circle_shadow.hide();
					returned.hud_svg_items.fpv_diamond.show();
					returned.hud_svg_items.fpv_diamond_shadow.show();
					returned.fma.fma_5_ap.show();
				}
				returned.fma.fma_5_ap.set(text);
			}),
			props.UpdateManager.FromHashValue('fd_enabled', 0.5, func(value) {
				if (value) {
					returned.svg_items.guides.show();
					returned.hud_svg_items.fpd.show();
					returned.fma.fma_5_fd.show();
				} else {
					returned.svg_items.guides.hide();
					returned.hud_svg_items.fpd.hide();
					returned.fma.fma_5_fd.hide();
				}
			}),
			props.UpdateManager.FromHashValue('fd_athr_enabled', 0.5, func(enabled) {
				if (enabled) {
					returned.svg_items.fma_1_man.hide();
					returned.fma.fma_5_athr.setColor([1, 1, 1]);
				} else {
					returned.svg_items.fma_1_man.show();
					returned.fma.fma_5_athr.setColor([0, 1, 1]);
				}
			}),
			props.UpdateManager.FromHashValue('fd_athr', 0.5, func(value) {
				if (value) {
					returned.svg_items.fma_1.show();
					returned.fma.fma_5_athr.show();
				} else {
					returned.svg_items.fma_1.hide();
					returned.fma.fma_5_athr.hide();
				}
			}),
			props.UpdateManager.FromHashValue('fd_trk_fpa', 0.5, func(trk) {
				if (trk) returned.svg_items.fpv.setColor(13 / 255, 192 / 255, 75 / 255);
				else returned.svg_items.fpv.setColor(0, 0, 0);
			}),
			props.UpdateManager.FromHashValue('fd_roll', 0.05, func(roll) {
				returned.svg_items.fdroll.setTranslation(roll * 2.2 * scale_constant, 0);
			}),
			props.UpdateManager.FromHashList(['fd_fpa', 'fd_trk'], 0.02, func(hash) {
				returned.hud_svg_items.fpd.setTranslation(hud_heading_scale * hash.fd_trk, -hud_pitch_scale * hash.fd_fpa);
			}),
			props.UpdateManager.FromHashValue('fd_pitch', 0.05, func(pitch_offset) {
				if (pitch_offset < -9) pitch_offset = -9;
				if (pitch_offset > 9) pitch_offset = 9;
				returned.svg_items.fdpitch.setTranslation(0, -pitch_to_px(pitch_offset) / 2 * scale_constant);
			}),
			props.UpdateManager.FromHashValue('ls', 0.5, func(ls) {
				if (ls) {
					returned.svg_items.ils.show();
					returned.svg_items.ils_course.show();
					returned.svg_items.ils_course_text.show();
					returned.hud_svg_items.gs.show();
					returned.hud_svg_items.loc.show();
					returned.hud_svg_items.ils_course.show();
				} else {
					returned.svg_items.ils.hide();
					returned.svg_items.ils_course.hide();
					returned.svg_items.ils_course_text.hide();
					returned.hud_svg_items.gs.hide();
					returned.hud_svg_items.loc.hide();
					returned.hud_svg_items.ils_course.hide();
				}
			}),
			props.UpdateManager.FromHashValue('ils_gs', 0.0025, func(gs) {
				returned.svg_items.gs.setTranslation(0, -80 * gs * scale_constant);
				returned.hud_svg_items.gs_needle.setTranslation(-18 * gs, 0);
				if (gs > 0.999) {
					returned.svg_items.gs_up.show();
					returned.hud_svg_items.gs_needle_up.show();
					returned.svg_items.gs_down.hide();
					returned.hud_svg_items.gs_needle_down.hide();
				} else if (gs < -0.999) {
					returned.svg_items.gs_up.hide();
					returned.hud_svg_items.gs_needle_up.hide();
					returned.svg_items.gs_down.show();
					returned.hud_svg_items.gs_needle_down.show();
				} else {
					returned.svg_items.gs_up.show();
					returned.hud_svg_items.gs_needle_up.show();
					returned.svg_items.gs_down.show();
					returned.hud_svg_items.gs_needle_down.show();
				}
			}),
			props.UpdateManager.FromHashValue('ils_gs_in_range', 0.5, func(gs_in_range) {
				if (gs_in_range) {
					returned.svg_items.gs.show();
					returned.hud_svg_items.gs_needle.show();
				} else {
					returned.svg_items.gs.hide();
					returned.hud_svg_items.gs_needle.hide();
				}
			}),
			props.UpdateManager.FromHashValue('ils_loc', 0.0025, func(loc) {
				returned.svg_items.loc.setTranslation(80 * loc * scale_constant, 0);
				returned.hud_svg_items.loc_needle.setTranslation(18 * loc, 0);
				returned.svg_items.ils_rollout.setTranslation(90 * loc * scale_constant, 0);
				if (loc > 0.999) {
					returned.svg_items.loc_right.show();
					returned.hud_svg_items.loc_needle_right.show();
					returned.svg_items.loc_left.hide();
					returned.hud_svg_items.loc_needle_left.hide();
				} else if (loc < -0.999) {
					returned.svg_items.loc_right.hide();
					returned.hud_svg_items.loc_needle_right.hide();
					returned.svg_items.loc_left.show();
					returned.hud_svg_items.loc_needle_left.show();
				} else {
					returned.svg_items.loc_right.show();
					returned.hud_svg_items.loc_needle_right.show();
					returned.svg_items.loc_left.show();
					returned.hud_svg_items.loc_needle_left.show();
				}
			}),
			props.UpdateManager.FromHashValue('ils_loc_in_range', 0.5, func(loc_in_range) {
				if (loc_in_range) {
					returned.svg_items.loc.show();
					returned.hud_svg_items.loc_needle.show();
				} else {
					returned.svg_items.loc.hide();
					returned.hud_svg_items.loc_needle.hide();
				}
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
			props.UpdateManager.FromHashValue('wing_speedbrake', 0.01, func(speedbrake) {
				if (speedbrake < 0.1) returned.svg_items.spoiler.hide();
				else returned.svg_items.spoiler.show();
				returned.svg_items.spoiler.setRotation(-90 / 1.5 * speedbrake * math.pi / 180);
			}),
			props.UpdateManager.FromHashValue('wing_speedbrake_scale', 0.01, func(speedbrake) {
				if (speedbrake) returned.svg_items.wing_spoiler.show();
				else returned.svg_items.wing_spoiler.hide();
			}),
			props.UpdateManager.FromHashValue('wing_speedbrake_arm', 0.5, func(arm) {
				if (arm) returned.svg_items.wing_spoiler_arm.show();
				else returned.svg_items.wing_spoiler_arm.hide();
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
			yaw_offset: props.globals.getNode('/systems/pfd/heading-rounded'),
			yaw_number: props.globals.getNode('/systems/pfd/heading-number'),
			heading_offset: props.globals.getNode('/systems/pfd/heading-rounded'),
			drift: props.globals.getNode('/it-autoflight/internal/drift-angle-deg'),
			true_heading: props.globals.getNode('/orientation/heading-deg')
		};
		hash.fd = {
			enabled: props.globals.getNode('/it-autoflight/output/fd1'),
			roll: props.globals.getNode('/it-autoflight/fd/roll-bar'),
			pitch: props.globals.getNode('/it-autoflight/fd/pitch-bar'),
			fpa: props.globals.getNode('/systems/pfd/fpd-angle'),
			trk: props.globals.getNode('/systems/pfd/fpd-lateral'),
			athr: props.globals.getNode('/it-autoflight/input/athr'),
			athr_enabled: props.globals.getNode('/systems/fadec/throttle/athr'),
			ap1: props.globals.getNode('/it-autoflight/input/ap1'),
			ap2: props.globals.getNode('/it-autoflight/input/ap2'),
			detent: props.globals.getNode('/systems/fadec/throttle/max-detent'),
			flex: props.globals.getNode('/systems/fadec/limit/takeoff/flex-active'),
			temp: props.globals.getNode('/fms/perf/takeoff/flex-temp'),
			dto: props.globals.getNode('/systems/fadec/limit/takeoff/dto-active')
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
			slat_cmd: props.globals.getNode('/fdm/jsbsim/fcs/slat-cmd-norm'),
			speedbrake: props.globals.getNode('/systems/pfd/spoiler'),
			speedbrake_scale: props.globals.getNode('/systems/pfd/spoiler-scale'),
			speedbrake_arm: props.globals.getNode('/controls/flight/speedbrake-armed')
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
			gs_in_range: props.globals.getNode('/instrumentation/nav/gs-in-range'),
			synthetic_runway_1: props.globals.getNode('/systems/pfd/synthetic-runway/corner-1/pitch'),
			synthetic_runway_2: props.globals.getNode('/systems/pfd/synthetic-runway/corner-1/yaw'),
			synthetic_runway_3: props.globals.getNode('/systems/pfd/synthetic-runway/corner-2/pitch'),
			synthetic_runway_4: props.globals.getNode('/systems/pfd/synthetic-runway/corner-2/yaw'),
			synthetic_runway_5: props.globals.getNode('/systems/pfd/synthetic-runway/corner-3/pitch'),
			synthetic_runway_6: props.globals.getNode('/systems/pfd/synthetic-runway/corner-3/yaw'),
			synthetic_runway_7: props.globals.getNode('/systems/pfd/synthetic-runway/corner-4/pitch'),
			synthetic_runway_8: props.globals.getNode('/systems/pfd/synthetic-runway/corner-4/yaw'),
		};
		hash.fma = {
			vs: props.globals.getNode('/it-autoflight/input/vs'),
			fpa: props.globals.getNode('/it-autoflight/input/fpa'),
			trk_fpa: props.globals.getNode('/it-autoflight/input/trk')
		};
		hash.gear = {
			transit_up: props.globals.getNode('/systems/pfd/gear-transit-up'),
			transit_down: props.globals.getNode('/systems/pfd/gear-transit-down'),
			down: props.globals.getNode('/systems/pfd/gear-down'),
			park_brk: props.globals.getNode('/controls/gear/brake-parking')
		};
		hash.hud = {
			scale: props.globals.getNode('/sim/current-view/hud-scale-raw')
		};
	},
	update: func() {
		var pfd_props = me.pfd_props;
		# generate notification
		var notification = {};
		foreach (key; keys(me.pfd_props)) {
			foreach (key2; keys(me.pfd_props[key])) {
				if (me.pfd_props[key][key2] == nil) print('pfd prop ' ~ key ~ "_" ~ key2 ~ " does not exist!!!");
				notification[key ~ "_" ~ key2] = me.pfd_props[key][key2].getValue();
			}
		}
		notification.ls = me.properties.ls.getValue();
		notification.vv = me.properties.vv.getValue();
		foreach (item; me.update_items) item.update(notification);
		# update synthetic runway
		if (notification.ls) {
			me.hud_svg_items.runway_group.show();
			if (me.property_number == 0) update_synthetic_runway(notification.altitude_indicated, notification.attitude_true_heading, [
				pfd_props.ils.synthetic_runway_1,
				pfd_props.ils.synthetic_runway_2,
				pfd_props.ils.synthetic_runway_3,
				pfd_props.ils.synthetic_runway_4,
				pfd_props.ils.synthetic_runway_5,
				pfd_props.ils.synthetic_runway_6,
				pfd_props.ils.synthetic_runway_7,
				pfd_props.ils.synthetic_runway_8
			]);
			
			if (selected_runway != nil) {
				var new_synthetic_runway_item = me.hud_svg_items.runway_group.createChild('path');
				new_synthetic_runway_item.setColor(0, 1, 0);
				new_synthetic_runway_item.setStrokeLineWidth(0.75);
				new_synthetic_runway_item.moveTo(146.5 + notification.ils_synthetic_runway_2 * hud_heading_scale, 63.943 - notification.ils_synthetic_runway_1 * hud_pitch_scale);
				new_synthetic_runway_item.lineTo(146.5 + notification.ils_synthetic_runway_4 * hud_heading_scale, 63.943 - notification.ils_synthetic_runway_3 * hud_pitch_scale);
				new_synthetic_runway_item.lineTo(146.5 + notification.ils_synthetic_runway_6 * hud_heading_scale, 63.943 - notification.ils_synthetic_runway_5 * hud_pitch_scale);
				new_synthetic_runway_item.lineTo(146.5 + notification.ils_synthetic_runway_8 * hud_heading_scale, 63.943 - notification.ils_synthetic_runway_7 * hud_pitch_scale);
				new_synthetic_runway_item.lineTo(146.5 + notification.ils_synthetic_runway_2 * hud_heading_scale, 63.943 - notification.ils_synthetic_runway_1 * hud_pitch_scale);
				new_synthetic_runway_item.update();
			}
			if (me.synthetic_runway_item) me.synthetic_runway_item.del();
			if (selected_runway != nil) me.synthetic_runway_item = new_synthetic_runway_item;
		} else {
			me.hud_svg_items.runway_group.hide();
		}
		# update fma
		foreach (key; keys(me.fma)) {
			me.fma[key].update(time.getValue(), key);
		}
		var athr_mode_show = pfd_props.fd.athr_enabled.getValue() and (itaf.UpdateFma.thrText != nil) and (itaf.UpdateFma.thrText != '');
		if (athr_mode_show) {
			me.fma.fma_1_athr_mode.set(itaf.UpdateFma.thrText);
			me.fma.fma_1_athr_mode.show();
		} else {
			me.fma.fma_1_athr_mode.hide();
			me.fma.fma_1_athr_mode.set('potato');
		}
		me.svg_items.fma_1_orange_box.hide();
		if (pfd_props.fd.detent.getValue() == 4) {
			# toga detent
			me.svg_items.fma_1_flex_temp.hide();
			me.svg_items.fma_1_flex_box.hide();
			me.svg_items.fma_1_man_mode.updateText('TOGA');
		} else if (pfd_props.fd.detent.getValue() == 3) {
			# flex mct detent
			me.svg_items.fma_1_flex_temp.hide();
			me.svg_items.fma_1_flex_box.hide();
			if (pfd_props.fd.flex.getValue()) {
				me.svg_items.fma_1_flex_box.show();
				me.svg_items.fma_1_flex_temp.show();
				me.svg_items.fma_1_man_mode.updateText('FLX    ');
				me.svg_items.fma_1_flex_temp.updateText(sprintf('+%d', pfd_props.fd.temp.getValue()));
			} else if (pfd_props.fd.dto.getValue()) {
				me.svg_items.fma_1_man_mode.updateText('DTO');
			} else {
				me.svg_items.fma_1_man_mode.updateText('MCT');
			}
		} else {
			me.svg_items.fma_1_flex_temp.hide();
			me.svg_items.fma_1_flex_box.hide();
			me.svg_items.fma_1_orange_box.show();
			me.svg_items.fma_1_man_mode.updateText('THR');
		}
		if (itaf.UpdateFma.latText != nil) {
			me.fma.fma_3_top.show();
			me.fma.fma_3_top.set(itaf.UpdateFma.latText);
		} else {
			me.fma.fma_3_top.hide();
			me.fma.fma_3_top.set('nothing');
		}
		if (itaf.UpdateFma.vertText != 'FPA' and itaf.UpdateFma.vertText != 'V/S') {
			if (itaf.UpdateFma.vertText != nil) {
				me.fma.fma_2_top.show();
				me.fma.fma_2_top.set(itaf.UpdateFma.vertText);
			} else {
				me.fma.fma_2_top.hide();
				me.fma.fma_2_top.set('nothing');
			}
			me.svg_items.fma_2_vs_value.hide();
		} else {
			me.fma.fma_2_top.show();
			me.svg_items.fma_2_vs_value.show();
			me.fma.fma_2_top.set(itaf.UpdateFma.vertText ~ "     ");
			var vs_value = "";
			if (itaf.UpdateFma.vertText == 'V/S') {
				vs_value_raw = pfd_props.fma.vs.getValue();
				if (vs_value_raw >= 0) vs_value = "+";
				else vs_value = "";
				vs_value ~= sprintf("%d", vs_value_raw);
			} else {
				vs_value_raw = pfd_props.fma.fpa.getValue();
				if (vs_value_raw >= 0) vs_value = "+";
				else vs_value = "";
				vs_value ~= sprintf("%.1f", vs_value_raw);
			}
			me.svg_items.fma_2_vs_value.updateText(vs_value);
		}
		if ((itaf.UpdateFma.latText == itaf.UpdateFma.vertText and itaf.UpdateFma.latText != '' and itaf.UpdateFma.latText != nil) or (itaf.UpdateFma.latText == 'FLARE')) {
			# land or flare or rollout
			me.fma['fma_2.5'].set(itaf.UpdateFma.latText);
			me.svg_items.fma_2_3.hide();
			me.fma['fma_2.5'].show();
		} else {
			me.svg_items.fma_2_3.show();
			me.fma['fma_2.5'].hide();
		}
		var gsArm = itaf.Output.gsArm.getBoolValue();
		var locArm = itaf.Output.locArm.getBoolValue();
		var lnavArm = itaf.Output.lnavArm.getBoolValue();
		var altArm = itaf.Output.altArm.getBoolValue();
		var vert_arm_text = "";
		if (altArm and !gsArm) vert_arm_text ~= "ALT";
		if (altArm and gsArm) vert_arm_text = "ALT G/S";
		if (gsArm and !altArm) vert_arm_text = "G/S";
		if (vert_arm_text != '') {
			me.fma.fma_2_middle.show();
			me.fma.fma_2_middle.set(vert_arm_text);
		} else {
			me.fma.fma_2_middle.hide();
			me.fma.fma_2_middle.set('nothing');
		}

		var lat_arm_text = "";
		if (lnavArm and !locArm) lat_arm_text ~= "NAV";
		if (lnavArm and locArm) lat_arm_text = "NAV LOC";
		if (locArm and !lnavArm) lat_arm_text = "LOC";
		if (lat_arm_text != '') {
			me.fma.fma_3_middle.show();
			me.fma.fma_3_middle.set(lat_arm_text);
		} else {
			me.fma.fma_3_middle.hide();
			me.fma.fma_3_middle.set('nothing');
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
		if (speed_trend > 0) {
			me.svg_items.speed_trend_up.show();
			me.svg_items.speed_trend_down.hide();
		} else {
			me.svg_items.speed_trend_up.hide();
			me.svg_items.speed_trend_down.show();
		}
		if (abs(speed_trend) > 2) {
			me.svg_items.speed_trend.setTranslation(0, -speed_trend * 2.645 * scale_constant);
			me.svg_items.speed_trend.show();
		}
		me.hud_svg_items.chevrons.setTranslation(0, -speed_trend * 2);
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
			me.hud_svg_items.ils_frequency.updateText(sprintf("%.02f", pfd_props.ils.frequency.getValue()));
			var gs = me.pfd_props.ils.gs.getValue();
			var loc = me.pfd_props.ils.loc.getValue();
			me.svg_items.ils_ident.updateText(me.pfd_props.ils.name.getValue());
			me.hud_svg_items.ils_ident.updateText(me.pfd_props.ils.name.getValue());
			if (me.pfd_props.ils.dme_in_range.getValue()) {
				me.svg_items.ils_distance.updateText(sprintf("%.1f", me.pfd_props.ils.dme.getValue()));
				me.hud_svg_items.ils_distance.updateText(sprintf("%.1f", me.pfd_props.ils.dme.getValue()));
				me.svg_items.ils_distance.show();
				me.svg_items.ils_distance_label.show();
				me.hud_svg_items.ils_dme.show();
			} else {
				me.svg_items.ils_distance.hide();
				me.svg_items.ils_distance_label.hide();
				me.hud_svg_items.ils_dme.hide();
			}
			me.svg_items.ils.show();
		} else me.svg_items.ils.hide();
	},
	svg_items: {}
};
var time = props.globals.getNode('/sim/time/elapsed-sec');
var fma_line = {
	new: func(group, element, default_value, default_color, default_visibility) {
		var returned = {parents: [fma_line]};
		returned.last_update = 0;
		returned.box = 0;
		returned.element = group.getElementById(element);
		returned.element.enableUpdate();
		returned.box_element = group.getElementById(element ~ "_box");
		returned.value = default_value;
		returned.color = default_color;
		returned.visibility = default_visibility;
		if (returned.visibility) returned.element.hide();
		return returned;
	},
	show: func() {
		if (me.visibility == 0) me.last_update = time.getValue();
		me.visibility = 1;
	},
	hide: func() {
		me.visibility = 0;
	},
	set: func(text) {
		if (text == me.value) return;
		if (text != me.value and text != '') me.last_update = time.getValue();
		me.value = text;
		me.element.updateText(text);
	},
	setColor: func(color) {
		if (color[0] != me.color[0] and
		    color[1] != me.color[1] and
		    color[2] != me.color[2]) {
			me.last_update = time.getValue();
		}
		me.color = [color[0], color[1], color[2]];
		me.element.setColor(color[0], color[1], color[2]);
	},
	update: func(t, key) {
		var cond = ((me.last_update + 10) > t) and me.visibility;
		#me.element.updateText(sprintf('%d', t - me.last_update));
		me.element.setVisible(me.visibility);
		me.box_element.setVisible(((me.last_update + 10) > t) and me.visibility);
	}
};
var convert_fl = func(number) {
	var as_string = sprintf("%03d", math.abs(number));
	return as_string;
}
var pfd1 = pfd.new('PFD_L', 0, 'captain_hud');
var pfd2 = pfd.new('PFD_R', 1, 'fo_hud');