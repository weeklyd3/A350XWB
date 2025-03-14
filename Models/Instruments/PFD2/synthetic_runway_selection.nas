var nav1 = props.globals.getNode('/instrumentation/nav/frequencies/selected-mhz');
var nav1_frequency = nav1.getValue();

var previous_airport_id = '';
var selected_runway = nil;
var update_selected_runway = func() {
	var info = airportinfo();
	if (info.id == previous_airport_id) return;
	previous_airport_id = info.id;
	foreach (runway; values(info.runways)) {
		if (runway.ils_frequency_mhz == nil or nav1_frequency == nil) continue;
		debug.dump(runway.id);
		debug.dump(runway.ils_frequency_mhz);
		debug.dump(nav1_frequency);
		if (math.abs(runway.ils_frequency_mhz - nav1_frequency) < 0.01) {
			# found the runway!
			selected_runway = runway;
			debug.dump(selected_runway.id);
		}
	}
}
var update_timer = maketimer(1, update_selected_runway);
update_timer.start();