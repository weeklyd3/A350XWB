var ecam = {
	new: func(name) {
		print('creating ecam with name', name);
		var display = canvas.new({
			"name": name,   # The name is optional but allow for easier identification
			"size": [2048, 2048], # Size of the underlying texture (should be a power of 2, required) [Resolution]
			"view": [889.646, 564.196],  # Virtual resolution (Defines the coordinate system of the canvas [Dimensions]
						# which will be stretched the size of the texture, required)
			"mipmapping": 1       # Enable mipmapping (optional)
		});
		me.display = display;
		var path = "Aircraft/A350XWB/Models/Instruments/Upper-ECAM/ecam.svg";
		# create an image child
		var group = display.createGroup('svg');
		canvas.parsesvg(group, path);
		foreach (elem; ["thr_text_l", "thr_needle_l", "donut_l", "thr_text_r", "thr_needle_r", "donut_r", "n1_left", "n1_right", "tat_temp", "sat_temp", "isa_temp", "utc"]) {
			me.svg_items[elem] = group.getElementById(elem);
		}
		foreach (elem; ["thr_text_l", "thr_text_r", "n1_left", "n1_right", "tat_temp", "sat_temp", "isa_temp", "utc"]) {
			me.svg_items[elem].enableUpdate();
		}
		me.svg_items["thr_needle_l"].setCenter(150.485, 75.63);
		me.svg_items["thr_needle_r"].setCenter(150.485, 75.63);
		me.svg_items["donut_l"].setCenter(150.485, 75.63);
		me.svg_items["donut_r"].setCenter(292.486, 75.63);
		setlistener("engines/engine/thr", func(value) {
			var thr = value.getValue();
			me.svg_items.thr_text_l.updateText(sprintf("%.1f", math.round(thr * 10) / 10));
			me.svg_items.thr_needle_l.setRotation((-120 + 210 * thr / 100) * math.pi / 180);
		}, 1, 0);
		setlistener("engines/engine[1]/thr", func(value) {
			var thr = value.getValue();
			me.svg_items.thr_text_r.updateText(sprintf("%.1f", math.round(thr * 10) / 10));
			me.svg_items.thr_needle_r.setRotation((-120 + 210 * thr / 100) * math.pi / 180);
		}, 1, 0);
		setlistener("engines/engine/n1", func(value) {
			var n1 = value.getValue();
			me.svg_items.n1_left.updateText(sprintf("%.1f", n1));
		});
		setlistener("engines/engine[1]/n1", func(value) {
			var n1 = value.getValue();
			me.svg_items.n1_right.updateText(sprintf("%.1f", n1));
		});
		setlistener("instrumentation/clock/indicated-string", func(value) {
			me.svg_items.utc.updateText(value.getValue());
		});
		setprop("/instrumentation/ecam/active-page", "apu");
		me.pages['hyd'] = hyd_page.new(display, group);
		me.pages['apu'] = apu_page.new(display, group);
		foreach (var page; keys(me.pages)) {
			setprop("/instrumentation/ecam/" ~ page ~ "-active", 0);
		}
		setlistener("/instrumentation/ecam/active-page", func(value) {
			foreach (var page; keys(me.pages)) {
				if (page != value.getValue()) {
					print('hiding page ', page);
					setprop("/instrumentation/ecam/" ~ page ~ "-active", 0);
					me.pages[page].hide();
				} else {
					me.pages[page].show();
					setprop("/instrumentation/ecam/" ~ page ~ "-active", 1);
					me.pages[page].update_all();
				}
			}
		}, 1, 0);
		display.addPlacement({"node": name});
		return {"parents": ecam};
	},
	pages: {},
	svg_items: {},
	show: func() {
		var window = canvas.Window.new([889, 564], "dialog");
		window.setCanvas(me.display);
	}
};
var hyd_page = {
	new: func(draw, svg_group) {
		me.canvas = draw;
		foreach (elem; ["yellow_quantity", "green_quantity", "hyd"]) {
			me.svg_items[elem] = svg_group.getElementById(elem);
		}
		foreach (elem; ["yellow_pressure", "green_pressure"]) {
			me.svg_items[elem] = svg_group.getElementById(elem);
			me.svg_items[elem].enableUpdate();
		}
		foreach (elem; ["green", "yellow"]) {
			foreach (elem2; ["supply", "pump"]) {
				foreach (elem3; ["on", "off"]) {
					foreach (elem4; ["1", "2"]) {
						var name = "eng" ~ elem4 ~ elem ~ elem2 ~ "_" ~ elem3;
						me.svg_items[name] = svg_group.getElementById(name);
						if (elem3 == "off") {
							var on_or_off_bool = 0;
							var engine = "engine";
							if (elem4 == "1") engine = "engine";
							else engine = "engine[1]";
							if (elem2 == "pump") on_or_off_bool = getprop("/engines/" ~ engine ~ "/" ~ elem ~ "-pump");
							else on_or_off_bool = 1;
							var on_or_off = "off";
							if (on_or_off_bool) on_or_off = "on";
							me.update_valve(elem4, elem, elem2, on_or_off);
						}
					}
				}
			}
		}
		setlistener("/systems/hydraulic/green-pressure", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_pressure('green', value.getValue());
		});
		setlistener("/systems/hydraulic/yellow-pressure", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_pressure('yellow', value.getValue());
		});
		# this is a mess!
		setlistener("engines/engine/yellow-pump", func(value) {
			if (!me.am_i_on_screen()) return;
			var on_or_off = 'off';
			if (value.getValue()) on_or_off = 'on';
			me.update_valve('1', 'yellow', 'pump', on_or_off);
		});
		setlistener("engines/engine[1]/yellow-pump", func(value) {
			if (!me.am_i_on_screen()) return;
			var on_or_off = 'off';
			if (value.getValue()) on_or_off = 'on';
			me.update_valve('2', 'yellow', 'pump', on_or_off);
		});
		setlistener("engines/engine/green-pump", func(value) {
			if (!me.am_i_on_screen()) return;
			var on_or_off = 'off';
			if (value.getValue()) on_or_off = 'on';
			me.update_valve('1', 'green', 'pump', on_or_off);
		});
		setlistener("engines/engine[1]/green-pump", func(value) {
			if (!me.am_i_on_screen()) return;
			var on_or_off = 'off';
			if (value.getValue()) on_or_off = 'on';
			me.update_valve('2', 'green', 'pump', on_or_off);
		});
		return {"parents": [hyd_page]};
	},
	hide: func() {
		me.svg_items['hyd'].hide();
	},
	show: func() {
		me.svg_items['hyd'].show();
	},
	am_i_on_screen: func() {
		return getprop("/instrumentation/ecam/active-page") == "hyd";
	},
	update_pressure: func(system, pressure) {
		# system: 'green' or 'yellow'
		me.svg_items[system ~ "_pressure"].updateText(sprintf("%d", pressure));
	},
	update_valve: func(eng, system, supply_or_pump, on_or_off) {
		# eng: 1 or 2
		# supply_or_pump: 'supply' or 'pump'
		# on_or_off: 'on' or 'off'
		var opposite = "";
		if (on_or_off == "on") opposite = "off";
		if (on_or_off == "off") opposite = "on";
		me.svg_items['eng' ~ eng ~ system ~ supply_or_pump ~ "_" ~ on_or_off].show();
		me.svg_items['eng' ~ eng ~ system ~ supply_or_pump ~ "_" ~ opposite].hide();
	},
	update_all: func() {
		me.update_pressure('green', getprop("/systems/hydraulic/green-pressure"));
		me.update_pressure('yellow', getprop("/systems/hydraulic/yellow-pressure"));
		foreach (elem; ["green", "yellow"]) {
			foreach (elem2; ["supply", "pump"]) {
				foreach (elem3; ["on", "off"]) {
					foreach (elem4; ["1", "2"]) {
						var name = "eng" ~ elem4 ~ elem ~ elem2 ~ "_" ~ elem3;
						if (elem3 == "off") {
							var on_or_off_bool = 0;
							var engine = "engine";
							if (elem4 == "1") engine = "engine";
							else engine = "engine[1]";
							if (elem2 == "pump") on_or_off_bool = getprop("/engines/" ~ engine ~ "/" ~ elem ~ "-pump");
							else on_or_off_bool = 1;
							var on_or_off = "off";
							if (on_or_off_bool) on_or_off = "on";
							me.update_valve(elem4, elem, elem2, on_or_off);
						}
					}
				}
			}
		}
	},
	svg_items: {}
};
var apu_page = {
	new: func(draw, svg_group) {
		me.canvas = draw;
		foreach (elem; ["apu", "apu_n_needle", "egt_needle", "apu_avail", "apu_gen_stats", "apu_gen_border", "apu_gen_off", "apu_gen_text", "apu_gen_connection", "apu_gen_avail", "apu_bleed_closed", "apu_bleed_open"]) {
			me.svg_items[elem] = svg_group.getElementById(elem);
		}
		#me.svg_items.apu_n_needle.updateCenter();
		me.svg_items.apu_n_needle.setCenter(68.620262, 460.778);
		me.svg_items.egt_needle.setCenter(68.620262, 460.778);
		print('center set');
		foreach (elem; ["apu_n_text", "apu_flap", "apu_egt_text", "apu_gen_hz", "apu_gen_voltage", "apu_gen_load", "apu_bleed_psi"]) {
			me.svg_items[elem] = svg_group.getElementById(elem);
			me.svg_items[elem].enableUpdate();
		}
		setlistener("/systems/apu/n", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_n(value.getValue());
 		}, 1, 0);
		setlistener("/systems/apu/flap", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_flap(value.getValue());
 		}, 1, 0);
		setlistener("/systems/apu/egt", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_egt(value.getValue());
		}, 1, 0);
		setlistener("/systems/apu/avail", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_avail(value.getValue());
		}, 1, 0);
		setlistener("/systems/apu/gen-ready", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_gen_stats();
		}, 1, 0);
		setlistener("/systems/apu/gen", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_gen_on(value.getValue());
		}, 1, 0);
		setlistener("/systems/apu/bleed", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_bleed(value.getValue());
		}, 1, 0);
		setlistener("/systems/apu/gen-connection", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_connection(value.getValue());
		}, 1, 0);
		return {"parents": [apu_page]};
	},
	update_n: func(n) {
		me.svg_items.apu_n_needle.setRotation((-135 + 1.80 * n) * math.pi / 180);
		me.svg_items['apu_n_text'].updateText(sprintf("%d", n));
	},
	update_flap: func(flap) {
		if (!flap) me.svg_items['apu_flap'].updateText('');
		else if (flap > 0.95) me.svg_items['apu_flap'].updateText('FLAP OPEN');
		else me.svg_items['apu_flap'].updateText('FLAP MOVING');
	},
	update_egt: func(egt) {
		me.svg_items.apu_egt_text.updateText(sprintf("%d", math.round(egt / 5) * 5));
		me.svg_items.egt_needle.setRotation((240 * egt / 1000 - 135) * math.pi / 180);
	},
	update_avail: func(avail) {
		if (avail) {
			me.svg_items.apu_avail.show();
			me.svg_items.apu_gen_avail.show();
		} else {
			me.svg_items.apu_avail.hide();
			me.svg_items.apu_gen_avail.hide();
		}
	},
	update_gen_stats: func() {
		me.svg_items.apu_gen_hz.updateText(sprintf("%d", getprop("/systems/apu/gen-hz")));
		me.svg_items.apu_gen_voltage.updateText(sprintf("%d", getprop("/systems/apu/gen-voltage")));
		me.svg_items.apu_bleed_psi.updateText(sprintf("%d", getprop("/systems/apu/bleed-psi")));
	},
	update_gen_on: func(value) {
		if (value) {
			me.svg_items.apu_gen_off.hide();
			me.svg_items.apu_gen_stats.show();
		} else {
			me.svg_items.apu_gen_off.show();
			me.svg_items.apu_gen_stats.hide();
		}
	},
	update_connection: func(value) {
		if (value) me.svg_items.apu_gen_connection.setColor(0, 1, 0);
		else me.svg_items.apu_gen_connection.setColor(1, 1, 1);
	},
	update_bleed: func(value) {
		if (value) {
			me.svg_items.apu_bleed_closed.hide();
			me.svg_items.apu_bleed_open.show();
		} else {
			me.svg_items.apu_bleed_closed.show();
			me.svg_items.apu_bleed_open.hide();
		}
	},
	hide: func() {
		me.svg_items['apu'].hide();
	},
	show: func() {
		me.svg_items['apu'].show();
	},
	am_i_on_screen: func() {
		return getprop("/instrumentation/ecam/active-page") == "apu";
	},
	update_all: func() {
		me.update_n(getprop("/systems/apu/n"));
		me.update_flap(getprop("/systems/apu/flap"));
		me.update_egt(getprop("/systems/apu/egt"));
		me.update_avail(getprop("/systems/apu/avail"));
		me.update_gen_stats();
		me.update_gen_on(getprop("/systems/apu/gen"));
		me.update_bleed(getprop("/systems/apu/bleed"));
		me.update_connection(getprop("/systems/apu/gen-connection"));
	},
	svg_items: {}
};
var upper_ecam = ecam.new('upper_ecam');