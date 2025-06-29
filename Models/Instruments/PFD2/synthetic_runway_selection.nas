var nav1 = props.globals.getNode('/instrumentation/nav/frequencies/selected-mhz');
var override = props.globals.initNode('/systems/pfd/synthetic-runway/override-airport', '', 'STRING');
var previous_airport_id = '';
var previous_frequency = 0;
var selected_runway = nil;
var show_real_runway = 1;
var runway_corners = [[nil, nil], [nil, nil], [nil, nil], [nil, nil]];
var runway_corners_position = [[0, 0], [0, 0], [0, 0], [0, 0]];
var runway_elevation = 0;
var update_selected_runway = func() {
	var nav1_frequency = nav1.getValue();
	if (size(override.getValue()) >= 3) var info = airportinfo(override.getValue());
	else var info = airportinfo();
	var airport_id = info.id;
	if (airport_id == previous_airport_id and nav1_frequency == previous_frequency) return;
	previous_frequency = nav1_frequency;
	debug.dump(previous_frequency);
	previous_airport_id = info.id;
	selected_runway = nil;
	foreach (runway; values(info.runways)) {
		if (runway.ils_frequency_mhz == nil or nav1_frequency == nil) continue;
		if (math.abs(runway.ils_frequency_mhz - nav1_frequency) < 0.01) {
			# found the runway!
			selected_runway = runway;
			runway_elevation = runway.ils.elevation * M2FT;
			var runway_location = geo.Coord.new().set_latlon(runway.lat, runway.lon);
			var runway_location_2 = geo.Coord.new().set_latlon(runway.lat, runway.lon);
			if (show_real_runway) {
				print('length:             ', runway.length);
				print('width:              ', runway.width);
				print('course:             ', runway.heading);
				var threshold = runway_location.apply_course_distance(math.fmod(runway.heading, 360), 0 * runway.threshold);
				var opposite_threshold = runway_location_2.apply_course_distance(math.fmod(runway.heading, 360), runway.length + 0 * runway.threshold);
				print('threshold:          ', threshold.lat(), ', ', threshold.lon());
				print('opposite threshold: ', opposite_threshold.lat(), ', ', opposite_threshold.lon());
				threshold.apply_course_distance(math.fmod(runway.heading + 270, 360), runway.width / 2);
				runway_corners[0] = [threshold.lat(), threshold.lon()];
				threshold.apply_course_distance(math.fmod(runway.heading + 90, 360), runway.width);
				runway_corners[1] = [threshold.lat(), threshold.lon()];
				opposite_threshold.apply_course_distance(math.fmod(runway.heading + 90, 360), runway.width / 2);
				runway_corners[2] = [opposite_threshold.lat(), opposite_threshold.lon()];
				opposite_threshold.apply_course_distance(math.fmod(runway.heading + 270, 360), runway.width);
				runway_corners[3] = [opposite_threshold.lat(), opposite_threshold.lon()];
				debug.dump(runway_corners);
			}
		}
	}
}
var update_synthetic_runway = func(altitude, true_heading, nodes) {
	var position = geo.Coord.new().set(geo.aircraft_position()).apply_course_distance(true_heading, 32.7);
	# [pitch, yaw];
	if (runway_corners[0][0] == nil) return;
	var delta_altitude = runway_elevation - altitude;
	var distance_1 = position.distance_to(geo.Coord.new().set_latlon(runway_corners[0][0], runway_corners[0][1])) * M2FT;
	var distance_2 = position.distance_to(geo.Coord.new().set_latlon(runway_corners[1][0], runway_corners[1][1])) * M2FT;
	var distance_3 = position.distance_to(geo.Coord.new().set_latlon(runway_corners[2][0], runway_corners[2][1])) * M2FT;
	var distance_4 = position.distance_to(geo.Coord.new().set_latlon(runway_corners[3][0], runway_corners[3][1])) * M2FT;
	var course_1 = position.course_to(geo.Coord.new().set_latlon(runway_corners[0][0], runway_corners[0][1])) - true_heading;
	var course_2 = position.course_to(geo.Coord.new().set_latlon(runway_corners[1][0], runway_corners[1][1])) - true_heading;
	var course_3 = position.course_to(geo.Coord.new().set_latlon(runway_corners[2][0], runway_corners[2][1])) - true_heading;
	var course_4 = position.course_to(geo.Coord.new().set_latlon(runway_corners[3][0], runway_corners[3][1])) - true_heading;
	var pitch_1 = math.atan2(delta_altitude, distance_1) * R2D;
	var pitch_2 = math.atan2(delta_altitude, distance_2) * R2D;
	var pitch_3 = math.atan2(delta_altitude, distance_3) * R2D;
	var pitch_4 = math.atan2(delta_altitude, distance_4) * R2D;
	nodes[0].setValue(pitch_1);
	nodes[1].setValue(math.periodic(-180, 180, course_1));
	nodes[2].setValue(pitch_2);
	nodes[3].setValue(math.periodic(-180, 180, course_2));
	nodes[4].setValue(pitch_3);
	nodes[5].setValue(math.periodic(-180, 180, course_3));
	nodes[6].setValue(pitch_4);
	nodes[7].setValue(math.periodic(-180, 180, course_4));
}
var update_timer = maketimer(1, update_selected_runway);
update_timer.start();